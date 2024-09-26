//
//////////////////////////////////////////////////////////////////////////////////
//
// Compiler Defines:
//
//	SETTING_FLOODTIME	2.0	//How many seconds between using 'voice_tripmineup' command
//
//	SETTING_SPREAD		80	//Spread (from the grenade itself)
//	SETTING_SIZEMIN		30	//Minimum tripmine sprite size
//	SETTING_SIZEMAX		80	//Maximum tripmine sprite size
//	SETTING_SPRITES		6	//Number of tripmine sprites created each second
//	SETTING_DURATION	25.0	//How many seconds grenades will give off tripmine
//	SETTING_THINKTIME	1.0	//How many seconds between creating new tripmine puffs
//
//	SETTING_DELAYSTART	2.0	//How many seconds after throw till grenade gives off tripmine
//	SETTING_DELAYTHROW	1.0	//How many seconds to delay between each throw
//
//	SETTING_CHOKE		1	//Turn on(1)/off(0) choking
//	SETTING_CHOKERADIUS	75.0	//Radius from tripmine grenade for choking
//	SETTING_CHOKECHANCE	2	//1 in # chance of playing choking sound
//
//	SETTING_DAMAGE		1	//Turn on(1)/off(0) choke damage
//	SETTING_DAMAGEAMT	33	//Amount of damage given when choking
//	SETTING_DAMAGECHANCE	1	//1 in # chance of giving damage while choking
//
//	SETTING_DAMAGEHIT	1	//Turn on(1)/off(0) hit damage (when grenade hits a player)
//	SETTING_DAMAGEHITAMT	33	//Amount of damage given per hit
//
//	SETTING_MSGJOIN		0	//Shows commands 30 seconds after player has joined the server
//	SETTING_MSGSPAWN	0	//Shows how many tripmine grenades you have when you spawn
//	SETTING_MSGTHROW	1	//Shows how many tripmine grenades you have left after throwing one
//
//	SETTING_WARN		0	//Inconsistent file warning setting
//					//	0 = say nothing
//					//	1 = tell admins
//					//	2 = tell public
//
//	SETTING_WARNACTION	1	//Inconsistent file action setting
//					//	0 = do nothing
//					//	1 = kick
//					//	2 = ban
//
//	SETTING_BANTIME		1	//Inconsistent file ban action length
//
//	SETTING_AMXBANS		0	//Inconsistent file ban action amxbans support
//						//	0 = off
//						//	1 = on
//						//	2 = on, alternate syntax
//
//	SETTING_MAXPLAYERS	32	//Max Player count for your server (keeping at 32 should be fine tho)
//
//	SETTING_MAXTRIPMINE	20	//Sets the max number of tripmine grenades allowed at once 
//					//	* Be careful messing with this one (default setting: 25)
//					//	* Setting this too high could make your server vulnerable to crashing
//
//	FULL_PRECACHE 		1	//Controls whether all files are precached or not 
//					//	* If you find that some sounds dont work, enable this
//					//	* If you get 'file not precached' errors, enable this
///////////////////////////////////////////////////////////////////////////
//


///////////////////////////////////////////////////////////////////////////////////////
// Module Include
//
#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <dodx>
#include <dodfun>
#include <fun>
#include <hamsandwich>

//////////////////////////////////////////////////
// SETTINGS
//
#define SETTING_FLOODTIME	2.0

#define SETTING_SPREAD		80
#define SETTING_SIZEMIN		30
#define SETTING_SIZEMAX		60		
#define SETTING_SPRITES		4
#define SETTING_DURATION	15.0
#define SETTING_THINKTIME	1.0

#define SETTING_DELAYSTART	1.0
#define SETTING_DELAYTHROW	1.0

#define SETTING_CHOKE		1
#define SETTING_CHOKERADIUS	210.0
#define SETTING_CHOKECHANCE	1

#define SETTING_DAMAGE		1
#define SETTING_DAMAGEAMT	5
#define SETTING_DAMAGECHANCE	1

#define SETTING_DAMAGEHIT	1
#define SETTING_DAMAGEHITAMT	20

#define SETTING_MSGJOIN		0
#define SETTING_MSGSPAWN	0
#define SETTING_MSGTHROW	1

#define SETTING_WARN		2
#define SETTING_WARNACTION	2
#define SETTING_BANTIME		15
#define SETTING_AMXBANS		0

#define SETTING_MAXPLAYERS	32

#define SETTING_MAXTRIPMINE	15

/////////////////////////////////////////////////
// FULL PRECACHE   (1=ON/0=OFF)
//
// Enable this if you find that some of
// the sounds dont play or they return
// precache errors.
// 
#define FULL_PRECACHE 0

/////////////////////////////////////////////////
// Debug Mode (1=ON/0=OFF)
//
// this enables the "debug_givetripmine" command
// which will give you +5 tripmine grenades...
// really useful for me when making changes,
// and i guess it could also be useful for
// trying new settings out...
//
#define DEBUG_MODE	0

