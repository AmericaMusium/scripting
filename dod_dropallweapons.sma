//////////////////////////////////////////////////////////////////////////////////
//
//	DoD Drop All Weapons
//		- Version 1.2
//		- 09.21.2009
//		- diamond-optic
//
//////////////////////////////////////////////////////////////////////////////////
//
// Credits:
//
//	- Dr. G: Code to enable dropping of knives/pistols
//	- Vet(3TT3V): Used alot of code & the webley world model from dod_pistolclips (v1.4)
//
//////////////////////////////////////////////////////////////////
//
// Information:
//
//	- Allows players to drop their knives & pistols and
//	  pick up different ones
//
//	- Players will now also drop their knife and/or pistol
//	  on dying if they have one
//
//	- I have not got around to allowing nades to be dropped yet
//	  ..Give me some time and I'll eventually get to it
//
//////////////////////////////////////////////////////////////////
//
// CVARs:
//
//	dod_dropallweapons "1"		//Turn ON(1)/OFF(0)
//
//////////////////////////////////////////////////////////////////
//
// Compiler Defines:
//
//	DOD_WEAPONJAM 0			//Set to 1 if you use dod_weaponjam
//
//////////////////////////////////////////////////////////////////
//
// File Placement
//
//	w_webley_v1.md	-->	../dod/models/
//
//////////////////////////////////////////////////////////////////
//
// Changelog:
//
//	- 09.20.2009 Version 1.0
//		Initial release
//
//	- 09.21.2009 Version 1.1
//		Fixed a dumb mistake
//
//      - 10.04.2022 Version 1.2
//              Tuned for knifes (TheVaskov)
//
//////////////////////////////////////////////////////////////////////////////////

#include <amxmodx>
#include <fun>
#include <dodx>
#include <engine>
#include <fakemeta>
#include <hamsandwich>


//Enable if running DoD Weapon Jam by diamond-optic
#define DOD_WEAPONJAM	0


#define VERSION "1.2"
#define SVERSION "v1.2 - by TheVaskov"

#define KNIFE 	0
#define PISTOL 	1

#define PISTOL_COLT	0
#define PISTOL_WEBLEY 	1
#define PISTOL_LUGER	2

#define KNIFE_ALLIES	0
#define KNIFE_AXIS	1
#define KNIFE_SPADE	2

#define OFFSET_WPN_ID			91
#define OFFSET_WPN_CLIP 		108
#define OFFSET_PISTOL_BPAMMO_LINUX	52
#define OFFSET_PISTOL_BPAMMO_WIN32	53
#define OFFSET_LINUX 			4

new KNIVES_NAMES[3][] = {"weapon_amerknife","weapon_gerknife","weapon_spade"}
new KNIVES_MODELS[3][] = {"models/w_amerk.mdl","models/w_paraknife.mdl","models/w_spade.mdl"}

new PISTOLS_NAMES[3][] = {"weapon_colt","weapon_webley","weapon_luger"}
new PISTOLS_MODELS[3][] = {"models/w_colt.mdl","models/w_webley_v1.mdl","models/w_luger.mdl"}

new TEMP_CLASSNAME[] = "dropped_weapon"

new is_linux,maxplayers
new gMsgAmmoX

new p_plugin

public plugin_init()
{
	register_plugin("DoD Drop All Weapons",VERSION,"AMXX DoD Team")
	register_cvar("dod_dropallweapons_stats",SVERSION,FCVAR_SERVER|FCVAR_SPONLY)

	p_plugin = register_cvar("dod_dropallweapons","1")
	
	for(new i = 0; i < 3; i++)
		{
		RegisterHam(Ham_DOD_Item_CanDrop,KNIVES_NAMES[i],"func_WeaponDrop")
		// RegisterHam(Ham_DOD_Item_CanDrop,PISTOLS_NAMES[i],"func_WeaponDrop")
		}
	
	// RegisterHam(Ham_Killed,"player","func_HamKilled")
	RegisterHam(Ham_Think,"info_target","func_HamThink")
	RegisterHam(Ham_Touch,"info_target","func_HamTouch")
	
	register_event("RoundState","func_RoundState","a","1=3","1=4","1=5")
	
	gMsgAmmoX = get_user_msgid("AmmoX")
	
	register_forward(FM_CreateNamedEntity,"fwd_CreateNamedEntity",1)
}

