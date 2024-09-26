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

#pragma semicolon 1

#define PLUGIN "Flamethrower Class"
#define VERSION "1.0"
#define AUTHOR "29th.org"

#define OFFSET_WPNID	91
#define OFFSET_CLIPAMMO 108
#define OFFSET_CLASS	366
#define OFFSET_RCLASS	367
#define OFFSET_SMGAMMO	56
#define OFFSET_LINUX	4
#define PEV_FLAMETHROWER pev_iuser3
#define SEQ_FIRE	77
#define HUD_WPN		7

#define AMMO_DEFAULT	30
#define AMMOBOX_INC	30
#define AMMO_MAX	120
#define EXPL_TRIGGER	55.0
#define EXPL_DAMAGE	200.0
#define EXPL_RADIUS	300.0
#define FLAME_SPEED	1200
#define FLAME_SPRSPEED	90
#define FLAME_RADIUS	8.0
#define FLAME_FRAMES	8.0
#define FLAME_LIFE	0.4
#define FLAME_ROF	0.1
#define FLAME_DMG	Float:25.0
#define FLAME_MINS	Float:{-4.0, -4.0, -4.0}
#define FLAME_MAXS	Float:{4.0, 4.0, 4.0}
#define BURN_DELAY	Float:2.0
#define ANI_SPEED	1.0
#define SCORCH_INDEX	60
#define BODY_NOGEAR	4089
#define FIRE_MESSAGE	"You are on fire! Sprint Away!"

new g_msgCurWeapon, g_msgScreenFade, g_msgScreenShake, g_msgRoundState, g_msgAmmoX;
new bool:g_isClass[33], bool:g_holding[33], bool:g_firing[33], Float:g_nextShot[33];
new bool:g_roundlive;
new p_enabled, p_ammo, p_limitbazooka, p_limitpiat, p_limitpschreck;
new firesprite, explosionsprite;

// Temporary
new p_stamina;

enum names 
{
	v_flamethrower,
	p_flamethrower,
	w_flamethrower,
	w_bazooka,
	w_piat,
	w_pschreck,
	blank_sound,
	explosion_sound,
	flame_fire,
	flame_off,
	flame_burning,
	flame_sprite,
	explosion_sprite,
	flame_entity,
	player_entity,
	water_entity,
	weapon_bazooka,
	weapon_piat,
	weapon_pschreck,
	ammo_american,
	ammo_british,
	ammo_german,
	ammo_pickup
};
new strings[ names ][ 64 ] = 
{
	"models/v_flamethrower.mdl",
	"models/p_flamethrower1.mdl",
	"models/w_flamethrower1.mdl",
	"models/w_bazooka.mdl",
	"models/w_piat.mdl",
	"models/w_pschreck.mdl",
	"vox/_period.wav",
	"weapons/explode4.wav",
	"ambience/rocketflame1.wav",
	"ambience/steamburst1.wav",
	"ambience/burning1.wav",
	"sprites/explode1.spr",
	"sprites/cexplo.spr",
	"wpn_flame",
	"player",
	"func_water",
	"weapon_bazooka",
	"weapon_piat",
	"weapon_pschreck",
	"ammo_generic_american",
	"ammo_generic_british",
	"ammo_generic_german",
	"items/ammopickup.wav"
};

//new p_speed, p_speedsprite, p_life, p_rof;

