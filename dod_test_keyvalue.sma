#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <dodx>
#include <dodfun>

#define PLUGIN "Dod MapSettings"
#define VERSION "1.0"
#define AUTHOR "29th ID"
new g_ent

// Done in precache so it is caught before the entities are spawned
public plugin_precache() {
	register_forward(FM_KeyValue, "forward_keyvalue")
	
}

// Done in init to remove entities that were already created
public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)


return PLUGIN_CONTINUE
}

// Thanks VEN for helping out with the following function
public forward_keyvalue(ent, handle) {

	new szClassname[32],szKeyname[32],szValue[32]

	if (!pev_valid(ent))
		
		
		/*
		get_kvd(handle, KV_Value, szValue, 31)
		server_print("ENT ---  %d ::  %s,", ent,  szValue)

	ENT ---  342 ::  ,
	ENT ---  342 ::  ,
	ENT ---  343 ::  func_wall,
	ENT ---  343 ::  ,
	ENT ---  343 ::  ,
		*/
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

		
        

            get_kvd(handle, KV_ClassName, szClassname, 31)
			get_kvd(handle, KV_KeyName, szKeyname, 31)
			get_kvd(handle, KV_Value, szValue, 31)
			server_print("KVD %s :: %s :: %s ",szClassname , szKeyname, szValue)

            /*
			set_kvd(0, KV_ClassName, g_entity_doddetect)
			set_kvd(0, KV_KeyName, g_kv_alliesparas)
			set_kvd(0, KV_Value, g_cvar_alliesparas)
			set_kvd(0, KV_fHandled, 0)
			dllfunc(DLLFunc_KeyValue, ent, 0)
			g_set_alliesparas = 1
			return FMRES_SUPERCEDE

KVD info_doddetect
KVD origin :: 1552 2960 -496
KVD info_doddetect
KVD detect_wind_velocity_y :: 0.0
KVD info_doddetect
KVD detect_wind_velocity_x :: 0.0
KVD info_doddetect
KVD detect_axis_respawnfactor :: 1.0
KVD info_doddetect
KVD detect_allies_respawnfactor :: 1.0
KVD info_doddetect
KVD detect_points_timerexpired :: 5
KVD info_doddetect
KVD detect_points_allieseliminated :: 5
KVD info_doddetect
KVD detect_points_axiseliminated :: 5
KVD info_doddetect
KVD detect_axis_infinite :: 1
KVD info_doddetect
KVD detect_allies_infinite :: 1
            */



	

	return FMRES_IGNORED
}


