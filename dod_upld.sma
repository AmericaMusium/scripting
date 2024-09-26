#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <fakemeta_util>
#include <dodx>
#include <dodfun>
#include <fun>
#include <engine>


#define m_pActiveItem 278 

public plugin_init()
{
    //register_event("HLTV", "OnHltv", "b");
    register_event("player_connect", "OnPlayerConnect", "a");
}

public OnPlayerConnect(id)
{
    // Set a custom icon for the player's radar
    set_pdata_string(id, pNetname, "icon player");
}