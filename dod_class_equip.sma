#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>
#include <dodx>
#include <dodfun>
#include <fun>
#include <engine>
#include <fakemeta>

#pragma semicolon 1

// Linux extra offsets
#define linux_diff_weapon 4
#define linux_diff_player 5

#define m_iId 91 // CbasePlayerItem

// Dod CbaseWeapon offsets
#define m_pKnifeItem 272			// prt ножа 
#define m_pistolItem 273        //  ptr пистолета в инвентаре
#define m_rifleItem 274        //  ptr основы в инвентаре
#define weaponbox_slot_knife 82
#define weaponbox_slot_pistol 83
#define weaponbox_slot_primary 84

new g_msgWeaponList;

#define m_iPrimaryAmmoType 106  // Item return AMMO_TYPE from ptr idx_weapon
#define m_iClip 108  			// Item return текущий реальный клип
#define m_iClientClip 109       // Item return текущий реальный клип
#define current_ammo 114        // Pointer Int* СPlayerWeapon
#define m_cAmmoTypes 152        // CWeaponBox integer 
#define m_rgAmmo 281            // Используется оффсет + к нему оффстер +AMMO_TYPE // new byammp = get_pdata_int(id_owner, m_rgAmmo + AMMO_TYPE, linux_diff_player);
#define m_iDefaultAmmo 112  	// int-
#define m_pPlayer 89 			// int returns owner's of weapon

#define m_knifeItem 272			// ptr ножа 
#define m_pistolItem 273        //  ptr secondary pistol в инвентаре
#define m_rifleItem 274         // ptr primary в инвентаре
#define m_nadeItem 276          // ptr гранаты

#define m_flStartThrow 117      // if == 1.0   attack pressed сила замаха, от 0.0до 1.0 
#define m_flReleaseThrow 118 
#define m_flTimeToExplode 119 // explossion in gametime format of weapon_nade_ex (when acitive nade picket up after throw)


#define m_pActiveItem 278 		// возвращает Entity idx оружия в руках (не константу) + linux_diff_player
#define m_rgpPlayerItems 81		// Weaponbox ячейки
#define m_fInReload	111         //  Integer 
#define m_iWeaponState 115		// IS BAZOOKA/PIAT/temp_p_submodelCHREK Shouldered


#define m_Player_rgpPlayerItems 272

/// CLASSES
// US Allies
#define DODCL_garand 1
#define DODCL_m1carb 2
#define DODCL_thomp 3
#define DODCL_greesg 4
#define DODCL_springf 5
#define DODCL_bar 6
#define DODCL_30cal 7
#define DODCL_bazooka 8
// Axis 
#define DODCL_k98 10
#define DODCL_k43 11
#define DODCL_mp40 12
#define DODCL_stg44 13
#define DODCL_k98s 14
#define DODCL_fg42 15
#define DODCL_fg42s 16
#define DODCL_mg34 17
#define DODCL_mg42 18
#define DODCL_panzerschreck 19
// brit 
#define DODCL_enfield 21
#define DODCL_sten 22
#define DODCL_scenfield 23
#define DODCL_bren 24
#define DODCL_piat 25

public plugin_init()
{   
    register_plugin("DOD class inventory", "0.0", "America");


}

// Weapon entity Names
new const DODW_NAMES[][] = 
{
    "", // Индекс 0 (не используется)
    "weapon_amerknife",  // Индекс 1
    "weapon_gerknife",   // Индекс 2
    "weapon_colt",       // Индекс 3
    "weapon_luger",      // Индекс 4
    "weapon_garand",     // Индекс 5
    "weapon_scopedkar",  // Индекс 6
    "weapon_thompson",   // Индекс 7
    "weapon_mp44",       // Индекс 8
    "weapon_spring",     // Индекс 9
    "weapon_kar",        // Индекс 10
    "weapon_bar",        // Индекс 11
    "weapon_mp40",       // Индекс 12
    "weapon_stickgrenade",
    "weapon_stickgrenade_ex",
    "weapon_mg42",       // Индекс 13
    "weapon_30cal",      // Индекс 14
    "weapon_spade",      // Индекс 15
    "weapon_m1carbine",  // Индекс 16
    "weapon_mg34",       // Индекс 17
    "weapon_greasegun",  // Индекс 18
    "weapon_fg42",       // Индекс 19
    "weapon_k43",        // Индекс 20
    "weapon_enfield",    // Индекс 21
    "weapon_sten",       // Индекс 22
    "weapon_bren",       // Индекс 23
    "weapon_webley"      // Индекс 24
};



