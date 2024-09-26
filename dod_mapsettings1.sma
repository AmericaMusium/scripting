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
	dod_map_weather <2/1/0/-1>
		Sets the weather type in the map
		Setting to 2 adds Snow
		Setting to 1 adds Rain
		Setting to 0 turns off weather
		Setting to -1 ignores command and goes to map default
	dod_map_removeflags <1/0>
		Setting to 1 removes all flags and control points
	dod_map_removetimer <1/0>
		Setting to 1 removes the map timer
	dod_map_removespawngun <1/0>
		Setting to 1 removes the spawn gun and trigger_hurt in spawn
	dod_map_removemortars <1/0>
		Setting to 1 mortar fields in a map
*/

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>

#define PLUGIN "Dod MapSettings"
#define VERSION "1.0"
#define AUTHOR "29th ID"

#define CREATE_ENTITY(%1)		engfunc(EngFunc_CreateNamedEntity,engfunc(EngFunc_AllocString,%1))

new g_cvar_Enabled, g_cvar_Alliesparas, g_cvar_Axisparas, g_cvar_Alliescountry, g_cvar_Weather
new g_cvar_Removeflags, g_cvar_Removetimer, g_cvar_Removespawngun, g_cvar_Removemortars

new g_set_alliesparas, g_set_axisparas, g_set_alliescountry, g_set_weathertype, g_ent, g_entity_created
new g_entity_doddetect[] = "info_doddetect"
new g_kv_alliesparas[] = "detect_allies_paras"
new g_kv_axisparas[] = "detect_axis_paras"
new g_kv_alliescountry[] = "detect_allies_country"
new g_kv_weathertype[] = "detect_weather_type"

// Done in precache so it is caught before the entities are spawned
public plugin_precache() {
	register_forward(FM_KeyValue, "forward_keyvalue")
	//add_game_entity(g_entity_doddetect)
	
	g_cvar_Enabled = register_cvar("dod_map_settings", "1")
	g_cvar_Alliesparas = register_cvar("dod_map_alliesparas", "0")
	g_cvar_Axisparas = register_cvar("dod_map_axisparas", "0")
	g_cvar_Alliescountry = register_cvar("dod_map_alliescountry", "0")
	g_cvar_Weather = register_cvar("dod_map_weather", "0")
	g_cvar_Removeflags = register_cvar("dod_map_removeflags", "0")
	g_cvar_Removetimer = register_cvar("dod_map_removetimer", "0")
	g_cvar_Removemortars = register_cvar("dod_map_removemortars", "0")
	g_cvar_Removespawngun = register_cvar("dod_map_removespawngun", "0")
}

// Done in init to remove entities that were already created
public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	if(!get_pcvar_num(g_cvar_Enabled))
		return PLUGIN_HANDLED
	if(get_pcvar_num(g_cvar_Removeflags))
		remove_map_ents("dod_control_point", 0)
	if(get_pcvar_num(g_cvar_Removetimer))
		remove_map_ents("dod_round_timer", 0)
	if(get_pcvar_num(g_cvar_Removemortars))
		remove_map_ents("func_mortar_field", 0)
	if(get_pcvar_num(g_cvar_Removespawngun)) {
		remove_map_ents("func_tank", 0) // The gun that shoots you if you're in enemy spawn
		remove_map_ents("trigger_hurt", 64) // 64 means DontHurtAllies
		remove_map_ents("trigger_hurt", 128) // 128 means DontHurtAxis
	}
	add_doddetect()



	return PLUGIN_HANDLED
}

