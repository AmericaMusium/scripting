#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <fakemeta_util>
#include <dodx>
#include <dodfun>
#include <fun>
#include <engine>

new VERSION[] = "1.1"

new const model_nade_world[] = { "models/snowballs/w_snowball.mdl" }
new const model_nade_view[] = { "models/snowballs/v_snowball.mdl" }
new const model_trail[] = { "sprites/blood-narrow.spr" }
new g_SpriteBlood;


public plugin_precache()
{
	g_SpriteBlood = precache_model(model_trail);

	precache_model(model_nade_world);
	precache_model(model_nade_view);
}

public plugin_init()
{
	register_plugin("ThrowKnifes", "2025", "America");
	register_clcmd("say /snowball", "snowball_throw");
	RegisterHam(Ham_Touch, "info_target", "ThrowedKnife_Touch", 1);

}

public snowball_throw(idx_player)
{	
	new Float:fOrigin[3];
	new iOrigin[3];
	get_user_origin(idx_player, iOrigin, 1);
	IVecFVec(iOrigin, fOrigin);
	
	// CREATE ENITY;
	new idx_snowball = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"));
	if(!pev_valid(idx_snowball))   return;

	set_pev(idx_snowball, pev_classname, "snowball_projectile"); // Добавил класснейм
	set_pev(idx_snowball, pev_solid, SOLID_TRIGGER);
	set_pev(idx_snowball, pev_movetype, MOVETYPE_TOSS);
	engfunc(EngFunc_SetSize, idx_snowball, Float:{-2.0, -2.0, -2.0}, Float:{2.0, 2.0, 2.0}); // Исправил размер
	
	set_pev(idx_snowball, pev_owner, idx_player); // Исправил установку владельца
	engfunc(EngFunc_SetModel, idx_snowball, model_nade_world);
	
	new Float:vVelocity[3], Float:vAngles[3];
	
	// Получаем текущие углы прицеливания игрока
	pev(idx_player, pev_v_angle, vAngles);
	
	// Смещаем угол на 25 градусов вверх
	vAngles[0] -= 20.0; // pitch (вверх/вниз)
	
	// Преобразуем углы в вектор направления
	angle_vector(vAngles, ANGLEVECTOR_FORWARD, vVelocity);
	
	// Умножаем на скорость
	vVelocity[0] *= 900.0;
	vVelocity[1] *= 900.0;
	vVelocity[2] *= 900.0;
	
	set_pev(idx_snowball, pev_velocity, vVelocity);
	set_pev(idx_snowball, pev_origin, fOrigin);
	set_pev(idx_snowball, pev_angles, vAngles); // Устанавливаем углы снежка
	set_pev(idx_snowball, pev_nextthink, get_gametime() + 0.3);
	fx_trail(idx_snowball);
}

public ThrowedKnife_Touch(idx_snowball, idx_object)
{	
	if(!pev_valid(idx_snowball)) return;
	new snowball_owner = entity_get_edict(idx_snowball, EV_ENT_owner);

	if(idx_object == snowball_owner) return;

	if(is_user_alive(idx_object) && !is_user_bot(idx_object)) 
	{
	
	new gmsgShake = get_user_msgid("ScreenShake")
	message_begin(MSG_ONE, gmsgShake, {0,0,0}, idx_object)
	write_short(255<<14) //ammount
	write_short(5<<14) //lasts this long
	write_short(255<<14) //frequency
	message_end()
	
	}

	// Получаем позицию касания
	new Float:origin[3];
	pev(idx_snowball, pev_origin, origin);
	

	new i_Ori[3];
	FVecIVec(origin, i_Ori);
	fx_bloodpuff_custom(i_Ori);
	
	// Удаляем снежок
	remove_entity(idx_snowball);
}



public fx_trail(idx_throwed_knife)
{
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BEAMFOLLOW);	// Temp entity type
	write_short(idx_throwed_knife);	// entity
	write_short(g_SpriteBlood);	// sprite index
	write_byte(6);	// life time in 0.1's
	write_byte(2);	// line width in 0.1's
	write_byte(200); // red (RGB) - белый цвет для снежка
	write_byte(200);	// green (RGB)
	write_byte(200); // blue (RGB)
	write_byte(150); // brightness
	message_end();
}


public fx_bloodpuff_custom(i_Ori[3])
{
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BLOODSPRITE);
	write_coord(i_Ori[0]);
	write_coord(i_Ori[1]);
	write_coord(i_Ori[2]);
	write_short(g_SpriteBlood);
	write_short(g_SpriteBlood);
	write_byte(14); // COLOR 
	write_byte(2);
	message_end();
}