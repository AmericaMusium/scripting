/*
	To Do:
	-Add max ammo
*/

#include <amxmodx>
#include <amxmisc>
#include <dodx>
#include <dodfun>
#include <dod_stocks>
#include <fakemeta>
#include <fakemeta_util>
#include <fun>
#include <hamsandwich>

#pragma semicolon 1

#define PLUGIN "Shotgun Class"
#define VERSION "1.0"
#define AUTHOR "29th.org"

#define OFFSET_WPNID	91
#define OFFSET_CLIPAMMO 108
#define OFFSET_CLASS	366
#define OFFSET_RCLASS	367
#define OFFSET_SMGAMMO	56
#define OFFSET_LINUX	4
#define COCK_TASK	2929
#define PEV_KEY 	pev_iuser3
#define HUD_WPN		DODW_KAR
#define HUD_AMMOCHAN	AMMO_RIFLE

#define WPN_ROF		1.0
#define WPN_RECOIL	10.0
#define WPN_CLIPAMMO	5
#define WPN_BPAMMO	30
#define WPN_AMMOBOXINC	5
#define WPN_MAXAMMO	WPN_BPAMMO + (WPN_CLIPAMMO * 2)
#define WPN_COCKDELAY	0.5
#define WPN_BULLETDECAL	10

#define WPN_PELLETS	8
#define WPN_DAMAGE	28.0
#define WPN_RANGE	2048.0
#define WPN_SPREAD_P	6.0 // Pitch
#define WPN_SPREAD_Y	6.0 // Yaw

#define SEQ_FIRE	72
#define SEQ_FIRE_FR	50
#define SEQ_RELOAD	260
#define SEQ_RELOAD_FR	13

// Customisation
#define CLASS_AMER	DODC_BAR
#define CLASS_BRIT	DODC_BREN
#define CLASS_AXIS	DODC_MP44
#define WEAP_AMER	DODW_BAR
#define WEAP_BRIT	DODW_BREN
#define WEAP_AXIS	DODW_STG44


new g_msgCurWeapon, g_msgRoundState, g_msgAmmoX;
new bool:g_isClass[33], bool:g_holding[33], Float:g_nextShot[33];
new bool:g_roundlive;
new p_enabled, p_limitamer, p_limitbrit, p_limitaxis;

enum anim   { sequence, frame };
new g_anim[ 33 ][ anim ];

enum decals { DECAL_SHOT1 = 48, DECAL_SHOT2, DECAL_SHOT3, DECAL_SHOT4, DECAL_SHOT5 };
enum wpnseq { idle, insert, draw, fire1, fire2, empty_idle, start_reload, after_reload };

enum plseq  { plnull, plfire, plreload };
new  g_plseq[ plseq ][ anim ] = 
{
	{ 0, 0 },
	{ SEQ_FIRE, 	SEQ_FIRE_FR },
	{ SEQ_RELOAD,	SEQ_RELOAD_FR }
};
enum names 
{
	// Weapon Models
	v_specialwpn,
	p_specialwpn,
	w_specialwpn,
	
	// Dummy Weapon Entities
	weapon_amer,
	weapon_brit,
	weapon_axis,
	
	// Ammo Entities
	ammo_american,
	ammo_british,
	ammo_german,
	
	// Dummy Weapon Models
	w_amer,
	w_brit,
	w_axis,
	
	// Other Entities
	player_entity,
	beam_sprite,
	
	// Sounds
	wpn_fire,
	wpn_cock,
	wpn_reload,
	wpn_empty,
	blank_sound,
	ammo_pickup,
	
	// Class Commands
	cls_amer,
	cls_brit,
	cls_axis,
	
