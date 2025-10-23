#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <fakemeta_util>
#include <dodx>
#include <dodfun>
#include <fun>
#include <engine>

#pragma semicolon 1

// RUS Description: 
// Плагин позволяет метнуть лопатку в противника и убить его 

#define TOUCH_DAMAGE 1
#define TOUCH_WEAPONBOX 0

// Макросы
#define get_touch_mode(%1) entity_get_int(%1,EV_INT_iuser1)
#define set_touch_mode(%1,%2) entity_set_int(%1,EV_INT_iuser1,%2) 
#define get_dodwid(%1) entity_get_int(%1,EV_INT_iuser2)
#define set_dodwid(%1,%2) entity_set_int(%1,EV_INT_iuser2,%2)

/// переопределяем смещения 
// Linux extra offsets
#define linux_diff_weapon 4
#define linux_diff_player 5
#define linux_diff_animation 4
// DOD CBASE offsets 


#define m_iId 91 // CbasePlayerItem
#define m_pPlayer 89 	// int returns weapon's owner  Cbase
#define m_pKnifeItem 272
#define m_pActiveItem 278 // ptr active weapon
#define m_pPlayer 89 			// int returns owner's of weapon
//// Fakameta-engine interpriter
#define G_CLSNAME_THROWKNIFE "thrknife"

// DODW_SPADE 19/ DODW_GERKNIFE 2/ DODW_AMERKNIFE 1/ DODW_BRITKNIFE 37
new Knife_Classnames[3][] = {"weapon_amerknife","weapon_gerknife","weapon_spade"}; // brit == weapon_amerknife
new Knife_Models[3][] = {"models/w_amerk.mdl", "models/w_paraknife.mdl", "models/w_spade.mdl"};

/// Register array of sounds
new const g_ThrowSound[] = "weapons/knifeswing2.wav";
new const g_ThrowFlySound[] = "weapons/knifeswing2.wav";
new const g_ThrowHitwallSound[] = "weapons/cbar_hit1.wav";
new const g_ThrowHitHumanSound[] = "weapons/hit_grass2.wav";
// Register player trigger
   
// Register messages 
new g_SpriteBlood;
new g_msgBloodPuff;// bloodpuff by touching knife to player
new g_MsgDeathMsg; // register hud message who kills with knifetype

// CVars
new cv_stackinwall; //  Stack 1 = 0, no stack in wall = 0
new cv_bldsprt; // bonus boold splashes 1 on . 0 = off 
new cv_spspeed; // speed fly spade
new cv_sprot; // rotation speed
new cv_trail; // trail for knife
new cv_glow; // fx glow model
//// Function list 

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

	cv_stackinwall = register_cvar("stack1_nostack0","0");
	cv_bldsprt = register_cvar("bloodspash1_no0","0");
	cv_spspeed = register_cvar("sp_speed", "1100");
	cv_sprot = register_cvar("sp_rotation","900");
	cv_trail = register_cvar("fx_trail","1");
	cv_glow = register_cvar("fx_glow","1");


	TumbleVector[0] = -float(get_pcvar_num(cv_sprot)); // = 1320.0  // Wheel


	g_maxpl = get_maxplayers();
	g_FriendlyFire = get_cvar_num ("mp_friendlyfire");

	// Регистрируем события взять ножа в руки
	for (new i = 0; i < sizeof(Knife_Classnames); i++)
	{	
		RegisterHam(Ham_Item_Deploy,Knife_Classnames[i], "Ham_Item_Deploy_P");
	}

	// RegisterHam(Ham_Touch, "info_target", "ThrowedKnife_Touch", 1);
	register_touch(G_CLSNAME_THROWKNIFE, "", "ThrowedKnife_Touch");

	g_msgBloodPuff = get_user_msgid("BloodPuff");
	g_MsgDeathMsg = get_user_msgid("DeathMsg");
	register_event("23", "fx_wallscratch", "a", "1=116", "1=104");

}


