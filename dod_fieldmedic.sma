/*****************************************************************************************
*
*	DoD Field Medic
*		For use with DOD 1.3
*		Rewritten by Vet(3TT3V)
*
*	Original plugins used/referenced:
*		HP Regeneration by Deviance/Doombringer
*		DoD Missing Sounds by Trp. Jed
*
*	Description:
*		This plugin allows players to regenerate hitpoints (health). Players can be
*		healed by saying "/medic" in team chat, or by automatic healing, or both,
*		depending on how the plugin is configured.
*
*		Calling a Medic:
*			Players must use 'say_team /medic' to summon a Medic. Doing so will
*			initiate the healing process. At default settings, this will regenerate
*			100 hitpoints in 10 seconds. Players can only summon a medic a set
*			number of times (default 2) per life. If you summon a medic with 100
*			health, or while currently being healed by the medic, it will still
*			count against you. When a player calls for a medic, a voice file can
*			optionally be played from the player's location for all to hear.
*
*		Auto-Healing:
*			Players will automatically regenerate hitpoints whenever they are
*			injured. At default settings, the regeneration is at a slower rate
*			of 1 hitpoint per second. Kind of like 'walking it off'.
*
*		Both Methods: (default)
*			The plugin defaults to perform both options at the same time. Calling
*			a 'Medic' overrides the auto-healing until you are at 100% health.
*
*		MaxSpeed Feature:
*			If enabled, when a player calls a Medic, their movement speed will
*			be slowed until they reach full health
*
*	Credits:
*		The basic healing routine is from the 'HP Regeneration by Doombringer'
*		plugin that I've modified somewhat. The idea of using a voice call is
*		from the plugin 'DoD Missing Sounds by Trp. Jed'.
*
*	Compatability Note:
*		The 'say /medic' client command will be forwarded on to other plugins after
*		this plugin has processed it. So if other plugins uses the same command,
*		they will still get processed as long as the other plugin is initialized
*		after this one. How other health plugins may affect this one is unknown.
*
*	Command:
*		dod_fieldmedic <#|?> (access level 'h' - default 3)
*			0 - Disables the plugin
*			1 - Players heal quickly when they call a Medic
*			2 - Players heal themselves automatic, but slowly
*			3 - Both mode-1 and mode-2 are enabled
*			? - Displays these command parameters
*
*	CVARs:
*		dodmedic_ctrl - Controls Plugin Mode (default 3)
*		dodmedic_autotime - Time rate to add auto-healing hitpoints (default 1.0)
*		dodmedic_autostep - Hitpoints to add for auto-healing time rate (default 1)
*		dodmedic_automaxhp - Maximum health for auto-healing (default 80)
*		dodmedic_time - Time rate to add Medic hitpoints (default 0.1)
*		dodmedic_step - Hitpoints to add for Medic time rate (default 1)
*		dodmedic_maxhp - Maximum health for Medic healing (default 100)
*		dodmedic_sound - Player yells "Medic" when called (default 1)
*		dodmedic_calls - Number of times a Medic can be called per life (default 2)
*		dodmedic_maxspeed - Speed player moves while being healed by Medic (default 30)
*		dodmedic_maxspeed_enable - <0|1> Enable maxspeed feature (default 0 - disabled)
*		dodmedic_fu_ck - <0|1> Enable FUllupdate cheCK (default 1 - enabled)
*		
******************************************************************************************/
// Version changes
// 1.7 - Use global to track tasks
// 1.7e - Use DeathMsg event instead of client_death forward
// 1.8 - Slow player while healing option
// 2.0 - Block fullupdate

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <dodx>

#define PLUGIN "DOD_FieldMedic"
#define VERSION "2.0"
#define AUTHOR "Vet(3TT3V)"
#define SVALUE "v2.0 by Vet(3TT3V)"

#define BRITISH 0

new g_medic_ctrl
new g_auto_time
new g_auto_step
new g_auto_maxhp
new g_medic_time
new g_medic_step
new g_medic_maxhp
new g_medic_maxspeed
new g_maxspeed_enable
new g_medic_maxcalls
new g_medic_sound
new g_medic_fu_ck
new g_sounds[3][] = {"player/britmedic.wav", "player/usmedic.wav", "player/germedic.wav"}
new g_response[4][] = {"Walk It Off", "Rub Some Dirt On It", "Its Just A Flesh Wound", "Take An Aspirin"}
new g_medic_calls[33]
new g_task_set[33] = {0, ...}
new Float:g_p_speed[33]

public plugin_precache()
{
	precache_sound("player/britmedic.wav")
	precache_sound("player/usmedic.wav")
	precache_sound("player/germedic.wav")
}

public plugin_init()
{
	g_medic_ctrl = register_cvar("dodmedic_ctrl", "3")
	g_auto_time = register_cvar("dodmedic_autotime", "1.0")
	g_auto_step = register_cvar("dodmedic_autostep", "1")
	g_auto_maxhp = register_cvar("dodmedic_automaxhp", "80")
	g_medic_time = register_cvar("dodmedic_time", "0.1")
	g_medic_step = register_cvar("dodmedic_step", "1")
	g_medic_maxhp = register_cvar("dodmedic_maxhp", "100")
	g_medic_sound = register_cvar("dodmedic_sound", "1")
	g_medic_maxcalls = register_cvar("dodmedic_calls", "2")
	g_medic_maxspeed = register_cvar("dodmedic_maxspeed", "30")
	g_maxspeed_enable = register_cvar("dodmedic_maxspeed_enable", "0")
	g_medic_fu_ck = register_cvar("dodmedic_fu_ck", "1")

	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_concmd("dod_fieldmedic", "controlmedic", ADMIN_CFG, "<#|?>")
	register_clcmd("say_team /medic", "cmdMedic")
	register_clcmd("say /medic", "cmdMedic")
	register_clcmd("fullupdate", "cmdFullUpdate", 0, "Block fullupdate")
	register_event("ResetHUD", "player_spawn", "be")
	register_event("DeathMsg", "event_death", "a")

	register_statsfwd(XMF_DAMAGE)
	register_forward(FM_SetClientMaxspeed, "fwd_maxspeed")
	register_cvar(PLUGIN, SVALUE, FCVAR_SERVER|FCVAR_SPONLY)

	log_message("[AMXX] DOD FieldMedic - Plugin %s", get_pcvar_num(g_medic_ctrl) ? "Initialized" : "Disabled")

}