public dod_client_spawn(idx_player)
{   

    // slot 0  == knife , 1 == pistol , 2 == rifle, 4 == nade
    switch(dod_get_user_class(idx_player))
    {
        case DODCL_garand:
        {
            set_clip_set_ammo(idx_player, 2, 1, 0);
        }
        default:
        {
            // give_weapon_to_slot(idx_player, 20, 3, 3, 1, 0);
        }
    }

}


public set_clip_set_ammo(idx_player, slot, clip, ammo)
{
    // set_clip
    new ptr_idx_weapon = get_weapon_ptr_from_slot(idx_player, slot);
    if(!ptr_idx_weapon) return;

    set_pdata_int(ptr_idx_weapon, m_iClip,  clip, linux_diff_weapon);
    // set_ammo 
    new ammotype = get_ammotype_from_ptr_weapon(ptr_idx_weapon  );
    set_pdata_int(idx_player, m_rgAmmo + ammotype, ammo, linux_diff_player);
}


///////////


public set_any_weapon_from_slot_to_slot(idx_player, from_slot, to_slot, bucket)
{   
    /*
    // 1. Проверка валидности слотов
    if (from_slot < 0 || from_slot >= enum_DODW_SLOTS) 
    {
        server_print("Invalid from_slot: %d", from_slot);
        return;
    }
    if (to_slot < 0 || to_slot >= enum_DODW_SLOTS) 
    {
        server_print("Invalid to_slot: %d", to_slot);
        return;
    }
    */
    // 2. Получаем указатель на оружие в исходном слоте
    new weapon_ptr = get_weapon_ptr_from_slot(idx_player, from_slot);
    if (weapon_ptr == -1 || !pev_valid(weapon_ptr)) 
    {
        server_print("No valid weapon in from_slot: %d", from_slot);
        return;
    }
  
    // 3. Получаем DODW ID оружия
    new dodw_id = get_dodw_id_from_ptr_idx_weapon(weapon_ptr);

    
    new wname[32];
    get_weapon_name_from_slot(idx_player, from_slot, wname);
    server_print("ИСХОДНЫЙ DODW: %d %s", dodw_id , wname);
    // 4. Получаем данные оружия из массива
    new clip = get_weapon_m_iClip_from_ptr(weapon_ptr);
    new ammo_type = get_ammotype_from_ptr_weapon(weapon_ptr);
    new max_ammo = 60;
    new flags = 128;
    server_print("clip %d max_ammo: %d ammo_type %d flags %d", clip , max_ammo, ammo_type, flags);
    // 5. Проверяем, что целевой слот свободен
    new target_weapon_ptr = get_weapon_ptr_from_slot(idx_player, to_slot);
    if (target_weapon_ptr != -1 && pev_valid(target_weapon_ptr)) 
    {
        server_print("Target slot %d is not empty", to_slot);
        // bucket = 1
        // return;
    }

    // 6. Удаляем оружие из старого слота
    // set_pdata_cbase(idx_player, m_Player_rgpPlayerItems + from_slot, -1, linux_diff_player);

    // 7. Устанавливаем оружие в новый слот
    // set_pdata_cbase(idx_player, m_Player_rgpPlayerItems + to_slot, weapon_ptr, linux_diff_player);

    // 8. Обновляем HUD игрока
    message_begin(MSG_ONE, g_msgWeaponList , {0, 0, 0}, idx_player);
    write_byte(get_ammo_type_by_dodw_id(dodw_id));    // Ammo1 Type
    write_byte(max_ammo);     // Ammo1 Max
    write_byte(-1);           // Ammo2 Type (не используется)
    write_byte(-1);           // Ammo2 Max (не используется)
    write_byte(to_slot);      // Новый слот
    write_byte(0);       // Позиция в слоте
    write_short(dodw_id);     // Weapon ID
    write_byte(128);        // Флаги
    write_byte(clip);            // Position (приоритет отображения)
    message_end();

    // 9. Обновляем активное оружие, если перемещенное оружие было активным
    new active_weapon_ptr = get_pdata_cbase(idx_player, m_pActiveItem, linux_diff_player);
    if (active_weapon_ptr == weapon_ptr) 
    {
        // Если перемещенное оружие было активным, обновляем активный слот
        //set_pdata_cbase(idx_player, m_pActiveItem, weapon_ptr, linux_diff_player);
    }

    server_print("Weapon moved from slot %d to slot %d", from_slot, to_slot);
}