	// Class-Limit Cvars
	limit_amer,
	limit_brit,
	limit_axis
};
new strings[ names ][ 64 ] = 
{
	"models/v_trenchshotgun2.mdl",
	"models/p_trenchshotgun2.mdl",
	"models/w_trenchshotgun.mdl",
	"weapon_bar",
	"weapon_bren",
	"weapon_mp44",
	"ammo_generic_american",
	"ammo_generic_british",
	"ammo_generic_german",
	"models/w_bar.mdl",
	"models/w_bren.mdl",
	"models/w_mp44.mdl",
	"player",
	"sprites/aplayer.spr",
	"weapons/avamods_shotgun_fire.wav",
	"weapons/avamods_shotgun_cock.wav",
	"weapons/avamods_shotgun_load.wav",
	"weapons/avamods_shotgun_load.wav",
	"weapons/avamods_shotgun_load.wav",
	"items/ammopickup.wav",
	"cls_bar",
	"cls_bren",
	"cls_mp44",
	"mp_limitalliesbar",
	"mp_limitbritmg",
	"mp_limitaxismp44"
};

new p_beamlife, beam, p_spread, p_cofmoving, p_dist, p_tracers, p_wall, p_wpn_pellets, p_wpn_damage, p_cof;

public plugin_init() 
{
	register_plugin( PLUGIN, VERSION, AUTHOR );
	
	g_msgCurWeapon 	= get_user_msgid( "CurWeapon" );
	g_msgRoundState	= get_user_msgid( "RoundState" );
	g_msgAmmoX	= get_user_msgid( "AmmoX" );
	p_enabled	= register_cvar( "dod_shotgun",	"1" );
	p_beamlife	= register_cvar( "p_beamlife",	"50" );
	p_spread	= register_cvar( "p_spread",	"8" );
	p_cofmoving	= register_cvar( "p_cofmoving","10" );
	p_dist		= register_cvar( "p_dist",	"1500" );
	p_tracers	= register_cvar( "p_tracers",	"0" );
	p_wall		= register_cvar( "p_wall",	"11" );
	p_wpn_pellets = register_cvar( "p_pellets", "30" );
	p_wpn_damage = register_cvar( "p_damage", "17" );
	p_cof 		= register_cvar( "p_cof", "6" );
	p_limitamer	= get_cvar_pointer( strings[limit_amer] );
	p_limitbrit	= get_cvar_pointer( strings[limit_brit] );
	p_limitaxis	= get_cvar_pointer( strings[limit_axis] );
	
	
	register_message( g_msgCurWeapon,	"fwd_CurWeapon" );
	register_message( g_msgRoundState,	"fwd_RoundState" );
	
	register_forward( FM_UpdateClientData,	"fwd_UpdateClientData_Post", 1 );
	register_forward( FM_AddToFullPack,	"fwd_AddToFullPack_Post", 1 );
	register_forward( FM_CmdStart, 		"fwd_CmdStart" );
	register_forward( FM_Touch, 		"fwd_Touch" );
	register_forward( FM_SetModel,		"fwd_SetModel" );
	
	RegisterHam( Ham_Weapon_Reload, 	strings[weapon_amer], "fwd_Reload" );
	RegisterHam( Ham_Weapon_Reload, 	strings[weapon_brit], "fwd_Reload" );
	RegisterHam( Ham_Weapon_Reload, 	strings[weapon_axis], "fwd_Reload" );
	
	register_clcmd( "cls_shotgun",	 	"clcmd_set_class" );
	register_clcmd( strings[cls_amer],	"clcmd_class_menu" );
	register_clcmd( strings[cls_brit],	"clcmd_class_menu" );
	register_clcmd( strings[cls_axis],	"clcmd_class_menu" );
	
}

public plugin_precache() 
{
	
	
	precache_model( "models/v_trenchshotgun2.mdl" );
	precache_model( "models/p_trenchshotgun2.mdl" );
	precache_model( "models/w_trenchshotgun.mdl" );
	
	precache_sound( strings[wpn_fire] );
	precache_sound( strings[wpn_cock] );
	precache_sound( strings[wpn_reload] );
	precache_sound( strings[blank_sound] );
	precache_sound( strings[ammo_pickup] );
	
	beam = precache_model( strings[beam_sprite] );
	
}

