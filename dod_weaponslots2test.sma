#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <fakemeta_util>
#include <fakemeta_stocks>
#include <dodx>
#include <dodfun>
#include <fun>
#include <engine>
#include <dodws>

#pragma semicolon 1

/* 
Исходя из сорускода Half_Life  weaponbox в первуб очередь выдаёт патрону определённого AMMO_TYPE игроку, что бы было валидно выдать ему оружие 
Соотвествнно текущий CUREENT_AMMO при спауне игрока записывает в випонбокс, и от туда напрямую игроку, ptr_weapon хранит только clip
*/

new g_msgWeaponList;


public plugin_init()
{  
    g_msgWeaponList	= get_user_msgid( "WeaponList" );
    set_task(11.0, "parse_weaponItems");
    set_task(12.0, "test_func");
    set_task(15.0, "parse_weaponItems");
    set_task(27.0, "parse_weaponItems");


    register_clcmd("say 1233", "say_handle");
    
}

public test_func()
{   
    new sexy[32];
    get_weapon_name_from_slot(1, 1, sexy);
    new dodw_id = get_weapon_dodw_id_from_slot(1, 1);
    server_print("get_weapon_ptr_from_slot %d", get_weapon_ptr_from_slot(1, 1));
    server_print("get_weapon_ptr_from_slot %s", sexy);
    server_print("get_weapon_dodw_id_from_slot %d", dodw_id);

    new found_slot = get_slot_of_weapon_ptr(1, get_weapon_ptr_from_slot(1, 2));
    new foundslot2 = get_slot_of_weapon_name(1, "weapon_kar");
    new WIWDIID = get_slot_of_weapon_dowd_id(1 , DODW_KAR);
    server_print("get_slot_of_weapon_ptr %d", found_slot);
    server_print("get_slot_of_weapon_name %d", foundslot2);
    server_print("get_slot_of_weapon_dowd_id %d", WIWDIID);
    
}

public parse_weaponItems()
{
    new idx_wpn;
    new sz_t_Clsname[32];
    // следующее в этом цикле уже АктивWeapons
    for (new i = 0 ; i < 7 ; i++)
    {
        idx_wpn = get_pdata_cbase(1, m_Player_rgpPlayerItems + i, linux_diff_player);
        
        if(pev_valid(idx_wpn))
        {
            entity_get_string(idx_wpn, EV_SZ_classname, sz_t_Clsname, charsmax(sz_t_Clsname));
            server_print("Slot: %d |Weapon: %s |ptr: %d |AmmoType: %d |Clip: %d", i, sz_t_Clsname, idx_wpn, get_ammotype_from_ptr_weapon(idx_wpn), get_weapon_m_iClip_from_ptr(idx_wpn));

            if( get_ammotype_from_ptr_weapon(idx_wpn) == 3) cbase_safe_parser( idx_wpn, 0, 512, 60);

        }
        else 
        {
            server_print("i %d : Weapon : %d", i , idx_wpn);
        }
        
    }
    
}


public cbase_safe_parser(ptr_idx_item, start_offset, finish_offset, what_parsing)
{   

    server_print("++cbase_safe_parser");
    for (new s = start_offset ; s <= finish_offset; s++)
    {
        new value = get_pdata_cbase_safe(ptr_idx_item, s, 4);
        if(pev_valid(value))
        {
            new int_value =  get_pdata_int(value, 0);
            if (int_value == 60)
            {   
                server_print("+++++ offset %d :: value %d %f %s", s , value, value, value);
            }
        }
    }
}

public say_handle(idx_player)
{   

    give_weapon_to_slot( idx_player , DODW_BREN, 7, 11 , 3, 1);
    new idx_weapon = get_pdata_cbase(idx_player, m_pActiveItem, linux_diff_player);
    server_print( "this player has weapon is DODW_ID == %d", get_dodw_id_from_ptr_idx_weapon(idx_weapon));
    server_print( "this weapon has DODW_AMMO_TYPE == %d", get_ammo_type_by_dodw_id( get_dodw_id_from_ptr_idx_weapon(idx_weapon)));
    // set_any_weapon_from_slot_to_slot( idx_player, 2, 3, 0);
    new ent;
    while((ent = find_ent_by_class(ent,"weaponbox")) != 0) 
    {
        if(pev_valid(ent))  parse_weaponbox(ent);    
    }


    
}

