#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fun>
#include <hamsandwich>
#include <fakemeta>
#include <dodx>
#include <dodfun>

new idx_cweapon
new DODCW_ID
new g_idx_player
#define CWEAPON_NAME "weapon_tpist"


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

// Dod CbaseWeapon offsets 
#define m_flNextPrimaryAttack 103 	// float
#define m_flNextSecondaryAttack 104 // float
#define m_flTimeWeaponIdle 105 	// float	
#define m_flNextAttack 211 // float
#define m_fInReload	111         //  Integer 
#define m_fInAttack 113
#define m_bUnderhand 120 // bool
#define m_flWaitFinished 149 // 5

#define m_iWeaponState 115		// IS BAZOOKA/PIAT/PSCHREK Shouldered

public plugin_init()
{
    register_plugin("DOD ADD CW" , "0.0" , "America")
    register_clcmd("say /cw", "cw_run") 
}

public plugin_precache()
{
   
    precache_model("models/mapmodels/hk_satchel.mdl");
}
public cw_run(idx_player)
{   
    g_idx_player = idx_player
    
    strip_user_weapons(idx_player);

    /* тоже не много работает)) 
    create_custom_weapon();
    return 0;

    */
    //Add Custom Weapon Suppo   rt
	DODCW_ID = custom_weapon_add("Custom LogNameW", 0 , CWEAPON_NAME)
    if (DODCW_ID < 0)
    {
        server_print("*** Ошибка создания кастомного оружия")
        return PLUGIN_HANDLED
    }
    server_print("*** new custom weapond created: %d", DODCW_ID)

    // give_item(idx_player, CWEAPON_NAME)  хуйня пока не сработала 
    Ham_Weapon_Give_stocko(idx_player)
    
}

public Ham_Weapon_Give_stocko(idx_player)
{
    // if(!equal(weapon,g_classnames[weapon_],7)) return 0;

    new idx_wpn = engfunc(EngFunc_CreateNamedEntity,engfunc(EngFunc_AllocString, "shell_pschreck"));
    if(!pev_valid(idx_wpn)) return 0;
    server_print("*** engfunc(EngFunc_CreateNamedEntity,engfunc(EngFunc_AllocString,");
    // engfunc(EngFunc_SetModel, idx_wpn, "models/mapmodels/hk_satchel.mdl")
    // entity_set_string(idx_wpn, EV_SZ_classname, "weapon_luger");
    set_pev(idx_wpn, pev_spawnflags, SF_NORESPAWN);
    dllfunc(DLLFunc_Spawn, idx_wpn);

    set_pdata_int(idx_wpn, m_iClip, 4);
    set_pdata_int(idx_wpn, m_iDefaultAmmo, 4);
    
    entity_set_int(idx_wpn, EV_INT_iuser4, 44);

    if(!ExecuteHamB(Ham_AddPlayerItem,idx_player,any:idx_wpn) || !ExecuteHamB(Ham_Item_AttachToPlayer, idx_wpn,any:idx_player))
    {
        if(pev_valid(idx_wpn)) set_pev(idx_wpn,pev_flags,pev(idx_wpn,pev_flags) & FL_KILLME);
        return 0;
    }
    server_print("*** Ham_Weapon_Give_stocko: %d", idx_wpn)
    return 1;

}

public create_prim_weapon_old(idx_player)
{
    // Create new primary weapon entity
    idx_cweapon = engfunc(EngFunc_CreateNamedEntity,engfunc(EngFunc_AllocString, CWEAPON_NAME))
    if (idx_cweapon < 0)
    {
        server_print("*** 2 Ошибка создания кастомного оружия")
        return PLUGIN_HANDLED
    }
    server_print("*** 2 new custom weapond created: %d", idx_cweapon)

    if(pev_valid(idx_cweapon))
        {
            server_print("*** 3 new custom weapond created: %d", idx_cweapon)

            // Set entity position
            new Float: origin[3]
            pev(idx_player, pev_origin, origin)
            engfunc(EngFunc_SetOrigin, idx_cweapon , origin)

            set_pev(idx_cweapon, pev_spawnflags, SF_NORESPAWN)
            // Spawn the entity
            dllfunc(DLLFunc_Spawn,idx_cweapon)

            entity_set_int(idx_cweapon, EV_INT_spawnflags, SF_NORESPAWN);
            ExecuteHam(Ham_Spawn, idx_cweapon);
            ExecuteHamB(Ham_Item_AttachToPlayer, idx_player, idx_cweapon);


            set_pev(idx_player, pev_viewmodel2 , "models/v_bar.mdl")
            // Установка количества патронов
            set_pdata_int(idx_cweapon, 51, 10); // 51 - m_iClip, 10 - количество патронов

            // Выдача оружия игроку
            engclient_cmd(idx_player, "use", CWEAPON_NAME);



            RegisterHam(Ham_Weapon_PrimaryAttack,	CWEAPON_NAME,	"CWEAPON_NAME_attack_P", true);
            RegisterHam(Ham_Item_PostFrame, CWEAPON_NAME, "CWEAPON_NAME_attack_P");

        }
}

public CWEAPON_NAME_attack_P()
{
    server_print("*** 4 attack registered")

}



public create_custom_weapon()
{   

    DODCW_ID = custom_weapon_add("weapon_tt33", 0 , "weapon_tt33")
    new ent = create_entity("ammo_m1carbine")
    server_print("*** 4 Disp %d", ent)
    if (ent > 0) {
        // Базовые свойства CBaseEntity
        set_pev(ent, pev_classname, "weapon_tt33");
        set_pev(ent, pev_movetype, MOVETYPE_NONE);
        set_pev(ent, pev_solid, SOLID_TRIGGER);
        
        // Свойства CBaseAnimating
        set_pev(ent, pev_framerate, 1.0);
        set_pev(ent, pev_sequence, 0);
        
        // Свойства CBasePlayerItem
        // set_pev(ent, pev_impulse, WEAPON_SLOT)
        set_pev(ent, pev_weaponmodel, "models/v_luger.mdl");
        
        // Свойства CBasePlayerWeapon
        set_pdata_int(ent, m_iClip, 4);
        set_pdata_int(ent, m_iDefaultAmmo, 4);
        set_pdata_float(ent, m_flNextPrimaryAttack, 0.0);
        set_pdata_float(ent, m_flNextSecondaryAttack, 0.0);
        set_pdata_float(ent, m_flTimeWeaponIdle, 0.0);
        
        // Дополнительные свойства для DoD
        set_pdata_int(ent, m_iWeaponState, 0);
        set_pdata_int(ent, m_fInReload, 0);
        
        // Спавним entity
        DispatchSpawn(ent)
        dllfunc(DLLFunc_Spawn,ent)
        server_print("*** 4 DispatchSpawn(ent) registered %d", ent)
        fake_touch(ent, g_idx_player);


        if(!ExecuteHamB(Ham_AddPlayerItem,g_idx_player,any:ent) || !ExecuteHamB(Ham_Item_AttachToPlayer, ent,any:g_idx_player))
        {
            if(pev_valid(ent)) set_pev(ent,pev_flags,pev(ent,pev_flags) & FL_KILLME);
            return 0;
        }
        server_print("*** Ham_Weapon_Give_stocko: %d", ent)
        //RegisterHam(Ham_Item_PostFrame, "weapon_tt33", "CW_Holster_registreed");

    }
    
    return ent
}

public CW_Holster_registreed()
{
    server_print("*** 4 CW_Holster_registreed");
}