#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>
#include <fun>
#include <dodx>
#include <dodfun>
#include <hamsandwich>

public plugin_init()
{
    RegisterHam(Ham_Spawn, "weapon_stickgrenade_ex", "On_Handgrenade_Spawned", 1) // спаунится, только если в руках
}


public On_Handgrenade_Spawned(idx_nade)
{
	server_print(" weapon_handgrenade_ex DETECYED")
}