public parse_weaponbox(ptr_weaponbox)
{
    server_print( "WEAPON_BOX FOUNDED");
    cmd_GetWeaponBoxContents(ptr_weaponbox);
    return;
    new ptr_idx_weapon;
    for (new i = 0; i < 6; i++)
    {   
        
        ptr_idx_weapon = get_pdata_cbase(ptr_weaponbox, m_rgpPlayerItems + i, linux_diff_weapon); // oofset 4
        if(pev_valid(ptr_idx_weapon))
        {   


            // SLOT + CLASSNAME     
            new temp_class_name[17];
            entity_get_string(ptr_idx_weapon, EV_SZ_classname,temp_class_name, 16);
            server_print( "WEAPONBOX:: slot %d:: ptr %d:: %s", i , ptr_idx_weapon , temp_class_name);

            // AMMO_TYPE CLASSNAME 
            new m_WeaponBox_rgiszAmmo = 88; //sz[32] /// 27 в 13 строке находит хуйню 
            new t_rgiszAmmo;
            new ammo_name[32];
            for (new j = 0; j < 32; j++)
            {
                t_rgiszAmmo = get_pdata_int(ptr_weaponbox, m_WeaponBox_rgiszAmmo + j, linux_diff_weapon); //

                if(t_rgiszAmmo)
                {
                    engfunc(EngFunc_SzFromIndex, t_rgiszAmmo, ammo_name, charsmax(ammo_name));
                    server_print( "WEAPONBOX:: ammoname: %s", ammo_name); 
                    //  WEAPONBOX:: 13 t_rgiszAmmo::  get_pdata_int 269196160 m_WeaponBox_rgiszAmmo == 27
                }

            }

            // AMMO_COUNT
            new m_WeaponBox_rgAmmo = 120; //sz[32]
            new t_rgAmmo;
            for (new l = 0; l < 32; l++)
            {   
                t_rgAmmo = get_pdata_int(ptr_weaponbox, m_WeaponBox_rgAmmo + l, linux_diff_weapon); //
                if(t_rgAmmo)
                {   
                    server_print( "WEAPONBOX:: Ammo:  %d ", t_rgAmmo);
                    // Установить Ammo 
                    // set_pdata_int(ptr_weaponbox, m_WeaponBox_rgAmmo + l, 11, 4); //)
                }
            }


            
            // m_cAmmoTypes брать строго через get_pdata_cbase --- ПИЗДЁЖЬ !! 
            new m_cAmmoTypes_i = get_pdata_cbase(ptr_weaponbox, m_cAmmoTypes, linux_diff_weapon); // Неработает
            new AmmoTypeFromPtr =  get_ammotype_from_ptr_weapon(ptr_idx_weapon); // Работает
            server_print( "WEAPONBOX::  m_cAmmoTypes %d | %d ", m_cAmmoTypes_i, AmmoTypeFromPtr );

            
            new m_bDontTouch = 153;
            new t_m_bDontTouch;
            t_m_bDontTouch = get_pdata_bool( ptr_weaponbox, m_bDontTouch, 4);
            set_pdata_bool(ptr_weaponbox, m_bDontTouch, true);
            set_pdata_int(ptr_weaponbox, m_bDontTouch, 1);
            set_pdata_short(ptr_weaponbox, m_bDontTouch, 1);
            server_print( "WEAPONBOX::  m_bDontTouch %d ", t_m_bDontTouch);
      




        
            /* !!!!!!!!!!!!!!!!!!!
            ЕСЛИ ИЗВЕСТНЕ АММО_TYPE и должен найти  интеджер согласно смещению. АММО хранит Виопнбокс
            */
        }
    }
}

public cmd_GetWeaponBoxContents(weaponbox) 
{
    for (new i = 0; i < 32; i++) 
        {   
            new rg_ammo_temp;
            rg_ammo_temp = get_ent_data(weaponbox, "CWeaponBox", "m_rgAmmo", i);

            server_print(" %d CweaponBox", rg_ammo_temp);
        }
}



//////// 







public get_dodw_id_from_weapon_name(weapon_name[])
{   
    // функиця не завершена, нужно произвести поиск по массиву и найти совпадение
    // return get_pdata_int(ptr_idx_weapon, m_iId, linux_diff_weapon);
    // switch ()
}



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


public delete_weapon_from_slot(idx_player, slot)
{   
    // удалить оружие из инвентаря
	new idx_weapon = get_weapon_ptr_from_slot(idx_player, slot);
	new dodw_id = get_dodw_id_from_ptr_idx_weapon(idx_weapon);

	new activeitem = get_pdata_cbase(idx_player, m_pActiveItem, linux_diff_player);
	new dodw_id_activeweapon = get_dodw_id_from_ptr_idx_weapon(activeitem);
	if(dodw_id_activeweapon == dodw_id) ExecuteHamB(Ham_Weapon_RetireWeapon, idx_weapon);	    
	if(!ExecuteHamB(Ham_RemovePlayerItem, idx_player, any:idx_weapon)) return 0;

	ExecuteHamB(Ham_Item_Kill, idx_weapon);
	set_pev(idx_player, pev_weapons, pev(idx_player, pev_weapons) & ~(1<<dodw_id));
	return 1;
}