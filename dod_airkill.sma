#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <engine>
#include <dodx>
#include <dodfun>
#include <dod_stocks>
#include <fun>

#pragma semicolon 1
/*
Хочу написать для Day Of Defeat 1.3 goldsrc amxx плагин, что бы при достижении количества убийств была возможность вызвать авиаудар

запустить расчёт киллов до смерти , при достижении макскилл открыть возможность для вызова айрсупплай

взять в руки вызовную станцию, запустить перезарядку R, при выстреле вызвать и удалить из инвентаря. 

запустить префрейм и если одета система вызова PIAT shouldered, то рисовать энтити
Во время зарядки создать entity объект видимый строго на клиенте.  сохранить origin 

Вызвать на origin ракетную атаку. 
*/
// Linux extra offsets
#define linux_diff_weapon 4
#define linux_diff_player 5
#define linux_diff_animation 4

#define m_iClip 108  			// int-
#define m_iDefaultAmmo 112  			// int-
#define current_ammo 114  			// int-


#define m_pPlayer 89 			// int returns owner's of weapon
#define m_knifeItem 272			// prt ножа 
#define m_pistolItem 273        //  ptr пистолета в инвентаре
#define m_rifleItem 274        //  ptr основы в инвентаре
#define m_nadeItem 276          //

#define m_pActiveItem 278 		// возвращает Entity idx оружия в руках (не константу) + linux_diff_player
#define m_rgpPlayerItems 81		// Weaponbox ячейки
#define m_fInReload	111         //  Integer 
#define m_iWeaponState 115		// IS BAZOOKA/PIAT/PSCHREK Shouldered


new kill_points[32];
new bool:is_player_caller[32];
#define MAXKILLS_FOR_AIRSUPLLY 1
#define AIRSTRIKE_CHARGE_MODEL "sprites/laserbeam.spr" // Модель для отображения во время зарядки
#define AIRSTRIKE_V_MODEL "models/v_binoculars.mdl"


new const Target_Classname[] = "target_airstrike"; //Classname  entity
new const Target_Model[] = "models/mapmodels/vicenza_tree1.mdl";

new g_msgWeaponList;

new KNIVES_NAMES[3][] = {"weapon_amerknife","weapon_gerknife","weapon_spade"};
new KNIVES_MODELS[3][] = {"models/w_amerk.mdl","models/w_paraknife.mdl","models/w_spade.mdl"};

new PISTOLS_NAMES[3][] = {"weapon_colt","weapon_webley","weapon_luger"};
new PISTOLS_MODELS[3][] = {"models/w_colt.mdl","models/w_webley_v1.mdl","models/w_luger.mdl"};


public plugin_init()
{
	register_plugin("DOD Air KillStreak", "0.0", "America");    
    // регистрируем убийство
    RegisterHam(Ham_Killed, "player", "on_Killed_P", 1);
    RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_piat", "on_Ham_Weapon_SecondaryAttack_P", 1);

    g_msgWeaponList	= get_user_msgid( "WeaponList" );
    for(new i = 0; i < 3; i++)
    {
        RegisterHam(Ham_DOD_Item_CanDrop,KNIVES_NAMES[i],"func_WeaponDrop");
        RegisterHam(Ham_DOD_Item_CanDrop,PISTOLS_NAMES[i],"func_WeaponDrop");
    }
    register_event("CurWeapon","on_CurWeapon_P","be", "1=1"); // процедура не обязятельная (лишняя)
    register_think(Target_Classname, "target_think");

}

public plugin_precache()
{
    // precache_model(AIRSTRIKE_CHARGE_MODEL);
    precache_model(AIRSTRIKE_V_MODEL);
    precache_model(Target_Model);
    
}

public on_Killed_P(idx_victim, idx_killer)
{   
    if(is_user_bot(idx_killer))
    {
        return;
    }
    // ведём подсчёт очков
    kill_points[idx_killer] ++;
    kill_points[idx_victim] = 0;
    if(kill_points[idx_killer] >= MAXKILLS_FOR_AIRSUPLLY)
    {
        // GIVE RAADIO ITEM4
        give_radio_item(idx_killer);
    }
}

