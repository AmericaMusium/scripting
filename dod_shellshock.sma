//////////////////////////////////////////////////////////////////////////////////
//
//	DoD Shell Shock
//		- Version 2.0
//		- 07.29.2009
//		- diamond-optic
//		- Servers: http://www.game-monitor.com/search.php?rulename=dod_shellshock_stats
//
//////////////////////////////////////////////////////////////////////////////////
//
// Credit:
//
//   - Original Code by v3x (he_damage_effect v0.2)
//   - Ported to DoD by diamond-optic
//   - cadav0r: new volume fx methods and various other fixes
//   - WARDOG: new ringing sound
//   - Emp`: suggestions on cleaning up some bits and pieces
//   - Wilson [29th ID]: PStatus method of catching player spawn
//   - TatsuSaisei: Fix for Wilson's PStatus method
//
// Information:
//
//   - When you take damage from the allowed weapons,
//     You will experiecne a random selection or a
//     combination of various effects.. For example, your
//     screen might be distorted, your sound volume might
//     decrease for a few seconds before it returns to
//     normal. There's also a chance for a ringing sound
//     in your ears, along with little floating dots all
//     around you...There is also an effect that changes
//     the way everything sounds to you (pitch shift/echo/etc).
//     You may even drop your weapon/object/ammo or fall down prone.
//
//   - CVARs to pick which weapons cause effects
//   - Minimum damage required controllable for each one of the effects
//   - Each effect has options to control specific aspects of that effect
//
//   - File consistency is enforced on the shellshock ring sound to
//     prevent people from replacing it with a blank sound file
//
// CVARS:
//
// 	dod_shellshock "1" 			//Turn on(1)/off(0)
//
//	//weapons that cause effects
//	dod_shellshock_wpn_grenades "1"
//	dod_shellshock_wpn_rockets "1"
//	dod_shellshock_wpn_mortars "1"
//	dod_shellshock_wpn_knives "0"
//	dod_shellshock_wpn_spades "0"
//	dod_shellshock_wpn_buttstocks "0"
//	dod_shellshock_wpn_bayonets "0"
//
// Compiler Defines:
//
//	SETTING_WARN		2	//Inconsistent file warning setting
//					//	0 = say nothing
//					//	1 = tell admins
//					//	2 = tell public
//
//	SETTING_WARNACTION	2	//Inconsistent file action setting
//					//	0 = do nothing
//					//	1 = kick
//					//	2 = ban
//
//	SETTING_FILEBANTIME	15	//Inconsistent file ban action length
//
//	SETTING_FILEAMXBANS	0	//Inconsistent file ban action amxbans support
//					//	0 = off
//					//	1 = on
//					//	2 = on, alternate syntax
//
// 	SETTING_FADE		1 	//Turn on(1)/off(0) screen fade effect
// 	SETTING_FADEDMG		30	//Sets the minimum damage required
// 	SETTING_FADEALPHA	100	//Sets the defualt fade alpha level
// 	SETTING_FADEINC		1	//Turn on(1)/off(0) increase of fade alpha level
// 	SETTING_FADEINCDMG	2	//Amount of damage for each step of fade alpha level increase
// 	SETTING_FADEINCAMT	5	//Fade alpha level increase amount per step 
//
// 	SETTING_SHAKE		1	//Turn on(1)/off(0) screen shake effect
// 	SETTING_SHAKEDMG	20	//Sets the minimum damage required
//
//	SETTING_VECTOR		1	//Turn on(1)/off(0) vector effect
// 	SETTING_VECTORDMG	50	//Sets the minimum damage required
// 	SETTING_VECTORAMT	60.0	//Sets the min/max angle of change
//
// 	SETTING_VOLUME		1	//Turn on(1)/off(0) short volume loss effect
// 	SETTING_VOLUMEDMG	65	//Sets the minimum damage required
// 	SETTING_VOLUMETIME1	10	//How long you lose volume (10ths of a second)
// 	SETTING_VOLUMETIME2	10	//Delay between each volume increase step (10ths of a second)
// 	SETTING_VOLUMEINC	1	//Turn on(1)/off(0) increase of volume loss time
// 	SETTING_VOLUMEINCDMG	10	//Amount of damage for each step of vol. loss increase
// 	SETTING_VOLUMEINCTIME	5	//Volume loss increase time per step (10ths of a second) 
//
// 	SETTING_RING		1	//Turn on(1)/off(0) ringing effect
// 	SETTING_RINGDMG		80	//Sets the minimum damage required
//
// 	SETTING_FOV		1	//Turn on(1)/off(0) fov effect
// 	SETTING_FOVDMG		85	//Sets the minimum damage required
//
// 	SETTING_SOUND		1	//Turn on(1)/off(0) soundfx effect
// 	dSETTING_SOUNDDMG	60	//Sets the minimum damage required
// 	SETTING_SOUNDTIME	10.0	//Sets how long the effect lasts (-1 = keep effect till client dies)
//
//	SETTING_DROP		1	//Turn on(1)/off(0) weapon drop effect
//	SETTING_DROPDMG		90	//Sets the minimum damage required
//
//	SETTING_PRONE		1	//Turn on(1)/off(0) forcing prone effect
//	SETTING_PRONEDMG	95	//Sets the minimum damage required
//
//	SETTING_PARTICLES	1	//Turn on(1)/off(0) particle effect (floating dots)
//	SETTING_PARTICLESDMG	20	//Sets the minimum damage required
//
//	SETTING_MAXPLAYERS	32	//Set to the maximum # of players (slot count)
//
// Extra:
//
//      Put the "dod_shellshock_ring.mp3" in /dod/sound/misc/
//
//	If you change the sound file, DO NOT use the same name,
//	change the #define RINGSOUND instead!!!
//
// Changelog:
//
//   - 05.01.2006 Version 0.1
//  	  Initial port of v3x's "he_damage_effect v0.2"
//  	  Added cvar to set min. dmg required
//	  Added Rockets as well as grenades
//
//   - 05.03.2006 Version 0.2
//  	  Added Garand & K43 buttstocks
//
//   - 05.05.2006 Version 0.3
//        Added CVAR for buttstocks
//	  Renamed to DoD Shell Shock
//
//   - 05.06.2006 Version 0.4
//        Removed buttstocks till I do it a better way
//        Changed from MSG_ONE to MSG_ONE_UNRELIABLE
//
//   - 05.10.2006 Version 0.5
//        Added CVARs for fade & shake (code from cadav0r)
//	  Added CVAR for volume
//
//   - 05.12.2006 Version 0.6
//        CVAR query bug fixed (thanks cadav0r)
//	  New method for volume effect (thanks cadav0r)
//	  Fixed volume staying at 0.0 bug
//
//   - 05.15.2006 Version 0.7
//	  Another fix for CVAR query problem
//        Added ringing sound MP3 (still plays during volume effect)
//	  Added CVAR for ringing effect
//	  Added FOV effect (defualts to 0 as im not satisfied with it yet)
//
//   - 05.18.2006 Version 0.7b
//	  Removed global damage cvar and added one for each effect
//
//   - 05.22.2006 Version 0.7c
//	  Fixed run-time error
//	  Adjusted a few random things...
//
//   - 05.24.2006 Version 0.7d
//	  Fixed 2 small errors becuase of my stupidity (thanks cadav0r)
//
//   - 06.09.2006 Version 0.8
//	  Added CVAR for how long you lose your volume
//	  Added CVAR for delay between each volume increase step (thanks cadav0r)
//	  New 'ringing' sound (thanks WARDOG)
//	  Adjusted ScreenFade & ScreenShake message variables
//
//   - 07.06.2006 Version 0.9
//	  Replaced ENGINE module with FAKEMETA module
//	  Fixed volume effect for multiple nade hits (thanks cadav0r)
//	  Added increasing of volume loss time depending on dmg (thanks cadav0r)
//	  Added CVAR for setting the fade effect's defualt alpha level
//	  Added increasing of fade alpha level depending on dmg (cadav0r's method)
//	  Added 4 CVARs to control vector effect settings
//	  Did some more work on the FOV effect, a little bit more satisfied with it
//
//   - 07.09.2006 Version 0.9b
//	  Removed FUN module
//
//   - 07.14.2006 Version 0.9c
//	  Fixed "Missing RIFF/WAVE chunk" console message
//
//   - 08.05.2006 Version 0.9d
//	  Fixed possible problem with ring sound not playing (thanks KidTwisted)
//	  Added RINGSOUND define to make it easy to use a different file
//	  Incase the volume global doesnt get set.. it defualts to 1.0
//	  Cleaned up code a bit...
//
//   - 08.28.2006 Version 1.0
//	  Added mortars, knives, spades, buttstocks, and bayonets
//	  Added CVARs to control which weapons cause the effect
//	  Changed some returns
//
//   - 09.21.2006 Version 1.1
//	  Added public cvar for stats tracking
//
//   - 12.16.2006 Version 1.2
//	  Cleaned up a bunch of things (thanks Emp`)
//
//   - 03.17.2007 Version 1.3
//	  Cleaned up some more things thru the code
//	  Changed the default values for some of the cvars
//	  Now the effects will stop if you die
//	  Improved the effect tasks
//	  Added a new feature: sfx (changes the way everything you hear sounds)
//
//   - 03.19.2007 Version 1.3b
//	  Fixed a typo in the CVAR comment section
//	  More simple way to stop all the effects at once
//	  Tasks are now removed on client disconnect
//	  Changed volume cvar query task from 10sec to 8sec
//	  Removed some plugin active checks (avoids problems when turning it on mid-game)
//	  Added RoundState checks
//
//   - 03.20.2007 Version 1.3c
//	  Removed an extra cvar (dod_shellshock_sfx_stay)
//	  Fixed the sfx effect time stuff
//
//   - 06.13.2007 Version 1.4
//	  Changed the way the cvar query is done (first time client spawns)
//	  Added round draws to roundstate check
//	  Removed some code in the roundstate function
//	  Added drop weapon effect
//	  Added force prone effect
//	  Added 'particle' effect
//	  Few minor code changes/fixes
//	  Replaced high & low vector CVARs with one single new CVAR
//
//   - 07.29.2009 Version 2.0
//	  Added cvar query for client's room_type setting
//	  Improved code for reseting sfx effect
//	  Replaced spawn forward with HamSandwich
//	  Added commands to force/stop shell shock on a player (can be called by other plugins)
//	  Added file consistency on the shellshock sound
//	  Renamed the sound file to start fresh for the file consistency
//	  Adjusted some default times
//	  Another attempt at fixing the 0 volume issue
//	  Replaced DoDx death forward with HamSandwich
//	  Changed alot of the CVARs to compiler defines
//	  Improved task handling
//	  Various code improvements
//	  Added compiler define for setting max players
//
//////////////////////////////////////////////////////////////////////////////////

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <dodx>
#include <hamsandwich>

