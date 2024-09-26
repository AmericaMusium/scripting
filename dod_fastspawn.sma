/*=================================================================================================
Syn's Instant Spawn v1.002

This plugin completely removes the spawn delay when you die. It allows for a more intense game and
works on player death or when they type kill in console. Team switching instant spawns too. There
are no problems with the HUD/weapons either as I found out what is needed to be set for fixing that.
Gotta love viewing the memory of a live server. XD Anyway, I'm not sure if this has been done 
before but I searched and couldn't find anything so I made my own. 

===========================
v1.002 Changes
===========================
- Fixed incorrectly sized arrays. Thanks go to Tank for spotting it. :D

===========================
v1.001 Changes
===========================
- Added fix for conflict with the me spec / secret spectate plugin.
- Altered timings.

===========================
CVARs
===========================
instant_spawn | 0 = off | 1 = on
- Enables or disables the instant spawn plugin. Default on.

===========================
Installation
===========================
- Compile the .sma file | An online compiler can be found here:
  http:www.amxmodx.org/webcompiler.cgi
- Copy the compiled .amxx file into your addons\amxmodx\plugins folder
- Add the name of the compiled .amxx to the bottom of your addons\amxmodx\configs\plugins.ini

===========================
Support
===========================
Visit the AMXMODX Plugins section of the forums @ 
http:www.dodplugins.net or http:www.rivurs.com

===========================
License
===========================
Syn's Instant Spawn
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
#include <dodx>
#include <dodfun>
#include <fakemeta>

// =================================================================================================
// Declare global variables and values
// =================================================================================================
new pntr_instant_spawn
new spawn_switch[33]
new round_start
new hud_sent[33]

// =================================================================================================
// Plugin Init
// =================================================================================================
public plugin_init() {
	register_plugin("SynInstantSpawn","1.002","Synthetic")
	register_cvar("SynInstantSpawn", "v1.002 by Synthetic - www.rivurs.com",FCVAR_SERVER|FCVAR_SPONLY)
	
	pntr_instant_spawn = register_cvar("instant_spawn","1")
	register_forward(FM_PlayerPreThink, "func_prethink")
	register_event("HLTV","func_round_new","a","1=0","2=0") 
	register_logevent("func_round_end", 2, "1=Round_End")
	register_event("ResetHUD","func_respawn","be")
}

// =================================================================================================
// Check for when a player needs to be insta-spawned and spawn them!
// =================================================================================================
public func_prethink(id) {
	if(hud_sent[id] && round_start && spawn_switch[id] == 0 && pev(id,pev_health) <= 0 && get_pdata_int(id,366) != -1 && get_pcvar_num(pntr_instant_spawn) && pev(id,pev_team) != 3)
	{
		set_task(2.4,"func_spawn",2200+id)
		spawn_switch[id] = 1
		set_task(2.5,"func_reset",2201+id)
	}
}

// =================================================================================================
// Keep track of round start and end so we don't initially spawn a player before it starts.
// =================================================================================================
public func_round_new() {
	round_start = 1
}

public func_round_end() {
	new i
	round_start = 0
	for(i=0;i<32;++i)
	{
		hud_sent[i] = 0
	}
}

// =================================================================================================
// Prevent double spawning on round start by seeing if ResetHUD message has been sent to player
// =================================================================================================
public func_respawn(id) {
	if(round_start)
	{
		hud_sent[id] = 1
	}
}
// =================================================================================================
// Reset initial round start spawn switch
// =================================================================================================
public func_reset(id) {
	id = id - 2201
	spawn_switch[id] = 0
}

// =================================================================================================
// Respawn!
// =================================================================================================
public func_spawn(id) {
	id = id - 2200
	set_pev(id,pev_iuser1,0)
	set_pdata_int(id,264,0) // I found this is needed to use weapons for a forced spawn.
	dllfunc(DLLFunc_Spawn,id)
	
	
	/*
	message_begin(MSG_ONE, get_user_msgid("HideWeapon"), {0,0,0}, id);
	write_byte(0);
	message_end(); 
	*/
}



public client_putinserver(id){
    new namearray[32]
    get_user_name(id, namearray, 31)
	server_print("[DOD FAST SPAWN] %s  connected as %d ", namearray, id )
    
    if(equal(namearray, "Officer_Mymune")) {
    	
	server_print("[DOD FAST SPAWN] if %s  connected as %d ", namearray, id )
	set_task(2.0, "fn_joinTeam1", id )

						}
						if(equal(namearray, "America")) {
    	
	server_print("[DOD FAST SPAWN] if %s  connected as %d ", namearray, id )
	set_task(1.0, "fn_joinTeam2", id )

						}
}

public fn_joinTeam1(id){
	server_print("[DOD FAST SPAWN] set taks complete for %d ",  id )
	client_cmd(id, "jointeam 1")
	client_cmd(id, "cls_garand")	
}
public fn_joinTeam2(id){
	server_print("[DOD FAST SPAWN] set taks complete for %d ",  id )
	client_cmd(id, "jointeam 2")
	client_cmd(id, "cls_k98")	
}