// Thanks VEN for helping out with the following function
public forward_keyvalue(ent, handle) {
	if (!pev_valid(ent) || !get_pcvar_num(g_cvar_Enabled))
		return FMRES_IGNORED
	
	new sz_alliesparas[8]
	get_pcvar_string(g_cvar_Alliesparas, sz_alliesparas, 7)
	new sz_axisparas[8]
	get_pcvar_string(g_cvar_Axisparas, sz_axisparas, 7)
	new sz_alliescountry[8]
	get_pcvar_string(g_cvar_Alliescountry, sz_alliescountry, 7)
	new sz_weathertype[8]
	get_pcvar_string(g_cvar_Weather, sz_weathertype, 7)
	
	static class[16]
	get_kvd(handle, KV_ClassName, class, 15)
	
	if (!equal(class, g_entity_doddetect))
		return FMRES_IGNORED
	else
		g_entity_created = 1

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
		if(str_to_num(sz_alliesparas) > -1) {
			DISPATCH_KEYVALUE(ent, g_kv_alliesparas, sz_alliesparas)
			g_set_alliesparas = 1
		}
		
		if(str_to_num(sz_axisparas) > -1) {
			DISPATCH_KEYVALUE(ent, g_kv_axisparas, sz_axisparas)
			g_set_axisparas = 1
		}
	
		if(str_to_num(sz_alliescountry) > -1) {
			DISPATCH_KEYVALUE(ent, g_kv_alliescountry, sz_alliescountry)
			g_set_alliescountry = 1
		}
	
		if(str_to_num(sz_weathertype) > -1) {
			DISPATCH_KEYVALUE(ent, g_kv_weathertype, sz_weathertype)
			g_set_weathertype = 1
		}
	}

	// if the key name is "model", supercede this KVD since it's already set by us before
	if (equal(key, g_kv_alliesparas) && g_set_alliesparas)
		return FMRES_SUPERCEDE
	if (equal(key, g_kv_axisparas) && g_set_axisparas)
		return FMRES_SUPERCEDE
	if (equal(key, g_kv_alliescountry) && g_set_alliescountry)
		return FMRES_SUPERCEDE
	if (equal(key, g_kv_weathertype) && g_set_weathertype)
		return FMRES_SUPERCEDE

	return FMRES_IGNORED
}

// Removes entities within the map - matches flags if they exist
public remove_map_ents(strEntity[], req_flags) {
	// Search for spawns
	new g_flags, g_iuser1, ent = -1
	
	while((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", strEntity)) != 0) {
		g_flags = pev(ent, pev_spawnflags)
		g_iuser1 = pev(ent, pev_iuser1)
		if( (req_flags > 0) && (g_flags != req_flags) && (g_iuser1 != 292929) )
			continue
		engfunc(EngFunc_RemoveEntity, ent)
	}
	
	return PLUGIN_CONTINUE
}

// Tests if info_doddetect has been created. If not, it creates it with desired keyvalues
public add_doddetect() {
	if(!g_entity_created && get_pcvar_num(g_cvar_Enabled))
	{
		
		new sz_alliesparas[8]
		get_pcvar_string(g_cvar_Alliesparas, sz_alliesparas, 7)
		new sz_axisparas[8]
		get_pcvar_string(g_cvar_Axisparas, sz_axisparas, 7)
		new sz_alliescountry[8]
		get_pcvar_string(g_cvar_Alliescountry, sz_alliescountry, 7)
		new sz_weathertype[8]
		get_pcvar_string(g_cvar_Weather, sz_weathertype, 7)
		
		new ent = CREATE_ENTITY(g_entity_doddetect)
		if(str_to_num(sz_alliesparas) > -1) {
			DISPATCH_KEYVALUE(ent, g_kv_alliesparas, sz_alliesparas)
			g_set_alliesparas = 1
		}
		
		if(str_to_num(sz_axisparas) > -1) {
			DISPATCH_KEYVALUE(ent, g_kv_axisparas, sz_axisparas)
			g_set_axisparas = 1
		}
	
		if(str_to_num(sz_alliescountry) > -1) {
			DISPATCH_KEYVALUE(ent, g_kv_alliescountry, sz_alliescountry)
			g_set_alliescountry = 1
		}
	
		if(str_to_num(sz_weathertype) > -1) {
			DISPATCH_KEYVALUE(ent, g_kv_weathertype, sz_weathertype)
			g_set_weathertype = 1
		}
		
		dllfunc(DLLFunc_Spawn, ent)
		
	}
}

stock DISPATCH_KEYVALUE(idEntity,szKeyName[],szValue[]) {
		set_kvd(0,KV_KeyName,szKeyName)
		set_kvd(0,KV_Value,szValue)
		set_kvd(0,KV_fHandled,0)
		return dllfunc(DLLFunc_KeyValue,idEntity,0)	
}
