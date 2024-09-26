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

#define TK_P_SLAY			(1<<0)
#define TK_P_MIRROR_DMG		(1<<1)


#define MAX_CONNECTIONS 1024
new g_connections
enum _:PLAYER_DATA
{
    STID[33],
    tkills,
    zanyat,
	gameid,
	named[32],
    yourkiller
}
new g_cache_stID[MAX_CONNECTIONS][PLAYER_DATA]
new session_id_to_registerlist[MAX_CONNECTIONS]
new g_TKcount[33]
new g_TKlimit
new g_TKbantime

new g_infomessages
new g_forgivetype

new g_servername[32]


public plugin_init()
{
	register_plugin("DOD TK NEW ","0.0","America")
	server_print("DOD TK NEW")

    register_event("DeathMsg", "player_died", "e") // private E event
    register_clcmd("say","HandleSay")
	register_clcmd("say_team","HandleSay")
	register_concmd ("tklist", "tk_list_print_console") 

	register_menucmd(register_menuid("Forgive"),1023,"actionFGMenu")

    g_forgivetype = 2 // -  how to forgive, 0="say forgivetk", 1=Yes/No menu, 2=both
    g_TKlimit = 6
    g_infomessages = 0 //  0= NO//   1 = show information messages (chat text) 
    g_TKbantime = 60 // Minutes for ban after 10 TKills
    g_servername = "server"
}

/// CACHE STEAM ID 

public client_connect(id)
{  
    if (is_user_bot(id))
		return PLUGIN_CONTINUE
    new stID[33]
    get_user_authid(id, stID, 32)
    
    static i
    for (i=1; i < MAX_CONNECTIONS; i++) 
    {   
        
        if( equal(stID, g_cache_stID[i][STID] ))
        {   
            // мы нашли человека который уже в этой сессии подключался.
            // В отдельном массиве текущей игры записываем ему адрес в реестре.
            session_id_to_registerlist[id] = i
            g_cache_stID[i][gameid] = id
            g_TKcount[id] = g_cache_stID[session_id_to_registerlist[id]][tkills]
            get_user_name(id,g_cache_stID[i][named],31)
            server_print("[TK_SYSTEM] 2nd Connect: %s # %d , TK in session: %d", g_cache_stID[i][named] , i, g_cache_stID[i][tkills])
            // найти порядковый номер в ресстре, и
            //  на основе порядкового номера посчитать teamkills
            if( g_cache_stID[i][tkills] >= 10)
            {   
                // server_print("[TK_SYSTEM] LIST## BANNED List ID: %d , Steam: %s , Teamkills in this session: %d", i ,stID, g_cache_stID[i][tkills])
                // ban kick
            }
            else
            {   
                // server_print("[TK_SYSTEM] LIST## HIS KILLS is %d of 10!", g_cache_stID[i][tkills])
                /// message : если вы убьете больше 10 , вы будете забанены.
            }
            return PLUGIN_CONTINUE
        }
        else if(!equal(stID, g_cache_stID[i][STID]))
        {
            if(g_cache_stID[i][zanyat] != 1)
            {
                
                g_cache_stID[i][STID]= stID
                g_cache_stID[i][tkills]= 0
                session_id_to_registerlist[id] = i
                g_cache_stID[i][zanyat] = 1
                g_cache_stID[i][gameid] = id
                get_user_name(id,g_cache_stID[i][named],31)
                g_connections++
                // записали новый SteamID в реестр.
                // client_print(0 , print_chat, " :%d : Steam: %s", i ,stID)
                server_print("[TK_SYSTEM] REGISTERED NEW: %s # %d",  g_cache_stID[i][named] ,i)
                return PLUGIN_CONTINUE
            }
        }
    }
    return PLUGIN_CONTINUE 
} 

public client_death(killer,victim,wpnindex,hitplace,TK)
{
	if (!TK || killer==victim || is_user_bot(killer))
		return PLUGIN_CONTINUE
	
	TKPunish(killer, victim)
	return PLUGIN_CONTINUE 
} 