///////////////////////////////////////////////
// Settings
//
#define SETTING_WARN		2
#define SETTING_WARNACTION	2
#define SETTING_FILEBANTIME	15
#define SETTING_FILEAMXBANS	0

#define SETTING_FADE		1
#define SETTING_FADEDMG		30
#define SETTING_FADEALPHA	100
#define SETTING_FADEINC		1
#define SETTING_FADEINCDMG	2
#define SETTING_FADEINCAMT	5

#define SETTING_SHAKE		1
#define SETTING_SHAKEDMG	20

#define SETTING_VECTOR		1
#define SETTING_VECTORDMG	50
#define SETTING_VECTORAMT	60.0	

#define SETTING_VOLUME		1
#define SETTING_VOLUMEDMG	65
#define SETTING_VOLUMETIME1	10
#define SETTING_VOLUMETIME2	10
#define SETTING_VOLUMEINC	1
#define SETTING_VOLUMEINCDMG	10
#define SETTING_VOLUMEINCTIME	5

#define SETTING_RING		1
#define SETTING_RINGDMG		20

#define SETTING_FOV		1
#define SETTING_FOVDMG		85

#define SETTING_SOUND		1
#define SETTING_SOUNDDMG	60
#define SETTING_SOUNDTIME	10.0

#define SETTING_DROP		1
#define SETTING_DROPDMG		90
	
