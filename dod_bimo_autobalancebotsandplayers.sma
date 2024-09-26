#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <dodx>
#include <dodfun>

public plugin_init()
{
	register_plugin("DOD humanwithbots","0.0","America")
    server_print("DOD humanwithbots")

    register_clcmd("jt","handle_teamjoin")
}


public handle_teamjoin(id)
{   
    new als, axs, dsb, tmp

    new tals[32]
    new taxs[32]
    // if (razn > 2) || someteam == 0 && total => 1) 
    new Players[32]
	new count, i, player 
	get_players(Players, count, "ch")
    for (i=0; i < count; i++) 
    {   
        // каждому игроку. 
        player = Players[i]
        tmp = get_user_team(player)
        if( tmp == ALLIES) 
        {
            tals[als] = player
            als++

        }
        else if(tmp == AXIS) 
        {
            taxs[axs] = player
            axs++
        }
    }
    
    if (als>axs)
    {
        dsb = als - axs
        if (dsb>=1) 
        {
            if(axs) client_cmd((tals[random_num(0,als)]),"jointeam 2")
            if((!axs) && dsb > 1) client_cmd((tals[random_num(0,als)]),"jointeam 2")
            return PLUGIN_CONTINUE
        }
    }
    else if (axs>als)
    {
        dsb = axs - als
        if (dsb>=1) 
        {
            if(als) client_cmd((taxs[random_num(0,axs)]),"jointeam 1")
            if((!als) && dsb > 1) client_cmd((taxs[random_num(0,axs)]),"jointeam 1")
            return PLUGIN_CONTINUE
        }
    }
}
