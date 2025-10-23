#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>
#include <dodx>
#include <hamsandwich>

#pragma semicolon 1


// ControlPoint 
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

enum 
{
    neutral,
    aliies,
    axis,
    special
};

new g_flag_count;

public plugin_init() 
{
    register_plugin("DOD BOMB-DEFUSE", "0.0", "America");


    // start match // re_initflags
}

public flag_init()
{

	new ent
	while((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", "dod_control_point")) != 0)
	{   
        // считаем общее количество флагов
        g_flag_count++;

        /*
		///engfunc(EngFunc_RemoveEntity, ent
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

		// каждый порядковый номер это каждый первый символ из группы четырёх символов , на пример:
		// MSG = "RedySexyMoon"
		// 100 = R ; 101 = S , 102 = M 
		/// /// new symb==a , if symb = symb + 2 , symb = c / abcdeft......
		// symb = symb + 3
        */
		flag_retune_hud_icons(ent, -1);

	}
}


public flag_retune_hud_icons(idx_cpoint, idx_number)
{	
    // classic hud icons 
    set_pdata_int(idx_cpoint, m_iNeutralIcon, 0, linux_diff_entity);
    set_pdata_int(idx_cpoint, m_iAlliesIcon,  1, linux_diff_entity);
    set_pdata_int(idx_cpoint, m_iAxisIcon,  2, linux_diff_entity);

    // set default owner flag on RoundStart
    set_pdata_int(idx_cpoint, m_iDefaultOwner, 0, linux_diff_entity); //
    entity_set_int(idx_cpoint, EV_INT_body, 0)
}