#define SETTING_PRONE		1
#define SETTING_PRONEDMG	95

#define SETTING_PARTICLES	1
#define SETTING_PARTICLESDMG	20

#define SETTING_MAXPLAYERS	32

//--------------------------------------------------------------------------------
// #define RINGSOUND "sound/misc/dod_shellshock_ring.mp3"	//ring sound fx file

new const RINGSOUND[] = "misc/dod_shellshock_ring.wav"
//--------------------------------------------------------------------------------

#define VERSION "2.0"
#define SVERSION "v2.0 - by diamond-optic (www.AvaMods.com)"

//Task IDs
#define SFX_TASK 21672
#define FOV_TASK 74366
#define VOL_TASK 55183

//Globals
new kick_reason[64]
new Float:gVolume[SETTING_MAXPLAYERS+1] = { 0.0, ... }
new gRoom[SETTING_MAXPLAYERS+1] = { 0, ... }
new volumeup[SETTING_MAXPLAYERS+1],gFov[SETTING_MAXPLAYERS+1]
new bool:g_round_restart = false
new gMsgScreenShake,gMsgScreenFade,gMsgSetFOV,p_dod_shellshock

//PCVARs
new p_grenades,p_rockets,p_mortars,p_knives,p_spades,p_buttstocks,p_bayonets

