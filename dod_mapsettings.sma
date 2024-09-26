/*
	Dod MapSettings
	Author: 29th ID
	Credits: VEN from amxx forums
	
	Part of the 29th ID's modification to
	Day of Defeat, making it more realistic
	DOD:Realism - dodrealism.branzone.com
	
	
	Description:
	This plugin allows you to edit your server's gameplay within each map in the following ways.
	-Enable or Disable "paras" on allies (skins and weapons)
	-Enable or Disable "paras" on axis (skins and weapons)
	-Enable British or Americans (skins and weapons)
	-Remove all flags from the map (good for deathmatch-style play)
	-Remove the timer from the map (good for deathmatch-style play)
	-Remove spawn guns (players can enter enemy spawns)
	
	
	Usage (CVARs):
	dod_map_settings <1/0>
		Enables or Disables the overall plugin
	dod_map_alliesparas <1/0/-1>
		Sets allies paras (skins and weapons)
		Setting to 1 enables
		Setting to 0 disables
		Setting to -1 ignores command and goes to map default
	dod_map_axisparas <1/0/-1>
		Sets axis paras (skins and weapons)
		Setting to 1 enables
		Setting to 0 disables
		Setting to -1 ignores command and goes to map default	
	dod_map_alliescountry <1/0/-1>
		Sets British or Allies
		Setting to 1 is British
		Setting to 0 is Americans
		Setting to -1 ignores command and goes to map default
	dod_map_removeflags <1/0>
		Setting to 1 removes all flags and control points
	dod_map_removetimer <1/0>
		Setting to 1 removes the map timer
	dod_map_removespawngun <1/0>
		Setting to 1 removes the spawn gun and trigger_hurt in spawn
*/

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>

#define PLUGIN "Dod MapSettings"
#define VERSION "1.0"
#define AUTHOR "29th ID"


new g_set_alliesparas, g_set_axisparas, g_set_alliescountry, g_ent
new g_entity_doddetect[] = "info_doddetect"
new g_kv_alliesparas[] = "detect_allies_paras"
new g_kv_axisparas[] = "detect_axis_paras"
new g_kv_alliescountry[] = "detect_allies_country"

// Done in precache so it is caught before the entities are spawned
public plugin_precache() {
	register_forward(FM_KeyValue, "forward_keyvalue")
	
	register_cvar("dod_map_settings", "1")
	register_cvar("dod_map_alliesparas", "-1")
	register_cvar("dod_map_axisparas", "-1")
	register_cvar("dod_map_alliescountry", "-1")
	register_cvar("dod_map_removeflags", "0")
	register_cvar("dod_map_removetimer", "0")
	register_cvar("dod_map_removespawngun", "0")
}

// Done in init to remove entities that were already created
public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	


	if(!get_cvar_num("dod_map_settings"))
		return PLUGIN_HANDLED
	if(get_cvar_num("dod_map_removeflags"))
		remove_map_ents("dod_control_point", 0)
	if(get_cvar_num("dod_map_removetimer"))
		remove_map_ents("dod_round_timer", 0)
	if(get_cvar_num("dod_map_removespawngun")) {
		remove_map_ents("func_tank", 0) // The gun that shoots you if you're in enemy spawn
		remove_map_ents("trigger_hurt", 64) // 64 means DontHurtAllies
		remove_map_ents("trigger_hurt", 128) // 128 means DontHurtAxis
	}
	return PLUGIN_HANDLED
}

// Thanks VEN for helping out with the following function
public forward_keyvalue(ent, handle) {
	if (!pev_valid(ent) || !get_cvar_num("dod_map_settings"))
		return FMRES_IGNORED
	
	new g_cvar_alliesparas[8]
	get_cvar_string("dod_map_alliesparas", g_cvar_alliesparas, 7)
	new g_cvar_axisparas[8]
	get_cvar_string("dod_map_axisparas", g_cvar_axisparas, 7)
	new g_cvar_alliescountry[8]
	get_cvar_string("dod_map_alliescountry", g_cvar_alliescountry, 7)
	
	static class[16]
	get_kvd(handle, KV_ClassName, class, 15)
	
	if (!equal(class, g_entity_doddetect))
		return FMRES_IGNORED

	// this variable will tell us whether the first KVD is fired to the hostage
	new bool:first_kvd = false
	if (ent != g_ent) { // hence this is the next hostage who recieves the KVD
		first_kvd = true // hence this is his first KVD
		g_ent = ent // our current hostage entity is the ent
	}

	static key[28]
	// retrieve the key name
	get_kvd(handle, KV_KeyName, key, 27)

	// this check will allow us to not fire this KVD multiple times, we need it only once
	if (first_kvd) {
		if(str_to_num(g_cvar_alliesparas) > -1) {
			set_kvd(0, KV_ClassName, g_entity_doddetect)
			set_kvd(0, KV_KeyName, g_kv_alliesparas)
			set_kvd(0, KV_Value, g_cvar_alliesparas)
			set_kvd(0, KV_fHandled, 0)
			dllfunc(DLLFunc_KeyValue, ent, 0)
			g_set_alliesparas = 1
		}
		
		if(str_to_num(g_cvar_axisparas) > -1) {
			set_kvd(0, KV_ClassName, g_entity_doddetect)
			set_kvd(0, KV_KeyName, g_kv_axisparas)
			set_kvd(0, KV_Value, g_cvar_axisparas)
			set_kvd(0, KV_fHandled, 0)
			dllfunc(DLLFunc_KeyValue, ent, 0)
			g_set_axisparas = 1
		}
	
		if(str_to_num(g_cvar_alliescountry) > -1) {
			set_kvd(0, KV_ClassName, g_entity_doddetect)
			set_kvd(0, KV_KeyName, g_kv_alliescountry)
			set_kvd(0, KV_Value, g_cvar_alliescountry)
			set_kvd(0, KV_fHandled, 0)
			dllfunc(DLLFunc_KeyValue, ent, 0)
			g_set_alliescountry = 1
		}
	}

	// if the key name is "model", supercede this KVD since it's already set by us before
	if (equal(key, g_kv_alliesparas) && g_set_alliesparas)
		return FMRES_SUPERCEDE
	if (equal(key, g_kv_axisparas) && g_set_axisparas)
		return FMRES_SUPERCEDE
	if (equal(key, g_kv_alliescountry) && g_set_alliescountry)
		return FMRES_SUPERCEDE

	return FMRES_IGNORED
}

// Removes entities within the map - matches flags if they exist
public remove_map_ents(strEntity[], req_flags) {
	// Search for spawns
	new g_flags, ent = -1
	
	while((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", strEntity)) != 0) {
		g_flags = pev(ent, pev_spawnflags)
		if( (req_flags > 0) && (g_flags != req_flags) )
			continue
		engfunc(EngFunc_RemoveEntity, ent)
	}
	
	return PLUGIN_CONTINUE
}
