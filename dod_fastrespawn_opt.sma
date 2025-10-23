#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>
#include <engine>

#define SPAWN_TIME 2.0
new msg_ResetHud


#define m_irdytospawn 354
#define m_imissedwave 355

public plugin_init()
{
    register_plugin("DOD FASTSPAWN GUARDED", "3.0", "America")
    RegisterHam(Ham_Killed, "player", "on_Ham_Killed_P", 1)
    msg_ResetHud = get_user_msgid("ResetHUD")
}

	

public on_Ham_Killed_P(idx_player)
{
    set_task(SPAWN_TIME ,"player_cheker", idx_player )

}

public player_cheker(idx_player)
{	
    if (!is_user_bot(idx_player) && is_user_connected(idx_player))
        {
        new team_case = get_user_team(idx_player)
        switch (team_case)
        {
            case 1: player_fast_respawn(idx_player)
            case 2: player_fast_respawn(idx_player)
            default: 	
            {
                return;
                /*
                entity_set_int(idx_player, EV_INT_team, 1);	
                player_fast_respawn(idx_player);
                */
            }	
        }
        return;
    }
	else
	    return;
}


public player_fast_respawn(idx_player)
{
	set_pev(idx_player,pev_iuser1,0)
	set_pdata_int(idx_player,264,1) // someone human did found this is needed to use weapons for a forced spawn.
	dllfunc(DLLFunc_Spawn,idx_player)
	// Fastrespawn_1(idx_player)
	set_task(0.5 ,"player_hud_update", idx_player )
}


public player_hud_update(idx_player)
{
    message_begin(MSG_ONE_UNRELIABLE, msg_ResetHud , {0,0,0}, idx_player);
    message_end();
}
/*
public client_putinserver(id)
{
    new namearray[32]
    get_user_name(id, namearray, 31)
	server_print("[DOD FAST SPAWN] %s  connected as %d ", namearray, id )

    if (equal(namearray, "Officer_Mymune"))
    {
	    server_print("[DOD FAST SPAWN] if %s  connected as %d ", namearray, id )
	    set_task(2.0, "fn_joinTeam1", id )
	}
    if(equal(namearray, "America"))
    {	
	    server_print("[DOD FAST SPAWN] if %s  connected as %d ", namearray, id )
	    set_task(1.0, "fn_joinTeam2", id )
    }
}

public fn_joinTeam1(id)
{
	server_print("[DOD FAST SPAWN] set taks complete for %d ",  id )
	client_cmd(id, "jointeam 1")
	client_cmd(id, "cls_garand")
    settaa(id)
}
public fn_joinTeam2(id)
{
	server_print("[DOD FAST SPAWN] set taks complete for %d ",  id )
	client_cmd(id, "jointeam 2")
	client_cmd(id, "cls_k98")
    settaa(id)
}
*/