//Globals for multi-use defines
new set_FadeAlpha = SETTING_FADEALPHA
new set_FadeDMG = SETTING_FADEALPHA
new set_FadeIncDMG = SETTING_FADEINCDMG
new Float:set_VectorAMT = SETTING_VECTORAMT
new set_VolumeDMG = SETTING_VOLUMEDMG
new set_VolumeTime1 = SETTING_VOLUMETIME1
new set_VolumeIncDMG = SETTING_VOLUMEINCDMG
new set_FileBanTime = SETTING_FILEBANTIME


public plugin_init()
{
	register_plugin("DoD Shell Shock",VERSION,"AMXX DoD Team")
	register_cvar("dod_shellshock_stats",SVERSION,FCVAR_SERVER|FCVAR_SPONLY)
	
	//global on/off
	p_dod_shellshock = register_cvar("dod_shellshock","1")
	
	//weapons
	p_grenades = register_cvar("dod_shellshock_wpn_grenades","1")
	p_rockets = register_cvar("dod_shellshock_wpn_rockets","1")
	p_mortars = register_cvar("dod_shellshock_wpn_mortars","1")
	p_knives = register_cvar("dod_shellshock_wpn_knives","0")
	p_spades = register_cvar("dod_shellshock_wpn_spades","0")
	p_buttstocks = register_cvar("dod_shellshock_wpn_buttstocks","0")
	p_bayonets = register_cvar("dod_shellshock_wpn_bayonets","0")
	
	//commands (good for having other plugins create or stop shellshock effects)
	register_concmd("dod_shellshock_start","cmd_shockstart",ADMIN_IMMUNITY,"<nick/#userid> <damage amount> - Shell Shock a client")
	register_concmd("dod_shellshock_stop","cmd_shockstop",ADMIN_IMMUNITY,"<nick/#userid> - Stops Shell Shock on a client")
	
	//messages
	gMsgScreenShake = get_user_msgid("ScreenShake")
	gMsgScreenFade = get_user_msgid("ScreenFade")
	gMsgSetFOV = get_user_msgid("SetFOV")
	
	//forwards
	RegisterHam(Ham_Spawn,"player","func_HamSpawn",1)
	RegisterHam(Ham_Killed,"player","func_HamKilled")
}

////////////////////////////////////////////////////
// Ring Sound file precache
//
public plugin_precache()
{
	// precache_generic(RINGSOUND)
	// enforce(RINGSOUND)
    precache_sound(RINGSOUND);
	
	formatex(kick_reason,63,"inconsistent file: ../%s",RINGSOUND)
}

////////////////////////////////////////////////////
// Client PutInServer function
//
public client_putinserver(id)
{
	if(!is_user_bot(id) && is_user_connected(id))
		{
		gVolume[id] = 0.0
		gRoom[id] = 0
		}
}

////////////////////////////////////////////////////
// Client Disconnect function
//
public client_disconnect(id)
{
	if(!is_user_connected(id) && !is_user_bot(id))
		{
		//volume
		if(task_exists(VOL_TASK+id))
			{
			remove_task(VOL_TASK+id)
			
			volumeup[id] = 0
			}
		
		//fov
		if(task_exists(FOV_TASK+id))
			remove_task(FOV_TASK+id)
			
		//sfx
		if(task_exists(SFX_TASK+id))
			remove_task(SFX_TASK+id)
		}
}