public plugin_precache()
{
	precache_model("models/w_colt.mdl")
	precache_model("models/w_luger.mdl")
	precache_model("models/w_webley_v1.mdl")
	precache_model("models/w_spade.mdl")
}

public plugin_cfg()
{
	if(is_linux_server())
		is_linux = 1
	
	maxplayers = get_maxplayers()
	
	set_task(5.0,"func_FixMapGuns")
}

//////////////////////////////////////////////////////////////
// Fix models for pre-placed
//
public func_FixMapGuns()
{		
	new ent = -1
	while((ent = find_ent_by_class(ent,KNIVES_NAMES[2])) != 0)
		entity_set_model(ent,"models/w_spade.mdl")
	
	ent = -1
	while((ent = find_ent_by_class(ent,PISTOLS_NAMES[0])) != 0)
		entity_set_model(ent,"models/w_colt.mdl")
	
	ent = -1
	while((ent = find_ent_by_class(ent,PISTOLS_NAMES[1])) != 0)
		entity_set_model(ent,"models/w_webley_v1.mdl")
		
	ent = -1
	while((ent = find_ent_by_class(ent,PISTOLS_NAMES[2])) != 0)
		entity_set_model(ent,"models/w_luger.mdl")
}

//////////////////////////////////////////////////////////////
// Fix models for pre-placed (respawned)
//
public fwd_CreateNamedEntity(iClassname)
{
	static ent,szClassname[32]
	ent = get_orig_retval()
    
	engfunc(EngFunc_SzFromIndex,iClassname,szClassname,31)
	
	if(equal(szClassname,KNIVES_NAMES[2]))
		set_task(1.0,"func_FixSpade",ent)
	
	else if(equal(szClassname,PISTOLS_NAMES[0]))
		set_task(1.0,"func_FixColt",ent)
		
	else if(equal(szClassname,PISTOLS_NAMES[1]))
		set_task(1.0,"func_FixWebley",ent)
		
	else if(equal(szClassname,PISTOLS_NAMES[2]))
		set_task(1.0,"func_FixLuger",ent)
}

public func_FixSpade(ent)
	if(is_valid_ent(ent) && !entity_get_edict(ent,EV_ENT_owner))
		entity_set_model(ent,"models/w_spade.mdl")

public func_FixColt(ent)
	if(is_valid_ent(ent) && !entity_get_edict(ent,EV_ENT_owner))
		entity_set_model(ent,"models/w_colt.mdl")	
		
public func_FixWebley(ent)
	if(is_valid_ent(ent) && !entity_get_edict(ent,EV_ENT_owner))
		entity_set_model(ent,"models/w_webley_v1.mdl")
		
public func_FixLuger(ent)
	if(is_valid_ent(ent) && !entity_get_edict(ent,EV_ENT_owner))
		entity_set_model(ent,"models/w_luger.mdl")
		
//////////////////////////////////////////////////////////////
// Drop the weapon
//
public func_WeaponDrop(ent)
{
	if(is_valid_ent(ent) && get_pcvar_num(p_plugin))
		{
		set_task(0.1,"func_ChangeModel",ent)
				
		SetHamReturnInteger(1)

		return HAM_SUPERCEDE
		}
		
	return HAM_IGNORED
}

//////////////////////////////////////////////////////////////
// Fix model after dropping
//
public func_ChangeModel(ent)
{
	if(is_valid_ent(ent))
		{
		new world_ent = entity_get_edict(ent,EV_ENT_owner)
		
		if(world_ent > maxplayers && is_valid_ent(world_ent))
			{
			static classname[32]
			entity_get_string(ent,EV_SZ_classname,classname,31)
	
			if(equal(classname,"weapon_colt"))
				entity_set_model(world_ent,"models/w_colt.mdl")
			else if(equal(classname,"weapon_webley"))
				entity_set_model(world_ent,"models/w_webley_v1.mdl")
			else if(equal(classname,"weapon_luger"))
				entity_set_model(world_ent,"models/w_luger.mdl")
			else if(equal(classname,"weapon_spade"))
				entity_set_model(world_ent,"models/w_spade.mdl")
			}
		}
}

