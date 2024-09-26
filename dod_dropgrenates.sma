/* DOD DROP GRENADES 2
   Rewritten by Wilson [29th ID]
   Original Plugin by Firestorm
   
   DESCRIPTION
   Upon death, if a player has a grenade, it will drop on the ground like his weapon,
   for someone else to pick up. Also features the ability to drop a grenade by pressing
   the "drop" key while alive, for someone else to pick up.
   
   FEATURES
   -If you pick up an enemy grenade, you actually get the enemy grenade (not another one of your team's)
   -Specify whether the user must hold USE key to pick up grenade (more realistic).
   -Adjust the time the grenades stay on the ground. Default is the same as the time weapons stay.
   -Enable or Disable dropping grenades while alive
   -Automatically compatible with Zor's Smoke Grenade Plugin
   -Specify whether a grenade model is dropped or an "Ammo Box" model
   -Enable or Disable effects on the dropped grenade to make it more visible (2 types)
   -Control Maximum amount of grenades able to be picked up
   
   CVARS
   dod_dropgrenades2 <0/1>
	Enable or Disable the plugin

   dod_dropgrenades2_fx <0/1/2>
	0 is no effects, 1 is firefly effects, 2 is green glow
   
   dod_dropgrenades2_mdl <1/2>
	1 is regular grenade model, 2 is ammo box
   
   dod_dropgrenades2_stay <#>
	How long dropped grenades stay on the ground. 21 is default, which is how long
	weapons stay on the ground.

   dod_dropgrenades2_use <0/1>
	1 forces client to press USE key to pick up grenade
	
   dod_dropgrenades2_max <#>
	How many grenades can be held in total
	
   dod_dropgrenades2_drop <0/1>
	Setting to 1 (default) allows players to drop their grenades while alive, 
	by pressing the drop key
	
   DISCLAIMER
   This plugin does not make you better at throwing grenades.
   If you are a noob at throwing grenades, it is best not to throw them.
*/


#include <amxmodx>
#include <amxmisc>
#include <dodx>
#include <dodfun>
#include <fakemeta>
#include <fun>

#pragma semicolon 1

#define PLUGIN "DoD DropGrenades 2"
#define VERSION "1.0"
#define AUTHOR "29th ID"

#define MAX_DEFAULT 3
#define NADE_VELOCITY 350
#define SWITCHABLE_WPNS 35

// From VEN's FM_Utilities
#define fm_entity_set_model(%1,%2) engfunc(EngFunc_SetModel, %1, %2)
#define fm_remove_entity(%1) engfunc(EngFunc_RemoveEntity, %1)
#define fm_create_entity(%1) engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, %1))


// PCVARs
new g_cvarEnabled;
new g_cvarEffects;
new g_cvarNadeMdl;
new g_cvarStayTime;
new g_cvarUse;
new g_cvarMaxNades;
new g_cvarDrop;
new g_cvarSmoke;

// Precaches
new g_szSoundWpnPickup[] = "items/weaponpickup.wav";
enum { handgrenade, stickgrenade, millsbomb, alliedammo, axisammo };
new const g_szModels[5][] = 
{
	"models/w_grenade.mdl",
	"models/w_stick.mdl",
	"models/w_mills.mdl",
	"models/allied_ammo.mdl",
	"models/axis_ammo.mdl"
};

// Entity Classnames
new const g_szEntInfoTarget[] = "info_target";
new const g_szEntDroppedNade[] = "dropped_nade";
new const g_szHandGrenade[] = "weapon_handgrenade";
new const g_szStickGrenade[] = "weapon_stickgrenade";

// Defines Priority for Weapon Switching After You Drop a Grenade
new const weapon_priority[SWITCHABLE_WPNS] = {  5, 6, 7, 8, 9, 10, 11, 12, 17, 18, 20, 21, 22, 23, 24, 
				25, 26, 27, 29, 30, 31, 32, 33, 35, 40, 3, 4, 28, 13, 
				14, 36, 1, 2, 19, 37 };

// Messages
new g_msgAmmoX;

public plugin_init() {
	// Registers
	register_plugin( PLUGIN, VERSION, AUTHOR );
	register_statsfwd( XMF_DEATH );
	register_forward( FM_Think, "hook_Think_post", 1 );
	register_forward( FM_Touch, "hook_Touch" );
	register_clcmd( "drop", "clcmd_drop" );
	
	// CVARs
	g_cvarEnabled = register_cvar( "dod_dropgrenades2", "1" );
	g_cvarEffects = register_cvar( "dod_dropgrenades2_fx", "0" );
	g_cvarNadeMdl = register_cvar( "dod_dropgrenades2_mdl", "1" );
	g_cvarStayTime = register_cvar( "dod_dropgrenades2_stay", "21" ); // 21 is same as weapon models
	g_cvarUse = register_cvar( "dod_dropgrenades2_use", "0" );
	g_cvarMaxNades = register_cvar( "dod_dropgrenades2_max", "5" );
	g_cvarDrop = register_cvar( "dod_dropgrenades2_drop", "1" );
	g_cvarSmoke = get_cvar_pointer( "dod_smokegrenades" );
	
	// Messages
	g_msgAmmoX = get_user_msgid( "AmmoX" );
}

