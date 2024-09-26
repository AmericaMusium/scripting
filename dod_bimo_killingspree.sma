/***************************************************************************************************
*
*	DoD Killing Spree - by Vet(3TT3V)
*		For use with DOD 1.3
*
*	Description:
*		This plugin simulates the 'Bonus Round' found in DOD:S. In that, when a team
*		wins, the winners are allowed to 'mop up' on the losers. During a killing
*		spree, the losers have weapons stripped (can optionally keep a knife/spade),
*		the spawn protection entities are disabled, the killing spree is announced
*		by HUD and soundbite, and an OSD is displayed to show the time remaining.
*		Losers are prevented from picking up dropped weapons. Also, control points
*		and control areas are disabled.
*
*	Command:
*		dod_killingspree (access level 'h') - Toggles the plugin on|off	
*
*	CVars:
*		dod_killingspree_enable <0|1>		// Disable/Enable the killing spree plugin (default 1)
*		dod_killingspree_time <##>		// Killing spree time (default 15 seconds, 11 minimum)
*		dod_killingspree_knives  <0|1>	// Give knives/spades to losers? (default 1 - yes)
*		dod_killingspree_stamina <0|1>	// Give winners unlimited stamina? (default 1 - yes)
*		dod_killingspree_respawn <0|1>	// Allow respawns during killing spree? (default 0 - no)
*		dod_killingspree_notify <0|1>		// Enable notify message and soundbite? (default 1 - yes)
*		dod_killingspree_osd <0|1>		// Enable countdown OSD? (default 1 - yes)
*		dod_killingspree_message <string>	// Notify message to show on HUD
*
*	Config file: (killingspree.cfg)
*		This plugin uses a config file to set several options during a killing spree.
*		Plugin pausing, allows you to pause specific plugins during a killing spree.
*		For example, the WeaponMod2 plugin will still give a loser a weapon if they say
*		/bar during a killing spree. So you'd want to pause this plugin. Server CVars
*		can be set/reset during the killing spree. In the default config, Friendly
*		Fire has been turned Off, Alltalk is turned On and the Chase Cam is Disabled.
*		All CVars are returned to their previous state after the killing spree ends.
*		Options to disable teleports (used as spawn protection on some maps).
*		The file MUST have all sections. Data within those sections is optional. I have
*		included a config file that will work well for most servers. Information for each
*		section is in the	config file. Please know what you are doing before modifying.
*
*	Compatibility:
*		Compatibility issues with other plugins is not addressed. If compatibility problems
*		arise, try listing this plugin elsewhere in the plugins.ini file. Or try pausing the
*		other plugin in the killingspree.cfg file. Other than that, I offer no support.
*
*	Version History:
*		3.0  - Added unlimited stamina option for winning team
*			 Fixed leftover, live grenades exploding upon new round
*			 Fixed problem when players join during a killingspree
*		2.9  - Fix DOD_ESCAPE map using func_breakable entity
*		2.8  - Fix occasional invalid entity error on Linux servers
*		2.7  - Added code to undeploy weapons if necessary
*		2.6  - Fix Func_tank think & code improvements
*		2.5  - Original release
*
****************************************************************************************************/

#include <amxmisc>
#include <dodx>
#include <dodfun>
#include <fakemeta>
#include <hamsandwich>

// Plugin defines - DO NOT CHANGE
#define PLUGIN "DoD_Killing_Spree"
#define VERSION "3.0"
#define AUTHOR "Vet(3TT3V)"
#define SVALUE "v3.0 by Vet(3TT3V)"

// Constant defines - DO NOT CHANGE
#define CLASS_MASTER "dod_control_point_master"
#define CLASS_CNTPNT "dod_control_point"
#define CLASS_CPAREA "dod_capture_area"
#define CLASS_T_TELE "trigger_teleport"
#define CLASS_SCORES "dod_score_ent"
#define CLASS_T_HURT "trigger_hurt"
#define CLASS_F_TANK "func_tank"
#define AXISNADE "grenade2"
#define ALLYNADE "grenade"
#define KS_IDLE 0
#define KS_PREP 1
#define KS_KILL 2
#define NEVER 0.0
#define PLUS1 1.0
#define POST 1
#define PRE 0
#define YES 1
#define NO 0

