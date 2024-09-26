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

new const g_tankcname[] = "rc_tank" //Classname  entity
new const g_tankmdl[] = "models/red/tiger/rc_tiger.mdl" 

#define THINK_FRAME 0.1

new g_players_tank[33]
new g_tanks_owner[2048]
new g_maxtanks 
new const LIMIT_TANKS = 1

/// Для плавного хранения данных выводим массивы, при создании массива внутри функции он имеет нулевое значение,
// нужно исключить сброс положения объекта.
static Float: f_pl_angles[3]
static Float: f_tank_angles[3]
static Float: f_origin[3]
static Float: pl_velocity[3]

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
		iOrigin[2] += 300
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
        // attach_view(id, id_tank)
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

    // HUD ANGLE POINTS
    new Float:fAngViev[3]
    pev(idowner, pev_v_angle, fAngViev)
    // SEND RETUNE AMGLES
    pev(id_tank, pev_angles, f_tank_angles)
    pev(idowner, pev_angles, f_pl_angles)
    f_tank_angles[1] = f_pl_angles[1] // лево право
    set_pev(id_tank, pev_angles, f_tank_angles)
    new Float: hudy = (fAngViev[0] + 90.0 ) / 180.0 
    set_hudmessage(130, 40, 10, 0.52, hudy , 0, 0.8, 0.4, 0.1, 0.1, -1) // // ВЕРХ == 0.0 , центр == 0,5 . 1.0 == полный низ. 
	show_hudmessage(idowner, " _xxx %f", -fAngViev[0])
    // client_print(idowner, print_center, "HORIZONT ANGLE: %i ", (-1*floatround(fAngViev[0]))  )

    // Input buttons
    buttonpress = pev(idowner, pev_button)
    if (buttonpress & IN_FORWARD)
    {
        velocity_by_aim ( idowner, 120, pl_velocity )
        // pev(idowner, pev_velocity, pl_velocity)
        pl_velocity[2] = -200.0
        set_pev(id_tank, pev_velocity, pl_velocity)
        // client_print(0, print_center, "eeedeeem")
    }
    if (buttonpress & IN_USE)
    {
       tank_switch(idowner, id_tank, 0)
    }

    else if (buttonpress & IN_BACK)
    {
        velocity_by_aim ( idowner, -120, pl_velocity )
        // pev(idowner, pev_velocity, pl_velocity)
        pl_velocity[2] = -200.0
        set_pev(id_tank, pev_velocity, pl_velocity)
        // client_print(0, print_center, "eeedeeem")
    }

    
    // tank_trace(id_tank, idowner)
    set_pev(id_tank, pev_nextthink, halflife_time() + THINK_FRAME)

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
        set_pev(id_tank, pev_nextthink, halflife_time() + 3.0)
        attach_view(id_player, id_tank)

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
        return PLUGIN_CONTINUE
    }
    else 
    {
    // выйти из танка
    attach_view(id_player, id_player)
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














public tank_normal_calc(id_tank)
{
        /// посчитать нормаль
    
    // Получаем скорость объекта
    static Float:velocity[3]; 
    pev(id_tank, pev_velocity, velocity)
    // Получаем координаты
    pev(id_tank, pev_origin, f_origin)
    f_origin[2] += 10.0
    static Float:end[3] // Получаем конечную точку трассы
    end[0] = f_origin[0] 
    end[1] = f_origin[1] 
    end[2] = f_origin[2]
    //----------для MOVETYPE_BOUNCE снижаем скорость-----
    velocity[0] *= 0.5
    velocity[1] *= 0.5
    velocity[2] *= 0.5
    set_pev(id_tank, pev_velocity, velocity)
    //----------------------------------
    // Нормаль поверхности, куда летит объект
    engfunc(EngFunc_TraceLine, f_origin, end, 0, id_tank, 0)
    get_tr2(0, TR_vecPlaneNormal, end)
    static Float:angles[3];
    angles[0] = f_pl_angles[0]
    angles[1] = f_pl_angles[1]
    angles[2] = f_pl_angles[2]
    // pev(id_tank, pev_angles, angles)
    static Float:vector[3]; 
    angle_vector(angles, ANGLEVECTOR_FORWARD, vector)
    static Float:out[3] // Крутим сначало угол Z
    out[0] = vector[1] * end[2] - vector[2] * end[1]
    out[1] = vector[2] * end[0] - vector[0] * end[2]
    out[2] = vector[0] * end[1] - vector[1] * end[0]
    static Float:outs[3] // Потом угол X
    outs[0] = end[1] * out[2] - end[2] * out[1]
    outs[1] = end[2] * out[0] - end[0] * out[2]
    outs[2] = end[0] * out[1] - end[1] * out[0]
    // Переводим в углы
    vector_to_angle(out, out)
    vector_to_angle(outs, angles)
    // Корректируем угол Z(зависит от модели)
    angles[2] = out[0] * -1.0
    if(angles[0] > 45.0 || angles[0] < -45.0 ) angles[0] = 0.0
    if(angles[2] > 45.0 || angles[2] < -45.0 ) angles[2] = 0.0
    angles[0] = floatclamp(angles[0], Float:-35.0, Float:35.0)  
    angles[2] = floatclamp(angles[2], Float:-35.0, Float:35.0)  
    // Устанавливаем
    set_pev(id_tank, pev_angles, angles)
    // 270  ok 270 
    client_print(0, print_center, "%f %f %f" , angles[0], angles[1] , angles[2])
    
    //////// NORMAL END
}