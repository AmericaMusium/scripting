#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <engine>
#include <dodx>
#include <dodfun>
#include <dod_stocks>
#include <fun>

#pragma semicolon 1
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
new is_player_caller[32];
#define MAXKILLS_FOR_AIRSUPLLY 1
#define AIRSTRIKE_CHARGE_MODEL "sprites/laserbeam.spr" // Модель для отображения во время зарядки
// #define AIRSTRIKE_REF_CLASSNAME "weapon_piat"


#define AIRSTRIKE_V_MODEL "models/v_rb3r.mdl"
#define AIRSTRIKE_P_MODEL "models/p_rb3r.mdl"
#define DODW_RADIOAIR 50

new const Target_Classname[] = "target_airstrike"; //Classname  entity
new const Target_Model[] = "models/mapmodels/vicenza_tree1.mdl";

new g_msgWeaponList;


public plugin_init()
{
    register_plugin("DOD Air KillStreak", "0.0", "America");    
    // регистрируем убийство
    // RegisterHam(Ham_Killed, "player", "on_Killed_P", 1);
    RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_piat", "on_Ham_Weapon_SecondaryAttack_P", true);
    RegisterHam(Ham_Item_Deploy, "weapon_piat", 	"on_Ham_Item_Deploy_Post",	true);

    g_msgWeaponList	= get_user_msgid( "WeaponList" );

    register_event("CurWeapon","on_CurWeapon_P","be", "1=1"); // процедура не обязятельная (лишняя)
    register_think(Target_Classname, "Target_Think");


    // debug
    register_clcmd( "say /ak", "RadioItem_Give" );
}

public plugin_precache()
{
    // precache_model(AIRSTRIKE_CHARGE_MODEL);
    precache_model(AIRSTRIKE_V_MODEL);
    precache_model(AIRSTRIKE_P_MODEL);
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
        RadioItem_Give(idx_killer);
    }
}

stock Ham_Weapon_Give(idx_player)
{
    // if(!equal(weapon,g_classnames[weapon_],7)) return 0;

    new idx_wpn = engfunc(EngFunc_CreateNamedEntity,engfunc(EngFunc_AllocString, "weapon_piat"));
    if(!pev_valid(idx_wpn)) return 0;

    set_pev(idx_wpn, pev_spawnflags, SF_NORESPAWN);
    dllfunc(DLLFunc_Spawn, idx_wpn);

    set_pdata_int(idx_wpn, m_iClip, 0);
    set_pdata_int(idx_wpn, m_iDefaultAmmo, 0);
    entity_set_int(idx_wpn, EV_INT_iuser4, DODW_RADIOAIR);

    if(!ExecuteHamB(Ham_AddPlayerItem,idx_player,any:idx_wpn) || !ExecuteHamB(Ham_Item_AttachToPlayer, idx_wpn,any:idx_player))
    {
        if(pev_valid(idx_wpn)) set_pev(idx_wpn,pev_flags,pev(idx_wpn,pev_flags) & FL_KILLME);
        return 0;
    }
    return 1;
}

public RadioItem_Give(idx_caller)
{   
    Ham_Weapon_Give(idx_caller);
    is_player_caller[idx_caller] = 1;

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
    client_print(0, print_chat, "idx_wpn  WEAPONSLOT " );
    // new Float:FVec[3];
    // pev(idx_caller,pev_origin,FVec);

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
        // set_task(2.0, "UTIL_Set_FOV_zoom", idx_player);
    }
}       

public on_Ham_Item_Deploy_Post(idx_wpn)
{
    if(entity_get_int(idx_wpn, EV_INT_iuser4) == DODW_RADIOAIR)
    {
        new id_owner = get_pdata_cbase(idx_wpn, m_pPlayer, linux_diff_weapon);
        set_pev(id_owner, pev_viewmodel2 , AIRSTRIKE_V_MODEL);
        entity_set_string(id_owner, EV_SZ_weaponmodel, AIRSTRIKE_P_MODEL);
        // pev(idx_wpn, pev_body, g_weapons[i][v_submdl] ) если будет субмодель
        return HAM_IGNORED;
    }
    return HAM_IGNORED;
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
    Targer_Create(idx_owner);
}


public Targer_Create(idx_player)
{   
    if(is_player_caller[idx_player] == false)
    {   
        return;
    }

    if(is_user_connected(idx_player) && is_user_alive(idx_player))
    {     
        // new iOrigin[3];
        new iOrigin_target[3]; //  
        // get_user_origin(idx_player, iOrigin, 0); //    looks
        get_user_origin(idx_player, iOrigin_target, 4); //  
        
        new Float:fOrigin[3]; //   float 
        IVecFVec(iOrigin_target, fOrigin); //     

        //// CREATE ENITY 
        new idx_target = create_entity("info_target");    
        set_pev(idx_target, pev_classname, Target_Classname);
        set_pev(idx_target, pev_solid, SOLID_NOT);   
        set_pev(idx_target, pev_movetype, MOVETYPE_TOSS);
        set_pev(idx_target, pev_owner, idx_player);
        // Если нужно что бы разбивалось от пули , надо менять на 
        // SOLID_BBOX и менять точку старта, а то задевае игрока
        // set_pev(idx_target, pev_health, 1.0);
        // set_pev(idx_target, pev_takedamage, DAMAGE_YES);
        
        entity_set_edict(idx_target, EV_ENT_owner, idx_player);
        // static Float:vVelocity[3]
        // velocity_by_aim(id, 300, vVelocity)
        // set_pev(idx_target, pev_velocity, vVelocity)
        set_pev(idx_target, pev_origin, fOrigin);
        // engfunc(EngFunc_SetModel, idx_target, Target_Model);// 
        if(!pev_valid(idx_target)) 
        {
            return;
        }
        set_pev(idx_target, pev_nextthink, get_gametime() + 1.0);
        client_print(0, print_chat, "231 is_player_caller[idx_player] == false)");
    }
}

public Target_Think(idx_target)
{   

    if(pev_valid(idx_target))
    {
    new idx_owner = pev( idx_target, pev_owner);
    new idx_weapon = get_pdata_cbase(idx_owner, m_pActiveItem, linux_diff_player);
    new Is_Bazooka_Aimed = get_pdata_cbase(idx_weapon, m_iWeaponState, linux_diff_weapon);

    client_print(0, print_chat, "242 set_pev(idx_target, pev_nextthink, get_gametime() + 1.0);");
    if(Is_Bazooka_Aimed && Util_Should_Message_Client(idx_owner))
    {
        new iOrigin_target[3]; //  
        get_user_origin(idx_owner, iOrigin_target, 3); //  
        new Float:fOrigin[3]; //   float 
        IVecFVec(iOrigin_target, fOrigin); //    
        set_pev(idx_target, pev_origin, fOrigin);
        set_pev(idx_target, pev_nextthink, get_gametime() + 1.0);
        client_print(0, print_chat, "250 set_pev(idx_target, pev_nextthink, get_gametime() + 1.0);");
    }
    }
        // remove_entity(idx_target);
}

//////// 
public Util_Should_Message_Client( idx_player )
{
    if( idx_player == 0 || idx_player > MAX_PLAYERS )
    {
        return false;
    }

    if( is_user_connected( idx_player ) && !is_user_bot( idx_player ) && is_user_alive( idx_player))
    {
        return true;
    }
    return false;
} 