public Ham_Item_Deploy_P(idx_weapon)
{

	new dodw_id = get_dodw_id_from_ptr_idx_weapon(idx_weapon);
	new idx_player = get_pdata_cbase(idx_weapon, m_pPlayer, linux_diff_weapon);
	switch(dodw_id)
	{
		case DODW_AMERKNIFE, DODW_GERKNIFE, DODW_SPADE, DODW_BRITKNIFE:
		{
			// Если игрок взял в руки нож, регистрировать форварды
			
			for (new i = 0; i < sizeof(Knife_Classnames); i++)
			{   
				RegisterHam(Ham_Item_PreFrame, Knife_Classnames[i], "Ham_Item_PreFrame_P");

				is_player_can_throw_knife[idx_player] = 1;

			}
			
		}
		default: return HAM_IGNORED;
	}
	return HAM_IGNORED;
}


public Ham_Item_PreFrame_P(idx_weapon)
{   
	// кто хозяин ?
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
	get_point_from_eyes_distance( idx_player, 30, fOrigin);

	//// CREATE ENITY ;
	new idx_throwed_knife = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"));
	if(!pev_valid(idx_throwed_knife))   return;

	new knife_dodw_id = get_dodw_id_from_ptr_idx_weapon(get_pdata_cbase(idx_player, m_pKnifeItem, linux_diff_weapon));
	set_pev(idx_throwed_knife, pev_classname, G_CLSNAME_THROWKNIFE);
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
	
	engfunc(EngFunc_SetSize, idx_throwed_knife, Float:{-1.0, -1.0, 1.0}, Float:{1.0, 1.0, 1.0});
	entity_set_edict(idx_throwed_knife, EV_ENT_owner, idx_player);

	new Float:vVelocity[3], Float:vAngles[3];
	velocity_by_aim(idx_player, get_pcvar_num(cv_spspeed), vVelocity);
	set_pev(idx_throwed_knife, pev_velocity, vVelocity);
	set_pev(idx_throwed_knife, pev_origin, fOrigin);

	vector_to_angle(vVelocity, vAngles);
	vAngles[0] += 45.0;
	vAngles[2] += 80.0;

	set_pev(idx_throwed_knife, pev_angles, vAngles);
	//set_pev(idx_throwed_knife, pev_nextthink, get_gametime() +0.1);

	entity_set_int(idx_throwed_knife, EV_INT_iuser1, TOUCH_DAMAGE);
	
	set_dodwid(idx_throwed_knife, knife_dodw_id);
	ham_strip_weapon_2(idx_player);
	
	
	// FX SOUND
	emit_sound(idx_throwed_knife, CHAN_AUTO, g_ThrowSound, 0.9, ATTN_NORM, 0, PITCH_NORM);
	// +Sound Effect
	set_task(0.13, "fx_throwing_sound", idx_throwed_knife);
	// +Glow Effect
	if(get_pcvar_num(cv_glow) == 1)
		set_rendering(idx_throwed_knife, kRenderFxGlowShell, random(255), random(255), random(255), kRenderNormal, random_num(1, 50));
	// FX_TRAIL
	if(cv_trail)
	{
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
		write_byte(TE_BEAMFOLLOW);	// Temp entity type
		write_short(idx_throwed_knife);	// entity
		write_short(g_SpriteBlood);	// sprite index
		write_byte(4);	// life time in 0.1's
		write_byte(2);	// line width in 0.1's
		write_byte(63);// red (RGB)
		write_byte(63);	// green (RGB)
		write_byte(63);// blue (RGB)
		write_byte(200);// brightness == 0 invisible, 255 visible
		message_end();
	}
}

	////// Small Stocks
