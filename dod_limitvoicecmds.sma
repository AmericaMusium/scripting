//
// AMX Mod X Script
//
// Developed by The AMX Mod X DoD Community
// http://www.dodplugins.net
//
// Author: FeuerSturm
//
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
//
//
// 
// USAGE (cvars for amxx.cfg):
// ===========================
//
// dod_limitvoicecmds_enabled <1/0>       =  enable/disable limiting
//                                           the amount of VoiceCommands
//                                           players can use
// 
// dod_limitvoicecmds_maxvoicecmds <#>    =  amount of allowed VoiceCommands
//                                           for each player
//                                           (set to 0 to disable all VCs)
//
// dod_limitvoicecmds_resetcount <1/2/0>    =  reset player's VoiceCommand count
//                                             1 = reset after each round
//                                             2 = reset on each respawn
//                                             0 = only reset on mapchange
//
// dod_limitvoicecmds_obeyimmunity <1/0>    =  enable/disable Immunity for
//                                             admins
//
//
//
// DESCRIPTION:
// ============
//
// - This plugin let's you limit the amount of VoiceCommands
//   each player can use. You can stop people from spamming
//   "Go! Go! Go!", "Need backup!", "Need Ammo!" and all the
//   other VoiceCommands.
// - Amount of allowed VCs per round/respawn is definable
// - Admins with flag "a" (ADMIN_IMMUNITY) can be excluded
//   from the limitations
//
//
//
// AMX Mod X & DoDx module needed!
//
//
// CHANGELOG:
// ==========
//
// - 22.08.2005 Version 0.5beta
//   Initial Release
//
// - 02.07.2007 Version 0.6
//   - using pcvar system now
//   - changed cvar names, please review them!
//   - added round state "Draw" to VoiceCmd reset
//   - added global tracking cvar
//  

#include <amxmodx>
#include <dodx>

#define Keysvoice (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<6)|(1<<7)|(1<<8)|(1<<9)

new g_dod_limitvoicecmds_enabled, g_dod_limitvoicecmds_maxvoicecmds, g_dod_limitvoicecmds_resetcount, g_dod_limitvoicecmds_obeyimmunity
new voicecommands[33]

public plugin_init()
{
	register_plugin("DoD Limit VoiceCmds","0.6","AMXX DoD Team")
	register_cvar("dod_limitvoicecmds_plugin", "Version 0.6 by FeuerSturm | www.dodplugins.net", FCVAR_SERVER|FCVAR_SPONLY)
	register_clcmd("voice_menu1","cmd_voicemenu1")
	register_clcmd("voice_menu2","cmd_voicemenu2")
	register_clcmd("voice_menu3","cmd_voicemenu3")
	g_dod_limitvoicecmds_enabled = register_cvar("dod_limitvoicecmds_enabled","1")
	g_dod_limitvoicecmds_maxvoicecmds = register_cvar("dod_limitvoicecmds_maxvoicecmds","10")
	g_dod_limitvoicecmds_resetcount = register_cvar("dod_limitvoicecmds_resetcount","1")
	g_dod_limitvoicecmds_obeyimmunity = register_cvar("dod_limitvoicecmds_obeyimmunity","1")
	register_menucmd(register_menuid("voice1"),Keysvoice,"Pressedvoice1")
	register_menucmd(register_menuid("voice2"),Keysvoice,"Pressedvoice2")
	register_menucmd(register_menuid("voice3"),Keysvoice,"Pressedvoice3")
	register_event("ResetHUD","avcs_eventrespawn","be")
	register_event("RoundState","avcs_eventroundend","a","1=3","1=4","1=5")
}

public client_authorized(id)
{
	voicecommands[id] = 0
}

