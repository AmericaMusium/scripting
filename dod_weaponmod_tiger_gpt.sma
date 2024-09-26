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
new const g_destroyed[] = "models/red/tiger/rc_tiger.mdl" 
new const s_start[] = "tank/tn_start.wav"
new const s_stop[] = "tank/tn_stop.wav"
new const s_vel[] = "tank/tn_vel.wav"
new const s_mid[] = "tank/tn_mid.wav"
new const s_expl[] = "weapons/mortar_satchel.wav"
new g_sprsmk
new g_sprxpd

#define THINK_FRAME 0.1
#define TANK_SPEED 320
#define BUMP_SIZE 150.0
#define TRACE_SIZE 400.0


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
    precache_sound(s_start)	
    precache_sound(s_stop)	
    precache_sound(s_vel)	
    precache_sound(s_mid)
    precache_sound(s_expl)	
    g_sprsmk = precache_model("sprites/smoke_ia.spr")
    g_sprxpd = precache_model("sprites/explosion1.spr")
  
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

        engfunc(EngFunc_SetSize, id_tank, Float:{-120.0, -120.0, -70.0}, Float:{120.0, 120.0, 50.0}) //   entity(      )
        set_pev(id_tank, pev_friction, 0.5)
        set_pev(id_tank, pev_gravity, 1.0)
        set_pev(id_tank, pev_solid, SOLID_SLIDEBOX) 
        set_pev(id_tank, pev_movetype, MOVETYPE_PUSHSTEP) 
        set_pev(id_tank, pev_nextthink, halflife_time() + THINK_FRAME)  
        set_pev(id_tank, pev_health, 1500.0)
	    set_pev(id_tank, pev_takedamage, 0.0)
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
    

    new hp = pev(id_tank, pev_health)
    if( hp < 1000) 
    {
        tank_destroy(id_tank)
    }
    // 

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

    
    tank_bump_low(id_tank)

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
    */
    ang_p[1] = f_pl_angles[1]
    set_pev(id_tank, pev_angles, ang_p);
    tank_sutface_angles(id_tank)

    }  

    
    return PLUGIN_CONTINUE
}

