////////////////////////////////////////////////////////////////////////////////////////////////////
/*

INFO:

This script makes it possible to throw your weapon at your enemy and hereby do damage to him.

To get your weapon flying u need to bind a key to throw_weapon and hit that key when you wanna throw
your weapon.

***MG34, MG42 and 30CAL cant be thrown


CREDIT:

The basics of this plugin was found in the request forum @ allied modders, and was original made by
KRoTaL. In the request forum someone updated it and posted it there, but i dont know who. However 
credit to that person and KRoTaL, I cant find the thread anymore sry.

diamond-optic(www.avamods.com)
www.dodplugins.net


TO DO:

- Trace hits and add adjustable damage for hitplaces
- Some kinda join message maybe
- Maybe add a chance that the weapon will be jammed after it have be thrown 


CHANGELOG:

02-17-2009 BETA release 



CVARS and default settings:


dod_tw 1				// plugin on/off | 1 = on 0 = off
dod_tw_damage 15 			// damage on hit
dod_tw_speed 700			// throw speed
dod_tw_time_alive 1			// how long after throwing the weapon it will hurt. in sec

*/
////////////////////////////////////////////////////////////////////////////////////////////////////
#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <dodx>
#include <dodfun>
#include <engine>
////////////////////////////////////////////////////////////////////////////////////////////////////
#define PLUGIN "DoD Throw knives +"
#define VERSION "1.2"
#define AUTHOR "TheVaskov"
////////////////////////////////////////////////////////////////////////////////////////////////////
// p's
new p_on, p_wpn_damage, p_wpn_speed, p_wpn_time_alive, wpn_id
////////////////////////////////////////////////////////////////////////////////////////////////////
//g's
new mp_friendlyfire
new g_FhSetModel
new g_MessageFade,gMsgDeathMsg
new bool:g_can_throw[33]

new Blood;
new BloodSpray;

new g_dropboxclass[33]
new const g_szClassName[] = "thrown_weapon"
new const g_szOrgClassName[] = "weaponbox"
new const g_ThrowSound[] = "weapons/knifeswing2.wav"
new const g_ThrowFlySound[] = "weapons/whizz10.wav"
new const g_ThrowHitwallSound[] = "weapons/knife_hitwall1.wav"
new const g_ThrowHitHumanSound[] = "weapons/hit_grass2.wav"
////////////////////////////////////////////////////////////////////////////////////////////////////
static bool:g_i_status[33]
public client_connect(i_player)
	g_i_status[i_player]=false

public client_PreThink(i_player){
	if(pev(i_player,pev_button)&IN_ATTACK2)
	{
		if(g_i_status[i_player]==false)
		{
			g_i_status[i_player]=true // Игрок  i_player послал +attack2
			//client_cmd(i_player,"throw_weapon")
			
			throw_wpn(i_player)
			
			
			PLUGIN_HANDLED;
		}
	}      
	else {
		if(g_i_status[i_player]==true)
		{
			g_i_status[i_player]=false // Игрок i_player послал -attack2
		}
	}
}
///////////////////////////////////////////

public plugin_precache() 
{
	
	// Blood = precache_model("sprites/axis_camera.spr");
	BloodSpray = precache_model("sprites/blood-narrow.spr");
	
	
}



