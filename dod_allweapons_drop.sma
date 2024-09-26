
#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>
#include <engine>

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

/// need fix models


new const weapon_classnames[31][] = {"weapon_amerknife","weapon_gerknife","weapon_colt","weapon_luger",
"weapon_garand","weapon_scopedkar","weapon_thompson","weapon_mp44","weapon_spring","weapon_kar","weapon_bar",
"weapon_mp40","weapon_mg42","weapon_30cal","weapon_spade","weapon_m1carbine","weapon_mg34","weapon_greasegun",
"weapon_fg42","weapon_k43","weapon_enfield","weapon_sten","weapon_bren","weapon_webley","weapon_bazooka","weapon_pschreck",
"weapon_piat","weapon_fg42","weapon_enfield", "weapon_stickgrenade" , "weapon_handgrenade"}





public plugin_init()
{
	register_plugin("Can Drop All weapons", "0.1", "America")

	for(new i = 0; i < 31; i++)
		{
		RegisterHam(Ham_DOD_Item_CanDrop, weapon_classnames[i],"func_WeaponDrop")
		}
	

}


//////////// ACCEPT DROP (List of DODW to accept is in public plugin_init)
public func_WeaponDrop(id)
{
	if(is_valid_ent(id))
	{
		
		SetHamReturnInteger(1)
		return HAM_SUPERCEDE
	}
	return HAM_IGNORED
}