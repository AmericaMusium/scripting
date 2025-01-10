#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <fun>
#include <dodx>
#include <dodfun>

#define PLUGIN "DOD Fast start round"
#define VERSION "0.0"
#define AUTHOR "America"


#define CLASS_MASTER "dod_control_point_master"
#define CLASS_CNTPNT "dod_control_point"
#define CLASS_CPAREA "dod_capture_area"
#define CLASS_T_TELE "trigger_teleport"
#define CLASS_SCORES "dod_score_ent"
#define CLASS_T_HURT "trigger_hurt"
#define CLASS_F_TANK "func_tank"
#define m_iTeam 90


#define NEVER 0.0
#define PLUS1 1.0
#define POST 1
#define PRE 0
#define YES 1
#define NO 0
#define fm_find_ent_by_class(%1,%2) engfunc(EngFunc_FindEntityByString, %1, "classname", %2)

new g_master_ent = -1
new g_score_ent = -1
new pluginname[32]

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	new ent
	get_plugin(-1, pluginname, 31)


	// Find the 'dod_control_point_master' entity
	g_master_ent = fm_find_ent_by_class(g_master_ent, CLASS_MASTER)
	if (!g_master_ent)
		pause("ad", pluginname)


	// Find 2 'dod_score_ent' entities - Fail if less
	for (ent = 0; ent < 2; ent++) {
		g_score_ent = fm_find_ent_by_class(g_score_ent, CLASS_SCORES)
		if (!g_score_ent)
			pause("ad", pluginname)
	}



	set_task(1.0, "force_startgame" )
	set_task(4.0, "force_startgame" )
	return PLUGIN_CONTINUE
}


public force_startgame()
{	
	ExecuteHamB(Ham_Use, g_score_ent, g_master_ent, g_master_ent, 3, NEVER)
	force_fast_spawn()
	//pause("ad", pluginname)
}

public force_fast_spawn()
{
    new id;
    new Float:gtime = get_gametime();
    for(id = 0; id < get_maxplayers(); id++)
    {
        set_pev(id, pev_nextthink, gtime + 2.0);
    }
    return PLUGIN_CONTINUE; // или PLUGIN_HANDLED, в зависимости от твоих потребностей
}