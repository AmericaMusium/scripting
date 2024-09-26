#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>
#include <dodx>
#include <dodfun>

new idx_admin = 0
new const STID_ADMIN[] = ""

public plugin_init()
{
    register_plugin("NEW dod_cK_admin_custom_models","0.1","America")
    RegisterHam(Ham_Spawn, "player", "Ham_Spawn_P", 1)
}

public plugin_precache()
{
	precache_model("models/w_knifepack.mdl")
}

public client_putinserver(id)
{	
if (is_user_bot(id)) return PLUGIN_CONTINUE

new authid[64]
get_user_authid(id, authid, charsmax(authid))

if(equal(authid, STID_ADMIN))
{
    idx_admin = id
}
if(!is_user_connected(id)) 
{
    return PLUGIN_CONTINUE;
}
return PLUGIN_CONTINUE;
}


public Ham_Spawn_P(idx_player)
{	
if(!is_user_alive( idx_player )) return

if(idx_admin == idx_player)
{
new player_team = get_user_team(idx_player)


switch (player_team)
{
    case ALLIES:
    {
        dod_clear_model(idx_player)
        // dod_set_model(idx_player,"ussr-inf")
    }
    case AXIS:
    {
        dod_clear_model(idx_player)
        // dod_set_model(idx_player,"ussr-inf")
    }


}
}
}