// Variable defines - CHANGE WITH CAUTION
#define SPREE_TIME "28"			// Killing Spree Default time
#define KS_MINTIME 11			// 11 seconds minimum (can lower but OSD may be inaccurate)
#define KS_MESSAGE "*** Killing Spree ***\n*** Bonus Round ***"	// Default message (use \n for 'New Line')
#define KS_WARNINGORI "BOOF/killingspree.wav"
#define KS_WARNING "BOOF/heatisone2.wav"				// Default soundbite
#define KS_WARNING2 "BOOF/queenwatch.wav"
#define KS_WARNING3 "BOOF/tinabest.wav"
#define KS_WARNING4 "BOOF/inst1.wav"
#define KS_WARNING5 "BOOF/mus1.wav"
#define KS_WARNING6 "BOOF/deschsurv.wav"
#define KS_INSTMP3 "sound/BOOF/inst.mp3"
#define KS_FULMP3 "sound/BOOF/vocmus.mp3"
#define MAX_PLUGINS 8
#define MAX_CVARS 32
#define DOD_KSFILE "killingspree.cfg"

// Function defines
#define fm_find_ent_by_class(%1,%2) engfunc(EngFunc_FindEntityByString, %1, "classname", %2)
#define fm_create_entity(%1) engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, %1))
#define fm_remove_entity(%1) engfunc(EngFunc_RemoveEntity, %1)
#define fm_force_touch(%1,%2) dllfunc(DLLFunc_Touch, %1, %2)
#define fm_force_use(%1,%2) dllfunc(DLLFunc_Use, %1, %2)
#define fm_spawn_entity(%1) dllfunc(DLLFunc_Spawn, %1)

// PCVar pointers
new g_enable
new g_kstime
new g_knives
new g_respawn
new g_stam_pt
new g_notify
new g_osdisp
new g_message

// Global Variables
new Float:g_killtime
new Float:g_osdtimer
new g_osdlife
new g_team
new g_safe
new g_knife
new g_stamina
new g_spawn
new g_pws_ent
new g_control = KS_IDLE
new g_master_ent = -1
new g_score_ent = -1
new g_weapon[3][] = {"weapon_gerknife", "weapon_amerknife", "weapon_spade"}
new g_cvars_count
new g_cvars_names[MAX_CVARS][32]
new g_cvars_value[MAX_CVARS][2]
new g_plugins_count
new g_plugins_names[MAX_PLUGINS][32]

