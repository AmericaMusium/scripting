/*
*	Weapon Sprites by Vet(3TT3V)
*	For DOD 1.3
*
*	This plugin will create an explosion sprite for grenades, mortars and rockets.
*		It will render the explosion sprite even if cl_particlefx is off.
*
*	It will also create a sparks sprite when a player's melee weapon strikes an object.
*
*	It works by hooking the creation of a world or entity decal and creates a sprite at
*		the same location. So server/client decal settings MAY affect renderability.
*
*	CVar (Optional - Will default to Enable)
*		weaponsprites_enable <0|1>	// plugin enable/disable (Default = 1 <enable>)
*/

#include <amxmodx>
#include <fakemeta>

#define PLUGIN "DOD_WeaponSprites"
#define VERSION "1.2"
#define AUTHOR "Vet(3TT3V)"
#define SVARIABLE "DOD_WeaponSprites"
#define SVALUE "v1.2 by Vet(3TT3V)"

new g_enabled
new g_spriteID

public plugin_precache()
{
	g_spriteID = engfunc(EngFunc_PrecacheModel, "sprites/grenade_flash.spr")
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_cvar(SVARIABLE, SVALUE, FCVAR_SERVER|FCVAR_SPONLY)

	//tempentity event - decal applied to world or entity
	register_event("23", "weapon_sprite", "a", "1=116", "1=104")

	g_enabled = register_cvar("weaponsprites_enable","1")
}

public weapon_sprite()
{
	static Float:origin[3]
	if (!get_pcvar_num(g_enabled))
		return

	switch (read_data(5)) {
		case 60, 61: {		// is decal scorch1 or 2?
			read_data(2, origin[0])
			read_data(3, origin[1])
			read_data(4, origin[2])
			message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
			write_byte(TE_EXPLOSION)
			write_coord(floatround(origin[0]))
			write_coord(floatround(origin[1]))
			write_coord(floatround(origin[2]))
			write_short(g_spriteID)
			write_byte(10)
			write_byte(30)
			write_byte(4)
			message_end()
		}
		case 54..58: {		// is decal shot1-5?
			read_data(2, origin[0])
			read_data(3, origin[1])
			read_data(4, origin[2])
			message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
			write_byte(TE_SPARKS)
			write_coord(floatround(origin[0]))
			write_coord(floatround(origin[1]))
			write_coord(floatround(origin[2]))
			message_end()
		}
		default: {
			return
		}
	}	
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1049\\ f0\\ fs16 \n\\ par }
*/
