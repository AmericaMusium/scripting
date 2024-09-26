#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <fakemeta_util>
#include <dodx>
#include <dodfun>
#include <fun>
#include <engine>

#define CLASS_MASTER "dod_control_point_master"
#define MAX_FLAGS 8

new bool:is_area_free[MAX_FLAGS]

new idx_sprt
new const g_sprt_mdl[] = "sprites/obj_icons/icon_obj_axis.spr" 



public plugin_precache()
{
   // idx_sprt = precache_model("sprites/obj_icons/icon_obj_axis.spr")   
}

public plugin_init()
{
   
	register_plugin("DOD Capture Flag", "may", "America")
    
    register_event("ObjScore","get_score","a") // Событие назначения очков при захвате флага. player , points

    //RegisterHam(Ham_Touch, "dod_control_point", "HAM_cpoint_touch_p")
	RegisterHam(Ham_Touch, "dod_capture_area", "HAM_carea_touch_p")

    /*
    RegisterHam(Ham_Think, CLASS_MASTER, "HAM_cp_master_THINK")

 
    register_clcmd("say cp","test_func")
    set_task(1.5, "test_func", 1)
 
    register_forward(FM_PrecacheGeneric, "fm_Prechache_generic_P");
    register_forward(FM_KeyValue, "fm_keyvalue");
    */
}



public HAM_cp_master_THINK(ent)
{
	//return HAM_SUPERCEDE
}

// Disable control points & capture areas
public HAM_cpoint_touch_p(id_flag, id_player)
{
    // client_print(0, print_chat, "POINT fl %d , pl %d",id_flag, id_player)
    /*
    entity_set_int(id_flag, EV_INT_movetype, MOVETYPE_FOLLOW) 
	entity_set_edict(id_flag, EV_ENT_aiment, id_player)
    */

     HAM_carea_touch_p(id_flag, id_player)

    new total_flags = objectives_get_num()
    new s_data[256]
    for(new i=0; i<total_flags; i++)
	{

        new cp_idx_ent =objective_get_data(i,CP_edict) 
        if(id_flag == cp_idx_ent)
        {

            new cp_area_idx = objective_get_data(i,CP_area) 
            server_print("Touch %d cp_index %d area: %d", id_flag, cp_idx_ent, cp_area_idx)
        }
       
	}
   
	return HAM_SUPERCEDE

}


// Disable control points & capture areas
public HAM_carea_touch_p(id_area, id_player)
{
    // is_area_free[i]
    // client_print(0, print_chat, "AREA fl %d , pl %d",id_flag, id_player)
    /*
    entity_set_int(id_flag, EV_INT_movetype, MOVETYPE_FOLLOW) 
	entity_set_edict(id_flag, EV_ENT_aiment, id_player)
    */
    new total_flags = objectives_get_num()
    new s_data[256]
    for(new i=0; i<total_flags ; i++)
	{
        new edict_area = objective_get_data(i, CP_area)
        area_set_data(i,CA_allies_numcap,4)
        if(edict_area == id_area)
            {
               // server_print("Area Entity: %d , HUD NUM %d" , edict_area,i )
                if(is_area_free[i]==false)
                {   
                    server_print("Area Entity: CLOSED %d , HUD NUM %d", edict_area, i)
                    return HAM_SUPERCEDE
                }
                else if(is_area_free[i]==true)
                {  
                    new team = get_user_team(id_player)
                    objective_set_data(i,CP_owner,team)
                
                    

                     server_print("Area Entity: FREE %d , HUD NUM %d " , edict_area,i)
                    return HAM_SUPERCEDE
                }
            }

        
	}
	return HAM_SUPERCEDE

}

public test_func(id)
{

    new total_flags = objectives_get_num()
    new s_data[256]
    for(new i=0; i<total_flags; i++)
	{
        new areanum
		areanum = objective_get_data(i,CP_area)
        server_print("Area id: %d", areanum)

        //objective_get_data(i,CP_model_allies, s_data, 128)
        //server_print("CP string: %s", s_data)
        //CP_allies_capsound

        new s_data1[64]
        new digi5 = objective_get_data( i, CP_icon_axis, s_data1, 63)
        server_print("CP_icon_axis : %s : %d", s_data1, digi5)

        new s_data2[64]
        new digi6 = area_get_data( i, CA_timetocap, s_data2, 63)
        server_print("Area data : %s : %d", s_data2, digi6)



	}
   
   
}

public cpcp222(id)
{
    new total_flags = objectives_get_num()
    for(new i=0; i<total_flags; i++)
	{
        
        objective_set_data(i,CP_icon_neutral,idx_sprt)
        objectives_reinit(0)
        
    }
 
    set_task(0.7, "cpcp222")
    server_print("cp ==")

    //28==btit flag
    // пока только стандартные файлы иконок

}

/*
CA_sprite == sprites/mapsprites/caparea.spr // спрайт с левой стороны захвата
CA_target == targetname of


Set flag captured by 1 == allies , 2==axis, 0 = neutral 
objective_set_data(i,CP_owner,2)
objectives_reinit(0)


s(g)et flag position on HUD map "m"
objective_set_data(i,CP_origin_x,1170)
objectives_reinit(0)
*/

public get_score()
{
    new PlayerID = read_data(1) 
    new PlayerScore = read_data(2) 
    server_print("Event ObjScore: Player %d : Points %d", PlayerID, PlayerScore)


}


public controlpoints_init()
{   
    // Event INITIAL at map start FLAGS
    /*    
    new PlayerID = read_data(1) 
    new PlayerScore = read_data(2) 
    
    server_print("ControlPoint Firs init: %d : %d", PlayerID, PlayerScore)
    */   
    for(new i=0; i<MAX_FLAGS; i++)
	{   
        server_print("ControlPoint %d", i)
        is_area_free[i] = true
    }


    
}


public fm_keyvalue(entid,handle) 
{
	if ( pev_valid(entid) )
	{
		new classname[64], key[64], value[64];
		new flagset[64], flagn[64], flagu[64];
		
		get_kvd(handle, KV_ClassName, classname, 63);
		get_kvd(handle, KV_KeyName, key, 63);
		get_kvd(handle, KV_Value, value, 63);
		
		if(equali(classname,"dod_control_point"))
		{	    
            if(equali(value,"sprites/obj_icons/icon_obj_axis.spr"))
            {
                //set_kvd(handle,KV_Value,"sprites/obj_icons/icon_obj_axiz.spr") ;
            }
            /*

			if(equali(value,"models/flags.mdl") || equali(value,"models/mapmodels/flags.mdl")) set_kvd(handle,KV_Value, flagset) ;
			else if(!equali(value,"models/null.mdl") && !equali(value,"models/mapmodels/null.mdl"))
			{
				if(equali(key,"point_reset_model")) set_kvd(handle,KV_Value, flagn);
				else if(equali(key,"point_axis_model")) set_kvd(handle,KV_Value, flagset);
				else if(equali(key,"point_allies_model")) set_kvd(handle,KV_Value, flagu);
			}
            */
		}
	}
}



