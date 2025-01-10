#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <fun>
#include <dodx>
#include <dodfun>
#include <hamsandwich>
#pragma semicolon 1

new g_LastWeapon[33] = 0;
new msg_ResetHud;

public plugin_init()
{
register_plugin("DOD Crosshair fix", "0.0", "America");
msg_ResetHud = get_user_msgid("ResetHUD");
register_event("CurWeapon", "CurWeapon_P", "be", "1=1");
}

public CurWeapon_P(idx_player)
{  
    new weapon = read_data(2);
    if (g_LastWeapon[idx_player]!= weapon)
    { 
    // weapon changed//  
    message_begin(MSG_ONE_UNRELIABLE, msg_ResetHud , {0,0,0}, idx_player);
    message_end();
    g_LastWeapon[idx_player] = weapon;
    }
    return PLUGIN_CONTINUE;


}