///////////////////////////////////////////////////////////////////////////////////////
// Version Control
//
#define AUTHOR "AMXX DoD Team"
#define PLUGIN_NAME "DoD Tripmine Grenades 2"
#define VERSION "1.6"
#define SVERSION "v1.6 - by diamond-optic (www.AvaMods.com)"

/////////////////////////////////////////////////
// Globals
//
new tripmine
new playerGrensCount[SETTING_MAXPLAYERS+1]
new bool:log_block_state = false
new bool:g_round_restart = false
new Float:g_nextThrow[SETTING_MAXPLAYERS+1] = { 0.0, ... }
new Float:throwing[SETTING_MAXPLAYERS+1] = { 0.0, ... }
new Float:g_NextSay[SETTING_MAXPLAYERS+1] = { 0.0, ... }
new Float:hitTime[SETTING_MAXPLAYERS+1]
new gMsgDeathMsg,gMsgFrags
new gibs_shrapnel
new tripmineCount = 0
new kick_reason[64]

//Globals for multi-use defines
new Float:flood_time = SETTING_FLOODTIME
new pos_spread = SETTING_SPREAD
new neg_spread = -(SETTING_SPREAD)

#if SETTING_DAMAGE

new tripmine_damage = SETTING_DAMAGEAMT
	
#endif

#if SETTING_DAMAGEHIT

new hit_damage = SETTING_DAMAGEHITAMT

#endif

#if SETTING_WARNACTION == 2

new bantime = SETTING_BANTIME

#endif

/////////////////////////////////////////////////
// Files
//
new fileNames[16][] =
{
	"sprites/tripmine_ia.spr",
	"models/mapmodels/tripmine_grenade.mdl",
	"weapons/grenthrow.wav",
	"weapons/grenpinpull.wav",
	"weapons/grenade_hit1.wav",
	"weapons/grenade_hit2.wav",
	"weapons/grenade_hit3.wav",
	"common/bodysplat.wav",
	"player/sprintgrunts.wav",
	"player/cough1.wav",
	"player/cough2.wav",
	"player/brit_tripmine.wav",
	"player/us_tripmine.wav",
	"player/ger_tripmine.wav",
	"misc/explode_tripmine.wav",
	"models/shrapnel.mdl"
}

enum
{
	sprites,
	model,
	throw,
	pin,
	hit1,
	hit2,
	hit3,
	splat,
	grunt,
	cough1,
	cough2,
	brit_tripmineup,
	us_tripmineup,
	ger_tripmineup,
	explode_tripmine,
	shrapnel
}

///////////////////////////////////////////////////////////////////////////////////////
// CVAR Pointers
//
new p_tripmine,p_friendlyfire
new p_garand,p_carbine,p_thompson,p_grease,p_sniper,p_bar,p_30cal,p_bazooka
new p_kar,p_k43,p_mp40,p_mp44,p_scharf,p_fg42,p_scopedfg,p_mg34,p_mg42,p_panzer
new p_enfield,p_sten,p_marksman,p_bren,p_piat

// Custom Weapon Variable
new wpnid_tripmine

///////////////////////////////////////////////////////////////////////////////////////
// Initialization
//
public plugin_init()
{
	//Register this plugin
	register_plugin(PLUGIN_NAME,VERSION,AUTHOR)
	
	//public tracking cvar
	register_cvar("dod_tripminegrenade2_stats",SVERSION,FCVAR_SERVER|FCVAR_SPONLY)

#if DEBUG_MODE

	//debug command (gives you +5 more tripmines)
	register_concmd("debug_givetripmine","debug_givetripmine",ADMIN_IMMUNITY,"Add 5 tripmine grenades to your total count")

#endif

	//Register Client Commands for this Plugin
	register_clcmd("throw_tripmine","throwtripmine",0,"- Will throw a tripmine grenade") 
	// register_clcmd("voice_tripmine","say_tripmine",0,"- Will yell out ^"Tripmine Em!^"") 

	//Register Event Hooks	
	register_event("RoundState","round_message","a","1=1","1=3","1=4","1=5")
	register_message(get_user_msgid("HandSignal"),"block_message")
	
	//Get Message IDs
	gMsgDeathMsg = get_user_msgid("DeathMsg")
	gMsgFrags = get_user_msgid("Frags")

	//Register Forwards
	RegisterHam(Ham_Spawn,"player","func_HamSpawn",1)
	RegisterHam(Ham_Think,"info_target","draw_tripmine")
	RegisterHam(Ham_Think,"info_target","draw_tripmine")
	RegisterHam(Ham_Touch,"info_target","grenade_touch")
	register_forward(FM_AlertMessage,"block_log")

	//Add Custom Weapon Support
	wpnid_tripmine = custom_weapon_add("Tripmine Grenade",0,"tripmine_grenade")
	
	//Register CVARS
	p_tripmine = register_cvar("dod_tripminegrenades","1")
	
	//Max grenades per class
	p_garand = register_cvar("dod_tripmine_garand","2")
	p_carbine = register_cvar("dod_tripmine_carbine","2")
	p_thompson = register_cvar("dod_tripmine_thompson","2")
	p_grease = register_cvar("dod_tripmine_grease","2")
	p_sniper = register_cvar("dod_tripmine_sniper","2")
	p_bar = register_cvar("dod_tripmine_bar","2") 
	p_30cal = register_cvar("dod_tripmine_30cal","2")
	p_bazooka = register_cvar("dod_tripmine_bazooka","2")
	p_kar = register_cvar("dod_tripmine_kar","2")
	p_k43 = register_cvar("dod_tripmine_k43","2")
	p_mp40 = register_cvar("dod_tripmine_mp40","2")
	p_mp44 = register_cvar("dod_tripmine_mp44","2")
	p_scharf = register_cvar("dod_tripmine_scharfschutze","2")
	p_fg42 = register_cvar("dod_tripmine_fg42","2")
	p_scopedfg = register_cvar("dod_tripmine_scoped_fg42","2")
	p_mg34 = register_cvar("dod_tripmine_mg34","2")
	p_mg42 = register_cvar("dod_tripmine_mg42","2")
	p_panzer = register_cvar("dod_tripmine_panzerjager","2")
	p_enfield = register_cvar("dod_tripmine_enfield","2")
	p_sten = register_cvar("dod_tripmine_sten","2")
	p_marksman = register_cvar("dod_tripmine_marksman","2")
	p_bren = register_cvar("dod_tripmine_bren","2")
	p_piat = register_cvar("dod_tripmine_piat","2")
	
	//Get friendly fire cvar pointer
	p_friendlyfire = get_cvar_pointer("mp_friendlyfire")
}

