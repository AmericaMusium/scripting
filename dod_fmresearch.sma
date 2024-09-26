/*
 * FAKEMETA RESEARCH  (v1.0)
 * by Wilson [29th ID]
 * 
 * www.29th.org
 *
 * DESCRIPTION
 * This plugin allows developers to research through fakemeta several 
 * times quicker than they would normally take, by coding an entire
 * test plugin just to find a PEV value, or ES/CD setting, or alter 
 * the said variables, or find that specific PDATA offset. FM Research
 * allows you to read, set, log, and compare these values dynamically
 * in game.
 *
 * USAGE
 *
 * PEV
 * Read: fm_pev <ent> <member> read
 * Set: fm_pev <ent> <member> <arg1> <arg2> <arg3>
 *
 * ClientData (CD)
 * Read: fm_cd <ent> <member> read
 * Set: fm_cd <ent> <member> <arg1> <arg2> <arg3>
 *
 * EntityState (ES)
 * Read: fm_cd <ent> <member> read
 * Set: fm_cd <ent> <member> <arg1> <arg2> <arg3>
 *
 * Pdata
 * Read: fm_pdata <ent> <offset> read
 * Set: fm_pdata <ent> <offset> <arg>
 *
 * Pdata Ranges
 * Log: fm_pdata_log <ent> <low> <high>
 * Read: fm_pdata_log <ent> <low> <high> console
 * Store: fm_pdata_log <ent> <low> <high> store
 * Compare: fm_pdata_log <ent> <low> <high> compare
 * Search: fm_pdata_search <ent> <low> <high> <target>
 *
 * SHORTCUTS
 * -For the <ent> argument, you can use keywords such as "id", "me", "wpn", "gun"
 * -The pdata argument "console" can be replaced by "con"
 * -To reset ClientData or EntityState data, use the "read" argument at the end, or the "reset" argument.
 *
 * NOTE
 * If you are using Day of Defeat, uncomment the line at the very top of the plugin that says "Uncomment"
 */


//Uncomment this line if you are using this for day of defeat
#define DAYOFDEFEAT


#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#if defined DAYOFDEFEAT
#include <dodx>
#endif


#define PLUGIN "FM Research"
#define VERSION "1.0"
#define AUTHOR "Wilson 29th ID"

#define TYPE_NONE 0
#define TYPE_INTEGER 1
#define TYPE_FLOAT 2
#define TYPE_VECTOR 3
#define TYPE_STRING 4
#define MAX_LINES 33
#define VALUE_READ -99

//Const List

#define PEV_MEMBERS 149
#define CD_MEMBERS   40
#define ES_MEMBERS   62

new g_pevlist[PEV_MEMBERS][32] = 
{
	"pev_string_start",
	"pev_classname",
	"pev_globalname",
	"pev_model",
	"pev_target",
	"pev_targetname",
	"pev_netname",
	"pev_message",
	"pev_noise",
	"pev_noise1",
	"pev_noise2",
	"pev_noise3",
	"pev_string_end",
	"pev_edict_start",
	"pev_chain",
	"pev_dmg_inflictor",
	"pev_enemy",
	"pev_aiment",
	"pev_owner",
	"pev_groundentity",
	"pev_euser1",
	"pev_euser2",
	"pev_euser3",
	"pev_euser4",
	"pev_edict_end",
	"pev_float_start",
	"pev_impacttime",
	"pev_starttime",
	"pev_idealpitch",
	"pev_ideal_yaw",
	"pev_pitch_speed",
	"pev_yaw_speed",
	"pev_ltime",
	"pev_nextthink",
	"pev_gravity",
	"pev_friction",
	"pev_frame",
	"pev_animtime",
	"pev_framerate",
	"pev_scale",
	"pev_renderamt",
	"pev_health",
	"pev_frags",
	"pev_takedamage",
	"pev_max_health",
	"pev_teleport_time",
	"pev_armortype",
	"pev_armorvalue",
	"pev_dmg_take",
	"pev_dmg_save",
	"pev_dmg",
	"pev_dmgtime",
	"pev_speed",
	"pev_air_finished",
	"pev_pain_finished",
	"pev_radsuit_finished",
	"pev_maxspeed",
	"pev_fov",
	"pev_flFallVelocity",
	"pev_fuser1",
	"pev_fuser2",
	"pev_fuser3",
	"pev_fuser4",
	"pev_float_end",
	"pev_int_start",
	"pev_fixangle",
	"pev_modelindex",
	"pev_viewmodel",
	"pev_weaponmodel",
	"pev_movetype",
	"pev_solid",
	"pev_skin",
	"pev_body",
	"pev_effects",
	"pev_light_level",
	"pev_sequence",
	"pev_gaitsequence",
	"pev_rendermode",
	"pev_renderfx",
	"pev_weapons",
	"pev_deadflag",
	"pev_button",
	"pev_impulse",
	"pev_spawnflags",
	"pev_flags",
	"pev_colormap",
	"pev_team",
	"pev_waterlevel",
	"pev_watertype",
	"pev_playerclass",
	"pev_weaponanim",
	"pev_pushmsec",
	"pev_bInDuck",
	"pev_flTimeStepSound",
	"pev_flSwimTime",
	"pev_flDuckTime",
	"pev_iStepLeft",
	"pev_gamestate",
	"pev_oldbuttons",
	"pev_groupinfo",
	"pev_iuser1",
	"pev_iuser2",
	"pev_iuser3",
	"pev_iuser4",
	"pev_int_end",
	"pev_byte_start",
	"pev_controller_0",
	"pev_controller_1",
	"pev_controller_2",
	"pev_controller_3",
	"pev_blending_0",
	"pev_blending_1",
	"pev_byte_end",
	"pev_bytearray_start",
	"pev_controller",
	"pev_blending",
	"pev_bytearray_end",
	"pev_vecarray_start",
	"pev_origin",
	"pev_oldorigin",
	"pev_velocity",
	"pev_basevelocity",
	"pev_clbasevelocity",
	"pev_movedir",
	"pev_angles",
	"pev_avelocity",
	"pev_v_angle",
	"pev_endpos",
	"pev_startpos",
	"pev_absmin",
	"pev_absmax",
	"pev_mins",
	"pev_maxs",
	"pev_size",
	"pev_rendercolor",
	"pev_view_ofs",
	"pev_vuser1",
	"pev_vuser2",
	"pev_vuser3",
	"pev_vuser4",
	"pev_punchangle",
	"pev_vecarray_end",
	"pev_string2_begin",
	"pev_weaponmodel2",
	"pev_viewmodel2",
	"pev_string2_end",
	"pev_edict2_start",
	"pev_pContainingEntity",
	"pev_absolute_end"
};