public tank_switch(id_player, id_tank, m)
{   
    // в этой функции сделать подключение камеры и системы управления танком.
    new Float: f_spOrigin[3]
    new Spawn_point
    // m == 1 заходим . ь== 0 выходим
    new mdlll = pev( id_player, pev_viewmodel)
    if(m == 1)
    {
        // зашли в танк
        g_tanks_owner[id_tank]  = id_player
        g_players_tank[id_player] = id_tank
        set_pev(id_tank, pev_takedamage, 1.0)
        set_pev(id_tank, pev_nextthink, halflife_time() + 3.0)
        emit_sound(id_tank, CHAN_ITEM, s_start, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);

        set_task(3.0,"tank_sound" , id_tank)
        /*
        attach_view(id_player, id_tank)
        message_begin(MSG_ONE, get_user_msgid("SetFOV"), {0,0,0}, id_player)
        write_byte(85) //Zooming AUG/SIG style
        message_end()

        /// 
        entity_set_string(id_player, EV_SZ_viewmodel , "models/v_mp40.mdl")
        set_pev( id_player, pev_viewmodel2, "models/v_mp40.mdl" );
        set_pev( id_player, pev_viewmodel, mdlll );
        entity_set_string(id_tank, EV_SZ_viewmodel , "models/v_mp40.mdl")
        set_pev( id_tank, pev_viewmodel2, "models/v_mp40.mdl" );
        set_pev( id_tank, pev_viewmodel, mdlll );
        */
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
    //attach_view(id_player, id_player)
    emit_sound(id_tank, CHAN_ITEM, s_stop, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
    pev(g_players_tank[id_player], pev_origin, f_spOrigin)
    f_spOrigin[2] += 200
    set_pev(id_player, pev_origin, f_spOrigin)
    set_pev(id_player, pev_maxspeed, 400.0 )
    set_pev(id_tank, pev_takedamage, 0.0)
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
    // cнаряд перед прицелом
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

public tank_sutface_angles(id_tank)
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
    new Float:fAngles[2][3]
    pev(id_tank, pev_angles, fAngles[0])

    new Float:fForward[3]
    angle_vector(fAngles[0], ANGLEVECTOR_FORWARD, fForward)
    new Float:fVectorRight[3], Float:fVectorForward[3]
 
    xs_vec_cross(fForward, normal, fVectorRight)
    xs_vec_cross(normal, fVectorRight, fVectorForward)
 
    vector_to_angle(fVectorForward, fAngles[0])
    vector_to_angle(fVectorRight, fAngles[1])
    fAngles[0][2] = -1.0 * fAngles[1][0]

    
    
    set_pev(id_tank, pev_angles,  fAngles[0])
    
    //set_pev(id_tank, pev_avelocity,  fAngles[0])
    set_pev(id_tank, pev_nextthink, halflife_time()  + THINK_FRAME) 
}

public tank_sound(id_tank)
{
    if(g_tanks_owner[id_tank] == 0) 
    {   
        return  
    }
    new float:t_vel[3]
    pev(id_tank, pev_velocity, t_vel)
    new float:sp = vector_length(t_vel)
    if(sp>208.0)
    {   
       
        //emit_sound(id_tank, CHAN_ITEM, s_vel, VOL_NORM, ATTN_NORM, 0, pitc);
        emit_sound(id_tank, CHAN_AUTO, s_vel, 1.0, ATTN_NORM, 0, PITCH_NORM)
        set_task(random_float(0.4,2.1),"tank_sound" , id_tank)
    }
    else
    {
        emit_sound(id_tank, CHAN_ITEM, s_mid, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
        set_task(random_float(2.0,3.0),"tank_sound" , id_tank)
    }

    new Float:frockOrigin[3]
    pev(id_tank, pev_origin, frockOrigin)
    message_begin(MSG_ALL,SVC_TEMPENTITY)
    write_byte(TE_SMOKE)
    engfunc(EngFunc_WriteCoord, frockOrigin[0]) 
    engfunc(EngFunc_WriteCoord, frockOrigin[1]) 
    engfunc(EngFunc_WriteCoord, frockOrigin[2]) 
    write_short(g_sprsmk)
    write_byte(random_num(20,27))
    write_byte(random_num(2,6))
    message_end()
    


    
}

public tank_destroy(id_tank)
{   
    if(!is_valid_ent(id_tank)) return;

    set_pev( id_tank, pev_body, 1);
    set_pev( id_tank, pev_classname, "tnk_dest")
    set_pev( id_tank, pev_velocity, {0.0, 0.0, 270.0})
    set_pev( id_tank, pev_gravity, 2.0)
    // explossion 
    emit_sound(id_tank, CHAN_ITEM, s_stop, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
    g_tanks_owner[id_tank] = 0
    tank_explode(id_tank)
    tank_smoke(id_tank)
}

public tank_smoke(id_tank)
{
    if(!is_valid_ent(id_tank)) return;
    new Float:frockOrigin[3]
    pev(id_tank, pev_origin, frockOrigin)
    message_begin(MSG_ALL,SVC_TEMPENTITY)
    write_byte(TE_SMOKE)
    engfunc(EngFunc_WriteCoord, frockOrigin[0]) 
    engfunc(EngFunc_WriteCoord, frockOrigin[1]) 
    engfunc(EngFunc_WriteCoord, frockOrigin[2]) 
    write_short(g_sprsmk)
    write_byte(random_num(20,27))
    write_byte(random_num(2,6))
    message_end()


    set_task(3.0,"tank_smoke" , id_tank)
}


public tank_explode(id_tank)
{	
	if(!pev_valid(id_tank)) 
		return PLUGIN_HANDLED

	new Float:fOrigin_satchel[3]
	pev(id_tank, pev_origin, fOrigin_satchel)

	new origin[3]
	origin[0] = floatround(fOrigin_satchel[0])
	origin[1] = floatround(fOrigin_satchel[1])
	origin[2] = floatround(fOrigin_satchel[2])
	// (origin[3], addrad= скорость движения, sprite, startfrate, framerate, life=радиус и продолжительность, width, amplitude, red, green, blue, brightness, speed)
	create_cylinder(origin, 1200, g_sprsmk, 0, 0, 30, 200, 10, 150, 150, 150, 40, 0)

	message_begin(MSG_BROADCAST,SVC_TEMPENTITY) // 
	write_byte(TE_EXPLOSION) // ()
	engfunc(EngFunc_WriteCoord, fOrigin_satchel[0]) // x
	engfunc(EngFunc_WriteCoord, fOrigin_satchel[1]) // y
	engfunc(EngFunc_WriteCoord, fOrigin_satchel[2] + 10.0) // z
	write_short(g_sprxpd) //  
	write_byte(80) // scale
	write_byte(15) // 
	write_byte(0) //
	message_end() // 

	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)// 
	write_byte(TE_SMOKE) // ()
	engfunc(EngFunc_WriteCoord, fOrigin_satchel[0]) // x
	engfunc(EngFunc_WriteCoord, fOrigin_satchel[1]) // y
	engfunc(EngFunc_WriteCoord, fOrigin_satchel[2] + 20.0) // x
	write_short(g_sprsmk) //  
	write_byte(25) // 
	write_byte(10) // 
	message_end() // 

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_WORLDDECAL);
	engfunc(EngFunc_WriteCoord, fOrigin_satchel[0]);
	engfunc(EngFunc_WriteCoord, fOrigin_satchel[1]);
	engfunc(EngFunc_WriteCoord, fOrigin_satchel[2]);
	write_byte(60); // 60 EXPLOD
	message_end();

	emit_sound(id_tank, CHAN_WEAPON, s_expl, 1.0, ATTN_NORM,0,PITCH_NORM)

	return PLUGIN_CONTINUE
}

stock create_cylinder(origin[3], addrad, sprite, startfrate, framerate, life, width, amplitude, red, green, blue, brightness, speed)
{
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BEAMCYLINDER)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2] + addrad)
	write_short(sprite)
	write_byte(startfrate)
	write_byte(framerate)
	write_byte(life)
	write_byte(width)
	write_byte(amplitude)
	write_byte(red)
	write_byte(green)
	write_byte(blue)
	write_byte(brightness)
	write_byte(speed)
	message_end()
}