///////////////////////////////////////////////////////////////////////////////////////
// Pre-Cache the models/sprites/sounds
//
public plugin_precache() 
{
	tripmine = precache_model(fileNames[sprites])		// tripmine sprite
	enforce(fileNames[sprites])
	
	formatex(kick_reason,63,"inconsistent file: ../%s",fileNames[sprites])

	gibs_shrapnel = precache_model(fileNames[shrapnel])

	precache_model(fileNames[model])			// grenade model
	precache_sound(fileNames[pin])				// grenade pin pulling sound
	precache_sound(fileNames[cough1])			// cough
	precache_sound(fileNames[cough2])			// cough
	precache_sound(fileNames[brit_tripmineup])			// voice
	precache_sound(fileNames[us_tripmineup])			// voice
	precache_sound(fileNames[ger_tripmineup])			// voice
	precache_sound(fileNames[explode_tripmine])		// tripmine explode

#if FULL_PRECACHE == 1

	//DoD already precaches???
	precache_sound(fileNames[throw])			// grenade throwing sound
	precache_sound(fileNames[hit1])				// grenade hit sound
	precache_sound(fileNames[hit2])				// grenade hit sound
	precache_sound(fileNames[hit3])				// grenade hit sound
	precache_sound(fileNames[splat])			// splat
	precache_sound(fileNames[grunt])			// grunt

#endif

}

#if SETTING_MSGJOIN

///////////////////////////////////////////////////////////////////////////////////////
// Join Message
//
public client_putinserver(id)
	if(!is_user_bot(id) && get_pcvar_num(p_tripmine)) 
		set_task(30.0, "ShowMsg", id)

public ShowMsg(id)
	if(is_user_connected(id)) 
		client_print(id, print_chat, "DoD Tripmine Grenades ENABLED! Commands: throw_tripmine & voice_tripmine")

#endif	
		
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
public throwtripmine(id) 
{
	new Float:gametime = get_gametime()	
	new button = pev(id,pev_button)
	
	if(!playerGrensCount[id] || button & IN_ATTACK || button & IN_ATTACK2 || gametime < g_nextThrow[id] || g_round_restart || tripmineCount >= SETTING_MAXTRIPMINE || !is_user_alive(id) || !get_pcvar_num(p_tripmine))
		return PLUGIN_HANDLED
		
	throwing[id] = gametime + 0.5
	client_cmd(id,"signal_areaclear")
	
	emit_sound(id,CHAN_ITEM,fileNames[pin],1.0,ATTN_NORM,0,PITCH_NORM + random_num(-30, -20))
	
	set_task(0.2,"throwtripmine_real",id)
	
	g_nextThrow[id] = (gametime + SETTING_DELAYTHROW)
	
	return PLUGIN_HANDLED
}
		