public plugin_init()
{
	/* reg plugin and public tracking */
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_cvar("dod_tw_stats",VERSION,FCVAR_SERVER|FCVAR_SPONLY)
	
	/* overall settings */
	p_on = register_cvar("dod_tw", "1")
	p_wpn_damage = register_cvar("dod_tw_damage", "200")
	p_wpn_speed = register_cvar("dod_tw_speed", "1100.0")
	p_wpn_time_alive = register_cvar("dod_tw_time_alive", "1.0")
	
	/* custom wpn ( name[], melee=0,logname[] ) */
	wpn_id = custom_weapon_add("thrown_weapon",0,"thrown_weapon")
	
	/* player killed */
	// RegisterHam(Ham_Killed, "player", "ham_killed", 0)
	
	/* touch.. FM... */
	register_forward(FM_Touch,"hook_touch")
	
	/* Ham cant reg it before its "real"
	new i_Ent = engfunc(EngFunc_CreateNamedEntity, g_szClassName)
	RegisterHamFromEntity(Ham_Touch, i_Ent, "hook_touch")*/
	
	/* weaponbox spawn */
	RegisterHam(Ham_Spawn, "weaponbox", "WeaponBox_Spawn", 1)
	
	/* pub.throw cmd */
	// register_clcmd("throw_weapon","throw_wpn",0,"- Throw your weapon")
	
	/* victim msg */
	g_MessageFade = get_user_msgid("ScreenFade")
	gMsgDeathMsg = get_user_msgid("DeathMsg")
	
	mp_friendlyfire = get_cvar_pointer("mp_friendlyfire")
}
////////////////////////////////////////////////////////////////////////////////////////////////////
public throw_wpn(id)
{
	if(is_user_alive(id) && !is_wpn_heavy(id))
	{
		g_can_throw[id]=true
		
		new clip,ammo
		new classbox = get_user_weapon(id, clip,ammo)
		g_dropboxclass[id] = classbox
		client_print(id,print_chat, "classbox = %d" , g_dropboxclass[id])
		
		client_cmd(id,"drop")
	}
}
////////////////////////////////////////////////////////////////////////////////////////////////////
public WeaponBox_Spawn(iEnt)
{
	
	g_FhSetModel = register_forward(FM_SetModel, "SetModel")
	
}
////////////////////////////////////////////////////////////////////////////////////////////////////
public SetModel(iEnt)
{
	new id = pev(iEnt, pev_owner)
	
	if(is_user_alive(id) && !is_wpn_heavy(id) && g_can_throw[id])
	{
		new Float:fVelocity[3]
		velocity_by_aim(id, 1800, fVelocity)
		fVelocity[2] += 30.0
		set_pev(iEnt, pev_velocity, fVelocity)
		
		/// rotation 
		new Float:TumbleVector[3]			
		TumbleVector[0] = random_float(-500.0,-501.0) // = 1320.0  // Wheel
		// TumbleVector[1] // = random_float(800.0,100.0)  // TEA
		TumbleVector[2] = random_float(-60.0,60.0) // 400.0 // = random_float(2.0,0.0) //  HOURS
		
		
		new Float:f5Angles[3], Float:f5Origin[3]
		
		vector_to_angle(fVelocity, f5Angles)
		pev(id, pev_origin, f5Origin)
		
		f5Angles[0] += 55.0
		// f5Angles[1] // 
		f5Angles[2] += 90.0
		
		set_pev(iEnt, pev_angles, f5Angles)
		
		set_pev(iEnt, pev_avelocity, TumbleVector)
		engfunc(EngFunc_SetSize, iEnt, Float:{-1.0, -1.0, -1.0}, Float:{1.0, 1.0, 1.0})
		set_pev(iEnt, pev_classname, g_szClassName)
		
		set_pev(iEnt, pev_solid, SOLID_TRIGGER)
		g_can_throw[id]=false
		set_task(get_pcvar_float(p_wpn_time_alive),"BackToNormal",iEnt)
		
		// thwrowspadeani(id)
		
		emit_sound(id,CHAN_BODY,g_ThrowSound,0.9,ATTN_NORM,0,PITCH_NORM)
		
		emit_sound(iEnt,CHAN_AUTO,g_ThrowFlySound,0.5,ATTN_NORM ,0,PITCH_NORM)
		
		custom_weapon_shot(wpn_id,id)
		
		
		
	}
	unregister_forward(FM_SetModel, g_FhSetModel)
}
////////////////////////////////////////////////////////////////////////////////////////////////////
public hook_touch(iEnt,id)
{
	if(get_pcvar_num(p_on) && is_user_connected(id) && is_user_alive(id))
	{
		static szClassName[32]
		pev(iEnt, pev_classname, szClassName, sizeof szClassName - 1)
		
		new iAttacker = pev(iEnt, pev_owner)
		
		if(!equal(szClassName, g_szClassName) 
		|| iAttacker == id 
		|| !is_user_alive(iAttacker) 
		|| (!get_pcvar_num(mp_friendlyfire) 
		&& get_user_team(iAttacker) == get_user_team(id)))
		return FMRES_IGNORED
		
		// ExecuteHamB(Ham_TakeDamage, id, iEnt, iAttacker, 20, DMG_BULLET) /* DMG_SHOCK no effect */
		red_flash(id)
		
		// ExecuteHamB(Ham_Killed, id, iAttacker, 0)
		
		// client_print(0,print_chat, "smash is %s ",  g_dropboxclass[iAttacker])
		static Float:fOrigin[3]
		pev(id, pev_origin, fOrigin)
		create_blood_dod(fOrigin)
		
		
		user_silentkill(id)
		new fragcount = dod_get_user_kills(iAttacker)
		fragcount++
		dod_set_user_kills(iAttacker, fragcount, 1)
		
		set_pev(iEnt, pev_classname, g_szOrgClassName)
		message_begin(MSG_ALL,gMsgDeathMsg,{0,0,0},0)
		write_byte(iAttacker) // killer
		write_byte(id) // victim
		write_byte(g_dropboxclass[iAttacker])  // 42 is smash
		message_end()
		
		
		
		new hitplace = random_num(0,6)
		// custom_weapon_dmg(wpn_id,iAttacker,id,get_pcvar_num(p_wpn_damage),hitplace)
		
	}
	static szClassName[32]
	pev(iEnt, pev_classname, szClassName, sizeof szClassName - 1)
	
	
	if(id == 0  &&  equal(szClassName, g_szClassName)){
		
		
		
		new Float:iOrigin[3]
		entity_get_vector(iEnt,EV_VEC_origin,iOrigin)
		// client_print(0,print_chat, "orogin %f , %f , %f ",  iOrigin[0],iOrigin[1],iOrigin[2])
		// pev(id,pev_origin,iOrigin)
		
		new i2Origin[3]
		FVecIVec(iOrigin,i2Origin)
		
		emit_sound(iEnt,CHAN_AUTO,g_ThrowHitwallSound,0.4,ATTN_IDLE ,0,PITCH_NORM)
		
		message_begin(MSG_PVS,SVC_TEMPENTITY)
		write_byte(TE_SPARKS)
		write_coord(i2Origin[0])
		write_coord(i2Origin[1])
		write_coord(i2Origin[2])
		message_end()
		
		set_pev(iEnt, pev_velocity, Float:{100.0, 100.0, 50.0})
		
		
		emit_sound(iEnt,CHAN_WEAPON   ,g_ThrowHitwallSound,0.4,ATTN_NORM,0,PITCH_NORM + 50)
		
		
	}
		return FMRES_IGNORED
	}
	////////////////////////////////////////////////////////////////////////////////////////////////////
	public ham_killed(id, idattacker, shouldgib)
	{
		if(get_pcvar_num(p_on) && is_user_connected(idattacker) && is_wpn_thrown(idattacker))
		{
			/*
			new steam[33], teamname[33], name[33]
			new steam2[33], teamname2[33], name2[33]
			get_user_authid(idattacker, steam, sizeof steam - 1)
			get_user_authid(id, steam2, sizeof steam2 - 1)
			dod_get_pl_teamname(idattacker, teamname, sizeof teamname - 1)
			dod_get_pl_teamname(id, teamname2, sizeof teamname2 - 1)
			get_user_name(idattacker, name, sizeof name - 1)
			get_user_name(id, name2, sizeof name2 - 1)
			new userid = get_user_userid(idattacker)
			new userid2 = get_user_userid(id)
			
			// log_message("^"%s<%d><%s><%s>^" killed ^"%s<%d><%s><%s>^" with ^"thrown_weapon^"", name, userid, steam, teamname, name2, userid2, steam2, teamname2)
			*/
			// client_print(0, print_chat,"*** %s killed %s by throwing his weapon at him!", name, name2)
		}	
	}
	////////////////////////////////////////////////////////////////////////////////////////////////////
	public BackToNormal(iEnt)
	{
		if(pev_valid(iEnt) && get_pcvar_num(p_on))
		{
			static szClassName[32]
			pev(iEnt, pev_classname, szClassName, sizeof szClassName - 1)
			
			if(!equal(szClassName, g_szClassName))
				return FMRES_IGNORED
			
			set_pev(iEnt, pev_classname, g_szOrgClassName)
		}
		return FMRES_IGNORED
	}
	////////////////////////////////////////////////////////////////////////////////////////////////////
	stock is_wpn_heavy(id)  
	{     
		new clip, ammo, 
		wpn = get_user_weapon(id, clip, ammo)     
		if(wpn == DODW_MORTAR
		//	|| wpn == DODW_AMERKNIFE
		//	|| wpn == DODW_GERKNIFE
		|| wpn == DODW_COLT
		|| wpn == DODW_LUGER
		|| wpn == DODW_GARAND
		|| wpn == DODW_SCOPED_KAR
		|| wpn == DODW_THOMPSON
		|| wpn == DODW_STG44
		|| wpn == DODW_SPRINGFIELD
		|| wpn == DODW_KAR
		|| wpn == DODW_BAR
		|| wpn == DODW_MP40
		|| wpn == DODW_HANDGRENADE
		|| wpn == DODW_STICKGRENADE
		|| wpn == DODW_STICKGRENADE_EX
		|| wpn == DODW_HANDGRENADE_EX
		|| wpn == DODW_MG42
		|| wpn == DODW_30_CAL
		//	|| wpn == DODW_SPADE 
		|| wpn == DODW_M1_CARBINE
		|| wpn == DODW_MG34
		|| wpn == DODW_GREASEGUN
		|| wpn == DODW_FG42
		|| wpn == DODW_K43
		|| wpn == DODW_ENFIELD
		|| wpn == DODW_STEN
		|| wpn == DODW_BREN
		|| wpn == DODW_WEBLEY
		|| wpn == DODW_BAZOOKA
		|| wpn == DODW_PANZERSCHRECK
		|| wpn == DODW_PIAT
		|| wpn == DODW_SCOPED_FG42
		|| wpn == DODW_KAR_BAYONET
		|| wpn == DODW_SCOPED_ENFIELD
		|| wpn == DODW_MILLS_BOMB
		//	|| wpn == DODW_BRITKNIFE
		|| wpn == DODW_GARAND_BUTT
		|| wpn == DODW_ENFIELD_BAYONET
		|| wpn == DODW_K43_BUTT)
		return 1  
		return 0
	}
	////////////////////////////////////////////////////////////////////////////////////////////////////
	/* best stock EVER! :D */
	stock is_wpn_thrown(idattacker)  
	{     
		new clip, ammo, 
		wpn = get_user_weapon(idattacker, clip, ammo)     
		if(wpn == wpn_id)         
			return 1   
		return 0
	}
	////////////////////////////////////////////////////////////////////////////////////////////////////
	stock red_flash(id)
	{
		message_begin(MSG_ONE_UNRELIABLE, g_MessageFade , {0,0,0}, id)
		write_short(1<<10)
		write_short(1<<10)
		write_short(0x0000)
		write_byte(255)
		write_byte(0) 
		write_byte(0) 
		write_byte(99)
		message_end() 	
	}
	////////////////////////////////////////////////////////////////////////////////////////////////////
	
	public thwrowspadeani(id)
	{
		if(!is_user_alive(id)) 
			return PLUGIN_HANDLED
		
		set_pev(id,pev_weaponanim,4)
		message_begin(MSG_ONE,SVC_WEAPONANIM,{0,0,0},id)
		write_byte(8)
		write_byte(pev(id,pev_body))
		message_end()
		return PLUGIN_HANDLED
	}

stock create_blood_dod(Float:fOrigin[3]) 
{
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BLOODSTREAM);
	engfunc(EngFunc_WriteCoord, fOrigin[0]);
	engfunc(EngFunc_WriteCoord, fOrigin[1]);
	engfunc(EngFunc_WriteCoord, fOrigin[2]);
	write_coord(random_num(-50, 50));
	write_coord(random_num(-50, 50));
	write_coord(-10);
	write_byte(70);
	write_byte(random_num(50, 100));
	message_end();
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY) ;
	write_byte(TE_BLOODSPRITE);
	engfunc(EngFunc_WriteCoord, fOrigin[0] + random_float(-5.0, 5.0));
	engfunc(EngFunc_WriteCoord, fOrigin[1] + random_float(-5.0, 5.0));
	engfunc(EngFunc_WriteCoord, fOrigin[2]);
	write_short(BloodSpray);
	write_short(BloodSpray);
	write_byte(70);
	write_byte(7);
	message_end();
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1049\\ f0\\ fs16 \n\\ par }
*/
