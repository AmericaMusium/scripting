#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>
#include <dodx>
#include <dodfun>
#include <fun>
#include <engine>
#include <fakemeta>

#define MODE_NOT_ACTIVE 0
#define MODE_ACTIVE 1


// global vars
new is_bazooka_mode_active;

public plugin_init()
{
    register_plugin("DOD Custom Equipments by SteamID","0.0","America")
    RegisterHam(Ham_Spawn, "player", "Ham_Spawn_P", 1)
    
    is_bazooka_mode_active = MODE_NOT_ACTIVE

    register_clcmd("say /bkmode", "menu_admin_ask", ADMIN_ALL)

}


public menu_admin_ask(id, level, cid)
{
    if (!cmd_access(id, level, cid, 1)) return;
    switch (is_bazooka_mode_active)
    {
        case MODE_NOT_ACTIVE: 
        {
            is_bazooka_mode_active = MODE_ACTIVE
            for(new id = 1 ; id < get_maxplayers() + 1 ; id++)
                {   
                    Ham_Spawn_P(id)
                }
        }
        case MODE_ACTIVE: is_bazooka_mode_active = MODE_NOT_ACTIVE
    }
    client_print( id, print_chat, "/bazooka-knife mode: %d", is_bazooka_mode_active)
    return;
}


public Ham_Spawn_P(idx_player)
{	
    if(!is_user_alive( idx_player )) return
    if(is_bazooka_mode_active == MODE_ACTIVE)
    {   


        strip_user_weapons(idx_player);
        new player_team = get_user_team(idx_player)
        switch (player_team)
        {
            case ALLIES:
            {
                give_item(idx_player, "weapon_bazooka")
                give_item(idx_player, "weapon_amerknife")

            }
            case AXIS:
            {
                give_item(idx_player, "weapon_pschreck")
                give_item(idx_player, "weapon_spade")
            }
            default: return
        }
    }
}