///////////////////////////////////////////////////////////////////////////////////////
// Throw the actual grenade
//
public throwtripmine_real(id) 
{
	if(!playerGrensCount[id] || g_round_restart || tripmineCount >= SETTING_MAXTRIPMINE || !is_user_alive(id) || !is_user_connected(id) || !get_pcvar_num(p_tripmine))
		return PLUGIN_HANDLED
		
	new Float:TumbleVector[3]
					
	TumbleVector[0] = random_float(450.0,-450.0)
	TumbleVector[1] = random_float(600.0,-600.0)
	TumbleVector[2] = random_float(300.0,-300.0)

	// create the grenade
	new grenid = engfunc(EngFunc_CreateNamedEntity,engfunc(EngFunc_AllocString,"info_target"))

	if(!grenid)
		return PLUGIN_HANDLED

	// calculate how hard to throw the grenade based on the aim angle
	new Float:vAngle[3],Float:throwAngle[3],Float:punchAngle[3]

	pev(id,pev_v_angle,vAngle)
	pev(id,pev_punchangle,punchAngle)
	throwAngle[0] = vAngle[0] + punchAngle[0] * 7.0

	if(throwAngle[0] < 0) 
		throwAngle[0] = -10.0 + throwAngle[0] * 2.0 //((90 - 10) / 90.0)
	else
		throwAngle[0] = -10.0 + throwAngle[0] * 0.5 //((90 + 10) / 90.0)

	new Float:flVel = (90 - throwAngle[0]) * 6.0

	// limit out velocity
	if(flVel > 900.0)	
		flVel = 900.0
	
	new Float:PlayerOrigin[3],Float:velocity[3],Float:angles[3],Float:forward_angles[3]

	//get hand origin
	//engfunc(EngFunc_GetBonePosition,id,20,PlayerOrigin,junk)
	//PlayerOrigin[2] += 12
	
	pev(id,pev_origin,PlayerOrigin)
	PlayerOrigin[2] += 32
	
	pev(id,pev_v_angle,angles)
	angle_vector(angles,ANGLEVECTOR_FORWARD,forward_angles)
	PlayerOrigin[0] += (forward_angles[0] * 10)
	PlayerOrigin[1] += (forward_angles[1] * 10)
	PlayerOrigin[2] += (forward_angles[2] * 10)
	
	velocity_by_aim(id,floatround(flVel),velocity)
	
	set_pev(grenid,pev_classname,"dod_tripmine")	
	set_pev(grenid,pev_origin,PlayerOrigin)
	engfunc(EngFunc_SetModel,grenid,fileNames[model])
	set_pev(grenid,pev_movetype,MOVETYPE_BOUNCE)	
	set_pev(grenid,pev_solid,SOLID_BBOX)	
	set_pev(grenid,pev_friction,0.65)	
	set_pev(grenid,pev_gravity,0.45)	
	set_pev(grenid,pev_velocity,velocity)	
	set_pev(grenid,pev_avelocity,TumbleVector)	
	set_pev(grenid,pev_owner,id)	
	
	new Float:start_delay = get_gametime() + SETTING_DELAYSTART
	set_pev(grenid,pev_nextthink,start_delay)
	set_pev(grenid,pev_fuser1,start_delay + SETTING_DURATION)

	set_pev(grenid,pev_iuser1,true)
	
	//set the nade's bbox size... still needs more work...
	//new Float:mina[3], Float:maxa[3]			
	//mina[0]=-2.0
	//mina[1]=-3.0
	//mina[2]=0.0
	//maxa[0]=2.0
	//maxa[1]=3.0
	//maxa[2]=2.0
	//set_pev(grenid, pev_size, mina, maxa)

	playerGrensCount[id]--
	tripmineCount++

#if SETTING_MSGTHROW
	
	client_print(id, print_chat,"You have %d Tripmine %s left...",playerGrensCount[id],(playerGrensCount[id] != 1) ? "Grenades" : "Grenade")

#endif
	
	//custom weapon support
	custom_weapon_shot(wpnid_tripmine,id)
	
	// Make the throw sound
	emit_sound(id,CHAN_BODY,fileNames[throw],0.9,ATTN_NORM,0,PITCH_NORM + random_num(-30, -20))
	
	return PLUGIN_HANDLED
}

//////////////////////////////////////////////////////////
// Allows players to Yell Out TRIPMINE UP!
//
public say_tripmine(id)
{
	if(!is_user_alive(id))
		return PLUGIN_HANDLED
				
	new Float:current_time = get_gametime()
		
	// check for exessive spamming
	if(g_NextSay[id] > current_time)
		{
		g_NextSay[id] = current_time + (flood_time * 2)
		
		//client_print(id, print_chat, "Chill out, you're flooding the server!")
		
		return PLUGIN_HANDLED
		}
	
	g_NextSay[id] = current_time + flood_time
	
	new sound_to_play = 0
	new team = get_user_team(id)

	// Check if its Allies, If so is it a brit map?
	if(team == 1 && dod_get_map_info(MI_ALLIES_TEAM))
		sound_to_play = brit_tripmineup
		
	else if(team == 1)
		sound_to_play = us_tripmineup
		
	else
		sound_to_play = ger_tripmineup
	
	
	emit_sound(id,CHAN_VOICE,fileNames[sound_to_play],0.8,ATTN_NORM,0,PITCH_NORM + random_num(-30, -20))
		
	client_cmd(id,"say_team Tripmine Em!")
		
	return PLUGIN_HANDLED 
}