public tank_bump_low(id_tank)
{
    new float:Dist[4]
    new float:Normal[3]
    new float:Norm_Ang[3]
    pev(id_tank, pev_origin, ff_origin)
    // ff_origin[2] -= 20.0
    ff_end[0] = ff_origin[0] - TRACE_SIZE;
    ff_end[1] = ff_origin[1];
    ff_end[2] = ff_origin[2];
    engfunc(EngFunc_TraceLine, ff_origin, ff_end, IGNORE_MONSTERS, id_tank, 0);
    new Float:fHitPos[3];
    get_tr2(0, TR_vecEndPos, fHitPos);
    get_tr2(0, TR_vecPlaneNormal, Normal);
    vector_to_angle(Normal, Norm_Ang);
    Dist[0] = get_distance_f(ff_origin, fHitPos)
    // draw_laser(ff_origin, fHitPos, 100)
    if(Dist[0] < BUMP_SIZE)
    {   
        if(Norm_Ang[0] < 30.0)
        {
            set_pev( id_tank, pev_velocity, { 500.0 , 0.0, -20.0})
        }
    }
    ff_end[0] = ff_origin[0] + TRACE_SIZE;
    ff_end[1] = ff_origin[1];
    ff_end[2] = ff_origin[2];
    engfunc(EngFunc_TraceLine, ff_origin, ff_end, IGNORE_MONSTERS, id_tank, 0);
    get_tr2(0, TR_vecEndPos, fHitPos);
    get_tr2(0, TR_vecPlaneNormal, Normal);
    vector_to_angle(Normal, Norm_Ang);
    Dist[1] = get_distance_f(ff_origin, fHitPos)
    if(Dist[1] < BUMP_SIZE)
    {   
        if(Norm_Ang[0] < 30.0)
        {
            set_pev( id_tank, pev_velocity, { -500.0 , 0.0, -20.0})
        }
    }

    ff_end[0] = ff_origin[0];
    ff_end[1] = ff_origin[1]  + TRACE_SIZE;
    ff_end[2] = ff_origin[2];
    engfunc(EngFunc_TraceLine, ff_origin, ff_end, IGNORE_MONSTERS, id_tank, 0);
    get_tr2(0, TR_vecEndPos, fHitPos);
    get_tr2(0, TR_vecPlaneNormal, Normal);
    vector_to_angle(Normal, Norm_Ang);
    Dist[2] = get_distance_f(ff_origin, fHitPos)
    
    if(Dist[2] < BUMP_SIZE)
    {   
        if(Norm_Ang[0] < 30.0)
        {
            set_pev( id_tank, pev_velocity, { 0.0 , -500.0, -20.0})
        }
    }

    ff_end[0] = ff_origin[0];
    ff_end[1] = ff_origin[1]  - TRACE_SIZE;
    ff_end[2] = ff_origin[2];
    engfunc(EngFunc_TraceLine, ff_origin, ff_end, IGNORE_MONSTERS, id_tank, 0);
    get_tr2(0, TR_vecEndPos, fHitPos);
    get_tr2(0, TR_vecPlaneNormal, Normal);
    vector_to_angle(Normal, Norm_Ang);
    Dist[3] = get_distance_f(ff_origin, fHitPos)
    if(Dist[3] < BUMP_SIZE)
    {   
        if(Norm_Ang[0] < 30.0)
        {
            set_pev( id_tank, pev_velocity, { 0.0 , 500.0, -20.0})
        }
    }
}