// Integer = 1
// Float = 2
// Vector = 3
new g_cdlist[CD_MEMBERS][2][32] = 
{
	{"CD_Origin","vector"},
	{"CD_Velocity","vector"},
	{"CD_ViewModel","integer"},
	{"CD_PunchAngle","vector"},
	{"CD_Flags","integer"},
	{"CD_WaterLevel","integer"},
	{"CD_WaterType","integer"},
	{"CD_ViewOfs","vector"},
	{"CD_Health","float"},
	{"CD_bInDuck","integer"},
	{"CD_Weapons","integer"},
	{"CD_flTimeStepSound","integer"},
	{"CD_flDuckTime","integer"},
	{"CD_flSwimTime","integer"},
	{"CD_WaterJumpTime","integer"},
	{"CD_MaxSpeed","float"},
	{"CD_FOV","float"},
	{"CD_WeaponAnim","integer"},
	{"CD_ID","integer"},
	{"CD_AmmoShells","integer"},
	{"CD_AmmoNails","integer"},
	{"CD_AmmoCells","integer"},
	{"CD_AmmoRockets","integer"},
	{"CD_flNextAttack","float"},
	{"CD_tfState","integer"},
	{"CD_PushMsec","integer"},
	{"CD_DeadFlag","integer"},
	{"CD_PhysInfo",""},
	{"CD_iUser1","integer"},
	{"CD_iUser2","integer"},
	{"CD_iUser3","integer"},
	{"CD_iUser4","integer"},
	{"CD_fUser1","float"},
	{"CD_fUser2","float"},
	{"CD_fUser3","float"},
	{"CD_fUser4","float"},
	{"CD_vUser1","vector"},
	{"CD_vUser2","vector"},
	{"CD_vUser3","vector"},
	{"CD_vUser4","vector"}
};
	

// Integer = 1
// Float = 2
// Vector = 3
new g_eslist[ES_MEMBERS][2][32] = 
{
	{"ES_EntityType","integer"},
	{"ES_Number","integer"},
	{"ES_MsgTime","float"},
	{"ES_MessageNum","integer"},
	{"ES_Origin","vector"},
	{"ES_Angles","vector"},
	{"ES_ModelIndex","integer"},
	{"ES_Sequence","integer"},
	{"ES_Frame","float"},
	{"ES_ColorMap","integer"},
	{"ES_Skin","integer"},
	{"ES_Solid","integer"},
	{"ES_Effects","integer"},
	{"ES_Scale","float"},
	{"ES_eFlags","integer"},
	{"ES_RenderMode","integer"},
	{"ES_RenderAmt","integer"},
	{"ES_RenderColor","vector"},
	{"ES_RenderFx","integer"},
	{"ES_MoveType","integer"},
	{"ES_AnimTime","float"},
	{"ES_FrameRate","float"},
	{"ES_Body","integer"},
	{"ES_Controller",""},
	{"ES_Blending",""},
	{"ES_Velocity","vector"},
	{"ES_Mins","vector"},
	{"ES_Maxs","vector"},
	{"ES_AimEnt","integer"},
	{"ES_Owner","integer"},
	{"ES_Friction","float"},
	{"ES_Gravity","float"},
	{"ES_Team","integer"},
	{"ES_PlayerClass","integer"},
	{"ES_Health","integer"},
	{"ES_Spectator","integer"},
	{"ES_WeaponModel","integer"},
	{"ES_GaitSequence","integer"},
	{"ES_BaseVelocity","vector"},
	{"ES_UseHull","integer"},
	{"ES_OldButtons","integer"},
	{"ES_OnGround","integer"},
	{"ES_iStepLeft","integer"},
	{"ES_flFallVelocity","float"},
	{"ES_FOV","float"},
	{"ES_WeaponAnim","integer"},
	{"ES_StartPos","vector"},
	{"ES_EndPos","vector"},
	{"ES_ImpactTime","float"},
	{"ES_StartTime","float"},
	{"ES_iUser1","integer"},
	{"ES_iUser2","integer"},
	{"ES_iUser3","integer"},
	{"ES_iUser4","integer"},
	{"ES_fUser1","float"},
	{"ES_fUser2","float"},
	{"ES_fUser3","float"},
	{"ES_fUser4","float"},
	{"ES_vUser1","vector"},
	{"ES_vUser2","vector"},
	{"ES_vUser3","vector"},
	{"ES_vUser4","vector"}
};

enum {ent, type, member, arg1, arg2, arg3};

