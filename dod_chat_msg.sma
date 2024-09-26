#include <amxmodx>
#include <amxmisc>



new Filename[256]
#define File_path "addons/amxmodx/logs/chat/"

public plugin_init()
{   
    
    new CurrentYear[8];
	new CurrentMonth[8];
	new CurrentDay[3];
	new CurDayTmp[3];
	new CurDay, CurTmpDay;
	get_time("20%y",CurrentYear,7);
	get_time("%m",CurrentMonth,7);
	get_time("%d",CurrentDay, 2);
	server_print("[Filename] Data: %s %s %s", CurrentDay , CurrentMonth, CurrentYear)

	format(Filename, 255, "%s%s%s%s.ini",  File_path, CurrentYear,CurrentMonth,CurrentDay)
	server_print("[Filename] Filename: %s", Filename)


    // Creating dirrectory
	new direx = dir_exists(File_path)
	if(direx == 0)
	{
		server_print("(!)[Filename] Dirrectory not exists = %s", File_path)
		mkdir(File_path)
	}
	if (!file_exists(Filename))
	{   
		server_print("(!)[Filename] file not exists = %s", Filename)
		log_to_file(Filename, "Safety line string writing for create file")
	}

	if (file_exists(Filename)) 
		server_print("[Filename] file exists = %s", Filename)

    register_clcmd("say", "get_chat_data")
}



public get_chat_data(id)
{
        new szMessage[192]
        read_args(szMessage, charsmax( szMessage ))
        remove_quotes(szMessage)

        new authid[32], usrip[32], name[32]
        get_user_authid(id,authid,31)
        get_user_name(id,name,31)
        get_user_ip(id,usrip,31,1)
        
        /// here you shold know what is FILENAME
        log_to_file(Filename,"%s %s %s: %s", authid, usrip, name, szMessage)
}