public cvar_result_volume(id,const cvar[],const value[])
{
	if(is_user_connected(id))
		{
		gVolume[id] = str_to_float(value)
	
		if(gVolume[id] < 0.1)
			{
			client_cmd(id,"volume 1.0")
				
			gVolume[id] = 1.0
			}
		}
}

public cvar_result_room(id,const cvar[],const value[])
{
	if(is_user_connected(id) && strlen(value))
		{
		gRoom[id] = str_to_num(value)
		
		if(gRoom[id] == 14 || gRoom[id] == 19)
			{
			gRoom[id] = 0
				
			client_cmd(id,"room_type 0")
			}
		}
}

////////////////////////////////////////////////////
// Spawn hook
//
public func_HamSpawn(id)
{
	if(is_user_connected(id) && !is_user_bot(id) && get_user_team(id))
		{
		if(!gVolume[id])
			{
			query_client_cvar(id,"volume","cvar_result_volume")
			query_client_cvar(id,"room_type","cvar_result_room")
			}
		else
			stop_all_effects(id)
		}
}

////////////////////////////////////////////////////
// Client Death
//
public func_HamKilled(victim,killer,shouldgib)
	if(is_user_connected(victim) && !is_user_bot(victim))
		stop_all_effects(victim)

////////////////////////////////////////////////////
// Client Spawn
//
public client_damage(attacker,victim,damage,wpnindex,hitplace,TA)
{	
	if(!is_user_alive(victim) || is_user_bot(victim) || g_round_restart || !is_user_connected(victim) || !get_pcvar_num(p_dod_shellshock))
		return PLUGIN_CONTINUE
	
	if((get_pcvar_num(p_grenades) && (wpnindex == DODW_HANDGRENADE || wpnindex == DODW_STICKGRENADE || wpnindex == DODW_MILLS_BOMB || wpnindex == DODW_STICKGRENADE_EX || wpnindex == DODW_HANDGRENADE_EX))
		|| (get_pcvar_num(p_rockets) && (wpnindex == DODW_PANZERSCHRECK || wpnindex == DODW_BAZOOKA || wpnindex == DODW_PIAT))
		|| (get_pcvar_num(p_mortars) && (wpnindex == DODW_MORTAR))
		|| (get_pcvar_num(p_knives) && (wpnindex == DODW_AMERKNIFE || wpnindex == DODW_GERKNIFE || wpnindex == DODW_BRITKNIFE))
		|| (get_pcvar_num(p_spades) && (wpnindex == DODW_SPADE))
		|| (get_pcvar_num(p_buttstocks) && (wpnindex == DODW_K43_BUTT || wpnindex == DODW_GARAND_BUTT))
		|| (get_pcvar_num(p_bayonets) && (wpnindex == DODW_KAR_BAYONET || wpnindex == DODW_ENFIELD_BAYONET)))
			shellshock_fx(victim,damage)

	return PLUGIN_CONTINUE
}

