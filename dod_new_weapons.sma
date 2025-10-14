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



public plugin_init()
{
    register_plugin("DODW ADD", "0.0", "America"); 
}