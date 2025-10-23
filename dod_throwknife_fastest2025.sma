#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <dodx>
#include <dodfun>
#include <fun>
#include <engine>

#pragma semicolon 1

// RUS Description: 
// Плагин позволяет метнуть лопатку в противника и убить его 

#define TOUCH_DAMAGE 1
#define TOUCH_WEAPONBOX 0
#define YES_THIS_IS_THROWEDKNIFE 9
#define TASK_REMOVE_OLD_KNIFE 1957

// Макросы
#define get_touch_mode(%1) entity_get_int(%1,EV_INT_iuser1)
#define set_touch_mode(%1,%2) entity_set_int(%1,EV_INT_iuser1,%2) 
#define get_dodwid(%1) entity_get_int(%1,EV_INT_iuser2)
#define set_dodwid(%1,%2) entity_set_int(%1,EV_INT_iuser2,%2)
#define is_this_throwed_knife(%1) entity_get_int(%1,EV_INT_iuser3)
#define this_is_this_throwed_knife(%1) entity_set_int(%1,EV_INT_iuser3, YES_THIS_IS_THROWEDKNIFE)

// Linux extra offsets переопределяем смещения 
#define linux_diff_weapon 4
#define linux_diff_player 5
// DOD CBASE offsets 
#define m_iId 91 // CbasePlayerItem
#define m_pPlayer 89 	// int returns weapon's owner  Cbase
#define m_pKnifeItem 272
#define m_pActiveItem 278 // ptr active weapon
#define m_pPlayer 89 			// int returns owner's of weapon

// DODW_SPADE 19/ DODW_GERKNIFE 2/ DODW_AMERKNIFE 1/ DODW_BRITKNIFE 37
new const Knife_Classnames[3][] = {"weapon_amerknife","weapon_gerknife","weapon_spade"}; // brit == weapon_amerknife
new const Knife_Models[3][] = {"models/w_amerk.mdl", "models/w_paraknife.mdl", "models/w_spade.mdl"};

/// Register array of sounds
new const g_ThrowSound[] = "weapons/knifeswing2.wav";
new const g_ThrowFlySound[] = "weapons/knifeswing2.wav";
new const g_ThrowHitwallSound[] = "weapons/cbar_hit1.wav";  // "1944/1944knife.wav";  // "weapons/1944hitiron.wav";   // "weapons/cbar_hit1.wav"; 
new const g_ThrowHitHumanSound[] = "weapons/hit_grass2.wav";
// Register messages 
new g_SpriteBlood;
new g_msgBloodPuff;// bloodpuff by touching knife to player
new g_MsgDeathMsg; // register hud message who kills with knifetype

// CVars
new cv_stackinwall; //  Stack 1 = 0, no stack in wall = 0
new cv_bldsprt; 	// bonus boold splashes 1 on . 0 = off 
new cv_spspeed; 	// speed fly spade
new cv_sprot; 		// rotation speed
new cv_trail; 		// trail for knife
new cv_glow; 		// fx glow model

new Float:TumbleVector[3];
// server data
new g_maxpl; // need for difference touch index nums
new g_FriendlyFire;

// Cчётчик выброшенных ножей
new is_player_can_throw_knife[33];

public plugin_precache()
{
	precache_model(Knife_Models[0]);
	precache_model(Knife_Models[1]);
	precache_model(Knife_Models[2]);
	precache_sound(g_ThrowSound);
	precache_sound(g_ThrowFlySound);
	precache_sound(g_ThrowHitwallSound);
	precache_sound(g_ThrowHitHumanSound);
	
	g_SpriteBlood = precache_model("sprites/blood-narrow.spr");
}

