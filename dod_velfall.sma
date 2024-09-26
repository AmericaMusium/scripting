/* Plugin generated by AMXX-Studio*/

#include <amxmodx>
#include <engine>

/*
			Decription: This plugin lowers a person's gravity if 
		   their velocity on a jump increases too high. It also deploys
				a parachute on their way down.

					Changelog:
				-1.0 Initial Release
				-1.1 Bug fixes, thanks to Hawk552
				-1.2 Parachute fixes, thanks to JTP.

Acknowledgements:
Thanks to Hawk552 for his entity tutorial and nightscreem for some coding.
Thanks also to XxAvalanchexX, Zenith77, and Des12 for their help on entities.
Thanks again to Hawk552 for some coding as well.*/

new bool:Falling[33] 
new Float:origin[3]
new model[] = "models/w_aflag.mdl"
new classname[] = "parachute"
new p_grav
new entid

public plugin_init() 
{ 
	register_plugin("Parachute","1.2","Satan")
	p_grav = register_cvar("mp_parachute", "0.25")
} 

public plugin_precache()
{
	if(file_exists(model))
	{
		precache_model(model)
	}
	else
	{
		set_fail_state("Model not found")
	}
}

public client_PreThink(id)
{ 
	
	if(is_user_bot(id))
	{
		return PLUGIN_HANDLED;
	}
	
	else
	
	if(entity_get_float(id, EV_FL_flFallVelocity) >= 254.0) 
	{
		entid = create_entity("info_target")
		entity_set_string(entid, EV_SZ_classname, classname)
		entity_set_edict(entid, EV_ENT_aiment, id)
		entity_set_edict(entid, EV_ENT_owner, id)
		entity_set_model(entid, model)
		entity_set_int(entid, EV_INT_movetype, MOVETYPE_FOLLOW)
		entity_set_int(entid, EV_INT_sequence, 1)
		entity_get_vector(id, EV_VEC_origin, origin)
		entity_set_origin(entid, origin)
		Falling[id] = true
	}
	else
	{
		Falling[id] = false
	}
	return PLUGIN_CONTINUE
} 

public client_PostThink(id)
{ 
	if(Falling[id])
	{
		entity_set_float(id, EV_FL_gravity, get_pcvar_float(p_grav))
	} 
	else
	{
		entity_set_float(id, EV_FL_gravity, 1.0)
		set_task(0.1, "remove", id)
	}
	
	Falling[id] = false
} 

public remove(id)
{    
	while((entid = find_ent_by_owner(entid, classname, id)))
		return remove_entity(entid)
	
	return PLUGIN_CONTINUE
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
