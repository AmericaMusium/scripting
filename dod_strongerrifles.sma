//////////////////////////////////////////////////////////////////////////////////
//
//	DoD Stronger Rifles
//		- Version 1.1
//		- 01.11.2009
//		- diamond-optic
//
//////////////////////////////////////////////////////////////////////////////////
//
// Information:
//
// 	- Allows you to set custom damage values for the Garand & K43
//
//	- Default CVAR values leave everything as normal except
//	  arm shots will be 100dmg (111%)
//
///////////////////////////////////////////////////////////////
//
// CVARs: 
//
//	dod_stronger_rifles "1" 		//turn ON(1)/OFF(0)
//	dod_stronger_rifles_m1 "1" 		//enable M1 Garand
//	dod_stronger_rifles_k43 "1" 		//enable for K43
//
//	dod_stronger_rifles_head "100"		//Damage % for head shots
//	dod_stronger_rifles_chest "100"		//Damage % for chest shots
//	dod_stronger_rifles_stomach "100"	//Damage % for stomach shots
//	dod_stronger_rifles_arms "111"		//Damage % for arm shots 
//	dod_stronger_rifles_legs "100"		//Damage % for leg shots
//
///////////////////////////////////////////////////////////////
//
// Extra:
//
// 	DoD Default Damage Values:
//
//		Head:	 300
//		Chest:	 120
//		Stomach: 120
//		Arms:	  90
//		Legs:	  90
//
///////////////////////////////////////////////////////////////
//
// Changelog:
//
//	- 12.18.2006 Version 1.0
//		Initial Release
//
//	- 01.11.2009 Version 1.1
//		Removed amxmisc include
//		Removed registering the stats forward
//		Totally new method using hamsandwich
//		Now allows you to set damage % values yourself
//
//////////////////////////////////////////////////////////////////////////////////

#include <amxmodx>
#include <fakemeta>
#include <dodx>
#include <hamsandwich>

#define VERSION "1.1"
#define SVERSION "v1.1 - by diamond-optic (www.avamods.com)"

new p_strong,p_m1,p_k43
new p_head,p_chest,p_stomach,p_arms,p_legs
new hitbox[33]
new g_iMaxPlayers

public plugin_init()
{
	register_plugin("DoD Stronger Rifles",VERSION,"AMXX DoD Team")
	register_cvar("dod_stronger_rifles_stats",SVERSION,FCVAR_SERVER|FCVAR_SPONLY)
	
	RegisterHam(Ham_TakeDamage,"player","func_TakeDamage")
	RegisterHam(Ham_TraceAttack,"player","func_TraceAttack")
	
	g_iMaxPlayers = get_maxplayers()
	
	p_strong = register_cvar("dod_stronger_rifles","1")
	
	p_m1 = register_cvar("dod_stronger_rifles_m1","1")
	p_k43 = register_cvar("dod_stronger_rifles_k43","0")
	
	p_head = register_cvar("dod_stronger_rifles_head","100")
	p_chest = register_cvar("dod_stronger_rifles_chest","100")
	p_stomach = register_cvar("dod_stronger_rifles_stomach","100")
	p_arms = register_cvar("dod_stronger_rifles_arms","111")
	p_legs = register_cvar("dod_stronger_rifles_legs","100")
}

public func_TraceAttack(id,idattacker,Float:damage,Float:direction[3],traceresult,damagebits)
{
	if(!get_pcvar_num(p_strong))
		return HAM_IGNORED

	hitbox[id] = get_tr2(traceresult,TR_iHitgroup)

	return HAM_IGNORED
}

public func_TakeDamage(id,inflictor,attacker,Float:damage,damagebits)
{ 
	if(!get_pcvar_num(p_strong) || !(1 <= attacker <= g_iMaxPlayers) || !(1 <= id <= g_iMaxPlayers) || !is_user_alive(id) || !is_user_connected(attacker))
		return HAM_IGNORED
	
	new weapon = dod_get_user_weapon(attacker,_,_)
	
	if((weapon == DODW_GARAND && get_pcvar_num(p_m1)) || (weapon == DODW_K43 && get_pcvar_num(p_k43)))
		{
		switch(hitbox[id])
			{
			case HIT_HEAD: damage=float(floatround(get_pcvar_float(p_head) / 100 * damage))
			case HIT_CHEST: damage=float(floatround(get_pcvar_float(p_chest) / 100 * damage))
			case HIT_STOMACH: damage=float(floatround(get_pcvar_float(p_stomach) / 100 * damage))
			case HIT_LEFTARM,HIT_RIGHTARM: damage=float(floatround(get_pcvar_float(p_arms) / 100 * damage))
			case HIT_LEFTLEG,HIT_RIGHTLEG: damage=float(floatround(get_pcvar_float(p_legs) / 100 * damage))
			}
			
		SetHamParamFloat(4,damage)
		
		return HAM_HANDLED
		}
	
	return HAM_IGNORED
}
