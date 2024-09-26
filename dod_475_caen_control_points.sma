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

#define m_cpointstring 164


#define linux_diff_entity 4


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

#define AlliesMdlstr 358



#define POINT_AXISSTREET 0
#define POINT_AXISBUNKER 1
#define POINT_CAEN_AXISPLAZA 2
#define POINT_CAEN_ALLIEDPLAZA 3
#define POINT_ALLIEDBUNKER 4
#define POINT_ALLIEDSTREET 5
#define m_SbarString0 394

new hud_flag_icon1;
new hud_flag_icon2;
new hud_flag_icon3;

public plugin_init()
{
	register_plugin("DOD CAEN ICONS","0.0","America")
	set_task(2.0, "parse_data")
	/// All hud becomes red here

	register_clcmd("say sss", "give_stripsss")
}   

public plugin_precache() {
	precache_model("sprites/obj_icons/dod_caen/icon_obj_custom2_neutral.spr")
	precache_model("sprites/obj_icons/dod_caen/icon_obj_custom2_allies.spr")
	precache_model("sprites/obj_icons/dod_caen/icon_obj_custom2_axis.spr")
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

		new float: CapDelayTime = get_pdata_float(ent, m_fCapDelayTime, 4)
		new float: NexCapTime = get_pdata_float(ent, m_fNextCapTime, 4)
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


		//set_pdata_string(ent, m_cpointstring * 4, ANIM_EXTENSION, -1, 4 * 4);

		// каждый порядковый номер это каждый первый символ из группы четырёх символов , на пример:
		// MSG = "RedySexyMoon"
		// 100 = R ; 101 = S , 102 = M 
		/// /// new symb==a , if symb = symb + 2 , symb = c / abcdeft......
		// symb = symb + 3

		//set_task(1.0, "hud_icons_cahnges", ent)
		//hud_icons_cahnges(ent)


        CP_change_data(ent, in_index)

	}

	//set_task(40.0, "parse_data")
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

		set_pdata_int(ent,m_iNeutralIcon, 201, linux_diff_entity) // 
		set_pdata_int(ent,m_iAxisIcon, 201, linux_diff_entity) /
		set_pdata_int(ent,m_iAlliesIcon, 201, linux_diff_entity) // 

			


		//entity_set_string(ent, EV_SZ_model, g_tankmdl);
		// engfunc(EngFunc_SetModel, ent, g_sprt_mdl)
		entity_set_int(ent,EV_INT_body, 0)
		set_task(1.0, "hud_icons_cahnges", ent)

}

public CP_change_data(idx_cpoint, idx_number)
{	
	/*
    switch (idx_number)
    {
        case POINT_AXISSTREET:{
		set_pdata_int(idx_cpoint,m_iNeutralIcon, 0, linux_diff_entity) // 
		set_pdata_int(idx_cpoint,m_iAlliesIcon, 1, linux_diff_entity) // 
		set_pdata_int(idx_cpoint,m_iAxisIcon, 2, linux_diff_entity) //
        }
		case POINT_AXISSTREET:{
        set_pdata_int(idx_cpoint,m_iNeutralIcon, 2, linux_diff_entity) // 
        set_pdata_int(idx_cpoint,m_iAxisIcon, 5, linux_diff_entity) /
        set_pdata_int(idx_cpoint,m_iAlliesIcon, 6, linux_diff_entity) // 
        }
    }
	*/
    /*
    0 == Белый нейтральный
    1 == Allies Star
    2 == Axis Axis
    3 == Neutral White 
    3 == Allies Artillery
    5 == Axis Artillery
    6 == Neutral White 
    7 == Allies Bridge
    8 == Axis Bridge
    9 == Neutral White 
    10 == Allies Radio
    11 == Axis Radio
    12 == Neutral White 
    13 == Allies Docs
    14 == Axis Docs
    15 == Neutral White 
    16 == Allies Truck
    17 == Axis Ganamak
    18 == Neutral Mers W136
    19 == Allies Mers W136
    20 == Axis Mers W136 
    21 == Neutral Tank
    22 == Allies Tank
    23 == Axis Tank
    21 == Neutral Tank
    22 == Allies Weelys
    23 == Axis Weelys
    */
    set_pdata_int(idx_cpoint,m_iNeutralIcon, 22, linux_diff_entity) // 
    set_pdata_int(idx_cpoint,m_iAlliesIcon, 22, linux_diff_entity) // 
    set_pdata_int(idx_cpoint,m_iAxisIcon, 22, linux_diff_entity) //

}
public give_stripsss(idx_player)
{

 new szSymbols[128]
 /*
 m_SbarString0
	*/

 new model[128]
 new ptr = pev(idx_player, pev_viewmodel)
 global_get(glb_pStringBase, ptr, model, 127)

 client_print(idx_player,print_chat,"global %s", model)


get_pdata_string( idx_player, m_SbarString0, szSymbols, 127, 1,5)
 // get_pdata_string(id, 1396, gisTeam, 16,1 ,4)
 client_print(idx_player,print_chat,"global %s", szSymbols)
set_task(1.0, "give_stripsss",idx_player  )
}
/* 

Методика установки кастом спрайта на флаг:
1. опробовать все цифры на m_iNeutral\Axis|AlliesIcon 
2. Если пропали иконки флагов, открыть консоль и должна быть вот такая надпись:
Server # 2
Error: could not load file sprites/obj_icons/dod_caen/icon_obj_custom2_neutral.spr
Error: could not load file sprites/obj_icons/dod_caen/icon_obj_custom2_allies.spr
Error: could not load file sprites/obj_icons/dod_caen/icon_obj_custom2_axis.spr
3. Создаём спрайты с нужным именем из консколи 
4. Предварительно кэшируем спрайты 
5. Ставим пустые номера. 
6. Готово
*/