public tank_bump_high(id_tank)
{
    new float:Dist[4]
    pev(id_tank, pev_origin, ff_origin)
    ff_origin[2] += 60.0
    ff_end[0] = ff_origin[0] - TRACE_SIZE;
    ff_end[1] = ff_origin[1];
    ff_end[2] = ff_origin[2];
    engfunc(EngFunc_TraceLine, ff_origin, ff_end, IGNORE_MONSTERS, id_tank, 0);
    new Float:fHitPos[3];
    get_tr2(0, TR_vecEndPos, fHitPos);
	Dist[0] = get_distance_f(ff_origin, fHitPos)
    //draw_laser(ff_origin, fHitPos, 100)

    ff_end[0] = ff_origin[0] + TRACE_SIZE;
    ff_end[1] = ff_origin[1];
    ff_end[2] = ff_origin[2];
    engfunc(EngFunc_TraceLine, ff_origin, ff_end, IGNORE_MONSTERS, id_tank, 0);

    get_tr2(0, TR_vecEndPos, fHitPos);
	Dist[1] = get_distance_f(ff_origin, fHitPos) 
    //draw_laser(ff_origin, fHitPos, 100)

    ff_end[0] = ff_origin[0];
    ff_end[1] = ff_origin[1]  + TRACE_SIZE;
    ff_end[2] = ff_origin[2];
    engfunc(EngFunc_TraceLine, ff_origin, ff_end, IGNORE_MONSTERS, id_tank, 0);

    get_tr2(0, TR_vecEndPos, fHitPos);
	Dist[2] = get_distance_f(ff_origin, fHitPos) 
    // draw_laser(ff_origin, fHitPos, 100)

    ff_end[0] = ff_origin[0];
    ff_end[1] = ff_origin[1]  - TRACE_SIZE;
    ff_end[2] = ff_origin[2];
    engfunc(EngFunc_TraceLine, ff_origin, ff_end, IGNORE_MONSTERS, id_tank, 0);
    
    get_tr2(0, TR_vecEndPos, fHitPos);
	Dist[3] = get_distance_f(ff_origin, fHitPos) 
    //draw_laser(ff_origin, fHitPos, 100)



    if(Dist[0] < BUMP_SIZE)
    {   
        //client_print(0, print_center, "dist: SEWER %f %f %f %f  ", Dist[0] , Dist[1], Dist[2], Dist[3])
        set_pev( id_tank, pev_velocity, { 60.0 , 0.0, -20.0})
    }
    else if (Dist[1] < BUMP_SIZE)
    {   
        //client_print(0, print_center, "dist: YUG %f %f %f %f  ", Dist[0] , Dist[1], Dist[2], Dist[3])
        set_pev( id_tank, pev_velocity, { -60.0 , 0.0, -20.0})
    }
    else if (Dist[2] < BUMP_SIZE)
    {   
        //client_print(0, print_center, "dist: VOSTOK %f %f %f %f  ", Dist[0] , Dist[1], Dist[2], Dist[3])
        set_pev( id_tank, pev_velocity, { 0.0 , -60.0, -20.0})
    }
    else if (Dist[3] < BUMP_SIZE)
    {   
        //client_print(0, print_center, "dist: ZAPAD %f %f %f %f  ", Dist[0] , Dist[1], Dist[2], Dist[3])
        set_pev( id_tank, pev_velocity, { 0.0 , 60.0, -20.0})
    }
}





