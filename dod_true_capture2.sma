#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <fakemeta_util>
#include <dodx>
#include <dodfun>
#include <fun>
#include <engine>



public plugin_precache()
{
    return 0
}

public plugin_init()
{
   
	register_plugin("DOD Capture Flag", "may", "America")
    
    register_event("ObjScore","get_score","a") // Событие назначения очков при захвате флага. player , points
    register_event("CapMsg","Event_CapMsg_Post","a") // Событие событие после захвата флага
    
}

public Event_CapMsg_Post(idx)
{
    // Player capture register info
    new id_player =  read_data(1)
    new id_team =  read_data(3)
    client_print(0, print_chat, "Event_CapMsg_Post: idx %d : id_team %d", id_player, id_team)

}









/*
CA_sprite == sprites/mapsprites/caparea.spr // спрайт с левой стороны захвата
CA_target == targetname of


Set flag captured by 1 == allies , 2==axis, 0 = neutral 
objective_set_data(i,CP_owner,2)
objectives_reinit(0)


s(g)et flag position on HUD map "m"
objective_set_data(i,CP_origin_x,1170)
objectives_reinit(0)
*/

public get_score()
{
    // Get current value player points after capture
    new PlayerID = read_data(1) 
    new PlayerScore = read_data(2) 
    new arg1 = read_data(3) 
    /*
    server_print("Event ObjScore: Player %d : Points %d", PlayerID, PlayerScore)
    client_print(0, print_chat, "DOD TREUCAP2: Player %d : Points %d", PlayerID, PlayerScore)
    */


}


public controlpoints_init()
{   
    // Event INITIAL at map start FLAGS before game starts
    
}

