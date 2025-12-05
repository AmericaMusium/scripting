#include <amxmodx>
#include <hamsandwich>


new g_msgDeathMsg


public plugin_init()
{
    register_plugin("HUD HeadShot", "1.0", "ACF Deluxe");
    g_msgDeathMsg = get_user_msgid("DeathMsg");
    // set_msg_block(g_msgDeathMsg, BLOCK_SET);
}

public client_death(idx_killer, idx_victim, id_weapon, hitplace, TK)
{   
    if(hitplace == HIT_HEAD && idx_killer)
    {
        fx_death_message(idx_killer, 0, id_weapon);
    }
}


public fx_death_message(killer, victim, dodw_id)
{
    message_begin(MSG_ALL, g_msgDeathMsg, {0,0,0}, 0);
    write_byte(killer); // killer
    write_byte(victim); // victim
    write_byte(dodw_id);  // weapon id
    message_end();
}