public plugin_init() {
	register_plugin( PLUGIN, VERSION, AUTHOR );
	
	//p_speed = register_cvar( "p_speed", "500" );
	//p_speedsprite = register_cvar( "p_speedsprite", "50" );
	//p_life = register_cvar( "p_life", "0.8" );
	//p_rof = register_cvar( "p_rof", "0.3" );
	
	g_msgCurWeapon 	= get_user_msgid( "CurWeapon" );
	g_msgScreenFade	= get_user_msgid( "ScreenFade" );
	g_msgScreenShake= get_user_msgid( "ScreenShake" );
	g_msgRoundState	= get_user_msgid( "RoundState" );
	g_msgAmmoX	= get_user_msgid( "AmmoX" );
	p_enabled	= register_cvar( "dod_flamethrower", "1" );
	p_ammo		= register_cvar( "dod_flamethrower_ammo", "90" );
	p_limitbazooka	= get_cvar_pointer( "mp_limitalliesbazooka" );
	p_limitpiat	= get_cvar_pointer( "mp_limitbritpiat" );
	p_limitpschreck	= get_cvar_pointer( "mp_limitaxispschreck" );
	
	// Temporary
	p_stamina	= register_cvar( "p_stamina", "10" );
	
	register_message( g_msgCurWeapon, 	"fwd_CurWeapon" );
	register_message( g_msgRoundState,	"fwd_RoundState" );
	register_forward( FM_UpdateClientData,	"fwd_UpdateClientData_Post", 1 );
	register_forward( FM_AddToFullPack,	"fwd_AddToFullPack_Post", 1 );
	register_forward( FM_CmdStart, 		"fwd_CmdStart" );
	register_forward( FM_Think, 		"fwd_Think" );
	register_forward( FM_Touch, 		"fwd_Touch" );
	register_forward( FM_SetModel,		"fwd_SetModel" );
	register_statsfwd( XMF_DEATH );
	
	register_clcmd( "cls_flamethrower", 	"clcmd_set_class" );
	register_clcmd( "cls_bazooka",		"clcmd_rocket_menu" );
	register_clcmd( "cls_piat",		"clcmd_rocket_menu" );
	register_clcmd( "cls_pschreck",		"clcmd_rocket_menu" );
}

public plugin_precache() {
	precache_model( strings[v_flamethrower] );
	precache_model( strings[p_flamethrower] );
	precache_model( strings[w_flamethrower] );
	precache_sound( strings[blank_sound] );
	precache_sound( strings[explosion_sound] );
	precache_sound( strings[flame_fire] );
	precache_sound( strings[flame_off] );
	precache_sound( strings[flame_burning] );
	precache_sound( strings[ammo_pickup] );
	firesprite 	= precache_model( strings[flame_sprite] );
	explosionsprite	= precache_model( strings[explosion_sprite] );
}

public client_connect( id ) {
	g_isClass[id]	= false;
	g_holding[id] 	= false;
	g_firing[id] 	= false;
	g_nextShot[id] 	= 0.0;
}

public fwd_CurWeapon( msgid, msgdest, id ) {
	if( plugin_enabled() )
	{
		new wpnactive	= get_msg_arg_int( 1 );
		new wpnid 	= get_msg_arg_int( 2 );
		
		if( wpnactive && has_flamethrower(id, wpnid) )
		{
			static curModel[32];
			pev( id, pev_viewmodel2, curModel, 31 );
			
			if( !equal(curModel, strings[v_flamethrower]) )
			{
				set_visuals( id );
			}
			
			// Alter Ammo Sprite
			set_msg_arg_int( 2, ARG_BYTE, HUD_WPN );
			
			// In case client drops weapon
			g_holding[id] = true;
			
			// Ensure that no backpack ammo shows up - necessary for picking up flamethrower
			set_smg_ammo( id, 0 );
		}
		// If switching from flamethrower to another weapon
		else if( wpnactive && g_holding[id] )
		{
			fire_off( id );
			g_holding[id] = false;
			new ammo = get_pdata_int( id, OFFSET_SMGAMMO, OFFSET_LINUX );
			if( ammo ) set_smg_ammo( id, ammo );
		}
	}
}

public fwd_RoundState( msgid, msgdest, id ) {
	new arg = get_msg_arg_int( 1 );
	if( arg == 1 )
	{
		g_roundlive = true;
	}
	else if( arg == 3 || arg == 4 )
	{
		g_roundlive = false;
	}
}

public fwd_UpdateClientData_Post( id, sendweapons, cd_handle ) {
	if( plugin_enabled() )
	{
		if( is_user_alive(id) && has_flamethrower(id, get_user_weapon(id)) )
		{
			set_cd( cd_handle, CD_flNextAttack, get_gametime() + 0.001 );
		}
	}
}

public fwd_AddToFullPack_Post( es_handle, e, entid, host, hostflags, player, pSet ) {
	if( plugin_enabled() )
	{
		if( player && g_firing[entid] )
			set_es( es_handle, ES_Sequence, SEQ_FIRE );
	}
}