////////////////////////////////////////////////////
// Shell Shock Effects
//
public shellshock_fx(id,damage)
{

#if SETTING_RING

	if(damage >= SETTING_RINGDMG)
    {
        emit_sound(id, CHAN_AUTO, RINGSOUND , 1.0, ATTN_NORM, 0, PITCH_NORM);
    }
    		
#endif

#if SETTING_VECTOR
		
	if(damage >= SETTING_VECTORDMG)
		{ 
		new Float:fVec[3]
		new Float:vec_high = set_VectorAMT
		new Float:vec_low = set_VectorAMT * -1
		
		fVec[0] = random_float(vec_low,vec_high)
		fVec[1] = random_float(vec_low,vec_high)
		fVec[2] = random_float(vec_low,vec_high)
		set_pev(id,pev_punchangle,fVec)
		}
		
#endif
		
#if SETTING_SHAKE
		
	if(damage >= SETTING_SHAKEDMG)
		{     
		message_begin(MSG_ONE_UNRELIABLE,gMsgScreenShake,{0,0,0},id)
		write_short(1<<14) //ammount 
		write_short(1<<12) //lasts this long 
		write_short(2<<14) //frequency
		message_end()
		}
		
#endif
	
	
#if SETTING_FADE

	if(damage >= set_FadeDMG)
		{
		new alpha
		
#if SETTING_FADEINC
		
		new inc,IncFadedmg = set_FadeDMG

		while(IncFadedmg < 100)
			{
			++inc
				
			IncFadedmg = set_FadeDMG + (inc * set_FadeIncDMG)
				
			if(damage > set_FadeDMG && damage >= IncFadedmg) 
				alpha = set_FadeAlpha + (inc * SETTING_FADEINCAMT)
				
			else if(damage < (set_FadeDMG + set_FadeIncDMG)) 
				alpha = set_FadeAlpha
			}

#else
			
		alpha = set_FadeAlpha
			
#endif
			
		if(alpha > 255)
			alpha = 255
			
		message_begin(MSG_ONE_UNRELIABLE,gMsgScreenFade,{0,0,0},id)
		write_short(1<<13)  //duraiton  (old - 1<<11)
		write_short(1<<12)  //hold time  (old - 1<<10)
		write_short(0x0002)  //flags  (old - 1<<12)
		write_byte(192) //red
		write_byte(0) //green
		write_byte(0) //blue
		write_byte(alpha) //alpha (160)
		message_end()
		}
		
#endif
	
#if SETTING_VOLUME
	
	if(damage >= set_VolumeDMG)
		{
		if(task_exists(VOL_TASK+id))
			remove_task(VOL_TASK+id)
			
		client_cmd(id,"volume 0")
		volumeup[id] = 0
	
		

#if SETTING_VOLUMEINC
		
		new noVolume2
		new inc,IncVolumedmg = set_VolumeDMG

		while(IncVolumedmg < 100)
			{
			++inc
				
			IncVolumedmg = set_VolumeDMG + (inc * set_VolumeIncDMG)
				
			if(damage > set_VolumeDMG && damage >= IncVolumedmg) 
				noVolume2 = set_VolumeTime1 + (inc * SETTING_VOLUMEINCTIME)
				
			else if(damage < (set_VolumeDMG + set_VolumeIncDMG)) 
				noVolume2 = set_VolumeTime1
			}

#else

		new noVolume2 = set_VolumeTime1

#endif
		
		new Float:noVolumeTime
		noVolumeTime = floatdiv(float(noVolume2),10.0)
		
		set_task(noVolumeTime,"volume_up",VOL_TASK+id)
		}
		
#endif
	
#if SETTING_FOV
	
	if(damage >= SETTING_FOVDMG)
		{
		if(task_exists(FOV_TASK+id))
			remove_task(FOV_TASK+id)
			
		message_begin(MSG_ONE_UNRELIABLE,gMsgSetFOV,{0,0,0},id)
		write_byte(170)
		message_end()
	
		gFov[id] = 170
		
		set_task(0.2,"reset_fov",FOV_TASK+id)
		}
		
#endif
	
#if SETTING_SOUND

	if(damage >= SETTING_SOUNDDMG)
		{
		if(task_exists(SFX_TASK+id))
			remove_task(SFX_TASK+id)
			
		switch(random_num(0,1))
			{
			case 0: {
				client_cmd(id,"room_type 14")
		
				client_cmd(id,"wait;room_delay 0.65;room_feedback 0.6;room_left 8; room_lp 1;room_mod 0.45;room_refl 0.74;room_size 0.8")
				}
			case 1:	{
				client_cmd(id,"room_type 19")
		
				client_cmd(id,"wait;room_delay 20;room_feedback 0.8;room_left 9;room_lp 1;room_mod 0.1;room_refl 0.92;room_size 3.25")			
				}
			}
								
		set_task(SETTING_SOUNDTIME,"reset_sfx",SFX_TASK+id)
		}
		
#endif
		
#if SETTING_DROP
		
	if(damage >= SETTING_DROPDMG)
		client_cmd(id,"-speed;-attack;drop") //-speed;-attack;slot3;+attack;wait;-attack;drop
		
#endif
		
#if SETTING_PRONE
		
	if(damage >= SETTING_PRONEDMG && !dod_get_pronestate(id))
		client_cmd(id,"prone")
		
#endif
		
#if SETTING_PARTICLES
		
	if(damage >= SETTING_PARTICLESDMG)
		{
		new Float:float_origin[3],origin[3]
		pev(id,pev_origin,float_origin)
				
		origin[0] = floatround(float_origin[0])
		origin[1] = floatround(float_origin[1])
		origin[2] = floatround(float_origin[2])
		
		message_begin(MSG_ONE_UNRELIABLE,SVC_TEMPENTITY,origin,id)
		write_byte(TE_LAVASPLASH)
		write_coord(origin[0])
		write_coord(origin[1])
		write_coord(origin[2]-15)
		message_end()	
		}
		
#endif

}

