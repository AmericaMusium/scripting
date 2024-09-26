#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <engine>
#include <xs>
#include <dodx>
#include <dodfun>

#define SCOOPED 1
#define NO_SCOOPED 0
#define UPDATE_TIME 0.3
#define UnitsToMeters(%1)	(%1*0.0254)
#define UnitsToMeters(%1)	(%1*0.0254)
#define UnitsToInches(%1)	(%1*1.00000054)
#define UnitsToFeet(%1)		(%1*0.08333232)
#define UnitsToYards(%1)	(%1*0.02777744)
#define UnitsToKM(%1)		(%1*0.0000254)
#define UnitsToMiles(%1)	(%1*0.00001524)

new topmatch_kills[33] = 0
new topround_kills[33] = 0

public plugin_init()
{
    register_plugin("DOD Sniper data","0.1","America")

    // registering snipeerskkills for top_snipers
    register_event("DeathMsg", "on_DeathMsg", "a")
}



// Enable HUD distance data
public dod_client_scope(id, value)
{
    switch (value)
    {
        case SCOOPED:
        {
            set_task(1.0, "sniper_hud_distance_update", id)
        }
        case NO_SCOOPED:
        {   
            client_print(id, print_center, " ")
            remove_task(id)
            return PLUGIN_CONTINUE
        }
    }
    return PLUGIN_CONTINUE
}

public sniper_hud_distance_update(idx_player)
{   
    // Get player's target origin
    new iOrigin_player[3]
    new iOrigin_aiming[3]
    get_user_origin(idx_player, iOrigin_player, 1) 
    get_user_origin(idx_player, iOrigin_aiming, 3) 
    new distance = get_distance(iOrigin_player, iOrigin_aiming)
    new f_print_distance = float(distance)
    new i_distance = floatround(UnitsToMeters(distance))
    client_print(idx_player, print_center, " %d meters ", i_distance)
    set_task(UPDATE_TIME, "sniper_hud_distance_update", idx_player)
}

public on_DeathMsg()
{   
    /*
	static param[4]
	param[1] = read_data(1)  // KILLER
	param[0] = read_data(2) // VICTIM 
	param[2] = read_data(3) // WEAPON
	param[3] = 0
    */
    new k =  read_data(1)  // KILLER
    new w = read_data(3) // WEAPON
    if (w == DODW_SCOPED_KAR || w == DODW_SPRINGFIELD || w == DODW_SCOPED_ENFIELD || w == DODW_SCOPED_FG42)
    {

    topmatch_kills[k]++
    topround_kills[k]++
    client_print(0, print_chat, " SNIPERSHOT !! total match kills: %d | round kills %d", topmatch_kills[k] , topround_kills[k])
    }   
}