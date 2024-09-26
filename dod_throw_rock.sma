//////////////////////////////////////////////////////////////////////////////////
//
//	DoD Throw Rocks
//		- Version 1.5
//		- 12.26.2008
//		- diamond-optic
//
//////////////////////////////////////////////////////////////////////////////////
//
// Credits:
//
//	- Zor for the base from 'DoD Smoke Grenade' v0.7a
//	- spq for help with blocking the suicide log message
//	- TatsuSaisei for logging detail messages, custom weapon support
//
//////////////////////////////////////////////////////////////////////////////////
//
// Information:
//
//	- Basically you can now throw rocks around...
//
//	- Hitting another player with the rock does damage (FF depends on dod_throwrocks_ff setting)
//	- Rock will make a footstep sound when it lands.. Confuse the enemy on your location..
//	- Randomly throws 2 different size rocks with slightly different weights & friction
//
//	- Psychostats compatible log messages (registers as a new weapon)
//
//	- Server List: http://www.game-monitor.com/search.php?rulename=dod_throwrocks_stats
//		* Public CVARs got a bit messed up by that screwy steam update *
//
//////////////////////////////////////////////////////////////////////////////////
//
// Commands:
//
//	throw_rock 	//Throw a Rock
//
//////////////////////////////////////////////////////////////////////////////////
//
// CVARs:
//
//	dod_throwrocks "1"			//turn ON(1)/OFF(0)
//
//	dod_throwrocks_admin "1"		//turn ON(1)/OFF(0) admin mode (def. level: immunity)
//	dod_throwrocks_admin_delay "0.5"	//how often an admin can throw a rock (if admin mode = 1)
//
//	dod_throwrocks_dmg "20"			//damage done when a rock hits a player
//
//	dod_throwrocks_delay "2.0"		//how often you can throw a rock (in seconds)
//
//	dod_throwrocks_ff "2"			//determines what rock does in FF situations...
//							//"0" = NO friendly fire no matter what
//							//"1" = ALWAYS friendly fire
//							//"2" = Obeys mp_friendlyfire setting
//
//////////////////////////////////////////////////////////////////////////////////
//
// Extra:
//
//	- If using AMXBans for the file consistency, I recommend that you
//	  check out the following link for a fix for the banning:
//		* http://www.dodplugins.net/forums/showthread.php?t=1421
//
//	- If you run the ps_heatmaps plugin, for creating spatial stats for
//	  creating heatmaps in PsychoStats 3.1+, I recommend that you check out
//	  the following link for a fix for that plugin recreating suicide log msgs
//		* http://www.avamods.com/download.php?view.177
//
//	- I also recommend that you check out one of the following links for fixing
//	  a possible problem that may occur with the DoD Stats & Stats Logging
//	  plugins that come with AMXX (as well as an improved display name)
//		* http://www.dodplugins.net/forums/showthread.php?t=1466
//		* http://www.avamods.com/download.php?view.176
//
//	- Set the admin level needed for 'admin mode' thru the ROCK_ADMIN define (default: immunity)
//
//	- Set the MAX_ROCKS define to set maximum number of rocks existing at one time (default: 32)
//		* Be careful messing with this one...
//		* Setting this too high could make your server vulnerable to crashing
//
//	- The FULL_PRECACHE define controls whether all files are precached or not 
//		* If you find that some sounds dont work, enable this
//		* If you get 'file not precached' errors, enable this
//
//////////////////////////////////////////////////////////////////////////////////
//
// Known Problems:
//
//	- When you kill someone with a rock it still prints in the console that it
//	  was a 'world' kill. But it does send it to the logs as a 'rock'..
//
//	- Sometimes the rock will get stuck in a spot where it doesnt totally come to
//	  rest, you'll see it just spinning around & hear it making the noise over and
//	  over again.. For this problem I added the 'dod_throwrocks_maxlife' cvar so
//	  that if for some reason the rock hasnt been removed by the normal process,
//	  it will be removed when the maxlife time has been reached..
//
//////////////////////////////////////////////////////////////////////////////////
//
// Change Log:
//
//	- 08.10.2006 Version 0.1
//		Initial testing release
//
//	- 11.04.2006 Version 0.1b
//		Added define for max number of rocks at one time
//		Changed way the rock gets 'killed'
//		Added log messages for detailed stats (thanks TatsuSaisei)
//		Added 'admin mode' where admins can have a diff delay time
//		Changed delay times to float values
//
//	- 11.15.2006 Version 1.0
//		Initial non-beta release
//
//	- 11.18.2006 Version 1.1
//		Added CVAR to control how rocks behave with friendly fire
//		Adjusted some of the defualt CVAR values
//		Decreased 'gravity' of both rocks slightly
//
//	- 05.28.2007 Version 1.2
//		Changed some returns
//		Added description to client command
//		Added draw to RoundState hook
//
//	- 06.13.2007 Version 1.3
//		Removed default DoD sounds from precache (dod already precaches them)
//		Added FULL_PRECACHE define to enable precaching of all files
//		Added weaponstats logging for victim's death
//		Fixed bug in setting user kills
//		Various code changes & improvements
//
//	- 11.05.2007 Version 1.4
//		Rock 'owner' no longer changes on hitting a player
//		Fix for annoying sound loop on stuck rock
//
//	- 12.26.2008 Version 1.5
//		Fixed a rare runtime error
//		Added custom weapon support
//		Small code improvements
//		Added PCVAR usage to mp_friendlyfire queries
//		Moved maxlife & removal CVARs to defines
//		Fixed throwing sound covering up weapon fire
//		Removed an unnecessary global
//		Now you cant throw rocks while shooting
//		Added simulated throwing animation
//		Checks for godmode when hitting a player
//		Improved the mathematical side of throwing
//		Changed touch & think forwards over to HamSandwich
//
///////////////////////////////////////////////////////////////////////////////////////

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <dodfun>
#include <dodx>
#include <fun>
#include <hamsandwich>

