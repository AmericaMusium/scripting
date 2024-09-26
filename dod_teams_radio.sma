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

#include <amxmodx>
#include <dodx>
#include <fakemeta>

#define Keysvoice (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<6)|(1<<7)|(1<<8)|(1<<9)
#define pev_army pev_groupinfo
new myarmy

// new const BRITISH = 0
// new const ALLIES = 1
// new const AXIS = 2
new const USSR = 4

new const RADIO_USSR[][] = 
{
"player/ussr/ussryessir.wav",
"player/ussr/ussrussregrenades.wav",
"player/ussr/ussrussrebazooka.wav",
"player/ussr/ussrtigerahead.wav",
"player/ussr/ussrtakingfireright.wav",
"player/ussr/ussrtakingfireleft.wav",
"player/ussr/ussrtakecover.wav",
"player/ussr/ussrsticktogether.wav",
"player/ussr/ussrstartround2.wav",
"player/ussr/ussrstartround.wav",
"player/ussr/ussrsrmoveout.wav",
"player/ussr/ussrspreadout.wav",
"player/ussr/ussrsniper.wav",
"player/ussr/ussrright.wav",
"player/ussr/ussrprepare.wav",
"player/ussr/ussrpanzerschreck.wav",
"player/ussr/ussrnegative.wav",
"player/ussr/ussrneedammo.wav",
"player/ussr/ussrmoveupmg.wav",
"player/ussr/ussrmoveout.wav",
"player/ussr/ussrmgahead.wav",
"player/ussr/ussrmedic.wav",
"player/ussr/ussrleft.wav",
"player/ussr/ussrhold.wav", // [23]
"player/ussr/ussrgrenade.wav",
"player/ussr/ussrgogogo.wav",
"player/ussr/ussrflankright.wav",
"player/ussr/ussrflankleft.wav",
"player/ussr/ussrflank.wav",
"player/ussr/ussrfireinthehole.wav",
"player/ussr/ussrfireinhole.wav",
"player/ussr/ussrfallback.wav",
"player/ussr/ussrenemybehind.wav",
"player/ussr/ussrenemyahead.wav",
"player/ussr/ussrdropguns.wav",
"player/ussr/ussrdisplace.wav",
"player/ussr/ussrcoverflanks.wav",
"player/ussr/ussrcover.wav",
"player/ussr/ussrceasefire.wav",
"player/ussr/ussrbehindussr.wav",
"player/ussr/ussrbackup.wav",
"player/ussr/ussrattack.wav",
"player/ussr/ussrareaclear.wav",
"player/ussr/ussr_smoke.wav"
}




// new g_dod_limitvoicecmds_enabled, g_dod_limitvoicecmds_maxvoicecmds, g_dod_limitvoicecmds_resetcount, g_dod_limitvoicecmds_obeyimmunity
new voicecommands[33]

public plugin_init()
{
	register_plugin("DOD_RADIO","0.0","[America]")
	register_cvar("DOD_RADIO", "[America]", FCVAR_SERVER|FCVAR_SPONLY)

	register_clcmd("voice_menu1","cmd_voicemenu1")
	register_clcmd("voice_menu2","cmd_voicemenu2")
	register_clcmd("voice_menu3","cmd_voicemenu3")
    // Custom created menus !
    register_menucmd(register_menuid("voice1ussr"),Keysvoice,"Pressedvoice1ussr")
	register_menucmd(register_menuid("voice2ussr"),Keysvoice,"Pressedvoice2ussr")
	register_menucmd(register_menuid("voice3ussr"),Keysvoice,"Pressedvoice3ussr")
	/*

	g_dod_limitvoicecmds_enabled = register_cvar("dod_limitvoicecmds_enabled","1")
	g_dod_limitvoicecmds_maxvoicecmds = register_cvar("dod_limitvoicecmds_maxvoicecmds","10")
	g_dod_limitvoicecmds_resetcount = register_cvar("dod_limitvoicecmds_resetcount","1")
	g_dod_limitvoicecmds_obeyimmunity = register_cvar("dod_limitvoicecmds_obeyimmunity","1")


	register_event("ResetHUD","avcs_eventrespawn","be")
	register_event("RoundState","avcs_eventroundend","a","1=3","1=4","1=5")
	*/
}

public plugin_precache() 
{
	//precache_sound("player/ussr/ussrmoveout.wav")  
	
	static i;
	for(i = 0; i < sizeof RADIO_USSR;i++) engfunc(EngFunc_PrecacheSound, RADIO_USSR[i]);
	
}
/*
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
*/
public cmd_voicemenu1(id)
{
   
	if(is_user_connected(id) == 0 || is_user_alive(id) == 0)
	{
		return PLUGIN_HANDLED
	}
    myarmy = pev(id, pev_army)
    if (myarmy == USSR)
    {
        show_menu(id,Keysvoice,"1. Squad move out!^n2. Hold this position!^n3. Fall back!^n4. Squad flank left!^n5. Squad flank right!^n6. Squad, stick together!^n7. Squad, covering fire!^n8. Use your grenades!^n9. Cease fire!^n0. Cancel", -1,"voice1ussr")
	    return PLUGIN_HANDLED; // полностью блокирует игровое событие, дальше ничего нет. (кроме предстоящих команд)
    }
	else return PLUGIN_CONTINUE; // ничего не тормозит, всё играет дальше
}

