#include <amxmodx>
#include <amxmisc>
#include <dodx>
#include <dodfun>
#include <fun>

#define SPECS 3
#define RANDOM 5
#define DRAW 3
#define NONE 0
#define MINPLAYERS 2

new roundstart = 0
new playerteam[33], playerclass[33], hasclass[33]
new def_flagowner[10]
new flagownerscaught = 0
new gmsgText, gmsgPTeam, gmsgVGUIMenu
new axisrrsound[2][] = {"player/gerstartround.wav","player/gerstartround2.wav"}
new britrrsound[2][] = {"player/britstartround.wav","player/britstartround2.wav"}
new usrrsound[2][] = {"player/usstartround.wav","player/usstartround2.wav"}
new axisrrmsg[2][] = {"Disembark and prepare for the attack!","Go! Go! Prepare for the assault!"}
new alliesrrmsg[2][] = {"Platoon, move out and stay low!","Squad, charge your weapons we're moving up!"}

public plugin_init()
{
	register_plugin("DoD RoundBased","0.4alpha","AMXX DoD Team")
	register_clcmd("jointeam","handle_teamjoin")
	register_event("DeathMsg", "player_died", "a")
	register_event("ResetHUD","player_newround","be")
	register_event("SetObj","flagreset","a","2=0")
	register_event("RoundState","fullcap_roundend","a","1=3","1=4","1=5")
	gmsgVGUIMenu = get_user_msgid("VGUIMenu")
	register_message(gmsgVGUIMenu,"block_menu")
	gmsgPTeam = get_user_msgid("PTeam")
	gmsgText = get_user_msgid("TextMsg")
}

public plugin_precache()
{
	precache_sound(axisrrsound[0])
	precache_sound(axisrrsound[1])
	precache_sound(britrrsound[0])
	precache_sound(britrrsound[1])
	precache_sound(usrrsound[0])
	precache_sound(usrrsound[1])
	return PLUGIN_CONTINUE
}

public client_putinserver(id)
{
	playerteam[id] = SPECS
	playerclass[id] = 0
	hasclass[id] = 0
	return PLUGIN_CONTINUE
}

public client_disconnect(id)
{
	set_task(0.1,"recount_players")
	return PLUGIN_CONTINUE
}

public recount_players()
{
	new players_in = 0
	new client[32], players
	get_players(client,players,"h")	
	for(new i=0; i<players; i++)
	{
		new id = client[i]
		if(is_user_connected(id) == 1 && playerteam[id] != SPECS)
		{
			players_in++
		}
	}
	if(players_in < MINPLAYERS)
	{
		set_hudmessage(0, 0, 255, -1.0, 0.1, 0, 6.0, 10.0, 0.1, 0.2, -1)
		if(roundstart == 0)
		{
			show_hudmessage(0,"Not enough players to start the Round!")
		}
		else if(roundstart == 1)
		{
			show_hudmessage(0,"Not enough players to continue the Round!")
			roundstart = 0
		}
		teamerase_newround()
		set_task(3.0,"respawn_all")
	}
	return PLUGIN_HANDLED
}