#define VERSION "1.5"
#define SVERSION "v1.5 - by diamond-optic (www.AvaMods.com)"

/////////////////////////////////////////////////
// FULL PRECACHE   (1=ON/0=OFF)
//
// Enable this if you find that some of
// the sounds dont play or they return
// precache errors.
// 
#define FULL_PRECACHE 0

/////////////////////////////////////////////////
// ROCK SETTINGS
// 
#define ROCK_MAX 32
#define ROCK_LIFE 15.0
#define ROCK_REMOVE 5.0

/////////////////////////////////////////////////
// ADMIN LEVEL SETTING   (for dod_throwrocks_admin)
// 
#define ROCK_ADMIN	ADMIN_IMMUNITY

/////////////////////////////////////////////////
// AVAMODS SERVER   (keep at 0.. fix for my server only)
// 
#define AVAMODS_SERVER 0

/////////////////////////////////////////////////
// Globals
//
new bool:g_round_restart = false
new bool:log_block_state = false
new Float:g_finishTime[1024] = { 0.0, ... }
new Float:g_nextThrow[33] = { 0.0, ... }
new Float:throwing[33] = { 0.0, ... }
new rockCount = 0
new gMsgScreenFade, gMsgDeathMsg, gMsgFrags
new wpnid_rock

new fileNames[17][] =
{
	"models/rockgibs.mdl",
	"weapons/grenthrow.wav",
	"player/pl_dirt1.wav",
	"player/pl_dirt2.wav",
	"player/pl_dirt3.wav",
	"player/pl_dirt4.wav",
	"player/damage1.wav",
	"player/damage2.wav",
	"player/damage3.wav",
	"player/damage4.wav",
	"player/damage5.wav",
	"player/damage6.wav",
	"player/damage7.wav",
	"player/damage8.wav",
	"player/damage9.wav",
	"player/damage10.wav",
	"player/damage11.wav"
}

