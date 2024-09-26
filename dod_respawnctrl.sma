/*********************************************************************************************
*
*	DOD Respawn Controller
*	Written by Vet(3TT3V)
*
*	To be used with Day of Defeat 1.3
*
*	Features:
*		Changes the respawn time factor of Ally and Axis players
*		Use 'dod_respawnctrl <#>' (ACCESS_CFG) command to change the plugin's behavior
*		Logs status changes with admin's name
*
*	Command:
*		dod_respawnctrl <0|1|2|3|?> - Changes the way the plugin operates (default 1)
*			0 - Plugin is disabled
*			1 - Plugin uses the respawnctrl.cfg file for respawn factors (default)
*			2 - Plugin uses respawn factors of 0.1 for both teams (no config needed)
*			3 - Plugin uses CVARs for respawn factors (default 0.5, no config needed)
*
*	CVARs:
*		dodrespawn_ctrl <0|1|2|3> (default 1) - Controls the mode of the plugin
*			DO NOT place this cvar in any config file that gets executed upon map change
*			Changing cvar value will not take affect until the map changes
*		dodrespawn_ally <#.#> (default = 0.5) - Factor for Allies in Ctrl mode 3
*		dodrespawn_axis <#.#> (default = 0.5) - Factor for Axis in Ctrl mode 3
*
*	Notes:
*		respawnctrl.cfg (if used) must be placed in the /amxmodx/config/ folder
*		map name 'dod_all' will apply factors to ALL maps not listed. If used
*			in conjunction WITH other maps, ensure its listed LAST in the config.
*		respawnctrl.cfg syntax: <mapname> <ally respawn factor> <axis respawn factor>
*			Factor minimum is 0.1 (No maximum, but I'd keep it under 3.0)
*			If the Allies factor is 0, the factors are not changed for that map.
*				(Only necessary if using the dod_all mapname)
*
*		Sample respawnctrl.cfg files:
*		1)	dod_kraftstoff 1.2 0.8
*			dod_zalec 0.7 1.3
*			(ONLY dod_kraftstoff and dod_zalec will have altered respawn factors)
*
*		2)	dod_jagd 0
*			dod_all 0.5 0.5
*			(All maps EXCEPT dod_jagd will have respawn factors of 0.5 for both teams)
*
*		3)	dod_kraftstoff 1.2 0.8
*			dod_zalec 0.7 1.3
*			dod_jagd 0
*			dod_all 0.9 1.1
*			(ALL maps EXCEPT dod_jagd will have altered respawn factors. dod_kraftstoff
*			and dod_zalec use the specified values. Other maps are set to 0.9 for Allies
*			and 1.1 for Axis)
*
**********************************************************************************************/

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>

// From Ven's fakemeta_util include
#define fm_create_entity(%1) engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, %1))
#define fm_DispatchSpawn(%1) dllfunc(DLLFunc_Spawn, %1)
#define fm_find_ent_by_class(%1,%2) engfunc(EngFunc_FindEntityByString, %1, "classname", %2)

#define PLUGIN "DOD Respawn Controller"
#define VERSION "1.6"
#define AUTHOR "Vet(3TT3V)"
#define SVARIABLE "DOD_RespawnCtrl"
#define SVALUE "v1.6 by Vet(3TT3V)"

#define DEFAULT_FACTOR "1.0"
#define RS_MIN 0.1
#define DOD_CLASSNAME "info_doddetect"
#define DOD_ALLY_KEY "detect_allies_respawnfactor"
#define DOD_AXIS_KEY "detect_axis_respawnfactor"
#define DOD_FRFILE "respawnctrl.cfg"
#define DOD_ALLMAPS "dod_all"

new g_control
new g_ally
new g_axis