// придёться сначала выдать оружие именно таким образом, тогда получится переместить оружие.
// Stock written by XxAvalanchexX
// gives a player a weapon efficiently
stock ham_give_weapon(idx_player, const weapon[]) 
{
	new ptr_idx_weapon = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, weapon));
	if(!pev_valid(ptr_idx_weapon)) return 0;
	    
	set_pev(ptr_idx_weapon, pev_spawnflags, SF_NORESPAWN);
	dllfunc(DLLFunc_Spawn, ptr_idx_weapon);
	    
	if(!ExecuteHamB(Ham_AddPlayerItem, idx_player, any:ptr_idx_weapon) || !ExecuteHamB(Ham_Item_AttachToPlayer, ptr_idx_weapon, any:idx_player))
	{
		if(pev_valid(ptr_idx_weapon)) set_pev(ptr_idx_weapon, pev_flags, pev(ptr_idx_weapon, pev_flags) & FL_KILLME);
		return 0;
	}
	  
	return ptr_idx_weapon;
}

public give_weapon_to_slot(idx_player, dodw_id, clip, ammo, to_slot, bucket)
{
    if (bucket == 0)
    {   // if bucket == 0 make slot free
        new szWeaponName[32];
        get_weapon_name_from_slot(idx_player, to_slot, szWeaponName);
        engclient_cmd(idx_player, "drop", szWeaponName);

        // new drop_ptr = get_weapon_ptr_from_slot( idx_player, to_slot);
        //ExecuteHamB( Ham_Item_Drop , drop_ptr); // Роняет server
        // remove_entity(drop_ptr); // Роняет  server
    }
    new weapon_name[32];
    get_weapon_name_from_dodw_id( dodw_id, weapon_name);

    // set_clip
    new ptr_idx_weapon = ham_give_weapon(idx_player, weapon_name);
    if(!ptr_idx_weapon) return;
    set_pdata_int(ptr_idx_weapon, m_iClip,  clip, linux_diff_weapon);
    // set_ammo 
    new ammotype = get_ammotype_from_ptr_weapon( ptr_idx_weapon);
    new old_ammo = get_pdata_int(idx_player, m_rgAmmo + ammotype, linux_diff_player); //
    if(old_ammo)    ammo += old_ammo;
    set_pdata_int(idx_player, m_rgAmmo + ammotype, ammo, linux_diff_player);


    message_begin(MSG_ONE, g_msgWeaponList , {0, 0, 0}, idx_player);
    write_byte(get_ammo_type_by_dodw_id(dodw_id));    // Ammo1 Type
    write_byte(ammo);     // Ammo1 Max
    write_byte(-1);           // Ammo2 Type (не используется)
    write_byte(-1);           // Ammo2 Max (не используется)
    write_byte(to_slot);      // Новый слот
    write_byte(bucket);       // Позиция в слоте
    write_short(dodw_id);     // Weapon ID
    write_byte(128);        // Флаги
    write_byte(clip);            // Position (приоритет отображения)
    message_end();


    // доделать массив МАКС Аммо. что бы не вводить в заблужение  
    // перепроверить конвертер DODW_TO WEAPON_NAME
    // Перепроверить если у игрока есть текущее оружие в слоте ? лишить ? 
}