enum
{
	model,
	throw,
	dirt1,
	dirt2,
	dirt3,
	dirt4,
	damage1,
	damage2,
	damage3,
	damage4,
	damage5,
	damage6,
	damage7,
	damage8,
	damage9,
	damage10,
	damage11
}
//
/////////////////////////////////////////////////
// CVAR Pointers
//
new p_dod_throwrocks
new p_dod_throwrocks_admin, p_dod_throwrocks_admin_delay
new p_dod_throwrocks_dmg, p_dod_throwrocks_delay
new p_dod_throwrocks_ff, p_friendlyfire

///////////////////////////////////////////////////////////////////////////////////////
// Initialization
//
public plugin_init()
{
	//Register plugin
	register_plugin("DoD Throw Rocks",VERSION,"AMXX DoD Team")
	register_cvar("dod_throwrocks_stats",SVERSION,FCVAR_SERVER|FCVAR_SPONLY)	
	
	//Add Custom Weapon Support
	wpnid_rock = custom_weapon_add("Rock",0,"rock")
	
	//Register CVARS
	p_dod_throwrocks = register_cvar("dod_throwrocks","1")					// on/off
	p_dod_throwrocks_admin = register_cvar("dod_throwrocks_admin","1")			// on/off admin mode
	p_dod_throwrocks_admin_delay = register_cvar("dod_throwrocks_admin_delay","0.5")	// delay between throws for admins if admin mode = 1 (in seconds)
	p_dod_throwrocks_dmg = register_cvar("dod_throwrocks_dmg","20")				// how much dmg
	p_dod_throwrocks_delay = register_cvar("dod_throwrocks_delay","2.0")			// delay between throws (in seconds)
	p_dod_throwrocks_ff = register_cvar("dod_throwrocks_ff","2")				// determines how the rocks treat FF
	
	//Register Client Commands
	register_clcmd("throw_rock","throwrock",0,"- Throw a rock")
		
	//Register Event Hooks	
	register_event("RoundState","round_message", "a", "1=1", "1=3", "1=4", "1=5")
	register_message(get_user_msgid("HandSignal"),"block_message")

	//Register Forwards
	RegisterHam(Ham_Think,"info_target","think_rock")	//tell rock how long to live
	RegisterHam(Ham_Touch,"info_target","touch_rock")	//when rock hits things
	register_forward(FM_AlertMessage,"log_block")		//blocks suicide message on rock death

	//get user message ids
	gMsgScreenFade = get_user_msgid("ScreenFade")
	gMsgDeathMsg = get_user_msgid("DeathMsg")
	gMsgFrags = get_user_msgid("Frags")
	
	//Get friendly fire cvar pointer
	p_friendlyfire = get_cvar_pointer("mp_friendlyfire")
}

///////////////////////////////////////////////////////////////////////////////////////
// Pre-Cache the models/sprites/sounds
//
public plugin_precache() 
{
	precache_model(fileNames[model])			//model

#if FULL_PRECACHE == 1
	
	// DoD already precaches these???
	precache_sound(fileNames[throw])			//throwing sound
	precache_sound(fileNames[dirt1])			//dirt sound
	precache_sound(fileNames[dirt2])			//dirt sound
	precache_sound(fileNames[dirt3])			//dirt sound
	precache_sound(fileNames[dirt4])			//dirt sound
	precache_sound(fileNames[damage1])			//damage sound
	precache_sound(fileNames[damage2])			//damage sound
	precache_sound(fileNames[damage3])			//damage sound
	precache_sound(fileNames[damage4])			//damage sound
	precache_sound(fileNames[damage5])			//damage sound
	precache_sound(fileNames[damage6])			//damage sound
	precache_sound(fileNames[damage7])			//damage sound
	precache_sound(fileNames[damage8])			//damage sound
	precache_sound(fileNames[damage9])			//damage sound
	precache_sound(fileNames[damage10])			//damage sound
	precache_sound(fileNames[damage11])			//damage sound

#endif
	
}

//////////////////////////////////////////////////////////////
// Blocks hand signal text
//
public block_message()
{
	new id = get_msg_arg_int(1)
	new Float:gametime = get_gametime()
	
	if(throwing[id] > gametime)
		return PLUGIN_HANDLED
		
	return PLUGIN_CONTINUE
}