public block_menu(msg_id, msg_Dest, msg_Ent)
{
	if(hasclass[msg_Ent] == 0)
	{
		return PLUGIN_CONTINUE
	}
	new VGUI = get_msg_arg_int(1)
	if(VGUI == 10 || VGUI == 12 || VGUI == 13)
	{
		dod_set_user_class(msg_Ent,playerclass[msg_Ent])
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public client_command(id)
{
	new command[32]
	read_argv(0,command,31)
	if(equal(command,"changeclass") == 1)
	{
		hasclass[id] = 0
	}
	return PLUGIN_CONTINUE
}

public player_died()
{
	new player = read_data(2)
	playerclass[player] = dod_get_next_class(player)
	if(playerclass[player] != 0)
	{
		hasclass[player] = 1
	}
	if(roundstart == 1)
	{
		set_task(1.0,"check_roundstate",player)
	}
	return PLUGIN_CONTINUE
}

public fullcap_roundend()
{
	set_task(3.0,"respawn_all")
	return PLUGIN_CONTINUE
}

public check_winnerteam()
{
	new axis_alive = 0
	new allies_alive = 0
	new client[32], players
	get_players(client,players,"h")	
	for(new i=0; i<players; i++)
	{
		new id = client[i]
		new team = get_user_team(id)
		if(is_user_connected(id) == 1 && is_user_alive(id) == 1)
		{
			if(team == ALLIES)
			{
				allies_alive++
			}
			else if(team == AXIS)
			{
				axis_alive++
			}
		}
	}
	if(allies_alive == 0 && axis_alive != 0)
	{
		return AXIS
	}
	if(allies_alive != 0 && axis_alive == 0)
	{
		return ALLIES
	}
	else if(allies_alive == 0 && axis_alive == 0)
	{
		return DRAW
	}
	return NONE
}	

public check_roundstate(player)
{
	playerteam[player] = get_user_team(player)	
	dod_set_user_team(player, 3, 0)
	if(check_winnerteam() == AXIS)
	{
		set_hudmessage(255, 0, 0, -1.0, 0.1, 0, 6.0, 10.0, 0.1, 0.2, -1)
		show_hudmessage(0,"The Allied team has been erased!")
		client_cmd(0,"spk ambience/germanwin")
	}
	if(check_winnerteam() == ALLIES)
	{
		set_hudmessage(0, 255, 0, -1.0, 0.1, 0, 6.0, 10.0, 0.1, 0.2, -1)
		show_hudmessage(0,"The Axis team has been erased!")
		if(dod_get_map_info(MI_ALLIES_TEAM) == 0)
		{
			client_cmd(0,"spk ambience/uswin")
		}
		else if(dod_get_map_info(MI_ALLIES_TEAM) == 1)
		{
			client_cmd(0,"spk ambience/britwin")
		}
	}
	if(check_winnerteam() == DRAW)
	{
		set_hudmessage(0, 0, 255, -1.0, 0.1, 0, 6.0, 10.0, 0.1, 0.2, -1)
		show_hudmessage(0,"Both teams have been erased! Round draw!")
	}
	if(check_winnerteam() == NONE)
	{
		return PLUGIN_CONTINUE
	}
	teamerase_newround()
	set_task(3.0,"respawn_all")
	return PLUGIN_HANDLED
}

public respawn_all()
{
	new client[32], players
	get_players(client,players,"h")	
	for(new i=0; i<players; i++)
	{
		new id = client[i]
		if(is_user_connected(id) == 1)
		{
			if(is_user_alive(id) == 1)
			{
				playerteam[id] = get_user_team(id)	
				dod_set_user_team(id, 3, 0)
			}
			set_msg_block(gmsgText, BLOCK_SET)
			if(playerteam[id] == ALLIES)
			{
				engclient_cmd(id,"jointeam","1")
			}
			else if(playerteam[id] == AXIS)
			{
				engclient_cmd(id,"jointeam","2")
			}
			set_msg_block(gmsgText, BLOCK_NOT)
			if(hasclass[id] == 1)
			{
				dod_set_user_class(id,playerclass[id])
			}
		}
	}
	return PLUGIN_HANDLED
}

public teamerase_newround()
{
	new maxobj = objectives_get_num()
	for(new i=0; i<maxobj; i++)
	{
		objective_set_data(i,CP_owner,def_flagowner[i])
	}
	objectives_reinit(0)
	return PLUGIN_HANDLED
}

public flagreset()
{
	if(flagownerscaught == 0)
	{
		set_task(1.0,"get_flagowners")
		flagownerscaught = 1
	}
	return PLUGIN_CONTINUE
}

public get_flagowners()
{
	new maxobj = objectives_get_num()
	for(new i=0; i<maxobj; i++)
	{
		def_flagowner[i] = objective_get_data(i,CP_owner)
	}
	return PLUGIN_HANDLED
}

public handle_teamjoin(id)
{
	new team_s[2]
	read_argv(1,team_s,2)
	new team = str_to_num(team_s)		
	if(team == ALLIES)
	{
		if(playerteam[id] == ALLIES)
		{
			hasclass[id] = 1
		}
		else if(playerteam[id] != ALLIES)
		{
			hasclass[id] = 0
		}
		playerteam[id] = ALLIES
	}
	else if(team == AXIS)
	{
		if(playerteam[id] == AXIS)
		{
			hasclass[id] = 1
		}
		else if(playerteam[id] != AXIS)
		{
			hasclass[id] = 0
		}
		playerteam[id] = AXIS
	}
	else if(team == SPECS)
	{
		hasclass[id] = 0
		playerteam[id] = SPECS
	}
	else if(team == RANDOM)
	{
		new randomteam = random_num(ALLIES,AXIS)
		playerteam[id] = randomteam
		hasclass[id] = 0
	}
	set_msg_block(gmsgText, BLOCK_SET)
	engclient_cmd(id,"jointeam","3")
	set_msg_block(gmsgText, BLOCK_NOT)
	message_begin(MSG_BROADCAST,gmsgPTeam,{0,0,0},0)
	write_byte(id)
	write_byte(playerteam[id])
	message_end()
	check_roundstart()
	return PLUGIN_HANDLED
}

public check_roundstart()
{
	if(roundstart == 1)
	{
		return PLUGIN_CONTINUE
	}
	else if(roundstart == 0)
	{
		new players_in = 0
		new client[32], players
		get_players(client,players,"h")	
		for(new i=0; i<players; i++)
		{
			new id = client[i]
			if(is_user_connected(id) == 1 && playerteam[id] != SPECS)
			{
				players_in++
			}
		}
		if(players_in >= MINPLAYERS)
		{
			set_hudmessage(0, 0, 255, -1.0, 0.1, 0, 6.0, 10.0, 0.1, 0.2, -1)
			show_hudmessage(0,"Get ready for Roundstart!")
			roundstart = 1
			teamerase_newround()
			set_task(3.0,"respawn_all")
		}
		else if(players_in < MINPLAYERS)
		{
			set_task(0.1,"respawn_all")
		}
	}
	return PLUGIN_HANDLED
}

public player_newround(id)
{
	if(dod_get_user_class(id) != 0)
	{
		hasclass[id] = 1
		playerclass[id] = dod_get_user_class(id)
	}
	if(roundstart == 1)
	{
		set_user_maxspeed(id,0.0)
		set_task(3.5,"announce_round",id)
		return PLUGIN_CONTINUE
	}
	return PLUGIN_CONTINUE
}

public announce_round(id)
{
	set_user_maxspeed(id,500.0)
	new rsr = random_num(0,1)
	if(get_user_team(id) == ALLIES)
	{
		client_print(id,print_chat,"%s",alliesrrmsg[rsr])
		if(dod_get_map_info(MI_ALLIES_TEAM) == 0)
		{
			client_cmd(id,"spk %s",usrrsound[rsr])
		}
		else if(dod_get_map_info(MI_ALLIES_TEAM) == 1)
		{
			client_cmd(id,"spk %s",britrrsound[rsr])
		}
		return PLUGIN_HANDLED
	}
	else if(get_user_team(id) == AXIS)
	{
		client_print(id,print_chat,"%s",axisrrmsg[rsr])
		client_cmd(id,"spk %s",axisrrsound[rsr])
		return PLUGIN_HANDLED
	}	
	return PLUGIN_HANDLED
}