public cmdMedic(id)
{
	if (get_pcvar_num(g_medic_ctrl) == 1 || get_pcvar_num(g_medic_ctrl) == 3) {
		if (g_medic_calls[id]) {
			--g_medic_calls[id]
			if (get_pcvar_num(g_medic_sound)) {
				new myteam = get_user_team(id)
				if (myteam != AXIS)
					myteam = dod_get_map_info(MI_ALLIES_TEAM) ? BRITISH : ALLIES
				emit_sound(id, CHAN_VOICE, g_sounds[myteam], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
			}
			if (pev(id, pev_health) >= get_pcvar_num(g_medic_maxhp)) {
				client_print(id, print_chat, "Medic: Quit Wasting My Time!")
				return PLUGIN_CONTINUE
			}
			clear_task(id)	// end auto-healing or previous medic call if running
			client_print(id, print_chat, "Medic: On my way!")
			set_task(get_pcvar_float(g_medic_time), "heal_player", id, "", 0, "b")
			g_task_set[id] = 2
			if (get_pcvar_num(g_maxspeed_enable))
				set_pev(id, pev_maxspeed, get_pcvar_float(g_medic_maxspeed))
		} else {
			client_print(id, print_chat, pev(id, pev_health) >= get_pcvar_num(g_medic_maxhp) ?
				"Medic: Leave Me Alone!" : "Medic: %s!", g_response[random(4)])
		}	
	}
	return PLUGIN_CONTINUE
}

public event_death()
{
	new victim = read_data(2)
	clear_task(victim)
}

public client_damage(attacker, victim, damage, wpnindex, hitplace, TA)
{
	if (!g_task_set[victim] && get_pcvar_num(g_medic_ctrl) > 1 && pev(victim, pev_health) > 0) {
		if (pev(victim, pev_health) < get_pcvar_num(g_auto_maxhp)) {
			set_task(get_pcvar_float(g_auto_time), "heal_player", victim, "", 0, "b")
			g_task_set[victim] = 1
		}
	}
}

public heal_player(id)
{
	new p_health = pev(id, pev_health)
	switch(g_task_set[id]) {
		case 1: {
			if (p_health >= get_pcvar_num(g_auto_maxhp)) {
				clear_task(id)
				return
			}
			p_health = clamp(p_health + get_pcvar_num(g_auto_step), 0, get_pcvar_num(g_auto_maxhp))
		}
		case 2: {
			if (p_health >= get_pcvar_num(g_medic_maxhp)) {
				clear_task(id)
				return
			}
			p_health = clamp(p_health + get_pcvar_num(g_medic_step), 0, get_pcvar_num(g_medic_maxhp))
		}
	}
	set_pev(id, pev_health, float(p_health))
}

public fwd_maxspeed(id, Float:speed)
{
	g_p_speed[id] = speed
	if (g_task_set[id] == 2 && get_pcvar_num(g_maxspeed_enable))
		return FMRES_SUPERCEDE

	return FMRES_IGNORED
}  

public player_spawn(id)
{
	clear_task(id)
	g_medic_calls[id] = get_pcvar_num(g_medic_maxcalls)
}

public client_disconnect(id)
{
	clear_task(id)
}

public client_putinserver(id)
{
	clear_task(id)
}

public clear_task(id)
{
	remove_task(id)
	g_task_set[id] = 0
	set_pev(id, pev_maxspeed, g_p_speed[id])
}

public controlmedic(id,lvl,cid)
{
	if (!cmd_access(id, lvl, cid, 2))
		return PLUGIN_HANDLED
		
	new tmpstr[32]
	read_argv(1, tmpstr, 31)
	trim(tmpstr)
	if (equal(tmpstr, "?")) {
		console_print(id, "^nFieldMedic Control: dod_fieldmedic #")
		console_print(id, "  0 - Disables DOD FieldMedic plugin")
		console_print(id, "  1 - Play must 'say /medic' to heal - fast")
		console_print(id, "  2 - Player automatically heals - slow")
		console_print(id, "  3 - Enables Mode 1 and Mode 2 simultaneously")
		console_print(id, "dod_fieldmedic Is Currently Set To: %d^n", get_pcvar_num(g_medic_ctrl))
		return PLUGIN_HANDLED
	}
	new tmpctrl = str_to_num(tmpstr)
	if (tmpctrl < 0 || tmpctrl > 3) {
		console_print(id, "dod_fieldmedic parameter out of range (0 - 3)")
		return PLUGIN_HANDLED
	}
	set_cvar_string("dodmedic_ctrl", tmpstr)
	get_user_name(id, tmpstr, 31)
	console_print(id, "dod_fieldmedic control changed to %d", tmpctrl)
	log_message("[AMXX] DOD FieldMedic - Admin %s changed control parameter to %d", tmpstr, tmpctrl)

	return PLUGIN_HANDLED
}

public cmdFullUpdate(id)
{
	if (get_pcvar_num(g_medic_fu_ck))
		return PLUGIN_HANDLED_MAIN
	return PLUGIN_CONTINUE
}
