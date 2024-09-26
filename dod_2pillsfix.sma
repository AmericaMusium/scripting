///////////////////////////////////////////////////////////////////////////////////////
//
//	AMX Mod (X)
//
//	Developed by:
//	The Amxmodx DoD Community
//	|BW|.Zor Editor (zor@blackwatch.recongamer.com)
//	http://www.dodcommunity.net
//
//	This program is free software; you can redistribute it and/or modify it
//	under the terms of the GNU General Public License as published by the
//	Free Software Foundation; either version 2 of the License, or (at
//	your option) any later version.
//
//	This program is distributed in the hope that it will be useful, but
//	WITHOUT ANY WARRANTY; without even the implied warranty of
//	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
//	General Public License for more details.
//
//	You should have received a copy of the GNU General Public License
//	along with this program; if not, write to the Free Software Foundation,
//	Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
//	In addition, as a special exception, the author gives permission to
//	link the code of this program with the Half-Life Game Engine ("HL
//	Engine") and Modified Game Libraries ("MODs") developed by Valve,
//	L.L.C ("Valve"). You must obey the GNU General Public License in all
//	respects for all of the code used other than the HL Engine and MODs
//	from Valve. If you modify this file, you may extend this exception
//	to your version of the file, but you are not obligated to do so. If
//	you do not wish to do so, delete this exception statement from your
//	version.
//
//	Name:
//	Author:		|BW|.Zor
//	Description:
//	Reference:
//
//	v0.1 	- Be!
//		- Need to do some research on better way to do this
//
///////////////////////////////////////////////////////////////////////////////////////

#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <dodx>

///////////////////////////////////////////////////////////////////////////////////////
// Version Control
//
new AUTH[] = "AMXX DoD Community"
new PLUGIN_NAME[] = "2pillboxes Fix"
new VERSION[] = "0.1"
//
///////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////
// Globals
//
// Axis Square	 FLX   BLX   FRY   BRY
new Axis[4] = { 1522, 2300, 1524, 2300}

// Allies Square   FLX   BLX   FRY   BRY
new Allies[4] = { 1524, 2300, 1522, 2300 }
//
///////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////
//
// Initializations of the Plugin
//
public plugin_init()
{
	// Register this plugin
	register_plugin(PLUGIN_NAME, VERSION, AUTH)

	register_clcmd("jointeam", "join")
}

///////////////////////////////////////////////////////////////////////////////////////
//
// Required modules for this plugin
//
public plugin_modules()
{
	require_module("DODX")

	return PLUGIN_CONTINUE
}


///////////////////////////////////////////////////////////////////////////////////////
//
// Configures of the Plugin
//
public plugin_cfg()
{
	new map[32]
	get_mapname(map, 31)

	if(containi(map, "dod_2pillboxes") == -1)
	{
		pause("acd", "dod_2pillsfix.amxx")

		return PLUGIN_HANDLED
	}

	return PLUGIN_CONTINUE
}

///////////////////////////////////////////////////////////////////////////////////////
//
// When a client is actually in the server
//
public join(id)
{
	new param[1]
	param[0] = id
	set_task(5.0, "tellAbout", (id*11), param, 1)
}

///////////////////////////////////////////////////////////////////////////////////////
//
// Tells players not to shoot from spawn!
//
public tellAbout(param[])
{
	set_hudmessage(255, 0, 0, 0.05, 0.4)
	show_hudmessage(param[0], "Do NOT Shoot from within the Spawn...you WILL be killed!")
}

///////////////////////////////////////////////////////////////////////////////////////
//
// Checks their location and if within a square they will not be able to shoot...and be warned
//
public client_PreThink(id)
{
	if(entity_get_int(id, EV_INT_button) & IN_ATTACK)
	{
    		if(check_location(id))
    		{
    			new clip, ammo

			if(get_user_weapon(id, clip, ammo) == DODW_HANDGRENADE || get_user_weapon(id, clip, ammo) == DODW_STICKGRENADE || get_user_weapon(id, clip, ammo) == DODW_STICKGRENADE_EX || get_user_weapon(id, clip, ammo) == DODW_HANDGRENADE_EX || get_user_weapon(id, clip, ammo) == DODW_MILLS_BOMB)
			{
				return PLUGIN_HANDLED
			}

			else
			{
				set_hudmessage(255, 0, 0, 0.05, 0.4)
				show_hudmessage(id, "You are not allowed to shoot from within the Spawn! Move Forward!")
				dod_user_kill(id)
			}
		}
	}

	return PLUGIN_CONTINUE
}

///////////////////////////////////////////////////////////////////////////////////////
//
// Computes the location and figures out whats needed
//
public bool:check_location(id)
{
	new origin[3]
    	get_user_origin(id, origin, 0)

	// Axis Check
    	if(origin[0] > Axis[0] && origin[0] < Axis[1] && origin[0] > Axis[2] && origin[0] < Axis[3])
    		return true

	// Allies Check
	if(origin[0] > Allies[0] && origin[0] < Allies[1] && origin[0] > Allies[2] && origin[0] < Allies[3])
    		return true

    	return false
}