public plugin_init()
{
	register_plugin("ThrowKnifes", "2025", "America");

	cv_stackinwall = register_cvar("stack1_nostack0", "0"); // Not already complete
	cv_bldsprt = register_cvar("bloodspash1_no0", "0");
	cv_spspeed = register_cvar("sp_speed", "1400");
	cv_sprot = register_cvar("sp_rotation", "900");
	cv_trail = register_cvar("fx_trail", "1");
	cv_glow = register_cvar("fx_glow", "1");

	TumbleVector[0] = -float(get_pcvar_num(cv_sprot)); // = 1320.0  // Wheel

	g_maxpl = get_maxplayers();
	g_FriendlyFire = get_cvar_num ("mp_friendlyfire");

	// Регистрируем события взять ножа в руки
	for (new i = 0; i < sizeof(Knife_Classnames); i++)
	{	
		RegisterHam(Ham_Item_Deploy, Knife_Classnames[i], "Ham_Item_Deploy_P");
		RegisterHam(Ham_Item_PreFrame, Knife_Classnames[i], "Ham_Item_PreFrame_P");
	}

	RegisterHam(Ham_Touch, "info_target", "ThrowedKnife_Touch", 1);

	g_msgBloodPuff = get_user_msgid("BloodPuff");
	g_MsgDeathMsg = get_user_msgid("DeathMsg");
	register_event("23", "fx_wallscratch", "a", "1=116", "1=104");

}


public Ham_Item_Deploy_P(idx_weapon)
{
	switch(get_dodw_id_from_ptr_idx_weapon(idx_weapon))
	{
		case DODW_AMERKNIFE, DODW_GERKNIFE, DODW_SPADE, DODW_BRITKNIFE:
		{
			is_player_can_throw_knife[get_pdata_cbase(idx_weapon, m_pPlayer, linux_diff_weapon)] = 1;
		}
		default: return HAM_IGNORED;
	}
	return HAM_IGNORED;
}


public Ham_Item_PreFrame_P(idx_weapon)
{   
	// Get weapons's owner
	new idx_player = get_pdata_cbase(idx_weapon, m_pPlayer, linux_diff_weapon);
	if(is_user_alive(idx_player))
	{
		if(pev(idx_player,pev_button)&IN_ATTACK2 && is_player_can_throw_knife[idx_player])
		{
			is_player_can_throw_knife[idx_player] = 0;
			ThrowedKnife_Throw(idx_player);
		}
	}
}

public ThrowedKnife_Throw(idx_player)
{
	new Float:fOrigin[3];
	get_point_from_eyes_distance( idx_player, 10, fOrigin);

	// CREATE ENITY;
	new idx_throwed_knife = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"));
	if(!pev_valid(idx_throwed_knife))   return;

	new knife_dodw_id = get_dodw_id_from_ptr_idx_weapon(get_pdata_cbase(idx_player, m_pKnifeItem, linux_diff_weapon));

	this_is_this_throwed_knife(idx_throwed_knife);
	// set_pev(idx_throwed_knife, pev_gravity, 1.0); // DEFAULT IS 1.0
	// set_pev(idx_throwed_knife, pev_solid, SOLID_SLIDEBOX); //// For Igonre Monsters SOLID_SLIDEBOX
	set_pev(idx_throwed_knife, pev_solid, SOLID_TRIGGER);  // +SOLID_TRIGGER
	set_pev(idx_throwed_knife, pev_movetype, MOVETYPE_TOSS); // +MOVETYPE_TOSS
	set_pev(idx_throwed_knife, pev_avelocity, TumbleVector);

	switch (knife_dodw_id)
	{
		case DODW_AMERKNIFE, DODW_BRITKNIFE: engfunc(EngFunc_SetModel, idx_throwed_knife, Knife_Models[0]);
		case DODW_GERKNIFE: engfunc(EngFunc_SetModel, idx_throwed_knife, Knife_Models[1]);
		case DODW_SPADE: engfunc(EngFunc_SetModel, idx_throwed_knife, Knife_Models[2]);
		default: engfunc(EngFunc_SetModel, idx_throwed_knife, Knife_Models[0]);
	}
	
	engfunc(EngFunc_SetSize, idx_throwed_knife, Float:{-2.0, -2.0, 2.0}, Float:{2.0, 2.0, 2.0});
	entity_set_edict(idx_throwed_knife, EV_ENT_owner, idx_player);

	new Float:vVelocity[3], Float:vAngles[3];
	velocity_by_aim(idx_player, get_pcvar_num(cv_spspeed), vVelocity);
	set_pev(idx_throwed_knife, pev_velocity, vVelocity);
	set_pev(idx_throwed_knife, pev_origin, fOrigin);

	vector_to_angle(vVelocity, vAngles);
	vAngles[0] += 45.0;
	vAngles[2] += 80.0;

	set_pev(idx_throwed_knife, pev_angles, vAngles);
	entity_set_int(idx_throwed_knife, EV_INT_iuser1, TOUCH_DAMAGE);
	
	set_dodwid(idx_throwed_knife, knife_dodw_id);
	ham_strip_weapon_2(idx_player);
	
	// fx_ SOUND
	
	
	emit_sound(idx_throwed_knife, CHAN_ITEM, g_ThrowSound, 0.9, ATTN_NORM, 0, random_num(90, 150));
	
	// fx_ +Rotation Sound Effect
	set_task(0.2, "fx_throwing_sound", idx_throwed_knife, _, _, "b");
	// FX_TRAIL
	if(get_pcvar_num(cv_trail))	fx_trail(idx_throwed_knife);

	set_task(60.0, "ThrowedKnife_Remove", TASK_REMOVE_OLD_KNIFE+idx_throwed_knife);
}

