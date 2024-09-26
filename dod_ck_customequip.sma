#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>
#include <dodx>
#include <dodfun>
#include <fun>
#include <engine>
#include <fakemeta>

// Linux extra offsets
#define linux_diff_weapon 4
#define linux_diff_player 5

// Dod CbaseWeapon offsets
#define m_knifeItem 272			// prt ножа 
#define m_pistolItem 273        //  ptr пистолета в инвентаре
#define m_rifleItem 274        //  ptr основы в инвентаре
#define weaponbox_slot_knife 82
#define weaponbox_slot_pistol 83
#define weaponbox_slot_primary 84


// file
new bool:is_file_exists = false
new szFilePath[64] //  = "addons/amxmodx/configs/";
new szFile[64] // = "addons/amxmodx/configs/ck_custom_equip.ini"; // Current Configfile for current map
new szFileName[32] = "vip_steam_equipments.ini"
new szDebugString[128] = "STEAM_0:1:168151617 weapon_enfield weapon_sten"
// file vars
new line_text[256], line_len, line_num


// global vars
new bool:b_is_player_vip[33] = false
new idx_player_line[33] = 0
new g_mode

#define CLASSICAL 1
#define ADDITIONAL 2

public plugin_init()
{
    register_plugin("DOD Custom Equipments by SteamID","0.0","America")
    RegisterHam(Ham_Spawn, "player", "Ham_Spawn_P", 1)
    g_mode = CLASSICAL



    upload_config_file()
}

public upload_config_file(){
    get_configsdir(szFilePath, 63)
    trim(szFilePath)
    format(szFile, 63, "%s/%s", szFilePath, szFileName)

    if(!dir_exists(szFilePath)){
        server_print("(!)[CUSTOM EQIPMENTS] Dirrectory not exists = %s", szFilePath);
        mkdir(szFilePath);

        return PLUGIN_CONTINUE;
    }
    else if (dir_exists(szFilePath))
    {
        if (!file_exists(szFile))
        {   
            server_print("(!)[CUSTOM EQIPMENTS] file not exists = %s", szFile);
            write_file(szFile, szDebugString , 0);  
            is_file_exists = false
            return PLUGIN_CONTINUE;
        }

        if (file_exists(szFile))
        {   
            server_print("[CUSTOM EQIPMENTS] file exists = %s", szFile);
            is_file_exists = true
            line_num = 0
            read_file(szFile, line_num, line_text, 255, line_len);
            // server_print("[CUSTOM EQIPMENTS] %s", line_text)
        }
    }
    return PLUGIN_CONTINUE;
}

public client_authorized(idx_player)
{   
    if (is_user_bot(idx_player)) 
        return PLUGIN_CONTINUE;

    if(is_file_exists)
    {
        new current_steam_id[64];
        get_user_authid(idx_player, current_steam_id, charsmax(current_steam_id));

        new file_handle = fopen(szFile, "rt");
        new line[256];
        new line_num2 = 0;

        if(file_handle != INVALID_HANDLE)
        {
            while(fgets(file_handle, line, sizeof(line)) != 0) // было != 1
            {
                line_num2++;

                if(strfind(line, current_steam_id, true) != -1)
                {   
                    
                    b_is_player_vip[idx_player] = true
                    idx_player_line[idx_player] = line_num2
                    server_print("[CUSTOM EQIPMENTS] VIP %s CONNECTED | file line = %d" , current_steam_id,line_num2 )
                    break;
                    
                }
            }

            fclose(file_handle);
            return PLUGIN_CONTINUE;
        }

        return PLUGIN_CONTINUE;
    }
    return PLUGIN_CONTINUE;
}


public client_disconnected(idx_player)
{
    b_is_player_vip[idx_player] = false
    idx_player_line[idx_player] = 0
}



public Ham_Spawn_P(idx_player)
{
    if(b_is_player_vip[idx_player] && is_user_alive(idx_player))
    {
        Menu_open(idx_player)
        return HAM_IGNORED
    }
    return HAM_IGNORED
    
}