public client_connect( id ) 
{
	g_isClass[id]	= false;
	g_holding[id] 	= false;
	g_nextShot[id] 	= 0.0;
	g_anim[id][sequence]	= 0;
	g_anim[id][frame]	= 0;
}

public fwd_CurWeapon( msgid, msgdest, id ) 
{
	if( plugin_enabled() )
	{
		new wpnactive 	= get_msg_arg_int( 1 );
		new wpnid	= get_msg_arg_int( 2 );
		
		if( wpnactive && has_specialwpn(id, wpnid) )
		{
			// Alter Ammo Sprite
			set_msg_arg_int( 2, ARG_BYTE, HUD_WPN );
		}
	}
}

public dod_client_weaponswitch( id, wpnnew, wpnold ) 
{
	if( plugin_enabled() )
	{
		
		if( has_specialwpn(id, wpnnew) )
		{
			static curModel[32];
			pev( id, pev_viewmodel2, curModel, 31 );
			
			if( !equal(curModel, strings[v_specialwpn]) )
			{
				set_visuals( id );
			}
			
			// In case client drops weapon
			g_holding[id] = true;
			
			// Play draw animation and restrict firing until it's done
			set_weaponanim( id, wpnseq:draw );
			g_nextShot[id] = get_gametime() + WPN_ROF + Float:0.1;
		}
		// If switching from flamethrower to another weapon
		else if( has_specialwpn(id, wpnold) )
		{
			g_holding[id] = false;
		}
	}
}

// Replace & Block special weapon dummies from automatically reloading
public fwd_Reload( wpnent ) 
{
	if( plugin_enabled() )
	{
		new owner = pev( wpnent, pev_owner );
		if( is_specialwpn(wpnent) )
		{
			reload( owner );
			return HAM_SUPERCEDE;
		}
	}
	return HAM_IGNORED;
}

public fwd_RoundState( msgid, msgdest, id ) 
{
	if( plugin_enabled() )
	{
		new arg = get_msg_arg_int( 1 );
		if( arg == 1 ) // Round starting
		{
			g_roundlive = true;
		}
		else if( arg == 3 || arg == 4 ) // Allies / Axis win
		{
			g_roundlive = false;
		}
	}
}

public fwd_UpdateClientData_Post( id, sendweapons, cd_handle ) 
{
	if( plugin_enabled() )
	{
		if( is_user_alive(id) && has_specialwpn(id, get_user_weapon(id)) )//g_holding[id] )
		{
			set_cd( cd_handle, CD_flNextAttack, get_gametime() + 0.001 );
		}
	}
}

public fwd_AddToFullPack_Post( es_handle, e, entid, host, hostflags, player, pSet ) 
{
	if( plugin_enabled() )
	{
		if( player && is_user_alive(e) && g_holding[e] )
		{
			new playseq = g_anim[e][ sequence ];
			
			if( playseq )
			{
				new seq 	= g_plseq[ plseq:playseq ][ sequence ];
				new maxframes	= g_plseq[ plseq:playseq ][ frame ];
				new curframe	= g_anim[e][ frame ];
				
				if( curframe <= maxframes )
				{
					set_es( es_handle, ES_Sequence, seq );
					set_es( es_handle, ES_Frame, float(curframe) );
					g_anim[e][ frame ]++;
				}
				else
				{
					g_anim[e][ sequence ] = 0;
				}
			}
		}
	}
}

