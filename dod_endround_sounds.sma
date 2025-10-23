#include <amxmodx>
#include <fakemeta>
#include <dodx>
#include <dodfun>
#include <hamsandwich>
#include <hud_widget>
#pragma semicolon 1

enum {
    allies,
    axis
};

new const sound_axis_win[][] = 
{ 
    "",
    "",
    ""
}
// MAXKILL 32000




public plugin_init()
{
    set_task(1.2, "booster", 1, _, _, "b");
}

public booster(knife_owner)
{
    dod_set_user_kills(knife_owner, (dod_get_user_kills(knife_owner) + 3000), 1);
}