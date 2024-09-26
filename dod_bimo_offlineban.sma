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
new arg1[2]
new a_data[11]
new arg3[2]
new a_time[10]
new a_name[33]
new a_steamid[24]
new a_ip[32]


#define offlinelist "addons/amxmodx/logs/allinfo_players.txt"
#define a_namemax 32


public plugin_init() {
	register_plugin("LOG_CONNCECTIONS","1.1","Remo Williams")
	// register_concmd("amx_allinfo","allinfo",ADMIN_KICK," - Obtain the specified users Information")
	// set_task(1.5, "file_readn_print")
	register_concmd ("off", "file_readn_print_ask", ADMIN_BAN, "123")
	register_concmd ("ofb", "offlineban_ask", ADMIN_BAN, "123")
	// register_concmd ("ott", "client_putinserver", ADMIN_BAN, "123")
}

public client_putinserver(id)
{	
	if (!is_user_bot(id))
	{
	
		new authid[32], usrip[32], name[32]
		
		get_user_authid(id,authid,31)
		get_user_name(id,name,31)
		
		if(!is_user_connected(id)) 
		{
			return PLUGIN_CONTINUE
		}
		get_user_ip(id,usrip,31,1)

		file_readn_save(id, authid, usrip, name)
		// log_to_file("allinfo_players.txt","%s %s %s", authid, usrip, name)
		
		return PLUGIN_CONTINUE
	}
	return PLUGIN_CONTINUE
}

public file_readn_save(id, steamidp[], usrip[], name[])
{

	new word[] = {"STEAM_"}


	if (!file_exists(offlinelist))
		return PLUGIN_CONTINUE
	if (file_exists(offlinelist)) 
		server_print("[OFBANSYSTEM] file exists = %s", offlinelist)
	
	new line_text[256], line_len, line_num
	new file_lines = file_size(offlinelist, 1)
	server_print("[OFBANSYSTEM] file_lines = %d", file_lines)
	line_num = file_lines
	//line_num++

	for (line_num; line_num > 0 ; line_num--) 
	{	

		read_file(offlinelist, line_num, line_text, 255, line_len)
		// L 02/04/2023 - 17:22:01: STEAM_0:1:168151617 192.168.0.12 America
		// new num = parse(line_text,arg1,charsmax(arg1),a_data,charsmax(a_data),arg3,charsmax(arg3),a_time,charsmax(a_time), a_steamid, charsmax(a_steamid), a_ip, charsmax(a_ip))
		// server_print("[OFBANSYSTEM] %s", line_text)
		new pos = containi(line_text, steamidp)
		if(pos != -1)
		{

			if( (file_lines-line_num) > 200 || (file_lines-line_num) < 40)
			{
				if((file_lines-line_num) < 3) // 
				{
					server_print("[OFBANSYSTEM] LAST CONNECTIONS SAFE")
					return PLUGIN_CONTINUE
				}
				else if((file_lines-line_num) > 200 )
				{
					log_to_file("allinfo_players.txt","%s %s %s", steamidp, usrip, name)
					server_print("[OFBANSYSTEM] old user log to file again as %s line: %d, name: %s", steamidp, file_lines, name)
					// log to file
					return PLUGIN_CONTINUE
				}
				
			}
	
			if ((file_lines-line_num) <= 200)
			{
				server_print("[OFBANSYSTEM] old user connnected. steam: %s line: %d , name: %s",steamidp, line_num , name)
				return PLUGIN_CONTINUE
			}		
		}
	}
	// log to file
	log_to_file("allinfo_players.txt","%s %s %s", steamidp, usrip, name)

	//server_print("[OFBANSYSTEM] Type to console ^"ofb 74 22 Reason^" its calls ban line, minutes, reason for ban")
	// if(id!=0)
			//console_print(id,"Type to console ^"ofb 74 22 Reason^" its calls ban line, minutes, reason for ban")


}
/////////////////////////////////
/*
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
*/