// MENU CREATOR 
 public Menu_open( idx_player )
 {


    if(is_file_exists)
    {
    // new file_handle = fopen(szFile, "rt")
    new szText[256]
    new target_line = idx_player_line[idx_player] - 1

    read_file(szFile, target_line, szText, 255, line_len)

    new opened_weapons = count_word_in_textline(szText, "weapon")
    if( opened_weapons < 1)
    return PLUGIN_CONTINUE

    new menu = menu_create( "\rCustom equipment menu", "Menu_Button_pressed" );
    /*
    for(opened_weapons; opened_weapons > 0; opened_weapons--)
    {

    }
    */
    ck_add_menu_with_weaponnames(menu, szText)
    // menu_additem( menu, "Save my previouse choise and stop annoyg me", "", 0)
    menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );
    menu_display( idx_player, menu, 0 );
    }
    return PLUGIN_CONTINUE;
 }

public Menu_Button_pressed(idx_player, menu, item)
{
    new m_Data[64], m_Name[64], i_Access, i_Callback;
    menu_item_getinfo(menu, item, i_Access, m_Data, charsmax(m_Data), m_Name, charsmax(m_Name), i_Callback);

    switch (g_mode)
    {
        case 1:
            give_weapon_to_player_classical(idx_player, m_Name);
        case 2:
            give_weapon_to_player_additional(idx_player, m_Name);
    }
    menu_destroy(menu);
    return PLUGIN_CONTINUE;
}

stock count_word_in_textline(const text[], const word[])
{ 
    // not used in this plugin anymore  
    /// return how many such words are in a line
    new count = 0;  
    new pos_symbol
    new string_length = strlen(text)-1

    for (pos_symbol = 0 ; pos_symbol < string_length ; pos_symbol++)
    {
        pos_symbol = strfind(text, word, true, pos_symbol)
        // server_print("pos_symbol %d count: %d", pos_symbol , count)
        if(pos_symbol < 0)
        {   
            return count
        }
        count++
    }
    return PLUGIN_CONTINUE;
}

stock ck_add_menu_with_weaponnames(target_menu, const text[])
{
    new count = 0;  
    new pos_symbol;
    new string_length = strlen(text);
    

    new start_symb, end_symb;

    for (pos_symbol = 0; pos_symbol < string_length; )
    {
        pos_symbol = strfind(text, "weapon", true, pos_symbol);
        if (pos_symbol < 0)
        {   
            return count;
        }

        // Найдено слово "weapon", начинаем парсить имя оружия
        start_symb = pos_symbol;
        end_symb = start_symb;

        // Находим конец имени оружия (первый пробел после "weapon")
        while (text[end_symb] != ' ' && end_symb < string_length)
        {
            end_symb++;
        }

        // Копируем имя оружия
        new parsed_weapon_name[32];
        new i = 0;
        for (new j = start_symb; j < end_symb && i < sizeof(parsed_weapon_name) - 1; j++, i++)
        {
            parsed_weapon_name[i] = text[j];
        }
    

        server_print("parsed wname: %s", parsed_weapon_name);
         // parsed_weapon_name
        menu_additem( target_menu, parsed_weapon_name, "", 0)

        count++;
        pos_symbol = end_symb; // Продолжаем поиск с конца найденного имени оружия
    }

   
    return count;
}

//////////////////////
/// GIVE WEAPON  /////
//////////////////////

public give_weapon_to_player_classical(idx_player, const wname[])
{
    if (is_user_connected(idx_player) && is_user_alive(idx_player))
    {
        new temp_cur_weapon_ent_id = get_pdata_cbase(idx_player, m_rifleItem); // to drop pistol use m_pistolItem
        if (temp_cur_weapon_ent_id != -1)
        {
            new temp_class_name[32];
            entity_get_string(temp_cur_weapon_ent_id, EV_SZ_classname, temp_class_name, 31);
            
            set_pev(idx_player, pev_iuser3, 0); // 0 NOT PRONED
            // set_pev(idx_player, pev_vuser1, {0.0, 0.0, 0.0}); // 2.0 = Stay and deploy mg42, mg34
            
            engclient_cmd(idx_player, "drop", temp_class_name);
        }

        give_item(idx_player, wname);
    }
}

public give_weapon_to_player_additional(idx_player, const wname[])
{
    if(is_user_connected(idx_player) && is_user_alive(idx_player))
	{   
        give_item(idx_player, wname);
    }
}

// надо сделать возможность сохранения и универсальность меню 