new g_cdhook[MAX_LINES][6];
new g_eshook[MAX_LINES][6];
new g_pdata[MAX_LINES][200];

new g_cvarDebug;

public plugin_init() {
	register_plugin( PLUGIN, VERSION, AUTHOR );
	
	register_clcmd( "fm_pev", "test_pev" );
	register_clcmd( "fm_cd",  "test_cd" );
	register_clcmd( "fm_es",  "test_es" );
	
	register_clcmd( "fm_pdata", "test_pdata" );
	register_clcmd( "fm_pdata_search", "search_pdata" );
	register_clcmd( "fm_pdata_log", "log_pdata" );
	
	register_clcmd( "fm_getent_aiming", "getent_aiming" );
	register_clcmd( "fm_getent_class",  "getent_class"  );
	register_clcmd( "fm_getent_origin", "getent_origin" );
	
	register_clcmd( "fm_tool_bitmask", "tool_bitmask" );
	
	register_forward( FM_UpdateClientData, "hook_UpdateClientData_post", 1 );
	register_forward( FM_AddToFullPack,    "hook_AddToFullPack_post", 1 );
	
	g_cvarDebug = register_cvar( "fm_debug", "1" );
}

// fm_pev <ent> <member> <arg1> <arg2> <arg3>
public test_pev( id ) {
	
	new m_arg1[32], m_arg2[32], m_arg3[32], m_szmember[32], m_szent[16], m_ent, m_member;
	read_argv(1, m_szent, 15);
	read_argv(2, m_szmember, 31);
	read_argv(3, m_arg1, 31);
	read_argv(4, m_arg2, 31);
	read_argv(5, m_arg3, 31);
	
	// Echo Instructions
	if( read_argc() == 1 ) echo_instructions( id, "pev" );
	
	// Which Member to Test?	
	for( new i; i < PEV_MEMBERS; i++ )
	{
		// Copy it to another string and remove "pev_" (for usage convenience)
		new m_raw[32];
		copy( m_raw, 31, g_pevlist[i] );
		replace( m_raw, 31, "pev_", "" );
		
		if( equali( m_szmember, g_pevlist[i] )
			|| equali( m_szmember, m_raw ) )
			
			m_member = i;
	}
	
	// Get Target Entity codes
	if( equal( m_szent, "player" ) || equal( m_szent, "id" ) || equal( m_szent, "me" ) )
	{
		m_ent = id;
	}
	else if( equal( m_szent, "weapon" ) || equal( m_szent, "wpn" ) || equal( m_szent, "gun" ) )
	{
		m_ent = detect_weapon_id( id );
		console_print( id, "Weapon: %i", m_ent );
	}
	// Otherwise, keep it as the #
	else m_ent = str_to_num( m_szent );
	
	// Integer or Edict
	if( (pev_int_start < m_member < pev_int_end) || (pev_edict_start < m_member < pev_edict_end) )
	{
		if( !determine_reset( m_arg1 ) )
		{
			new m_set = str_to_num(m_arg1);
			set_pev( m_ent, m_member, m_set );
			console_print( id, "[Ent %i] Set %s Integer to %i", m_ent, m_szmember, m_set );
		}
		else if( determine_reset( m_arg1 ) )
		{
			new m_set;
			pev( m_ent, m_member, m_set );
			console_print( id, "[Ent %i] Get %s Integer is set to %i", m_ent, m_szmember, m_set );
		}
	}
	
	// Float
	else if( pev_float_start < m_member < pev_float_end )
	{
		if( !determine_reset( m_arg1 ) )
		{
			new Float:m_set = str_to_float(m_arg1);
			set_pev( m_ent, m_member, m_set );
			console_print( id, "[Ent %i] Set %s Float to %f", m_ent, m_szmember, m_set );
		}
		else if( determine_reset( m_arg1 ) )
		{
			new Float:m_set;
			pev( m_ent, m_member, m_set );
			console_print( id, "[Ent %i] Get %s Float is set to %f", m_ent, m_szmember, m_set );
		}
	}

	// Vector
	else if( pev_vecarray_start < m_member < pev_vecarray_end )
	{
		if( !determine_reset( m_arg1 ) )
		{
			new Float:m_set[3];
			m_set[0] = str_to_float(m_arg1);
			m_set[1] = str_to_float(m_arg2);
			m_set[2] = str_to_float(m_arg3);
			set_pev( m_ent, m_member, m_set );
			console_print( id, "[Ent %i] Set %s Vector to {%f, %f, %f}", m_ent, m_szmember, m_set[0], m_set[1], m_set[2] );
		}
		else if( determine_reset( m_arg1 ) )
		{
			new Float:m_set[3];
			pev( m_ent, m_member, m_set );
			console_print( id, "[Ent %i] Get %s Vector is set to {%f, %f, %f}", m_ent, m_szmember, m_set[0], m_set[1], m_set[2] );
		}
	}
	
	// String
	else if( (pev_string_start < m_member < pev_string_end) || (pev_string2_begin < m_member < pev_string2_end) )
	{
		if( !determine_reset( m_arg1 ) )
		{
			set_pev( m_ent, m_member, m_arg1 );
			console_print( id, "[Ent %i] Set %s String to %s", m_ent, m_szmember, m_arg1 );
		}
		else if( determine_reset( m_arg1 ) )
		{
			new m_set[128];
			pev( m_ent, m_member, m_set, 127 );
			console_print( id, "[Ent %i] Get %s String is set to %s", m_ent, m_szmember, m_set );
		}
	}
	else console_print( id, "PEV ERROR" );

	return PLUGIN_HANDLED;
}