public plugin_init()
{
	g_control = register_cvar("dodrespawn_ctrl", "1")
	g_ally = register_cvar("dodrespawn_ally", "2")
	g_axis = register_cvar("dodrespawn_axis", "2")

	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_concmd("dod_respawnctrl", "respawncontrol", ADMIN_CFG, "<#|?>")
	register_cvar(SVARIABLE, SVALUE, FCVAR_SERVER|FCVAR_SPONLY)

	new getally[6]
	new getaxis[6]
	switch (get_pcvar_num(g_control)) {
		case 1: {
			new cfg_dir[64]
			new fr_file[128]
			get_configsdir(cfg_dir, 63)
			trim(cfg_dir)
			format(fr_file, 127, "%s/%s", cfg_dir, DOD_FRFILE)
			if (!file_exists(fr_file)) {
				log_message("[AMXX] DOD RespawnCtrl - respawnctrl.cfg file not found.")
				return PLUGIN_CONTINUE
			}
			new mapname[32]
			new file_text[48]
			new txt_len
			new file_lines = file_size(fr_file, 1)
			new fr_map[32]
			new keyvalue[16]
			new datafound = 0
			get_mapname(mapname, 31)
			for (new i = 0; i <= file_lines; i++) {
				read_file(fr_file, i ,file_text, 47, txt_len)
				strtok(file_text, fr_map, 31, keyvalue, 15, ' ', 1)
				if(equali(mapname, fr_map) || equali(DOD_ALLMAPS, fr_map)) {
					datafound = 1
					break
				}
			}
			if (!datafound) {
				log_message("[AMXX] DOD RespawnCtrl - Map data not found.")
				return PLUGIN_CONTINUE
			}
			strtok(keyvalue, getally, 5, getaxis, 5, ' ', 1)
		}
		case 2: {
			float_to_str(Float:RS_MIN, getally, 5)
			float_to_str(Float:RS_MIN, getaxis, 5)
		}
		case 3: {
			get_pcvar_string(g_ally, getally, 5)
			get_pcvar_string(g_axis, getaxis, 5)
		}
		default: {
			return PLUGIN_CONTINUE
		}
	}
	if (equali(getally, "0")) {
		log_message("[AMXX] DOD RespawnCtrl - Factors not changed.")
		return PLUGIN_CONTINUE
	}
	if (str_to_float(getally) < RS_MIN || str_to_float(getaxis) < RS_MIN) {
		log_message("[AMXX] DOD RespawnCtrl - Invalid respawn factor(s)")
		return PLUGIN_CONTINUE
	}

	new ent = fm_find_ent_by_class(0, DOD_CLASSNAME)
	if (!ent) {
		ent = fm_create_entity(DOD_CLASSNAME)
		fm_set_kvd(ent, DOD_ALLY_KEY, DEFAULT_FACTOR)
		fm_set_kvd(ent, DOD_AXIS_KEY, DEFAULT_FACTOR)
		fm_DispatchSpawn(ent)
	}

	fm_set_kvd(ent, DOD_ALLY_KEY, getally)
	fm_set_kvd(ent, DOD_AXIS_KEY, getaxis)
	
	log_message("[AMXX] DOD RespawnCtrl - Respawn factors set. Allies = %s; Axis = %s", getally, getaxis)
	return PLUGIN_CONTINUE
}

public respawncontrol(id,lvl,cid)
{
	if (!cmd_access(id, lvl, cid, 2))
		return PLUGIN_HANDLED
		
	new tmpstr[32]
	read_argv(1, tmpstr, 31)
	trim(tmpstr)
	if (equal(tmpstr, "?")) {
		console_print(id, "^nDOD_RespawnCtrl Usage: dod_respawnctrl #")
		console_print(id, "  0 - Disables the DOD_RespawnCtrl plugin")
		console_print(id, "  1 - Use the respawnctrl.cfg file for respawn factors")
		console_print(id, "  2 - Set all maps to the fastest respawn factor (3 seconds)")
		console_print(id, "  3 - Use the CVARs for respawn factors (default 0.5)")
		console_print(id, "dod_respawnctrl Is Currently Set To: %d^n", get_pcvar_num(g_control))
		return PLUGIN_HANDLED
	}

	new tmpctrl = str_to_num(tmpstr)
	if (tmpctrl < 0 || tmpctrl > 3) {
		console_print(id, "dod_respawnctrl control parameter out of range (0 - 3)")
		return PLUGIN_HANDLED
	}

	set_cvar_string("dodrespawn_ctrl", tmpstr)
	get_user_name(id, tmpstr, 31)
	console_print(id, "dodrespawnctrl control changed to %d", tmpctrl)
	log_message("[AMXX] DOD RespawnCtrl - Admin %s changed control value to %d", tmpstr, tmpctrl)

	return PLUGIN_HANDLED
}

// From Ven's fakemeta_util include
// based on Basic-Master's set_keyvalue, upgraded version optionally accepts a classname
stock fm_set_kvd(entity, const key[], const value[], const classname[] = "")
{
	if (classname[0])
		set_kvd(0, KV_ClassName, classname)
	else {
		new class[32]
		pev(entity, pev_classname, class, 31)
		set_kvd(0, KV_ClassName, class)
	}
	set_kvd(0, KV_KeyName, key)
	set_kvd(0, KV_Value, value)
	set_kvd(0, KV_fHandled, 0)

	return dllfunc(DLLFunc_KeyValue, entity, 0)
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1049\\ f0\\ fs16 \n\\ par }
*/