public plugin_precache()
{	

	precache_sound(KS_WARNING)	// Notify soundbite warning
	precache_sound(KS_WARNING2)	// Notify soundbite warning
	precache_sound(KS_WARNING3)	// Notify soundbite warning
	precache_sound(KS_WARNING4)	// Notify soundbite warning
	precache_sound(KS_WARNING5)	// Notify soundbite warning
	precache_sound(KS_WARNING6)	// Notify soundbite warning

	/*
	KS_WARNING4
	*/
	// precache_sound(KS_WARNINGORI)	// Notify soundbite warning
	// precache_sound(KS_WARNING5)	// Notify soundbite warning
	/*
	precache_generic(KS_INSTMP3)
    precache_generic(KS_FULMP3)
	*/
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_cvar(PLUGIN, SVALUE, FCVAR_SERVER|FCVAR_SPONLY)
	register_concmd("dod_killingspree", "killingspree_toggle", ADMIN_CFG, "Toggles KillingSpree On|Off")
	server_print("DOD KILLING SPREES")
	g_enable = register_cvar("dod_killingspree_enable", "1")		// Disable/Enable the killingspree
	g_kstime = register_cvar("dod_killingspree_time", SPREE_TIME)	// Killingspree time
	g_knives = register_cvar("dod_killingspree_knives", "1")		// Give knives to losers?
	g_respawn = register_cvar("dod_killingspree_respawn", "0")		// Allow respawns during killingspree?
	g_stam_pt = register_cvar("dod_killingspree_stamina", "1")		// Allow unlimited stamina for winners?
	g_notify = register_cvar("dod_killingspree_notify", "1")		// Enable notify message and soundbite?
	g_osdisp = register_cvar("dod_killingspree_osd", "1")			// Enable countdown OSD?
	g_message = register_cvar("dod_killingspree_message", KS_MESSAGE)	// Notify message (string)

	RegisterHam(Ham_Think, CLASS_MASTER, "HAM_cp_master_THINK")
	RegisterHam(Ham_Use, CLASS_SCORES, "HAM_score_ent_USE")
	RegisterHam(Ham_Use, CLASS_SCORES, "HAM_score_ent_USE_post", POST)
	RegisterHam(Ham_Touch, CLASS_T_HURT, "HAM_hurt_TOUCH")
	RegisterHam(Ham_Touch, CLASS_CNTPNT, "HAM_caps_TOUCH")
	RegisterHam(Ham_Touch, CLASS_CPAREA, "HAM_caps_TOUCH")
	RegisterHam(Ham_Spawn, "player", "HAM_player_SPAWN_post", POST)
	RegisterHam(Ham_Think, "player", "HAM_player_THINK")
	register_forward(FM_Touch, "ks_touch")
	register_event("RoundState", "round_start", "a", "1=1")

	new ent, pluginname[32]
	get_plugin(-1, pluginname, 31)

	// Find the 'dod_control_point_master' entity
	g_master_ent = fm_find_ent_by_class(g_master_ent, CLASS_MASTER)
	if (!g_master_ent)
		pause("ad", pluginname)

	// Find 2 'dod_score_ent' entities - Fail if less
	for (ent = 0; ent < 2; ent++) {
		g_score_ent = fm_find_ent_by_class(g_score_ent, CLASS_SCORES)
		if (!g_score_ent)
			pause("ad", pluginname)
	}

	// Create a 'player_weaponstrip' entity for losers
	g_pws_ent = fm_create_entity("player_weaponstrip")
	if (!pev_valid(g_pws_ent))
		pause("ad", pluginname)
	fm_spawn_entity(g_pws_ent)

	// Load plugin and CVar options from config file
	new cfg_dir[64], ks_file[128]
	g_cvars_count = 0
	g_plugins_count = 0
	get_configsdir(cfg_dir, 63)
	trim(cfg_dir)
	format(ks_file, 127, "%s/%s", cfg_dir, DOD_KSFILE)
	if (!file_exists(ks_file))
		return PLUGIN_CONTINUE

	new line_text[48], line_len, line_num
	new file_lines = file_size(ks_file, 1)
	new keyname[32], keyvalue[16], mapname[32]
	for (line_num = 0; line_num <= file_lines; line_num++) {
		read_file(ks_file, line_num, line_text, 47, line_len)
		if (equali(line_text, "[PLUGINS]"))
			break
	}
	++line_num
	read_file(ks_file, line_num, line_text, 47, line_len)
	while (line_text[0]) {
		copy(g_plugins_names[g_plugins_count], 31, line_text)
		++g_plugins_count
		if (g_plugins_count == MAX_PLUGINS)
			g_plugins_count = MAX_PLUGINS - 1
		++line_num
		read_file(ks_file, line_num, line_text, 47, line_len)
	}

	for (++line_num; line_num <= file_lines; line_num++) {
		read_file(ks_file, line_num, line_text, 47, line_len)
		if (equali(line_text, "[CVARS]"))
			break
	}
	++line_num
	read_file(ks_file, line_num, line_text, 47, line_len)
	while (line_text[0]) {
		strtok(line_text, keyname, 31, keyvalue, 15, ' ')
		copy(g_cvars_names[g_cvars_count], 31, keyname)
		g_cvars_value[g_cvars_count][POST] = str_to_num(keyvalue)
		++g_cvars_count
		if (g_cvars_count == MAX_CVARS)
			g_cvars_count = MAX_CVARS - 1
		++line_num
		read_file(ks_file, line_num, line_text, 47, line_len)
	}

	get_mapname(mapname, 31)
	// Load teleport_off mapnames from config file
	for (++line_num; line_num <= file_lines; line_num++) {
		read_file(ks_file, line_num, line_text, 47, line_len)
		if (equali(line_text, "[TELEPORT_OFF]")) {
			++line_num
			read_file(ks_file, line_num, line_text, 47, line_len)
			while (line_text[0]) {
				if (equali(line_text, mapname)) {
					RegisterHam(Ham_Touch, CLASS_T_TELE, "HAM_hurt_TOUCH")
					break
				}
				++line_num
				read_file(ks_file, line_num, line_text, 47, line_len)
			}
			break
		}
	}

	// Fix for dod_escape
	if (equali(mapname, "dod_escape")) {
		RegisterHam(Ham_Touch, "func_breakable", "HAM_break_TOUCH")
	}

	return PLUGIN_CONTINUE
}