stock ham_give_weapon(idx_player)
{
	// if(!equal(weapon,g_classnames[weapon_],7)) return 0;
	
	new idx_wpn = engfunc(EngFunc_CreateNamedEntity,engfunc(EngFunc_AllocString, "weapon_piat"));
	if(!pev_valid(idx_wpn)) return 0;
	    
	set_pev(idx_wpn, pev_spawnflags, SF_NORESPAWN);
	dllfunc(DLLFunc_Spawn, idx_wpn);

    set_pdata_int(idx_wpn, m_iClip, 0);
    set_pdata_int(idx_wpn, m_iDefaultAmmo, 0);
	    
	if(!ExecuteHamB(Ham_AddPlayerItem,idx_player,any:idx_wpn) || !ExecuteHamB(Ham_Item_AttachToPlayer, idx_wpn,any:idx_player))
	{
		if(pev_valid(idx_wpn)) set_pev(idx_wpn,pev_flags,pev(idx_wpn,pev_flags) & FL_KILLME);
		return 0;
	}
	return 1;
}

public give_radio_item(idx_caller)
{   

    /// выдавать такой предмет, которого нет в инвентаре у человека надо
    // give_item(idx_caller, "weapon_piat");
    ham_give_weapon(idx_caller);
    is_player_caller[idx_caller] = true;

    message_begin( MSG_ONE, g_msgWeaponList, {0,0,0}, idx_caller );
    write_byte( AMMO_ROCKET ); // Ammo 3 Type 
    write_byte( 0 ); // Ammo 1 Max
    write_byte( 0 ); // Ammo 2 Type
    write_byte( 0 ); // Ammo 2 Max
    write_byte( 3 ); // Slot (Starts at 0) НОМЕР СЛОТА 6 свободен, но худ не видно / 4й видно слот !
    write_byte( 1 ); // Bucket (Starts at 0) ЭТО НОМЕР ОРУЖИЯ В СЛОТЕ ПО ПОРЯДКУ.
    write_short( 31 ); // Weapon ID
    write_byte( 0); // Flags
    write_byte( 1 ); // Clip Ammo // кратность деления количества патронов в обойме. в результате покажет остаток патронов в запасе . если у Вас 60 патронов, то при 1 = 60, если 5 =12
    message_end();
	// 

    new Float:FVec[3];
	pev(idx_caller,pev_origin,FVec);
}

// Drop the weapon
public func_WeaponDrop(ent)
{
    SetHamReturnInteger(1);
    return HAM_SUPERCEDE;
}

public on_CurWeapon_P(idx_player)
{   
    // проверить, если достоин
    
    if(is_player_caller[idx_player])
    {
        new idx_DODW = read_data(2);
        //if(idx_DODW==DODW_WEBLEY)
        //{ 
            client_print(0, print_chat, "DODW = %d ", idx_DODW );
            // set_pev(idx_player, pev_viewmodel2 , AIRSTRIKE_V_MODEL);
           // set_task(2.0, "UTIL_Set_FOV_zoom", idx_player);
    }
}       



public UTIL_Set_FOV(idx_player, i_fov)
{
    // Использовать MSG_ONE, чтобы не затрагивать других игроков
    message_begin(MSG_ONE, get_user_msgid("SetFOV"), _, idx_player);
    write_byte(i_fov);
    message_end();
}


public on_Ham_Weapon_SecondaryAttack_P(idx_wpn)
{   
    // это однокраный вызов по клику. сделать проверку на шоулдеред
    // создать объект прицела с проверка на шоулдеред и сменой координат. 
    new idx_owner = pev( idx_wpn, pev_owner);
    client_print(0, print_chat, "SSSSSECCC");
    target_create(idx_owner);
}




public target_think(idx_target)
{   
    if(pev_valid(idx_target))
    {
    new idx_owner = pev( idx_target, pev_owner);
    new iOrigin_target[3]; //  
    // get_user_origin(idx_player, iOrigin, 0); //    looks
    get_user_origin(idx_owner, iOrigin_target, 3); //  
    new Float:fOrigin[3]; //   float 
    IVecFVec(iOrigin_target, fOrigin); //    
    set_pev(idx_target, pev_origin, fOrigin);
    set_pev(idx_target, pev_nextthink, get_gametime() + 1.0);
    
    // if player alive // if player shouldered
   // new activeitem // = get_pdata_cbase(idx_owner, m_pActiveItem, linux_diff_player);
    new is_radio_activemode = dod_shouldered(idx_owner);
    client_print(0, print_chat, "THINKS BY owner %d || is_radio_activemode %d", idx_owner , is_radio_activemode);
    }
    else return;
}