public ham_strip_weapon_2(idx_player)
{   
    // удалить оружие из инвентаря
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


public get_weapon_m_iClip_from_ptr(prt_idx_weapon)
{
    return get_pdata_int(prt_idx_weapon, m_iClip, linux_diff_weapon);
}
public get_ammotype_from_ptr_weapon(prt_idx_weapon)
{
    return get_pdata_int(prt_idx_weapon, m_iPrimaryAmmoType, linux_diff_weapon);
}

public get_weapon_ptr_from_slot(idx_player, slot)
{
    if (slot < 0 || slot > 6) return -1; // Слоты от 0 до 6
    return get_pdata_cbase(idx_player, m_Player_rgpPlayerItems + slot, linux_diff_player);
}

public get_weapon_dodw_id_from_slot(idx_player, slot)
{   
    return get_dodw_id_from_ptr_idx_weapon(get_weapon_ptr_from_slot(idx_player, slot));
}

public get_weapon_name_from_slot(idx_player, slot, weapon_name[])
{   
    new ptr_weapon = get_weapon_ptr_from_slot(idx_player, slot);
    if (ptr_weapon == -1 || !pev_valid(ptr_weapon))
    {
        weapon_name[0] = '^0'; // Очищаем строку, если оружие не найдено
        return weapon_name;
    }
    entity_get_string(ptr_weapon, EV_SZ_classname, weapon_name, 31);
    return weapon_name;
}

//////// 
public get_slot_of_weapon_ptr(idx_player, ptr_weapon)
{
    for (new i = 0; i < 7; i++)
    {
        new idx_wpn = get_pdata_cbase(idx_player, m_Player_rgpPlayerItems + i, linux_diff_player);
        if (idx_wpn == ptr_weapon)
        {
            return i;
        }
    }
    return -1;
}

public get_slot_of_weapon_name(idx_player, weapon_name[32])
{
    for (new i = 0; i < 7; i++)
    {
        new current_weapon_name[32];
        copy(current_weapon_name, 31, get_weapon_name_from_slot(idx_player, i, current_weapon_name));

        if (equal(weapon_name, current_weapon_name))
        {
            return i;
        }
    }
    return -1;
}


public get_slot_of_weapon_dowd_id(idx_player, dodw_id)
{
    // Проверяем, что dodw_id находится в допустимом диапазоне
    if (dodw_id < 1 || dodw_id >= sizeof(DODW_NAMES)) 
    {
        server_print("Invalid DODW ID: %d", dodw_id);
        return -1;
    }

    // Получаем имя оружия по dodw_id
    new weapon_name[32];
    copy(weapon_name, 31, DODW_NAMES[dodw_id]);
    server_print("Weapon name for DODW ID %d: %s", dodw_id, weapon_name);

    // Ищем слот, в котором находится это оружие
    new slot = get_slot_of_weapon_name(idx_player, weapon_name);
    server_print("Slot for weapon %s: %d", weapon_name, slot);

    return slot;
}

public get_ammo_type_by_dodw_id(dodw_id)
{
    //-- Where is MG34? можно найти
    switch (dodw_id)
    {
        case DODW_THOMPSON, DODW_MP40, DODW_GREASEGUN, DODW_STEN:                       return AMMO_SMG;
        case DODW_M1_CARBINE, DODW_K43:                                                 return AMMO_ALTRIFLE;
        case DODW_GARAND, DODW_ENFIELD, DODW_SCOPED_ENFIELD, DODW_KAR, DODW_SCOPED_KAR: return AMMO_RIFLE;
        case DODW_COLT  , DODW_LUGER, DODW_WEBLEY:                                      return AMMO_PISTOL;
        case DODW_SPRINGFIELD:                                                          return AMMO_SPRING;
        case DODW_BAR, DODW_BREN, DODW_STG44, DODW_FG42, DODW_SCOPED_FG42:              return AMMO_HEAVY;
        case DODW_MG42:                                                                 return AMMO_MG42;
        case DODW_30_CAL:                                                               return AMMO_30CAL;
        case DODW_HANDGRENADE, DODW_STICKGRENADE, DODW_STICKGRENADE_EX, DODW_HANDGRENADE_EX:return AMMO_GREN;
        case DODW_BAZOOKA, DODW_PIAT, DODW_PANZERSCHRECK:                               return AMMO_ROCKET;
        default: return -1;
    }
    return -1;
}



public get_dodw_id_from_ptr_idx_weapon(ptr_idx_weapon)
{   
    if(ptr_idx_weapon == -1 || !pev_valid(ptr_idx_weapon)) return -1;
    return get_pdata_int(ptr_idx_weapon, m_iId, linux_diff_weapon);
}


public get_weapon_name_from_dodw_id(dodw_id, weapon_name[])
{
    switch (dodw_id)
    {
        case DODW_AMERKNIFE: copy(weapon_name, 31, "weapon_amerknife");
        case DODW_GERKNIFE: copy(weapon_name, 31, "weapon_gerknife");
        case DODW_COLT: copy(weapon_name, 31, "weapon_colt");
        case DODW_LUGER: copy(weapon_name, 31, "weapon_luger");
        case DODW_GARAND: copy(weapon_name, 31, "weapon_garand");
        case DODW_SCOPED_KAR: copy(weapon_name, 31, "weapon_scoped_kar");
        case DODW_THOMPSON: copy(weapon_name, 31, "weapon_thompson");
        case DODW_STG44: copy(weapon_name, 31, "weapon_stg44");
        case DODW_SPRINGFIELD: copy(weapon_name, 31, "weapon_springfield");
        case DODW_KAR: copy(weapon_name, 31, "weapon_kar");
        case DODW_BAR: copy(weapon_name, 31, "weapon_bar");
        case DODW_MP40: copy(weapon_name, 31, "weapon_mp40");
        case DODW_HANDGRENADE: copy(weapon_name, 31, "weapon_handgrenade");
        case DODW_STICKGRENADE: copy(weapon_name, 31, "weapon_stickgrenade");
        case DODW_STICKGRENADE_EX: copy(weapon_name, 31, "weapon_stickgrenade_ex");
        case DODW_HANDGRENADE_EX: copy(weapon_name, 31, "weapon_handgrenade_ex");
        case DODW_MG42: copy(weapon_name, 31, "weapon_mg42");
        case DODW_30_CAL: copy(weapon_name, 31, "weapon_30_cal");
        case DODW_SPADE: copy(weapon_name, 31, "weapon_spade");
        case DODW_M1_CARBINE: copy(weapon_name, 31, "weapon_m1_carbine");
        case DODW_MG34: copy(weapon_name, 31, "weapon_mg34");
        case DODW_GREASEGUN: copy(weapon_name, 31, "weapon_greasegun");
        case DODW_FG42: copy(weapon_name, 31, "weapon_fg42");
        case DODW_K43: copy(weapon_name, 31, "weapon_k43");
        case DODW_ENFIELD: copy(weapon_name, 31, "weapon_enfield");
        case DODW_STEN: copy(weapon_name, 31, "weapon_sten");
        case DODW_BREN: copy(weapon_name, 31, "weapon_bren");
        case DODW_WEBLEY: copy(weapon_name, 31, "weapon_webley");
        case DODW_BAZOOKA: copy(weapon_name, 31, "weapon_bazooka");
        case DODW_PANZERSCHRECK: copy(weapon_name, 31, "weapon_panzerschreck");
        case DODW_PIAT: copy(weapon_name, 31, "weapon_piat");
        case DODW_SCOPED_FG42: copy(weapon_name, 31, "weapon_scoped_fg42");
        case DODW_FOLDING_CARBINE: copy(weapon_name, 31, "weapon_folding_carbine");
        case DODW_KAR_BAYONET: copy(weapon_name, 31, "weapon_kar_bayonet");
        case DODW_SCOPED_ENFIELD: copy(weapon_name, 31, "weapon_scoped_enfield");
        case DODW_MILLS_BOMB: copy(weapon_name, 31, "weapon_mills_bomb");
        case DODW_BRITKNIFE: copy(weapon_name, 31, "weapon_britknife");
        case DODW_GARAND_BUTT: copy(weapon_name, 31, "weapon_garand_butt");
        case DODW_ENFIELD_BAYONET: copy(weapon_name, 31, "weapon_enfield_bayonet");
        case DODW_MORTAR: copy(weapon_name, 31, "weapon_mortar");
        case DODW_K43_BUTT: copy(weapon_name, 31, "weapon_k43_butt");
        default: copy(weapon_name, 31, "unknown_weapon");
    }
}
