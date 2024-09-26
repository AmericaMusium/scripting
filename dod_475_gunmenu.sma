/*=================================================================================================
Syn's Weapons Mod v3.003

This weapons mod allows clients to get any chosen primary gun they want with a pile of additional
options and features. It effectively does the same thing as Toolz weaponmod but through completely 
different methods and fixes the /say command issue as well the inherent issue where client's 
don't get a weapon due to lag/packet loss when using the give_item() function.

===========================
v3.005 Changes
===========================
- Fixed m_Primarywepon to 274 (previously it was 273) by America

===========================
v3.002 Changes
===========================
- Fixed random HLDS crash issue caused by improperly removing weapon entities by using
  Ham_RemovePlayerItem. 
- Fixed problems with key binds not working and other issues due to private data calls on invalid 
  entities resulting in abnormal plugin termination.
- Fixed client's getting stuck in deployed view mode when changing to different guns
  while previously using a deployed MG.
- Fixed non chosen weapon entity blocking. It appears I broke it at some point without realizing it.
- Refined weapon entity removal system.
- Fixed disabled weapons not actually being disabled.

===========================
Features
===========================
- Provides client access to all primary guns in DoD.
- Can allow clients to spawn with their chosen weapon via the /gunsave feature.
- Clients always get their chosen weapon irregardless of the quality of their internet connection.
- You do not need to be on your primary weapon to change weapons.
- Allows setting class restrictions according to map config or by plugin CVARs which act as global
  settings for all maps. Either method can be set to update the normal DoD class choice menu.
- Optional dropped weapon removal mode to keep the server clean.
- Dropped weapons near a player's pickup range are not picked up when a player chooses a weapon.
- Weapons can be individually disabled allowing only access via normal DoD class choice menu.
- Built in help features.

===========================
Notes
===========================
- Credit goes to Toolz for his/her original plugin idea.
- When enabling class restrictions on a currently running round where previously disabled, a map 
  change or server restart is recommended as active class counts will be inaccurate if you don't.
- When using class restrictions and mirroring to the DoD class menu selections, the "There is
  currently x player(s) of this class on your team" count will be inaccurate but being as no one 
  probably cares about this anyway, I didn't bother to correct it and it alleviates having to send
  more data to clients.
- Tested on AMXMODX v1.8.1

===========================
Say Commands
===========================
/gunlist - Displays a list of all the gun names.
/gunbinding - Displays help on how to bind guns to a key.
/gunmenu - Displays a gun choice menu players can use to select their wanted gun.
/gunsave - Will toggle saving last gun choice for a player removing the need to manually request it.

===========================
CVARs
===========================
swm_wm | 0 = off | 1 = on
- Enables or disables the weaponsmod plugin. Default on.

swm_changes | x
- Sets how times a player can change their weapons between respawn/rounds. Default 2.

swm_delay | x
- Sets delay in seconds before a player can get another weapon after choosing one. Setting this too
  low will allow clients to continually get guns and could eat your server alive. AMXMODX flood
  protection will limit the abillity of setting as well. Default 5.

swm_max_weaponname | replace "weaponname" with corresponding weapon name | 0 = disable weapon
- Replace weaponname with the weapon's name. Allows you to specify a max for each weapon. These are 
  the internal class maximums for use when class restrictions are enabled and class restriction type
  is set to global. Default 5 for all classes. 
  
swm_disable_"weaponname" | 0 = disable | 1 = enable
- Disables a specific weapon when you want to force players to use the default DoD class menu.
  Default is disabled for all weapons.

swm_help | 0 = off | 1 = on
- Allows players to say /gunlist in chat to receive a list of all the available gun choices.
  Default on.

swm_class_restrict | 0 = off | 1 = on
- Enables or disables whether class restrictions are enforced. Default off.

swm_restrict_type | 0 = per map | 1 = global
- Lets you choose restrictions per a map's config or through global max weapon CVARs. Default per
  map. Default per map.
  
swm_menu_restrict | 0 = off | 1 = on
- Enables or disables setting server class restrictions which effect the state of class choices in
  the default DoD class menu. This is not to be confused with the weapons mod menu. Default off.

swm_gunsave | 0 = off | 1 = on
- Enables or disables the automatic last weapon chosen giving on respawn system. Default on.

swm_notify | 0 = off | 1 = on
- Enables or disables telling new joining players of this weapons mod features. Default on.

swm_remove | 0 = off | 1 = on
- Enables or disables removing all weapon entities. This will remove any and all weapons that aren't
  being used by a player. Default off.
  
swm_give_menu | 0 = off | 1 = on
- Enables or disables the weapons mod weapon give menu. Default on.

===========================
Installation
===========================
- Compile the .sma | An online compiled version can be found here on the same page you
  downloaded this from.
- Copy the compiled .amxx file into your addons\amxmodx\plugins folder
- Add the name of the .amxx file to the bottom of your addons\amxmodx\configs\plugins.ini
- Change the map or restart your server to start using the plugin!

===========================
Support
===========================
Visit the AMXMODX Plugins section of the forums @ 
http:www.dodplugins.net or http:www.rivurs.com

===========================
License
===========================
Syn's Weapons Mod
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
#include <hamsandwich>
#include <fakemeta_util>
#include <dodx>
#include <dodfun>
#include <fun>
#include <engine>

#define m_knifeItem 272			// prt ножа 
#define m_pistolItem 273        //  ptr пистолета в инвентаре
#define m_rifleItem 274        //  ptr основы в инвентаре

// =================================================================================================
// Declare global variables and values
// =================================================================================================
new const weapon_dod_list[36][] = { "","weapon_amerknife","weapon_gerknife","weapon_colt","weapon_luger",
"weapon_garand","weapon_scopedkar","weapon_thompson","weapon_mp44","weapon_spring","weapon_kar","weapon_bar",
"weapon_mp40","","","","","weapon_mg42","weapon_30cal","weapon_spade","weapon_m1carbine","weapon_mg34","weapon_greasegun",
"weapon_fg42","weapon_k43","weapon_enfield","weapon_sten","weapon_bren","weapon_webley","weapon_bazooka","weapon_pschreck",
"weapon_piat","weapon_fg42","","","weapon_enfield" }
new weapon_disable[36] // Stores all disabled weapons

new client_gun_changes[33] // Keeps track of how many changes a player has left
new client_chosen_class[33] // Stores the chosen weapon class by int for use with the weapon_dod_list array
new client_chosen_weapon_id[33] // Stores the weapon entity id for each gun given to a specific client - used for blocking others
new client_spawn_class[33] // Stores the initial spawn class
new client_last_spawn_class[33] // Stores the previous spawn class
new client_last_given_class[33] // Stores the last gun given from gunsave
new client_give_switch[33] // Used to hold the state of a client who dropped their weapon to determine correct class count
new client_gunsave[33] // Used for storing client /gunsave state
new client_block_state[33] // Keeps track of whether a client chose a weapon - used for other weapon entity blocking
new client_notify[33] // Keeps track of newly joined clients and if they have been notified of features
new Float:client_give_timer[33] // Stores HL timestamp when a gun was last given plus delay for use in delaying how fast weapons can be given

new class_restrictions[36] // Stores current set of class restrictions
new class_active[36] // Stores all active classes in use
new class_load // Used as a switch to load classes into class_restrictions array once
new const class_name_list[36][] = { "","","","","","mp_limitalliesgarand","mp_limitaxisscopedkar","mp_limitalliesthompson","mp_limitaxismp44",
"mp_limitalliesspring","mp_limitaxiskar","mp_limitalliesbar","mp_limitaxismp40","","","","","mp_limitaxismg42","mp_limitallies30cal",
"","mp_limitalliescarbine","mp_limitaxismg34","mp_limitalliesgreasegun","mp_limitaxisfg42","mp_limitaxisk43",
"mp_limitbritassault","mp_limitbritlight","mp_limitbritmg","","mp_limitalliesbazooka","mp_limitaxispschreck",
"mp_limitbritpiat","mp_limitaxisfg42s","mp_limitalliescarbine","","mp_limitbritsniper" }

new const messages[16][] = { "[WeaponsMod] The weapons mod is disable right now.",
"[WeaponsMod] This weapon is currently disabled.",
"[WeaponsMod] You've used up your gun changes, you must wait until respawn to change guns again.",
"[WeaponsMod] The server has reached the maximum number of this class.",
"[WeaponsMod] Weapon change recorded.",
"[WeaponsMod] You must enable /gunsave before you can choose a weapon when dead.",
"[WeaponsMod] Type /gunlist, /gunmenu, /gunbinding, or /gunsave to use the WeaponMod features!",
"[WeaponsMod] You will now respawn with the last gun chosen!",
"[WeaponsMod] You will no longer respawn with the last gun chosen!",
"[WeaponsMod] /k98 /k43 /mp40 /stg44 /fg42 /scopedfg42 /scopedk98 /mg34 /mg42",
"[WeaponsMod] /panzerschreck /garand /carbine /thompson /greasegun /bar /piat",
"[WeaponsMod] /springfield /30cal /bazooka /enfield /sten /bren /scopedenfield",
"[WeaponsMod] To bind a gun to a key, go into console and enter: bind key ^"say /weaponname^"",
"[WeaponsMod] For example, you want the 6 key to give you the K98. You would enter:",
"[WeaponsMod] bind 6 ^"say /k98^"", "[WeaponsMod] You must un-deploy before getting a new weapon!" }

new class_name[9] // Used for blocking dropped weapons to make sure we don't block touches to non weapons
new weapon_ent_kill[33] // Stores previous weapon kill state per player
 
new p_weapon_changes
new p_weapon_delay

new p_max_scopedfg42
new p_max_scopedenfield
new p_max_k98
new p_max_garand
new p_max_carbine
new p_max_k43
new p_max_mp40
new p_max_thompson
new p_max_stg44
new p_max_bar
new p_max_fg42
new p_max_greasegun
new p_max_bazooka
new p_max_enfield
new p_max_sten
new p_max_mg42
new p_max_mg34
new p_max_30cal
new p_max_springfield
new p_max_scopedk98
new p_max_bren
new p_max_panzerschreck
new p_max_piat

new p_disable_scopedfg42
new p_disable_scopedenfield
new p_disable_k98
new p_disable_garand
new p_disable_carbine
new p_disable_k43
new p_disable_mp40
new p_disable_thompson
new p_disable_stg44
new p_disable_bar
new p_disable_fg42
new p_disable_greasegun
new p_disable_bazooka
new p_disable_enfield
new p_disable_sten
new p_disable_mg42
new p_disable_mg34
new p_disable_30cal
new p_disable_springfield
new p_disable_scopedk98
new p_disable_bren
new p_disable_panzerschreck
new p_disable_piat

new p_weaponsmod
new p_weapon_help
new p_class_restrictions
new p_restriction_type
new p_autospawn_weapon
new p_wm_notify
new p_remove_weapons
new p_menu_restrict
new p_give_menu

new g_iMaxPlayers

// =================================================================================================
// Plugin init
// =================================================================================================
public plugin_init() {
	register_plugin("Syn's Weapon Mod","3.005f1","DoD Synthetic")
	register_cvar("syns_weapon_mod", "v3.005f1 by Synthetic - www.rivurs.com",FCVAR_SERVER|FCVAR_SPONLY)



	
	register_clcmd("say /gunlist","func_help_gunlist",0)
	register_clcmd("say /gunbinding","func_help_gunbiding",0)
	register_clcmd("say /gunmenu","func_gun_menu",0)
	register_clcmd("say /gunsave","func_gun_save",0)
	
	register_clcmd("say /garand","func_garand",0)
	register_clcmd("say /scopedk98","func_scopedk98",0)
	register_clcmd("say /thompson","func_thompson",0)
	register_clcmd("say /stg44","func_stg44",0)
	register_clcmd("say /springfield","func_spring",0)
	register_clcmd("say /k98","func_k98",0)
	register_clcmd("say /bar","func_bar",0)
	register_clcmd("say /mp40","func_mp40",0)
	register_clcmd("say /mg42","func_mg42",0)
	register_clcmd("say /30cal","func_30cal",0)
	register_clcmd("say /carbine","func_carbine",0)
	register_clcmd("say /mg34","func_mg34",0)
	register_clcmd("say /greasegun","func_grease",0)
	register_clcmd("say /fg42","func_fg42",0)
	register_clcmd("say /k43","func_k43",0)
	register_clcmd("say /enfield","func_enfield",0)
	register_clcmd("say /sten","func_sten",0)
	register_clcmd("say /bren","func_bren",0)
	register_clcmd("say /bazooka","func_bazooka",0)
	register_clcmd("say /panzerschreck","func_pschreck",0)
	register_clcmd("say /piat","func_piat",0)
	register_clcmd("say /scopedfg42","func_scopedfg42",0)
	// register_clcmd("say /scopedenfield","func_scopedenfield",0)
	
	p_weapon_delay = register_cvar("swm_delay","5.0")
	p_weapon_changes = register_cvar("swm_changes", "2")
	
	p_max_scopedfg42 = register_cvar("swm_max_scopedfg42","5")
	p_max_scopedenfield = register_cvar("swm_max_scopedenfield","0")
	p_max_k98 = register_cvar("swm_max_k98","5")
	p_max_garand = register_cvar("swm_max_garand","5")
	p_max_carbine = register_cvar("swm_max_carbine","5")
	p_max_k43 = register_cvar("swm_max_k43","5")
	p_max_mp40 = register_cvar("swm_max_mp40","5")
	p_max_thompson = register_cvar("swm_max_thompson","5")
	p_max_stg44 = register_cvar("swm_max_stg44","5")
	p_max_bar = register_cvar("swm_max_bar","5")
	p_max_fg42 = register_cvar("swm__max_fg42","5")
	p_max_greasegun = register_cvar("swm_max_greasegun","5")
	p_max_bazooka = register_cvar("swm_max_bazooka","5")
	p_max_enfield = register_cvar("swm_max_enfield","5")
	p_max_sten = register_cvar("swm_max_sten","5")
	p_max_mg42 = register_cvar("swm_max_mg42","2")
	p_max_mg34 = register_cvar("swm_max_mg34","2")
	p_max_30cal = register_cvar("swm_max_30cal","2")
	p_max_springfield = register_cvar("swm_max_springfield","2")
	p_max_scopedk98 = register_cvar("swm_max_scopedk98","2")
	p_max_bren = register_cvar("swm_max_bren","5")
	p_max_panzerschreck = register_cvar("swm_max_panzerschreck","5")
	p_max_piat = register_cvar("swm_max_piat","5")
	
	p_disable_scopedfg42 = register_cvar("swm_disable_scopedfg42","0")
	p_disable_scopedenfield = register_cvar("swm_disable_scopedenfield","1")
	p_disable_k98 = register_cvar("swm_disable_k98","0")
	p_disable_garand = register_cvar("swm_disable_garand","0")
	p_disable_carbine = register_cvar("swm_disable_carbine","0")
	p_disable_k43 = register_cvar("swm_disable_k43","0")
	p_disable_mp40 = register_cvar("swm_disable_mp40","0")
	p_disable_thompson = register_cvar("swm_disable_thompson","0")
	p_disable_stg44 = register_cvar("swm_disable_stg44","0")
	p_disable_bar = register_cvar("swm_disable_bar","0")
	p_disable_fg42 = register_cvar("swm__disable_fg42","0")
	p_disable_greasegun = register_cvar("swm_disable_greasegun","0")
	p_disable_bazooka = register_cvar("swm_disable_bazooka","0")
	p_disable_enfield = register_cvar("swm_disable_enfield","0")
	p_disable_sten = register_cvar("swm_disable_sten","0")
	p_disable_mg42 = register_cvar("swm_disable_mg42","0")
	p_disable_mg34 = register_cvar("swm_disable_mg34","0")
	p_disable_30cal = register_cvar("swm_disable_30cal","0")
	p_disable_springfield = register_cvar("swm_disable_springfield","0")
	p_disable_scopedk98 = register_cvar("swm_disable_scopedk98","0")
	p_disable_bren = register_cvar("swm_disable_bren","0")
	p_disable_panzerschreck = register_cvar("swm_disable_panzerschreck","0")
	p_disable_piat = register_cvar("swm_disable_piat","0")
	
	p_weaponsmod = register_cvar("swm_wm","1")
	p_weapon_help = register_cvar("swm_help", "1")
	p_class_restrictions = register_cvar("swm_class_restrict","0")
	p_restriction_type = register_cvar("swm_restrict_type","1")
	p_menu_restrict = register_cvar("swm_menu_restrict","0")
	p_autospawn_weapon = register_cvar("swm_gunsave","1")
	p_wm_notify = register_cvar("swm_notify","1")
	p_remove_weapons = register_cvar("swm_remove","0")
	p_give_menu = register_cvar("swm_give_menu","1")

	// register_forward(FM_SetModel,"func_remove_weapon",1)
	register_forward(FM_Touch,"func_weapon_touch",0) // Use Fakemeta since Ham_Touch does not pickup all entity touches..Broken pre/post?
	RegisterHam(Ham_Spawn,"player","func_respawn", 1)  
	RegisterHam(Ham_Killed,"player","func_client_death",0)
	register_forward(FM_PlayerPreThink,"func_prethink")
	// register_event("HLTV", "func_client_death", "a", "1=0", "2=0")
	
	g_iMaxPlayers = get_maxplayers()

	register_event("HLTV", "reset_gun_changes", "a", "1=0", "2=0")
	// client_gun_changes[id] = get_pcvar_num(p_weapon_changes)

}

//===== RESET GUN CHANGES IF ROUND RESTAR (FIX FOR KILLIN SPREE
public reset_gun_changes()
{
	new cnt
	for (cnt = 0; cnt <=31; cnt ++)
	{
		client_gun_changes[cnt] = get_pcvar_num(p_weapon_changes)
	} 

	set_task(6.0, "reset_gun_changes2")
	
}

public reset_gun_changes2()
{
	new cnt
	for (cnt = 0; cnt <=31; cnt ++)
	{
		client_gun_changes[cnt] = get_pcvar_num(p_weapon_changes)
	} 
}
// =================================================================================================
// Give client a weapon if they meet the proper conditions
// =================================================================================================
public func_give_weapon(id,weapon_class_id) 
{
	// ============================
	// Handle requirements
	// ============================
	
	// engclient_cmd(id,"slot3"," ")

	// See if plugin is enabled and if not, tell client
	if(!get_pcvar_num(p_weaponsmod))
	{
		client_print(id,print_chat,messages[0])
		return PLUGIN_HANDLED
	}
	
	// See if player's gun give delay has been met
	if(get_gametime() < client_give_timer[id])
		return PLUGIN_HANDLED
	
	// See if weapon is disabled and if so, tell client
	if(weapon_disable[weapon_class_id])
	{
		client_print(id,print_chat,messages[1])
		return PLUGIN_HANDLED
	}
	
	// See if client has exceeded their gun changes
	if(!client_gun_changes[id])
	{
		client_print(id,print_chat,messages[2])
		return PLUGIN_HANDLED
	}
	
	// If restrictions are enabled, see if class limit has been reached
	if(get_pcvar_num(p_class_restrictions) && class_active[weapon_class_id] == class_restrictions[weapon_class_id] && client_chosen_class[id] != weapon_class_id)
	{
		client_print(id,print_chat,messages[3])
		return PLUGIN_HANDLED
	}
	
	// See if player is alive and handle dead player gun choice notification
	if(!is_user_alive(id))
	{
		if(client_gunsave[id])
		{
			client_print(id,print_chat,messages[4])
			client_chosen_class[id] = weapon_class_id // Store weapon choice
		}
		else
		{
			client_print(id,print_chat,messages[5])
		}
		return PLUGIN_HANDLED
	}
	
	// ============================
	// Handle class counts
	// ============================
	// Decrement old class and increment new class. Also, update DoD class menu if enabled.
	new temp_cur_weapon_ent_id = get_pdata_cbase(id, m_rifleItem) // Get weapon entity ID of client's primary weapon - returns -1 on none
	
	if(get_pcvar_num(p_class_restrictions))
	{
		// See if client has a primary weapon. If they do, we know we can decrement that class and give the new class
		if(pev_valid(temp_cur_weapon_ent_id))
		{
			new temp_class = get_pdata_int(temp_cur_weapon_ent_id,91)
			
			class_active[temp_class]--
			//server_print("SWM > Dec Class in Give1: %i | %i",temp_class,class_active[temp_class])
			class_active[weapon_class_id]++
			//server_print("SWM > Inc Class in Give1: %i | %i",weapon_class_id,class_active[weapon_class_id])
			
			// Handle updating the DoD class menu if the option is enabled.
			if(get_pcvar_num(p_menu_restrict))
				func_set_class_menu(weapon_class_id,temp_class)
		}
		else // No main, decrement last given and inc new
		{
			// Determine spawn or weaponmod class to decrement. If give switch is true, we know our last class was given
			// from the weapons mod so we can decrement the last given class from the weapons mod. If not, we know that
			// the last class given was from the DoD class menu so we decrement the last spawn weapon class. For both
			// we also update our new given class.
			if(client_give_switch[id])
			{
				class_active[client_last_given_class[id]]--
				//server_print("SWM > Dec Class in Give2: %i | %i",client_last_given_class[id],class_active[client_last_given_class[id]])
				class_active[weapon_class_id]++
				//server_print("SWM > Inc Class in Give2: %i | %i",weapon_class_id,class_active[weapon_class_id])
				
				// Handle updating the DoD class menu if the option is enabled.
				if(get_pcvar_num(p_menu_restrict))
					func_set_class_menu(weapon_class_id,client_last_given_class[id])
				
				// Reset weaponmod give switch
				client_give_switch[id] = 0
			}
			else
			{
				class_active[client_last_spawn_class[id]]--
				//server_print("SWM > Dec Class in Give3: %i | %i",client_last_spawn_class[id],class_active[client_last_spawn_class[id]])
				class_active[weapon_class_id]++
				//server_print("SWM > Inc Class in Give3: %i | %i",weapon_class_id,class_active[weapon_class_id])
				
				// Handle updating the DoD class menu if the option is enabled.
				if(get_pcvar_num(p_menu_restrict))
					func_set_class_menu(weapon_class_id,client_last_spawn_class[id])
			}
		}
	}

	// ============================
	// Handle the weapon giving
	// ============================
	// First we drop any primary weapon a client may have then continue to creating new weapon

	// Kill off player current main weapon if they have one
	if(pev_valid(temp_cur_weapon_ent_id))
	{	
		new temp_class_name[17],Float:temp_vuser1[3]
		pev(temp_cur_weapon_ent_id,pev_classname,temp_class_name,16)
		
		// Undeploy any potentially prone deployed weapons We have to force client's to undeploy for now
		// until I can find what needs to be changed to make it work.
		pev(id,pev_vuser1,temp_vuser1)
		if(get_pdata_int(id,152) == 79 && get_pdata_int(id,229) == 1 && temp_vuser1[0] != 2.0)
		{
			client_print(id,print_chat,messages[15])
			return PLUGIN_HANDLED
		}
		// Undeploy any potentially deployed on enity weapons
		if(temp_vuser1[0] == 2.0)
			set_pev(id,pev_vuser1,{ 0.0,0.0,0.0 })
			
		
		// Undeploy any potentially deployed rocket launchers
		set_pdata_int(temp_cur_weapon_ent_id,115,0,4)
		
		// Set the kill state for old primary weapon
		weapon_ent_kill[id] = 1
		
		// Drop primary weapon
		
		engclient_cmd(id,"drop",temp_class_name)
	}
	
	// Store client's weapon choice as an int specific to the weapon_dod_list array. If you didn't notice these are
	// also the same number as DoD numbers it's classes.
	client_chosen_class[id] = weapon_class_id
	
	//////scooped fix
	if(weapon_class_id == 32 || weapon_class_id == 35)
	{
		// Create new primary weapon entity
		new temp_weapon_entity
		temp_weapon_entity = engfunc(EngFunc_CreateNamedEntity,engfunc(EngFunc_AllocString,weapon_dod_list[client_chosen_class[id]]))
		//Make sure entity was created
		if(pev_valid(temp_weapon_entity))
		{
			// Check to see if weapon chosen is scoped enfield or scoped fg42 and make scoped if it is
			set_pdata_int(temp_weapon_entity,115,1,4) // Set entity scope flag true
			
			// Set entity position
			new Float:origin[3]
			pev(id,pev_origin,origin)
			engfunc(EngFunc_SetOrigin,temp_weapon_entity,origin)
				
			// Required as stated in HLSDK - Prevents two guns from showing (weaponbox)
			set_pev(temp_weapon_entity,pev_spawnflags,SF_NORESPAWN)
			
			// Spawn the entity
			dllfunc(DLLFunc_Spawn,temp_weapon_entity)
			/////////////
			// give_item(id, "weapon_fg42")
			// temp_cur_weapon_ent_id = get_pdata_cbase(id, m_rifleItem)
			// set_pdata_int(temp_cur_weapon_ent_id,115,1,4) // Set entity scope flag true
		}
	}
	else 
	{
		give_item (id, weapon_dod_list[weapon_class_id] )
			
		
		// Store weapon entity ID for use with blocking other weapon entities
		client_chosen_weapon_id[id] = weapon_class_id
		
		// Decrement a weapon change from the client's counter
		client_gun_changes[id]--
					
		// Set client chose a weapon for use with blocking other guns on the ground
		client_block_state[id] = 1
		
		// Grab HL timestamp for determining the next time this client can get another gun
		client_give_timer[id] = get_gametime() + get_pcvar_float(p_weapon_delay)
		
		// Set that this client has chosen a weapon from the weapons mod. Used for calculating active classes.
		client_give_switch[id] = 1
		
		// Store client's last given class as the class chosen from the weapons mod. Used for calculating active classes.
		client_last_given_class[id] = client_chosen_class[id]
		
		// Set the client's last spawn class to the chosen weapon from the weapons mod. We
		// do this so the correct class counts are made when a player respawns after using
		// the weapons mod. Essentially we are just injecting the weapons mod given class
		// into the spawn class count handler to save un-needed coding.
		client_last_spawn_class[id] = client_chosen_class[id]
	}
	
	return PLUGIN_CONTINUE
}


// =================================================================================================
// Block any weapons on the ground from being picked up if player doesn't have their chosen yet!
// =================================================================================================
public func_weapon_touch(entity_id1,entity_id2) {
	if(entity_id2 > 0 && entity_id2 < 33 && client_block_state[entity_id2])
	{
		if(get_pdata_cbase(entity_id2, m_rifleItem ) != client_chosen_weapon_id[entity_id2])
		{
			pev(entity_id1,pev_classname,class_name,9)
			if(equal(class_name,"weaponbox"))
			{
				return FMRES_SUPERCEDE
			}
			else
			{
				client_block_state[entity_id2] = 0 // Reset client chose state
			}
		}
	}
	return FMRES_IGNORED
}

// =================================================================================================
// Update DoD class menu
// =================================================================================================
public func_set_class_menu(new_class,old_class) {
	// Since the client's previous class was decremented, we need to update the DoD class menu
	// for that particular class. This basically just resets the class choice from being greyed
	// out and non-selectable for the client. To reduce bandwidth, only update this when it's one
	// under the max to prevent sending extra data to clients.
	if(class_active[old_class] == class_restrictions[old_class]-1)
	{
		set_cvar_num(class_name_list[old_class],class_restrictions[old_class]+1)// Increment class restrictions by 1 since 
		//server_print("SWM > Enable DoD class menu for class: %i | %i",old_class,-1)
	}
					
	// See if we have reached the max for this class and if so then update the DoD class menu. 
	// This greys out the choices in the DoD class menu if the max of that class is reached.
	if(class_active[new_class] == class_restrictions[new_class])
	{
		set_cvar_num(class_name_list[new_class],0)
		//server_print("SWM > Disable DoD class menu for class: %i | %i",new_class,class_restrictions[new_class])
	}
}

// =================================================================================================
// Set max amount of gun changes, reset gun save for ID and set client to be notified of features
// =================================================================================================
public client_connect(id) {
	// Reset gun changes for this client
	client_gun_changes[id] = get_pcvar_num(p_weapon_changes)
	
	// Reset /gunsave state for this client
	client_gunsave[id] = 0
	
	// Set new connecting player notification message state if enabled
	if(get_pcvar_num(p_wm_notify))
		client_notify[id] = 1
		
	// Load classes once on first player to connect
	if(!class_load)
	{
		func_get_restrictions()
		class_load = 1
	}
}

// =================================================================================================
// On spawn, change weapon to chosen if they are using /gunsave and notify of / say command features 
// once if enabled. Also update active spawn classes.
// =================================================================================================
public func_respawn(id) {
	// If restrictions are enabled and player now has a different class then before, decrement old class count and
	// increment new class count. If this is the first time the client spawned, only increment their class.
	if(get_pcvar_num(p_class_restrictions))
	{
		// Store initial spawn class. This is used to trigger the class count in spawn when the class has changed
		// from the previous spawn class
		new temp_weapon_entit_id = get_pdata_cbase(id, m_rifleItem)
		
		if(pev_valid(temp_weapon_entit_id))
		{
			client_spawn_class[id] = get_pdata_int(temp_weapon_entit_id,91)
		
			// Only change class if the classes differ from new to previous
			if(client_spawn_class[id] != client_last_spawn_class[id])
			{
				 // Check to make sure we have a previous class first (AKA not the first spawn of map) as 
				 // we don't need to decrement the previous until we know what it was.
				if(client_last_spawn_class[id] > 0)
				{
					class_active[client_last_spawn_class[id]]--
					//server_print("SWM > Dec Class in Spawn1: %i | %i",client_last_spawn_class[id],class_active[client_last_spawn_class[id]])
					class_active[client_spawn_class[id]]++
					//server_print("SWM > Inc Class in Spawn1: %i | %i",client_spawn_class[id],class_active[client_spawn_class[id]])
				}
				else
				{
					class_active[client_spawn_class[id]]++
					//server_print("SWM > Inc Class in Spawn2: %i | %i",client_spawn_class[id],class_active[client_spawn_class[id]])
				}
			}
		}
		
		// Store client's last spawn class. This is used to trigger the class count in spawn when the class has changed
		// from the initial spawn class.
		client_last_spawn_class[id] = client_spawn_class[id]
		client_gun_changes[id] = get_pcvar_num(p_weapon_changes)
	}
	
	// See if gunsave feature is enabled and if the client is using it, give them their chosen weapon.
	if(get_pcvar_num(p_autospawn_weapon) && client_gunsave[id])
	{
		client_gun_changes[id] = get_pcvar_num(p_weapon_changes)
		func_give_weapon(id,client_chosen_class[id])
	}
		
		
	// Show player notification message once
	if(client_notify[id])
	{
		client_print(id,print_chat,messages[6])
		client_notify[id] = 0
	}
}
// =================================================================================================
// Reset gun changes on client death so if a client's gun changes are used up they can still spawn
// with their chosen gun when using /gunsave
// =================================================================================================
public func_client_death(id,nil) {
	// Reset gun change amount for this client
	client_gun_changes[id] = get_pcvar_num(p_weapon_changes)
}

// =================================================================================================
// Kill off all dropped weapons or just ones when client is given a new weapon from weaponsmod
// =================================================================================================
public func_remove_weapon(id) {
	new class_name[9]
	new owner = pev(id,pev_owner)
	
	if( !(0 < owner <= g_iMaxPlayers) )
		return
	
	if(get_pcvar_num(p_remove_weapons))
	{
		// Remove every single weaponbox
		pev(id,pev_classname,class_name,9)
		if(equal(class_name,"weaponbox"))
		{
			// Kill the weapon entity
			set_pev(id,pev_solid,SOLID_NOT)
			dllfunc(DLLFunc_Think,id)
			set_pev(id,pev_nextthink,get_gametime() + 0.001)
		}
	}
	else
	{
		// Remove old primary weaponboxes only
		pev(id,pev_classname,class_name,9)
		if(weapon_ent_kill[owner] && equal(class_name,"weaponbox"))
		{
			// Set old primary weaponbox to die
			set_pev(id,pev_solid,SOLID_NOT)
			dllfunc(DLLFunc_Think,id)
			set_pev(id,pev_nextthink,get_gametime() + 0.001)
			
			// Reset primary weapon kill state after 2 SetModel passes as this is sufficient
			weapon_ent_kill[owner]++
			if(weapon_ent_kill[owner] == 3)
				weapon_ent_kill[owner] = 0
		}
	}
}

// =================================================================================================
// Get/set class restrictions and load disabled weapons
// =================================================================================================
public func_get_restrictions() {
	// See if we are using server restrictions or weapon mod restrictions
	if(get_pcvar_num(p_class_restrictions))
	{
		if(!get_pcvar_num(p_restriction_type))
		{
			// Get server class limits
			class_restrictions[5]  = get_cvar_num(class_name_list[5])
			class_restrictions[6]  = get_cvar_num(class_name_list[6])
			class_restrictions[7]  = get_cvar_num(class_name_list[7])
			class_restrictions[8]  = get_cvar_num(class_name_list[8])
			class_restrictions[9]  = get_cvar_num(class_name_list[9])
			class_restrictions[10]  = get_cvar_num(class_name_list[10])
			class_restrictions[11]  = get_cvar_num(class_name_list[11])
			class_restrictions[12]  = get_cvar_num(class_name_list[12])
			class_restrictions[17]  = get_cvar_num(class_name_list[17])
			class_restrictions[18]  = get_cvar_num(class_name_list[18])
			class_restrictions[20]  = get_cvar_num(class_name_list[20])
			class_restrictions[21]  = get_cvar_num(class_name_list[21])
			class_restrictions[22]  = get_cvar_num(class_name_list[22])
			class_restrictions[23]  = get_cvar_num(class_name_list[23])
			class_restrictions[24]  = get_cvar_num(class_name_list[24])
			class_restrictions[25]  = get_cvar_num(class_name_list[25])
			class_restrictions[26]  = get_cvar_num(class_name_list[26])
			class_restrictions[27]  = get_cvar_num(class_name_list[27])
			class_restrictions[29]  = get_cvar_num(class_name_list[29])
			class_restrictions[30]  = get_cvar_num(class_name_list[30])
			class_restrictions[31]  = get_cvar_num(class_name_list[31])
			class_restrictions[32]  = get_cvar_num(class_name_list[32])
			class_restrictions[35]  = get_cvar_num(class_name_list[35])
		}
		else
		{
			// Get weapons mod class limits
			class_restrictions[5]  = get_pcvar_num(p_max_garand)
			class_restrictions[6]  = get_pcvar_num(p_max_scopedk98)
			class_restrictions[7]  = get_pcvar_num(p_max_thompson)
			class_restrictions[8]  = get_pcvar_num(p_max_stg44)
			class_restrictions[9]  = get_pcvar_num(p_max_springfield)
			class_restrictions[10]  = get_pcvar_num(p_max_k98)
			class_restrictions[11]  = get_pcvar_num(p_max_bar)
			class_restrictions[12]  = get_pcvar_num(p_max_mp40)
			class_restrictions[17]  = get_pcvar_num(p_max_mg42)
			class_restrictions[18]  = get_pcvar_num(p_max_30cal)
			class_restrictions[20]  = get_pcvar_num(p_max_carbine)
			class_restrictions[21]  = get_pcvar_num(p_max_mg34)
			class_restrictions[22]  = get_pcvar_num(p_max_greasegun)
			class_restrictions[23]  = get_pcvar_num(p_max_fg42)
			class_restrictions[24]  = get_pcvar_num(p_max_k43)
			class_restrictions[25]  = get_pcvar_num(p_max_enfield)
			class_restrictions[26]  = get_pcvar_num(p_max_sten)
			class_restrictions[27]  = get_pcvar_num(p_max_bren)
			class_restrictions[29]  = get_pcvar_num(p_max_bazooka)
			class_restrictions[30]  = get_pcvar_num(p_max_panzerschreck)
			class_restrictions[31]  = get_pcvar_num(p_max_piat)
			class_restrictions[32]  = get_pcvar_num(p_max_scopedfg42)
			class_restrictions[35]  = get_pcvar_num(p_max_scopedenfield)
		}
		
		// Set server starting class limits
		set_cvar_num(class_name_list[5],class_restrictions[5])
		set_cvar_num(class_name_list[6],class_restrictions[6])
		set_cvar_num(class_name_list[7],class_restrictions[7])
		set_cvar_num(class_name_list[8],class_restrictions[8])
		set_cvar_num(class_name_list[9],class_restrictions[9])
		set_cvar_num(class_name_list[10],class_restrictions[10])
		set_cvar_num(class_name_list[11],class_restrictions[11])
		set_cvar_num(class_name_list[12],class_restrictions[12])
		set_cvar_num(class_name_list[17],class_restrictions[17])
		set_cvar_num(class_name_list[18],class_restrictions[18])
		set_cvar_num(class_name_list[20],class_restrictions[20])
		set_cvar_num(class_name_list[21],class_restrictions[21])
		set_cvar_num(class_name_list[22],class_restrictions[22])
		set_cvar_num(class_name_list[23],class_restrictions[23])
		set_cvar_num(class_name_list[24],class_restrictions[24])
		set_cvar_num(class_name_list[25],class_restrictions[25])
		set_cvar_num(class_name_list[26],class_restrictions[26])
		set_cvar_num(class_name_list[27],class_restrictions[27])
		set_cvar_num(class_name_list[29],class_restrictions[29])
		set_cvar_num(class_name_list[30],class_restrictions[30])
		set_cvar_num(class_name_list[31],class_restrictions[31])
		set_cvar_num(class_name_list[32],class_restrictions[32])
		set_cvar_num(class_name_list[35],class_restrictions[35])
	}
	
	// Get disabled weapons
	weapon_disable[5]  = get_pcvar_num(p_disable_garand)
	weapon_disable[6]  = get_pcvar_num(p_disable_scopedk98)
	weapon_disable[7]  = get_pcvar_num(p_disable_thompson)
	weapon_disable[8]  = get_pcvar_num(p_disable_stg44)
	weapon_disable[9]  = get_pcvar_num(p_disable_springfield)
	weapon_disable[10]  = get_pcvar_num(p_disable_k98)
	weapon_disable[11]  = get_pcvar_num(p_disable_bar)
	weapon_disable[12]  = get_pcvar_num(p_disable_mp40)
	weapon_disable[17]  = get_pcvar_num(p_disable_mg42)
	weapon_disable[18]  = get_pcvar_num(p_disable_30cal)
	weapon_disable[20]  = get_pcvar_num(p_disable_carbine)
	weapon_disable[21]  = get_pcvar_num(p_disable_mg34)
	weapon_disable[22]  = get_pcvar_num(p_disable_greasegun)
	weapon_disable[23]  = get_pcvar_num(p_disable_fg42)
	weapon_disable[24]  = get_pcvar_num(p_disable_k43)
	weapon_disable[25]  = get_pcvar_num(p_disable_enfield)
	weapon_disable[26]  = get_pcvar_num(p_disable_sten)
	weapon_disable[27]  = get_pcvar_num(p_disable_bren)
	weapon_disable[29]  = get_pcvar_num(p_disable_bazooka)
	weapon_disable[30]  = get_pcvar_num(p_disable_panzerschreck)
	weapon_disable[31]  = get_pcvar_num(p_disable_piat)
	weapon_disable[32]  = get_pcvar_num(p_disable_scopedfg42)
	weapon_disable[35]  = get_pcvar_num(p_disable_scopedenfield)
	
	return PLUGIN_CONTINUE
}

// =================================================================================================
// Alternate gun saving for a client
// =================================================================================================
public func_gun_save(id) {
	// See if the /gunsave feature is enabled
	if(!get_pcvar_num(p_autospawn_weapon))
		return PLUGIN_HANDLED
	
	// Alternate gun save respawning
	switch(client_gunsave[id])
	{
		case 0: {
			client_print(id,print_chat,messages[7])
			client_gunsave[id] = 1
		}
		case 1: {
			client_print(id,print_chat,messages[8])
			client_gunsave[id] = 0
		}
	}
	return PLUGIN_HANDLED
}

// =================================================================================================
// Help gunlist
// =================================================================================================
public func_help_gunlist(id) {
	if(get_pcvar_num(p_weapon_help) == 1)
	{
		client_print(id,print_chat,messages[9])
		client_print(id,print_chat,messages[10])
		client_print(id,print_chat,messages[11])
	}
	return PLUGIN_HANDLED
}

// =================================================================================================
// Help gunbinding
// =================================================================================================
public func_help_gunbiding(id) {
	if(get_pcvar_num(p_weapon_help) == 1)
	{
		client_print(id,print_chat,messages[12])
		client_print(id,print_chat,messages[13])
		client_print(id,print_chat,messages[14])
	}
	return PLUGIN_HANDLED
}

// =================================================================================================
// Individual weapon give functions - it's done this way to block /weapon spam in chat
// =================================================================================================
public func_garand(id) {
	func_give_weapon(id,5)
	return PLUGIN_HANDLED
}

public func_scopedk98(id) {
	func_give_weapon(id,6)
	return PLUGIN_HANDLED
}

public func_thompson(id) {
	func_give_weapon(id,7)
	return PLUGIN_HANDLED
}

public func_stg44(id) {
	func_give_weapon(id,8)
	return PLUGIN_HANDLED
}

public func_spring(id) {
	func_give_weapon(id,9)
	return PLUGIN_HANDLED
}

public func_k98(id) {
	func_give_weapon(id,10)
	return PLUGIN_HANDLED
}

public func_bar(id) {
	func_give_weapon(id,11)
	return PLUGIN_HANDLED
}

public func_mp40(id) {
	func_give_weapon(id,12)
	return PLUGIN_HANDLED
}

public func_mg42(id) {
	func_give_weapon(id,17)
	return PLUGIN_HANDLED
}

public func_30cal(id) {
	func_give_weapon(id,18)
	return PLUGIN_HANDLED
}

public func_carbine(id) {
	func_give_weapon(id,20)
	return PLUGIN_HANDLED
}

public func_mg34(id) {
	func_give_weapon(id,21)
	return PLUGIN_HANDLED
}

public func_grease(id) {
	func_give_weapon(id,22)
	return PLUGIN_HANDLED
}

public func_fg42(id) {
	func_give_weapon(id,23)
	return PLUGIN_HANDLED
}

public func_k43(id) {
	func_give_weapon(id,24)
	return PLUGIN_HANDLED
}

public func_enfield(id) {
	func_give_weapon(id,25)
	return PLUGIN_HANDLED
}

public func_sten(id) {
	func_give_weapon(id,26)
	return PLUGIN_HANDLED
}

public func_bren(id) {
	func_give_weapon(id,27)
	return PLUGIN_HANDLED
}

public func_bazooka(id) {
	func_give_weapon(id,29)
	return PLUGIN_HANDLED
}

public func_pschreck(id) {
	func_give_weapon(id,30)
	return PLUGIN_HANDLED
}

public func_piat(id) {
	func_give_weapon(id,31)
	return PLUGIN_HANDLED
}

public func_scopedfg42(id) {
	func_give_weapon(id,32)
	return PLUGIN_HANDLED
}


public func_scopedenfield(id) {
	// func_give_weapon(id,35)
	return PLUGIN_HANDLED
}

// =================================================================================================
// Setup gun menu
// =================================================================================================
public func_gun_menu(id) {
	
	if(!get_pcvar_num(p_give_menu))
	{
		client_print(id,print_chat,"[WeaponsMod] The gun menu is currently disabled.")
		return PLUGIN_HANDLED
	}
	
	new gun_menu = menu_create("Gun Menu","func_menu")
	menu_additem(gun_menu,"Garand","1",0)
	menu_additem(gun_menu,"M1 Carbine","2",0)
	menu_additem(gun_menu,"Thompson","3",0)
	menu_additem(gun_menu,"Grease Gun","4",0)
	menu_additem(gun_menu,"Springfield","5",0)
	menu_additem(gun_menu,"BAR","6",0)
	menu_additem(gun_menu,"30cal","7",0)
	menu_additem(gun_menu,"Bazooka","8",0)
	menu_additem(gun_menu,"K98","9",0)
	menu_additem(gun_menu,"K43","10",0)
	menu_additem(gun_menu,"MP40","11",0)
	menu_additem(gun_menu,"STG44","12",0)
	menu_additem(gun_menu,"Scoped K98","13",0)
	menu_additem(gun_menu,"MG34","14",0)
	menu_additem(gun_menu,"MG42","15",0)
	menu_additem(gun_menu,"Panzerschreck","16",0)
	menu_additem(gun_menu,"Fg42","17",0)
	menu_additem(gun_menu,"Scoped Fg42","18",0)
	menu_additem(gun_menu,"Enfield","19",0)
	menu_additem(gun_menu,"Sten","20",0)
	menu_additem(gun_menu,"Scoped Enfield","21",0)
	menu_additem(gun_menu,"Bren","22",0)
	menu_additem(gun_menu,"PIAT","23",0)
	
	// =================================
	// Active /gunsave menu option
	// =================================
	if(get_pcvar_num(p_autospawn_weapon) == 1)
	{
		if (client_gunsave[id] == 0)
		{
			menu_additem(gun_menu,"Enable Gun Save Mode","24",0)
		}
		else
		{
			menu_additem(gun_menu,"Disable Gun Save Mode","24",0)
		}
	}
	
	menu_setprop(gun_menu,MPROP_EXIT,MEXIT_ALL)
	menu_display(id,gun_menu,0)
	return PLUGIN_HANDLED
}

// =================================================================================================
// Handle menu
// =================================================================================================
public func_menu(id,gun_menu,item)
{
	if (item == MENU_EXIT)
	{
		menu_destroy(gun_menu)
		return PLUGIN_HANDLED
	}
	new data[6],iName[64]
	new access,callback
	menu_item_getinfo(gun_menu,item,access,data,5,iName,63,callback)
	new key = str_to_num(data)
	
	switch(key)
	{
		case 1:{
			func_give_weapon(id,5)
		}
		case 2:{
			func_give_weapon(id,20)
		}
		case 3:{
			func_give_weapon(id,7)
		}
		case 4:{
			func_give_weapon(id,22)
		}
		case 5:{ 
			func_give_weapon(id,9)
		}
		case 6:{
			func_give_weapon(id,11)
		}
		case 7:{
			func_give_weapon(id,18)
		}
		case 8:{
			func_give_weapon(id,29)
		}
		case 9:{
			func_give_weapon(id,10)
		}
		case 10:{
			func_give_weapon(id,24)
		}
		case 11:{
			func_give_weapon(id,12)
		}
		case 12:{
			func_give_weapon(id,8)
		}
		case 13:{
			func_give_weapon(id,6)
		}
		case 14:{
			func_give_weapon(id,21)
		}
		case 15:{
			func_give_weapon(id,17)
		}
		case 16:{
			func_give_weapon(id,30)
		}
		case 17:{
			func_give_weapon(id,23)
		}
		case 18:{
			func_give_weapon(id,32)
		}
		case 19:{
			func_give_weapon(id,25)
		}
		case 20:{
			func_give_weapon(id,26)
		}
		case 21:{
			func_give_weapon(id,35)
		}
		case 22:{
			func_give_weapon(id,27)
		}
		case 23:{
			func_give_weapon(id,31)
		}
		case 24:{
			func_gun_save(id)
		}
	}
	menu_destroy(gun_menu)
	return PLUGIN_HANDLED
}

stock dod_set_scoped(id, dValue) {
    new m_iCurEnt = -1, m_iWpnEnt = 0, m_szWpn[32];
    new clip, ammo, m_iWpn = get_user_weapon(id,clip,ammo);
    xmod_get_wpnlogname(m_iWpn, m_szWpn, 31);
    format(m_szWpn, 31, "weapon_%s", m_szWpn);
    if(equal(m_szWpn, "weapon_scoped_enfield")) m_szWpn = "weapon_enfield";
    if(equal(m_szWpn, "weapon_scoped_fg42")) m_szWpn = "weapon_fg42";
    new Float:m_flOrigin[3];
    pev(id, pev_origin, m_flOrigin);
    while((m_iCurEnt = engfunc(EngFunc_FindEntityInSphere, m_iCurEnt, m_flOrigin, Float:1.0)) != 0) {
        new m_szClassname[32];
        pev(m_iCurEnt, pev_classname, m_szClassname, 31);
        if(equal(m_szClassname, m_szWpn))
            m_iWpnEnt = m_iCurEnt;
    }
    set_pdata_int(id,m_iWpnEnt,115, dValue, 4);
}