//////////////////////////////////////////////////////////////
// Drop fake weapon on death
//
public func_HamKilled(id)
{
	if(get_pcvar_num(p_plugin))
		{
		new wpnid,weapon_type = -1
		
		//Knife
		if(user_has_weapon(id,DODW_AMERKNIFE))
			{
			wpnid = DODW_AMERKNIFE
			weapon_type = KNIFE_ALLIES
			}
		else if(user_has_weapon(id,DODW_GERKNIFE))
			{
			wpnid = DODW_GERKNIFE
			weapon_type = KNIFE_AXIS
			}
		else if(user_has_weapon(id,DODW_SPADE))
			{
			wpnid = DODW_SPADE
			weapon_type = KNIFE_SPADE
			}
		
		if(weapon_type != -1)
			spawn_weapon(id,KNIFE,weapon_type,wpnid)
	
		//Pistol
		weapon_type = -1
		
		if(user_has_weapon(id,DODW_COLT))
			{
			wpnid = DODW_COLT
			weapon_type = PISTOL_COLT
			}
		else if(user_has_weapon(id,DODW_WEBLEY))
			{
			wpnid = DODW_WEBLEY
			weapon_type = PISTOL_WEBLEY
			}
		else if(user_has_weapon(id,DODW_LUGER))
			{
			wpnid = DODW_LUGER
			weapon_type = PISTOL_LUGER
			}
		
		if(weapon_type != -1)
			{
			new wpnent = dod_get_weapon_ent(id,wpnid)
			new clip = get_pdata_int(wpnent,OFFSET_WPN_CLIP,OFFSET_LINUX)
			
			new backpack
			if(is_linux)
				backpack = get_pdata_int(id,OFFSET_PISTOL_BPAMMO_LINUX,OFFSET_LINUX)
			else
				backpack = get_pdata_int(id,OFFSET_PISTOL_BPAMMO_WIN32,OFFSET_LINUX)
			
#if DOD_WEAPONJAM
			
			new jammed = entity_get_int(wpnent,EV_INT_iuser4)
			spawn_weapon(id,PISTOL,weapon_type,wpnid,clip,backpack,jammed)
			
#else

			spawn_weapon(id,PISTOL,weapon_type,wpnid,clip,backpack)

#endif
			}
			
		return HAM_HANDLED
		}
		
	return HAM_IGNORED
}

//////////////////////////////////////////////////////////////
// Thought process of fake weapons
//
public func_HamThink(ent)
{	
	static classname[32]
	entity_get_string(ent,EV_SZ_classname,classname,31)
			
	if(equal(classname,TEMP_CLASSNAME))
		{
		remove_entity(ent)
				
		return HAM_SUPERCEDE
		}
		
	return HAM_IGNORED
}

//////////////////////////////////////////////////////////////
// Handle touching a fake weapon
//
public func_HamTouch(ent,player)
{
	if(!is_valid_ent(ent) || !is_user_alive(player) || !get_pcvar_num(p_plugin))
		return HAM_IGNORED
		
	static classname[32]
	entity_get_string(ent,EV_SZ_classname,classname,31)
		
	if(equal(classname,TEMP_CLASSNAME))
		{
		new type = entity_get_int(ent,EV_INT_iuser4)
		
		if(!check_weapons(player,type))
			{			
			client_cmd(player,"spk weapons/ammopickup.wav")
			
			static targetname[32]
			entity_get_string(ent,EV_SZ_targetname,targetname,31)
			
			give_item(player,targetname)
			
			new wpnid = entity_get_int(ent,EV_INT_iuser1)
			
			if(wpnid == DODW_COLT || wpnid == DODW_WEBLEY || wpnid == DODW_LUGER)
				{			
				new backpack = entity_get_int(ent,EV_INT_iuser3)
				
				if(is_linux)
					set_pdata_int(player,OFFSET_PISTOL_BPAMMO_LINUX,backpack,OFFSET_LINUX)
				else
					set_pdata_int(player,OFFSET_PISTOL_BPAMMO_WIN32,backpack,OFFSET_LINUX)
				
				message_begin(MSG_ONE_UNRELIABLE,gMsgAmmoX,{0,0,0},player)
				write_byte(AMMO_PISTOL)
				write_byte(backpack)
				message_end()
								
				new clip = entity_get_int(ent,EV_INT_iuser2)
				new wpnent = dod_get_weapon_ent(player,wpnid)
				set_pdata_int(wpnent,OFFSET_WPN_CLIP,clip,OFFSET_LINUX)
				
#if DOD_WEAPONJAM

				new jammed = entity_get_int(ent,EV_INT_iuser1)
				entity_set_int(ent,EV_INT_iuser4,jammed)

#endif

				}
			
			remove_entity(ent)
			
			return HAM_SUPERCEDE
			}
		}

	return HAM_IGNORED
}