public ThrowedKnife_Touch(idx_throwed_knife, idx_object)
{	
	if(!is_valid_ent(idx_throwed_knife)) return HAM_IGNORED;
	switch(is_this_throwed_knife(idx_throwed_knife))
	{
		case YES_THIS_IS_THROWEDKNIFE:
		{
			// Register Universal data
			new Float:f_Ori[3], i_Ori[3];
			new last_touch_mode = get_touch_mode(idx_throwed_knife);
			new knife_owner = entity_get_edict(idx_throwed_knife, EV_ENT_owner);
			entity_get_vector(idx_throwed_knife, EV_VEC_origin, f_Ori);
			FVecIVec(f_Ori, i_Ori);

			// FOR PLAYERS
			if ((idx_object > 0) && (idx_object <= g_maxpl))
			{   
				if (!is_user_alive(idx_object))
					return HAM_IGNORED;
				switch (last_touch_mode)
				{
					case TOUCH_DAMAGE:
					{	
						if(knife_owner != idx_object)
						{	
							set_touch_mode(idx_throwed_knife, TOUCH_WEAPONBOX);
							emit_sound(idx_throwed_knife,CHAN_AUTO, g_ThrowHitHumanSound, 0.4, ATTN_NORM ,0, random_num(90, 150));
							drop_to_floor(idx_throwed_knife);

							fx_bloodpuff(i_Ori);
							if(get_pcvar_num(cv_bldsprt)) fx_bloodpuff_custom(i_Ori);
							switch (g_FriendlyFire)
							{	
								case 1:
								{
									fx_death_message(knife_owner, idx_object, get_dodwid(idx_throwed_knife));
									user_silentkill(idx_object);
									dod_set_user_kills(knife_owner, (dod_get_user_kills(knife_owner) + 1), 1);
									return HAM_IGNORED;

								}
								default:
								{
									if(get_user_team(knife_owner) != get_user_team(idx_object))
									{
										fx_death_message(knife_owner, idx_object, get_dodwid(idx_throwed_knife));
										user_silentkill(idx_object);
										dod_set_user_kills(knife_owner, (dod_get_user_kills(knife_owner) + 1), 1);
										return HAM_IGNORED;
									}
								}
							}
						}
						
					}
					case TOUCH_WEAPONBOX:
					{	
						new success_giving;
						switch ( get_dodwid(idx_throwed_knife))
						{
							case DODW_AMERKNIFE: success_giving = give_item(idx_object, "weapon_amerknife");
							case DODW_GERKNIFE:	success_giving = give_item(idx_object, "weapon_gerknife");
							case DODW_SPADE: success_giving = give_item(idx_object, "weapon_spade");
							default: // == case DODW_BRITKNIFE
							{
								success_giving = give_item(idx_object, "weapon_amerknife");
							}
						}
						if (pev_valid(idx_throwed_knife) && success_giving != -1)	remove_entity(idx_throwed_knife);
						return HAM_IGNORED;
					}
					default: return HAM_IGNORED;
				}
				// проверим return HAM_IGNORED;
			}
			else if (idx_object == 0)
			{	
				// fx_ +Glow Effect
				if(get_pcvar_num(cv_glow))	fx_rendering(idx_throwed_knife);

				switch (last_touch_mode)
				{
					case TOUCH_DAMAGE:
					{
						
						set_touch_mode(idx_throwed_knife, TOUCH_WEAPONBOX);
						fx_sparks(i_Ori);
						fx_damp_veloctiy(idx_throwed_knife);
						emit_sound(idx_throwed_knife, CHAN_AUTO, g_ThrowHitwallSound, 0.6, 1.0, 0, random_num(90, 150));
					
						if(get_pcvar_num(cv_stackinwall))
						{
							set_pev(idx_throwed_knife, pev_movetype, MOVETYPE_NONE);
							set_task(2.0, "fx_unstuck", idx_throwed_knife);
							return HAM_IGNORED;
						}
					}
					default: 
					{	
						emit_sound(idx_throwed_knife, CHAN_AUTO, g_ThrowHitwallSound, 0.4, 1.0, 0, random_num(90, 150));
						return HAM_IGNORED;
					}
				}
				// выходим ввиду отсуствия сравнения с чем
				return HAM_IGNORED;
			}
			else 
			{	
				switch (last_touch_mode)
				{
					case TOUCH_DAMAGE:
					{	
						set_touch_mode(idx_throwed_knife, TOUCH_WEAPONBOX);
						fx_sparks(i_Ori);
						fx_damp_veloctiy(idx_throwed_knife);
						emit_sound(idx_throwed_knife, CHAN_AUTO, g_ThrowHitwallSound, 0.3, 1.0, 0, random_num(90, 150));
						//// Во всех остальных случаях поинтересоваться что за объект и разбить
						new clT[32];
						pev(idx_object, pev_classname, clT, 31);
						if(equal(clT,"func_breakable")) 
						{
							new tgn[16];
							entity_get_string(idx_object, EV_SZ_targetname, tgn, 15);
							server_print("TARGET NAME : %s", tgn);
							// for example in DOD_CHARLIE or CAEN we have some breakeble object which has target name , 
							// thats why we shouldn't destriy this.
							if(!tgn[0])
							{
								ExecuteHam(Ham_TakeDamage, idx_object, 1, 1, 300.0, DMG_BULLET);
								
							}
						}
						/*
						if (pev(idx_throwed_knife, pev_flags) & FL_ONGROUND ) // FL_PARTIALGROUND == cущность находится на частично твердой поверхности
						{
							set_pev( idx_throwed_knife, pev_angles, {0.0, 0.0, 0.0});
						}
						*/
					}
					default: return HAM_IGNORED; // ввиду остуствия вариантов
				}
				return HAM_IGNORED;
			}
			return HAM_IGNORED;
		}
		default: return HAM_IGNORED;
	}
	return HAM_IGNORED;
}

