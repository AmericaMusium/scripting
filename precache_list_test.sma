/* Sublime AMXX Editor v4.2 */

#include <amxmodx>
#include <precache_list>

#define PLUGIN  "Test API [Resources Manager]"
#define AUTHOR  "Shadows Adi"

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_concmd("debug", "show_precache")
}

public show_precache(id)
{
	new iSize = precache_get_size(t_model)
	new szTemp[MAX_RESOURCE_SIZE]

	for(new i; i < iSize; i++)
	{
		precache_get_item(i, szTemp, charsmax(szTemp), t_model)

		log_to_file("debug.log", "Model: %s", szTemp)
	}

	iSize = precache_get_size(t_sound)

	for(new i; i < iSize; i++)
	{
		precache_get_item(i, szTemp, charsmax(szTemp), t_sound)

		log_to_file("debug.log", "Sound: %s", szTemp)
	}

	iSize = precache_get_size(t_decal)

	for(new i; i < iSize; i++)
	{
		precache_get_item(i, szTemp, charsmax(szTemp), t_decal)

		log_to_file("debug.log", "Decal: %s", szTemp)
	}

	iSize = precache_get_size(t_generic)

	for(new i; i < iSize; i++)
	{
		precache_get_item(i, szTemp, charsmax(szTemp), t_generic)

		log_to_file("debug.log", "Generic: %s", szTemp)
	}

	iSize = precache_get_size(t_eventscript)

	for(new i; i < iSize; i++)
	{
		precache_get_item(i, szTemp, charsmax(szTemp), t_eventscript)

		log_to_file("debug.log", "Event: %s", szTemp)
	}

	log_to_file("debug.log", "Precached? %s", is_resource_precached("models/p_usp.mdl", t_model) ? "true" : "false")

	if(is_resource_precached("models/p_usp.mdl", t_model))
	{
		log_to_file("debug.log", "Replaced? %s", unprecache_resource("models/p_usp.mdl", REPLACE, true, "models/p_glock18.mdl") ? "successfull" : "unsuccessfull")
	}

	if(is_resource_unprecached("models/p_usp.mdl"))
	{
		log_to_file("debug.log", "Resourse is unprecached!")
	}
	else
	{
		log_to_file("debug.log", "Resourse is not unprecached!")
	}
}