//////////////////////////////////////////////////////////////
// Trap the round message and handle
//
public func_RoundState() 
{
	new wpnent = -1		
	while((wpnent = find_ent_by_class(wpnent,TEMP_CLASSNAME)) != 0)
		if(is_valid_ent(wpnent))
			remove_entity(wpnent)
}

//////////////////////////////////////////////////////////////
// Spawn the weapon after dying
//

#if DOD_WEAPONJAM

stock spawn_weapon(id,wpn,type,wpnid,clip=0,backpack=0,jammed=0)
{

#else

stock spawn_weapon(id,wpn,type,wpnid,clip=0,backpack=0)
{

#endif

	static Float:n_info[3],ent
	n_info = Float:{0.0,0.0,0.0}
	
	ent = create_entity("info_target")
	
	if(ent)
		{
		if(wpn == KNIFE)
			{
			entity_set_string(ent,EV_SZ_targetname,KNIVES_NAMES[type])
			entity_set_model(ent,KNIVES_MODELS[type])
			}
		else
			{
			entity_set_string(ent,EV_SZ_targetname,PISTOLS_NAMES[type])
			entity_set_model(ent,PISTOLS_MODELS[type])
			
			entity_set_int(ent,EV_INT_iuser2,clip)
			entity_set_int(ent,EV_INT_iuser3,backpack)
			entity_set_int(ent,EV_INT_iuser4,PISTOL)
			
#if DOD_WEAPONJAM

			entity_set_float(ent,EV_FL_fuser1,float(jammed))
			
#endif
			}
		
		entity_set_string(ent,EV_SZ_classname,TEMP_CLASSNAME)
		
		entity_set_int(ent,EV_INT_iuser1,wpnid)
		
		n_info[1] = get_gametime() + 22.0
		entity_set_float(ent,EV_FL_nextthink,n_info[1])
		
		entity_set_int(ent,EV_INT_solid,SOLID_TRIGGER)
		entity_set_int(ent,EV_INT_movetype,MOVETYPE_TOSS)
		
		n_info[1] = float(random(360))
		entity_set_vector(ent,EV_VEC_angles,n_info)
		
		entity_get_vector(id,EV_VEC_origin,n_info)
		n_info[0] += (random_num(-40,40))
		n_info[1] += (random_num(-40,40))
		entity_set_origin(ent,n_info)
		}
}

stock dod_get_weapon_ent(id,wpnid)
{
	new ent = -1,entid

	new Float:origin[3]
	entity_get_vector(id,EV_VEC_origin,origin)
	
	while((ent = find_ent_in_sphere(ent,origin,0.4)) != 0)
			
		{
		if(is_valid_ent(ent))
			{
			entid = get_pdata_int(ent,OFFSET_WPN_ID,OFFSET_LINUX)
			
			if(wpnid == entid)
				return ent
			}
		}
		
	return 0
}

stock check_weapons(id,type)
{
	switch(type)
		{
		case PISTOL:
			{
			if(dod_weapon_type(id,DODWT_SECONDARY))
				return 1
			else if(user_has_weapon(id,DODW_WEBLEY))
				return 1
			}
		case KNIFE: return dod_weapon_type(id,DODWT_MELEE)
		}
	
	return 0
}




/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1049\\ f0\\ fs16 \n\\ par }
*/
