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
new szFileName[32] = "ck_mp40_sten_only.ini"
new szDebugString[128] = "STEAM_0:1:168151617"
// file vars
new line_text[256], line_len, line_num


// global vars
new bool:b_is_player_mp40_sten[33] = false


public plugin_init()
{
    register_plugin("DOD mo40 sten by SteamID","0.0","America")
    RegisterHam(Ham_Spawn, "player", "Ham_Spawn_P", 1)
    register_event("CurWeapon","CurWeapon_P","be", "1=1");
    upload_config_file()
}

public upload_config_file(){
    get_configsdir(szFilePath, 63)
    trim(szFilePath)
    format(szFile, 63, "%s/%s", szFilePath, szFileName)

    if(!dir_exists(szFilePath)){
        // server_print("(!)[MP40 STEN ONLY] Dirrectory not exists = %s", szFilePath);
        mkdir(szFilePath);

        return PLUGIN_CONTINUE;
    }
    else if (dir_exists(szFilePath))
    {
        if (!file_exists(szFile))
        {   
            // server_print("(!)[MP40 STEN ONLY] file not exists = %s", szFile);
            write_file(szFile, szDebugString , 0);  
            is_file_exists = false
            return PLUGIN_CONTINUE;
        }

        if (file_exists(szFile))
        {   
            // server_print("[MP40 STEN ONLY] file exists = %s", szFile);
            is_file_exists = true
            line_num = 0
            read_file(szFile, line_num, line_text, 255, line_len);
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
                    
                    b_is_player_mp40_sten[idx_player] = true
                    // server_print("[MP40 STEN ONLY] VIP %s CONNECTED | file line = %d" , current_steam_id,line_num2 )
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
    b_is_player_mp40_sten[idx_player] = false
}



public Ham_Spawn_P(idx_player)
{
    if(b_is_player_mp40_sten[idx_player] && is_user_alive(idx_player))
    {
        Menu_open(idx_player)
        return HAM_IGNORED
    }
    return HAM_IGNORED
    
}


public CurWeapon_P(idx_player)
{
    
    if(b_is_player_mp40_sten[idx_player] && is_user_alive(idx_player))
    {
        new temp_cur_weapon_ent_id = get_pdata_cbase(idx_player, m_rifleItem); // to drop pistol use m_pistolItem
        if (temp_cur_weapon_ent_id != -1)
        {
            new temp_class_name[32];
            entity_get_string(temp_cur_weapon_ent_id, EV_SZ_classname, temp_class_name, 31);
            if ( equal(temp_class_name, "weapon_sten") || equal(temp_class_name, "weapon_mp40"))
            {   
               return 0
            }
            else 
            {
                // client_print(idx_player, print_chat, "WEAPON LIST %s " , temp_class_name)
                engclient_cmd(idx_player, "drop", temp_class_name);
            }
        }
    }
    return 0
}

// MENU CREATOR 
 public Menu_open( idx_player )
 {

    new menu = menu_create( "\rPrimary weapon menu", "Menu_Button_pressed" );

    menu_additem( menu, "MP 40 ", "", 0)
    menu_additem( menu, "Sten ", "", 0)

    menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );
    menu_display( idx_player, menu, 0 );
    
    return PLUGIN_CONTINUE;
 }

public Menu_Button_pressed(idx_player, menu, item)
{
    new m_Data[64], m_Name[64], i_Access, i_Callback;
    menu_item_getinfo(menu, item, i_Access, m_Data, charsmax(m_Data), m_Name, charsmax(m_Name), i_Callback);

    switch (item)
    {
        case 0:
            give_weapon_to_player_classical(idx_player, "weapon_mp40");
        case 1:
            give_weapon_to_player_classical(idx_player, "weapon_sten");
     }
    menu_destroy(menu);
    return PLUGIN_CONTINUE;
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
