#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fun>
#include <hamsandwich>
#include <fakemeta>


new bool:is_enable_hud_damage[33]

public plugin_init()
{
    RegisterHam(Ham_TakeDamage, "player", "on_TakeDamage_Post", 1)


    // правильный цикл по maxpl
    for(new id = 1 ; id < get_maxplayers()+ 1 ; id++)
    {   
         // = 32 
        is_enable_hud_damage[id] = false
    }

}

public on_TakeDamage_Post(victim, inflictor, attacker, Float:damage, damage_type)
{
    if(is_user_alive(attacker) && Util_Should_Message_Client( attacker ))
    {
    set_hudmessage(250, 100, 100, 0.5, 0.5, 0 , 0.0 , 0.0 , 3.0, 0.0 , 2)
    show_hudmessage(attacker, "%.0f", damage)
    }
}



public Util_Should_Message_Client( id )
{
    if( id == 0 || id > MAX_PLAYERS )
    {
        return false;
    }

    if( is_user_connected( id ) && !is_user_bot( id ) && is_user_alive(id) )
    {
        return true;
    }

    return false;
} 