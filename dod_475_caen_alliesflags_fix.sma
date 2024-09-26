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

new idx_icon = 0

    /*
    0 == Белый нейтральный
    1 == Allies Star
    2 == Axis Axis
    3 == Neutral White 
    4 == Allies Artillery
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

public plugin_init()
{
register_plugin("DOD CAEN ICONS","0.0","America")

	new mapname[32];
	get_mapname(mapname, 31);

	server_print("MAPNAME IS %s !!" , mapname) 

	if(!equal(mapname, "dod_caen"))
	{	
		pause("ad")
	}
set_task(2.0, "controlpoints_init")
register_event("CapMsg","on_CapMsg_p","a") // Событие событие после захвата флага
register_event("ObjScore","on_ObjScore_p","a") // Событие назначения очков при захвате флага. player , points
//register_clcmd("say con", "controlpoints_init")

} 

public controlpoints_init()
{   
    idx_icon++
    new ent
    while((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", "dod_control_point")) != 0){
    new in_index =  get_pdata_int(ent, m_iIndex)

    controlpoints_retune_hud_icons(ent, in_index)
    }
}




public controlpoints_retune_hud_icons(idx_cpoint, idx_number)
{	
    // classic hud icons 
    
    set_pdata_int(idx_cpoint,m_iNeutralIcon, 0, linux_diff_entity) // 
    set_pdata_int(idx_cpoint,m_iAlliesIcon,  1, linux_diff_entity) // 
    set_pdata_int(idx_cpoint,m_iAxisIcon,  2, linux_diff_entity) //
    

    // Custom HUD Icons
    /*
    
    switch (idx_number)
    {
        case POINT_AXISSTREET:
        {
            set_pdata_int(idx_cpoint,m_iNeutralIcon, 0, linux_diff_entity) // 
            set_pdata_int(idx_cpoint,m_iAlliesIcon, 10, linux_diff_entity) // 
            set_pdata_int(idx_cpoint,m_iAxisIcon, 11, linux_diff_entity) //
        }
        case POINT_AXISBUNKER:
        {
            set_pdata_int(idx_cpoint,m_iNeutralIcon, 0 , linux_diff_entity) // 
            set_pdata_int(idx_cpoint,m_iAlliesIcon, 4, linux_diff_entity) // 
            set_pdata_int(idx_cpoint,m_iAxisIcon, 5, linux_diff_entity) //
        }
        case POINT_CAEN_AXISPLAZA:
        {
            set_pdata_int(idx_cpoint,m_iNeutralIcon, 0, linux_diff_entity) // 
            set_pdata_int(idx_cpoint,m_iAlliesIcon, 13, linux_diff_entity) // 
            set_pdata_int(idx_cpoint,m_iAxisIcon, 14, linux_diff_entity) //
        }
        case POINT_CAEN_ALLIEDPLAZA:
        {   
            server_print("TANK SETTED")
            set_pdata_int(idx_cpoint,m_iNeutralIcon, 0, linux_diff_entity) // 
            set_pdata_int(idx_cpoint,m_iAlliesIcon, 16, linux_diff_entity) // 
            set_pdata_int(idx_cpoint,m_iAxisIcon, 17, linux_diff_entity) //
        }
        case POINT_ALLIEDBUNKER:
        {
            set_pdata_int(idx_cpoint,m_iNeutralIcon, 0, linux_diff_entity) // 
            set_pdata_int(idx_cpoint,m_iAlliesIcon, 4, linux_diff_entity) // 
            set_pdata_int(idx_cpoint,m_iAxisIcon, 5, linux_diff_entity) //
        }
        case POINT_ALLIEDSTREET:
        {
            set_pdata_int(idx_cpoint,m_iNeutralIcon, 0, linux_diff_entity) // 
            set_pdata_int(idx_cpoint,m_iAlliesIcon, 10, linux_diff_entity) // 
            set_pdata_int(idx_cpoint,m_iAxisIcon, 11, linux_diff_entity) //
        }
        
    }
    */
    
    client_print(0, print_chat, " Now idx_icon = %d ", idx_icon)


    // set default owner flag on RoundStart
    set_pdata_int(idx_cpoint,m_iDefaultOwner, 0, linux_diff_entity) //
}



public controlpoints_model_update()
{
new ent
while((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", "dod_control_point")) != 0){
new current_flag_owner = get_pdata_int(ent, m_iTeam)

switch (current_flag_owner)
{
    case ALLIES: entity_set_int(ent, EV_INT_body, 1)
    case AXIS: entity_set_int(ent, EV_INT_body, 0)
    case 0: entity_set_int(ent, EV_INT_body, 3)
}
}
}

public on_CapMsg_p(idx)
{
    controlpoints_model_update()
}

public on_ObjScore_p(idx)
{
// Get current value player points after capture
controlpoints_model_update()
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