public fwd_CmdStart( id, uc_handle, seed ) {
	if( plugin_enabled() )
	{
		if( is_user_alive(id) && has_flamethrower(id, get_user_weapon(id)) )
		{
			static buttons, newbuttons, oldbuttons;
			buttons = get_uc( uc_handle, UC_Buttons );
			newbuttons = buttons;
			oldbuttons = pev( id, pev_oldbuttons );
			
			if( (buttons & IN_ATTACK) && can_fire(id) )
			{
				new Float:gtime = get_gametime();
				
				newbuttons &= ~IN_ATTACK;
				if( g_nextShot[id] <= gtime )
				{
					fire( id );
					g_nextShot[id] = gtime + FLAME_ROF;
				}
			}
			else if( oldbuttons & IN_ATTACK )
			{
				fire_off( id );
			}
			
			if( buttons & IN_ATTACK2 )
			{
				newbuttons &= ~IN_ATTACK2;
			}
			if( buttons & IN_RELOAD )
			{
				newbuttons &= ~IN_RELOAD;
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

public fwd_Think( ent ) {
	if( plugin_enabled() )
	{
		if( pev_valid(ent) )
		{
			static classname[32];
			pev( ent, pev_classname, classname, 31 );
			
			if( equal(classname, strings[flame_entity]) )
			{
				new victim = pev( ent, pev_aiment );
				new Float:stamina = victim ? dod_stamina( victim ) : 0.0;
				
				// If flame is still in the air or if the victim is alive and has stamina
				if( !victim || (is_user_alive(victim) && stamina && water_level(victim) <= 1) )
				{
					set_pev( ent, pev_nextthink, ANI_SPEED );
					
					new Float:ltime;
					pev( ent, pev_ltime, ltime );
					if( ltime && ltime <= get_gametime() )
						set_pev( ent, pev_flags, FL_KILLME );
					
					new Float:frame;
					pev( ent, pev_frame, frame );
					if( frame < FLAME_FRAMES )
						set_pev( ent, pev_frame, frame + 0.3 );
					else
						set_pev( ent, pev_frame, 0.0 );
				}
				else
				{
					remove_flame( victim, ent );
				}
			}
		}
	}
}

public fwd_Touch( ptd, ptr ) {
	if( plugin_enabled() )
	{
		if( pev_valid(ptd) && pev_valid(ptr) && is_user_alive(ptd) )
		{
			static ptd_classname[32], ptr_classname[32];
			pev( ptd, pev_classname, ptd_classname, 31 );
			pev( ptr, pev_classname, ptr_classname, 31 );
			
			if( equal(ptd_classname, strings[player_entity]) && equal(ptr_classname, strings[flame_entity]) )
			{
				if( water_level(ptd) <= 1 )
				{
					new attacker = pev( ptr, pev_owner );
					player_damage( ptd, attacker, FLAME_DMG, DMG_BURN );
					flash_screen( ptd );
						
					if( !task_exists( ptd ) )
					{
						// Notify player that he is on fire
						client_print( ptd, print_center, FIRE_MESSAGE );
							
						// Initialise burning process
						new repeat = get_user_health( ptd ) / floatround( FLAME_DMG );
						new args[2];
						args[0] = ptd;
						args[1] = attacker;
						set_task( Float:2.0, "burn", ptd, args, 2, "a", repeat > 0 ? repeat : 0 );
						
						// Attach flame to player
						attach_flame( ptd, ptr );
							
						// Play burning sound
						emit_sound( ptd, CHAN_AUTO, strings[flame_burning], 0.8, ATTN_NORM, 0, PITCH_NORM );
					}
					// If player is already burning, remove the flame entity
					else	set_pev( ptr, pev_flags, FL_KILLME );
				}
				
			}
		}
		else if( !ptd && pev_valid(ptr) )
		{
			static ptr_classname[32];
			pev( ptr, pev_classname, ptr_classname, 31 );
			
			if( equal(ptr_classname, strings[flame_entity]) )
			{
				new iOrigin[3], Float:fOrigin[3];
				pev( ptr, pev_origin, fOrigin );
				FVecIVec( fOrigin, iOrigin );
				scorch( iOrigin );
			}
		}
		else if( pev_valid(ptd) && is_user_alive(ptr) )
		{
			new wpnid = get_user_weapon( ptr );
			if( has_flamethrower(ptr, wpnid ) )
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
						new clipammo 	= clip_ammo( ptr );
						new newammo	= clipammo + AMMOBOX_INC;
						if( clipammo < AMMO_MAX )
						{
							// Set Ammo
							clip_ammo( ptr, newammo <= AMMO_MAX ? newammo : AMMO_MAX  );
							emit_sound( ptd, CHAN_ITEM, strings[ammo_pickup], 0.8, ATTN_NORM, 0, PITCH_NORM );
							
							// Ensure that it doesn't get picked up again
							set_pev( ptd, pev_solid, SOLID_NOT );
							set_pev( ptd, pev_flags, FL_KILLME );
							
						}
						// Ensure that the rocket's ammo is not increased
						return FMRES_SUPERCEDE;
					}
				}
			}
		}
			
	}
	return FMRES_IGNORED;
}

public fwd_SetModel( ent, const model[] ) {
	if( plugin_enabled() )
	{
		new owner = pev( ent, pev_owner );
		if( pev_valid(ent) && (owner && g_holding[owner])
		&& (equal(model, strings[w_bazooka]) || equal(model, strings[w_piat]) || equal(model, strings[w_pschreck])) )
		{
			engfunc( EngFunc_SetModel, ent, strings[w_flamethrower] );
			return FMRES_SUPERCEDE;
		}
	}
	return FMRES_IGNORED;
}

public clcmd_set_class( id ) {
	if( plugin_enabled() )
	{
		set_class( id );
		client_print( id, print_chat, "*You will respawn as Flamethrower" );
		return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE;
}

public clcmd_rocket_menu( id ) {
	if( plugin_enabled() )
	{
		if( class_allowed(id) )
		{
			new menu = menu_create( "Engineer Classes", "menu_handler" );
			menu_additem( menu, "Rocket Class" );
			menu_additem( menu, "Flamethrower Class" );
			menu_display( id, menu );
		}
	}
}

public menu_handler( id, menu, item ) {
	if( item == 0 )
	{
		set_class( id, 0 );
	}
	if( item == 1 )
	{
		set_class( id );
		client_print( id, print_chat, "*You will respawn as Flamethrower" );
	}
}

public dod_player_spawn( id ) {
	if( plugin_enabled() )
	{
		if( is_class(id) )
		{
			// Set his weapon to a flamethrower
			g_holding[id] = true;
			has_flamethrower( id, _, 1 );
			set_visuals( id );
			//remove_gear( id );
			// Set Ammo
			clip_ammo( id, get_pcvar_num(p_ammo) );
			alter_hud_ammo( id );
			set_smg_ammo( id, 0 );
		}
	}
}

public client_damage( attacker, victim, damage, wpnindex, hitplace, ta ) {
	if( plugin_enabled() )
	{
		if( hitplace == HIT_CHEST && damage >= EXPL_TRIGGER && !is_melee_weapon(wpnindex) )
		{
			if( has_flamethrower(victim, get_user_weapon(victim)) )
			{
				set_task( Float:0.1, "explode_player", victim );
			}
		}
	}
}

public client_death( killer, victim, wpnindex, hitplace, tk ) {
	if( plugin_enabled() )
	{
		fire_off( victim );
	}
}

fire( id ) {	
	if( !g_firing[id] ) {
		g_firing[id] = true;
		// Play firing sound
		emit_sound( id, CHAN_WEAPON, strings[flame_fire], 0.8, ATTN_NORM, 0, PITCH_NORM );
	}
	
	new flame = create_flame( id );

	if( pev_valid(flame) )
	{		
		new Float:fStart[3];
		//get_startpos( id, 64, 12, -16, fStart );
		get_startpos( id, 32, 0, -16, fStart );
		set_pev( flame, pev_origin, fStart );
		
		
		new Float:fVel[3];
		velocity_by_aim( id, FLAME_SPEED, fVel );
		//velocity_by_aim( id, FLAME_SPEED, fVel );
		set_pev( flame, pev_velocity, fVel );
		
		fire_sprite( id );
	}
	
	// Decrease Ammo
	clip_ammo( id, _, -1 );
	
	// Decrease Stamina if standing
	if( ~(pev(id, pev_button) & IN_DUCK) )
	{
		decrease_stamina( id );
	}
}

create_flame( owner ) {
	new flame = engfunc( EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString,"func_wall") );
	new Float:gtime = get_gametime();
	
	// Strings
	set_pev( flame, pev_classname, strings[flame_entity] );
	engfunc( EngFunc_SetModel, flame, strings[flame_sprite] );
		
	// Integers
	set_pev( flame, pev_owner, owner );
	set_pev( flame, pev_rendermode, kRenderTransAdd );
	set_pev( flame, pev_renderamt, 255.0 );
	set_pev( flame, pev_movetype, MOVETYPE_BOUNCEMISSILE );
	set_pev( flame, pev_solid, SOLID_BBOX );
	set_pev( flame, pev_nextthink, ANI_SPEED );
		
	// Floats
	new Float:radius = FLAME_RADIUS;
	new Float:mins[3];
	mins[0] = radius * -1;
	mins[1] = radius * -1;
	mins[2] = radius * -1;
	new Float:maxs[3];
	maxs[0] = radius;
	maxs[1] = radius;
	maxs[2] = radius;
	engfunc( EngFunc_SetSize, flame, FLAME_MINS, FLAME_MAXS );
	set_pev( flame, pev_mins, FLAME_MINS );
	set_pev( flame, pev_maxs, FLAME_MAXS );
	set_pev( flame, pev_absmin, FLAME_MINS);
	set_pev( flame, pev_absmax, FLAME_MAXS );
	set_pev( flame, pev_ltime, gtime + FLAME_LIFE );
		
	return flame;
}

// From EJL's Flamethrower plugin
fire_sprite( id ) {
	new origin[3], aim[3], velocity[3];
	new length, speed = 10;
	get_user_origin( id, origin );
	get_user_origin( id, aim, 2 );

	velocity[0] = aim[0] - origin[0];
	velocity[1] = aim[1] - origin[1];
	velocity[2] = aim[2] - origin[2];
	
	length = sqrt( velocity[0] * velocity[0] + velocity[1] * velocity[1] + velocity[2] * velocity[2] );
	
	velocity[0] = velocity[0] * speed / length;
	velocity[1] = velocity[1] * speed / length;
	velocity[2] = velocity[2] * speed / length;
	
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte ( 120 ); // Throws a shower of sprites or models
	write_coord( origin[0] ); // start pos
	write_coord( origin[1] );
	write_coord( origin[2] );
	write_coord( velocity[0] ); // velocity
	write_coord( velocity[1] );
	write_coord( velocity[2] );
	write_short( firesprite ); // spr
	write_byte ( 8 ); // count
	write_byte ( FLAME_SPRSPEED ); // speed 50
	write_byte ( 100 ); //(noise)
	write_byte ( 5 ); // (rendermode) 5
	message_end();
}

fire_off( id ) {
	if( g_firing[id] )
	{
		emit_sound( id, CHAN_WEAPON, strings[flame_off], 0.4, ATTN_NORM, 0, PITCH_NORM );
		g_firing[id] = false;
	}
}

public burn( args[] ) {
	new victim = args[0];
	new attacker = args[1];

	flash_screen( victim );
	
	player_damage( victim, attacker, FLAME_DMG, DMG_BURN );
}

public explode_player( id ) {
	new Float:origin[3], iOrigin[3];
	pev( id, pev_origin, origin );
	FVecIVec( origin, iOrigin );
	
	// Create explosion sound
	emit_sound( id, CHAN_AUTO, strings[explosion_sound], 0.4, ATTN_NORM, 0, PITCH_NORM );
	
	// Create explosion sprite
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte ( TE_EXPLOSION );
	write_coord( floatround(origin[0]) );
	write_coord( floatround(origin[1]) );
	write_coord( floatround(origin[2])+45 );
	write_short( explosionsprite );
	write_byte ( 30 );
	write_byte ( 30 );
	write_byte ( 12 );
	message_end();
	
	// Create explosion damage
	fm_radius_damage( origin, EXPL_DAMAGE, EXPL_RADIUS, id );
	
}

stock fm_radius_damage( Float:origin[3], Float:damage, Float:radius, inflictor = 0 )
{
	static Float:plOrigin[3], Float:plDistance, Float:plDamage;
	
	for( new i=1; i<=get_maxplayers(); i++ )
	{
		if( is_user_alive(i) )
		{
			pev( i, pev_origin, plOrigin );
			plDistance = get_distance_f( origin, plOrigin );
			
			if( plDistance <= radius )
			{
				plDamage = damage - (damage/radius) * plDistance;
				player_damage( i, inflictor, plDamage, DMG_BLAST );

				// Screen Fade
				message_begin( MSG_ONE_UNRELIABLE, g_msgScreenShake, _, i );
				write_short( 1<<14 ); //ammount 
				write_short( 1<<12 ); //lasts this long 
				write_short( 2<<14 ); //frequency
				message_end();
			}
		}
	}
	return 1;
}

is_melee_weapon( wpnid ) {
	// Knives
	if( wpnid == DODW_AMERKNIFE || wpnid == DODW_BRITKNIFE || wpnid == DODW_GERKNIFE || wpnid == DODW_SPADE )
		return 1;
	// Secondary Attacks
	if( wpnid == DODW_GARAND_BUTT || wpnid == DODW_ENFIELD_BAYONET || wpnid == DODW_K43_BUTT || wpnid == DODW_KAR_BAYONET )
		return 1;
	return 0;
}

water_level( id ) {
	return pev(id, pev_waterlevel);
}

can_fire( id ) {
	new clipammo = clip_ammo( id );
	
	if( g_roundlive && (water_level(id) <= 2) && (clipammo > 0) )
		return 1;
	return 0;
}

attach_flame( id, flame ) {
	set_pev( flame, pev_velocity, Float:{0.0,0.0,0.0} );
	//set_pev( flame, pev_owner, id );
	set_pev( flame, pev_solid, SOLID_NOT );
	set_pev( flame, pev_aiment, id );
	set_pev( flame, pev_ltime, Float:0.0 );
}

player_damage( id, attacker, Float:amt, dmgtype ) {
	if( is_user_alive(id) )
	{
		new hp = get_user_health( id );
		new newhp = hp - floatround( amt );
		if( newhp > 0 )
		{
			fm_fakedamage( id, strings[flame_entity], amt, dmgtype );
		}
		else
		{
			// Kill client
			// TODO: Add TK Penalty
			fire_off( id );
			user_silentkill( id );
			if( get_user_team(id) != get_user_team(attacker) )
				dod_set_user_kills( attacker, dod_get_user_kills(attacker)+1, 1 );
			dod_make_deathmsg( attacker, id, 0 );
		}
	}
}

// From diamond-optic's dod_shellshock
flash_screen( id ) {
	message_begin( MSG_ONE_UNRELIABLE, g_msgScreenFade, _, id );
	write_short( 1<<13 );  //duraiton  (1<<13)
	write_short( 1<<12 );  //hold time  (1<12)
	write_short( 0 );  //flags  (0x0002)
	write_byte ( 192 ); //red (192)
	write_byte ( 0 ); //green
	write_byte ( 0 ); //blue
	write_byte ( 160 ); //alpha (160)
	message_end();
}

// Returns 1 on success; 0 on failure
remove_flame( id, ent=0 ) {
	// Remove burn task
	if( task_exists(id) ) {
		remove_task( id );
	}
	// If no ent is provided, find it
	if( !ent )
	{
		static aiment;
		while( ( ent = fm_find_ent_by_class(ent, strings[flame_entity]) ) != 0 ) {
			aiment = pev( ent, pev_aiment );
			
			if( aiment == id )
			{
				exit;
			}
		}
	}
	// If ent was provided or found
	if( ent )
	{
		// Remove entity
		set_pev( ent, pev_flags, FL_KILLME );
		
		// Clear burning sound
		emit_sound( id, CHAN_AUTO, strings[flame_burning], 0.4, ATTN_NORM, SND_STOP, PITCH_NORM );
		
		return 1;
	}
	return 0;
}

scorch( origin[3] ) {	
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte ( 116 );
	write_coord( origin[0] );
	write_coord( origin[1] );
	write_coord( origin[2] );
	write_byte( SCORCH_INDEX );
	message_end();
}

has_flamethrower( id, wpnid=0, set=-1 ) {
	if( !wpnid )
	{
		new team = get_user_team( id );
		
		if( team == ALLIES && !dod_is_map_british() )
			wpnid = DODW_BAZOOKA;
		else if( team == ALLIES )
			wpnid = DODW_PIAT;
		else
			wpnid = DODW_PANZERSCHRECK;
	}
	
	//new wpnent = dod_get_weapon_ent( id, wpnid );
	new wpnent = dod_get_weapon_ent_by_owner( id, wpnid );
	
	if( wpnent && set > -1 )
		set_pev( wpnent, PEV_FLAMETHROWER, set );
	
	return wpnent ? pev( wpnent, PEV_FLAMETHROWER ) : 0;
}

set_class( id, set=1 ) {
	if( set )
	{
		g_isClass[ id ] = true;
		
		new class, team = get_user_team( id );
		
		if( team == ALLIES && !dod_is_map_british() ) // American
			class = DODC_BAZOOKA;
		else if( team == ALLIES ) // British
			class = DODC_PIAT;
		else // German
			class = DODC_PANZERJAGER;
			
		set_pdata_int( id, OFFSET_CLASS, class, OFFSET_LINUX );
		set_pdata_int( id, OFFSET_RCLASS, 0, OFFSET_LINUX ); // Make sure not on Random class
	}
	else
	{
		g_isClass[ id ] = false;
	}
}

is_class( id ) {
	new class = dod_get_user_class( id );
	
	if( g_isClass[id] &&
		(class == DODC_BAZOOKA || class == DODC_PIAT || class == DODC_PANZERJAGER) )
		return 1;
		
	return 0;
}

set_visuals( id ) {
	set_pev( id, pev_viewmodel2, strings[v_flamethrower] );
	set_pev( id, pev_weaponmodel2, strings[p_flamethrower] );
}

/*remove_gear( id ) {
	set_pev( id, pev_body, BODY_NOGEAR );
}*/

alter_hud_ammo( id ) {
	message_begin( MSG_ONE, g_msgCurWeapon, _, id );
	write_byte( 1 );
	write_byte( HUD_WPN );
	write_byte( 0 );
	message_end();
}

set_smg_ammo( id, amt ) {	
	message_begin( MSG_ONE, g_msgAmmoX, _, id );
	write_byte( AMMO_SMG );
	write_byte( amt );
	message_end();
}

clip_ammo( id, set=-1, diff=0 ) {
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

decrease_stamina( id ) {
	new Float:current;
	pev( id, pev_fuser4, current );
	new Float:factor	= get_pcvar_float( p_stamina );
	new Float:set		= (current - factor) >= 0.0 ? (current - factor) : 0.0;
	
	// Set new stamina
	set_pev( id, pev_fuser4, set );
}

class_allowed( id ) {
	new team, class, limit = 0;
	team = get_user_team( id );
	
	if( team == ALLIES && !dod_is_map_british() )
	{
		class = DODC_BAZOOKA;
		limit = get_pcvar_num( p_limitbazooka );
	}
	else if( team == ALLIES )
	{
		class = DODC_PIAT;
		limit = get_pcvar_num( p_limitpiat );
	}
	else
	{
		class = DODC_PANZERJAGER;
		limit = get_pcvar_num( p_limitpschreck );
	}

	new pClass, engineers = 0;
	for( new i=1; i<=get_maxplayers(); i++ )
	{
		if( is_user_connected(i) )
		{
			pClass = dod_get_user_class( i );
			if( class == pClass )
				engineers++;
		}
	}
	
	if( limit > engineers || limit == -1 || dod_get_user_class(id) == class )
		return 1;
		
	return 0;
}

// Taken from WeaponMod
get_startpos( id, forw, right, up, Float:vSrc[3] ) {
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

stock dod_get_weapon_ent_by_owner( id, wpnid ) {
	new wpnname;
	switch( wpnid )
	{
		case DODW_BAZOOKA: 	 wpnname = weapon_bazooka;
		case DODW_PIAT:		 wpnname = weapon_piat;
		case DODW_PANZERSCHRECK: wpnname = weapon_pschreck;
		default:		 return 0;
	}
	return fm_find_ent_by_owner( 0, strings[names:wpnname], id );
}

stock sqrt(num) {
	new div = num;
	new result = 1;
	while (div > result) { // end when div == result, or just below
		div = (div + result) / 2; // take mean value as new divisor
		result = num / div;
	}
	return div;
}

stock plugin_enabled() return get_pcvar_num( p_enabled );
