
/* AMXMOD script - dod_tk_manager
*
*  Team Killer manager for DOD - by Fractal (fractal323@comcast.net) and SidLuke (sidluke@o2.pl)
*  Provides simple automated control over TKers
*
*  Commands to forgive tks are any of "forgivetk", "forgive tk", "!forgivetk", "!forgive tk"
*  (can be upper or lower case)
*
*
*  Cvar settings (put in amx.cfg):
*  -------------------------------
*  amx_tk_limit <value>               -  number of TKs allowed before banning
*  amx_tk_bantime <minutes>           -  how long to ban if limit exceeded (0=permanent)
*  amx_tk_adminimmunity <0|1>         -  prevent admin from being kicked/banned for TKing
*                                        (for admins with ADMIN_BAN access)
*  amx_tk_forgivetype <0|1|2>         -  how to forgive, 0="say forgivetk", 1=Yes/No menu, 2=both
*  amx_tk_usemapmemory <0|1>          -  use map specific TK memory (prevents TKers from
*                                        resetting their counter by disconnecting/reconnecting)
*  amx_tk_infomessages <0|1>          -  show information messages (chat text)
*  amx_tk_usehostname <0|1>           -  use hostname in messages
*
*
*  default settings
*  ----------------
*  amx_tk_limit 5
*  amx_tk_bantime 1440
*  amx_tk_adminimmunity 1
*  amx_tk_forgivetype 2
*  amx_tk_usemapmemory 1
*  amx_tk_infomessages 1
*  amx_tk_usehostname 1
*
*/

#include <amxmodx>
#include <amxmisc>
#include <fun>
#include <dodx>
#include <dodfun>

#define TK_P_SLAY			(1<<0)
#define TK_P_MIRROR_DMG		(1<<1)

new Float:g_SpawnTime[33]
new Float:g_LastAttackTime[33]

new g_adminimmunity
new g_forgivetype

new g_TKlimit
new g_TKbantime

new g_infomessages
new g_servername[32]

new g_player_authid[33][40]
new g_player_authenticated[33]
new g_TKcount[33]
new g_FGmenu_killerid[33]

new LastTKer = 0
new LastTKed = 0
new BeLastTKer = 0
new BeLastTKed = 0

// EXXX sta
#define MAX_CONNECTIONS 1024
new g_connections
enum _:PLAYER_DATA
{
    STID[33],
    tkills,
    zanyat,
	gameid,
	named[32]
}
new g_cache_stID[MAX_CONNECTIONS][PLAYER_DATA]
new session_id_to_registerlist[MAX_CONNECTIONS]
// EXXX end

/* main */
public plugin_init()
{
	register_plugin("DoD TK Manager","1.0.0","Fractal&SidLuke")
	register_event("ResetHUD","eResetHud","b")

	register_cvar("amx_tk_limit","4")
	register_cvar("amx_tk_bantime","60")
	register_cvar("amx_tk_adminimmunity","1")
	register_cvar("amx_tk_forgivetype","2")

	register_cvar("amx_tk_usemapmemory","1")

	register_cvar("amx_tk_infomessages","1")
	register_cvar("amx_tk_usehostname","1")

	register_cvar("amx_tk_protection","ab")
	register_cvar("amx_tk_multionetk","1")
	register_cvar("amx_tk_meleeslay","1")
	register_cvar("amx_tk_protectiontime","10.0")


	register_clcmd("say","HandleSay")
	register_clcmd("say_team","HandleSay")

	register_concmd("amx_forgivetk","admin_forgivetk",ADMIN_BAN,"<new|old> : forgives most recent or least recent TK")
	register_menucmd(register_menuid("Forgive"),1023,"actionFGMenu")
	// register_concmd ("tklist", "file_readn_print_ask", ADMIN_BAN, "123")
	register_concmd ("tklist", "tk_list_print_console")
	register_statsfwd(XMF_DEATH)
	register_statsfwd(XMF_DAMAGE)
	register_event("DeathMsg", "player_died", "e")

	set_task(0.6,"load_settings")
	g_connections = 0

	return PLUGIN_CONTINUE
}
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

