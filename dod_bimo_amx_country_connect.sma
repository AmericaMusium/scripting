//////////////////////////////////////////////////////////////////////////////////
//
//	Country On Connect
//		- Version 1.2b
//		- 12.17.2006
//		- diamond-optic
//
//////////////////////////////////////////////////////////////////////////////////
//
// Information:
//
// 	- Shows country from which a player is in when they connect..
//	- Can set cvars to prevent msgs being shown for admins & bots...
//
//	- * Requires GEOIP module *
//
// Credit:
//
//	- santa_sh0t_tupac: fixing my sloppy coding on bot detection
//
// CVAR: 
//
//	amx_country_connect "1" 			//Turn On/Off
//	amx_country_connect_admins "0"			//Dont show msg for admins
//	amx_country_connect_bots "1"			//Dont show msg for bots
//
//	amx_country_connect_defualt "United States"	//Country of server (for bots)
//
// EXTRA:
//
//	Change #define ADMIN to admin level used for amx_country_connect_admins
//
// Changelog:
//
//	- 07.11.2006 Version 1.0
//		Initial Release
//
//	- 08.06.2006 Version 1.1
//		Changed a return
//
//	- 12.09.2006 Version 1.2
//		If country returns "error", it prints as "Unknown"
//
//	- 12.17.2006 Version 1.2b  (1.3b changes)
//		Much better way of detecting bots (thanks santa_sh0t_tupac)
//		Checks to make sure player is actually connected
//
//////////////////////////////////////////////////////////////////////////////////

#include <amxmodx>
#include <amxmisc>
#include <geoip>

#define VERSION "1.2b"
#define SVERSION "v1.2b - by diamond-optic (www.AvaMods.com)"

#define ADMIN ADMIN_IMMUNITY

new p_connect, p_admins, p_bots, p_defualt

public plugin_init()
{
	register_plugin("Country On Connect",VERSION,"diamond-optic")
	register_cvar("amx_country_connect_stats",SVERSION,FCVAR_SERVER|FCVAR_SPONLY)
	
	p_connect = register_cvar("amx_country_connect","1")
	p_admins = register_cvar("amx_country_connect_admins","0")
	p_bots = register_cvar("amx_country_connect_bots","1")
	p_defualt = register_cvar("amx_country_connect_defualt","United States")
}

public client_putinserver(id)
{
	if(!get_pcvar_num(p_connect) || !is_user_connected(id) || (access(id, ADMIN) && get_pcvar_num(p_admins)) || (is_user_bot(id) && get_pcvar_num(p_bots)))
		return PLUGIN_CONTINUE
	
	new name[33]
	get_user_name(id,name,32)
		
	new country[46]
		
	if(is_user_bot(id))
		get_pcvar_string(p_defualt,country,45)
	else
		{
		new ip[17]
		
		get_user_ip(id,ip,16,1)
		geoip_country(ip,country,45)
		
		if(equali(country,"error"))
			formatex(country,45,"Unknown")
		}
		
	client_print(0,print_chat," * %s is playing from: %s",name, country)
	server_print("[connect] * %s is playing from: %s",name, country)
	return PLUGIN_CONTINUE
}
