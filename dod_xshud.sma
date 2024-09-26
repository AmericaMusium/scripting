#include <amxmodx>
#include <fakemeta>
#include <xs>

#define PLUGIN "New Plug-In"
#define VERSION "1.0"
#define AUTHOR "author"


new Float:origin[33][3]

public plugin_init() 
{
    register_plugin(PLUGIN, VERSION, AUTHOR)
    
    register_clcmd("say test", "aim_cross_change")
}



public updateHud(id) {

    
    new Float:angles[3];


    new Float:v_forward_1[3], Float:velocity[3];
    new Float:anglevec_2[3]

	pev( id, pev_v_angle, v_forward_1 );
    pev( id+1, pev_v_angle, anglevec_2 );

    // Вычисляем направление взгляда игрока
	engfunc( EngFunc_MakeVectors, v_forward_1 );
	global_get( glb_v_forward, v_forward_1 )
    //  0.971279 -0.226437 -0.073086 

    /*
    engfunc( EngFunc_MakeVectors, anglevec_2 );
	global_get( glb_v_forward, anglevec_2 )
    */
    get_user_origin(id, origin[id]);
    get_user_origin(id+1, origin[id+1]);

    new name[32]
    get_user_name(id+1, name, 31)

    // Вычисляем угол между направлением взгляда игрока и направлением на игрока 2
    new Float:angle_to_player2 = angle_between_vectors(v_forward_1, origin[id+1]);

    // Если угол меньше определенного порога, то игрок 2 находится в области видимости игрока 1
    if (angle_to_player2 < 45.0) {
        client_print(id, print_chat, "Player 2 is visible! %f %f %f " , v_forward_1[0], v_forward_1[1], v_forward_1[2]); // Выводим сообщение о видимости игрока 2
    }



}

public angle_between_vectors(float:v1[3], float:v2[3]) 
{
    new Float:dot = v1[0] * v2[0] + v1[1] * v2[1] + v1[2] * v2[2];

    new Float:magnitude_v1 = xs_rsqrt(v1[0] * v1[0] + v1[1] * v1[1] + v1[2] * v1[2]);
    new Float:magnitude_v2 = xs_rsqrt(v2[0] * v2[0] + v2[1] * v2[1] + v2[2] * v2[2]);

    new Float:cos_angle = dot / (magnitude_v1 * magnitude_v2);
    return xs_acos(cos_angle, (180.0 / M_PI));
}


public aim_cross_change(id)
{



}