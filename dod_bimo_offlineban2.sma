#include <amxmodx>
#include <amxmisc>

#define File_path "addons/amxmodx/logs/r/"
#define a_namemax 32


public plugin_init() {
	register_plugin("NEW OFFLINEBAN","0.1","America")
	register_concmd ("newban", "menu_dir_browse", ADMIN_BAN, "123")
	//register_concmd ("newban", "menu_dir_browse")
}

public client_putinserver(id)
{	
    if (is_user_bot(id)) return PLUGIN_CONTINUE

	
    new authid[32], usrip[32], name[32]
    
    get_user_authid(id,authid,31)
    get_user_name(id,name,31)
    
    if(!is_user_connected(id)) 
    {
        return PLUGIN_CONTINUE;
    }
    get_user_ip(id,usrip,31,1)

    file_write_connection(id, authid, usrip, name)
    
    return PLUGIN_CONTINUE;

}




public file_write_connection(id, steamidp[], usrip[], name[])
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

	new Filename[256]
	format(Filename, 255, "%s%s%s.ini",  File_path, CurrentYear,CurrentMonth)
	//format(banmessage, 255, "amx_ban ^"%s^" ^"%d^" ^"%s^"", a_steamid, b_time, r_reason)
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


	new line_text[256], line_len, line_num
	new file_lines = file_size(Filename, 1)

	server_print("[Filename] Total Lines: %d", file_lines)
	line_num = file_lines-2

	CurDay = str_to_num(CurrentDay);

	for(line_num;line_num>0;line_num--)
	{	
		read_file(Filename, line_num, line_text, 255, line_len)
		// L 02/04/2023 - 17:22:01: STEAM_0:1:168151617 192.168.0.12 America
		// new num = parse(line_text,arg1,charsmax(arg1),a_data,charsmax(a_data),arg3,charsmax(arg3),a_time,charsmax(a_time), a_steamid, charsmax(a_steamid), a_ip, charsmax(a_ip))
		server_print("[Filename] %s", line_text)
		CurDayTmp[0] = line_text[5]
		CurDayTmp[1] = line_text[6]
		CurTmpDay = str_to_num(CurDayTmp);
			//server_print("[Filename] %d, %d", CurDay, CurTmpDay )

		new pos = containi(line_text, steamidp)
		if(pos != -1)
		{  
		// Если SteamID уже был записан
		server_print("[Filename] Founded in Line: %d %s", line_num+1, steamidp)
		if(CurTmpDay == CurDay)            
		{   
		// если был сегодня , то пропускаем 
		server_print("[Filename] Today reconnected %s %s %s", steamidp, usrip, name)
		return PLUGIN_HANDLED
		}
		else
		{	

		server_print("[Filename] Registered old SteamID %s %s %s", steamidp, usrip, name)
		log_to_file(Filename,"%s %s %s", steamidp, usrip, name)
		return PLUGIN_HANDLED
		}
		}
		else if(line_num < 2)
		{	

			server_print("[Filename] Registered new SteamID %s %s %s", steamidp, usrip, name)
			log_to_file(Filename,"%s %s %s", steamidp, usrip, name)
			return PLUGIN_HANDLED
		}
	// SteamID не найден
	}  
	// цикл итерации окончен.
	return PLUGIN_HANDLED
}