public TKPunish(killer, victim)
{
    
	g_TKcount[killer]++
    g_cache_stID[session_id_to_registerlist[killer]][tkills] = g_TKcount[killer]
    g_cache_stID[session_id_to_registerlist[victim]][yourkiller] = killer
    // yourkiller
	if (g_TKcount[killer] < 1)
		return 0

	new name[32]
	get_user_name(killer,name,31)

	if (g_TKcount[killer] < g_TKlimit)
	{
		set_hudmessage(255, 255, 255, 0.05, 0.575, 0, 3.0, 3.0, 0.1, 0.5, 8)  
		show_hudmessage(0,"%s^nTK warning %i of %i", name, g_TKcount[killer], g_TKlimit)
	}
	else if (g_TKcount[killer] == g_TKlimit)
	{
        //if(is_user_bot(victim))
			//set_task(0.5,"BAN_FOR_ATIME",killer)
		set_hudmessage(255, 255, 255, 0.05, 0.575, 0, 3.0, 3.0, 0.1, 0.5, 8)  
		show_hudmessage(0,"%s^nSlayed for violating %i TK warning", name, g_TKlimit)
		set_task(0.5,"BAN_FOR_ATIME",killer)
	}
	else
	{
        // if(!is_user_bot(victim))
			// set_task(0.5,"BAN_FOR_ATIME",killer)
		set_hudmessage(255, 0, 0, 0.05, 0.575, 0, 3.0, 3.0, 0.1, 0.5, 8)  
		set_task(0.5,"BAN_FOR_ATIME",killer)


        if ((g_TKbantime % 1440)==0)
        {
            show_hudmessage(0,"%s^nExceeded %i TK limit and is BANNED for %d hours", name, g_TKlimit, (g_TKbantime / 60))
            
        }
        else if (g_TKbantime < 60)
        {
            show_hudmessage(0,"%s^nExceeded %i TK limit and is BANNED for %d minutes", name, g_TKlimit, (g_TKbantime % 1440))
            
        }
        else
        {
            show_hudmessage(0,"%s^nExceeded %i TK limit and is BANNED for %d hours %d minutes", name, g_TKlimit, (g_TKbantime / 60), (g_TKbantime % 1440))
            
        }
		return PLUGIN_CONTINUE
	}
	if (g_infomessages)
	{
		client_print(0,print_chat,"[ADMIN] %i team kills will get you slayed", g_TKlimit) 
		if ((g_TKbantime % 1440)==0)
			client_print(0,print_chat,"[ADMIN] %i team kills will get you a %d HOUR ban from %s",g_TKlimit + 1,(g_TKbantime / 60),g_servername) 
		else if (g_TKbantime < 60)
			client_print(0,print_chat,"[ADMIN] %i team kills will get you a %d MINUTE ban from %s",g_TKlimit + 1,(g_TKbantime % 1440),g_servername) 

		else
		client_print(0,print_chat,"[ADMIN] %i team kills will get you a %d HOUR %d MINUTE ban from %s",g_TKlimit + 1,(g_TKbantime / 60),(g_TKbantime % 1440),g_servername) 
		client_print(0,print_chat,"[ADMIN] Team killers can be forgiven by saying forgivetk") 
	}

	if (g_forgivetype!=0)
	{
        // Если жертва == бот, простить.
		if(!is_user_bot(victim))
		{
		new menuBody[192]
		format(menuBody,191,"Forgive %s's TK?^n^n1. Yes^n2. No^n^n3. Exit^n",name)
		new keys = (1<<0)|(1<<1)|(1<<2)
		show_menu(victim,keys,menuBody,30)
        }
	}
	return PLUGIN_CONTINUE
}

public actionFGMenu(id,key)
{
	switch(key)
	{
		case 0:
		{
			/*
			// victim's killer id
			g_cache_stID[session_id_to_registerlist[id]][yourkiller]
			// killers's tk 
			g_cache_stID[session_id_to_registerlist[g_cache_stID[session_id_to_registerlist[id]][yourkiller]]][tkills] 
			// victim adress
			session_id_to_registerlist[id] 
			// killer's adress
			session_id_to_registerlist[g_cache_stID[session_id_to_registerlist[id]][yourkiller]] 
			//
			*/

			g_TKcount[g_cache_stID[session_id_to_registerlist[id]][yourkiller]]--

			new NameV[32], NameK[32]
			get_user_name(id,NameV,31)
			get_user_name(g_cache_stID[session_id_to_registerlist[id]][yourkiller],NameK,31)

			set_hudmessage(0, 90, 235, 0.05, 0.675, 0, 3.0, 3.0, 0.1, 0.5, 9)  
			show_hudmessage(0,"%s has forgiven %s's TK.", NameV, NameK)

		}
	}

	return PLUGIN_HANDLED
}

