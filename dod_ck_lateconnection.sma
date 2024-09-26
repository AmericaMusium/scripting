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
#define m_weapon_clip 108
#define m_knifeItem 272			// prt ножа 
#define m_pistolItem 273        //  ptr пистолета в инвентаре
#define m_rifleItem 274         //  ptr основы в инвентаре
#define weaponbox_slot_knife 82
#define weaponbox_slot_pistol 83
#define weaponbox_slot_primary 84


// global vars
new bool:b_is_player_pistol_only[33] = false

public plugin_init()
{
    register_plugin("DOD mo40 sten by SteamID","0.0","America")
    RegisterHam(Ham_Spawn, "player", "Ham_Spawn_P", 1)
    register_event("CurWeapon","CurWeapon_P","be", "1=1");

    for(new id = 1 ; id < get_maxplayers()+1 ; id++)
    {
        b_is_player_pistol_only[id] = false
    }
}

public client_authorized(idx_player)
{   
    if (is_user_bot(idx_player)) 
        return PLUGIN_CONTINUE;

    new Float: gametime = get_gametime()
    if(gametime > 300.0)
    {
        b_is_player_pistol_only[idx_player] = true
    }
    return PLUGIN_CONTINUE;
    
}


public client_disconnected(idx_player)
{
    b_is_player_pistol_only[idx_player] = false
}



public Ham_Spawn_P(idx_player)
{
    if(b_is_player_pistol_only[idx_player] && is_user_alive(idx_player))
    {   
       
        new team = pev(idx_player, pev_team)
        switch (team){
            case 1: give_weapon_to_player_classical(idx_player,"weapon_colt")
            case 2: give_weapon_to_player_classical(idx_player,"weapon_luger")
            default: return HAM_IGNORED
        }
        
        return HAM_IGNORED
    }
    return HAM_IGNORED
}



public CurWeapon_P(idx_player)
{   
    if(b_is_player_pistol_only[idx_player] && is_user_alive(idx_player))
    {   

        //new arg1 = read_data(1)
        new idx_DODW = read_data(2)
        //new clip = read_data(3)

        if(idx_DODW == DODW_LUGER || idx_DODW==DODW_COLT || idx_DODW==DODW_WEBLEY || idx_DODW==DODW_AMERKNIFE || idx_DODW==DODW_GERKNIFE || idx_DODW==DODW_BRITKNIFE)
        {  
            set_pdata_int(get_pdata_cbase(idx_player, m_pistolItem) ,m_weapon_clip, 7); // set their ammo
            return PLUGIN_CONTINUE
        }
        else 
        {
            new temp_cur_weapon_ent_id = get_pdata_cbase(idx_player, m_rifleItem); // to drop pistol use m_pistolItem
            if (temp_cur_weapon_ent_id != -1)
            {
                new temp_class_name[32];
                entity_get_string(temp_cur_weapon_ent_id, EV_SZ_classname, temp_class_name, 31);
                // client_print(idx_player, print_chat, "WEAPON LIST %s " , temp_class_name)
                engclient_cmd(idx_player, "drop", temp_class_name);
            }
        }
    }
    return 0
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
