#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>
#include <fakemeta_util>
#include <fun>
#include <dodx>
#include <dodfun>
#include <dodconst>
#include <dodstats>
#include <dod_stocks>
#include <hamsandwich>
#include <xs>
#include <dhudmessage>

new const g_tankcname[] = "rc_tank" //Classname  entity
new const g_tankmdl[] = "models/red/tiger/rc_tiger.mdl" 

#define THINK_FRAME 0.1
#define TANK_SPEED 320

new g_players_tank[33]
new g_tanks_owner[2048]
new g_maxtanks 
new const LIMIT_TANKS = 99

/// Для плавного хранения данных выводим массивы, при создании массива внутри функции он имеет нулевое значение,
// нужно исключить сброс положения объекта.
static Float: f_pl_angles[3]
static Float: f_tank_angles[3]
static Float: f_origin[3]
static Float: pl_velocity[3]


    new float:ang_p[3]
    new Float:fAngViev[3]
    new Float:ff_origin[3];
    new Float:ff_end[3];
    new Float:normal[3];
    new Float:angles[3];
    new Float:normal_p[3];
    new float: f_cos_r 
    new float: f_ang_cos 
    new float: f_ang_sin
    new float: angp_0
    new float: angp_1 
    


public plugin_init()
{
    register_plugin("DOD RC TANK", "0.0", "America")
    register_clcmd("say /rc", "tank_create")
    register_think("rc_tank", "tank_think")
    register_touch(g_tankcname, "player", "tank_touch") 
}
public plugin_precache()
{
	precache_model(g_tankmdl) 
} 


public tank_create(id)
{
    if (g_maxtanks == LIMIT_TANKS) return PLUGIN_CONTINUE
    if(is_user_connected(id) && is_user_alive(id))
	{ 	
		new iOrigin[3] //    
		get_user_origin(id, iOrigin, 3)  //    looks
		iOrigin[2] += 100
		new Float:fOrigin[3] //   float 
		IVecFVec(iOrigin, fOrigin) //     
		//// CREATE ENITY 
		new id_tank = create_entity("info_target")	
		set_pev(id_tank, pev_classname, g_tankcname) 
		// Если нужно что бы разбивалось от пули , надо менять на 
		// SOLID_BBOX и менять точку старта, а то задевае игрока
		set_pev(id_tank, pev_origin, fOrigin)
		if(!pev_valid(id_tank)) return PLUGIN_HANDLED     
        engfunc(EngFunc_SetModel, id_tank, g_tankmdl)
        /// ШИРИНА, ДЛНИНА К ДУЛУ , ВЫСОТА
        engfunc(EngFunc_SetSize, id_tank, Float:{-120.0, -100.0, -70.0}, Float:{120.0, 100.0, 50.0}) //   entity(      )
        set_pev(id_tank, pev_friction, 0.5)
        set_pev(id_tank, pev_gravity, 1.0)
        set_pev(id_tank, pev_solid, SOLID_SLIDEBOX) 
        set_pev(id_tank, pev_movetype, MOVETYPE_PUSHSTEP) 
        set_pev(id_tank, pev_nextthink, halflife_time() + THINK_FRAME)  
        set_pev(id_tank, pev_health, 400.0)
	    set_pev(id_tank, pev_takedamage, 1.0)
        g_tanks_owner[id_tank] = 0 
        g_players_tank[id] = 0
        g_maxtanks++

	}
	return PLUGIN_HANDLED
} 