// fm_cd <ent> <member> <arg1> <arg2> <arg3>
public test_cd( id ) {
	
	new m_arg1[16], m_arg2[16], m_arg3[16], m_szmember[32], m_szent[16], m_ent, m_member, m_type;
	read_argv(1, m_szent, 15);
	read_argv(2, m_szmember, 31);
	read_argv(3, m_arg1, 15);
	read_argv(4, m_arg2, 15);
	read_argv(5, m_arg3, 15);
	
	// Echo Instructions
	if( read_argc() == 1 ) echo_instructions( id, "cd" );
	
	// Which Member to Test?	
	for( new i; i < CD_MEMBERS; i++ )
	{
		// Copy it to another string and remove "cd_" (for usage convenience)
		new m_raw[32];
		copy( m_raw, 31, g_cdlist[i][0] );
		replace( m_raw, 31, "cd_", "" );
		
		if( equali( m_szmember, g_cdlist[i][0] )
			|| equali( m_szmember, m_raw ) )
		{
			m_member = i;
			m_type = determine_type( g_cdlist[i][1] );
			break;
		}
	}
	
	// Get Target Entity codes
	if( equal( m_szent, "player" ) || equal( m_szent, "id" ) || equal( m_szent, "me" ) )
	{
		m_ent = id;
	}
	else if( equal( m_szent, "weapon" ) || equal( m_szent, "wpn" ) || equal( m_szent, "gun" ) )
	{
		m_ent = detect_weapon_id( id );
		console_print( id, "Weapon: %i", m_ent );
	}
	// Otherwise, keep it as the #
	else m_ent = str_to_num( m_szent );
	
	// Store data in global variable to use in hook
	g_cdhook[id][ent] = m_ent;
	g_cdhook[id][type] = m_type;
	g_cdhook[id][member] = m_member;
	
	// Test if it should be read
	if( equali( m_arg1, "read" ) || equal( m_arg1, "reset" ) )
	{
		g_cdhook[id][arg1] = VALUE_READ;
		g_cdhook[id][arg2] = VALUE_READ;
		g_cdhook[id][arg3] = VALUE_READ;
	}
	else
	{
		g_cdhook[id][arg1] = str_to_num(m_arg1);
		g_cdhook[id][arg2] = str_to_num(m_arg2);
		g_cdhook[id][arg3] = str_to_num(m_arg3);
	}
	
	return PLUGIN_HANDLED;
}
		
public hook_UpdateClientData_post( entid, sendweapons, cd_handle ) {
	new id = find_id_value( entid, "cd" );
	if( !g_cdhook[id][ent] || !g_cdhook[id][type] ) return FMRES_IGNORED;
	
	// Retrieve data from global variable
	//new m_ent    = g_cdhook[id][ent];
	new m_type   = g_cdhook[id][type];
	new m_member = g_cdhook[id][member];
	new m_arg1   = g_cdhook[id][arg1];
	new m_arg2   = g_cdhook[id][arg2];
	new m_arg3   = g_cdhook[id][arg3];
	
	// Get const version of member
	new m_szmember[32];
	copy( m_szmember, 31, g_cdlist[m_member][0] );
	
	// Integer
	if( m_type == TYPE_INTEGER && m_member )
	{
		if( m_arg1 != VALUE_READ )
		{
			set_cd( cd_handle, ClientData:m_member, m_arg1 );
			if( cvar_debug() ) console_print( id, "[Ent %i] Set %s Integer to %i", entid, m_szmember, m_arg1 );
			return FMRES_HANDLED;
		}
		else
		{
			new m_get = get_cd( cd_handle, ClientData:m_member );
			console_print( id, "[Ent %i] Get %s Integer is set to %i", entid, m_szmember, m_get, m_arg1 );
		}
	}
	// Float
	else if( m_type == TYPE_FLOAT && m_member )
	{
		if( m_arg1 != VALUE_READ )
		{
			set_cd( cd_handle, ClientData:m_member, float( m_arg1 ) );
			if( cvar_debug() ) console_print( id, "[Ent %i] Set %s Float to %f", entid, m_szmember, float( m_arg1 ) );
			return FMRES_HANDLED;
		}
		else
		{
			new Float:m_get;
			get_cd( cd_handle, ClientData:m_member, m_get );
			console_print( id, "[Ent %i] Get %s Float is set to %f", entid, m_szmember, m_get, m_arg1 );
		}
	}
	// Vector
	else if( m_type == TYPE_VECTOR && m_member )
	{
		// Use "OR" (||) in case an arg is supposed to be 0
		if( m_arg1 != VALUE_READ || m_arg2 != VALUE_READ || m_arg3 != VALUE_READ )
		{
			new Float:m_set[3];
			m_set[0] = float( m_arg1 );
			m_set[1] = float( m_arg2 );
			m_set[2] = float( m_arg3 );
			set_cd( cd_handle, ClientData:m_member, m_set );
			if( cvar_debug() ) console_print( id, "[Ent %i] Set %s Vector to {%f, %f, %f}", entid, m_szmember, m_set[0], m_set[1], m_set[2] );
			return FMRES_HANDLED;
		}
		else
		{
			new Float:m_get[3];
			get_cd( cd_handle, ClientData:m_member, m_get );
			console_print( id, "[Ent %i] Get %s Vector is set to {%f, %f, %f}", entid, m_szmember, m_get[0], m_get[1], m_get[2], m_arg1, m_arg2, m_arg3 );
		}
	}
	// String
	else if( m_type == TYPE_STRING && m_member )
	{
		if( m_arg1 != VALUE_READ )
		{
			set_cd( cd_handle, ClientData:m_member, m_arg1 );
			if( cvar_debug() ) console_print( id, "[Ent %i] Set %s String to %s", entid, m_szmember, m_arg1 );
			return FMRES_HANDLED;
		}
		else
		{
			new m_get[64];
			get_cd( cd_handle, ClientData:m_member, m_get );
			console_print( id, "[Ent %i] Get %s String is set to %s", entid, m_szmember, m_get );
		}
	}
	// Only gets called if "Getting"
	// Set values to 0 so it isn't called again
	g_cdhook[id][ent] = 0;
	g_cdhook[id][type] = 0;
	g_cdhook[id][member] = 0;
	g_cdhook[id][arg1] = 0;
	g_cdhook[id][arg2] = 0;
	g_cdhook[id][arg3] = 0;
	
	return FMRES_IGNORED;
	
}