public client_command(id)
{
	if(is_user_connected(id) == 0 || is_user_alive(id) == 0 || get_pcvar_num(g_dod_limitvoicecmds_enabled) == 0 || ((get_user_flags(id)&ADMIN_IMMUNITY) && get_cvar_num("dod_limitvoicecmds_obeyimmunity") == 1))
	{ 
		return PLUGIN_CONTINUE
	}
	new voicecmd[32]
	read_argv(0,voicecmd,31)
	if(contain(voicecmd,"voice_") != -1 && contain(voicecmd,"voice_menu") == -1)
	{
		new maxvcs = get_pcvar_num(g_dod_limitvoicecmds_maxvoicecmds)
		if(maxvcs == 0)
		{
			client_print(id,print_chat,"[DoD Limit VoiceCmds] VoiceCommands are disabled!")
			return PLUGIN_HANDLED
		}
		if(voicecommands[id] >= maxvcs)
		{
			client_print(id,print_chat,"[DoD Limit VoiceCmds] Please DON'T spam VoiceCommands!")
			return PLUGIN_HANDLED
		}
		else
		{
			voicecommands[id]++
			return PLUGIN_CONTINUE
		}
	}
	return PLUGIN_CONTINUE 
}

public avcs_eventroundend(){
	if(get_pcvar_num(g_dod_limitvoicecmds_enabled) == 0 || get_pcvar_num(g_dod_limitvoicecmds_resetcount) != 1)
	{
		return PLUGIN_CONTINUE
	}
	new plist[32],pnum
	get_players(plist,pnum)
	for(new i=0; i<pnum; i++){
		new player = plist[i]
		if(is_user_connected(player) == 1 && voicecommands[player] > 0)
		{
			voicecommands[player] = 0
		}
	}
	return PLUGIN_CONTINUE
}

public avcs_eventrespawn(id){
	if(get_pcvar_num(g_dod_limitvoicecmds_enabled) == 0 || get_pcvar_num(g_dod_limitvoicecmds_resetcount) != 2)
	{
		return PLUGIN_CONTINUE
	}
	if(is_user_connected(id) == 1 && voicecommands[id] > 0)
	{
		voicecommands[id] = 0
	}
	return PLUGIN_CONTINUE
}

public cmd_voicemenu1(id){
	if(is_user_connected(id) == 0 || is_user_alive(id) == 0)
	{
		return PLUGIN_HANDLED
	}
	show_menu(id,Keysvoice,"1. Squad move out!^n2. Hold this position!^n3. Fall back!^n4. Squad flank left!^n5. Squad flank right!^n6. Squad, stick together!^n7. Squad, covering fire!^n8. Use your grenades!^n9. Cease fire!^n0. Cancel", -1,"voice1")
	return PLUGIN_HANDLED
}

