#include <amxmodx>
#include <engine>
#include <dodx>
#include <dodfun>

public plugin_init()
{
	register_plugin("DOD RocketFrags","0.1","America")
	// server_print("RocketFrags")
    // RegisterHam(Ham_Killed, "player", "func_firstfunction_afterkill", 1)
    register_event("DeathMsg", "player_died", "a")

}

/*
public client_death(killer,victim,wpnindex,hitplace,TK)
{
    server_print("killer %d ; victim : %d; wpn %d ; hitplace %d; TK %d ", killer,victim,wpnindex,hitplace,TK)
    if (wpnindex==DODW_BAZOOKA)
    {
        server_print("AAAAAAAAAAAAAAAAAAAAAAAA")
    }
}
*/

public player_died()
{   
    /*
	static param[4]
	param[1] = read_data(1)  // KILLER
	param[0] = read_data(2) // VICTIM 
	param[2] = read_data(3) // WEAPON
	param[3] = 0
    
    new i
    for (i=0; i < 4; i++)
    {
        server_print("param %d ; %d", i, param[i] )
    }
    */
    new d = read_data(3) // WEAPON
    if (d == DODW_BAZOOKA || d == DODW_PIAT || d == DODW_PANZERSCHRECK )
    {
		dod_set_user_kills(read_data(1), dod_get_user_kills(read_data(1)) + 1 , 1)
    }
}