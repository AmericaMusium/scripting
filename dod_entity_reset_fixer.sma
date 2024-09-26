
#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>

#define PLUGIN "dod_entity_reset_fixes"
#define VERSION "1.1"
#define AUTHOR "Vet(3TT3V)"

// Constant defines - DO NOT CHANGE
#define CLASS_MASTER "dod_control_point_master"
#define CLASS_CNTPNT "dod_control_point"
#define CLASS_CPAREA "dod_capture_area"
#define CLASS_T_TELE "trigger_teleport"
#define CLASS_SCORES "dod_score_ent"
#define CLASS_T_HURT "trigger_hurt"
#define CLASS_F_TANK "func_tank"
#define AXISNADE "grenade2"
#define ALLYNADE "grenade"
#define KS_IDLE 0
#define KS_PREP 1
#define KS_KILL 2
#define NEVER 0.0
#define PLUS1 1.0
#define POST 1
#define PRE 0
#define YES 1
#define NO 0
#define fm_find_ent_by_class(%1,%2) engfunc(EngFunc_FindEntityByString, %1, "classname", %2)

new g_master_ent = -1
new g_score_ent = -1


public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	//RegisterHam(Ham_Think, CLASS_MASTER, "HAM_cp_master_THINK")


	new ent, pluginname[32]
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



	set_task(3.0, "killingspree_timer" )
	return PLUGIN_CONTINUE
}


public killingspree_timer()
{	

	server_print("THE TIIIIIIIIIIIIIIIIIIIIIIIIME")
	ExecuteHamB(Ham_Use, g_score_ent, g_master_ent, g_master_ent, 3, NEVER)
}