// fm_es <ent> <member> <arg1> <arg2> <arg3>
public test_es( id ) {
	
	new m_arg1[16], m_arg2[16], m_arg3[16], m_szmember[32], m_szent[16], m_ent, m_member, m_type;
	read_argv(1, m_szent, 15);
	read_argv(2, m_szmember, 31);
	read_argv(3, m_arg1, 15);
	read_argv(4, m_arg2, 15);
	read_argv(5, m_arg3, 15);
	
	// Echo Instructions
	if( read_argc() == 1 ) echo_instructions( id, "es" );
	
	// Which Member to Test?	
	for( new i; i < ES_MEMBERS; i++ )
	{
		// Copy it to another string and remove "es_" (for usage convenience)
		new m_raw[32];
		copy( m_raw, 31, g_eslist[i][0] );
		replace( m_raw, 31, "es_", "" );
		
		if( equali( m_szmember, g_eslist[i][0] )
			|| equali( m_szmember, m_raw ) )
		{
			m_member = i;
			m_type = determine_type( g_eslist[i][1] );
			break;
		}
	}
	
	// Get Target Entity codes
	if( equal( m_szent, "player" ) || equal( m_szent, "id" ) || equal( m_szent, "me" ) )
	{
		m_ent = id;
	}
	else if( equal( m_szent, "weapon" ) || equal( m_szent, "wpn" ) || equal( m_szent, "gun" ) )
	{
		m_ent = detect_weapon_id( id );
		console_print( id, "Weapon: %i", m_ent );
	}
	// Otherwise, keep it as the #
	else m_ent = str_to_num( m_szent );
	
	// Store data in global variable to use in hook
	g_eshook[id][ent] = m_ent;
	g_eshook[id][type] = m_type;
	g_eshook[id][member] = m_member;
	
	// Test if it should be read
	if( equali( m_arg1, "read" ) || equal( m_arg1, "reset" ) )
	{
		g_eshook[id][arg1] = VALUE_READ;
		g_eshook[id][arg2] = VALUE_READ;
		g_eshook[id][arg3] = VALUE_READ;
	}
	else
	{
		g_eshook[id][arg1] = str_to_num(m_arg1);
		g_eshook[id][arg2] = str_to_num(m_arg2);
		g_eshook[id][arg3] = str_to_num(m_arg3);
	}
	
	return PLUGIN_HANDLED;
}

public hook_AddToFullPack_post( es_handle, e, entid, host, hostflags, player, pSet ) {
	new id = find_id_value( entid, "es" );
	if( !g_eshook[id][ent] || !g_eshook[id][type] ) return FMRES_IGNORED;
	
	// Retrieve data from global variable
	//new m_ent    = g_eshook[id][ent];
	new m_type   = g_eshook[id][type];
	new m_member = g_eshook[id][member];
	new m_arg1   = g_eshook[id][arg1];
	new m_arg2   = g_eshook[id][arg2];
	new m_arg3   = g_eshook[id][arg3];
	
	// Get const version of member
	new m_szmember[32];
	copy( m_szmember, 31, g_eslist[m_member][0] );
	
	// Integer
	if( m_type == TYPE_INTEGER )
	{
		if( m_arg1 != VALUE_READ )
		{
			set_es( es_handle, EntityState:m_member, m_arg1 );
			if( cvar_debug() ) console_print( id, "[Ent %i] Set %s Integer to %i", entid, m_szmember, m_arg1 );
			return FMRES_HANDLED;
		}
		else
		{
			new m_get = get_es( es_handle, EntityState:m_member );
			console_print( id, "[Ent %i] Get %s Integer is set to %i", entid, m_szmember, m_get, m_arg1 );
		}
	}
	// Float
	else if( m_type == TYPE_FLOAT )
	{
		if( m_arg1 != VALUE_READ )
		{
			set_es( es_handle, EntityState:m_member, float( m_arg1 ) );
			if( cvar_debug() ) console_print( id, "[Ent %i] Set %s Float to %f", entid, m_szmember, float( m_arg1 ) );
			return FMRES_HANDLED;
		}
		else
		{
			new Float:m_get;
			get_es( es_handle, EntityState:m_member, m_get );
			console_print( id, "[Ent %i] Get %s Float is set to %f", entid, m_szmember, m_get, m_arg1 );
		}
	}
	// Vector
	else if( m_type == TYPE_VECTOR )
	{
		// Use "OR" (||) in case an arg is supposed to be 0
		if( m_arg1 != VALUE_READ || m_arg2 != VALUE_READ || m_arg3 != VALUE_READ )
		{
			new Float:m_set[3];
			m_set[0] = float( m_arg1 );
			m_set[1] = float( m_arg2 );
			m_set[2] = float( m_arg3 );
			set_es( es_handle, EntityState:m_member, m_set );
			if( cvar_debug() ) console_print( id, "[Ent %i] Set %s Vector to {%f, %f, %f}", entid, m_szmember, m_set[0], m_set[1], m_set[2] );
			return FMRES_HANDLED;
		}
		else
		{
			new Float:m_get[3];
			get_es( es_handle, EntityState:m_member, m_get );
			console_print( id, "[Ent %i] Get %s Vector is set to {%f, %f, %f}", entid, m_szmember, m_get[0], m_get[1], m_get[2], m_arg1, m_arg2, m_arg3 );
		}
	}
	// String
	else if( m_type == TYPE_STRING )
	{
		if( m_arg1 != VALUE_READ )
		{
			set_es( es_handle, EntityState:m_member, m_arg1 );
			if( cvar_debug() ) console_print( id, "[Ent %i] Set %s String to %s", entid, m_szmember, m_arg1 );
			return FMRES_HANDLED;
		}
		else
		{
			new m_get[64];
			get_es( es_handle, EntityState:m_member, m_get );
			console_print( id, "[Ent %i] Get %s String is set to %s", entid, m_szmember, m_get );
		}
	}
	// Only gets called if "Getting"
	// Set values to 0 so it isn't called again
	g_eshook[id][ent] = 0;
	g_eshook[id][type] = 0;
	g_eshook[id][member] = 0;
	g_eshook[id][arg1] = 0;
	g_eshook[id][arg2] = 0;
	g_eshook[id][arg3] = 0;
	
	return FMRES_IGNORED;
	
}


