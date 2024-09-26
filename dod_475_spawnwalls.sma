#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>
#include <fakemeta_util>
#include <fun>
#include <dodx>
#include <dodfun>
#include <dodconst>
#include <dodstats>
#include <hamsandwich>
#include <xs>

new Float:position[3], Float:mins[3] , Float:maxs[3]

public plugin_init()
{
	register_plugin("DOD SPAWNWALLS","0.0","America")



	new mapname[32]
	get_mapname(mapname, charsmax(mapname))

	if(!equal(mapname, "dod_caen"))
	{	
		pause("ad")
	}
	if(equal(mapname, "dod_caen"))
	{
	create_axis_zone()
	create_allies_zone()
	register_touch("axis_base_wall", "player", "axis_base_wall_kill")
	register_touch("allies_base_wall", "player", "allies_base_wall_kill")
	}
}
/*
axis 2709.3 2989.1 147.1 -82 -532 -132 82 532 132
allies -989.4 -2620.6 136.0 -32 -432 -132 32 432 132
*/ 
public create_axis_zone() 
{
	new entity = fm_create_entity("info_target")
	set_pev(entity, pev_classname, "axis_base_wall")
	position[0] = 2700.0
	position[1] = 3000.0
	position[2] = 150.0
	mins[0] = -82.0
	mins[1] = -532.0
	mins[2] = -132.0
	maxs[0] = 82.0
	maxs[1] = 532.0
	maxs[2] = 132.0	
	fm_entity_set_origin(entity, position)
	set_pev(entity, pev_movetype, MOVETYPE_PUSHSTEP)
	set_pev(entity, pev_solid, SOLID_TRIGGER)
	fm_entity_set_size(entity, mins, maxs)
}

public create_allies_zone() 
{
	new entity = fm_create_entity("info_target")
	set_pev(entity, pev_classname, "allies_base_wall")	
	position[0] = -990.0
	position[1] = -2620.0
	position[2] = 136.0
	mins[0] = -32.0
	mins[1] = -432.0
	mins[2] = -132.0
	maxs[0] = 32.0
	maxs[1] = 432.0
	maxs[2] = 132.0	
	fm_entity_set_origin(entity, position)
	set_pev(entity, pev_movetype, MOVETYPE_PUSHSTEP)
	set_pev(entity, pev_solid, SOLID_TRIGGER)
	fm_entity_set_size(entity, mins, maxs)
}


public axis_base_wall_kill(wall,player)
{
	if(is_user_alive(player) && (get_user_team(player)==1))
	{
		user_silentkill(player)
	}
	if(is_user_alive(player) && (get_user_team(player)==0))
	{
		user_silentkill(player)
	}
}


public allies_base_wall_kill(wall,player)
{
	if(is_user_alive(player) && (get_user_team(player)==2))
	{
		user_silentkill(player)
	}
}