public tank_think(id_tank)
{
    if(!is_valid_ent(id_tank)) return PLUGIN_CONTINUE
    

    if(g_tanks_owner[id_tank] == 0) 
    {   
        client_print(0, print_chat, "tank free")
        set_pev(id_tank, pev_nextthink, 0.0 )//  halflife_time() + 2.0)  
        return PLUGIN_CONTINUE
    }
    if(g_tanks_owner[id_tank] != 0)
    {
    new idowner = g_tanks_owner[id_tank]
    new buttonpress = 0
    
    // Input buttons
    buttonpress = pev(idowner, pev_button)
    if (buttonpress & IN_FORWARD)
    {
        velocity_by_aim ( idowner, TANK_SPEED, pl_velocity )
        pl_velocity[2] = -50.0
        set_pev(id_tank, pev_velocity, pl_velocity)
    }
    if (buttonpress & IN_USE)
    {
       tank_switch(idowner, id_tank, 0)
    }

    else if (buttonpress & IN_BACK)
    {
        velocity_by_aim ( idowner, -TANK_SPEED, pl_velocity )
        pl_velocity[2] = -50.0
        set_pev(id_tank, pev_velocity, pl_velocity)
        
    }

    pev(idowner, pev_v_angle, fAngViev)
    // SEND RETUNE AMGLES
    //pev(id_tank, pev_angles, f_tank_angles)
    pev(idowner, pev_angles, f_pl_angles)
    //f_tank_angles[1] = f_pl_angles[1] // лево право
    //set_pev(id_tank, pev_angles, f_tank_angles)
   
    /*
    new Float: hudy = (fAngViev[0] + 90.0 ) / 180.0 
    set_hudmessage(130, 40, 10, 0.52, hudy , 0, 0.8, 0.4, 0.1, 0.1, -1) // // ВЕРХ == 0.0 , центр == 0,5 . 1.0 == полный низ. 
	show_hudmessage(idowner, " _xxx %f", -fAngViev[0])
    // client_print(idowner, print_center, "HORIZONT ANGLE: %i ", (-1*floatround(fAngViev[0]))  )
    pev(id_tank, pev_origin, ff_origin);
    ff_origin[2] += 20.0
    
 
    show_hudmessage(0, "крендула ang_p[0] %f, ^n Поворот:%f cos:%f sin:%f  " , ang_p[0] ,f_pl_angles[1],  f_ang_cos , f_ang_sin )
    set_hudmessage(0, 255, 0, 0.3, 0.40 , 0, 6.0, 6.0)
    */
    ang_p[1] = f_pl_angles[1]
    //ang_p[0] = 90.0
    set_pev(id_tank, pev_angles, ang_p);

    UpdateTerrain(id_tank, ang_p)

   
    // BREFORE OPTIMIZE 
    /*
    f_ang_cos = ((floatabs(f_pl_angles[1])) -90.0)/90 // прямой множител нормали 0 
    f_ang_sin = 1.0 -(floatabs(f_ang_cos)) // прямой множител нормали 0 модулем
    new ff_ang_cos = ((floatabs(f_pl_angles[1])) -90.0)/90 // прямой множител нормали 0 
    f_ang_cos = round_down(ff_ang_cos)
    f_ang_sin = 1.0 -(floatabs(f_ang_cos))
    */
  
    /*
    ff_origin[2] += 20.0
    ff_end[0] = ff_origin[0];
    ff_end[1] = ff_origin[1];
    ff_end[2] = -9990.0; 
    engfunc(EngFunc_TraceLine, ff_origin, ff_end, IGNORE_MONSTERS, id_tank, 0);
    get_tr2(0, TR_vecPlaneNormal, normal);
    vector_to_angle(normal, angles);
    angles[0] = round_down(angles[0])
    angles[1] = round_down(angles[1])
    angles[2] = round_down(angles[2])
     // normal[0] работает по X {-1.0:,1.0}  
    // normal[1] работает по y {-1.0:,1.0}  
    // это то, что надо определять при наклоне = ang_p[0] = 90.0 - angles[0] 
    //ang_p[0] = (angles[0] * ((floatabs(f_pl_angles[1])-90.0)/90.0)) // всё правильно
    ang_p[1] = f_pl_angles[1] // Всё приваильно
    // ang_p[2] = angles[1] * ( (1.0 -floatabs((floatabs(f_pl_angles[1])-90.0)/90.0)))
    // ang_p[0] = 90.0 - angles[1] ?? 
    // ang_p[2] = (-(angles[1]-90.0) * ((floatabs(f_pl_angles[1])-90)/90.0)) // всё правильно дайёт поперечны крен.
    /* my manual
    ang_p[0] = angles[0] * ((floatabs(angles[1])-90.0)/90.0)
    ang_p[1] = angles[1]
    ang_p[2] = angles[0] * ( (1.0 -floatabs((floatabs(angles[1])-90.0)/90.0)))
    if( angles[1] < 0.0)
    {
        ang_p[2] *= -1.0
    } 
    set_pev(id_tank, pev_angles, ang_p);
    */

  
    }  

    
    return PLUGIN_CONTINUE
}

