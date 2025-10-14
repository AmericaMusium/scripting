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
new g_vote_in_progress;
new g_votes_for;
new g_votes_against;

public plugin_init()
{
    register_plugin("DOD dod_ck_bazookaknifemode_vote","0.0","America")
    RegisterHam(Ham_Spawn, "player", "Ham_Spawn_P", 1)
    
    is_bazooka_mode_active = MODE_NOT_ACTIVE
    g_vote_in_progress = 0
    g_votes_for = 0
    g_votes_against = 0

    register_clcmd("say /bkmode", "menu_admin_ask", ADMIN_ALL)
    register_clcmd("say /bkvote", "start_vote", ADMIN_ALL)
}

public start_vote(id, level, cid)
{
    if (!cmd_access(id, level, cid, 1)) return;
    if (g_vote_in_progress)
    {
        client_print(id, print_chat, "The Voting is active now.") // "Голосование уже идет.
        return;
    }

    g_vote_in_progress = 1
    g_votes_for = 0
    g_votes_against = 0

    new menu = menu_create("Turn on bazooka-knife mode?", "vote_handler") // "8Включить режим базукакножа?""
    menu_additem(menu, "Yes", "1", 0)
    menu_additem(menu, "No", "2", 0)

    new players[32], num, player
    get_players(players, num, "ch")
    for (new i = 0; i < num; i++)
    {
        player = players[i]
        if (!is_user_bot(player))
        {
            menu_display(player, menu, 0)
        }
    }

    set_task(15.0, "end_vote")
    client_print(0, print_chat, "Voting started for Bazooka-Knife mode!") /// "Голосование за включение режима Bazooka-Knife началось!")
}

public vote_handler(id, menu, item)
{
    if (item == MENU_EXIT || !g_vote_in_progress)
    {
        menu_destroy(menu)
        return
    }

    if (item == 0)
    {
        g_votes_for++
    }
    else if (item == 1)
    {
        g_votes_against++
    }

    client_print(id, print_chat, "Thanks for vote.")
    menu_destroy(menu)
}

public end_vote()
{
    g_vote_in_progress = 0

    new total_votes = g_votes_for + g_votes_against
    if (total_votes == 0)
    {
        client_print(0, print_chat, "Voting Failed. No one comes.")
        return
    }

    if (g_votes_for > g_votes_against)
    {
        is_bazooka_mode_active = MODE_ACTIVE
        client_print(0, print_chat, "Voting complete. Bazooka-Knife mode on!!")
    }
    else
    {
        is_bazooka_mode_active = MODE_NOT_ACTIVE
        client_print(0, print_chat, "Voting complete. Bazooka-Knife mode off!!")
    }

    if (is_bazooka_mode_active == MODE_ACTIVE)
    {
        for(new id = 1 ; id < get_maxplayers() + 1 ; id++)
        {
            Ham_Spawn_P(id)
        }
    }
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
    client_print(id, print_chat, "/bazooka-knife mode: %d", is_bazooka_mode_active)
    return;
}

public Ham_Spawn_P(idx_player)
{       
    if(!is_user_alive(idx_player)) return
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