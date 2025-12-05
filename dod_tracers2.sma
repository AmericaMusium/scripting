#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>




new g_sprite;
// gunfire data
new Float:g_vec_start[33][3];
new Float:g_vec_end[33][3];

public plugin_precache()
{
    // Предзакешируем спрайт для цветных трассеров
    g_sprite = precache_model("sprites/plasma.spr");
}


public plugin_init()
{
	register_plugin("[RE] Gun Tracer", "0.1", "holla");

	// RegisterHam(Ham_TakeDamage, "player", "on_TakeDamage_P", true); // Хуки для отслеживания урона
	RegisterHam(Ham_TraceAttack, "player", "shoot_item");
}

public on_TakeDamage_P(victim, inflictor, attacker, Float:damage, damagebits)
	{   

	if(is_user_connected(victim) && is_user_connected(attacker) && (attacker != victim))
	{   
		// Регистрируем нанесённый и полученный урон Damage
	new int_Damage = floatround(damage);
	client_print( attacker, print_center, "%d" , int_Damage);
	}
	return HAM_IGNORED;
}


public shoot_item(ent, attacker, Float:damage, Float:direction[3], ptr, damagebits)
{	
	if(attacker < 1 || attacker > get_maxplayers())
		return 0;
	// сдлеать проверку аттакера
	pev(attacker, pev_origin, g_vec_start[attacker]);
	get_tr2(ptr, TR_vecEndPos, g_vec_end[attacker]);

	// FX_SPARKS(endpoint)
	// FX_Tracer(attacker, startpoint, endpoint);

	new iOrigin[3] //    
	iOrigin[2] -= 8; 
	get_user_origin(attacker, iOrigin, Origin_Eyes) //    origin zero
	// get_user_origin(id, iOrigin1, 1) //   looks to
	IVecFVec(iOrigin, g_vec_start[attacker]) //  7

	FX_ColoredTracer(attacker, g_vec_start[attacker], g_vec_end[attacker], {203, 198, 51});
	
	return HAM_IGNORED
}

stock FX_SPARKS(Float:origin[3])
{
	message_begin(MSG_ALL, SVC_TEMPENTITY)
	write_byte(TE_SPARKS)
	engfunc(EngFunc_WriteCoord, origin[0])
	engfunc(EngFunc_WriteCoord, origin[1])
	engfunc(EngFunc_WriteCoord, origin[2])
	message_end()	
}




stock FX_Tracer(player, Float:start[3], Float:end[3])
{
	message_begin(player ? MSG_ONE_UNRELIABLE : MSG_BROADCAST, SVC_TEMPENTITY, .player=player);
	write_byte(TE_TRACER);
	write_coord_f(start[0]);
	write_coord_f(start[1]);
	write_coord_f(start[2]);
	write_coord_f(end[0]);
	write_coord_f(end[1]);
	write_coord_f(end[2]);
	message_end();
}



stock FX_UserTracer(player, Float:origin[3], Float:velocity[3], life, color, length)
{
	message_begin(player ? MSG_ONE_UNRELIABLE : MSG_BROADCAST, SVC_TEMPENTITY, .player=player);
	write_byte(TE_USERTRACER);
	write_coord_f(origin[0]);
	write_coord_f(origin[1]);
	write_coord_f(origin[2]);
	write_coord_f(velocity[0]);
	write_coord_f(velocity[1]);
	write_coord_f(velocity[2]);
	write_byte(life);
	write_byte(color);
	write_byte(length);
	message_end();
}



	// Дополнительная функция с цветными трассерами
stock FX_ColoredTracer(player, Float:start[3], Float:end[3], color[3] = {255, 255, 255})
{
	// TE_BEAMPOINTS для цветных трассеров
	// message_begin(player ? MSG_ONE_UNRELIABLE : MSG_BROADCAST, SVC_TEMPENTITY, .player = player);
	message_begin(MSG_ALL,SVC_TEMPENTITY)
	write_byte(TE_BEAMPOINTS);
	write_coord_f(start[0]);
	write_coord_f(start[1]);
	write_coord_f(start[2]);
	write_coord_f(end[0]);
	write_coord_f(end[1]);
	write_coord_f(end[2]);
	write_short(g_sprite); // Нужно предзакешировать спрайт
	write_byte(1); // начальный кадр
	write_byte(10); // частота кадров
	write_byte(2); // жизнь в 0.1 сек
	write_byte(4); // ширина
	write_byte(2); // шум
	write_byte(color[0]); // R
	write_byte(color[1]); // G
	write_byte(color[2]); // B
	write_byte(25); // яркость
	write_byte(200); // скорость
	message_end();
}
	/*

public fw_TraceAttack_Post(entity, attacker, Float:damage, Float:fDir[3], ptr, damagetype) {
         if(!CustomItem(get_pdata_cbase(attacker, m_pActiveItem, 5))) return HAM_IGNORED;
         static Float:vecEnd[3]; get_tr2(ptr, TR_vecEndPos, vecEnd);
    engfunc(EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, vecEnd, 0);
         write_byte(TE_GUNSHOTDECAL);
    engfunc(EngFunc_WriteCoord, vecEnd[0]);
         engfunc(EngFunc_WriteCoord, vecEnd[1]);
         engfunc(EngFunc_WriteCoord, vecEnd[2]);
         write_short(entity);
         write_byte(random_num(41, 45));
         message_end();
         return HAM_IGNORED;
}
*/