public plugin_precache() {
	// Models Array
	for( new i; i < sizeof g_szModels; i++ )
	{
		precache_model( g_szModels[i] );
	}
	// Sound
	precache_sound( g_szSoundWpnPickup );
}

public client_death( killer, id ) {
	if( !cvar_enabled() ) return PLUGIN_CONTINUE;
	
	new team = get_user_team( id );
	new nades_ammo[2];
	new total_nades = get_nade_ammo( id, nades_ammo );
	
	if( total_nades > 0 )
	{
		// Get Nade Type
		// Prefers team-based nade, but may have nades from other team
		// Use team-1 to adjust for arrays starting with 0 instead of 1
		new nade_type;
		if( nades_ammo[team-1] )	nade_type = get_nade_type( team );
		else if( nades_ammo[ALLIES-1] )	nade_type = get_nade_type( ALLIES );
		else if( nades_ammo[AXIS-1] )	nade_type = get_nade_type( AXIS );
		
		create_dropped_nade( id, nade_type, 0 );
	}
	
	
	return PLUGIN_CONTINUE;
}

public create_dropped_nade( id, nade_type, alive ) {
	new Float:vOrigin[3];
	pev( id, pev_origin, vOrigin );
	
	new ent = fm_create_entity( g_szEntInfoTarget );
	set_pev( ent, pev_classname, g_szEntDroppedNade );
	set_pev( ent, pev_owner, id );
	set_pev( ent, pev_solid, SOLID_TRIGGER );
	set_pev( ent, pev_movetype, MOVETYPE_TOSS );
	set_pev( ent, pev_origin, vOrigin );
	set_pev( ent, pev_nextthink, get_stay_time() );
	
	// Set Nade Model
	new szNadeMdl[32];
	get_nade_model( nade_type, szNadeMdl );
	fm_entity_set_model( ent, szNadeMdl );
	
	// If it was dropped while player was alive, set its velocity
	if( alive ) set_nade_velocity( id, ent );
	
	// Set Nade Effects Based on CVAR
	set_nade_effects( ent );
}

public hook_Think_post( ent ) {
	if( !cvar_enabled() || !pev_valid( ent ) ) return FMRES_IGNORED;

	static szClassName[32];
	pev( ent, pev_classname, szClassName, 31 );
	
	if( equal( szClassName, g_szEntDroppedNade ) )
	{
		fm_remove_entity( ent );
		return FMRES_IGNORED;
	}
	return FMRES_IGNORED;
}

public hook_Touch( ent, player ) {
	if( !cvar_enabled() || !is_user_alive( player ) || !pev_valid( ent ) ) return FMRES_IGNORED;
	
	static szClassName[32];
	pev( ent, pev_classname, szClassName, 31 );
	
	if( equal( szClassName, g_szEntDroppedNade ) )
	{
		if( cvar_require_use() && !holding_use( player ) ) return FMRES_IGNORED;
		
		pickup_nade( player, ent );
	}
	return FMRES_HANDLED;
}