public get_dodw_id_from_ptr_idx_weapon(ptr_idx_weapon)
{   
	if(ptr_idx_weapon == -1 || !pev_valid(ptr_idx_weapon)) return -1;
	return get_pdata_int(ptr_idx_weapon, m_iId, linux_diff_weapon);
}
public ThrowedKnife_Touch(idx_throwed_knife, idx_object)
{
    if(!pev_valid(idx_throwed_knife))
        return HAM_IGNORED;

    new classname[32];
    pev(idx_throwed_knife, pev_classname, classname, 31);

    if(equali(classname, G_CLSNAME_THROWKNIFE))
    {
        // Register Universal data
        new Float:f_Ori[3], i_Ori[3];
        new last_touch_mode = get_touch_mode(idx_throwed_knife);

        new knife_owner = entity_get_edict(idx_throwed_knife, EV_ENT_owner);

        entity_get_vector(idx_throwed_knife, EV_VEC_origin, f_Ori);
        FVecIVec(f_Ori, i_Ori);

        set_touch_mode(idx_throwed_knife, TOUCH_WEAPONBOX);

        // Проверяем, является ли объект игроком
        if (idx_object > 0 && idx_object <= g_maxpl && is_user_alive(idx_object))
        {
            switch (last_touch_mode)
            {
                case TOUCH_DAMAGE:
                {
                    if(knife_owner != idx_object)
                    {
                        emit_sound(idx_throwed_knife, CHAN_AUTO, g_ThrowHitHumanSound, 0.4, ATTN_IDLE, 0, PITCH_NORM);
                        fx_bloodpuff(i_Ori);
                        set_pev(idx_throwed_knife, pev_solid, SOLID_SLIDEBOX);
                        switch (g_FriendlyFire)
                        {
                            case 1:
                            {
                                fx_death_message(knife_owner, idx_object, get_dodwid(idx_throwed_knife));
                                user_silentkill(idx_object);
                                dod_set_user_kills(knife_owner, (dod_get_user_kills(knife_owner) + 1), 1);
                            }
                            default:
                            {
                                if(get_user_team(knife_owner) != get_user_team(idx_object))
                                {
                                    fx_death_message(knife_owner, idx_object, get_dodwid(idx_throwed_knife));
                                    user_silentkill(idx_object);
                                    dod_set_user_kills(knife_owner, (dod_get_user_kills(knife_owner) + 1), 1);
                                }
                            }
                        }
                    }
                }
                case TOUCH_WEAPONBOX:
                {
                    switch (get_dodwid(idx_throwed_knife))
                    {
                        case DODW_AMERKNIFE: give_item(idx_object, "weapon_amerknife");
                        case DODW_GERKNIFE: give_item(idx_object, "weapon_gerknife");
                        case DODW_SPADE: give_item(idx_object, "weapon_spade");
                        default: // == case DODW_BRITKNIFE
                        {
                            give_item(idx_object, "weapon_amerknife");
                        }
                    }

                    remove_entity(idx_throwed_knife);
                    return HAM_IGNORED;
                }
                default: return HAM_IGNORED;
            }
            return HAM_IGNORED;
        }
        else
        {
            // WOLRD
            if (pev(idx_throwed_knife, pev_flags) & FL_ONGROUND)
            {
                set_pev(idx_throwed_knife, pev_solid, SOLID_TRIGGER);
            }

            fx_sparks(i_Ori);
            emit_sound(idx_throwed_knife, CHAN_AUTO, g_ThrowHitwallSound, 0.3, 1.0, 0, PITCH_NORM);

            if(get_pcvar_num(cv_stackinwall) == 1)
            {
                set_pev(idx_throwed_knife, pev_movetype, MOVETYPE_NONE);
                set_task(2.0, "fx_unstuck", idx_throwed_knife);
                return HAM_IGNORED;
            }
        }

        fx_damp_veloctiy(idx_throwed_knife);
        return HAM_IGNORED;
    }
    return HAM_IGNORED;
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
	if( get_touch_mode (idx_throwed_knife))
	{
			emit_sound(idx_throwed_knife, CHAN_AUTO, g_ThrowSound,0.5 ,ATTN_NORM, 0, PITCH_HIGH);
			set_task(0.12, "fx_throwing_sound", idx_throwed_knife);
	}	

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