public file_readn_print_ask(id, level, cid)
{
	if (!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED

	file_readn_print(id)
}


public file_readn_print(id)
{	
	/*
	new cfg_dir[64] // создали массив берём адрес конфиг
	get_configsdir(cfg_dir, 63)
	trim(cfg_dir) // видимо убрать пробелы
	server_print("[OFBANSYSTEM] cdg_dir = %s", cfg_dir)
	format(offlinelist, 127, "%s/%s", cfg_dir, DOD_KSFILE)
	*/
	new word[] = {"STEAM_"}


	if (!file_exists(offlinelist))
		return PLUGIN_CONTINUE
	if (file_exists(offlinelist)) 
		server_print("[OFBANSYSTEM] file exists = %s", offlinelist)
	
	
	
	new line_text[256], line_len, line_num
	new file_lines = file_size(offlinelist, 1)
	server_print("[OFBANSYSTEM] file_lines = %d", file_lines)
	if(file_lines > 21 ) line_num = file_lines - 20
	if(file_lines <=1) line_num = 1

	for (line_num; line_num <= file_lines; line_num++) 
	{	
		new a_name2[33]
		new a_name3[16]
		new a_name4[16]
		new a_name5[16]
		new a_name6[16]
		new a_name7[16]
		new a_name8[16]

		read_file(offlinelist, line_num, line_text, 255, line_len)
		// L 02/04/2023 - 17:22:01: STEAM_0:1:168151617 192.168.0.12 America
		new num = parse(line_text,arg1,charsmax(arg1),a_data,charsmax(a_data),arg3,charsmax(arg3),a_time,charsmax(a_time), a_steamid, charsmax(a_steamid), a_ip, charsmax(a_ip), a_name, 31, a_name2, 31, a_name3, 16,  a_name4, 16, a_name5, 16, a_name6, 16, a_name7, 16, a_name8)
		// server_print("[OFBANSYSTEM] %s", line_text)
		new pos = containi(line_text, word)
		if(pos != -1)
		{
			// server_print("[OFBANSYSTEM] line: %d text=%s",line_num, line_text )
			server_print("[OFBANSYSTEM] %s line: %d %s %s %s %s %s %s %s %s %s",a_data, line_num, a_name, a_name2, a_name3, a_name4, a_name5, a_name6, a_name7, a_name8, a_steamid )
			// server_print("[OFBANSYSTEM] line: %d %s %s",line_num, a_data, a_name )
			if(id!=0)
				console_print(id, "%s line: %d %s %s %s %s %s %s %s %s %s",a_data, line_num, a_name, a_name2, a_name3, a_name4, a_name5, a_name6, a_name7, a_name8, a_steamid )
		}

	}
	server_print("[OFBANSYSTEM] Type to console ^"ofb 74 22 Reason^" its calls ban line, minutes, reason for ban")
	if(id!=0)
			console_print(id,"Type to console ^"ofb 74 22 Reason^" its calls ban line, minutes, reason for ban")

	
}

public offlineban_ask(id, level, cid)
{
	if (!cmd_access(id, level, cid, 1))
		return PLUGIN_CONTINUE
	/// 
	new a_mess[128]
	read_args(a_mess, charsmax(a_mess))

	new r_line[5]
	new r_time[5]
	new r_reason[128]
	new num = parse(a_mess, r_line,charsmax(r_line), r_time,charsmax(r_time), r_reason,charsmax(r_reason))

	// server_print("[OFBANSYSTEM] Ban line: %s in time: %s reason: %s", r_line , r_time, r_reason)

	new b_line = str_to_num(r_line)
	new b_time = str_to_num(r_time)

	if (!file_exists(offlinelist))
		return PLUGIN_CONTINUE
	new line_text[256]
	new line_len
	read_file(offlinelist, b_line, line_text, 255, line_len)
	// server_print("[OFBANSYSTEM] bna 2 line: %d text=%s",b_line, line_text )	
	new nume2 = parse(line_text,arg1,charsmax(arg1),a_data,charsmax(a_data),arg3,charsmax(arg3),a_time,charsmax(a_time), a_name, charsmax(a_name), a_steamid, charsmax(a_steamid), a_ip, charsmax(a_ip))
	// server_print("[OFBANSYSTEM] 2222222 [%s], Data:[%s] %s %s name: %s %s ip: %s ",arg1, a_data, arg3, a_time, a_name, a_steamid, a_ip)

	new banmessage[256]
	// amx_addban wewewew STEAM_0:1:168151617 5 atd
	// amx_ban "America" "1" "testban"  
	format(banmessage, 255, "amx_addban ^"%s^" ^"%s^" ^"%d^" ^"%s^"", a_name, a_steamid, b_time, r_reason)
	//format(banmessage, 255, "amx_ban ^"%s^" ^"%d^" ^"%s^"", a_steamid, b_time, r_reason)
	server_print("[OFBANSYSTEM] Banmessage: %s", banmessage)
	if(id!=0)
		console_print(id, "Banmessage: %s", banmessage)
	server_cmd(banmessage)
	// amx_ban <nick, #userid, authid> <time in minutes> <reason>
}