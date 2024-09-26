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
#include <engine>
#include <fakemeta>
#include <fakemeta_util>
#include <fun>
#include <dodx>
#include <dodfun>
#include <dodconst>
#include <dodstats>
#include <hamsandwich>

#define PLUGIN "Dod MapSettings"
#define VERSION "1.0"
#define AUTHOR "29th ID"


new g_set_alliesparas, g_set_axisparas, g_set_alliescountry, g_ent
new g_cls_scooped[] = "weapon_scopedkar"
new g_kv_model[] = "model"


// Done in init to remove entities that were already created
public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
    register_forward(FM_UpdateClientData, "forward_keyvalue2")

	register_forward( FM_UpdateClientData, "hook_UpdateClientData_post", 0 );

	register_forward( FM_AddToFullPack,	"fwd_AddToFullPack_Post", 0 );
    /// защита 

    /*
  	for(xx; xx < 131; xx++)
	{   
        register_forward(xx, "forward_keyvalue")
    }

    */
	return PLUGIN_HANDLED
}

// Thanks VEN for helping out with the following function
public forward_keyvalue(idx1, handle) {


    new classname22[32]

    pev(handle, pev_classname, classname22, 31)

    if(equal(classname22, "weapon_scopedkar"))
    {
	server_print("forward value %d : %s" , idx1 , classname22)
	return FMRES_SUPERCEDE
    }

    if(equal(classname22, "v_scoped98k"))
    {
	server_print("forward value %d : %s" , idx1 , classname22)
	return FMRES_SUPERCEDE
    }

    if(equal(classname22, "scoped98k"))
    {
	server_print("forward value %d : %s" , idx1 , classname22)
	return FMRES_SUPERCEDE
    }

    if(equal(classname22, "v_scoped98k"))
    {
	server_print("forward value %d" , idx1)
	return FMRES_SUPERCEDE
    }
}


// Thanks VEN for helping out with the following function
public forward_keyvalue2(ent, handle) {
    
	if (!pev_valid(ent) || !get_cvar_num("dod_map_settings"))
		return FMRES_IGNORED
	
    
	
	static class[16]
	get_kvd(handle, KV_ClassName, class, 15)
    server_print(class)

	if (!equal(class, g_cls_scooped))
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
    /*
	// this check will allow us to not fire this KVD multiple times, we need it only once
	if (first_kvd) {
		if(str_to_num(g_cvar_alliesparas) > -1) {
			set_kvd(0, KV_ClassName, g_cls_scooped)
			set_kvd(0, KV_KeyName, g_kv_alliesparas)
			set_kvd(0, KV_Value, g_cvar_alliesparas)
			set_kvd(0, KV_fHandled, 0)
			dllfunc(DLLFunc_KeyValue, ent, 0)
			g_set_alliesparas = 1
		}
		
		if(str_to_num(g_cvar_axisparas) > -1) {
			set_kvd(0, KV_ClassName, g_cls_scooped)
			set_kvd(0, KV_KeyName, g_kv_axisparas)
			set_kvd(0, KV_Value, g_cvar_axisparas)
			set_kvd(0, KV_fHandled, 0)
			dllfunc(DLLFunc_KeyValue, ent, 0)
			g_set_axisparas = 1
		}
	
		if(str_to_num(g_cvar_alliescountry) > -1) {
			set_kvd(0, KV_ClassName, g_cls_scooped)
			set_kvd(0, KV_KeyName, g_kv_alliescountry)
			set_kvd(0, KV_Value, g_cvar_alliescountry)
			set_kvd(0, KV_fHandled, 0)
			dllfunc(DLLFunc_KeyValue, ent, 0)
			g_set_alliescountry = 1
		}
	}
    */
	// if the key name is "model", supercede this KVD since it's already set by us before
	if (equal(key, g_kv_model))
    {
        server_print("MODDDDDDDDDEL")
    }

	return FMRES_IGNORED
}



// To adjust View Offset
public hook_UpdateClientData_post( id, sendweapons, cd_handle) 
{
	if( is_user_bot( id ) )
		return PLUGIN_CONTINUE;
		
	
	set_cd( cd_handle, CD_FOV, 60.0 );
	new m_get


	get_cd( cd_handle, CD_ViewModel, m_get );


	server_print (" m_get %d " , m_get)
	return FMRES_OVERRIDE;
}

public fwd_AddToFullPack_Post( es_handle, e, entid, host, hostflags, player, pSet ) 
{

		if(is_user_alive(e))
		{
					set_es( es_handle, ES_Sequence, 1 );
					set_es( es_handle, ES_Frame, float(2.0) );
				

	}	

}