public shoot_laser(ent)
{
// We get the origin of the entity.
new Float:origin[3]
pev(ent, pev_origin, origin)

// We want to trace down to the floor, if it's there.
new Float:traceto[3]
traceto[0] = origin[0]
traceto[1] = origin[1]
traceto[2] = origin[2] - 100.0

new trace = 0
// Draw the traceline. We're assuming the object is resting on the floor.
engfunc(EngFunc_TraceLine, origin, traceto, IGNORE_MONSTERS, ent, trace)

new Float:fraction
get_tr2(trace, TR_flFraction, fraction)
// If we didn't hit anything, then we won't get a valid TR_vecPlaneNormal.
if (fraction == 1.0) return

new Float:normal[3]
get_tr2(trace, TR_vecPlaneNormal, normal)
// We'll multiply the the normal vector by a scalar to make it longer.
normal[0] *= 400.0 // Mathematically, we multiplied the length of the vector by 400*(3)^(1/2),
normal[1] *= 400.0 // or, in words, four hundred times root three.
normal[2] *= 400.0

// To get the endpoint, we add the normal vector and the origin.
new Float:endpoint[3]
endpoint[0] = origin[0] + normal[0]
endpoint[1] = origin[1] + normal[1]
endpoint[2] = origin[2] + normal[2]

// Finally, we draw from the laser!
draw_laser(origin, endpoint, 100) // Make it stay for 10 seconds. Not a typo; staytime is in 10ths of a second.
}





public draw_laser(Float:start[3], Float:end[3], staytime)
{                    
message_begin(MSG_ALL, SVC_TEMPENTITY)
write_byte(TE_BEAMPOINTS)
engfunc(EngFunc_WriteCoord, start[0])
engfunc(EngFunc_WriteCoord, start[1])
engfunc(EngFunc_WriteCoord, start[2])
engfunc(EngFunc_WriteCoord, end[0])
engfunc(EngFunc_WriteCoord, end[1])
engfunc(EngFunc_WriteCoord, end[2])
write_short(g_sprsmk)
write_byte(0)
write_byte(0)
write_byte(600) // In tenths of a second.
write_byte(10)
write_byte(1)
write_byte(255) // Red
write_byte(0) // Green
write_byte(0) // Blue
write_byte(127)
write_byte(1)
message_end()
} 