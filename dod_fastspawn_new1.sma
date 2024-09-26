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

public plugin_init()
{
    register_plugin("DOD FASTSPAWN GUARDED", "3.0", "America")
    RegisterHam(Ham_Killed, "player", "settaa", 1)

}


public settaa(id)
{
    set_task(2.0 ,"fwdPlayerKilled", id )

}
public fwdPlayerKilled(id)
{	
	
	set_pev(id,pev_iuser1,0)
	set_pdata_int(id,264,1) // someone human did found this is needed to use weapons for a forced spawn.
	// dllfunc(DLLFunc_Spawn,id)
    // client_print(0 , print_chat,"Spawned")

	
		Fastrespawn_1(id)
}

public Fastrespawn_1(id)
{
if (!is_user_bot(id))
{	
	new float:gtime = get_gametime()
	set_pev(id,pev_nextthink, gtime + 2.0)
	//set_task(1.0 ,"fwdPlayerKilled", id )
}
}

/*
public client_putinserver(id)
{
    new namearray[32]
    get_user_name(id, namearray, 31)
	server_print("[DOD FAST SPAWN] %s  connected as %d ", namearray, id )

    if (equal(namearray, "Officer_Mymune"))
    {
	    server_print("[DOD FAST SPAWN] if %s  connected as %d ", namearray, id )
	    set_task(2.0, "fn_joinTeam1", id )
	}
    if(equal(namearray, "America"))
    {	
	    server_print("[DOD FAST SPAWN] if %s  connected as %d ", namearray, id )
	    set_task(1.0, "fn_joinTeam2", id )
    }
}

public fn_joinTeam1(id)
{
	server_print("[DOD FAST SPAWN] set taks complete for %d ",  id )
	client_cmd(id, "jointeam 1")
	client_cmd(id, "cls_garand")
    settaa(id)
}
public fn_joinTeam2(id)
{
	server_print("[DOD FAST SPAWN] set taks complete for %d ",  id )
	client_cmd(id, "jointeam 2")
	client_cmd(id, "cls_k98")
    settaa(id)
}
*/