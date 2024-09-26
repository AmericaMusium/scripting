
#include <amxmodx>
#include <fakemeta>
#include <dodx>
#include <dodfun>
#include <engine>

#define MAX_READYPLAYERS 12

new g_total_registered
new bool:is_player_ready[33] = false


public plugin_init()
{
    register_plugin("DOD ClanMatch","0.0","America")
    register_clcmd("say /ready","Clanmatch_Register")
}


public Clanmatch_Register(idx_player)
{
    is_player_ready[idx_player] = true
    
    g_total_registered = 0
    for (new id = 0; id < get_maxplayers(); id++)
    {
        if(is_player_ready[id]==true)
        {   
            if(is_user_connected(id))
                g_total_registered++
        }
    }

    if(g_total_registered >= MAX_READYPLAYERS)
    {
        Clanmatch_Votemap()

        new sz_cmd[64]
        format(sz_cmd, charsmax(sz_cmd), "mp_clan_match 1")
        server_cmd(sz_cmd)
    }
}

public Clanmatch_Votemap()
{

}
