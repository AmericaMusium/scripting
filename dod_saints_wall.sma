#include <amxmodx>
#include <engine>
#include <fakemeta>

#define MODEL "models/mapmodels/null.mdl"

public plugin_precache()
{
	precache_model(MODEL)
}

public plugin_init()
{
	register_plugin("dod_saints fix", "0.7", "Fysiks")
	
	create_wall(Float:{-1112.0, 640.0, -500.0}, Float:{-10.0, -5.0, -25.0}, Float:{5.0, 2.0, 5.0})
}

stock create_wall(Float:fvOrigin[3], Float:mins[3], Float:maxs[3])
{
	// Doesn't seem to work so far.
	new entMyWall = create_entity("func_wall")
	entity_set_string(entMyWall, EV_SZ_classname, "wall")
	entity_set_model(entMyWall, MODEL)
	
	// Set size and absmin+absmax values
	entity_set_vector(entMyWall, EV_VEC_mins, mins)
	entity_set_vector(entMyWall, EV_VEC_absmin, mins)

	entity_set_vector(entMyWall, EV_VEC_maxs, maxs)
	entity_set_vector(entMyWall, EV_VEC_absmax, maxs)
	
	// Set angle
	mins[0] = 0.0
	mins[1] = 0.0
	mins[2] = 0.0
	entity_set_vector(entMyWall, EV_VEC_angles, Float:{0.0,0.0,0.0})
	
	// Get user origin
	entity_set_origin(entMyWall, fvOrigin)

	// Set other values
	entity_set_int(entMyWall, EV_INT_solid, SOLID_BBOX)
	entity_set_int(entMyWall, EV_INT_movetype, MOVETYPE_FLY)
	
	return entMyWall
}