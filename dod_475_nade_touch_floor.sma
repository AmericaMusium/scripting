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
#define PLUGIN "DOD NADE TOUCH"
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
#define MINE_CLSNAME "ent_satchel"
#define TASK_THINK 1.0


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

	// register_think(MINE_CLSNAME, "Nade_Postthink")
	register_touch( "player", MINE_CLSNAME , "satchel_touch_post")

}

public CurWeapon_P(id)
{
	new weapon = read_data(2)
	if(weapon == DODW_HANDGRENADE ||weapon == DODW_STICKGRENADE || weapon == DODW_MILLS_BOMB)
	{
	// взять гранаты индекс
	g_player_dt[id][nade] = get_pdata_cbase(id, m_nadeItem, 5);

	client_print(0 ,print_chat," CurWeapon_P Weapon ID %d by ID %d user ", g_player_dt[id][nade], id) 
	}
	return PLUGIN_CONTINUE
}


public Nade_attack_P(id_ent)
{	
    /*
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
    */
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
	/*
	g_player_dt[id_owner][active] = false
	set_pev(id_nade, pev_dmgtime, g_player_dt[id_owner][ntimer])
	*/

	client_print(0 ,print_chat," grenade_throw Weapon ID (%d) by ID %d user ", id_nade , id_owner) 
	set_task(0.2, "grenade_throw_P", id_nade)
	return PLUGIN_CONTINUE
}
public grenade_throw_P(id_nade)
{   
	new Float:gtime = get_gametime()
	// таймер взрыва установлен на время замаха. 
	new id_owner = pev( id_nade, pev_owner)
	set_pev(id_nade, pev_dmgtime, gtime + 2400.0)
	set_pev(id_nade, pev_nextthink, gtime + 1.0)



	set_pev(id_nade, pev_classname, MINE_CLSNAME)
	entity_set_string(id_nade, EV_SZ_classname, MINE_CLSNAME)

	new classname[32]
	pev(id_nade, pev_classname, classname, 31)

	set_pev(id_nade, pev_movetype, MOVETYPE_STEP)
	//set_pev(id_nade, pev_solid, SOLID_TRIGGER)
	entity_set_model( id_nade, "models/w_garand.mdl" )
	// set_pev(id_nade, pev_spawnflags, SF_DETONATE)

	// set_pev(id_nade, pev_flags, FL_TOUCH)

	// set_pev(id_nade, pev_flags, FL_ONGROUND)
	set_pev(id_nade, pev_mins, Float:{-5.0, -5.0, -5.0})
	set_pev(id_nade, pev_maxs, Float:{5.0, 5.0, 5.0})


	server_print(classname)
	client_print(0 ,print_chat," grenade_throw_P Weapon ID (%d) by ID %d user time: %f ", id_nade , id_owner , gtime) 
	set_task(1.0, "satchel_task", id_nade, "", 0, "b");
	return PLUGIN_CONTINUE
}

public Nade_Postthink(id_nade)
{
	new Float:gtime = get_gametime()
	// set_pev(id_nade, pev_dmgtime, gtime + 500.00)
	set_pev(id_nade, pev_nextthink, gtime + 2.00)

	new id_owner = pev( id_nade, pev_owner)
	client_print(0 ,print_chat," Nade_Postthink Weapon ID (%d) by ID %d user", id_nade , id_owner) 
	// set_pev(id_nade, pev_velocity, {0.0 , 0.0 , 50.0})

}

public satchel_touch_post(id_nade, id_toucher)
{
	client_print(0 ,print_chat," satchel_touch_post %d %d " ,  id_nade, id_toucher)
}

/* 

у нас нет необходимости сейчас в Nade_Postthink т.к назначив 40 минутный таймер этого уже достаточно

НО БЕЗ И С ФИНКОМ ТАЧ НЕ ЗАПУСКАЕТСЯ
S
*/

public satchel_task(id_satchel)
{

}