/////////////////////////////
public tk_list_print_console(id)
{
	new line_num = 1
	for (line_num; line_num < 16 ; line_num++) 
	{	
		if(is_user_connected(line_num) && (!is_user_bot(line_num)))
		{
			// print every strins
			// по текущему онлайну
			server_print("%d %s tk: %d . %s", line_num, g_cache_stID[session_id_to_registerlist[line_num]][named] , g_cache_stID[session_id_to_registerlist[line_num]][tkills], g_cache_stID[session_id_to_registerlist[line_num]][STID] )
			// по порядку server_print("%d %s tk: %d . %s", line_num, g_cache_stID[line_num][named] , g_cache_stID[line_num][tkills], g_cache_stID[line_num][STID] )
			if(id!=0)
				console_print(id, "%d %s tk: %d . %s", line_num, g_cache_stID[session_id_to_registerlist[line_num]][named] , g_cache_stID[session_id_to_registerlist[line_num]][tkills], g_cache_stID[session_id_to_registerlist[line_num]][STID] )
		}
		
	}

	set_task(0.2, "tk_list_print_console2", id)
}
public tk_list_print_console2(id)
{
	new line_num = 16
	for (line_num; line_num < 33 ; line_num++) 
	{	
		if(is_user_connected(line_num) && (!is_user_bot(line_num)))
		{
			// print every strins
			// по текущему онлайну
			server_print("%d %s tk: %d . %s", line_num, g_cache_stID[session_id_to_registerlist[line_num]][named] , g_cache_stID[session_id_to_registerlist[line_num]][tkills], g_cache_stID[session_id_to_registerlist[line_num]][STID] )
			// по порядку server_print("%d %s tk: %d . %s", line_num, g_cache_stID[line_num][named] , g_cache_stID[line_num][tkills], g_cache_stID[line_num][STID] )
			if(id!=0)
				console_print(id, "%d %s tk: %d . %s", line_num, g_cache_stID[session_id_to_registerlist[line_num]][named] , g_cache_stID[session_id_to_registerlist[line_num]][tkills], g_cache_stID[session_id_to_registerlist[line_num]][STID] )
		}
		
	}

	// set_task(0.1, "tk_list_print_console2", id)

}
























/////// CHAT FORGIVE 
public HandleSay(id)
{
	if (g_forgivetype==1)
		return PLUGIN_CONTINUE

	new text[12]
	read_argv(1,text,11)

	if (forgivetk(text))
	{
		new menuid, keys
		// if they still have menu on screen then cancel it
		if (get_user_menu(id,menuid,keys))
			client_cmd(id,"slot3")
		forgiveNewTK(id)
	}
	return PLUGIN_CONTINUE
}

stock forgivetk(text[])
{
	if (containi(text,"forgivetk") == 0)
		return 1
	if (containi(text,"!forgivetk") == 0)
		return 1
	if (containi(text,"forgive tk") == 0)
		return 1
	if (containi(text,"!forgive tk") == 0)
		return 1

	return 0
}


forgiveNewTK(id)
{

	g_TKcount[session_id_to_registerlist[g_cache_stID[session_id_to_registerlist[id]][yourkiller]]]--
	g_cache_stID[session_id_to_registerlist[g_cache_stID[session_id_to_registerlist[id]][yourkiller]]][tkills] = g_TKcount[session_id_to_registerlist[g_cache_stID[session_id_to_registerlist[id]][yourkiller]]]
	new NameV[32]
	get_user_name(id,NameV,31)

	new NameK[32]
	get_user_name(session_id_to_registerlist[g_cache_stID[session_id_to_registerlist[id]][yourkiller]],NameK,31)

	set_hudmessage(0, 90, 235, 0.05, 0.675, 0, 3.0, 3.0, 0.1, 0.5, 9)  
	show_hudmessage(0,"%s has forgiven %s's TK.", NameV, NameK)
	
}



public BAN_FOR_ATIME(id)
{	
	// g_TKbantime
	////////
	if(!is_user_connected(id))
		return PLUGIN_CONTINUE
	if(is_user_admin(id))
		return PLUGIN_CONTINUE
	new a_name[32]
	new a_steamid[32]
	new banmessage[256]

	get_user_authid(id,a_steamid,31)
	get_user_name(id,a_name,31)
	// amx_addban wewewew STEAM_0:1:168151617 5 atd

	
	format(banmessage, 255, "amx_addban ^"%s^" ^"%s^" ^"60^" ^"Teamkills^"", a_name, a_steamid)
	server_print("[TK_SYSTEM] Banmessage: %s", banmessage)
	if(id!=0)
		console_print(id, "Banmessage: %s", banmessage)
	server_cmd(banmessage)
}


//// PANZERSHCRE KILLS FIX 
public player_died()
{   
	new ki = read_data(1) // killer
	new vi = read_data(2) // victim
    new d = read_data(3) // WEAPON
    if (d == DODW_BAZOOKA || d == DODW_PIAT || d == DODW_PANZERSCHRECK || d == 0)
    {
		dod_set_user_kills(ki, dod_get_user_kills(ki) + 1 , 1)
		
		if(get_user_team(ki)==get_user_team(vi))
		{
			g_cache_stID[ki][tkills]++
			// client_death(ki,vi,d,1,1)
		}
    }
	
}