public Pressedvoice1(id,key)
{
	if(is_user_alive(id) == 0)
	{
		return PLUGIN_HANDLED
	}
	switch (key)
	{
		case 0:
		{
			client_cmd(id,"voice_attack")
			return PLUGIN_HANDLED
			
		}
		case 1:
		{
			client_cmd(id,"voice_hold")
			return PLUGIN_HANDLED
		}
		case 2:
		{
			client_cmd(id,"voice_fallback")
			return PLUGIN_HANDLED
		}
		case 3:
		{
			client_cmd(id,"voice_left")
			return PLUGIN_HANDLED
		}
		case 4:
		{
			client_cmd(id,"voice_right")
			return PLUGIN_HANDLED
		}
		case 5:
		{
			client_cmd(id,"voice_sticktogether")
			return PLUGIN_HANDLED
		}
		case 6:
		{
			client_cmd(id,"voice_cover")
			return PLUGIN_HANDLED
		}
		case 7:
		{
			client_cmd(id,"voice_usegrens")
			return PLUGIN_HANDLED
		}
		case 8:
		{
			client_cmd(id,"voice_ceasefire")
			return PLUGIN_HANDLED
		}
		case 9:
		{
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_HANDLED
}

public cmd_voicemenu2(id)
{
	if(is_user_connected(id) == 0 || is_user_alive(id) == 0)
	{
		return PLUGIN_HANDLED
	}
	show_menu(id,Keysvoice,"1. Yes sir!^n2. Negative!^n3. I need backup!^n4. Fire in the hole!^n5. Grenade!^n6. Sniper!^n7. Taking fire - left flank!^n8. Taking fire - right flank!^n9. Area clear!^n0. Cancel", -1, "voice2") // Display menu
	return PLUGIN_HANDLED
}

public Pressedvoice2(id,key)
{
	if(is_user_alive(id) == 0)
	{
		return PLUGIN_HANDLED
	}
	switch (key)
	{
		case 0:
		{
			client_cmd(id,"voice_yessir")
			return PLUGIN_HANDLED
		}
		case 1:
		{
			client_cmd(id,"voice_negative")
			return PLUGIN_HANDLED
		}
		case 2:
		{
			client_cmd(id,"voice_backup")
			return PLUGIN_HANDLED
		}
		case 3:
		{
			client_cmd(id,"voice_fireinhole")
			return PLUGIN_HANDLED
		}
		case 4:
		{
			client_cmd(id,"voice_grenade")
			return PLUGIN_HANDLED
		}
		case 5:
		{
			client_cmd(id,"voice_sniper")
			return PLUGIN_HANDLED
		}
		case 6:
		{
			client_cmd(id,"voice_fireleft")
			return PLUGIN_HANDLED
		}
		case 7:
		{
			client_cmd(id,"voice_fireright")
			return PLUGIN_HANDLED
		}
		case 8:
		{
			client_cmd(id,"voice_areaclear")
			return PLUGIN_HANDLED
		}
		case 9:
		{
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_HANDLED
}

public cmd_voicemenu3(id)
{
	if(is_user_connected(id) == 0 || is_user_alive(id) == 0)
	{
		return PLUGIN_HANDLED
	}
	new mgahead[128], movemg[128], usepanz[128], bazahead[128]
	if(get_user_team(id) == AXIS)
	{
		mgahead = "Machinegun position ahead!"
		movemg = "Move up the mg!"
		usepanz = "Use the panzerschreck!"
		bazahead = "Bazooka! / Piat!"
	}
	else if(get_user_team(id) == ALLIES)
	{
		if(dod_get_map_info(MI_ALLIES_TEAM) == 0)
		{
		 	mgahead = "Mg42 position ahead!"
			movemg = "Move up the .30 cal!"
			usepanz = "Use the bazooka!"
			bazahead = "Panzerschreck!"
		}
		else if(dod_get_map_info(MI_ALLIES_TEAM) == 1)
		{
			mgahead = "Mg position ahead!"
			movemg = "Bring up that Bren!"
			usepanz = "Use the piat!"
			bazahead = "Panzerschreck!"
		}
	}
	new layout3[1024]
	format(layout3,1023,"1. Go go go!^n2. Displace!^n3. Enemy ahead!^n4. Enemy behind us!^n5. %s^n6. %s^n7. I need Ammo!^n8. %s^n9. %s^n0. Cancel",mgahead,movemg,usepanz,bazahead)
	show_menu(id,Keysvoice,layout3, -1, "voice3")
	return PLUGIN_HANDLED
}

public Pressedvoice3(id,key)
{
	if(is_user_alive(id) == 0)
	{
		return PLUGIN_HANDLED
	}
	switch (key)
	{
		case 0:
		{
			client_cmd(id,"voice_gogogo")
			return PLUGIN_HANDLED
		}
		case 1:
		{
			client_cmd(id,"voice_displace")
			return PLUGIN_HANDLED
		}
		case 2:
		{
			client_cmd(id,"voice_enemyahead")
			return PLUGIN_HANDLED
		}
		case 3:
		{
			client_cmd(id,"voice_enemybehind")
			return PLUGIN_HANDLED
		}
		case 4:
		{
			client_cmd(id,"voice_mgahead")
			return PLUGIN_HANDLED
		}
		case 5:
		{
			client_cmd(id,"voice_moveupmg")
			return PLUGIN_HANDLED
		}
		case 6:
		{
			client_cmd(id,"voice_needammo")
			return PLUGIN_HANDLED
		}
		case 7:
		{
			client_cmd(id,"voice_usebazooka")
			return PLUGIN_HANDLED
		}
		case 8:
		{
			client_cmd(id,"voice_bazookaspotted")
			return PLUGIN_HANDLED
		}
		case 9:
		{
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_HANDLED
}