public tank_switch(id_player, id_tank, m)
{   
    // в этой функции сделать подключение камеры и системы управления танком.
    new Float: f_spOrigin[3]
    new Spawn_point
    // m == 1 заходим . ь== 0 выходим

    if(m == 1)
    {
        // зашли в танк
        g_tanks_owner[id_tank]  = id_player
        g_players_tank[id_player] = id_tank
        set_pev(id_tank, pev_nextthink, halflife_time() + 1.0)
        //attach_view(id_player, id_tank)
        /* включит
        // if in brit or aliies team
        if(get_user_team(id_player)!=2)
	    {
            if((Spawn_point = engfunc(EngFunc_FindEntityByString, -1, "classname", "info_player_allies")) != 0)
            {   
                pev(Spawn_point, pev_origin, f_spOrigin)
                set_pev(id_player, pev_origin, f_spOrigin)
                // set_pev(id, pev_movetype, MOVETYPE_NONE)
                // set_pev( id, pev_flags, pev( id, pev_flags ) | FL_FROZEN ) 
                set_pev( id_player, pev_maxspeed, 0.0 )
                server_print("on tank")
            }
        }
        // if in axis team: 
        if(get_user_team(id_player)==2)
	    {
            if((Spawn_point = engfunc(EngFunc_FindEntityByString, -1, "classname", "info_player_axis")) != 0)
            {   
                pev(Spawn_point, pev_origin, f_spOrigin)
                set_pev(id_player, pev_origin, f_spOrigin)
                // set_pev( id, pev_flags, pev( id, pev_flags ) | FL_FROZEN )
                set_pev( id_player, pev_maxspeed, 0.0 )
                server_print("on tank")
            }
        }
        */
        return PLUGIN_CONTINUE
    }
    else 
    {
    // выйти из танка
    //attach_view(id_player, id_player)
    pev(g_players_tank[id_player], pev_origin, f_spOrigin)
    f_spOrigin[2] += 200
    set_pev(id_player, pev_origin, f_spOrigin)
    set_pev(id_player, pev_maxspeed, 400.0 )
    g_players_tank[id_player] = 0
    g_tanks_owner[id_tank] = 0

    }
    return PLUGIN_CONTINUE
}

public tank_touch(id_tank, id_player)
{
    if(!is_user_alive(id_player)) return PLUGIN_CONTINUE
    if(g_tanks_owner[id_tank] == 0)
    {   
        
        new buttonpress = pev(id_player, pev_button)
        if (buttonpress & IN_USE)
        {   
            
            tank_switch(id_player, id_tank, 1)
        }
    }
    else
    {
        return PLUGIN_CONTINUE
    }
    return PLUGIN_CONTINUE 
   
}


public rocket_shoot(id_player, rocketindex, wId)
{ 
    if (!pev_valid(g_players_tank[id_player]) || g_players_tank[id_player] == 0 || !rocketindex ) return;
    /*
    TANK ENT HAT THIS :
    set_pev(TankEnt, pev_angles, vAngles)
    set_pev(TankEnt, pev_avelocity, vAVelocity)
    set_pev(TankEnt, pev_velocity, vVelocity)
    
    */

    new Float:pOrigin[3]
    new Float:tOrigin[3]
    pev(g_players_tank[id_player], pev_origin, tOrigin)

    //VelocityByAim(g_players_tank[id_player], 450 , pOrigin) 
    //xs_vec_add( tOrigin, pOrigin, tOrigin )
    tOrigin[2] += 80.0
    set_pev(rocketindex, pev_origin, tOrigin)

    /*
    VelocityByAim(id_player, 150 , pOrigin) 
	pev(g_players_tank[id_player], pev_origin, tOrigin)
    // MOVE Start rocket point from tank's tube
	tOrigin[2] += 40.0                     // Tune HeightPoint startpoint rocket
	set_pev(rocketindex, pev_origin, tOrigin)
    */

}


stock Float:round_down(Float:value)
{
    new Float:rounded_value = floatround(value * 10.0) / 10.0;
    return rounded_value
}


public UpdateTerrain(id_tank, float:cur_angles[3])
{
    pev(id_tank, pev_origin, ff_origin)
    ff_origin[2] += 20.0
    ff_end[0] = ff_origin[0];
    ff_end[1] = ff_origin[1];
    ff_end[2] = -9990.0; 
    engfunc(EngFunc_TraceLine, ff_origin, ff_end, IGNORE_MONSTERS, id_tank, 0);
    get_tr2(0, TR_vecPlaneNormal, normal);

    

    vector_to_angle(normal, angles);
    ang_p[0] = angles[0] - 90.0

    set_pev(id_tank, pev_angles, ang_p)


    // Get angles
    new Float:fAngles[2][3]
    pev(id_tank, pev_angles, fAngles[0])
 
    // Get forward vector
    new Float:fForward[3]
    angle_vector(fAngles[0], ANGLEVECTOR_FORWARD, fForward)
 
    /* // Get up vector
    new Float:fVectorUp[3] // normal
    get_tr2(iTraceResult, TR_vecPlaneNormal, fVectorUp) // 
    */
    // Calculate vectors
    new Float:fVectorRight[3], Float:fVectorForward[3]
 
    xs_vec_cross(fForward, normal, fVectorRight)
    xs_vec_cross(normal, fVectorRight, fVectorForward)
 
    vector_to_angle(fVectorForward, fAngles[0])
    vector_to_angle(fVectorRight, fAngles[1])
 
    // Update angles
    fAngles[0][2] = -1.0 * fAngles[1][0]
 
    // Set angles that we calculated
    set_pev(id_tank, pev_angles, fAngles[0])
    set_pev(id_tank, pev_nextthink, halflife_time()  + 0.2) 
}