public volume_up(id)
{
	id -= VOL_TASK
	
	if(is_user_bot(id) || !is_user_connected(id))
		return PLUGIN_HANDLED
	  
	new Float:set_value,Float:set_time
	set_value = floatdiv(float(volumeup[id] + 1),10.0)
	set_time = float(SETTING_VOLUMETIME2)
	 
	if(set_time < 1.0)
		set_time = 1.0
		
	set_time = floatdiv(set_time,10.0)
	
	if(set_value < gVolume[id]) 
		{
		client_cmd(id,"volume %f",set_value)
		++volumeup[id]
		set_task(set_time,"volume_up",VOL_TASK+id)
		} 
	else
		{
		client_cmd(id,"volume %f",gVolume[id])
		volumeup[id] = 0
		}
	return PLUGIN_HANDLED
}

public reset_fov(id)
{
	id -= FOV_TASK
   
	if(gFov[id] > 90) 
		{	
		message_begin(MSG_ONE_UNRELIABLE,gMsgSetFOV,{0,0,0},id)
		write_byte(gFov[id])
		message_end()
		
		gFov[id] = gFov[id] - 2
		
		set_task(0.1,"reset_fov",FOV_TASK+id)
		} 
	else
		{ 
		message_begin(MSG_ONE_UNRELIABLE,gMsgSetFOV,{0,0,0},id)
		write_byte(90)
		message_end()
		}
}

public reset_sfx(id)
{
	id -= SFX_TASK
	
	if(is_user_connected(id))
		{	
		client_cmd(id,"room_type %d",gRoom[id])
		
		message_begin(MSG_ONE_UNRELIABLE,gMsgScreenFade,{0,0,0},id)
		write_short(1<<10)  //duraiton
		write_short(1<<10)  //hold time
		write_short(0x0002)  //flags
		write_byte(100) //red
		write_byte(0) //green
		write_byte(0) //blue
		write_byte(100) //alpha
		message_end()
			
		message_begin(MSG_ONE_UNRELIABLE,get_user_msgid("ScreenShake"),{0,0,0},id)
		write_short(1<<12) //ammount 
		write_short(2<<12) //lasts this long 
		write_short(160) //frequency
		message_end()
		}
}

////////////////////////////////////////////////////
// Stop All Effects
//
public stop_all_effects(id)
{
	//ring
	client_cmd(id,"mp3 stop")

	//volume
	if(task_exists(VOL_TASK+id))
		{
		remove_task(VOL_TASK+id)
		
		client_cmd(id,"volume %f",gVolume[id])
		volumeup[id] = 0
		}

	//fov
	if(task_exists(FOV_TASK+id))
		remove_task(FOV_TASK+id)
	
	message_begin(MSG_ONE_UNRELIABLE,gMsgSetFOV,{0,0,0},id)
	write_byte(90)
	message_end()

	//sfx
	if(task_exists(SFX_TASK+id))
		{
		remove_task(SFX_TASK+id)
	
		client_cmd(id,"room_type %d",gRoom[id])
		}
}


public enforce(const file[])
	if(file_exists(file) && equali(RINGSOUND,file))
		force_unmodified(force_exactfile,{0,0,0},{0,0,0},file)

