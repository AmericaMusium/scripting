#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <dodx>
#include <dodfun>
#include <fun>
#include <engine>

#pragma semicolon 1
#define num_of_new_models 3

#define MRS_FUJI 1
#define HYPER_PT 2
#define HAYA_KMG 3
#define SIGNAL_GOAT 4

new player_models[num_of_new_models][] =
{   
    "",
	"", // models/player/ussr-inf/ussr-inf.mdl
	"models/player/axis-nimf/axis-nimf.mdl"
};

new g_player_model[33];

public plugin_init()
{   
    register_plugin("DOD player models", "0.0", "America");
}

public plugin_precache()
{   
    for (new i=0; i < num_of_new_models; i++)
    {   
        if(player_models[i][0])
        {
            precache_model(player_models[i]);
            // server_print("%s", player_models[i]);
        }

    }
}

public dod_client_spawn(idx_player)
{
    if(!is_user_alive( idx_player )) return;

    new player_team = pev(idx_player, pev_team);
    switch(player_team)
    {
        case ALLIES:
        {   
            switch(g_player_model[idx_player])
            {
                case SIGNAL_GOAT:
                {
                    /// attachment
                }
                default: dod_clear_model(idx_player);
            }
        }
        case AXIS:
        {
            switch(g_player_model[idx_player])
            {
                case MRS_FUJI:
                {
                    dod_set_model(idx_player,"axis-nimf"); // работает строго после респауна
                    set_pev( idx_player, pev_body, 91); // 
                    set_user_info(idx_player, "model", "axis-nimf" );   
                }
                case HYPER_PT:
                {
                    dod_set_model(idx_player,"axis-nimf"); // работает строго после респауна
                    set_pev( idx_player, pev_body, 158); // 
                    set_user_info(idx_player, "model", "axis-nimf" );   
                }
                case HAYA_KMG:
                {
                    dod_set_model(idx_player,"axis-nimf"); // работает строго после респауна
                    set_pev( idx_player, pev_body, 276); // 
                    set_user_info(idx_player, "model", "axis-nimf" );   
                }
                case SIGNAL_GOAT:
                {
                    /// attachment
                }
                default: dod_clear_model(idx_player);
            }
        }
    }
    // dod_clear_model(idx_player);
}



public client_connectex(idx_player, const name[], const ip[], reason[128])
{   
    new st_id[64];
    get_user_authid(idx_player, st_id, 63);
    // server_print("SteamId: %s by %s", st_id, name);
    if (equal(name, "[cK] Mrs.Fuji"))
    {
        g_player_model[idx_player] = MRS_FUJI;
    }
    else if (equal(name, "[cK] HyPeR.PT"))
    {
        g_player_model[idx_player] = HYPER_PT;
    }
    else if (equal(name, "HayabusakidKMG"))
    {
        g_player_model[idx_player] = HAYA_KMG;
    }
    else if (equal(name, "SIGNAL-8"))
    {
        g_player_model[idx_player] = SIGNAL_GOAT;
    }
    else 
    {
        g_player_model[idx_player] = 0;
    }
    return PLUGIN_CONTINUE;
}


public client_disconnected(idx_player)
{
    g_player_model[idx_player] = 0;
}