/***************************************************************************************************
                        		AMX Parachute
          
  Version: 0.2.2
  Author: KRoTaL (Ported by Wilson [29th ID])

  1.0   Ported into DoD by Wilson [29th ID]

  Commands:

	Press +use to slow down your fall.

  Cvars:

	sv_parachute "1"	 -	0: disables the plugin
					1: enables the plugin
	

  Setup (AMXX 1.71):

    Install the amxx file. 
    Enable engine (amxx's modules.ini) 
    Put the parachute.mdl file in the cstrike/models folder


***************************************************************************************************/

#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <dodx>
#include <dodfun>

#define PLUGINNAME	"AMXX Parachute"
#define VERSION		"1.0"
#define AUTHOR		"KRoT@L (Ported by 29thID)"

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
	
	register_event( "ResetHUD", "event_resethud", "be" )
}

public plugin_precache()
{
	precache_model("models/parachute.mdl")
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

public client_PreThink(id)
{
	if( get_cvar_num( "sv_parachute" ) == 0 )
	{
		return PLUGIN_CONTINUE
	}

	if( !is_user_alive(id) )
	{
		return PLUGIN_CONTINUE
	}
	if (get_user_button(id) & IN_USE )
	{
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
						entity_set_model(para_ent[id], "models/parachute.mdl")
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
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1049\\ f0\\ fs16 \n\\ par }
*/