public ThrowedKnife_Remove(idx_throwed_knife)
{
	if(is_valid_ent(idx_throwed_knife-TASK_REMOVE_OLD_KNIFE)) remove_entity(idx_throwed_knife-TASK_REMOVE_OLD_KNIFE);
}

public fx_trail(idx_throwed_knife)
{
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BEAMFOLLOW);	// Temp entity type
	write_short(idx_throwed_knife);	// entity
	write_short(g_SpriteBlood);	// sprite index
	write_byte(12);	// life time in 0.1's
	write_byte(2);	// line width in 0.1's
	write_byte(63);// red (RGB)
	write_byte(63);	// green (RGB)
	write_byte(63);// blue (RGB)
	write_byte(150);// brightness == 0 invisible, 255 visible
	message_end();
}

public fx_rendering(idx_throwed_knife)
{
	set_rendering(idx_throwed_knife, kRenderFxGlowShell, random(255), random(255), random(255), kRenderNormal, 16);
}

public fx_sparks(i_Ori[3])
{
	// FX	
	message_begin(MSG_ALL,SVC_TEMPENTITY);
	write_byte(TE_SPARKS);
	write_coord(i_Ori[0]);
	write_coord(i_Ori[1]);
	write_coord(i_Ori[2]);
	message_end();
}