///////////////////////////////////////////////////////////////////////////////////////
// Make the grenade generate tripmine
//
public draw_tripmine(grenid) 
{	
	if(!pev_valid(grenid))
		return HAM_IGNORED
	
	static classname[32]
	pev(grenid,pev_classname,classname,31)
	
	if(equali(classname,"dod_tripmine") && !g_round_restart)
		{
		new Float:gametime = get_gametime()
		
		if(gametime < pev(grenid,pev_fuser1))
			{
			if(pev(grenid,pev_iuser1))
				{
				emit_sound(grenid,CHAN_WEAPON,fileNames[explode_tripmine],0.8,ATTN_NORM,0,PITCH_NORM-70)
				set_pev(grenid,pev_iuser1,false)
						
				new Float:origin[3],iOrigin[3]
				pev(grenid,pev_origin,origin)
				
				iOrigin[0] = floatround(origin[0])
				iOrigin[1] = floatround(origin[1])
				iOrigin[2] = floatround(origin[2])+2
						
				message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
				write_byte(TE_SPARKS)
				write_coord(iOrigin[0])
				write_coord(iOrigin[1])
				write_coord(iOrigin[2])
				message_end()
				
				message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
				write_byte(TE_DLIGHT)
				write_coord(iOrigin[0])
				write_coord(iOrigin[1])
				write_coord(iOrigin[2])
				write_byte(5)
				write_byte(12)
				write_byte(252)
				write_byte(199)
				write_byte(2)
				write_byte(25)
				message_end()
				
				message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
				write_byte(TE_BREAKMODEL)
				write_coord(iOrigin[0])
				write_coord(iOrigin[1])
				write_coord(iOrigin[2]+3)
				write_coord(5)
				write_coord(5)
				write_coord(5)
				write_coord(random_num(-40,40))
				write_coord(random_num(-40,40))
				write_coord(random_num(10,100))
				write_byte(10)
				write_short(gibs_shrapnel)
				write_byte(random_num(3,6))
				write_byte(25)
				write_byte(0x02)
				message_end()
				}
			else
				{
				//bring in some tripmine..
				make_tripmine(grenid,SETTING_SPRITES)
	
#if SETTING_CHOKE

				// Do the damage & choke
				funcDamageChoke(grenid)
				
#endif

				}
	
			// Set the next think
			set_pev(grenid,pev_nextthink,gametime + SETTING_THINKTIME)
			}
		else
			{
			// trigger removal and re-use of the grenade as per the delay setting
			engfunc(EngFunc_RemoveEntity,grenid)
			
			tripmineCount--
			}
			
		return HAM_SUPERCEDE
		}
	
	return HAM_IGNORED

}

///////////////////////////////////////////////////////////////////////////////////////
// Make Tripmine
//
make_tripmine(grenid,count)
{
	new Float:GrenOrigin[3],iOrigin[3]
	pev(grenid,pev_origin,GrenOrigin)
	
	iOrigin[0] = floatround(GrenOrigin[0])
	iOrigin[1] = floatround(GrenOrigin[1])
	iOrigin[2] = floatround(GrenOrigin[2])
	
	for(new i=0; i < count; i++)
		{	
		// Start the message
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY, iOrigin)
		write_byte(TE_tripmine)
		write_coord(iOrigin[0] + random_num(neg_spread,pos_spread))
		write_coord(iOrigin[1] + random_num(neg_spread,pos_spread))
		write_coord(iOrigin[2] + random_num(neg_spread,pos_spread))
		write_short(tripmine)
		write_byte(random_num(SETTING_SIZEMIN,SETTING_SIZEMAX))
		write_byte(random_num(3,8))
		message_end()
		// End the message
		}
}

#if SETTING_CHOKE