public inconsistent_file(id,const filename[],reason[64])
{
	if(equali(RINGSOUND,filename))
		{
		new nick[32],steamid[32]
		get_user_authid(id,steamid,31)
		get_user_name(id,nick,31)
		new userid = get_user_userid(id)
		
		static output[128]
		format(output,127,"^"%s<%d><%s>^" inconsistent file ^"%s^"",nick,userid,steamid,filename)		
		log_amx("%s",output)	
		
		switch(SETTING_WARN)
			{
			case 1: {
				new players[32],num
				get_players(players,num,"c")
				
				for(new i = 0; i < num; i++)
					{
					new admin_id = players[i]
						
					if(get_user_flags(admin_id) & ADMIN_KICK)
						client_print(admin_id,print_chat,"%s",output)
					}
				}
			case 2: {
				client_cmd(0,"spk ^"fvox/beep^"")
				
				set_hudmessage(random_num(1,255),random_num(1,255),random_num(1,255),0.03,0.4,0,6.0,5.0,0.1,0.2,4)
				show_hudmessage(0,"WARNING!!^n%s^nhas an inconsistent shellshock sound!",nick)
				
				client_print(0,print_chat,"WARNING!! %s has an inconsistent shellshock sound!",nick)
				}
			}
		
		switch(SETTING_WARNACTION)
			{
			case 0: return PLUGIN_HANDLED
			case 1: { server_cmd("amx_kick #%d ^"%s^"",userid,kick_reason); return PLUGIN_HANDLED; }
			case 2: { set_task(3.0,"inconsistent_ban",id); return PLUGIN_HANDLED; }
			}
		}
	
	return PLUGIN_CONTINUE
}

public inconsistent_ban(id)
{
	if((is_user_connected(id) || is_user_connecting(id)) && !is_user_bot(id))
		{
		new nick[32],steamid[32]
		get_user_authid(id,steamid,31)
		get_user_name(id,nick,31)
		new userid = get_user_userid(id)
						
		switch(SETTING_FILEAMXBANS)
			{
			case 0: server_cmd("kick #%d ^"%dm Ban - %s^";wait;banid ^"%d^" ^"%s^";wait;writeid",userid,set_FileBanTime,kick_reason,set_FileBanTime,steamid)
			case 1: server_cmd("amx_ban %d %s %s",set_FileBanTime,steamid,kick_reason)
			case 2: server_cmd("amx_ban %s %d %s",steamid,set_FileBanTime,kick_reason)					
			}
		}
}

////////////////////////////////////////////////////////////////
// CMD: Start Shell Shock Effects
//
public cmd_shockstart(id,level,cid)
{
	if(!cmd_access(id,level,cid,2))
		return PLUGIN_HANDLED

	new player[32],arg_damage[4],damage
	read_argv(1,player,31)
	read_argv(2,arg_damage,3)
	remove_quotes(player)
	damage = str_to_num(arg_damage)
	
	// Search for the Player
	new player_id = cmd_target(id,player,14)

	if(!player_id)
		return PLUGIN_HANDLED

	//do the effects
	shellshock_fx(player_id,damage)

	//only log and such if it wasnt called by the server
	if(id)
		{
		new nameCalled[32],nameAgainst[32]
		new steamCalled[32],steamAgainst[32]
		get_user_name(id,nameCalled,31)
		get_user_authid(id,steamCalled,31)
		get_user_name(player_id,nameAgainst,31)
		get_user_authid(player_id,steamAgainst,31)
		
		// Tell them it succeded
		client_print(id,print_console,"you have shell shocked %s for %d damage...",nameAgainst,damage)

		// Now Log it
		log_amx("%s<%s> shell shocked %s<%s> for %d damage",nameCalled,steamCalled,nameAgainst,steamAgainst,damage)
		}
		
	return PLUGIN_HANDLED
}

////////////////////////////////////////////////////////////////
// CMD: Stop Shell Shock Effects
//
public cmd_shockstop(id,level,cid)
{
	if(!cmd_access(id,level,cid,1))
		return PLUGIN_HANDLED

	new player[32]
	read_argv(1,player,31)
	remove_quotes(player)
	
	// Search for the Player
	new player_id = cmd_target(id,player,14)

	if(!player_id)
		return PLUGIN_HANDLED

	//do the effects
	stop_all_effects(player_id)

	//only log and such if it wasnt called by the server
	if(id)
		{
		new nameCalled[32],nameAgainst[32]
		new steamCalled[32],steamAgainst[32]
		get_user_name(id,nameCalled,31)
		get_user_authid(id,steamCalled,31)
		get_user_name(player_id,nameAgainst,31)
		get_user_authid(player_id,steamAgainst,31)
		
		// Tell them it succeded
		client_print(id,print_console,"you have stopped shell shock effects for %s",nameAgainst)

		// Now Log it
		log_amx("%s<%s> stopped shell shock effects for %s<%s>",nameCalled,steamCalled,nameAgainst,steamAgainst)
		}
		
	return PLUGIN_HANDLED
}
