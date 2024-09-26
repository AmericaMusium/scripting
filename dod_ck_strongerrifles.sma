#include <amxmodx>
#include <fakemeta>
#include <dodx>
#include <hamsandwich>
#include <engine>

public plugin_init()
{
	register_plugin("DoD Stronger Rifles", "[ck]","America")	
	RegisterHam(Ham_TakeDamage,"player","func_TakeDamage")	
}

public func_TakeDamage(id,inflictor,attacker,Float:damage,damagebits)
{ 
	// bits 64 == nades //4226 SPADE // 32896 = K98KNIFE / 65664 = buttgarand
	
	if( is_user_bot(attacker))
		return HAM_IGNORED
	
	new weapon = dod_get_user_weapon(attacker,_,_)
	if((weapon == DODW_GARAND) 
	|| (weapon == DODW_K43)
	|| (weapon == DODW_KAR) 
	|| (weapon == DODW_ENFIELD)) 
	{
		// victim , weapon , wpnsowner=attaker , dmg , type 
		ExecuteHam(Ham_TakeDamage, id, inflictor , attacker, 200.0 , damagebits)
		/*
		damage = 400.0	
		SetHamParamFloat(4, 400.0)
		*/
		return HAM_IGNORED
		
	}
	/*
	if (weapon == DODW_HANDGRENADE || weapon == DODW_STICKGRENADE)
	{	
		//client_print(0, print_chat, "nade damage 1 %f", damage)
		damage *= 0.30
		SetHamParamFloat(4, damage)
		//client_print(0, print_chat, "nade damage 2 %f", damage)
		return HAM_OVERRIDE
	}
	*/
	else
		return HAM_IGNORED
}