///////////////////////////////////////////////////////////////////////////////////////
// Check for Damage/Choking
//
public funcDamageChoke(grenid)
{
	new Float:GrenOrigin[3],ent = -1
	pev(grenid,pev_origin,GrenOrigin)
			
	while((ent = engfunc(EngFunc_FindEntityInSphere,ent,GrenOrigin,SETTING_CHOKERADIUS)) != 0)
		{
		new classname[32]
		pev(ent,pev_classname,classname,31)
		
		if(equali(classname,"player") && is_user_alive(ent) && !get_user_godmode(ent))
			{
			if(random_num(1,SETTING_CHOKECHANCE) == 1)
				emit_sound(ent,CHAN_VOICE,fileNames[random_num(cough1, cough2)],0.8,ATTN_NORM,0,PITCH_NORM + random_num(-30, -20))		
	
#if SETTING_DAMAGE

			if(random_num(1,SETTING_DAMAGECHANCE) == 1)
				{				
				new grenade_owner = pev(grenid,pev_owner)
				
				if(!is_user_connected(grenade_owner))
					return PLUGIN_HANDLED
				
				new attacker_team = get_user_team(grenade_owner)
				new victim_team = get_user_team(ent)
				
				if(attacker_team != victim_team || (attacker_team == victim_team && get_pcvar_num(p_friendlyfire)))
					{
					new current_health = pev(ent,pev_health)
	
					if(current_health > tripmine_damage)
						{							
						emit_sound(ent,CHAN_VOICE,fileNames[random_num(cough1,cough2)],0.6,ATTN_NORM,0,PITCH_NORM + random_num(-30, -20))
						emit_sound(ent,CHAN_BODY,fileNames[grunt],1.0,ATTN_NORM,0,PITCH_NORM + random_num(-30, -20))
						
						set_pev(ent,pev_health,float(current_health - tripmine_damage))
						
						//custom weapon damage	
						custom_weapon_dmg(wpnid_tripmine,grenade_owner,ent,tripmine_damage,HIT_CHEST)
						}
					else
						{
						emit_sound(ent,CHAN_VOICE,fileNames[random_num(cough1,cough2)],0.6,ATTN_NORM,0,PITCH_NORM + random_num(-30, -20))
						emit_sound(ent,CHAN_BODY,fileNames[grunt],1.0,ATTN_NORM,0,PITCH_NORM + random_num(-30, -20))
							
						log_block_state = true
						user_silentkill(ent)
						log_block_state = false
						
						message_begin(MSG_ALL,gMsgDeathMsg,{0,0,0},0)
						write_byte(grenade_owner)
						write_byte(ent)
						write_byte(0)
						message_end()
		
						new steam[32],teamname[32],name[32]
						new steam2[32],teamname2[32],name2[32]
						get_user_authid(grenade_owner,steam,31)
						get_user_authid(ent,steam2,31)
						dod_get_pl_teamname(grenade_owner,teamname,31)
						dod_get_pl_teamname(ent,teamname2,31)
						get_user_name(grenade_owner,name,31)
						get_user_name(ent,name2,31)
						
						log_message("^"%s<%d><%s><%s>^" killed ^"%s<%d><%s><%s>^" with ^"tripmine_grenade^"", name, get_user_userid(grenade_owner), steam, teamname, name2, get_user_userid(ent), steam2, teamname2)
					
						//custom weapon damage	
						custom_weapon_dmg(wpnid_tripmine,grenade_owner,ent,tripmine_damage,HIT_CHEST)

						new kills = dod_get_user_kills(grenade_owner) + 1
						dod_set_user_kills(grenade_owner, kills,0)
						
						message_begin(MSG_BROADCAST,gMsgFrags,{0,0,0},0)
						write_byte(grenade_owner)
						write_short(kills)
						message_end()
						}					
					}
				}
				
#endif
				
			}
		}
		
	return PLUGIN_HANDLED
}

#endif