///////////////////////////////////
// Entity Get Functions
///////////////////////////////////

public getent_aiming( id ) {
	new m_iAiming[3], Float:m_flAiming[3];
	get_user_origin( id, m_iAiming, 3 );
	IVecFVec( m_iAiming, m_flAiming );
	// Find Entity
	new m_iCurEnt = -1;
	while( ( m_iCurEnt = engfunc( EngFunc_FindEntityInSphere, m_iCurEnt, m_flAiming, Float:1.0 ) ) != 0 ) {
		if( pev_valid(m_iCurEnt) )
		{
			new m_szClassname[32];
			pev( m_iCurEnt, pev_classname, m_szClassname, 31 );
			console_print( id, "[%i] Entity %s found at %i %i %i", m_iCurEnt, m_szClassname, m_flAiming[0], m_flAiming[1], m_flAiming[2] );
		}
	}
	console_print( id, "Finished logging for aim location %f %f %f", m_flAiming[0], m_flAiming[1], m_flAiming[2] );
	return PLUGIN_HANDLED;
}

public getent_class( id ) {
	new m_iCurEnt = -1, args[32], Float:m_flOrigin[3];
	read_args( args, 31 );
	while( ( m_iCurEnt = engfunc( EngFunc_FindEntityByString, m_iCurEnt, "classname", args ) ) != 0 ) {
		if( pev_valid( m_iCurEnt ) )
		{
			pev( m_iCurEnt, pev_origin, m_flOrigin );
			console_print( id, "[%i] Entity %s found at %f %f %f", m_iCurEnt, args, m_flOrigin[0], m_flOrigin[1], m_flOrigin[2] );
		}
		else console_print( id, "Invalid Entity!" );
	}
	console_print( id, "Finished logging for class %s", args );
	return PLUGIN_HANDLED;
}

public getent_origin( id ) {
	new m_iCurEnt = -1, Float:m_flOrigin[3];
	pev( id, pev_origin, m_flOrigin );
	
	while( ( m_iCurEnt = engfunc( EngFunc_FindEntityInSphere, m_iCurEnt, m_flOrigin, Float:1.0 ) ) != 0 ) {
		if( pev_valid( m_iCurEnt ) )
		{
			new m_szClassname[32];
			pev( m_iCurEnt, pev_classname, m_szClassname, 31 );
			console_print( id, "[%i] Entity %s found at %f %f %f", m_iCurEnt, m_szClassname, m_flOrigin[0], m_flOrigin[1], m_flOrigin[2] );
		}
		else console_print( id, "Invalid Entity!" );
	}
	console_print( id, "Finished logging for origin %f %f %f", m_flOrigin[0], m_flOrigin[1], m_flOrigin[2] );
	return PLUGIN_HANDLED;
}

stock detect_weapon_id( id ) {
	new m_iCurEnt = -1, m_iWpnEnt = 0, m_szWpn[32];
	
	// Get User Weapon and WpnName
	new clip, ammo, m_iWpn = get_user_weapon(id,clip,ammo);
	#if defined DAYOFDEFEAT
	xmod_get_wpnlogname( m_iWpn, m_szWpn, 31 ); // Requires DoDX Module
	format( m_szWpn, 31, "weapon_%s", m_szWpn );
	#else
	get_weaponname( m_iWpn, m_szWpn, 31 );
	#endif

	// Get User Origin
	new Float:m_flOrigin[3];
	pev( id, pev_origin, m_flOrigin );
	
	// Find Weapon
	while( ( m_iCurEnt = engfunc( EngFunc_FindEntityInSphere, m_iCurEnt, m_flOrigin, Float:1.0 ) ) != 0 ) {
		new m_szClassname[32];
		pev( m_iCurEnt, pev_classname, m_szClassname, 31 );
    
		if( equal( m_szClassname, m_szWpn ) )
			m_iWpnEnt = m_iCurEnt;
	}
	return m_iWpnEnt;
}

///////////////
//////////Pdata
///////////////