public Pressedvoice1ussr(id,key)
{
	if(is_user_alive(id) == 0)
	{
		return PLUGIN_HANDLED
	}
	switch (key)
	{
		case 0:
		{
			// client_cmd(id,"voice_attack")
            /*
            squad_moveout
            emit_sound(id,CHAN_AUTO,"player/ussr/ussrmoveout.wav" ,0.6, ATTN_NORM,0,PITCH_NORM)
            hand_signal
            chat_message
            */
         
			emit_sound(id,CHAN_AUTO, RADIO_USSR[19] ,0.6, ATTN_NORM,0,PITCH_NORM)
			return PLUGIN_HANDLED
			
		}
		case 1:
		{	
			// client_cmd(id,"voice_hold")
			emit_sound(id,CHAN_AUTO, RADIO_USSR[23] ,0.6, ATTN_NORM,0,PITCH_NORM)
			return PLUGIN_HANDLED
		}
		case 2:
		{
			//client_cmd(id,"voice_fallback")
			emit_sound(id,CHAN_AUTO, RADIO_USSR[31] ,0.6, ATTN_NORM,0,PITCH_NORM)
			return PLUGIN_HANDLED
		}
		case 3:
		{
			// client_cmd(id,"voice_left")
			emit_sound(id,CHAN_AUTO, RADIO_USSR[27] ,0.6, ATTN_NORM,0,PITCH_NORM)
			return PLUGIN_HANDLED
		}
		case 4:
		{
			//client_cmd(id,"voice_right")
			emit_sound(id,CHAN_AUTO, RADIO_USSR[26] ,0.6, ATTN_NORM,0,PITCH_NORM)
			return PLUGIN_HANDLED
		}
		case 5:
		{
			// client_cmd(id,"voice_sticktogether")
			emit_sound(id,CHAN_AUTO, RADIO_USSR[7] ,0.6, ATTN_NORM,0,PITCH_NORM)
			return PLUGIN_HANDLED
		}
		case 6:
		{
			//client_cmd(id,"voice_cover")
			emit_sound(id,CHAN_AUTO, RADIO_USSR[37] ,0.6, ATTN_NORM,0,PITCH_NORM)
			return PLUGIN_HANDLED
		}
		case 7:
		{
			//client_cmd(id,"voice_usegrens")
			emit_sound(id,CHAN_AUTO, RADIO_USSR[1] ,0.6, ATTN_NORM,0,PITCH_NORM)
			return PLUGIN_HANDLED
		}
		case 8:
		{
			//client_cmd(id,"voice_ceasefire")
			emit_sound(id,CHAN_AUTO, RADIO_USSR[38] ,0.6, ATTN_NORM,0,PITCH_NORM)
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
	myarmy = pev(id, pev_army)
	if (myarmy == USSR)
    {
		show_menu(id,Keysvoice,"1. Yes sir!^n2. Negative!^n3. I need backup!^n4. Fire in the hole!^n5. Grenade!^n6. Sniper!^n7. Taking fire - left flank!^n8. Taking fire - right flank!^n9. Area clear!^n0. Cancel", -1, "voice2ussr") // Display menu
		return PLUGIN_HANDLED
	}
	else return PLUGIN_CONTINUE; // ничего не тормозит, всё играет дальше
}

public Pressedvoice2ussr(id,key)
{
	if(is_user_alive(id) == 0)
	{
		return PLUGIN_HANDLED
	}
	switch (key)
	{
		case 0:
		{
			// client_cmd(id,"voice_yessir")
			emit_sound(id,CHAN_AUTO, RADIO_USSR[0] ,0.6, ATTN_NORM,0,PITCH_NORM)
			return PLUGIN_HANDLED
		}
		case 1:
		{
			//client_cmd(id,"voice_negative")
			emit_sound(id,CHAN_AUTO, RADIO_USSR[16] ,0.6, ATTN_NORM,0,PITCH_NORM)
			return PLUGIN_HANDLED
		}
		case 2:
		{
			//client_cmd(id,"voice_backup")
			emit_sound(id,CHAN_AUTO, RADIO_USSR[40] ,0.6, ATTN_NORM,0,PITCH_NORM)
			return PLUGIN_HANDLED
		}
		case 3:
		{
			// client_cmd(id,"voice_fireinhole")
			emit_sound(id,CHAN_AUTO, RADIO_USSR[29] ,0.6, ATTN_NORM,0,PITCH_NORM)
			return PLUGIN_HANDLED
		}
		case 4:
		{
			//client_cmd(id,"voice_grenade")
			emit_sound(id,CHAN_AUTO, RADIO_USSR[24] ,0.6, ATTN_NORM,0,PITCH_NORM)
			return PLUGIN_HANDLED
		}
		case 5:
		{
			//client_cmd(id,"voice_sniper")
			emit_sound(id,CHAN_AUTO, RADIO_USSR[12] ,0.6, ATTN_NORM,0,PITCH_NORM)
			return PLUGIN_HANDLED
		}
		case 6:
		{
			//client_cmd(id,"voice_fireleft")
			emit_sound(id,CHAN_AUTO, RADIO_USSR[27] ,0.6, ATTN_NORM,0,PITCH_NORM)
			return PLUGIN_HANDLED
		}
		case 7:
		{
			//client_cmd(id,"voice_fireright")
			emit_sound(id,CHAN_AUTO, RADIO_USSR[26] ,0.6, ATTN_NORM,0,PITCH_NORM)
			return PLUGIN_HANDLED
		}
		case 8:
		{
			//client_cmd(id,"voice_areaclear")
			emit_sound(id,CHAN_AUTO, RADIO_USSR[42] ,0.6, ATTN_NORM,0,PITCH_NORM)
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
	myarmy = pev(id, pev_army)
	if (myarmy == USSR)
    {
	new layout3[1024]
	format(layout3,1023,"1. Go go go!^n2. Displace!^n3. Enemy ahead!^n4. Enemy behind us!^n5. %s^n6. %s^n7. I need Ammo!^n8. %s^n9. %s^n0. Cancel",mgahead,movemg,usepanz,bazahead)
	show_menu(id,Keysvoice,layout3, -1, "voice3ussr")
	return PLUGIN_HANDLED // BLOCK 
	}
	else return PLUGIN_CONTINUE; // ничего не тормозит, всё играет дальше	
}

public Pressedvoice3ussr(id,key)
{
	if(is_user_alive(id) == 0)
	{
		return PLUGIN_HANDLED
	}
	switch (key)
	{
		case 0:
		{
			// client_cmd(id,"voice_gogogo")
			emit_sound(id,CHAN_AUTO, RADIO_USSR[25] ,0.6, ATTN_NORM,0,PITCH_NORM)
			return PLUGIN_HANDLED
		}
		case 1:
		{
			// client_cmd(id,"voice_displace")
			emit_sound(id,CHAN_AUTO, RADIO_USSR[35] ,0.6, ATTN_NORM,0,PITCH_NORM)
			return PLUGIN_HANDLED
		}
		case 2:
		{
			// client_cmd(id,"voice_enemyahead")
			emit_sound(id,CHAN_AUTO, RADIO_USSR[33] ,0.6, ATTN_NORM,0,PITCH_NORM)
			return PLUGIN_HANDLED
		}
		case 3:
		{
			// client_cmd(id,"voice_enemybehind")
			emit_sound(id,CHAN_AUTO, RADIO_USSR[32] ,0.6, ATTN_NORM,0,PITCH_NORM)
			return PLUGIN_HANDLED
		}
		case 4:
		{
			//client_cmd(id,"voice_mgahead")
			emit_sound(id,CHAN_AUTO, RADIO_USSR[20] ,0.6, ATTN_NORM,0,PITCH_NORM)
			return PLUGIN_HANDLED
		}
		case 5:
		{
			//client_cmd(id,"voice_moveupmg")
			emit_sound(id,CHAN_AUTO, RADIO_USSR[18] ,0.6, ATTN_NORM,0,PITCH_NORM)
			return PLUGIN_HANDLED
		}
		case 6:
		{
			// client_cmd(id,"voice_needammo")
			emit_sound(id,CHAN_AUTO, RADIO_USSR[17] ,0.6, ATTN_NORM,0,PITCH_NORM)
			return PLUGIN_HANDLED
		}
		case 7:
		{
			// client_cmd(id,"voice_usebazooka")
			emit_sound(id,CHAN_AUTO, RADIO_USSR[2] ,0.6, ATTN_NORM,0,PITCH_NORM)
			return PLUGIN_HANDLED
		}
		case 8:
		{
			//client_cmd(id,"voice_bazookaspotted")
			emit_sound(id,CHAN_AUTO, RADIO_USSR[15] ,0.6, ATTN_NORM,0,PITCH_NORM)
			return PLUGIN_HANDLED
		}
		case 9:
		{
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_HANDLED
}

public RoundStart()
{
	client_print(0, print_chat,"[RADIO] Round started for id: %d");
	emit_sound(0, CHAN_AUTO, RADIO_USSR[9] ,0.6, ATTN_NORM,0,PITCH_NORM)
}


public fwd_RoundState( msgid, msgdest, id ) 
{

		new arg = get_msg_arg_int( 1 );
		if( arg == 1 ) // Round starting
		{
			client_print(0, print_chat,"[RADIO] Round started for id: %d dest %d", id, msgdest);
		}
		else if( arg == 3 || arg == 4 ) // Allies / Axis win
		{
			client_print(0, print_chat,"[RADIO] Round started for id: %d", id);

			/*
			Существует еще какая-нибудь функция воспроизведения, но чтоб звук воспроизводился 
			только одному игроку (остальные вокруг не слышали его)?
			client_cmd(id, "spk sound/radio/blow.wav")
			*/

		}
	
}