///////////////////////////////////////////////////////////////////////////////////////
// Check if the grenade has hit a wall or ground
//
public grenade_touch(grenid,object)
{
	if(!pev_valid(grenid) || !get_pcvar_num(p_tripmine))
		return HAM_IGNORED
	
	new classname[32]
	pev(grenid,pev_classname,classname,31)
	
	if(equali(classname,"dod_tripmine"))
		{		
		new obj_classname[32]
		pev(object,pev_classname,obj_classname,31)
		
		//get the current vector
		new Float:NewVector[3]
		pev(grenid,pev_velocity,NewVector)
			
		//add a bit of static friction
		NewVector[0] *= 0.7
		NewVector[1] *= 0.7
		NewVector[2] *= 0.7	
		set_pev(grenid,pev_velocity,NewVector)
		
		new Float:gametime = get_gametime()
		
		if(!equali(obj_classname,"player"))
			{
			new Float:currOrigin[3]
			pev(grenid,pev_origin,currOrigin)
	
			new Float:lastOrigin[3]
			lastOrigin[0] = Float:pev(grenid,pev_fuser2)
			lastOrigin[1] = Float:pev(grenid,pev_fuser3)
			lastOrigin[2] = Float:pev(grenid,pev_fuser4)
	
			if(get_distance_f(currOrigin,lastOrigin) < 2.0)
				return HAM_IGNORED
			else
				{
				set_pev(grenid,pev_fuser2,currOrigin[0])
				set_pev(grenid,pev_fuser3,currOrigin[1])
				set_pev(grenid,pev_fuser4,currOrigin[2])
				}
				
			// play bounce sound
			switch(random_num(0,2))
				{
				case 0:	emit_sound(grenid,CHAN_ITEM,fileNames[hit1],0.3,ATTN_NORM,0,PITCH_NORM-50)
				case 1:	emit_sound(grenid,CHAN_ITEM,fileNames[hit2],0.3,ATTN_NORM,0,PITCH_NORM-20)
				case 2:	emit_sound(grenid,CHAN_ITEM,fileNames[hit3],0.3,ATTN_NORM,0,PITCH_NORM-30)
				}
				
			return HAM_SUPERCEDE
			}
		else if(gametime > hitTime[object] && is_user_alive(object) && is_user_connected(object))
			{
			hitTime[object] = gametime + 1.2	
			
			new grenade_owner = pev(grenid,pev_owner)
			
			if(!is_user_connected(grenade_owner))
				return HAM_IGNORED
				
#if SETTING_DAMAGEHIT
			
			new attacker_team = get_user_team(grenade_owner)
			new victim_team = get_user_team(object)
			
			new friendlyfire = 0
			if(attacker_team == victim_team)
				friendlyfire = 1
			
			if((!friendlyfire || (friendlyfire && get_pcvar_num(p_friendlyfire))) && !get_user_godmode(object))
				{
				new current_health = pev(object,pev_health)
				
				if(current_health > hit_damage)
					{					
					set_pev(object,pev_health,float(current_health - hit_damage))
					
					new steam[32],teamname[32],name[32]
					get_user_authid(grenade_owner,steam,31)
					dod_get_pl_teamname(grenade_owner,teamname,31)
					get_user_name(grenade_owner,name,31)

					new hitplace = random_num(1,6)
	
					//custom weapon damage	
					custom_weapon_dmg(wpnid_tripmine,grenade_owner,object,hit_damage,hitplace)
	
					}
				else
					{
					log_block_state = true
					user_silentkill(object)
					log_block_state = false
					
					message_begin(MSG_ALL,gMsgDeathMsg,{0,0,0},0)
					write_byte(grenade_owner)
					write_byte(object)
					write_byte(0)
					message_end()
	
					new steam[32],teamname[32],name[32]
					new steam2[32],teamname2[32],name2[32]
					get_user_authid(grenade_owner,steam,31)
					get_user_authid(object,steam2,31)
					dod_get_pl_teamname(grenade_owner,teamname,31)
					dod_get_pl_teamname(object,teamname2,31)
					get_user_name(grenade_owner,name,31)
					get_user_name(object,name2,31)
					new userid = get_user_userid(grenade_owner)
					new userid2 = get_user_userid(object)
						
					new hitplace = random_num(0,6)

					log_message("^"%s<%d><%s><%s>^" killed ^"%s<%d><%s><%s>^" with ^"tripmine_grenade^"",name,userid,steam,teamname,name2,userid2,steam2,teamname2)

					//custom weapon damage	
					custom_weapon_dmg(wpnid_tripmine,grenade_owner,object,hit_damage,hitplace)

					new kills = dod_get_user_kills(grenade_owner) + 1
					dod_set_user_kills(grenade_owner,kills,0)
					
					message_begin(MSG_BROADCAST,gMsgFrags,{0,0,0},0)
					write_byte(grenade_owner)
					write_short(kills)
					message_end()
					}
						
				emit_sound(grenid,CHAN_BODY,fileNames[splat],0.8,ATTN_NORM,0,PITCH_NORM + random_num(-30, -20))
				emit_sound(grenid,CHAN_ITEM,fileNames[hit1],0.6,ATTN_NORM,0,PITCH_NORM + random_num(-30, -20))
		
				emit_sound(object,CHAN_VOICE,fileNames[grunt],1.0,ATTN_NORM,0,PITCH_NORM + random_num(-30, -20))
				}
			else
				{				
				switch(random_num(0,2))
					{
					case 0:	emit_sound(grenid,CHAN_ITEM,fileNames[hit1],0.8,ATTN_NORM,0,PITCH_NORM + random_num(-30, -20))
					case 1:	emit_sound(grenid,CHAN_ITEM,fileNames[hit2],0.8,ATTN_NORM,0,PITCH_NORM + random_num(-30, -20))
					case 2:	emit_sound(grenid,CHAN_ITEM,fileNames[hit3],0.8,ATTN_NORM,0,PITCH_NORM + random_num(-30, -20))
					}	
				}
				
#else

			switch(random_num(0,2))
				{
				case 0:	emit_sound(grenid,CHAN_ITEM,fileNames[hit1],0.8,ATTN_NORM,0,PITCH_NORM + random_num(-30, -20))
				case 1:	emit_sound(grenid,CHAN_ITEM,fileNames[hit2],0.8,ATTN_NORM,0,PITCH_NORM + random_num(-30, -20))
				case 2:	emit_sound(grenid,CHAN_ITEM,fileNames[hit3],0.8,ATTN_NORM,0,PITCH_NORM + random_num(-30, -20))
				}

#endif
				
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
	if(read_data(1) == 1)
		g_round_restart = false
	else
		{	
		g_round_restart = true
		    
		new grenid		
		while((grenid = engfunc(EngFunc_FindEntityByString, -1,"classname","dod_tripmine")) > 0)
			{
			emit_sound(grenid,CHAN_WEAPON,fileNames[explode_tripmine],0.75,ATTN_NORM,SND_STOP,PITCH_NORM + random_num(-30, -20))
		    
			if(task_exists(grenid))
				remove_task(grenid)
			
			engfunc(EngFunc_RemoveEntity,grenid)
			tripmineCount--
			}
		}
}

///////////////////////////////////////////////////////////////////////////////////////
// client spawn
//
public func_HamSpawn(id)
	if(is_user_alive(id) && !is_user_bot(id) && get_user_team(id) && is_user_connected(id) && get_pcvar_num(p_tripmine))
		give_tripmine(id)

///////////////////////////////////////////////////////////////////////////////////////
// Give tripmine nades
//
give_tripmine(id)
{
	new team = get_user_team(id)
	
	if(team == ALLIES)
		{
		switch(dod_get_user_class(id))
			{
			case DODC_GARAND: playerGrensCount[id] = get_pcvar_num(p_garand)
			case DODC_CARBINE: playerGrensCount[id] = get_pcvar_num(p_carbine)
			case DODC_THOMPSON: playerGrensCount[id] = get_pcvar_num(p_thompson) 
			case DODC_GREASE: playerGrensCount[id] = get_pcvar_num(p_grease) 
			case DODC_SNIPER: playerGrensCount[id] = get_pcvar_num(p_sniper) 
			case DODC_BAR: playerGrensCount[id] = get_pcvar_num(p_bar) 
			case DODC_30CAL: playerGrensCount[id] = get_pcvar_num(p_30cal) 
			case DODC_BAZOOKA: playerGrensCount[id] = get_pcvar_num(p_bazooka)
			case DODC_ENFIELD: playerGrensCount[id] = get_pcvar_num(p_enfield) 
			case DODC_STEN: playerGrensCount[id] = get_pcvar_num(p_sten) 
			case DODC_MARKSMAN: playerGrensCount[id] = get_pcvar_num(p_marksman) 
			case DODC_BREN: playerGrensCount[id] = get_pcvar_num(p_bren) 
			case DODC_PIAT: playerGrensCount[id] = get_pcvar_num(p_piat)
			}
		}
	else if(team == AXIS)
		{	
		switch(dod_get_user_class(id))
			{
			case DODC_KAR: playerGrensCount[id] = get_pcvar_num(p_kar) 
			case DODC_K43: playerGrensCount[id] = get_pcvar_num(p_k43) 
			case DODC_MP40: playerGrensCount[id] = get_pcvar_num(p_mp40) 
			case DODC_MP44: playerGrensCount[id] = get_pcvar_num(p_mp44) 
			case DODC_SCHARFSCHUTZE: playerGrensCount[id] = get_pcvar_num(p_scharf) 
			case DODC_FG42: playerGrensCount[id] = get_pcvar_num(p_fg42) 
			case DODC_SCOPED_FG42: playerGrensCount[id] = get_pcvar_num(p_scopedfg) 
			case DODC_MG34: playerGrensCount[id] = get_pcvar_num(p_mg34) 
			case DODC_MG42: playerGrensCount[id] = get_pcvar_num(p_mg42) 
			case DODC_PANZERJAGER: playerGrensCount[id] = get_pcvar_num(p_panzer)
			}
		}

#if SETTING_MSGSPAWN

	client_print(id,print_chat,"You have %d Tripmine %s...",playerGrensCount[id],(playerGrensCount[id] > 1) ? "Grenades" : "Grenade")

#endif
	
}

///////////////////////////////////////////////////////////////////////////////////////
// file consistency
//
public enforce(const file[])
	if(file_exists(file) && equali(fileNames[sprites],file))
		force_unmodified(force_exactfile,{0,0,0},{0,0,0},file)

public inconsistent_file(id,const filename[],reason[64])
{
	if(equali(fileNames[sprites],filename))
		{
		new nick[32],steamid[32],userid
		get_user_authid(id,steamid,31)
		get_user_name(id,nick,31)
		userid = get_user_userid(id)
		
		static output[128]
		format(output,127,"^"%s<%d><%s>^" inconsistent file ^"/%s^"",nick,userid,steamid,filename)
		
		log_amx("%s",output)
		
		format(reason,63,"inconsistent file: /%s",filename)	
		
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
				show_hudmessage(0,"WARNING!!^n%s^nhas an inconsistent tripmine grenade sprite!",nick)
				
				client_print(0,print_chat,"WARNING!! %s has an inconsistent tripmine grenade sprite!",nick)
				}
			}
				
		switch(SETTING_WARNACTION)
			{
			case 0: return PLUGIN_HANDLED
			case 1: { server_cmd("amx_kick #%d %s",userid,kick_reason); return PLUGIN_HANDLED; }
			case 2: { set_task(3.0,"inconsistent_ban",id); return PLUGIN_HANDLED; }
			}
		}
		

	
	return PLUGIN_CONTINUE
}