// fm_pdata_log <ent> <low> <high> <output>
public log_pdata( id ) {
	new m_pdata_szent[16], m_pdata_szlow[16], m_pdata_szhigh[16], m_pdata_szoutput[16];
	new m_pdata_low, m_pdata_high, m_pdata_ent;
	read_argv( 1, m_pdata_szent, 15 );
	read_argv( 2, m_pdata_szlow, 15 );
	read_argv( 3, m_pdata_szhigh, 15 );
	read_argv( 4, m_pdata_szoutput, 15 );
	
	// Echo Instructions
	if( read_argc() == 1 ) echo_instructions( id, "logpdata" );
	
	m_pdata_low = str_to_num( m_pdata_szlow );
	m_pdata_high = str_to_num( m_pdata_szhigh );
	
	// Get Entity
	if( equal( m_pdata_szent, "player" ) || equal( m_pdata_szent, "id" ) || equal( m_pdata_szent, "me" ) )
	{
		m_pdata_ent = id;
	}
	else if( equal( m_pdata_szent, "weapon" ) || equal( m_pdata_szent, "wpn" ) || equal( m_pdata_szent, "gun" ) )
	{
		m_pdata_ent = detect_weapon_id( id );
	}
	else m_pdata_ent = str_to_num( m_pdata_szent );
	
	static i;
	for( i = m_pdata_low; i <= m_pdata_high; i++ )
	{
		new test_sz[128], test_int = get_pdata_int( m_pdata_ent, i );
		new Float:test_fl  = get_pdata_float( m_pdata_ent, i );
		new sizes = 127
		get_pdata_string( m_pdata_ent, i, test_sz, sizes, 1, 4 );
		
		if( !test_int && !test_fl ) continue;
		
		// Log to console
		if( equal( m_pdata_szoutput, "console" ) || equal( m_pdata_szoutput, "con" ) )
		{
			console_print( id, "[Ent %i][Offset %i] Int: %i Float: %f Sz: %s", m_pdata_ent, i, test_int, test_fl, test_sz );
		}
		// Store in array
		else if( equal( m_pdata_szoutput, "store" ) || equal( m_pdata_szoutput, "save" ) )
		{
			g_pdata[id][i-m_pdata_low] = test_int;
		}
		// Compare to array
		else if( equal( m_pdata_szoutput, "compare" ) || equal( m_pdata_szoutput, "check" ) )
		{
			if( test_int == g_pdata[id][i-m_pdata_low] ) continue;
			console_print( id, "[Ent %i][Offset %i] Int: %i Float: %f -> Int: %i Float %f", m_pdata_ent, i, g_pdata[id][i-m_pdata_low], g_pdata[id][i-m_pdata_low], test_int, test_fl );
		}
		// Log to amx logs
		else
		{
			log_amx( "[Ent %i][Offset %i] Int: %i Float: %f Sz: %s", m_pdata_ent, i, test_int, test_fl, test_sz );
		}
	}
	console_print( id, "Logged [ent %i] pdata %i to %i", m_pdata_ent, m_pdata_low, m_pdata_high );
	return PLUGIN_HANDLED;
}

// fm_pdata_search <ent> <low> <high> <target>
public search_pdata( id ) {
	new m_pdata_szent[16], m_pdata_szlow[16], m_pdata_szhigh[16], m_pdata_sztarget[16];
	new m_pdata_low, m_pdata_high, m_pdata_ent, m_pdata_target;
	read_argv( 1, m_pdata_szent, 15 );
	read_argv( 2, m_pdata_szlow, 15 );
	read_argv( 3, m_pdata_szhigh, 15 );
	read_argv( 4, m_pdata_sztarget, 15 );
	
	// Echo Instructions
	if( read_argc() == 1 ) echo_instructions( id, "searchpdata" );
	
	m_pdata_low = str_to_num( m_pdata_szlow );
	m_pdata_high = str_to_num( m_pdata_szhigh );
	m_pdata_target = str_to_num( m_pdata_sztarget );
	
	// Get Entity
	if( equal( m_pdata_szent, "player" ) || equal( m_pdata_szent, "id" ) || equal( m_pdata_szent, "me" ) )
	{
		m_pdata_ent = id;
	}
	else if( equal( m_pdata_szent, "weapon" ) || equal( m_pdata_szent, "wpn" ) || equal( m_pdata_szent, "gun" ) )
	{
		m_pdata_ent = detect_weapon_id( id );
	}
	else m_pdata_ent = str_to_num( m_pdata_szent );
	
	static i;
	for( i = m_pdata_low; i <= m_pdata_high; i++ )
	{
		new test_sz[128], test_int = get_pdata_int( m_pdata_ent, i );
		new Float:test_fl  = get_pdata_float( m_pdata_ent, i );
		get_pdata_string( m_pdata_ent, i, test_sz, 127, 1 , 4 );
		
		if( m_pdata_target == test_int || m_pdata_target == test_int || equali(m_pdata_sztarget, test_sz) )
			console_print( id, "[Ent %i][Offset %i] Int: %i Float: %f Sz: %s", m_pdata_ent, i, test_int, test_fl, test_sz );
	}
	console_print( id, "Finished Searching for %i [Ent %i] pdata %i to %i", m_pdata_target, m_pdata_ent, m_pdata_low, m_pdata_high );
	return PLUGIN_HANDLED;
}

