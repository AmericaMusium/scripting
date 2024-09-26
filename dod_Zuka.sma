/*=================================================================================================
Syn's Rocket Exploit Fix v1.003

This plugin prevents Bazooka/Panzer/Piat ceiling/floor exploits. It works for all maps.

===========================
v1.003 Changes
===========================
- Adjusted ranges to be more accurate and direct hits now kill like normal.
  
- Use of CVAR pointers for speed improvement.

===========================
v1.002 Changes
===========================
- Added CVAR amx_fix_rockets_above to seperately enable or disable ceiling damage above player
  damage.
  
- Added CVAR amx_fix_rockets_below to seperately enable or disable underneath floor damage blocking.

===========================
Features
===========================
- Prevents ceiling/rocket glitching. This reduces damage above head and completely blocks damage to
  players on top of a floor where a rocket is shot from underneath.

===========================
CVARS
===========================
amx_fix_rockets | 0 = off | 1 = on
- Enables or disables the plugin. Default on.

amx_fix_rockets_above | 0 = off | 1 = on
- Enables or disables the plugin. Default on.

amx_fix_rockets_below | 0 = off | 1 = on
- Enables or disables the plugin. Default on.

===========================
Installation
===========================
- Compile the .sma file | An online compiler can be found here:
  http:www.amxmodx.org/webcompiler.cgi
- Copy the compiled .amxx file into your addons\amxmodx\plugins folder
- Add the name of the compiled .amxx to the bottom of your addons\amxmodx\configs\plugins.ini
- Change the map or restart your server to start using the plugin!

===========================
Support
===========================
Visit the AMXMODX Plugins section of the forums @ 
http:www.dodplugins.net or http:www.rivurs.com

===========================
License
===========================
Syn's Rocket Exploit Fix
Copyright (C) 2012 Synthetic

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

=================================================================================================*/

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>

// =================================================================================================
// Declare global variables and values
// =================================================================================================
new ent
new Float:rocket_origin[3]
new Float:player_origin[33][3]
new Float:player_origin2[33][3]

new pntr_fix_rockets
new pntr_fix_rockets_above
new pntr_fix_rockets_below
new pntr_fix_rockets_debug

// =================================================================================================
// Plugin init
// =================================================================================================
public plugin_init() {
	register_plugin("Syn's Rocket Exploit Fix","1.003","«Synthetiç» www.rivurs.com")
	register_cvar("syns_rocket_exploit_fix", "v1.003 by Synthetic - www.rivurs.com",FCVAR_SERVER|FCVAR_SPONLY)
	
	pntr_fix_rockets = register_cvar("amx_fix_rockets", "1")
	pntr_fix_rockets_above = register_cvar("amx_fix_rockets_above","1")
	pntr_fix_rockets_below = register_cvar("amx_fix_rockets_below","1")
	pntr_fix_rockets_debug = register_cvar("amx_fix_rockets_debug","0")

	register_forward(FM_PlayerPreThink,"func_prethink")
	register_forward(FM_Think,"func_think")
	
}

// =================================================================================================
// Adjust rockets so damage above players is allot less and damage from underneath floor is blocked
// =================================================================================================
public func_prethink(id) {
	pev(id,pev_origin,player_origin[id])
	pev(id,pev_origin,player_origin2[id])
	player_origin[id][2] = player_origin[id][2] + 70.0 // Adjust so range is above players head
	player_origin2[id][2] = player_origin2[id][2] - 60.0 // Adjust so range is below players feet
}

// =================================================================================================
// Adjust rockets so damage above players is allot less and damage from underneath floor is blocked
// =================================================================================================
public func_think(id) {
	if(get_pcvar_num(pntr_fix_rockets))
	{
		new i
		// Bazookas
		while((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", "shell_bazooka")) != 0)
		{
			pev(ent,pev_origin,rocket_origin)
			for(i=1;i<32;++i)
			{
				if(get_pcvar_num(pntr_fix_rockets_above) && get_distance_f(rocket_origin,player_origin[i]) < 42.00)
				{
					set_pev(ent,pev_dmg,40.0)
					if(get_pcvar_num(pntr_fix_rockets_debug))
						client_print(0,print_chat,"[Rocket Exploit Fix] Hit above!")
				}
				if(get_pcvar_num(pntr_fix_rockets_below) && get_distance_f(rocket_origin,player_origin2[i]) < 33.00)
				{
					set_pev(ent,pev_dmg,0.0)
					if(get_pcvar_num(pntr_fix_rockets_debug))
						client_print(0,print_chat,"[Rocket Exploit Fix] Hit below!")
				}
			}
		}
		// Panzers
		while((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", "shell_pschreck")) != 0)
		{
			pev(ent,pev_origin,rocket_origin)
			for(i=1;i<32;++i)
			{
				if(get_pcvar_num(pntr_fix_rockets_above) && get_distance_f(rocket_origin,player_origin[i]) < 42.00)
				{
					set_pev(ent,pev_dmg,40.0)
					if(get_pcvar_num(pntr_fix_rockets_debug))
						client_print(0,print_chat,"[Rocket Exploit Fix] Hit above!")
				}
				if(get_pcvar_num(pntr_fix_rockets_below) && get_distance_f(rocket_origin,player_origin2[i]) < 33.00)
				{
					set_pev(ent,pev_dmg,0.0)
					if(get_pcvar_num(pntr_fix_rockets_debug))
						client_print(0,print_chat,"[Rocket Exploit Fix] Hit below!")
				}
			}
		}
		// Piats
		while((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", "shell_piat")) != 0)
		{
			pev(ent,pev_origin,rocket_origin)
			for(i=1;i<32;++i)
			{
				if(get_pcvar_num(pntr_fix_rockets_above) && get_distance_f(rocket_origin,player_origin[i]) < 42.00)
				{
					set_pev(ent,pev_dmg,40.0)
					if(get_pcvar_num(pntr_fix_rockets_debug))
						client_print(0,print_chat,"[Rocket Exploit Fix] Hit above!")
				}
				if(get_pcvar_num(pntr_fix_rockets_below) && get_distance_f(rocket_origin,player_origin2[i]) < 33.00)
				{
					set_pev(ent,pev_dmg,0.0)
					if(get_pcvar_num(pntr_fix_rockets_debug))
						client_print(0,print_chat,"[Rocket Exploit Fix] Hit below!")
				}
			}
		}
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1049\\ f0\\ fs16 \n\\ par }
*/