/*

 ___flag # 64 name: POINT_AXISSTREET , Target:
current_flag_owner: 0 , default_flag_owner: 2 , point_val: 0 , Index: 0 , Cappoints 1 , teampoints 1
CapDelayTime: 1.000000 NexCapTime: 0.000000
m_iNeutralIcon: 0 AX:2 AL:27
Model:models/mapmodels/flags.mdl , submodel_num 3
CapSound_AX: ambience/gerareasecure.wav , CapSound_AL ambience/britareasecure.wav
CapSound_1:  , CapSound_4
 SymbNum: 1599095117
 SymbStr: M


 ___flag # 65 name: POINT_AXISBUNKER , Target:
current_flag_owner: 0 , default_flag_owner: 2 , point_val: 0 , Index: 1 , Cappoints 1 , teampoints 1
CapDelayTime: 1.000000 NexCapTime: 0.000000
m_iNeutralIcon: 0 AX:2 AL:27
Model:models/mapmodels/flags.mdl , submodel_num 3
CapSound_AX: ambience/gerobjectivesecure.wav , CapSound_AL ambience/britobjectivesecure.wav
CapSound_1:  , CapSound_4
 SymbNum: 1599095117
 SymbStr: M


 ___flag # 66 name: POINT_CAEN_AXISPLAZA , Target:
current_flag_owner: 0 , default_flag_owner: 0 , point_val: 0 , Index: 2 , Cappoints 1 , teampoints 1
CapDelayTime: 1.000000 NexCapTime: 0.000000
m_iNeutralIcon: 0 AX:2 AL:27
Model:models/mapmodels/flags.mdl , submodel_num 3
CapSound_AX: ambience/gerobjectivesecure.wav , CapSound_AL ambience/britobjectivesecure.wav
CapSound_1:  , CapSound_4
 SymbNum: 1599095117
 SymbStr: M


 ___flag # 67 name: POINT_CAEN_ALLIEDPLAZA , Target:
current_flag_owner: 0 , default_flag_owner: 0 , point_val: 0 , Index: 3 , Cappoints 1 , teampoints 1
CapDelayTime: 1.000000 NexCapTime: 0.000000
m_iNeutralIcon: 0 AX:2 AL:27
Model:models/mapmodels/flags.mdl , submodel_num 3
CapSound_AX: ambience/gerareasecure.wav , CapSound_AL ambience/britpointcaptured.wav
CapSound_1:  , CapSound_4
 SymbNum: 1599095117
 SymbStr: M


 ___flag # 68 name: POINT_ALLIEDBUNKER , Target:
current_flag_owner: 0 , default_flag_owner: 1 , point_val: 0 , Index: 4 , Cappoints 1 , teampoints 1
CapDelayTime: 1.000000 NexCapTime: 0.000000
m_iNeutralIcon: 0 AX:2 AL:27
Model:models/mapmodels/flags.mdl , submodel_num 3
CapSound_AX: ambience/gerpointcaptured.wav , CapSound_AL ambience/britpointcaptured.wav
CapSound_1:  , CapSound_4
 SymbNum: 1599095117
 SymbStr: M


 ___flag # 69 name: POINT_ALLIEDSTREET , Target:
current_flag_owner: 0 , default_flag_owner: 1 , point_val: 0 , Index: 5 , Cappoints 1 , teampoints 1
CapDelayTime: 1.000000 NexCapTime: 0.000000
m_iNeutralIcon: 0 AX:2 AL:27
Model:models/mapmodels/flags.mdl , submodel_num 3
CapSound_AX: ambience/gerareasecure.wav , CapSound_AL ambience/britareasecure.wav
CapSound_1:  , CapSound_4
 SymbNum: 1599095117
 SymbStr: M

*/