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



	set_task(3.0, "force_startgame" )
	set_task(5.0, "force_startgame" )
	set_task(6.0, "force_startgame" )
	register_clcmd("say /axiswin", "force_axis_win")


	return PLUGIN_CONTINUE
}


public force_startgame()
{	
	server_print(":: :: :: Round Fast Started " )
	// ExecuteHamB(Ham_Use, g_score_ent, g_master_ent, g_master_ent, 3, NEVER) // originsl
	/// 
	ExecuteHam(Ham_Use, g_score_ent, g_master_ent, g_master_ent, 3, NEVER)

	force_fast_spawn()
	//pause("ad", pluginname)
}

public force_fast_spawn()
{	
	new Float:gtime = get_gametime()
	for(new id = 1 ; id < get_maxplayers() + 1 ; id++)
	{
		set_pev(id,pev_nextthink, gtime + 2.0)
	}
}





public client_putinserver(id)
{
	new namearray[32]
	get_user_name(id, namearray, 31)
	//server_print("[DOD FAST SPAWN] %s  connected as %d ", namearray, id )

	if (equal(namearray, "Officer_Mymune"))
	{
		//server_print("[DOD FAST SPAWN] if %s  connected as %d ", namearray, id )
		set_task(2.0, "fn_joinTeam1", id )
	}
	if(equal(namearray, "America"))
	{	
		//server_print("[DOD FAST SPAWN] if %s  connected as %d ", namearray, id )
		set_task(1.0, "fn_joinTeam2", id )
	}

}


public fn_joinTeam1(id)
{
// server_print("[DOD FAST SPAWN] set taks complete for %d ",  id )
client_cmd(id, "jointeam 1")
client_cmd(id, "cls_garand")
Fastrespawn_1(id)
}

public fn_joinTeam2(id)
{
server_print("[DOD FAST SPAWN] set taks complete for %d ",  id )
client_cmd(id, "jointeam 2")
client_cmd(id, "cls_k98s")
Fastrespawn_1(id)
}


public Fastrespawn_1(id)
{
if (!is_user_bot(id))
{	
	new Float:gtime = get_gametime()
	set_pev(id,pev_nextthink, gtime + 10.0)
	//set_task(1.0 ,"fwdPlayerKilled", id )
}
}

public fwdPlayerKilled(id)
{	
new myclass = dod_get_user_class(id)
if (myclass  < 0)
{
	dod_set_user_class(id, 1 )
	return PLUGIN_HANDLED
}
else
{
	Fastrespawn_1(id)
	/*
set_pev(id,pev_iuser1,0)
set_pdata_int(id,264,10) 
dllfunc(DLLFunc_Spawn,id)
*/
}
return PLUGIN_CONTINUE
}


public force_axis_win()
{

	new ent
	while((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", "dod_control_point")) != 0)
	{

		set_pdata_int(ent, m_iTeam, 2 , 4) // SET axis owner flag

	}
}