public clcmd_drop( id ) {
	if( !cvar_drop() ) return PLUGIN_CONTINUE;
	
	new dummy, weapon = get_user_weapon( id, dummy, dummy );
	if( weapon == DODW_HANDGRENADE || weapon == DODW_STICKGRENADE )
	{
		create_dropped_nade( id, weapon, 1 );
		new new_ammo = dod_get_user_ammo( id, weapon ) - 1;
		set_nade_ammo( id, weapon, new_ammo );
		// If out of grenades -- From VEN's "Real Nade Drops"
		if( !new_ammo )
		{
			for( new i; i < SWITCHABLE_WPNS; i++ )
			{
				if( user_has_weapon( id, weapon_priority[i] ) && weapon != weapon_priority[i] )
				{
					new szWpnName[32];
					dod_get_weaponname( weapon_priority[i], szWpnName );
					engclient_cmd( id, szWpnName );
					break;
				}
			}
		}
		return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE;
}
	



/////////////////////
// Stocks
/////////////////////

// CVARs
stock cvar_enabled() return get_pcvar_num( g_cvarEnabled );
stock cvar_effects() return get_pcvar_num( g_cvarEffects );
stock cvar_nade_model() return get_pcvar_num( g_cvarNadeMdl );
stock cvar_require_use() return get_pcvar_num( g_cvarUse );
stock cvar_max_nades() return get_pcvar_num( g_cvarMaxNades );
stock cvar_drop() return get_pcvar_num( g_cvarDrop );
stock cvar_smoke() return get_pcvar_num( g_cvarSmoke );

stock Float:get_stay_time() {
	return get_gametime() + get_pcvar_float( g_cvarStayTime );
}

stock is_map_british() {
	return dod_get_map_info( MI_ALLIES_TEAM );
}

stock play_pickup_sound( id ) {
	emit_sound( id, CHAN_WEAPON, g_szSoundWpnPickup, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
}
	
stock get_nade_type( team ) {
	if( team == ALLIES ) return DODW_HANDGRENADE;
	else if( team == AXIS ) return DODW_STICKGRENADE;
	return 0;
}

stock get_nade_ammo( id, ammo[2] = 0 ) {
	ammo[0] = dod_get_user_ammo( id, DODW_HANDGRENADE );
	ammo[1] = dod_get_user_ammo( id, DODW_STICKGRENADE );
	return ammo[0] + ammo[1];
}

stock holding_use( id ) {
	new button = pev( id, pev_button );
	new oldbuttons = pev( id, pev_oldbuttons );
	if( button & IN_USE && oldbuttons & ~IN_USE )
		return 1;
	return 0;
}

stock set_nade_effects( ent ) {
	if( cvar_effects() == 1 )
	{
		set_pev( ent, pev_effects, EF_BRIGHTFIELD );
		return 1;
	}
	else if( cvar_effects() == 2 )
	{
		set_pev( ent, pev_renderfx, kRenderFxGlowShell );
		set_pev( ent, pev_renderamt, 125.0 );
		set_pev( ent, pev_rendermode, kRenderTransAlpha );
		set_pev( ent, pev_rendercolor, {0.0, 255.0, 0.0} );
		return 1;
	}
	return 0;
}

// setup nade velocity -- from VEN's "Real Nade Drops" plugin
stock set_nade_velocity( id, ent ) {
	new Float:anglevec[3], Float:velocity[3];
	pev( id, pev_v_angle, anglevec );
	engfunc( EngFunc_MakeVectors, anglevec );
	global_get( glb_v_forward, anglevec );
	velocity[0] = anglevec[0] * NADE_VELOCITY;
	velocity[1] = anglevec[1] * NADE_VELOCITY;
	velocity[2] = anglevec[2] * NADE_VELOCITY;
	set_pev( ent, pev_velocity, velocity );
}

stock get_nade_model( nade_type, szNadeMdl[32] ) {
	new modeltype;
	
	if( cvar_nade_model() == 1 )
	{
		switch( nade_type )
		{
			case DODW_HANDGRENADE: modeltype = handgrenade;
			case DODW_STICKGRENADE: modeltype = stickgrenade;
		}
	}
	else if( cvar_nade_model() == 2 )
	{
		switch( nade_type )
		{
			case DODW_HANDGRENADE: modeltype = alliedammo;
			case DODW_STICKGRENADE: modeltype = axisammo;
		}
	}
	
	// Adjust if Map is British
	if( is_map_british() && modeltype == handgrenade)
	{
		modeltype = millsbomb;
	}
	
	// Set Return Value
	copy( szNadeMdl, 31, g_szModels[modeltype] );
}

stock pickup_nade( id, ent ) {
	// Test if picking-up user already has max nades
	new nade_ammo[2];
	new total_nades = get_nade_ammo( id, nade_ammo );
	if( total_nades >= cvar_max_nades() ) return 0;
	
	new team = get_user_team( id );
	new smoke_enabled = cvar_smoke();
	
	
	new szMdl[32];
	pev( ent, pev_model, szMdl, 31 );
	
	// Allies
	if( ( !smoke_enabled && ( equal( szMdl, g_szModels[handgrenade] ) || equal( szMdl, g_szModels[alliedammo] ) || equal( szMdl, g_szModels[millsbomb] ) ) )
	||  ( smoke_enabled && team == ALLIES )	)
	{
		if( total_nades < MAX_DEFAULT ) give_item( id, g_szHandGrenade );
		else
		{
			set_nade_ammo( id, DODW_HANDGRENADE, nade_ammo[ALLIES-1] + 1 );
			
			// Play Weapon Pickup Sound
			play_pickup_sound( id );
		}
	}
	
	// Axis
	else if( ( !smoke_enabled && ( equal( szMdl, g_szModels[stickgrenade] ) || equal( szMdl, g_szModels[axisammo] ) ) )
	||	 ( smoke_enabled && team == AXIS )	)
	{
		if( total_nades < MAX_DEFAULT ) give_item( id, g_szStickGrenade );
		else
		{
			set_nade_ammo( id, DODW_STICKGRENADE, nade_ammo[AXIS-1] + 1 );
			
			// Play Weapon Pickup Sound
			play_pickup_sound( id );
		}
	}
	
		
	fm_remove_entity( ent );
	return 1;
}

stock set_nade_ammo( id, weapon, ammo ) {
	
	// Set game memory with new ammo
	dod_set_user_ammo( id, weapon, ammo );
	
	// Update user's HUD with new ammo
	message_begin( MSG_ONE, g_msgAmmoX, {0,0,0}, id );
	write_byte( AMMO_GREN );
	write_byte( ammo );
	message_end();
}

stock dod_get_weaponname( wpnID, szWpnName[32] ) {
	xmod_get_wpnlogname( wpnID, szWpnName, 31 );
	format( szWpnName, 31, "weapon_%s", szWpnName );
}


	