// THIS TRIGGERS THE KILLINGSPREE
public HAM_score_ent_USE(ent)
{
	if (g_control == KS_IDLE && get_pcvar_num(g_enable)) {
		g_control = KS_PREP
		g_score_ent = ent
		g_team = pev(ent, pev_team)			// Get the winning team
		new tmpint = get_pcvar_num(g_kstime)	// Get/set the killingspree time
		if (tmpint < KS_MINTIME)
			tmpint = KS_MINTIME
		g_killtime = float(tmpint)
		set_task(g_killtime, "killingspree_timer", 2201)
		return HAM_SUPERCEDE
	}
	return HAM_IGNORED
}

public HAM_score_ent_USE_post(ent)
{
	switch (g_control) {
		case KS_PREP: {
			g_safe = YES					// Disable trigger_hurt entities
			func_tanks_off()					// Disable func_tank entities
			g_knife = get_pcvar_num(g_knives)		// Set knife option
			g_stamina = get_pcvar_num(g_stam_pt)	// Set stamina option
			strip_weapons()					// Strip weapons from losers, set stamina
			set_cvar_options()				// Set optional CVars
			pause_plugins()					// Pause optional plugins
			g_spawn = get_pcvar_num(g_respawn)		// Set respawn option
			
			set_task(0.1, "do_stop_sound_for_all")
			set_task(0.3, "ks_notify")
			delete_satchels()
			// ks_notify()				// Do HUD message, sound & OSD
			g_control = KS_KILL
		}
		case KS_KILL: {						// Killingspree over, reset stuff
			g_control = KS_IDLE
			ExecuteHamB(Ham_Think, g_master_ent)
			remove_task(2203)
			reset_cvar_options(PRE)
			reset_stamina()
			delete_satchels()
			// client_print(0, print_chat, "[kspre] 310")
			set_task(3.0, "unpause_plugins")
			cleanup_nades()
		}
	}
	return HAM_IGNORED
}


public delete_satchels()
{
	new ent = -1
	while ((ent = fm_find_ent_by_class(ent, "tripsatchel"))) 
	{
		fm_remove_entity(ent)
	}
	return PLUGIN_CONTINUE
}

public do_stop_sound_for_all()
{
	new i, player
    for (i=0; i < 32; i++) 
    {   
        // каждому игроку. 
        player = i
		if(is_user_connected(player) && (player != 0) && (player != 33) && !is_user_bot(player))
      		client_cmd(player,"stopsound")
	}
	
}

// Use the score_ent by the CP_master to end the killingspree
public killingspree_timer()
{
	ExecuteHamB(Ham_Use, g_score_ent, g_master_ent, g_master_ent, 3, NEVER)
}

public HAM_cp_master_THINK(ent)
{
	if (g_control == KS_KILL)
		return HAM_SUPERCEDE

	return HAM_IGNORED
}

// Reenable protection entities
public round_start()
{
	if (g_safe) {
		g_safe = NO
		func_tanks_on()
	}
	return PLUGIN_CONTINUE
}

// Disable trigger_hurt & trigger_teleport entities
public HAM_hurt_TOUCH(ent)
{
	if (g_safe)
		return HAM_SUPERCEDE
	return HAM_IGNORED
}

// Disable func_tank entities
public func_tanks_off()
{
	new ent = -1
	while ((ent = fm_find_ent_by_class(ent, CLASS_F_TANK)))
		set_pev(ent, pev_nextthink, NEVER)
}

// Enable func_tank entities
public func_tanks_on()
{
	new ent = -1
	while ((ent = fm_find_ent_by_class(ent, CLASS_F_TANK)))
		ExecuteHamB(Ham_Think, ent)
}

// Disable control points & capture areas
public HAM_caps_TOUCH(ent)
{
	if (g_control)
		return HAM_SUPERCEDE
	return HAM_IGNORED
}

// Disable func_breakable on dod_escape
public HAM_break_TOUCH(ent)
{
	static modelID[8]

	if (g_control) {
		pev(ent, pev_model, modelID, 7)
		if (equali(modelID, "*178"))
			return HAM_SUPERCEDE
	}

	return HAM_IGNORED
}

