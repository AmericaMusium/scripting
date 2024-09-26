#include <amxmodx>
#include <dodx>
#include <dodfun>
#include <hamsandwich>



public plugin_init()
{
	register_plugin("DOD BOT DAMAGE LESS","0.0","America")
	server_print("DOD BOT DAMAGE LESS")
    RegisterHam ( Ham_TakeDamage, "player", "UserTakeDamage")
}

public UserTakeDamage ( victim, weapon, attacker, Float:damage, damagebits )
{
    if (!is_user_bot(attacker) || !is_user_alive(victim) || is_user_bot(victim)) 
    {
        return HAM_IGNORED
    }
    else if(is_user_bot(attacker))
    {
        new float:rdmg = damage * 0.3
        //reduce attack
        SetHamParamFloat(4, rdmg)
        // return HAM_SUPERCEDE

    }
    else return HAM_IGNORED
}