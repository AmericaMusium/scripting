#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <fakemeta_util>
#include <hamsandwich>


#define PLUGIN  "Addons: func_door_rotating Fix"
#define VERSION "1.0"
#define AUTHOR  "Celena Luna"

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	RegisterHam(Ham_ObjectCaps, "player", "fw_Player_ObjectCaps")
}

public fw_Player_ObjectCaps(id)
{
	new iArg[2]

	if(get_pdata_int(id, m_afButtonPressed, 5) & IN_USE)
	{
		new a = FM_NULLENT

		new Float:fOrigin[3]; pev(id, pev_origin, fOrigin)

		while((a = find_ent_in_sphere(a, fOrigin, 50.0)) != 0)
		{	
			if(fm_is_ent_classname(a, "func_door_rotating"))
			{
				iArg[0] = id
				iArg[1] = a
				set_task(0.1, "Check_Door", 0, iArg, sizeof(iArg))
			}
		}	
	}		
}

public Check_Door(iArg[], taskid)
{
	new ent, id;
	id = iArg[0]
	ent = iArg[1]

	if(!fm_is_ent_classname(ent, "func_door_rotating"))
		return

	new DoorState = ExecuteHam(Ham_GetToggleState, ent)

	
	if(DoorState != TS_GOING_UP || DoorState != TS_GOING_DOWN)
	{
		if(DoorState == TS_AT_TOP || DoorState ==TS_AT_BOTTOM) 
			ExecuteHamB(Ham_Use, ent, id, 1,2,1.0)
		
	}
}