// Respawning control
public HAM_player_THINK(id)
{
	if (g_control) {
		if (!g_spawn) {
			set_pev(id, pev_nextthink, NEVER)
			return HAM_SUPERCEDE
		}
	}
	return HAM_IGNORED
}

// Respawning (if enabled) and new players, strip weapons from losers
public HAM_player_SPAWN_post(id)
{
	if (g_control) {
		switch (pev(id, pev_team)) {
			case 1, 2: {
				if (pev(id, pev_team) != g_team) {
					strip_give(id)
					return HAM_SUPERCEDE
				}
			}
		}
	}
	return HAM_IGNORED
}

// Disable pickup of dropped weapons for losers
public ks_touch(ent, player)		// Note: Touch typically occurs as player->ent. But it can also occur as
{						//	 ent->player. If it does, it will occur the other way also.
	static tclass[32]
	if (g_control) {			// Will be false 99.9% of the time. So plugin shouldn't affect normal touches.
 		if (pev_valid(ent) && pev_valid(player)) {
			if (pev(player, pev_team) != g_team) {
				pev(ent, pev_classname, tclass, 31)
				if (equal(tclass, "weapon", 6))
					return FMRES_SUPERCEDE
			}
		}
	}
	return FMRES_IGNORED
}

// Undeploy (if necessary), and either set stamina or strip weapons
public strip_weapons()
{
	static Float:tmpFl[3]
	for (new id = 1; id <= get_maxplayers(); id++) {
		if (pev(id, pev_iuser3) == 2)
			set_pev(id, pev_iuser3, 1)			// Undeploy from prone
		pev(id, pev_vuser1, tmpFl)
		if (tmpFl[0] == 2.0)
			set_pev(id, pev_vuser1, 1.0)			// Undeploy from sandbags
		if (is_user_alive(id)) {
			if (pev(id, pev_team) != g_team)
				strip_give(id)
			else
				if (g_stamina)
					dod_set_stamina(id, STAMINA_SET, 100, 100)
		}
	}
}

public strip_give(id)
{
	fm_force_use(g_pws_ent, id)		// strip weapons
	if (g_knife) {				// give knife if option set
		new team = pev(id, pev_team)
		if (team == 2 && dod_get_map_info(MI_AXIS_PARAS))
			team = 0
			// The following is a modified/dedicated 'fm_give_item()' routine
		new ent = fm_create_entity(g_weapon[team])
		if (!pev_valid(ent))
			return 0
		new Float:origin[3]
		pev(id, pev_origin, origin)
		set_pev(ent, pev_origin, origin)
		set_pev(ent, pev_spawnflags, pev(ent, pev_spawnflags) | SF_NORESPAWN)
		fm_spawn_entity(ent)
		new save = pev(ent, pev_solid)
		fm_force_touch(ent, id)
		if (pev(ent, pev_solid) != save)
			return ent
		fm_remove_entity(ent)
		return -1
	}
	return 1
}

// Get pre-KS CVar settings
public get_cvar_options()
{
	if (g_cvars_count)
		for (new i = 0; i < g_cvars_count; i++)
			g_cvars_value[i][PRE] = get_cvar_num(g_cvars_names[i])
}

// Set KS CVar settings
public set_cvar_options()
{
	get_cvar_options()		// get current CVar values
	reset_cvar_options(POST)
}

// Reset CVar settings
public reset_cvar_options(amt)
{
	if (g_cvars_count)
		for (new i = 0; i < g_cvars_count; i++)
			set_cvar_num(g_cvars_names[i], g_cvars_value[i][amt])
}

// Reset stamina
public reset_stamina()
{
	if (g_stamina) {
		for (new id = 1; id <= get_maxplayers(); id++) {
			if (pev_valid(id) && is_user_connected(id))
				dod_set_stamina(id, STAMINA_RESET)
		}
	}
}

// Pause optional plugins
public pause_plugins()
{
	if (g_plugins_count)
		for (new i = 0; i < g_plugins_count; i++)
			pause("ac", g_plugins_names[i])
}

// Unpause plugins
public unpause_plugins()
{
	// client_print(0, print_chat, "[kspre] 547")
	if (g_plugins_count)
		for (new i = 0; i < g_plugins_count; i++)
			unpause("ac", g_plugins_names[i])
}

