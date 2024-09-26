#include <amxmodx>
#include <fakemeta>
#include <dodx>
#include <dodfun>


#define m_iTeam 90


public plugin_init(){
register_plugin("DOD 475 dev","0.0","America");
server_print("DOD 475 dev");

register_concmd ("erer", "restart_ask") //, ADMIN_ADMIN, "123")



// register_concmd ("ussr", "set_ussr_mdl")


 register_clcmd("eax", "force_axis_win")
  register_clcmd("eal", "force_allies_win")

}

public restart_ask(id, level, cid)
{

server_cmd("restart")
}

public force_axis_win()
{

	new ent
	while((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", "dod_control_point")) != 0)
	{

		set_pdata_int(ent, m_iTeam, 2 , 4) // SET axis owner flag

	}
}

public force_allies_win()
{

	new ent
	while((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", "dod_control_point")) != 0)
	{

		set_pdata_int(ent, m_iTeam, 1 , 4) // SET axis owner flag

	}
}

