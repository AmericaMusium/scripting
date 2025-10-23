#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>
#include <fun>
#include <dodx>
#include <dodfun>
#include <hamsandwich>
/*
crnt1 = get_pdata_float(id_ent, m_flTimeToExplode, 4) // дата взрыва weapon_nade_ex
crnt2 = get_pdata_float(id_ent, m_flStartThrow, 4) // замах == 1,0
crnt3 = get_pdata_float(id_ent, m_flReleaseThrow, 4) // замаъ отпущен
#define m_flNextPrimaryAttack 103 // 
#define m_flNextSecondaryAttack 104
#define m_fInAttack 113
#define m_bUnderhand 120 // bool
#define m_flWaitFinished 149 // 5
*/
#define PLUGIN "DOD NADE TIMER"
#define VERSION "09march2023"
#define AUTHOR "[America][TheVaskov]"
// Linux extra offsets
#define linux_diff_weapon 4
#define linux_diff_player 5
#define m_pPlayer 89 	// int returns weapon's owner
#define m_pActiveItem 278 // notused here but can.
#define m_nadeItem 276 // return player's nade IndexEnt
#define m_flStartThrow 117 // if == 1.0   attack pressed 
#define m_flReleaseThrow 118 
#define m_flTimeToExplode 119 // explossion in gametime format of weapon_nade_ex (when acitive nade picket up after throw)
enum _:PLAYER_DATA
{
    float:ntimer,
	bool:active,
	nade
}
new g_player_dt[33][PLAYER_DATA]
#define EXPL_TIME 2.0

public plugin_init()
{
	register_plugin("NADE ACTIVATOR", "0.0", "America")
	
	register_event("CurWeapon","CurWeapon_P","be", "1=1") // процедура не обязятельная (лишняя)
	RegisterHam(Ham_Weapon_PrimaryAttack,	"weapon_stickgrenade",	"Nade_attack_P", true);
	RegisterHam(Ham_Weapon_PrimaryAttack,	"weapon_handgrenade",	"Nade_attack_P", true);
	// малое дополнение 
	
	RegisterHam(Ham_Spawn, "weapon_stickgrenade_ex", "On_Handgrenade_Spawned", 1)
}

public CurWeapon_P(id)
{
	new weapon = read_data(2)
	if(weapon == DODW_HANDGRENADE || DODW_STICKGRENADE || DODW_MILLS_BOMB)
	{
	// взять индекс гранаты
	g_player_dt[id][nade] = get_pdata_cbase(id, m_nadeItem, 5);
	}
	return PLUGIN_CONTINUE
}
public Nade_attack_P(id_ent)
{	
	if(get_pdata_float(id_ent, m_flStartThrow, 4) == 1.0) // замах == 1,0
	{	
		new id_owner = get_pdata_cbase(id_ent, m_pPlayer, linux_diff_weapon);
		if(g_player_dt[id_owner][active] == true )
		{
			/// если таймер уже активирован 
			if( get_gametime() > g_player_dt[id_owner][ntimer])
			{
				// если время вышло, убить игрока, освободить кнопку.
				g_player_dt[id_owner][active] = false
				ExecuteHam(Ham_TakeDamage, id_owner, id_ent , id_ent , 400.0 , DMG_BULLET)
				return PLUGIN_CONTINUE
			}
			// user_silentkill(id_owner)
			return PLUGIN_CONTINUE
		}
		else
		{
		// сохраняем время замаха
		g_player_dt[id_owner][ntimer] = get_gametime() + EXPL_TIME
		g_player_dt[id_owner][active] = true
		return PLUGIN_CONTINUE
		}
	}
	return PLUGIN_CONTINUE
}
public grenade_throw(id_owner,id_nade)
{	
	// сбросим счётсчик , установим время. 
	// здесь нужно повторять функцию установки параметров, т.к. по факту здесь они даже не сработали, потому что скрипт срабатывает быстрее чем игровые назначения.
	// по факту если не запустить grenade_throw_P() то движок перепишет параметры гранаты по стандарту .
	
	// sticknade_ex fix пока нет необходимости,
	// set_pdata_float(id_nade, m_flTimeToExplode, g_ntimer[id_owner] , 4) // 
	// это защита от хитрожопых, которые бросая гранату, и сразу нажимают на Е
	g_player_dt[id_owner][active] = false
	set_pev(id_nade, pev_dmgtime, g_player_dt[id_owner][ntimer])
	set_task(0.1, "grenade_throw_P", id_nade)
	return PLUGIN_CONTINUE
}
public grenade_throw_P(id_nade)
{
	// таймер взрыва установлен на время замаха. 
	new id_owner = pev( id_nade, pev_owner)
	set_pev(id_nade, pev_dmgtime, g_player_dt[id_owner][ntimer])
	return PLUGIN_CONTINUE
}

public On_Handgrenade_Spawned(idx_nade)
{
	server_print(" weapon_handgrenade_ex DETECYED")
}