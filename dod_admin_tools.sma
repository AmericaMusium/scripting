#include <amxmodx>
#include <fakemeta>
#include <dodx>
#include <dodfun>
#include <hamsandwich>
#include <engine>

public plugin_init()
{
    register_plugin("DOD Admin Tools", "0.0","America")	
    RegisterHam(Ham_TakeDamage,"player","func_TakeDamage")	
    register_concmd ("r", "restart_ask")
    register_concmd ("rr", "restart_ask")
    register_concmd ("rrr", "restart_ask")



}

public func_TakeDamage(id,inflictor,attacker,Float:damage,damagebits)
{ 
	// bits 64 == nades //4226 SPADE // 32896 = K98KNIFE / 65664 = buttgarand
	
	if( is_user_bot(attacker) && !is_user_bot(id) )
    {
        SetHamParamFloat(4, 0.0)
        return HAM_OVERRIDE
        //return HAM_IGNORED
    }
	return HAM_IGNORED
}
/*

public client_PreThink(pPlayer)
{
    // чем медленне бежит , тем прозрачней 
    if(!is_user_alive(pPlayer))
        return;

    static Float: fVecVelocity[3];
    entity_get_vector(pPlayer, EV_VEC_velocity, fVecVelocity);

    set_rendering(
        .index      = pPlayer,
        .fx         = kRenderFxNone,
        .render     = kRenderTransAlpha,
        .amount     = max( 20, floatround(vector_length(fVecVelocity)))
    );
}
*/

public client_PreThink(idx_player)
{   
    static Float:vVel[3];
    if (entity_get_int(idx_player, EV_INT_button) & IN_RUN)
    {   
        static Float:vVelocity[3];
        static Float:vViewAngle[3];
        static Float:vForward[3];

        // Получаем текущую скорость игрока
        pev(idx_player, pev_velocity, vVelocity);

        // Получаем угол взгляда игрока
        pev(idx_player, pev_v_angle, vViewAngle);

        // Преобразуем угол взгляда в вектор направления
        angle_vector(vViewAngle, ANGLEVECTOR_FORWARD, vForward);

        // Увеличиваем скорость в направлении взгляда
        vVelocity[0] += vForward[0] * 100.0; // Увеличиваем скорость по оси X
        vVelocity[1] += vForward[1] * 100.0; // Увеличиваем скорость по оси Y
        vVelocity[2] += vForward[2] * 100.0; // Увеличиваем скорость по оси Z

        // Устанавливаем новую скорость
        set_pev(idx_player, pev_velocity, vVelocity);
        /*
        new Float:fOrigin[3];
        // entity_set_vector(idx_player, EV_VEC_origin, fOrigin);
        entity_set_float(idx_player, EV_FL_maxspeed, 1400.0);
        */


    }
        
}

public restart_ask()
{
server_cmd("restart")
}



public Float:get_point_from_eyes_distance( idx_player, distance, Float:f_Origin[3])
{
	// Получаем позицию глаз игрока
	new Float:fOrigin[3], Float:fAngles[3], i_Origin[3];
	get_user_origin(idx_player, i_Origin, 1); // Получаем целочисленные координаты глаз
	IVecFVec(i_Origin, fOrigin); // Преобразуем в float для точных вычислений

	// Получаем углы взгляда игрока
	pev(idx_player, pev_v_angle, fAngles);

	// Вычисляем вектор направления взгляда
	new Float:fForward[3], Float:fRight[3], Float:fUp[3];
	angle_vector(fAngles, ANGLEVECTOR_FORWARD, fForward);
	angle_vector(fAngles, ANGLEVECTOR_RIGHT, fRight);
	angle_vector(fAngles, ANGLEVECTOR_UP, fUp);

	// Смещаем точку на 35 юнитов вперед от глаз игрока
	f_Origin[0] = fOrigin[0] + fForward[0] * float(distance);
	f_Origin[1] = fOrigin[1] + fForward[1] * float(distance);
	f_Origin[2] = fOrigin[2] + fForward[2] * float(distance);
	// iTarget теперь содержит целочислен

	return f_Origin;
}