public fwd_CmdStart( id, uc_handle, seed ) 
{
	if( plugin_enabled() )
	{
		if( is_user_alive(id) && has_specialwpn(id, get_user_weapon(id)) )
		{
			static buttons, newbuttons;
			buttons = get_uc( uc_handle, UC_Buttons );
			newbuttons = buttons;
			
			if( (buttons & IN_ATTACK) )
			{
				newbuttons &= ~IN_ATTACK;
				new Float:gtime = get_gametime();
				
				if( g_roundlive && can_fire(id) )
				{					
					if( g_nextShot[id] <= gtime )
					{
						fire( id );
						g_nextShot[id] = gtime + WPN_ROF;
					}
				}
				else if( g_roundlive ) // Out of clip ammo
				{
					if( g_nextShot[id] <= gtime )
					{
						empty_sound( id );
						g_nextShot[id] = gtime + WPN_ROF;
					}
				}
			}
			
			if( buttons & IN_ATTACK2 )
			{
				newbuttons &= ~IN_ATTACK2;
			}
			
			if( buttons != newbuttons )
			{
				set_uc( uc_handle, UC_Buttons, newbuttons );
				return FMRES_SUPERCEDE;
			}
		}
	}
	return FMRES_IGNORED;
}

public fwd_Touch( ptd, ptr ) 
{
	if( plugin_enabled() )
	{
		if( pev_valid(ptd) && is_user_alive(ptr) )
		{
			new wpnid = get_user_weapon( ptr );
			if( has_specialwpn(ptr, wpnid ) )
			{
				new owner = pev( ptd, pev_owner );
				new team = get_user_team( ptr );
				
				static ptd_classname[32];
				pev( ptd, pev_classname, ptd_classname, 31 );
				
				if( owner != ptr )
				{
					if( (team == ALLIES && !dod_is_map_british() && equal(ptd_classname, strings[ammo_american]))
					||  (team == ALLIES && equal(ptd_classname, strings[ammo_british]))
					||  (team == AXIS   && equal(ptd_classname, strings[ammo_german])) )
					{
						new bpammo 	= bp_ammo( ptr );
						new newammo	= bpammo + WPN_AMMOBOXINC;
						if( bpammo < WPN_MAXAMMO )
						{
							// Set Ammo
							bp_ammo( ptr, newammo <= WPN_MAXAMMO ? newammo : WPN_MAXAMMO );
							emit_sound( ptd, CHAN_ITEM, strings[ammo_pickup], 0.8, ATTN_NORM, 0, PITCH_NORM );
							
							// Ensure that it doesn't get picked up again
							set_pev( ptd, pev_solid, SOLID_NOT );
							set_pev( ptd, pev_flags, FL_KILLME );
							
						}
						// Ensure that the dummy weapon's ammo is not increased
						return FMRES_SUPERCEDE;
					}
				}
			}
		}
	}
	return FMRES_IGNORED;
}

public fwd_SetModel( ent, const model[] ) 
{
	if( plugin_enabled() )
	{
		new owner = pev( ent, pev_owner );
		if( pev_valid(ent) && (owner && g_holding[owner])
		&& (equal(model, strings[w_amer]) || equal(model, strings[w_brit]) || equal(model, strings[w_axis])) )
		{
			engfunc( EngFunc_SetModel, ent, strings[w_specialwpn] );
			return FMRES_SUPERCEDE;
		}
	}
	return FMRES_IGNORED;
}

