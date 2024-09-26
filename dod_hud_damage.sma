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
    if(is_user_alive(attacker))
    {
    set_hudmessage(250, 100, 100, 0.5, 0.5, 0 , 0.0 , 0.0 , 3.0, 0.0 , 2)
    show_hudmessage(attacker, "%.0f", damage)
    }

}