#if SETTING_WARNACTION == 2

public inconsistent_ban(id)
{
	if((is_user_connected(id) || is_user_connecting(id)) && !is_user_bot(id))
		{
		new nick[32],steamid[32],userid
		get_user_authid(id,steamid,31)
		get_user_name(id,nick,31)
		userid = get_user_userid(id)
			
		switch(SETTING_AMXBANS)
			{
			case 0: server_cmd("kick #%d ^"%dm Ban - %s^";wait;banid ^"%d^" ^"%s^";wait;writeid",userid,bantime,kick_reason,bantime,steamid)
			case 1: server_cmd("amx_ban %d %s %s",bantime,steamid,kick_reason)
			case 2: server_cmd("amx_ban %s %d %s",steamid,bantime,kick_reason)					
			}
		}
}

#endif

///////////////////////////////////////////////////////////////////////////////////////
// Block suicide log
//
public block_log(type, msg[])
	return(log_block_state?FMRES_SUPERCEDE:FMRES_IGNORED)

///////////////////////////////////////////////////////////////////////////////////////
// DEBUG - Give tripmine nades
//
#if DEBUG_MODE

public debug_givetripmine(id,level,cid)
{
	if(cmd_access(id,level,cid,1))
		playerGrensCount[id] += 5
		
	return PLUGIN_HANDLED
}

#endif
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1049\\ f0\\ fs16 \n\\ par }
*/