public clcmd_set_class( id ) 
{
	if( plugin_enabled() )
	{
		set_class( id );
		client_print( id, print_chat, "*You will respawn as Shotgun" );
		return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE;
}

public dod_player_spawn( id ) 
{
	if( plugin_enabled() )
	{
		if( is_class(id) )
		{
			// Set his weapon to special
			g_holding[id] = true;
			has_specialwpn( id, _, 1 );
			set_visuals( id );
			
			// Set Ammo
			clip_ammo( id, WPN_CLIPAMMO );
			bp_ammo( id, WPN_BPAMMO );
			alter_hud_ammo( id );
			
			// Reset Global Variables
			g_nextShot[id] 		= 0.0;
			g_anim[id][sequence]	= 0;
			g_anim[id][frame]	= 0;
		}
		else
		{
			g_holding[id] = false;
		}
	}
}

public dod_client_changeclass( id, class, oldclass ) 
{
	if( plugin_enabled() )
	{
		if( g_isClass[id] )
		{
			// If new class is not dummy for special
			if( class != CLASS_AMER && class != CLASS_BRIT && class != CLASS_AXIS )
			{
				set_class( id, 0 );
			}
		}
	}
}

public clcmd_class_menu( id ) 
{
	if( plugin_enabled() )
	{
		if( class_allowed(id) )
		{
			new menu = menu_create( "Support Classes", "menu_handler" );
			menu_additem( menu, "BAR Class" );
			menu_additem( menu, "Shotgun Class" );
			menu_display( id, menu );
		}
	}
}

public menu_handler( id, menu, item ) 
{
	if( item == 0 )
	{
		set_class( id, 0 );
	}
	if( item == 1 )
	{
		set_class( id );
		client_print( id, print_chat, "*You will respawn as Shotgun" );
	}
}

public fire( id ) 
{
	// Stop reloading
	if( task_exists(id) )	remove_task( id );
	if( task_exists(id+COCK_TASK) )
	{
		remove_task( id+COCK_TASK );
		reload_done_cock( id+COCK_TASK );
		return PLUGIN_CONTINUE;
	}
	
	// Play firing sound
	emit_sound( id, CHAN_WEAPON, strings[wpn_fire], 0.8, ATTN_NORM, 0, PITCH_NORM );
	if( clip_ammo(id) - 1 )	set_task( WPN_COCKDELAY, "cock_sound", id );

	// Visual Effects
	set_playeranim( id, plseq:plfire );
	set_weaponanim( id, wpnseq:fire1 );
	create_recoil( id, WPN_RECOIL );
	muzzle_flash( id );
	
	// Decrease Ammo
	clip_ammo( id, _, -1 );
	
	// Get COF Offset
	new Float:offset[3], Float:cof = get_pcvar_float(p_cof);
	pev( id, pev_v_angle, offset );
	
	// If moving, use the moving cof
	new Float:velocity[3];
	pev( id, pev_velocity, velocity );
	if( velocity[0] || velocity[1] || velocity[2] )
	{
		cof = get_pcvar_float( p_cofmoving );
	}
	
	offset[0] += random_float( cof, (cof * -1.0) );
	offset[1] += random_float( cof, (cof * -1.0) );
	
	// Tracelines
	for( new i; i < get_pcvar_num(p_wpn_pellets); i++ )
	{
		shoot_pellet( id, offset );
	}
	
	return PLUGIN_CONTINUE;
}

public shoot_pellet( id, Float:offset[3] ) {
	new Float:start[3], Float:view_ofs[3];
	pev( id, pev_origin, start );
	pev( id, pev_view_ofs, view_ofs );
	xs_vec_add( start, view_ofs, start );
	
	new Float:dest[3];
	xs_vec_copy( offset, dest );
	//pev( id, pev_v_angle, dest );
	
	new Float:spread 	= get_pcvar_float( p_spread );
	new Float:distance	= get_pcvar_float( p_dist );
	
	dest[0] += random_float( spread, (spread * -1.0) );
	dest[1] += random_float( spread, (spread * -1.0) );
	
	engfunc( EngFunc_MakeVectors, dest );
	new Float:fwd[3];
	global_get( glb_v_forward, fwd );
	xs_vec_mul_scalar( fwd, distance, dest );
	xs_vec_add( start, dest, dest );
	
	new Float:end[3];
	traceline( start, dest, id, end );
	
	if( !xs_vec_equal(dest, end) )
	{
		new Float:newstart[3];
		xs_vec_mul_scalar( fwd, get_pcvar_float(p_wall), newstart );
		xs_vec_add( end, newstart, newstart );
		
		if( fm_point_contents(newstart) == CONTENTS_EMPTY )
			traceline( newstart, dest, id );		
	}
}

public traceline( Float:start[3], Float:dest[3], id, Float:end[3]={0.0,0.0,0.0} ) 
{
	engfunc( EngFunc_TraceLine, start, dest, 0, id, 0 );
	
	new ent = get_tr2( 0, TR_pHit );
	
	get_tr2( 0, TR_vecEndPos, end );
	bullet_decal( end );
	
	// Coloured tracers
	if( get_pcvar_num(p_tracers) )
		tracer( start, end );
		
	if( pev_valid(ent) )
	{
		ExecuteHam( Ham_TakeDamage, ent, 0, id, get_pcvar_float(p_wpn_damage), DMG_BULLET );
	}
}

public tracer( Float:fStart[3], Float:fEnd[3] ) 
{
	new start[3], end[3];
	FVecIVec( fStart, start );
	FVecIVec( fEnd, end );
	
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte ( TE_BEAMPOINTS );
	write_coord( start[0] );
	write_coord( start[1] );
	write_coord( start[2] );
	write_coord( end[0] );
	write_coord( end[1] );
	write_coord( end[2] );
	write_short( beam );
	write_byte ( 0 );
	write_byte ( 0 );
	write_byte ( get_pcvar_num(p_beamlife) );
	write_byte ( 10 ); 
	write_byte ( 0 ); 
	write_byte ( random(255) );
	write_byte ( random(255) );
	write_byte ( random(255) );
	write_byte ( 200 );
	write_byte ( 10 );
	message_end();
}

public reload( id ) 
{
	if( !task_exists(id) )
	{
		new clipammo	= clip_ammo( id );
		new bpammo	= bp_ammo( id );
		new slots	= WPN_CLIPAMMO - clipammo;
		
		// Ensure that the ammo being loaded exists in the user's backpack
		if( slots > bpammo ) slots = bpammo;
		
		if( slots )
		{
			set_weaponanim( id, wpnseq:start_reload );
			set_task( WPN_COCKDELAY, "insert_round", id, _, _, "a", slots );
			
			// If reloaded while empty, cock it afterward
			if( !clipammo )
			{
				set_task( WPN_COCKDELAY * float(slots + 1), "reload_done_cock", id + COCK_TASK );
				//g_nextShot[id] = get_gametime() + (WPN_COCKDELAY * float(slots + 1)) + WPN_ROF;
			}
			else
			{
				set_task( WPN_COCKDELAY * float(slots + 1), "reload_done", id );
			}
		}
	}
}

public insert_round( id ) 
{
	clip_ammo( id, _, 1 );
	bp_ammo( id, _, -1 );
	set_playeranim( id, plseq:plreload );
	set_weaponanim( id, wpnseq:insert );
	emit_sound( id, CHAN_AUTO, strings[wpn_reload], 0.8, ATTN_NORM, 0, PITCH_NORM );
}

public reload_done( id ) {
	set_weaponanim( id, wpnseq:idle );
}

public reload_done_cock( id ) {
	id -= COCK_TASK;
	set_weaponanim( id, wpnseq:after_reload );
	g_nextShot[id] = get_gametime() + WPN_ROF;
}

public cock_sound( id ) 
{
	emit_sound( id, CHAN_AUTO, strings[wpn_cock], 0.8, ATTN_NORM, 0, PITCH_NORM );
}

public empty_sound( id ) 
{
	client_cmd( id, "spk %s", strings[wpn_empty] );
}

public can_fire( id ) 
{
	new waterlevel = pev(id, pev_waterlevel);
	return ( clip_ammo( id ) > 0 && waterlevel <= 2 );
}

public has_specialwpn( id, wpnid=0, set=-1 ) 
{
	if( !wpnid )
	{
		new team = get_user_team( id );
		
		if( team == ALLIES && !dod_is_map_british() )
			wpnid = WEAP_AMER;
		else if( team == ALLIES )
			wpnid = WEAP_BRIT;
		else
			wpnid = DODW_STG44;
	}
	else
	{
		if( wpnid != WEAP_AMER && wpnid != WEAP_BRIT && wpnid != WEAP_AXIS )
			return 0;
	}
	
	new wpnent = dod_get_weapon_ent_by_owner( id, wpnid );
	
	if( wpnent && set > -1 )
		set_pev( wpnent, PEV_KEY, set );
	
	return wpnent ? pev( wpnent, PEV_KEY ) : 0;
}

is_specialwpn( wpnent ) 
{
	static classname[32];
	pev( wpnent, pev_classname, classname, 31 );
	
	if( equal(classname, strings[weapon_amer]) || equal(classname, strings[weapon_brit]) || equal(classname, strings[weapon_axis]) )
		return pev( wpnent, PEV_KEY );
		
	return 0;
}

set_class( id, set=1 ) 
{
	if( set )
	{
		g_isClass[ id ] = true;
		
		new class, team = get_user_team( id );
		
		if( team == ALLIES && !dod_is_map_british() )
			class = CLASS_AMER;
		else if( team == ALLIES )
			class = CLASS_BRIT;
		else
			class = CLASS_AXIS;
			
		set_pdata_int( id, OFFSET_CLASS, class, OFFSET_LINUX );
		set_pdata_int( id, OFFSET_RCLASS, 0, OFFSET_LINUX ); // Make sure not on Random class
	}
	else
	{
		g_isClass[ id ] = false;
	}
}

is_class( id ) 
{
	new class = dod_get_user_class( id );
	
	if( g_isClass[id] &&
		(class == CLASS_AMER || class == CLASS_BRIT || class == CLASS_AXIS) )
		return 1;
		
	return 0;
}

set_visuals( id ) 
{
	set_pev( id, pev_viewmodel2, strings[v_specialwpn] );
	set_pev( id, pev_weaponmodel2, strings[p_specialwpn] );
}

public alter_hud_ammo( id ) 
{
	message_begin( MSG_ONE, g_msgCurWeapon, _, id );
	write_byte( 1 );
	write_byte( HUD_WPN );
	write_byte( 0 );
	message_end();
	
}

set_weaponanim( id, seq ) 
{
	set_pev( id, pev_weaponanim, seq );
	message_begin( MSG_ONE, SVC_WEAPONANIM, _, id );
	write_byte( seq );
	write_byte( pev(id, pev_body) );
	message_end();
}

set_playeranim( id, seq ) 
{
	g_anim[id][sequence] 	= seq;
	g_anim[id][frame]	= 0;
}

muzzle_flash( id ) {
	set_pev( id, pev_effects, pev(id, pev_effects) | EF_MUZZLEFLASH );
}

bullet_decal( Float:fOrigin[3] ) 
{
	new origin[3];
	FVecIVec( fOrigin, origin );

	message_begin( MSG_BROADCAST, SVC_TEMPENTITY, origin );
	write_byte ( TE_WORLDDECAL );
	write_coord( origin[0] );
	write_coord( origin[1] );
	write_coord( origin[2] );
	write_byte ( WPN_BULLETDECAL );
	message_end();
}

class_allowed( id ) 
{
	new team, class, limit = 0;
	team = get_user_team( id );
	
	if( team == ALLIES && !dod_is_map_british() )
	{
		class = CLASS_AMER;
		limit = get_pcvar_num( p_limitamer );
	}
	else if( team == ALLIES )
	{
		class = CLASS_BRIT;
		limit = get_pcvar_num( p_limitbrit );
	}
	else
	{
		class = CLASS_AXIS;
		limit = get_pcvar_num( p_limitaxis );
	}

	new pClass, classmembers = 0;
	for( new i=1; i<=get_maxplayers(); i++ )
	{
		if( is_user_connected(i) )
		{
			pClass = dod_get_user_class( i );
			if( class == pClass )
				classmembers++;
		}
	}
	
	if( limit > classmembers || limit == -1 || dod_get_user_class(id) == class )
		return 1;
		
	return 0;
}

// Created by potatis_invalido
stock create_recoil( id, Float:recoil ) 
{
	new Float:angles[3];
	pev(id, pev_v_angle, angles);
	 
	angles[0] -= random_float(recoil * 1.2, recoil * 0.8);
	if(angles[0] < -88.994750)
	{
		angles[0] = -88.994750;
	}
	else if(angles[0] > 88.994750)
	{
		angles[0] = 88.994750;
	}
	 
	angles[1] += random_float(recoil * 0.35, recoil * -0.35);
	if(angles[1] > 180.0)
	{
		angles[1] -= 360.0;
	}
	else if(angles[1] < -180.0)
	{
		angles[1] += 360.0;
	}
	set_pev(id, pev_angles, angles);
	set_pev(id, pev_fixangle, 1);
}

stock clip_ammo( id, set=-1, diff=0 ) 
{
	new wpnent = dod_get_weapon_ent_by_owner( id, get_user_weapon(id) );
	new ammo = get_pdata_int( wpnent, OFFSET_CLIPAMMO, OFFSET_LINUX );
	
	if( set > -1 )
	{
		ammo = set;
		set_pdata_int( wpnent, OFFSET_CLIPAMMO, ammo, OFFSET_LINUX );
	}
	if( diff != 0 )
	{
		ammo += diff;
		set_pdata_int( wpnent, OFFSET_CLIPAMMO, ammo, OFFSET_LINUX );
	}
	return ammo;
}

stock bp_ammo( id, set=-1, diff=0 ) 
{
	new wpnid = get_user_weapon( id );
	new channel = HUD_AMMOCHAN;
	new ammo = dod_get_user_ammo( id, wpnid );
	
	if( set > -1 )
	{
		ammo = set;
		dod_set_user_ammo( id, wpnid, ammo );
		
		// Update user's HUD with new ammo
		message_begin( MSG_ONE, g_msgAmmoX, _, id );
		write_byte( channel );
		write_byte( ammo * 5 );
		message_end();
	}
	if( diff != 0 )
	{
		ammo += diff;
		dod_set_user_ammo( id, wpnid, ammo );
		
		// Update user's HUD with new ammo
		message_begin( MSG_ONE, g_msgAmmoX, _, id );
		write_byte( channel );
		write_byte( ammo * 5 );
		message_end();
	}
	return ammo;
}

// Taken from WeaponMod
stock get_startpos( id, forw, right, up, Float:vSrc[3] ) 
{
	new Float:vOrigin[3], Float:vAngle[3];
	
	pev( id, pev_origin, vOrigin );
	pev( id, pev_v_angle, vAngle );
	engfunc( EngFunc_MakeVectors, vAngle );
	
	new Float:vForward[3], Float:vRight[3], Float:vUp[3];
	
	global_get( glb_v_forward, vForward );
	global_get( glb_v_right, vRight );
	global_get( glb_v_up, vUp );
	
	vSrc[0] = vOrigin[0] + vForward[0] * forw + vRight[0] * right + vUp[0] * up;
	vSrc[1] = vOrigin[1] + vForward[1] * forw + vRight[1] * right + vUp[1] * up;
	vSrc[2] = vOrigin[2] + vForward[2] * forw + vRight[2] * right + vUp[2] * up;
}

stock dod_get_weapon_ent_by_owner( id, wpnid ) 
{
	new wpnname;
	switch( wpnid )
	{
		case WEAP_AMER: 	wpnname = weapon_amer;
		case WEAP_BRIT:		wpnname = weapon_brit;
		case WEAP_AXIS:		wpnname = weapon_axis;
		default:		return 0;
	}
	return fm_find_ent_by_owner( 0, strings[names:wpnname], id );
}

stock plugin_enabled() return get_pcvar_num( p_enabled );