public fx_bloodpuff(i_Ori[3])
{
	message_begin(MSG_BROADCAST, g_msgBloodPuff, {0,0,0}, 0);
	write_coord(i_Ori[0]);
	write_coord(i_Ori[1]);
	write_coord(i_Ori[2]);
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
	write_byte(248);
	write_byte(2);
	message_end();
}

public fx_death_message(killer, victim, dodw_id)
{
	message_begin(MSG_ALL, g_MsgDeathMsg,{0,0,0},0);
	write_byte(killer); // killer
	write_byte(victim); // victim
	write_byte(dodw_id);  // 42 is smash
	message_end();
}

public fx_damp_veloctiy(idx_throwed_knife)
{	
	new Float: velocity[3];
	pev( idx_throwed_knife, pev_velocity, velocity);
	velocity[0] *= 0.2;
	velocity[1] *= 0.2;
	velocity[2] *= 0.2;
	set_pev(idx_throwed_knife, pev_velocity, velocity);

	pev(idx_throwed_knife, pev_v_angle, velocity);
	velocity[0] *= 0.2; // wheel
	// velocity[1] += 20.0; // tea
	velocity[2] += 20.0; // hours
}


public fx_wallscratch()
{
	static Float:f_Ori[3], i_Ori[3];
	
	switch (read_data(5)) 
	{
		case 54..58: 
		{		// is decal shot1-5?
			read_data(2, f_Ori[0]);
			read_data(3, f_Ori[1]);
			read_data(4, f_Ori[2]);

			FVecIVec(f_Ori,i_Ori);
			fx_sparks(i_Ori);
		}
		default: 
		{
			return;
		}
	}	
}

public fx_throwing_sound(idx_throwed_knife)
{	
	if(!pev_valid(idx_throwed_knife))
		remove_task(idx_throwed_knife);
	else 
	{	
		if(get_touch_mode(idx_throwed_knife) == TOUCH_WEAPONBOX)
		{
			remove_task(idx_throwed_knife);
			return;
		}
		else if (pev(idx_throwed_knife, pev_flags) & FL_ONGROUND)	remove_task(idx_throwed_knife);
		else
		{	
			emit_sound(idx_throwed_knife, CHAN_AUTO, g_ThrowSound, 0.3, ATTN_NORM, 0, PITCH_NORM );
			// set_task(0.12, "fx_throwing_sound", idx_throwed_knife);
			return;
		}
	}
	return;
}

public fx_unstuck(idx_throwed_knife)
{
	if(pev_valid(idx_throwed_knife))
	{	
		set_pev(idx_throwed_knife, pev_movetype, MOVETYPE_TOSS);
		set_pev(idx_throwed_knife, pev_avelocity, {60.0 , 50.0 , 150.0});
		set_pev(idx_throwed_knife, pev_velocity, {0.0 , 0.0 , 0.0});
	}
}
////// Small Stocks
public get_dodw_id_from_ptr_idx_weapon(ptr_idx_weapon)
{   
	if(ptr_idx_weapon == -1 || !pev_valid(ptr_idx_weapon)) return -1;
	return get_pdata_int(ptr_idx_weapon, m_iId, linux_diff_weapon);
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


public ham_strip_weapon_2(idx_player)
{
	new idx_weapon = get_pdata_cbase(idx_player, m_pKnifeItem);
	new dodw_id = get_dodw_id_from_ptr_idx_weapon(idx_weapon);

	new activeitem = get_pdata_cbase(idx_player, m_pActiveItem, linux_diff_player);
	new dodw_id_activeweapon = get_dodw_id_from_ptr_idx_weapon(activeitem);
	if(dodw_id_activeweapon == dodw_id) ExecuteHamB(Ham_Weapon_RetireWeapon, idx_weapon);	    
	if(!ExecuteHamB(Ham_RemovePlayerItem, idx_player, any:idx_weapon)) return 0;

	ExecuteHamB(Ham_Item_Kill, idx_weapon);
	set_pev(idx_player, pev_weapons, pev(idx_player, pev_weapons) & ~(1<<dodw_id));
	return 1;
}