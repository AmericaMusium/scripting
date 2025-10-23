#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>
#include <fakemeta_util>
#include <fun>
#include <dodx>
#include <dodfun>
#include <dodconst>
#include <dodstats>
#include <hamsandwich>


// Animation
#define linux_diff_entity 4
#define m_cpointstring 164

#define m_iTeam 90
#define m_iDefaultOwner 93
#define m_iIndex 94
#define m_iPointValue 95
#define m_iCapPoints 96
#define m_iTeamPoints 97
#define m_fCapDelayTime 98
#define m_fNextCapTime 99
#define ofs_sz_WinString 100

 


#define m_iAlliesIcon 553
#define m_iAxisIcon 554
#define m_iNeutralIcon 555

#define m_bAlliesCantTouch 556
#define m_bPointVisible 557 // прячет HUD иконку 
#define m_bActive 623 // прячет HUD иконку 

#define AlliesMdlstr 358

new hud_flag_icon1, hud_flag_icon2
new const g_tankmdl[] = "models/wmod/w_pps43.mdl"
new const g_sprt_mdl[] = "sprites\obj_icons\icon_obj_88_axis.spr" 


public plugin_init()
{
	register_plugin("DOD TEST GPT","0.0","America")
	set_task(2.0, "parse_data")
	/// All hud becomes red here
}   
public plugin_precache()
{
	hud_flag_icon1 = precache_model("sprites/obj_icons/icon_obj_truck_axis.spr")
	hud_flag_icon2 = precache_model(g_sprt_mdl)
	precache_model(g_tankmdl) 
	server_print("srpute %d", hud_flag_icon2)
}

public parse_data()
{	

	new ent
	while((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", "dod_control_point")) != 0)
	{
		///engfunc(EngFunc_RemoveEntity, ent)
		
		new flagname[64]
		entity_get_string(ent, EV_SZ_netname , flagname, 63)
		new targname[64]
		entity_get_string(ent, EV_SZ_targetname , targname, 63)
		server_print(" ^n ___flag # %d name: %s , Target: %s", ent, flagname , targname )

		new current_flag_owner = get_pdata_int(ent, m_iTeam)
		new default_flag_owner = get_pdata_int(ent, m_iDefaultOwner)
		new point_val =  get_pdata_int(ent, m_iPointValue)
		new cappoints =  get_pdata_int(ent, m_iCapPoints)
		new teampoints =  get_pdata_int(ent, m_iTeamPoints)
		new in_index =  get_pdata_int(ent, m_iIndex)
		server_print("current_flag_owner: %d , default_flag_owner: %d , point_val: %d , Index: %d , Cappoints %d , teampoints %d", current_flag_owner, default_flag_owner, point_val, in_index, cappoints, teampoints )

		new Float: CapDelayTime = get_pdata_float(ent, m_fCapDelayTime, 4)
		new Float: NexCapTime = get_pdata_float(ent, m_fNextCapTime, 4)
		server_print("CapDelayTime: %f NexCapTime: %f " , CapDelayTime, NexCapTime)

		new neutral_icon = get_pdata_int(ent, m_iNeutralIcon)
		new axis_icon =  get_pdata_int(ent, m_iAxisIcon)
		new allies_icon = get_pdata_int(ent, m_iAlliesIcon)
		server_print("m_iNeutralIcon: %d AX:%d AL:%d", neutral_icon, axis_icon , allies_icon)

		new mdlname[128]
		entity_get_string(ent, EV_SZ_model , mdlname, 127)
		new submdl_num = entity_get_int(ent,EV_INT_body)
		server_print("Model:%s , submodel_num %d", mdlname, submdl_num )

		new capsound_ax[64]
		new capsound_al[64]
		new capsound_1[64]
		new capsound_4[64]
		entity_get_string(ent, EV_SZ_noise2 , capsound_ax, 63)
		entity_get_string(ent, EV_SZ_noise1 , capsound_al, 63)
		server_print("CapSound_AX: %s , CapSound_AL %s", capsound_ax, capsound_al )
		entity_get_string(ent, EV_SZ_noise , capsound_1, 63)
		entity_get_string(ent, EV_SZ_noise3 , capsound_4, 63)
		server_print("CapSound_1: %s , CapSound_4 %s", capsound_1, capsound_4 )

	
		new symb = get_pdata_int(ent, 100)
		server_print(" SymbNum: %d^n SymbStr: %s^n ", symb, symb)
		

		set_pdata_int(ent, m_iDefaultOwner, 0, linux_diff_entity) //


		
		//entity_set_int( ent, m_bAlliesCantTouch, 0)
		// каждый порядковый номер это каждый первый символ из группы четырёх символов , на пример:
		// MSG = "RedySexyMoon"
		// 100 = R ; 101 = S , 102 = M 
		/// /// new symb==a , if symb = symb + 2 , symb = c / abcdeft......
		// symb = symb + 3

		//set_task(1.0, "hud_icons_cahnges", ent)
		hud_icons_cahnges(ent)



		
	}

	set_task(40.0, "parse_data")
}


public hud_icons_cahnges(ent)
{		
	/*
		// ONLY FOR DOD_SAINTS, CAUSE 18 19 20 PRECAHED 
		set_pdata_int(ent,m_iNeutralIcon, random_num(18,20), 4) // 
		set_pdata_int(ent,m_iAxisIcon, random_num(18,20), 4) /
		set_pdata_int(ent,m_iAlliesIcon,random_num(18,20), 4) // 
	*/
		entity_set_string(ent, EV_SZ_netname, "Bargulie Wanted"); // WORKS! 

		set_pdata_int(ent,m_iNeutralIcon, 0, linux_diff_entity) // 
		set_pdata_int(ent,m_iAlliesIcon, 1, linux_diff_entity) // 
		set_pdata_int(ent,m_iAxisIcon, 2, linux_diff_entity) //


			


		//entity_set_string(ent, EV_SZ_model, g_tankmdl);
		engfunc(EngFunc_SetModel, ent, g_sprt_mdl)
		entity_set_int(ent,EV_INT_body, 0)
		set_task(1.0, "hud_icons_cahnges", ent)

}



public force_three_man_caps()
{
	for (new i = 0; i < g_capcnt; i++) {
		if (g_capally[i])
			fm_set_kvd(g_capent[i], KEY_ALLYNUM, "13", CL_CAPAREA)
		if (g_capaxis[i])
			fm_set_kvd(g_capent[i], KEY_AXISNUM, "14", CL_CAPAREA)
	}
}