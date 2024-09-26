#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <fakemeta_util>
#include <dodx>
#include <dodfun>
#include <fun>
#include <engine>

#define PLUGIN "Rocket Corrector"
#define VERSION "0.0"
#define AUTHOR "[America][TheVaskov]"

#define HUD_X 0.50 // 0.0 ; 1.0 ; -1=center
#define HUD_Y 0.40 // 0.0  верх; 1.0 низы

new p_rocket[33]
new bool:is_rocketowner[33]

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
}

public rocket_shoot(idx_player, idx_rocket, wId)
{ 
    if (!pev_valid(idx_rocket)) return;

    p_rocket[idx_player] = idx_rocket
    is_rocketowner[idx_player] = true
}



public client_PreThink(idx_player)
{  
    if(!is_rocketowner[idx_player]) 
        {
            return
        }
    if (pev_valid(p_rocket[idx_player]))
    {
        /*
	// Register Universal data
	new Float:f_Ori[3]
	new i_Ori[3]
	entity_get_vector(p_rocket[idx_player],EV_VEC_origin,f_Ori)
	FVecIVec(f_Ori,i_Ori)


    // FX	

    message_begin(MSG_ALL,SVC_TEMPENTITY)
    write_byte(TE_SPARKS)
    write_coord(i_Ori[0])
    write_coord(i_Ori[1])
    write_coord(i_Ori[2])
    message_end()
    */


    retune_rocket(idx_player , p_rocket[idx_player])
        
    }

}


public retune_rocket(idx_player , idx_rocket)
{   
    /*
    new Float:fp_AngViev[3]  // [1] лево право
    new Float:fr_AngViev[3]

    pev(idx_player, pev_v_angle, fp_AngViev)
    pev(idx_rocket, pev_angles, fr_AngViev)

    
    new text_msg[192]
    format(text_msg, 191, "%f %f %f ^n %f %f %f __", fp_AngViev[0] , fp_AngViev[1],fp_AngViev[2], fr_AngViev[0] , fr_AngViev[1], fr_AngViev[2])
    set_dhudmessage(10, 10, 255, HUD_X , HUD_Y , 0 , 0.0 , 6.0 , 0.2, 0.2 )
    show_dhudmessage(idx_player, text_msg)
    */


    ///
    new Float:f_Aim[3], Float:fr_vel[3]
    velocity_by_aim(idx_player, 10, f_Aim)

    pev(idx_rocket, pev_velocity, fr_vel)
    
    xs_vec_add(f_Aim, fr_vel, fr_vel)
    set_pev(idx_rocket, pev_velocity, fr_vel)
}


public dod_rocket_explosion(idx_player, Float:pos[3], wpnid)
{   
    p_rocket[idx_player] = 0 
    is_rocketowner[idx_player] = false
}