#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <dodx>
#include <dodfun>
#include <hamsandwich>
#include <fakemeta>

#define PLUGINNAME	"AMXX Parachute"
#define VERSION		"1.0"
#define AUTHOR		"KRoT@L (Ported by 29thID)"


#define m_afButtonPressed 238
new para_ent[33]

/*
В парашюте можно prethink 
заменить на ham_objectcaps 
(вызывается каждый кадр, когда нажата клавиша 'E' /+use)
*/

public plugin_init()
{
	register_plugin( PLUGINNAME, VERSION, AUTHOR )

	register_cvar( "sv_parachute", "1" )
	register_cvar( "admin_parachute", "0" )
    RegisterHam(Ham_ObjectCaps, "player", "fw_Player_ObjectCaps2")
	register_event( "ResetHUD", "event_resethud", "be" )
}

public plugin_precache()
{
	precache_model("models/475parachute.mdl")
}

public client_connect(id)
{
	if(para_ent[id] > 0)
	{
		remove_entity(para_ent[id])
	}
	para_ent[id] = 0
}

public event_resethud( id ) {
	if(para_ent[id] > 0)
	{
		remove_entity(para_ent[id])
	}
	para_ent[id] = 0
}

public fw_Player_ObjectCaps(id)
{

	if(get_pdata_int(id, m_afButtonPressed, 5) & IN_USE)
	{
		client_print(id,print_chat,"pressed E")

        if ( !( get_entity_flags(id) & FL_ONGROUND ) )
		{
			new Float:velocity[3]
			entity_get_vector(id, EV_VEC_velocity, velocity)
			if(velocity[2] < 0)
			{
				if (para_ent[id] == 0)
				{
					para_ent[id] = create_entity("info_target")
					if (para_ent[id] > 0)
					{
						entity_set_model(para_ent[id], "models/475parachute.mdl")
						entity_set_int(para_ent[id], EV_INT_movetype, MOVETYPE_FOLLOW)
						entity_set_edict(para_ent[id], EV_ENT_aiment, id)
                        set_pev(id,pev_gravity, 0.01)

					}
				}
				if (para_ent[id] > 0)
				{
					velocity[2] = (velocity[2] + 40.0 < -100) ? velocity[2] + 40.0 : -100.0
					entity_set_vector(id, EV_VEC_velocity, velocity)
					if (entity_get_float(para_ent[id], EV_FL_frame) < 0.0 || entity_get_float(para_ent[id], EV_FL_frame) > 254.0)
					{
						if (entity_get_int(para_ent[id], EV_INT_sequence) != 1)
						{
							entity_set_int(para_ent[id], EV_INT_sequence, 1)
						}
						entity_set_float(para_ent[id], EV_FL_frame, 0.0)
					}
					else 
					{
						entity_set_float(para_ent[id], EV_FL_frame, entity_get_float(para_ent[id], EV_FL_frame) + 1.0)
					}
				}
			}
			else
			{
				if (para_ent[id] > 0)
				{
					remove_entity(para_ent[id])
					para_ent[id] = 0
				}
			}
		}
		else
		{
            

			if (para_ent[id] > 0)
			{
				remove_entity(para_ent[id])
				para_ent[id] = 0
			}
		}
	}
	else if (get_user_oldbutton(id) & IN_USE)
	{
		if (para_ent[id] > 0)
		{
			remove_entity(para_ent[id])
			para_ent[id] = 0
		}
	}
	
	return PLUGIN_CONTINUE
}		

public fw_Player_ObjectCaps2(id)
{

	if(get_pdata_int(id, m_afButtonPressed, 5) & IN_USE)
	{
		client_print(id,print_chat,"pressed E")

        if ( !( get_entity_flags(id) & FL_ONGROUND ) )
		{
			new Float:velocity[3]
			entity_get_vector(id, EV_VEC_velocity, velocity)
			if(velocity[2] < 0)
			{
				if (para_ent[id] == 0)
				{
					para_ent[id] = create_entity("info_target")
					if (para_ent[id] > 0)
					{   
                        set_pev(id,pev_gravity, 0.2)
						entity_set_model(para_ent[id], "models/475parachute.mdl")
						entity_set_int(para_ent[id], EV_INT_movetype, MOVETYPE_FOLLOW)
						entity_set_edict(para_ent[id], EV_ENT_aiment, id)
					}
				}
				if (para_ent[id] > 0)
				{
					velocity[2] = (velocity[2] + 40.0 < -100) ? velocity[2] + 40.0 : -100.0
					entity_set_vector(id, EV_VEC_velocity, velocity)
					if (entity_get_float(para_ent[id], EV_FL_frame) < 0.0 || entity_get_float(para_ent[id], EV_FL_frame) > 254.0)
					{
						if (entity_get_int(para_ent[id], EV_INT_sequence) != 1)
						{
							entity_set_int(para_ent[id], EV_INT_sequence, 1)
						}
						entity_set_float(para_ent[id], EV_FL_frame, 0.0)
					}
					else 
					{
						entity_set_float(para_ent[id], EV_FL_frame, entity_get_float(para_ent[id], EV_FL_frame) + 1.0)
					}
				}
			}
			else
			{   
                set_pev(id,pev_gravity, 1.0)
				if (para_ent[id] > 0)
				{
					remove_entity(para_ent[id])
					para_ent[id] = 0
				}
			}
		}
		else
		{
			if (para_ent[id] > 0)
			{
				remove_entity(para_ent[id])
				para_ent[id] = 0
			}
		}
	}
	else if (get_user_oldbutton(id) & IN_USE)
	{
		if (para_ent[id] > 0)
		{
			remove_entity(para_ent[id])
			para_ent[id] = 0
		}
	}
	
	return PLUGIN_CONTINUE
}		
