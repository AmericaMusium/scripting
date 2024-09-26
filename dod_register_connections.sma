// All Info - Remo Williams - Easiest coding ever I know....lol.
// Flag "C" To Get AllInfo
// This Plugin Logs Each Player's STEAMID, NAME, and IP ADDRESS to a log file.
// It logs the information on connect, and again if you use the command.
// Log File is located at Addons/amxmodx/logs/allinfo_players.txt
// I hate .log files.
// lol.
// Usage: amx_allinfo <Name>
//
//
//
//////////////////////////////////
// Change Log			//
//////////////////////////////////////////////////////////
// 1.0 - First Release					//
// 1.1 - Removed Non-sense Code				//
//     - Changed Access Detection Code			//
//////////////////////////////////////////////////////////
#include <amxmodx>
#include <amxmisc>

public plugin_init() {
	register_plugin("LOG_CONNCECTIONS","1.1","Remo Williams")
	register_concmd("amx_allinfo","allinfo",ADMIN_KICK," - Obtain the specified users Information")
}

public client_putinserver(id) {
	
	new authid[32], usrip[32], name[32]
	
	get_user_authid(id,authid,31)
	get_user_name(id,name,31)
	
	if(!is_user_connected(id)) {
		return PLUGIN_HANDLED
	}
	
	get_user_ip(id,usrip,31,1)
	client_print(id,print_console," ***** [ Name: %s  |  STEAMID: %s  | IP: %s ] ***** ^n",name,authid,usrip)
	log_to_file("allinfo_players.txt","		%s | STEAMID: %s | IP: %s ^n",name,authid,usrip)
	
	return PLUGIN_HANDLED
}

public allinfo(id,level,cid) { 
	
	if (!cmd_access(id,level,cid,2)) { 
		return PLUGIN_HANDLED 
	} 
	
	new command[32], arg[32], target, authid[32], usrip[32], name[32]
	
	read_argv(0,command,31)
	read_argv(1,arg,31)
	
	target = cmd_target(id,arg,1)
	
	get_user_authid(target,authid,31)
	get_user_name(target,name,31)
	
	if(!is_user_connected(target)) {
		return PLUGIN_HANDLED
	}
	
	get_user_ip(target,usrip,31,1)
	client_print(id,print_console," ***** [ Name: %s  |  STEAMID: %s  | IP: %s ] ***** ^n",name,authid,usrip)
	log_to_file("allinfo_players.txt","		%s | STEAMID: %s | IP: %s ^n",name,authid,usrip)
	return PLUGIN_HANDLED
}