///////////////////////////////////////////////////////////////////////////////////////
// start the throw (hand signal animation)
//
public throwrock(id) 
{
	new Float:gametime = get_gametime()
	new button = pev(id,pev_button)
	
	if(!get_pcvar_num(p_dod_throwrocks) || !is_user_alive(id) || g_round_restart || gametime < g_nextThrow[id] || rockCount >= ROCK_MAX || button & IN_ATTACK || button & IN_ATTACK2)
		return PLUGIN_HANDLED
		
	throwing[id] = gametime + 0.5
	client_cmd(id,"signal_backup")
	
	// Make the throw sound
	emit_sound(id,CHAN_BODY,fileNames[throw],0.9,ATTN_NORM,0,PITCH_NORM)
	
	set_task(0.2,"throwrock_real",id)
	
	if(access(id,ROCK_ADMIN) && get_pcvar_num(p_dod_throwrocks_admin))
		g_nextThrow[id] = (gametime + get_pcvar_float(p_dod_throwrocks_admin_delay))
	else
		g_nextThrow[id] = (gametime + get_pcvar_float(p_dod_throwrocks_delay))
	
	return PLUGIN_HANDLED
}

///////////////////////////////////////////////////////////////////////////////////////
// Throw the rock
//
public throwrock_real(id) 
{
	if(!get_pcvar_num(p_dod_throwrocks) || !is_user_alive(id) || !is_user_connected(id) || g_round_restart || rockCount >= ROCK_MAX)
		return PLUGIN_HANDLED
		
	new Float:TumbleVector[3]	
	TumbleVector[0] = random_float(500.0,-500.0)
	TumbleVector[1] = random_float(600.0,-600.0)
	TumbleVector[2] = random_float(350.0,-350.0)
	
	// create the rock
	new rockid = engfunc(EngFunc_CreateNamedEntity,engfunc(EngFunc_AllocString,"info_target"))
	
	if(!rockid)
		return PLUGIN_HANDLED
		
	new Float:vAngle[3],Float:throwAngle[3],Float:limit

	pev(id,pev_v_angle,vAngle)
	throwAngle[0] = vAngle[0] * 6.0
	
	if(throwAngle[0] < 0)
		{
		throwAngle[0] = throwAngle[0] * 0.5
		limit = 750.0
		}

	else
		{
		throwAngle[0] = -(throwAngle[0])
		limit = 1000.0
		}	
	
	new Float:flVel 
	if(throwAngle[0] == 0)
		flVel = 600.0
	else
		flVel = (90.0 - throwAngle[0]) * 5.0

	// limit velocity
	if(flVel > limit)	
		flVel = limit
	
	new Float:PlayerOrigin[3]/*,Float:junk[3]*/,Float:velocity[3],Float:angles[3],Float:forward_angles[3]

	/*
	//get hand origin
	engfunc(EngFunc_GetBonePosition,id,20,PlayerOrigin,junk)
	PlayerOrigin[2] += 15
	*/
	
	pev(id, pev_origin, PlayerOrigin)
	PlayerOrigin[2] += 28
	

	pev(id,pev_v_angle,angles)
	angle_vector(angles,ANGLEVECTOR_FORWARD,forward_angles)
	PlayerOrigin[0] += (forward_angles[0] * 10)
	PlayerOrigin[1] += (forward_angles[1] * 10)
	PlayerOrigin[2] += (forward_angles[2] * 10)
	
	velocity_by_aim(id,floatround(flVel),velocity)

	set_pev(rockid,pev_classname,"dod_rock")	
	set_pev(rockid,pev_origin,PlayerOrigin)
	engfunc(EngFunc_SetModel,rockid,fileNames[model])
		
	set_pev(rockid,pev_movetype,MOVETYPE_BOUNCE)		
	set_pev(rockid,pev_solid,SOLID_BBOX)	
	set_pev(rockid,pev_velocity,velocity)	
	set_pev(rockid,pev_avelocity,TumbleVector)	
	set_pev(rockid,pev_owner,id)	
	
	//new Float:minsize[3],Float:maxsize[3]
	
	if(random_num(1,5) == 1)
		{
		set_pev(rockid,pev_body,0)
		set_pev(rockid,pev_friction,random_float(0.55,0.65))	
		set_pev(rockid,pev_gravity,random_float(0.30,0.40))
		
		/*
		minsize[0]=-5.0
		minsize[1]=-5.0
		minsize[2]=-5.0
		maxsize[0]=5.0
		maxsize[1]=5.0
		maxsize[2]=5.0
		*/
		}
	else
		{
		set_pev(rockid,pev_body,1)
		set_pev(rockid,pev_friction,random_float(0.50,0.60))	
		set_pev(rockid,pev_gravity,random_float(0.25,0.35))
		
		/*
		minsize[0]=-2.0
		minsize[1]=-2.0
		minsize[2]=-2.0
		maxsize[0]=2.0
		maxsize[1]=2.0
		maxsize[2]=2.0
		*/
		}
	
	//set bbox size
	//engfunc(EngFunc_SetSize,rockid,minsize,maxsize)
	
	// Next time to think
	new Float:gametime = get_gametime()
	set_pev(rockid,pev_nextthink,gametime + 1.0)
	
	g_finishTime[rockid] = (gametime + ROCK_LIFE)

	rockCount++
	
	//custom weapon support
	custom_weapon_shot(wpnid_rock,id)
		
	return PLUGIN_HANDLED
}

