#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>
#include <fakemeta_util>
#include <fun>
#include <dodx>
#include <dodfun>
#include <dodconst>
#include <dodstats>
#include <hamsandwich>

new const g_sprt_mdl[] = "sprites/icon_ussr.spr" 
new hud_flag_icon2
public plugin_init()
{
    register_plugin("HL EVENTS", "0.0", "America")
    register_event("AmmoPickup", "AmmoPickup_P", "a")
    register_event("ClientAreas", "ClientAreas_P", "a")
    register_clcmd("say 22","ClientAreas_F")
}


public plugin_precache()
{
	hud_flag_icon2 = precache_model(g_sprt_mdl)
}

public AmmoPickup_P()
{
    client_print(0, print_chat, "AmmoPickup_P")
}


public ClientAreas_P(id)
{
    client_print(0, print_chat, "ClientAreas_P")
}

public ClientAreas_F(id)
{

    new ClientAreas_M = get_user_msgid("ClientAreas")	// Add your code here...
    message_begin(MSG_ONE,ClientAreas_M,{0,0,0},id)
    write_byte(1)  // 1 = block manual swtich weapon, hide ammo
    write_byte(-1)  // 1 = block manual swtich weapon, hide ammo
    write_string(g_sprt_mdl);
    message_end()

    client_print(0, print_chat, "ClientAreas_F")
}