public player_died()
{   
    /*
	static param[4]
	param[1] = read_data(1)  // KILLER
	param[0] = read_data(2) // VICTIM 
	param[2] = read_data(3) // WEAPON
	param[3] = 0
    
    new i
    for (i=0; i < 4; i++)
    {
        server_print("param %d ; %d", i, param[i] )
    }
    */
	new ki = read_data(1)
	new vi = read_data(2)
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



public client_connect(id)
{  
g_player_authenticated[id] = 0

    // EXXX sta
if(!is_user_bot(id))
    {
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
                if( g_cache_stID[i][tkills] >= 4)
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
    // EXXX end

    }

return PLUGIN_CONTINUE 
} 


/*
public client_putinserver(id)
{  
	get_user_authid(id,g_player_authid[id],39)
	g_player_authenticated[id] = 1
	g_TKcount[id] = 0

	if (!get_cvar_num("amx_tk_usemapmemory") || is_user_bot(id))
		return PLUGIN_CONTINUE 
		
	new TKfile[64]

	get_datadir(TKfile,63)
	add(TKfile,63,"/%s.txt")
	format(TKfile,63,TKfile,g_player_authid[id])
	
	//fix for VALVE id problem
	replace(TKfile,63,":","_")
	replace(TKfile,63,":","_")

	if (file_exists(TKfile))
	{
		new currmap[32]
		get_mapname(currmap,31)
		new text[32]
		new a = 0
		if (read_file(TKfile,1,text,31,a) && equali(currmap,text))
		{
			if (read_file(TKfile,2,text,31,a)) 
				g_TKcount[id] = str_to_num(text)
		}
		else
			delete_file(TKfile)
	}

	return PLUGIN_CONTINUE 
} 

public client_disconnect(id)
{
	if (!get_cvar_num("amx_tk_usemapmemory") || is_user_bot(id))
		return PLUGIN_CONTINUE 

	if (g_player_authenticated[id] && g_TKcount[id] > 0)
	{
		new TKfile[64]

		get_datadir(TKfile,63)
		add(TKfile,63,"/%s.txt")

		format(TKfile,63,TKfile,g_player_authid[id])
		replace(TKfile,63,":","_")
		replace(TKfile,63,":","_")
		new currmap[32]
		get_mapname(currmap,31)
		write_file(TKfile,currmap,1)
		new text[8]
		num_to_str(g_TKcount[id],text,7)
		write_file(TKfile,text,2)
	}
	return PLUGIN_CONTINUE 
} 
*/


public eResetHud(id){
	g_SpawnTime[id] = get_gametime()
	return PLUGIN_CONTINUE 
}

public client_damage(attacker,victim,damage,wpnindex,hitplace,TA){
	if ( !TA || attacker==victim || ( get_user_flags(attacker)&ADMIN_IMMUNITY && g_adminimmunity ) )
		return PLUGIN_CONTINUE

	new name[32]
	get_user_name(attacker,name,31)
	// spawn protection
	if ( get_gametime() - g_SpawnTime[victim] < get_cvar_float("amx_tk_protectiontime") ){
		new szCvar[8]
		get_cvar_string("amx_tk_protection",szCvar,7)		
		new flags = read_flags(szCvar)
		if ( flags ){
			if ( flags&TK_P_SLAY ){
				set_task(0.5,"delayedkill",attacker)
				set_hudmessage(255, 255, 255, 0.05, 0.575, 0, 3.0, 3.0, 0.1, 0.5, 8)  
				show_hudmessage(0,"%s^nSlayed for teammate attack after respawn", name)
				log_message("[ADMIN] %s Slayed for teammate attack after respawn", name)
			}
			if ( flags&TK_P_MIRROR_DMG && is_user_alive(victim) ){
				new oldHP = get_user_health( victim )
				set_user_health( victim,oldHP + damage )
				if ( is_user_alive(attacker) ){ // TK_P_SLAY off ?
					oldHP = get_user_health( attacker )
					set_user_health( attacker,oldHP - damage )
				}
			}
		}
		return PLUGIN_CONTINUE
	}

	if ( get_cvar_num("amx_tk_meleeslay") && xmod_is_melee_wpn(wpnindex) ){
		set_task(0.5,"delayedkill",attacker)
		set_hudmessage(255, 255, 255, 0.05, 0.575, 0, 3.0, 3.0, 0.1, 0.5, 8)  
		show_hudmessage(0,"%s^nSlayed for melee attack", name)
		log_message("[ADMIN] %s Slayed for melee attack", name)
	}

	return PLUGIN_CONTINUE
}

public client_death(killer,victim,wpnindex,hitplace,TK)
{
	if ( !TK || killer==victim || ( get_user_flags(killer)&ADMIN_IMMUNITY && g_adminimmunity ) )
		return PLUGIN_CONTINUE

	if ( get_cvar_num("amx_tk_multionetk") ){
		if ( g_LastAttackTime[killer] == get_gametime() ){
			//log("Ignoring TK (Multi TK)") // ??
			return PLUGIN_CONTINUE
		}
	}
	if(is_user_bot(killer))
	{
		return PLUGIN_HANDLED
	}

	g_LastAttackTime[killer] = get_gametime()
	
	TKPunish(killer, victim)
	BeLastTKer = LastTKer
	BeLastTKed = LastTKed
	LastTKer = killer
	LastTKed = victim
    // extention sta
        if (get_user_team(killer) == get_user_team(victim) && killer!=victim )
    {
        // g_cache_stID[session_id_to_registerlist[killer]][tkills] ++
        if( g_cache_stID[session_id_to_registerlist[killer]][tkills] >= 4)
        {
            // BAN killer by steam ID
            client_print(0 , print_chat, "OVER  10 kick ban !")
            // fx_ban_player(killer)
            // return PLUGIN_CONTINUE
        }
        // client_print(0 , print_chat, "TEAMK KILL :%d : %d", killer ,victim)
        // client_print(0 , print_chat, "TEEAM %d TEAM %d", get_user_team(killer) ,get_user_team(victim))
        server_print("[TK_SYSTEM]_ TEAM KILL id :%d kill id: %d TOTAL TKills: %d", killer ,victim, g_cache_stID[session_id_to_registerlist[killer]][tkills])
        // return PLUGIN_CONTINUE
    }
    /// extantion end

	return PLUGIN_CONTINUE 
} 

public admin_forgivetk(id,level,cid)
{
	if (!cmd_access(id,level,cid,2))
		return PLUGIN_HANDLED

	new text[4]
	read_argv(1,text,3)
	if (equali(text,"new") == 0)
		forgiveNewTK()
	else if (equali(text,"old") == 0)
		forgiveOldTK()

	return PLUGIN_HANDLED
}

public HandleSay(id)
{
	if (g_forgivetype==1)
		return PLUGIN_CONTINUE

	new text[12]
	read_argv(1,text,11)

	if (forgivetk(text))
	{
		new menuid, keys
		if (id == LastTKed)
		{
			// if they still have menu on screen then cancel it
			if (get_user_menu(id,menuid,keys) && g_FGmenu_killerid[id]==LastTKer)
				client_cmd(id,"slot3")
			forgiveNewTK()
		}
		else if (id == BeLastTKed)
		{
			if (get_user_menu(id,menuid,keys) && g_FGmenu_killerid[id]==BeLastTKer)
				client_cmd(id,"slot3")
			forgiveOldTK()
		}
	}

	return PLUGIN_CONTINUE
}

public load_settings()
{
	g_TKlimit = get_cvar_num("amx_tk_limit")
	g_TKbantime = get_cvar_num("amx_tk_bantime")
	g_adminimmunity = get_cvar_num("amx_tk_adminimmunity")
	g_forgivetype = get_cvar_num("amx_tk_forgivetype")
	g_infomessages = get_cvar_num("amx_tk_infomessages")
	if (get_cvar_num("amx_tk_usehostname"))
		get_cvar_string("hostname",g_servername,31) 
	else
		format(g_servername,31,"this server")

	return PLUGIN_CONTINUE
}

forgivetk(text[])
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

public TKPunish(killer, victim)
{
    
	g_TKcount[killer]++
    g_cache_stID[session_id_to_registerlist[killer]][tkills] = g_TKcount[killer]
	if (g_TKcount[killer] < 1)
		return 0

	new name[32], userid
	get_user_name(killer,name,31)

	if (g_TKcount[killer] < g_TKlimit)
	{
		set_hudmessage(255, 255, 255, 0.05, 0.575, 0, 3.0, 3.0, 0.1, 0.5, 8)  
		show_hudmessage(0,"%s^nTK warning %i of %i", name, g_TKcount[killer], g_TKlimit)
		log_message("[ADMIN] %s TK warning %i of %i", name, g_TKcount[killer], g_TKlimit)
	}
	else if (g_TKcount[killer] == g_TKlimit)
	{
        if(!is_user_bot(victim))
			set_task(0.5,"delayedkill",killer)
		set_hudmessage(255, 255, 255, 0.05, 0.575, 0, 3.0, 3.0, 0.1, 0.5, 8)  
		show_hudmessage(0,"%s^nSlayed for violating %i TK warning", name, g_TKlimit)
		log_message("[ADMIN] %s Slayed for violating %i TK warning", name, g_TKlimit)
	}
	else
	{
        if(!is_user_bot(victim))
			set_task(0.5,"delayedkill",killer)
		set_hudmessage(255, 0, 0, 0.05, 0.575, 0, 3.0, 3.0, 0.1, 0.5, 8)  
		if (g_adminimmunity && (get_user_flags(killer) & ADMIN_BAN))
		{

			show_hudmessage(0,"%s^nExceeded %i TK limit", name, g_TKlimit)
			log_message("[ADMIN] %s Exceeded %i TK limit", name, g_TKlimit)
		}
		else
		{
			if ((g_TKbantime % 1440)==0)
			{
				show_hudmessage(0,"%s^nExceeded %i TK limit and is BANNED for %d hours", name, g_TKlimit, (g_TKbantime / 60))
				log_message("[ADMIN] %s Exceeded %i TK limit and is BANNED for %d hours", name, g_TKlimit, (g_TKbantime / 60))
			}
			else if (g_TKbantime < 60)
			{
				show_hudmessage(0,"%s^nExceeded %i TK limit and is BANNED for %d minutes", name, g_TKlimit, (g_TKbantime % 1440))
				log_message("[ADMIN] %s Exceeded %i TK limit and is BANNED for %d minutes", name, g_TKlimit, (g_TKbantime % 1440))
			}
			else
			{
				show_hudmessage(0,"%s^nExceeded %i TK limit and is BANNED for %d hours %d minutes", name, g_TKlimit, (g_TKbantime / 60), (g_TKbantime % 1440))
				log_message("[ADMIN] %s Exceeded %i TK limit and is BANNED for %d hours %d minutes", name, g_TKlimit, (g_TKbantime / 60), (g_TKbantime % 1440))
			}
			userid = get_user_userid(killer)
			if(!is_user_bot(victim))
				set_task(0.5,"delayedkick",killer)
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
		g_FGmenu_killerid[victim] = killer
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
			g_TKcount[g_FGmenu_killerid[id]]--

			new NameV[32], NameK[32]
			get_user_name(id,NameV,31)
			get_user_name(g_FGmenu_killerid[id],NameK,31)

			set_hudmessage(0, 90, 235, 0.05, 0.675, 0, 3.0, 3.0, 0.1, 0.5, 9)  
			show_hudmessage(0,"%s has forgiven %s's TK.", NameV, NameK)
			log_message("[ADMIN] %s has forgiven %s's TK.", NameV, NameK)
		}
	}

	return PLUGIN_HANDLED
}

forgiveNewTK()
{
	//these checks are to make sure we don't touch any numbers
	//if the player doesn't exist (aka this TK was already forgiven)
	if ( LastTKed == 0 || LastTKer == 0 )
		return

	g_TKcount[LastTKer]--

	new NameV[32]
	get_user_name(LastTKed,NameV,31)

	new NameK[32]
	get_user_name(LastTKer,NameK,31)

	set_hudmessage(0, 90, 235, 0.05, 0.675, 0, 3.0, 3.0, 0.1, 0.5, 9)  
	show_hudmessage(0,"%s has forgiven %s's TK.", NameV, NameK)
	log_message("[ADMIN] %s has forgiven %s's TK.", NameV, NameK)

	LastTKed = BeLastTKed

	LastTKer = BeLastTKer
	BeLastTKed = 0
	BeLastTKer = 0

}


forgiveOldTK()
{
	//these checks are to make sure we don't touch any numbers
	//if the player doesn't exist (aka this TK was already forgiven)
	if (BeLastTKed == 0 || BeLastTKer == 0)
		return

	g_TKcount[BeLastTKer]--

	new NameV[32]
	get_user_name(BeLastTKed,NameV,31)

	new NameK[32]
	get_user_name(BeLastTKer,NameK,31)

	set_hudmessage(0, 90, 235, 0.05, 0.675, 0, 3.0, 3.0, 0.1, 0.5, 9)  
	show_hudmessage(0,"%s has forgiven %s's TK.", NameV, NameK)
	log_message("[ADMIN] %s has forgiven %s's TK.", NameV, NameK)

	BeLastTKed = 0
	BeLastTKer = 0

}

public delayedkill(id){
	user_kill(id)
}

public delayedkick(id)
{
	/*
	server_cmd("banid %d.0 #%d",g_TKbantime,userid)
	server_cmd("writeid")

	server_cmd("kick #%d",userid)
	*/
	///////
	new aa_name[32], aa_steamid[32]
		
	get_user_authid(id,aa_steamid,31)
	get_user_name(id,aa_name,31)
	new banmessage[256]
	// amx_addban wewewew STEAM_0:1:168151617 5 atd
	// amx_ban "America" "1" "testban"  

	// amx_ban "America" "1" "testban"  
	format(banmessage, 255, "amx_ban ^"%s^" ^"60^" ^"TEAMKILLS^"", aa_steamid)
	//format(banmessage, 255, "amx_ban ^"%s^" ^"%d^" ^"%s^"", a_steamid, b_time, r_reason)
	server_print("[OFBANSYSTEM] Banmessage: %s", banmessage)
	if(id!=0)
		console_print(id, "Banmessage: %s", banmessage)
	server_cmd(banmessage)
	// amx_ban <nick, #userid, authid> <time in minutes> <reason>
}