///////////////////////////////////////////////////////////////////////////////////////
// Have the rock think
//
public think_rock(rockid) 
{	
	if(!get_pcvar_num(p_dod_throwrocks) || !pev_valid(rockid))
		return HAM_IGNORED

	new classname[32]
	pev(rockid,pev_classname,classname,31)
	
	if(equali(classname,"dod_rock"))
		{
		if(!rockid || g_round_restart)
			return HAM_IGNORED
		
		new Float:gametime = get_gametime()
			
		if(gametime < g_finishTime[rockid])
			{
			if(pev(rockid,pev_flags) & FL_PARTIALGROUND) // & FL_ONGROUND)
				{
				new Float:remove_time = gametime + ROCK_REMOVE
		
				set_pev(rockid,pev_nextthink,remove_time)
				g_finishTime[rockid] = remove_time
				}
			else
				set_pev(rockid,pev_nextthink,gametime + 1.0)
				
			}
		else
			{
			engfunc(EngFunc_RemoveEntity,rockid)
			rockCount--
			}
			
		return HAM_SUPERCEDE
		}
		
	return HAM_IGNORED
}

///////////////////////////////////////////////////////////////////////////////////////
// Check if the rock has hit a wall or ground
//
public touch_rock(rockid,object)
{
	if(!get_pcvar_num(p_dod_throwrocks) || !pev_valid(rockid))
		return HAM_IGNORED

	new classname[32]
	pev(rockid,pev_classname,classname,31)
	
	if(equali(classname,"dod_rock"))
		{		
		new obj_classname[32]
		pev(object,pev_classname,obj_classname,31)
	
		new owner = pev(rockid,pev_owner)
	
#if AVAMODS_SERVER
	
		if(equali(obj_classname,"dod_cow") || equali(obj_classname,"dod_cat") || equali(obj_classname,"dod_dog") || equali(obj_classname,"dod_chick") || equali(obj_classname,"dod_rat") || equali(obj_classname,"dod_deer"))
			{
			engfunc(EngFunc_RemoveEntity, rockid)
			rockCount--
			}
		else if(!equali(obj_classname,"player") || !is_user_connected(owner) || get_user_godmode(object))

#else

		if(!equali(obj_classname,"player") || !is_user_connected(owner) || get_user_godmode(object))
		
#endif
		
			{
			// get the current vector
			new Float:NewVector[3]
			pev(rockid, pev_velocity, NewVector)
				
			// add a bit of static friction (slows it down)
			NewVector[0] *= random_float(0.6,0.8)	//0.7
			NewVector[1] *= random_float(0.6,0.8)	//0.7
			NewVector[2] *= random_float(0.6,0.8)	//0.7	
				
			set_pev(rockid,pev_velocity,NewVector)
						
			new Float:currOrigin[3]
			pev(rockid,pev_origin,currOrigin)
	
			new Float:lastOrigin[3]
			lastOrigin[0] = Float:pev(rockid,pev_iuser1)
			lastOrigin[1] = Float:pev(rockid,pev_iuser2)
			lastOrigin[2] = Float:pev(rockid,pev_iuser3)
	
			if(get_distance_f(currOrigin,lastOrigin) < 2.0)
				return HAM_IGNORED
			else
				{
				set_pev(rockid,pev_iuser1,currOrigin[0])
				set_pev(rockid,pev_iuser2,currOrigin[1])
				set_pev(rockid,pev_iuser3,currOrigin[2])
				}
			
			switch(random_num(1, 4))
				{
				case 1:	emit_sound(rockid,CHAN_BODY,fileNames[dirt1],1.0,ATTN_NORM,0,PITCH_NORM)
				case 2:	emit_sound(rockid,CHAN_BODY,fileNames[dirt2],1.0,ATTN_NORM,0,PITCH_NORM)
				case 3:	emit_sound(rockid,CHAN_BODY,fileNames[dirt3],1.0,ATTN_NORM,0,PITCH_NORM)
				case 4:	emit_sound(rockid,CHAN_BODY,fileNames[dirt4],1.0,ATTN_NORM,0,PITCH_NORM)
				}
				
			return HAM_SUPERCEDE
			}
		else if(is_user_connected(object) && is_user_alive(object))
			{	
			//new owner = pev(rockid,pev_owner)
			//set_pev(rockid,pev_owner,object)
				
			new team = get_user_team(owner)
			new other_team = get_user_team(object)
			
			new server_ff = get_pcvar_num(p_friendlyfire)
			new plugin_ff = get_pcvar_num(p_dod_throwrocks_ff)
			
			new damage = get_pcvar_num(p_dod_throwrocks_dmg)
	
			if(pev(object,pev_health) <= damage && (team != other_team || (team == other_team && ((server_ff && plugin_ff == 2) || plugin_ff == 1))))
				{
				switch(random_num(1,11))
					{
					case 1:	emit_sound(object,CHAN_VOICE,fileNames[damage1],1.0,ATTN_NORM,0,PITCH_NORM)
					case 2:	emit_sound(object,CHAN_VOICE,fileNames[damage2],1.0,ATTN_NORM,0,PITCH_NORM)
					case 3:	emit_sound(object,CHAN_VOICE,fileNames[damage3],1.0,ATTN_NORM,0,PITCH_NORM)
					case 4:	emit_sound(object,CHAN_VOICE,fileNames[damage4],1.0,ATTN_NORM,0,PITCH_NORM)
					case 5:	emit_sound(object,CHAN_VOICE,fileNames[damage5],1.0,ATTN_NORM,0,PITCH_NORM)
					case 6:	emit_sound(object,CHAN_VOICE,fileNames[damage6],1.0,ATTN_NORM,0,PITCH_NORM)
					case 7:	emit_sound(object,CHAN_VOICE,fileNames[damage7],1.0,ATTN_NORM,0,PITCH_NORM)
					case 8:	emit_sound(object,CHAN_VOICE,fileNames[damage8],1.0,ATTN_NORM,0,PITCH_NORM)
					case 9:	emit_sound(object,CHAN_VOICE,fileNames[damage9],1.0,ATTN_NORM,0,PITCH_NORM)
					case 10: emit_sound(object,CHAN_VOICE,fileNames[damage10],1.0,ATTN_NORM,0,PITCH_NORM)
					case 11: emit_sound(object,CHAN_VOICE,fileNames[damage11],1.0,ATTN_NORM,0,PITCH_NORM)
					}
				
				switch(random_num(1, 4))
					{
					case 1:	emit_sound(rockid, CHAN_BODY, fileNames[dirt1], 1.0, ATTN_NORM, 0, PITCH_NORM)
					case 2:	emit_sound(rockid, CHAN_BODY, fileNames[dirt2], 1.0, ATTN_NORM, 0, PITCH_NORM)
					case 3:	emit_sound(rockid, CHAN_BODY, fileNames[dirt3], 1.0, ATTN_NORM, 0, PITCH_NORM)
					case 4:	emit_sound(rockid, CHAN_BODY, fileNames[dirt4], 1.0, ATTN_NORM, 0, PITCH_NORM)
					}
						
				log_block_state = true
				user_silentkill(object)
				log_block_state = false
						
				message_begin(MSG_ALL, gMsgDeathMsg,{500, 500, 500}, 0)
				write_byte(owner)
				write_byte(object)
				write_byte(0)
				message_end()
				
				new steam[32], teamname[32], name[32]
				new steam2[32], teamname2[32], name2[32]
				get_user_authid(owner, steam, 31)
				get_user_authid(object, steam2, 31)
				dod_get_pl_teamname(owner, teamname, 31)
				dod_get_pl_teamname(object, teamname2, 31)
				get_user_name(owner, name, 31)
				get_user_name(object, name2, 31)
				new userid = get_user_userid(owner)
				new userid2 = get_user_userid(object)

				new hitplace = random_num(0,6)
				
				//new Float:rockOrigin[3]
				//pev(rockid,pev_origin,rockOrigin)
				//new hitplace = get_closest_hitplace(object,rockOrigin)
									
				log_message("^"%s<%d><%s><%s>^" killed ^"%s<%d><%s><%s>^" with ^"rock^"", name, userid, steam, teamname, name2, userid2, steam2, teamname2)
	
				//custom weapon damage	
				custom_weapon_dmg(wpnid_rock,owner,object,damage,hitplace)
				
				//client_print(0,print_chat,"hitplace: %d",hitplace)

				new kills = dod_get_user_kills(owner) + 1
				dod_set_user_kills(owner,kills,0)
				
				message_begin(MSG_BROADCAST, gMsgFrags, {0,0,0}, 0)
				write_byte(owner)
				write_short(kills)
				message_end()
				}
			else if(team != other_team || (team == other_team && ((server_ff == 1 && plugin_ff == 2) || plugin_ff == 1)))
				{
				new steam[32], teamname[32], name[32]
				get_user_authid(owner, steam, 31)
				dod_get_pl_teamname(owner, teamname, 31)
				get_user_name(owner, name, 31)
				
				message_begin(MSG_ONE_UNRELIABLE,gMsgScreenFade,{0,0,0},object)
				write_short(1<<10)  //duraiton
				write_short(1<<10)  //hold time
				write_short(0x0002)  //flags
				write_byte(192) //red
				write_byte(0) //green
				write_byte(0) //blue
				write_byte(140) //alpha
				message_end()
									
				new hitplace = random_num(1,6)
				
				//new Float:rockOrigin[3]
				//pev(rockid,pev_origin,rockOrigin)
				//new hitplace = get_closest_hitplace(object,rockOrigin)
				
				//custom weapon damage	
				custom_weapon_dmg(wpnid_rock,owner,object,damage,hitplace)
				
				set_pev(object,pev_health, float(pev(object, pev_health) - damage))
							
				switch(random_num(1, 11))
					{
					case 1:	emit_sound(object, CHAN_VOICE, fileNames[damage1], 1.0, ATTN_NORM, 0, PITCH_NORM)
					case 2:	emit_sound(object, CHAN_VOICE, fileNames[damage2], 1.0, ATTN_NORM, 0, PITCH_NORM)
					case 3:	emit_sound(object, CHAN_VOICE, fileNames[damage3], 1.0, ATTN_NORM, 0, PITCH_NORM)
					case 4:	emit_sound(object, CHAN_VOICE, fileNames[damage4], 1.0, ATTN_NORM, 0, PITCH_NORM)
					case 5:	emit_sound(object, CHAN_VOICE, fileNames[damage5], 1.0, ATTN_NORM, 0, PITCH_NORM)
					case 6:	emit_sound(object, CHAN_VOICE, fileNames[damage6], 1.0, ATTN_NORM, 0, PITCH_NORM)
					case 7:	emit_sound(object, CHAN_VOICE, fileNames[damage7], 1.0, ATTN_NORM, 0, PITCH_NORM)
					case 8:	emit_sound(object, CHAN_VOICE, fileNames[damage8], 1.0, ATTN_NORM, 0, PITCH_NORM)
					case 9:	emit_sound(object, CHAN_VOICE, fileNames[damage9], 1.0, ATTN_NORM, 0, PITCH_NORM)
					case 10: emit_sound(object, CHAN_VOICE, fileNames[damage10], 1.0, ATTN_NORM, 0, PITCH_NORM)
					case 11: emit_sound(object, CHAN_VOICE, fileNames[damage11], 1.0, ATTN_NORM, 0, PITCH_NORM)
					}
					
				switch(random_num(1, 4))
					{
					case 1:	emit_sound(rockid, CHAN_BODY, fileNames[dirt1], 1.0, ATTN_NORM, 0, PITCH_NORM)
					case 2:	emit_sound(rockid, CHAN_BODY, fileNames[dirt2], 1.0, ATTN_NORM, 0, PITCH_NORM)
					case 3:	emit_sound(rockid, CHAN_BODY, fileNames[dirt3], 1.0, ATTN_NORM, 0, PITCH_NORM)
					case 4:	emit_sound(rockid, CHAN_BODY, fileNames[dirt4], 1.0, ATTN_NORM, 0, PITCH_NORM)
					}
				}
			else
				{
				switch(random_num(1, 4))
					{
					case 1:	emit_sound(rockid, CHAN_BODY, fileNames[dirt1], 1.0, ATTN_NORM, 0, PITCH_NORM)
					case 2:	emit_sound(rockid, CHAN_BODY, fileNames[dirt2], 1.0, ATTN_NORM, 0, PITCH_NORM)
					case 3:	emit_sound(rockid, CHAN_BODY, fileNames[dirt3], 1.0, ATTN_NORM, 0, PITCH_NORM)
					case 4:	emit_sound(rockid, CHAN_BODY, fileNames[dirt4], 1.0, ATTN_NORM, 0, PITCH_NORM)
					}	
				}
				
			return HAM_SUPERCEDE
			}
		}
	
	return HAM_IGNORED
}