public menu_admin_ask(id, level, cid)
{
	if (!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED

	menu_dir_browse(id)
	return PLUGIN_CONTINUE
}


//lets make the function that will make the menu
 public menu_dir_browse( id )
 {

	// Creating dirrectory
	new direx = dir_exists(File_path)
	new FileYear, FileMonth
	if(direx == 0)
	{
		mkdir(File_path)
		server_print(" Created %s",File_path)
	}	
    new menu_dir = menu_create( "\rBan players \w Folder Browser", "menu_dir_press" );
	new dir, Filename[256], m_Name[32]
    dir = open_dir(File_path, Filename, sizeof(Filename)-1)
	if(dir)
	{
		server_print(" Dirrectory opened")
		while (next_file(dir, m_Name, sizeof(Filename)-1))
		{	
			// pozhe format(Filename, 255, "%s%s",  File_path, Filename)	
			//202304.ini and menu
			/*
			if(equal(m_Name, ".."))
			{	
				
				format(Filename, 255, "%s%s",  File_path, m_Name)
				server_print("%s", Filename)
				format(m_Name, 255, "%s (<= Back)",  m_Name)
				menu_additem( menu_dir, m_Name, Filename, 0)
			}
			if(!equal(m_Name, ".."))
			{	
				FileYear = str_to_num(m_Name)
				format(Filename, 255, "%s%s",  File_path, m_Name)
				server_print("%s", Filename)
				//menu_additem( menu, Filename, "", 0)
				menu_additem( menu_dir, m_Name, Filename, 0)
			}

			*/
			format(Filename, 255, "%s%s",  File_path, m_Name)
			server_print("%s", Filename)
			//menu_additem( menu, Filename, "", 0)
			menu_additem( menu_dir, m_Name, Filename, 0)

			
		}
	}
	
	close_dir(dir)
	menu_setprop( menu_dir, MPROP_EXIT, MEXIT_ALL );
	menu_display(id, menu_dir, 0);
 }



 
 public menu_dir_press( id, menu, item )
 {

	new m_Data[64], m_Name[64], i_Access, i_Callback
	menu_item_getinfo(menu, item, i_Access, m_Data, charsmax(m_Data), m_Name, charsmax(m_Name), i_Callback)

	server_print("[menu_dir_press]item:%d name:%s data: %s ",item, m_Name, m_Data)
    menu_file_browse(id, menu, item, m_Name , m_Data )
	menu_destroy( menu )
}

 public menu_file_browse(id, menu, item, m_Name[] , m_Data[] )
 {

	if(!file_exists(m_Data))
	{   
		server_print("(!)[menu_file_browse] file not exists = %s", m_Data)
	}
	server_print("File opened")
	new CurrentMonth[32]
    new CurrentDay[3]
    new CurDayTmp[3]
	new CurDay
	new CurTmpDay
	new CDayDown = 32
	new arg1[2]
	new a_data[64]
	new arg3[2]
	new UnicArr[33]


	new Filename[256]
	new menu_nhand[256]

	get_time("%d",CurrentDay, 2) 
	
	new menu_file = menu_create( "\rBan players \w File Browser", "menu_file_press" );
	
	format(Filename, 255, "%s",  m_Data)
	server_print("[Filename] Open Choosed File:  %s", Filename)

	// Start Open File cycle FULL 			
	new line_text[256], line_len, line_num
	new file_lines = file_size(Filename, 1)

	server_print("[Filename] Total Lines: %d %s", file_lines, Filename)
	line_num = file_lines-2
	CurDay = str_to_num(CurrentDay);
	new UnicConPerDay = 0
	new UnicConPerDay0 = 0
	
	for (line_num; line_num > 1 ; line_num--) 
	{	
		read_file(Filename, line_num, line_text, 255, line_len)
		// L 02/11/2023 - 11:01:39: STEAM_0:1:168151617 192.168.0.13 America
		new num = parse(line_text,arg1,charsmax(arg1),a_data,charsmax(a_data))
		server_print("[Filename] %s %s",a_data ,line_text)
		
		CurDayTmp[0] = a_data[3]
		CurDayTmp[1] = a_data[4]
		CurTmpDay = str_to_num(CurDayTmp);
		if(CurTmpDay < CDayDown)
		{
			
			server_print("(!)[Filename] Day %d not registered founded only %d",CDayDown ,CurTmpDay)
			CDayDown = CurTmpDay
			
			
		}
		if(CurTmpDay == CDayDown)
		{
			UnicConPerDay = UnicConPerDay0 - line_num
			UnicConPerDay0 = line_num
			server_print("[Filename] Day %d registered %d",CDayDown ,CurTmpDay)
			format(a_data, 63, "%s ; %d connections",  a_data, UnicConPerDay )
			menu_additem( menu_file, a_data, Filename, 0)
			CDayDown--
			
		}


	} 

	/*
	menu_setprop(menu_file,MPROP_NEXTNAME,"Next Page");
	menu_setprop(menu_file,MPROP_BACKNAME,"Prev Page");
	menu_setprop(menu_file,MPROP_EXITNAME," Exit");

	// menu_setprop(menu_file,MPROP_NUMBER_COLOR,"\y");	
	
	*/

	menu_setprop( menu_file, MPROP_EXIT, MEXIT_ALL );
	menu_display(id, menu_file, 0);

 }


public menu_file_press( id, menu, item )
{
	
	new m_Data[64], m_Name[64], i_Access, i_Callback
	menu_item_getinfo(menu, item, i_Access, m_Data, charsmax(m_Data), m_Name, charsmax(m_Name), i_Callback)
	server_print("Data[%s]",m_Data)
	server_print("Name[%s]",m_Name)
	menu_day_browse(id, menu, item, m_Name, m_Data)
	/*
	Data[addons/amxmodx/logs/r/202303.ini]
	Name[03/29/2023]
	*/

	//menu_day_browse(id, menu, item, m_Name[] , m_Data[])

	// menu_destroy( menu )
	
}

public menu_day_browse(id, menu, item, m_Name[] , m_Data[])
{
	if(!file_exists(m_Data))
	{   
		server_print("(!)[menu_file_browse] file not exists = %s", m_Data)
	}
	server_print("File opened")

	new CurrentMonth[32]
    new CurrentDay[3]
    new CurDayTmp[3]
	new CurDay
	new CurTmpDay
	new CDayDown
	new arg1[2]
	new a_data[11]
	new arg3[2]
	new a_time[10]
	new a_name[64]
	new a_steamid[24]
	new a_ip[32]
	
	new a_name2[33]
	new a_name3[16]
	new a_name4[16]
	new a_name5[16]
	new a_name6[16]
	new a_name7[16]
	new a_name8[16]
	
	new Filename[256]
	new TargetData
	new TempArr[3]

	server_print("menu_day_browse[%s]",m_Data)
	server_print("menu_day_browse[%s]",m_Name)
	format(Filename, 255, "%s", m_Data)
	TempArr[0] = m_Name[3]
	TempArr[1] = m_Name[4]
	// 04/16/2023
	TargetData = str_to_num(TempArr);
	server_print("Target Data: %d",TargetData)

	menu_destroy( menu );

	new menu_day = menu_create( "\rBan players \w Day Browser", "menu_day_press" );
	// Start Open File cycle FULL 			
	new line_text[256], line_len, line_num
	new file_lines = file_size(Filename, 1)

	server_print("[Filename] Total Lines: %d %s", file_lines, Filename)
	line_num = file_lines-2

	for (line_num; line_num > 1 ; line_num--) 
	{	
		a_name2 = ""
		a_name3 = ""
		a_name4 = ""
		a_name5 = ""
		a_name6 = ""
		a_name7 = ""
		a_name8 = ""
		read_file(Filename, line_num, line_text, 255, line_len)
		// L 02/11/2023 - 11:01:39: STEAM_0:1:168151617 192.168.0.13 America
		new num = parse(line_text,arg1,charsmax(arg1),a_data,charsmax(a_data),arg3,charsmax(arg3),a_time,charsmax(a_time), a_steamid, charsmax(a_steamid), a_ip, charsmax(a_ip), a_name, 31, a_name2, 31, a_name3, 16,  a_name4, 16, a_name5, 16, a_name6, 16, a_name7, 16, a_name8)
		server_print("[Filename] %s", line_text)
		server_print("%s data", a_data)	
		CurDayTmp[0] = a_data[3]
		CurDayTmp[1] = a_data[4]
		CurTmpDay = str_to_num(CurDayTmp);

		if(CurTmpDay == TargetData)
		{	
			format(a_name, 255, "%s%s%s%s%s%s%s%s", a_name, a_name2,a_name3,a_name4,a_name5,a_name6,a_name7,a_name8)
			menu_additem( menu_day, a_name, a_steamid, 0)
		}
	}

	menu_setprop( menu_day, MPROP_EXIT, MEXIT_ALL );
	menu_display(id, menu_day, 0);
	
    return PLUGIN_HANDLED;
}
 
 public menu_day_press( id, menu, item )
 {

	new m_Data[64], m_Name[64], i_Access, i_Callback
	menu_item_getinfo(menu, item, i_Access, m_Data, charsmax(m_Data), m_Name, charsmax(m_Name), i_Callback)
	server_print("Data[%s]",m_Data)
	server_print("Name[%s]",m_Name)
	menu_nick_browse(id, menu, item, m_Name, m_Data)

    //lets finish up this function by destroying the menu with menu_destroy, and a return
	// menu_destroy( menu )

    return PLUGIN_HANDLED;
 }

 /// 09090 0900 чере menu_item_getinfo пересобрать поисковик пунктов , счётсчик CDayDown мешает жить нормально
 /// в остальном всё близится к концу
 /// поставить callback 
 /// спрашивать уверенность бана и вариацию времени.
 /// 909090 сдеалть обработчик никнеймов что бы копировать в массив с пробелами 

public menu_nick_browse(id, menu, item, m_Name[] , m_Data[])
{	
//Data[STEAM_0:1:5754444497]
//Name[Big Fly      ]
//create ban and unban menu with 
	new m_Name2[256]

	format(m_Name2, 255, "\rBan player: \w %s - %s", m_Name, m_Data)
	
	new menu_nick = menu_create( m_Name2, "menu_nick_press" );

	format(m_Name2, 255, "^"%s^" Ban for 10 minutes", m_Name)
	menu_additem( menu_nick, m_Name2, m_Data, 0)
	format(m_Name2, 255, "^"%s^" Ban for 30 minutes", m_Name)
	menu_additem( menu_nick, m_Name2, m_Data, 0)
	format(m_Name2, 255, "^"%s^" Ban for 1 hour", m_Name)
	menu_additem( menu_nick, m_Name2, m_Data, 0)
	format(m_Name2, 255, "^"%s^" Ban for 1 day", m_Name)
	menu_additem( menu_nick, m_Name2, m_Data, 0)
	format(m_Name2, 255, "^"%s^" Ban for 6 days", m_Name)
	menu_additem( menu_nick, m_Name2, m_Data, 0)
	format(m_Name2, 255, "^"%s^" Ban PERMAMENT", m_Name)
	menu_additem( menu_nick, m_Name2, m_Data, 0)
	format(m_Name2, 255, "^"%s^" UNBAN !", m_Name)
	menu_additem( menu_nick, m_Name2, m_Data, 0)

	menu_setprop( menu_nick, MPROP_EXIT, MEXIT_ALL );
	menu_display(id, menu_nick, 0);
}

public menu_nick_press( id, menu, item )
{

	new m_Data[64], m_Name[64], i_Access, i_Callback
	new banmessage[256]
	new o_Nick[64]
	menu_item_getinfo(menu, item, i_Access, m_Data, charsmax(m_Data), m_Name, charsmax(m_Name), i_Callback)
	server_print("Data[%s]",m_Data)
	server_print("Name[%s]",m_Name)
	server_print("Banitem[%d]",item)


	new num = parse(m_Name,o_Nick,charsmax(o_Nick))
	server_print("o_Nick[%s]",o_Nick)


	menu_destroy( menu )
	switch (item)
	{
	case 0:
		{
			format(banmessage, 255, "amx_addban ^"%s^" ^"%s^" ^"10^" ^"newofflineban^"", o_Nick, m_Data)
		}
	case 1:
		{
			format(banmessage, 255, "amx_addban ^"%s^" ^"%s^" ^"30^" ^"newofflineban^"", o_Nick, m_Data)
		}
	case 2:
		{
			format(banmessage, 255, "amx_addban ^"%s^" ^"%s^" ^"60^" ^"newofflineban^"", o_Nick, m_Data)
		}
	case 3:
		{
			format(banmessage, 255, "amx_addban ^"%s^" ^"%s^" ^"1440^" ^"newofflineban^"", o_Nick, m_Data)
		}
	case 4:
		{
			format(banmessage, 255, "amx_addban ^"%s^" ^"%s^" ^"8640^" ^"newofflineban^"", o_Nick, m_Data)
		}
	case 5:
		{
			format(banmessage, 255, "amx_addban ^"%s^" ^"%s^" ^"0^" ^"newofflineban^"", o_Nick, m_Data)
		}
	case 6:
		{
			format(banmessage, 255, "amx_unban ^"%s^"", m_Data)
		}
	}
		
	// amx_addban wewewew STEAM_0:1:168151617 5 atd
	// amx_ban "America" "1" "testban"  
	//format(banmessage, 255, "amx_addban ^"%s^" ^"%s^" ^"%d^" ^"%s^"", a_name, a_steamid, b_time, r_reason)
	//format(banmessage, 255, "amx_ban ^"%s^" ^"%d^" ^"%s^"", a_steamid, b_time, r_reason)
	server_print("[OFBANSYSTEM] Banmessage: %s", banmessage)

	server_cmd(banmessage)
		
}