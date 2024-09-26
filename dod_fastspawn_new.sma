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

/// - проблема в отсуствии ресетхуд из-за не правильно скорости респауна . 
//  + плагина при рестарте сервера отправлет игрока амеркиа за команду фаш

public plugin_init()
{
register_plugin("DOD FAST SPAWN NEW", "1.0", "America")
RegisterHam(Ham_Killed, "player", "Fastrespawn_1", 1)
register_concmd ("r", "restart_ask")
}

public restart_ask(id, level, cid)
{
server_cmd("restart")
}



public Fastrespawn_1(id)
{
if (!is_user_bot(id))
{
	set_task(1.0 ,"fwdPlayerKilled", id )
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
set_pev(id,pev_iuser1,0)
set_pdata_int(id,264,0) 
dllfunc(DLLFunc_Spawn,id)
}
return PLUGIN_CONTINUE
}


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
Fastrespawn_1(id)
}
public fn_joinTeam2(id)
{
server_print("[DOD FAST SPAWN] set taks complete for %d ",  id )
client_cmd(id, "jointeam 2")
client_cmd(id, "cls_k98")
Fastrespawn_1(id)
}