// fm_pdata <ent> <offset> <arg>
public test_pdata( id ) {
	new m_pdata_szent[16], m_pdata_szoffset[16], m_pdata_szarg[16];
	new m_pdata_ent, m_pdata_offset;
	read_argv( 1, m_pdata_szent, 15 );
	read_argv( 2, m_pdata_szoffset, 15 );
	read_argv( 3, m_pdata_szarg, 15 );
	
	// Echo Instructions
	if( read_argc() == 1 ) echo_instructions( id, "testpdata" );
	
	m_pdata_offset = str_to_num( m_pdata_szoffset );
	
	// Get Target Entity Code
	if( equal( m_pdata_szent, "player" ) || equal( m_pdata_szent, "id" ) || equal( m_pdata_szent, "me" ) )
	{
		m_pdata_ent = id;
	}
	else if( equal( m_pdata_szent, "weapon" ) || equal( m_pdata_szent, "wpn" ) || equal( m_pdata_szent, "gun" ) )
	{
		m_pdata_ent = detect_weapon_id( id );
	}
	else m_pdata_ent = str_to_num( m_pdata_szent );
	
	
	if( determine_reset( m_pdata_szarg ) )
	{
		new test_int = get_pdata_int( m_pdata_ent, m_pdata_offset );
		new Float:test_fl = get_pdata_float( m_pdata_ent, m_pdata_offset );
		console_print( id, "[Ent %i] Get Pdata Offset %i is set to Int: %i Float: %f", m_pdata_ent, m_pdata_offset, test_int, test_fl );
	}
	else if( contain( m_pdata_szarg, ".") > -1 )
	{
		new Float:m_flValue = str_to_float( m_pdata_szarg );
		set_pdata_float( m_pdata_ent, m_pdata_offset, m_flValue );
		console_print( id, "[Ent %i] Set Pdata Offset %i to Float %f", m_pdata_ent, m_pdata_offset, m_flValue );
	}
	else
	{
		new m_iValue = str_to_num( m_pdata_szarg );
		set_pdata_int( m_pdata_ent, m_pdata_offset, m_iValue );
		console_print( id, "[Ent %i] Set Pdata Offset %i to Integer %i", m_pdata_ent, m_pdata_offset, m_iValue );
	}
	
	return PLUGIN_HANDLED;
}

public tool_bitmask( id ) {
	new bitmask, bitstring[255];
	new argcount = read_argc();
	new argstring[16];
	for ( new i; i < argcount; i++ )
	{
		read_argv( i, argstring, 15 );
		bitmask |= str_to_num( argstring );
		format( bitstring, 254, "%s%i, ", bitstring, str_to_num( argstring ) );
	}
	console_print( id, "[Bitmask] %i = %s", bitmask, bitstring );
	return PLUGIN_HANDLED;
}

///
/// Stocks
///

stock determine_type( szString[] ) {
	if( equal( szString, "integer" ) ) return TYPE_INTEGER;
	else if( equal( szString, "float" ) ) return TYPE_FLOAT;
	else if( equal( szString, "vector" ) ) return TYPE_VECTOR;
	else if( equal( szString, "string" ) ) return TYPE_STRING;
	return TYPE_NONE;
}

stock send_message(id, strMsg[], printmode) {
	new players[32],pNum,strName[32];
	if( id ) get_user_name(id, strName, 31);
	get_players(players,pNum);
	for(new i=0;i<pNum;i++)
		client_print(players[i],printmode,"%s %s", strName, strMsg);
}

echo_instructions( id, szSet[] ) {
	if( equal( szSet, "pev" ) )
	{
		console_print( id, "TO READ: fm_pev <ent> <member> read" );
		console_print( id, "TO SET: fm_pev <ent> <member> <arg1> <arg2> <arg3>" );
	}
	else if( equal( szSet, "cd" ) )
	{
		console_print( id, "TO READ: fm_cd <ent> <member> read" );
		console_print( id, "TO SET: fm_cd <ent> <member> <arg1> <arg2> <arg3>" );
	}
	else if( equal( szSet, "es" ) )
	{
		console_print( id, "TO READ: fm_cd <ent> <member> read" );
		console_print( id, "TO SET: fm_cd <ent> <member> <arg1> <arg2> <arg3>" );
	}
	else if( equal( szSet, "logpdata" ) )
	{
		console_print( id, "TO LOG: fm_pdata_log <ent> <low> <high>" );
		console_print( id, "TO READ: fm_pdata_log <ent> <low> <high> console" );
		console_print( id, "TO STORE: fm_pdata_log <ent> <low> <high> store" );
		console_print( id, "TO COMPARE: fm_pdata_log <ent> <low> <high> compare" );
	}
	else if( equal( szSet, "searchpdata" ) )
	{
		console_print( id, "TO SEARCH: fm_pdata_search <ent> <low> <high> <target>" );
	}
	else if( equal( szSet, "testpdata" ) )
	{
		console_print( id, "TO READ: fm_pdata <ent> <offset> read" );
		console_print( id, "TO SET: fm_pdata <ent> <offset> <arg>" );
	}
}

find_id_value( entid, set[8] ) {
	new id;
	if( equal( set, "cd" ) )
	{
		for( new i; i < MAX_LINES; i++ )
		{
			if( g_cdhook[i][ent] == entid )
				id = i;
		}
	}
	else if( equal( set, "es" ) )
	{
		for( new i; i < MAX_LINES; i++ )
		{
			if( g_eshook[i][ent] == entid )
				id = i;
		}
	}
	return id;
}

determine_reset( szString[] ) {
	if( equali( szString, "read" ) || equali( szString, "reset" ) )
		return true;
	return false;
}

stock cvar_debug() {
	return get_pcvar_num( g_cvarDebug );
}
		
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1049\\ f0\\ fs16 \n\\ par }
*/