///////////////////////////////////////////////////////////////////////////////////////
// Trap the round message and handle
//
public round_message() 
{
	if(!get_pcvar_num(p_dod_throwrocks))
		return PLUGIN_CONTINUE 
		
	if(read_data(1) == 1)
		{
		g_round_restart = false
		}
	else
		{
		g_round_restart = true
	    
		
		//check to see if there are any rocks out
		//new rockid = engfunc(EngFunc_FindEntityByString,-1,"classname","dod_rock")
		
		new rockid
		while((rockid = engfunc(EngFunc_FindEntityByString,-1,"classname","dod_rock")) > 0)
			{
			if(rockid && pev_valid(rockid))
				{
				engfunc(EngFunc_RemoveEntity,rockid)
				rockCount--
				}
			}
		}
		
	return PLUGIN_CONTINUE
}

///////////////////////////////////////////////////////////////////////////////////////
// Block suicide log
//
public log_block(type,msg[])
	return(log_block_state?FMRES_SUPERCEDE:FMRES_IGNORED)

/*
///////////////////////////////////////////////////////////////////////////////////////
// Get Closest Hitplace Stock
//
stock get_closest_hitplace(id,Float:rockOrigin[3])
{
	new Float:distance = 9999.9
	new hitplace

	for(new i = 1; i < 8; i++)
		{
		new Float:fOrigin[3],Float:angles[3]
		engfunc(EngFunc_GetBonePosition,id,i,fOrigin,angles)
		
		new Float:dist = get_distance_f(rockOrigin,fOrigin)
		
		if(dist < distance)
			{
			distance=dist
			hitplace=i
			}
		}

	return hitplace
}
*/
