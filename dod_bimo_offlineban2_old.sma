#include <amxmodx>
#include <amxmisc>

#define File_path "addons/amxmodx/logs/r/"
#define a_namemax 32
new g_menu_day[33]

public plugin_init() {
	register_plugin("LOG_CONNCECTIONS","0.1","America")

	register_concmd ("cb", "menu_dir_browse")
}

public client_putinserver(id)
{	
    if (is_user_bot(id)) return PLUGIN_CONTINUE

	
    new authid[32], usrip[32], name[32]
    
    get_user_authid(id,authid,31)
    get_user_name(id,name,31)
    
    if(!is_user_connected(id)) 
    {
        return PLUGIN_CONTINUE
    }
    get_user_ip(id,usrip,31,1)

    file_write_connection(id, authid, usrip, name)
    
    return PLUGIN_CONTINUE

}




public file_write_connection(id, steamidp[], usrip[], name[])
{   
	new CurrentMonth[32];
	new CurrentDay[3];
	new CurDayTmp[3];
	new Cday, Ctday;

	get_time("%y%m",CurrentMonth,31);
	get_time("%d",CurrentDay, 2);
	server_print("[Filename] Data: %s  day  %s", CurrentMonth , CurrentDay)

	new Filename[256]
	format(Filename, 255, "%s%s.ini",  File_path, CurrentMonth)
	//format(banmessage, 255, "amx_ban ^"%s^" ^"%d^" ^"%s^"", a_steamid, b_time, r_reason)
	server_print("[Filename] Filename: %s", Filename)


	// Creating dirrectory
	new direx = dir_exists(File_path)
	if(direx == 0)
	{
		mkdir(File_path)
	}
	if (!file_exists(Filename))
	{   
		server_print("[Filename] file (!) not exists = %s", Filename)
		log_to_file(Filename, "Safety writing to create file")
	}

	if (file_exists(Filename)) 
		server_print("[Filename] file exists = %s", Filename)


	new line_text[256], line_len, line_num
	new file_lines = file_size(Filename, 1)

	server_print("[Filename] Total Lines: %d", file_lines)
	line_num = file_lines-2

	Cday = str_to_num(CurrentDay);

	for(line_num;line_num>0;line_num--)
	{	
		read_file(Filename, line_num, line_text, 255, line_len)
		// L 02/04/2023 - 17:22:01: STEAM_0:1:168151617 192.168.0.12 America
		// new num = parse(line_text,arg1,charsmax(arg1),a_data,charsmax(a_data),arg3,charsmax(arg3),a_time,charsmax(a_time), a_steamid, charsmax(a_steamid), a_ip, charsmax(a_ip))
		server_print("[Filename] %s", line_text)
		CurDayTmp[0] = line_text[5]
		CurDayTmp[1] = line_text[6]
		Ctday = str_to_num(CurDayTmp);
			//server_print("[Filename] %d, %d", Cday, Ctday )

		new pos = containi(line_text, steamidp)
		if(pos != -1)
		{  
		// Если SteamID уже был записан
		server_print("[Filename] Founded in Line: %d %s", line_num+1, steamidp)
		if(Ctday == Cday)            
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



//lets make the function that will make the menu
 public menu_dir_browse( id )
 {
	// Creating dirrectory
	new direx = dir_exists(File_path)
	if(direx == 0)
	{
		mkdir(File_path)
		server_print(" Created %s",File_path)
	}	
    new menu_dir = menu_create( "\rBan players \w Folder Browser", "menu_dir_press" );
	new dir, Filename[5]
    dir=open_dir(File_path, Filename, sizeof(Filename)-1)
	if(dir)
	{
		server_print(" Dirrectory opened")
		while (next_file(dir, Filename, sizeof(Filename)-1))
		{	
			server_print("%s",Filename)
       		//menu_additem( menu, Filename, "", 0)
			menu_additem( menu_dir, Filename, "", 0)
			
		}
	}
	
	close_dir(dir)
	menu_setprop( menu_dir, MPROP_EXIT, MEXIT_ALL );
	menu_display(id, menu_dir, 0);
 }



 
 public menu_dir_press( id, menu, item )
 {
    //Because of the simplicity of this menu, we can switch for which item was pressed
    //Note - this is zero-based, so the first item is 0    
	new m_Data[64], m_Name[64], i_Access, i_Callback
	menu_item_getinfo(menu, item, i_Access, m_Data, charsmax(m_Data), m_Name, charsmax(m_Name), i_Callback)
	//server_print("item[%d]",item)
	//server_print("Access[%d]",i_Access)
	server_print("Data[%s]",m_Data)
	server_print("Name[%s]",m_Name)
	//server_print("Callback[%d]",i_Callback)

    menu_file_browse(id, menu, item, m_Name , m_Data )
    //lets finish up this function by destroying the menu with menu_destroy, and a return
	menu_destroy( menu )

    return PLUGIN_HANDLED;
 }

 public menu_file_browse(id, menu, item, m_Name[] , m_Data[] )
 {
	client_print(0, print_chat, "menu %d item %d", id , item) 
	new CurrentMonth[32]
    new CurrentDay[3]
    new CurDayTmp[3]
	new Cday
	new Ctday
	new CDayDown
	new arg1[2]
	new a_data[11]
	new arg3[2]
	new a_time[10]
	new a_name[33]
	new a_steamid[24]
	new a_ip[32]

	new a_name2[33]
	new a_name3[16]
	new a_name4[16]
	new a_name5[16]
	new a_name6[16]
	new a_name7[16]
	new a_name8[16]

	new menu_nhand[256]
	new num
	CDayDown = 32
	get_time("%d",CurrentDay, 2) 
	
    //g_menu = menu_create( "\rBan players \w File Browser", "menu_file_press" );
	new menu_file = menu_create( "\rBan players \w File Browser", "menu_file_press" );
	new dir, Filename[256]
    dir = open_dir(File_path, Filename, sizeof(Filename)-1)
	if (dir)
	{
		server_print(" Dirrectory opened")
		new ItC = 0
		while (next_file(dir, Filename, sizeof(Filename)-1))
		{	
			ItC++
			if(ItC == item+1)
			{		
				format(Filename, 255, "%s%s",  File_path, Filename)
				server_print("[Filename] Choosed Item: %d, %s", ItC,Filename)

				// Start Open File cycle FULL 			
				new line_text[256], line_len, line_num
				new file_lines = file_size(Filename, 1)

				server_print("[Filename] Total Lines: %d %s", file_lines, Filename)
				line_num = file_lines-2
				Cday = str_to_num(CurrentDay);
				
				for (line_num; line_num > 1 ; line_num--) 
				{	
					CDayDown--
					read_file(Filename, line_num, line_text, 255, line_len)
					// L 02/11/2023 - 11:01:39: STEAM_0:1:168151617 192.168.0.13 America
					num = parse(line_text,arg1,charsmax(arg1),a_data,charsmax(a_data),arg3,charsmax(arg3),a_time,charsmax(a_time), a_steamid, charsmax(a_steamid), a_ip, charsmax(a_ip), a_name, 31, a_name2, 31, a_name3, 16,  a_name4, 16, a_name5, 16, a_name6, 16, a_name7, 16, a_name8)
					server_print("[Filename] %s", line_text)
					server_print("%s data", a_data)	
					
					CurDayTmp[0] = a_data[3]
					CurDayTmp[1] = a_data[4]
					Ctday = str_to_num(CurDayTmp);

					if(Ctday <= CDayDown)
					{
						CDayDown = Ctday
						server_print("Ctday >= CDayDown %d / %d Cuntdown", Ctday , CDayDown)	
					}	
					
					server_print("Current Temp Day from Line %d / %d Cuntdown", Ctday , CDayDown)	
					if(Ctday == CDayDown)
					{	
						format(menu_nhand, 255, "Open %s (Month/Day/Year)", a_data )
						menu_additem( menu_file, menu_nhand, Filename, 0)
						server_print("%s data Day %d Countdown = %d handler: %s", a_data, Ctday, CDayDown , menu_nhand )
					}
					
				} 
				break 
			}	
		}
	}
	
	close_dir(dir)
	menu_setprop( menu_file, MPROP_EXIT, MEXIT_ALL );
	menu_display(id, menu_file, 0);

 }


public menu_file_press( id, menu, item )
{
	new CurrentMonth[32]
    new CurrentDay[3]
    new CurDayTmp[3]
	new Cday
	new Ctday
	new CDayDown
	new arg1[2]
	new a_data[11]
	new arg3[2]
	new a_time[10]
	new a_name[33]
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
	new m_Data[64], m_Name[64], i_Access, i_Callback
	menu_item_getinfo(menu, item, i_Access, m_Data, charsmax(m_Data), m_Name, charsmax(m_Name), i_Callback)
	//server_print("item[%d]",item)
	//server_print("Access[%d]",i_Access)
	server_print("Data[%s]",m_Data)
	server_print("Name[%s]",m_Name)
	//server_print("Callback[%d]",i_Callback)
	format(Filename, 255, "%s", m_Data)
	TempArr[0] = m_Name[8]
	TempArr[1] = m_Name[9]

	TargetData = str_to_num(TempArr);
	server_print("Target Data %d",TargetData)

	menu_destroy( menu );

	new menu_day = menu_create( "\rBan players \w Day Browser", "menu_day_press" );
	// Start Open File cycle FULL 			
	new line_text[256], line_len, line_num
	new file_lines = file_size(Filename, 1)

	server_print("[Filename] Total Lines: %d %s", file_lines, Filename)
	line_num = file_lines-2

	for (line_num; line_num > 1 ; line_num--) 
	{	
		read_file(Filename, line_num, line_text, 255, line_len)
		// L 02/11/2023 - 11:01:39: STEAM_0:1:168151617 192.168.0.13 America
		new num = parse(line_text,arg1,charsmax(arg1),a_data,charsmax(a_data),arg3,charsmax(arg3),a_time,charsmax(a_time), a_steamid, charsmax(a_steamid), a_ip, charsmax(a_ip), a_name, 31, a_name2, 31, a_name3, 16,  a_name4, 16, a_name5, 16, a_name6, 16, a_name7, 16, a_name8)
		server_print("[Filename] %s", line_text)
		server_print("%s data", a_data)	
		CurDayTmp[0] = a_data[3]
		CurDayTmp[1] = a_data[4]
		Ctday = str_to_num(CurDayTmp);

		if(Ctday == TargetData)
		{
			menu_additem( menu_day, a_name, a_steamid, 0)
		}
	}

	menu_setprop( menu_day, MPROP_EXIT, MEXIT_ALL );
	menu_display(id, menu_day, 0);
	
    return PLUGIN_HANDLED;
 }

 
 public menu_day_press( id, menu, item )
 {
    //Because of the simplicity of this menu, we can switch for which item was pressed
    //Note - this is zero-based, so the first item is 0    

  
    client_print(id, print_chat, "menu %d item %d", menu , item) 


    //lets finish up this function by destroying the menu with menu_destroy, and a return
	menu_destroy( menu )

    return PLUGIN_HANDLED;
 }

 /// чере menu_item_getinfo пересобрать поисковик пунктов , счётсчик CDayDown мешает жить нормально
 /// в остальном всё близится к концу
 /// поставить callback 
 /// спрашивать уверенность бана и вариацию времени.
 /// сдеалть обработчик никнеймов что бы копировать в массив с пробелами 

