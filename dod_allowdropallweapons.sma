#include <amxmodx>
#include <engine>
#include <hamsandwich>

#include <fakemeta>
#include <hamsandwich>
#include <fakemeta_util>
#include <fakemeta_stocks>
#include <dodx>
#include <dodfun>
#include <fun>

#pragma semicolon 1


/// переопределяем смещения 
// Linux extra offsets
#define linux_diff_weapon 4
#define linux_diff_player 5
#define linux_diff_animation 4
// DOD CBASE offsets 


#define m_iId 91 // CbasePlayerItem
#define m_flNextPrimaryAttack 103 	// float
#define m_flNextSecondaryAttack 104 // float
#define m_flTimeWeaponIdle 105 	// float	
#define m_flNextAttack 211 // float


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


new const weapon_clsnames[][] = 
{
    "weapon_amerknife",
    "weapon_gerknife",
    "weapon_spade",
    "weapon_colt",
    "weapon_luger",
    "weapon_webley",
    "weapon_handgrenade",
    "weapon_stickgrenade"
};

new const weapon_models[][] =
{
    "models/w_amerk.mdl",
    "models/w_paraknife.mdl",
    "models/w_spade.mdl",
    "models/w_colt.mdl",
    "models/w_luger.mdl",
    "models/w_webley.mdl"
};

enum
{
    amerknife_model,
    gerknife_model,
    spade_model,
    colt_model,
    luger_model,
    webley_model
}


public plugin_precache()
{
    for (new i = 0; i < sizeof(weapon_models); i++)
    {
        precache_model(weapon_models[i]);
    }
}

public plugin_init()
{
    register_plugin("DOD Allow Drop All Weapons", "2025", "America");

    for (new i = 0; i < sizeof(weapon_clsnames); i++)
    {
        RegisterHam(Ham_DOD_Item_CanDrop, weapon_clsnames[i], "Weapon_Drop_P" );
    }

    register_forward(FM_SetModel, 				"WeaponBox_Drop_P", false);
    RegisterHam(Ham_Spawn, "weaponbox", "Weaponbox_Spawn_Post", true);
    state WeaponBox_Disabled;
}


public Weapon_Drop_P(id)
{

	if(is_valid_ent(id))
	{
		SetHamReturnInteger(1);
		return HAM_SUPERCEDE;
	}
	return HAM_IGNORED;
}

public WeaponBox_Drop_P(const ptr_weaponbox) <WeaponBox_Enabled>
{   
    state WeaponBox_Disabled;
    if (pev_valid(ptr_weaponbox))
    {
        new clsname[32];
        pev(ptr_weaponbox, pev_classname, clsname, 31);
        if (equal(clsname, "weaponbox"))
        {
            new ptr_idx_weapon;
            for (new i = 0; i < 6; i++)
            {   
                ptr_idx_weapon = get_pdata_cbase(ptr_weaponbox, m_rgpPlayerItems + i, linux_diff_weapon); // oofset 4
                if(pev_valid(ptr_idx_weapon))
                {   

                    switch (get_dodw_id_from_ptr_idx_weapon(ptr_idx_weapon))
                    {
                        case DODW_AMERKNIFE, DODW_BRITKNIFE: engfunc(EngFunc_SetModel, ptr_idx_weapon, weapon_models[amerknife_model]);
                        case DODW_GERKNIFE: engfunc(EngFunc_SetModel, ptr_idx_weapon,   weapon_models[gerknife_model]);
                        case DODW_SPADE: engfunc(EngFunc_SetModel, ptr_idx_weapon,      weapon_models[spade_model]);
                        case DODW_COLT: engfunc(EngFunc_SetModel, ptr_idx_weapon,       weapon_models[colt_model]);
                        case DODW_LUGER: engfunc(EngFunc_SetModel, ptr_idx_weapon,      weapon_models[luger_model]);
                        case DODW_WEBLEY: engfunc(EngFunc_SetModel, ptr_idx_weapon,     weapon_models[webley_model]);
                        default: 
                        {
                            server_print("DEFAULT RUNS INS SFINCTION");
                            return FMRES_IGNORED;
                        }
                    }
                    return FMRES_SUPERCEDE;
                }
            }
        }
        else return FMRES_IGNORED;
        return FMRES_IGNORED;
    }
    else return FMRES_IGNORED;
}

public get_ammotype_from_ptr_weapon(prt_idx_weapon)
{
    return get_pdata_int(prt_idx_weapon, m_iPrimaryAmmoType, linux_diff_weapon);
}

public get_dodw_id_from_ptr_idx_weapon(ptr_idx_weapon)
{   
    if(ptr_idx_weapon == -1 || !pev_valid(ptr_idx_weapon)) return -1;
    return get_pdata_int(ptr_idx_weapon, m_iId, linux_diff_weapon);
}



/// KORD_12.7 » 16 ноя 2013, 12:04
public Weaponbox_Spawn_Post(const iWeaponBox)
{
        if (is_valid_ent(iWeaponBox))
        {
            state (is_valid_ent(pev(iWeaponBox, pev_owner))) WeaponBox_Enabled;
        }
        return HAM_IGNORED;
}

public WeaponBox_Drop_P(const iEntity) <WeaponBox_Disabled>
{
        return FMRES_IGNORED;
} 