// Sound, Display, and OSD
public ks_notify()
{
	if (get_pcvar_num(g_notify)) {
		new ksmess[128]
		get_pcvar_string(g_message, ksmess, 127)
		while (replace(ksmess, 127, "\n", "^n")) {}
		set_hudmessage(255, 255, 255, -1.0, 0.40, 0, 4.0, 5.0, 0.5, 0.15, 4)
		show_hudmessage(0, ksmess)

		// format(ksmess, 127, "spk %s", KS_WARNING)
		// client_cmd(0, ksmess)
		new i = random_num(0,5)
		if(i==0)
		{
			format(ksmess, 127, "spk %s", KS_WARNING)
			//format(ksmess, 127, "spk stopsound; mp3 play %s", KS_INSTMP3)
		}
		else if(i==1)
		{	
			format(ksmess, 127, "spk %s", KS_WARNING2)
			// format(ksmess, 127, "spk stopsound; mp3 play %s", KS_FULMP3)
		}
		else if(i==2)
		{	
			format(ksmess, 127, "spk %s", KS_WARNING3)
			// format(ksmess, 127, "spk stopsound; mp3 play %s", KS_FULMP3)
		}
		else if(i==3)
		{	
			format(ksmess, 127, "spk %s", KS_WARNING4)
			// format(ksmess, 127, "spk stopsound; mp3 play %s", KS_FULMP3)
		}
		else if(i==4)
		{	
			format(ksmess, 127, "spk %s", KS_WARNING5)
			// format(ksmess, 127, "spk stopsound; mp3 play %s", KS_FULMP3)
		}
		else if(i==5)
		{	
			format(ksmess, 127, "spk %s", KS_WARNING6)
			// format(ksmess, 127, "spk stopsound; mp3 play %s", KS_FULMP3)
		}


		client_cmd(0, ksmess)
		
	}
	if (get_pcvar_num(g_osdisp)) {
		g_osdtimer = g_killtime / 100
		g_osdlife = 100
		update_osd()
		set_task(g_osdtimer, "update_osd", 2203, "", 0, "b")
	}
}

// Update the OSD message (task 2203)
public update_osd()
{
	static r_val, g_val
	switch (g_osdlife	) {
		case 19:
			g_val = 0
		case 49:
			r_val = 255
		case 100: {
			r_val = 0
			g_val = 255
		}
	}
	set_hudmessage(r_val, g_val, 0, -1.0, 0.90, 0, 0.0, g_osdtimer, 0.05, 0.05, 3)
	show_hudmessage(0, "%d%", g_osdlife)
	--g_osdlife
	if (!g_osdlife)			// Precautionary, will probably never happen
		remove_task(2203)
}

public cleanup_nades()
{
	new ent = -1
	while ((ent = fm_find_ent_by_class(ent, ALLYNADE))) {
		fm_remove_entity(ent)
	}
	ent = -1
	while ((ent = fm_find_ent_by_class(ent, AXISNADE))) {
		fm_remove_entity(ent)
	}
	return PLUGIN_CONTINUE
}

// Toggle Killingspree plugin on/off
public killingspree_toggle(id, lvl, cid)
{
	if (cmd_access(id, lvl, cid, 1)) {
		new uname[32]
		get_user_name(id, uname, 31)
		if (get_pcvar_num(g_enable)) {
			set_cvar_string("dod_killingspree_enable", "0")
			console_print(id, "DOD_KillingSpree is now Disabled")
			log_message("[AMXX] Admin %s DISABLED DOD_KillingSpree", uname)
			set_hudmessage(255, 255, 255, -1.0, 0.40, 0, 4.0, 5.0, 0.5, 0.15, 4)
			show_hudmessage(0, "Killing Spree (Bonus Round) has been Disabled")
		} else {
			set_cvar_string("dod_killingspree_enable", "1")
			console_print(id, "DOD_KillingSpree is now Enabled")
			log_message("[AMXX] Admin %s ENABLED DOD_KillingSpree", uname)
			set_hudmessage(255, 255, 255, -1.0, 0.40, 0, 4.0, 5.0, 0.5, 0.15, 4)
			show_hudmessage(0, "Killing Spree (Bonus Round) has been Enabled")
		}
	}
	return PLUGIN_HANDLED
}

// In case there's a map change during a killing spree,
// return server settings to their previous values
public plugin_end()
{
	if (g_control == KS_KILL)
		reset_cvar_options(PRE)
}
