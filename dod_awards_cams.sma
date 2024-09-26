#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>
#include <fun>
#include <dodx>
#include <dodfun>
#include <hamsandwich>
new const g_award_cam_model[] = "models/w_k43.mdl" 
new const g_award_player_model[] = "models/player/axis-inf/axis-inf.mdl"


new seq_num = 1
public plugin_init()
{
	register_plugin("DOD Cansave","0.0","America")
    server_print("DOD Cansave")

    register_clcmd("say awcams","create_entity_cam")
     register_clcmd("say awpla","create_entity_player")
    
}

public plugin_precache()
{
	// precache_model( g_award_cam_model ) 
    // precache_model( g_award_player_model ) 
}

public client_PreThink(id_owner)
{
        // het Origin
		new iOrigin[3] // 

		get_user_origin(id_owner, iOrigin, 1) //    looks
        
        // HUD ANGLE POINTS
        new Float:fAngViev[3] 
         new Float:f_pl_angles[3] 
        pev(id_owner, pev_v_angle, fAngViev) // fAngViev[0] вертикалка  fAngViev[1] лево право
        // pev(id_owner, pev_angles, f_pl_angles) /

      
        client_print(id_owner, print_center, "iOrigin: %d %d %d  f_pl_angles: %.0f %.0f %.0f", iOrigin[0], iOrigin[1], iOrigin[2], fAngViev[0],  fAngViev[1],  fAngViev[2])

}       


public create_entity_cam(id_owner)
{
            // het Origin
		new iOrigin[3] //    
        new float:fOrigin[3]
		get_user_origin(id_owner, iOrigin, 1) //    looks
        IVecFVec(iOrigin,fOrigin);
        // HUD ANGLE POINTS
        new Float:fAngViev[3] 
        pev(id_owner, pev_v_angle, fAngViev) // fAngViev[0] вертикалка  fAngViev[1] лево право



		//// CREATE ENITY 
		new id_camera = create_entity("info_target")	
		set_pev(id_camera, pev_classname, "award_cam") 
		set_pev(id_camera, pev_solid, SOLID_TRIGGER)   
		set_pev(id_camera, pev_movetype, MOVETYPE_NONE) 

		
		entity_set_edict(id_camera, EV_ENT_owner, id_owner)

		set_pev(id_camera, pev_origin, fOrigin)
        set_pev(id_camera, pev_angles, fAngViev)
        // pev_angles
		if(!pev_valid(id_camera)) 
		{
			return PLUGIN_HANDLED  
		}


        attach_view(id_owner, id_camera)
        engfunc(EngFunc_SetModel, id_camera, g_award_cam_model) // 
        engfunc(EngFunc_SetSize, id_camera, Float:{-6.0, -6.0, 0.0}, Float:{6.0, 6.0, 3.0}) //   entity(      )

		// данный метод сохраняет положением камеры от игрока и от спектатора одинаково хорошо
}

// установить entity и дать ему секвенцию и аттачменты
// установить проверку наличия текстового файла с камерами и награждениями , если нет текста, то метод награждения классический 
//  
// классический метод:
/* fade black in (MsgScreedFade+)
 camera on spawn in move type 
 */ 


 /* 
режимы игры, можно ограничит захват флага только некоторым игрокам
2 захватчика, остальные дамагеры, медики , и строители , снайперы

для  такого режима игрры надо вынести информер по каждой фигуре и немного инфы о чужой команде 
 */ 

 public create_entity_player(id_owner)
{
            // het Origin
		new iOrigin[3] //    
        new float:fOrigin[3]
		get_user_origin(id_owner, iOrigin, 3) //    looks
        IVecFVec(iOrigin,fOrigin);
        // HUD ANGLE POINTS
        new Float:fAngViev[3] 
        pev(id_owner, pev_v_angle, fAngViev) // fAngViev[0] вертикалка  fAngViev[1] лево право



		//// CREATE ENITY 
		new id_award_player = create_entity("info_target")	
		set_pev(id_award_player, pev_classname, "award_player") 
		set_pev(id_award_player, pev_solid, SOLID_TRIGGER)   
		set_pev(id_award_player, pev_movetype, MOVETYPE_NONE) 

		
		entity_set_edict(id_award_player, EV_ENT_owner, id_owner)

		set_pev(id_award_player, pev_origin, fOrigin)
        set_pev(id_award_player, pev_angles, fAngViev)
        // pev_angles
		if(!pev_valid(id_award_player)) 
		{
			return PLUGIN_HANDLED  
		}

        engfunc(EngFunc_SetModel, id_award_player, g_award_player_model) // 
        engfunc(EngFunc_SetSize, id_award_player, Float:{-6.0, -6.0, 0.0}, Float:{6.0, 6.0, 3.0}) //   entity(      )

        set_pev( id_award_player, pev_sequence, 1 );
        set_task(1.0, "seq_changer", id_award_player )

		// данный метод сохраняет положением камеры от игрока и от спектатора одинаково хорошо
}

public seq_changer(id_award_player)
{   

     set_pev( id_award_player, pev_sequence, seq_num );
     seq_num++
     set_task(2.0, "seq_changer", id_award_player )


    set_pev(id_award_player, pev_frame, 1);
    set_pev(id_award_player, pev_framerate, random_float(0.1,5.0));
    set_pev(id_award_player, pev_sequence, seq_num);
    set_pev(id_award_player, pev_gaitsequence, seq_num);
    set_pev(id_award_player, pev_animtime, random_float(0.5, 10.0));
    
}


public METOD-FUNC-FROWARD-NATIVE()
{
 new int: X = 13 
 new int: Y = 26

 new int: Z 
 Z = X + Y 


 print(Z)
}




