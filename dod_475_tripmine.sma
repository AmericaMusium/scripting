#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>
#include <fakemeta_util>
#include <fun>
#include <dodx>
#include <dodfun>
#include <hamsandwich>

#define PLUGIN "DOD Sathels"
#define VERSION "23jan2023"
#define AUTHOR "[America][TheVaskov]"

#define TRIPsatchel_MAXALL 64
#define TRIPsatchel_MAXHAVE 2
#define TRIPsatchel_SETDIST 150.0
#define TRIPsatchel_RADDAM 350.0
#define TRIPsatchel_DAMAGE 140.0

/// CLASSES
// US Allies
#define cl_garand 1
#define cl_m1carb 2
#define cl_thomp 3
#define cl_greesg 4
#define cl_springf 5
#define cl_bar 6
#define cl_30cal 7
#define cl_bazooka 8
// Axis 
#define cl_k98 10
#define cl_k43 11
#define cl_mp40 12
#define cl_stg44 13
#define cl_k98s 14
#define cl_fg42 15
#define cl_fg42s 16
#define cl_mg34 17
#define cl_mg42 18
#define cl_panzerschreck 19
// brit 
#define cl_enfield 21
#define cl_sten 22
#define cl_scenfield 23
#define cl_bren 24
#define cl_piat 25

#define extime 1.0


new const gentClassname[] = "tripsatchel" //Classname  entity
new const gentModel[] = "models/tripmine_475.mdl" 
new const gentSpriteExplode[] = "sprites/explosion1.spr" 
new const gentSpriteSmoke[] = "sprites/puff.spr" // 
new gent_Sprite[3] //   
new const s_expl[] = "weapons/mortar_satchel.wav"
new const s_notify[] = "weapons/mgoverheat.wav"


new g_satchel_have[33]
new g_satchel_owner[2048]
new g_maxsatchels 
new g_MessageFade, gMsgDeathMsg
new g_torus


// new p_friendlyfire

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	register_clcmd("say /plantsatchel", "Satchel_create")
	register_clcmd("/plantsatchel", "Satchel_create")
	
	//register_touch(gentClassname, "player", "EntityTouch")
	register_event("HLTV", "DeleteAllsatchels", "a", "1=0", "2=0")
	g_MessageFade = get_user_msgid("ScreenFade")
	gMsgDeathMsg = get_user_msgid("DeathMsg")
	// gMsgFrags = get_user_msgid("Frags")

	RegisterHam(Ham_Spawn,"player","func_HamSpawn",1)


	register_touch(gentClassname, "player", "Satchel_Damage")

	// RegisterHam(Ham_Item_PostFrame, "weapon_spade", "Satchel_create")
	// RegisterHam(Ham_TakeDamage, "info_target", "fw_takedamage")
	// register_forward(FM_CmdStart,"anttroop_button")
	// p_friendlyfire = get_cvar_pointer("mp_friendlyfire")
	// 

	
}

/*
public anttroop_button(id, uc_handle)     
{
static Button, OldButtons
Button = get_uc(uc_handle, UC_Buttons)
OldButtons = pev(id, pev_oldbuttons)

if((Button & IN_USE) && !(OldButtons & IN_USE))
	StartCreate(id)
else return
}

*/

public plugin_precache()
{
	precache_model( gentModel ) 
	precache_sound(s_expl)
	// precache_sound(s_notify)
	gent_Sprite[1] = precache_model( gentSpriteExplode ) 
	gent_Sprite[2] = precache_model( gentSpriteSmoke ) 
	g_torus =  precache_model("sprites/glow01.spr")
} 

public func_HamSpawn(id)
{	
	if(is_user_alive(id) && !is_user_bot(id))
	{
		g_satchel_have[id] = 0
		Satchel_Equip(id)
		// client_print(id, print_chat, "HAM POST SPAWN")
	}
		
}
	
public Satchel_Equip(id)
{
	g_satchel_have[id] = 1
	client_print(id, print_chat, "You have %d satchels , to set: say /plantsatchel", g_satchel_have[id])

	/*
	new myclass = dod_get_user_class(id)
	if (myclass == cl_garand || myclass == cl_m1carb || myclass == cl_k98 || myclass == cl_k43 )
	{	
		g_satchel_have[id] = 2
		client_print(id, print_chat, "You have 2 satchels , to set: say /plantsatchel", myclass)
	}
		
	else if (myclass == cl_bazooka || myclass == cl_panzerschreck || myclass == cl_piat)
	{	
		g_satchel_have[id] = 3
		client_print(id, print_chat, "You have 3 satchels , to set: say /plantsatchel", myclass)
	}
	*/
		
}

public DeleteAllsatchels()
{
	static tripscount = 0
	new ent = -1
	while ((ent = fm_find_ent_by_class(ent, "tripsatchel"))) 
	{	
		tripscount++
		fm_remove_entity(ent)
	}
	server_print(" ADTER ROUND founded %d  was %d", tripscount, g_maxsatchels)
	g_maxsatchels = 0
	for(new id = 0 ; id < get_maxplayers() ; id++)
	{
		g_satchel_have[id] = 0
	}

	return PLUGIN_CONTINUE
}

			


public Satchel_create(id)
{	
	new myclass = dod_get_user_class(id)
	if(is_user_connected(id) && is_user_alive(id))
	{ 	
		// client_print(0, print_chat, "My class: %d", myclass)
		// if(myclass != 1) return PLUGIN_HANDLED
		new iOrigin[3] //    
		new iOrigin1[3] //  
		get_user_origin(id, iOrigin, 0) //    origin zero
		get_user_origin(id, iOrigin1, 1) //   looks to
		
		new Float:fOrigin[3] //   float 
		IVecFVec(iOrigin1, fOrigin) //     

		//// CREATE ENITY 
		new id_satchel = create_entity("info_target")	
		
		set_pev(id_satchel, pev_solid, SOLID_TRIGGER)   
		set_pev(id_satchel, pev_movetype, MOVETYPE_TOSS)


		// Если нужно что бы разбивалось от пули , надо менять на 
		// SOLID_BBOX и менять точку старта, а то задевае игрока
		// set_pev(id_satchel, pev_health, 1.0);
		// set_pev(id_satchel, pev_takedamage, DAMAGE_YES);
		
		entity_set_edict(id_satchel, EV_ENT_owner, id)
		static Float:vVelocity[3]
		velocity_by_aim(id, 300, vVelocity)
		set_pev(id_satchel, pev_velocity, vVelocity)
		set_pev(id_satchel, pev_origin, fOrigin)

		if(!pev_valid(id_satchel)) 
		{
			return PLUGIN_HANDLED  
		}
		// new units = get_entity_distance(id, id_satchel) 
		// units > TRIPsatchel_SETDIST || 
		if(g_maxsatchels >= TRIPsatchel_MAXALL || g_satchel_have[id] <= 0)  //    150 ,       
		{ 
			remove_entity(id_satchel)
		}
		else
		{
			g_maxsatchels++
			g_satchel_have[id]--
			g_satchel_owner[id_satchel] = id
			
			// new message = pev(id_satchel, pev_owner)
			// client_print(0, print_chat,"SATHEL %d OWNER: %d", id_satchel, message)
			// set_pev(id_satchel, pev_nextthink, get_gametime() + 1.0) //  think
			// drop_to_floor(id_satchel)
			emit_sound(id,CHAN_VOICE,"weapons/bazookareloadgetrocket.wav",1.0,ATTN_NORM,0,PITCH_NORM) //  
			engfunc(EngFunc_SetModel, id_satchel, gentModel) // 
			engfunc(EngFunc_SetSize, id_satchel, Float:{-6.0, -6.0, 0.0}, Float:{6.0, 6.0, 3.0}) //   entity(      )


			set_task(extime, "Satchel_retune", id_satchel)
		}
	}
	return PLUGIN_HANDLED
} 


public Satchel_retune(id_satchel)
{
	set_pev(id_satchel, pev_classname, gentClassname) 
	
	client_print(0, print_chat,"Someone somewhere sets satchel, now we have %d satchels on battlefield ! Carefull ", g_maxsatchels)

	new msg[64]
	format(msg, 63 , "%d satchels on battlefield ! Carefull ", g_maxsatchels)
	message_begin(MSG_ALL,get_user_msgid("HudText"))
	write_string(msg) // sprite name
	write_byte(1); // red
	message_end();
		
	set_task(random_float(25.0, 35.0), "Satchel_Damage", id_satchel)
	// set_task(random_float(5.0, 8.0), "Satchel_Notify", id_satchel)
}

public Satchel_Damage(id_satchel, id_player)
{
	if(!pev_valid(id_satchel)) 
		return PLUGIN_CONTINUE

	new sclassname[32]
	pev(id_satchel, pev_classname, sclassname, 31)
	if(!equal(sclassname, gentClassname))
		return PLUGIN_CONTINUE
	
	if (id_player == g_satchel_owner[id_satchel])
		return PLUGIN_CONTINUE
	
	if (is_user_alive(id_player))
		if (get_user_team(id_player) == get_user_team(g_satchel_owner[id_satchel]))
			return PLUGIN_CONTINUE

	
	new Float:fOrigin_satchel[3]
	pev(id_satchel, pev_origin, fOrigin_satchel)

	new iPlayers[32]  
	new iPlayer, iNum 
	get_players(iPlayers, iNum, "ah")
	for(new i; i < iNum; i++) //    
	{
		iPlayer = iPlayers[i]
		new Float:fOrigin_Player[3] 
		new Float:fDistance 
		pev(iPlayer, pev_origin, fOrigin_Player)
		 //
		fDistance = get_distance_f(fOrigin_Player, fOrigin_satchel)
		
		/*
		if(fDistance < 1200.0)
		{	
			shake_screen(iPlayer)
		}
		*/
		if(fDistance < TRIPsatchel_RADDAM)
		{	
			
			// new ownerteam = get_user_team(g_satchel_owner[id_satchel])
			// new victeam = get_user_team(iPlayer)
			/*
			new current_health =  pev(iPlayer, pev_health)
			client_print(0, print_chat,"1 HEALTH %f", float(current_health))
			new float:sethp
			sethp = float(current_health) - (TRIPsatchel_DAMAGE * (1.0 - (fDistance/TRIPsatchel_RADDAM)))

			if(current_health >= 1.0)
			{	
				client_print(0, print_chat,"2  HEALTH %f", sethp)
				set_pev(iPlayer, pev_health, float(sethp))
				red_flash(iPlayer)
			}
			else if(current_health <= 1.0)
			{
				*/
			/*	
			mode1
			new deathcount = dod_get_pl_deaths(iPlayer)
			deathcount++
			dod_set_pl_deaths(iPlayer, deathcount, 1)
			user_silentkill(iPlayer)
			message_begin(MSG_ALL, gMsgDeathMsg,{0,0,0},0)
			write_byte(g_satchel_owner[id_satchel]) // killer
			write_byte(iPlayer) // victim
			write_byte(0)  // 42 is smash
			message_end()
			new fragcount = dod_get_user_kills(g_satchel_owner[id_satchel])
			fragcount++
			dod_set_user_kills(g_satchel_owner[id_satchel], fragcount, 1)

			*/
			// mode2
			//iPlayer
			new Float:dmgs 
			// множитель урона
			dmgs = TRIPsatchel_DAMAGE * (1.0 - (fDistance/TRIPsatchel_RADDAM))
			// dmgs*= 0.01
			// victim , inflictor , owner weapins, dmg , type
			// server_print("%f", dmgs)
			ExecuteHam(Ham_TakeDamage, iPlayer, 0 , g_satchel_owner[id_satchel], dmgs , DMG_BULLET)
			red_flash(iPlayer)
		}
	}
	Satchel_Explode(id_satchel)
	return PLUGIN_CONTINUE
}

public Satchel_Explode(id_satchel)
{	
	if(!pev_valid(id_satchel)) 
		return PLUGIN_HANDLED

	new Float:fOrigin_satchel[3]
	pev(id_satchel, pev_origin, fOrigin_satchel)

	new origin[3]
	origin[0] = floatround(fOrigin_satchel[0])
	origin[1] = floatround(fOrigin_satchel[1])
	origin[2] = floatround(fOrigin_satchel[2])
	// (origin[3], addrad= скорость движения, sprite, startfrate, framerate, life=радиус и продолжительность, width, amplitude, red, green, blue, brightness, speed)
	create_cylinder(origin, 1200, g_torus, 0, 0, 30, 200, 10, 150, 150, 150, 40, 0)

	message_begin(MSG_BROADCAST,SVC_TEMPENTITY) // 
	write_byte(TE_EXPLOSION) // ()
	engfunc(EngFunc_WriteCoord, fOrigin_satchel[0]) // x
	engfunc(EngFunc_WriteCoord, fOrigin_satchel[1]) // y
	engfunc(EngFunc_WriteCoord, fOrigin_satchel[2] + 10.0) // z
	write_short(gent_Sprite[1]) //  
	write_byte(30) // scale
	write_byte(15) // 
	write_byte(0) //
	message_end() // 

	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)// 
	write_byte(TE_SMOKE) // ()
	engfunc(EngFunc_WriteCoord, fOrigin_satchel[0]) // x
	engfunc(EngFunc_WriteCoord, fOrigin_satchel[1]) // y
	engfunc(EngFunc_WriteCoord, fOrigin_satchel[2] + 20.0) // x
	write_short(gent_Sprite[2]) //  
	write_byte(25) // 
	write_byte(10) // 
	message_end() // 

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_WORLDDECAL);
	engfunc(EngFunc_WriteCoord, fOrigin_satchel[0]);
	engfunc(EngFunc_WriteCoord, fOrigin_satchel[1]);
	engfunc(EngFunc_WriteCoord, fOrigin_satchel[2]);
	write_byte(60); // 60 EXPLOD
	message_end();

	emit_sound(id_satchel, CHAN_WEAPON, s_expl, 1.0, ATTN_NORM,0,PITCH_NORM)
	// g_satchel_have[(g_satchel_owner[id_satchel])] --
	g_maxsatchels--
	if(g_maxsatchels<1) g_maxsatchels=0
	remove_entity(id_satchel)
	return PLUGIN_CONTINUE
}


public Satchel_Notify(id_satchel){

	if(!pev_valid(id_satchel)) 
		return PLUGIN_HANDLED
	else
		emit_sound(id_satchel, CHAN_AUTO, s_notify, 0.8, ATTN_NORM,0, (PITCH_NORM + (random_num(-10,10))))
		set_task(random_float(5.0, 8.0), "Satchel_Notify", id_satchel)
}

stock red_flash(id)
{
	if(!is_user_alive(id) || is_user_bot(id)) 
		return PLUGIN_HANDLED

	/*
	message_begin(MSG_ONE_UNRELIABLE, g_MessageFade , {0,0,0}, id)
	write_short(1<<10)
	write_short(1<<10)
	write_short(0x0001)
	write_byte(240)
	write_byte(10) 
	write_byte(10) 
	write_byte(50)
	message_end() 
	*/
	

	new gmsgShake = get_user_msgid("ScreenShake")
	message_begin(MSG_ONE, gmsgShake, {0,0,0}, id)
	write_short(255<<14) //ammount
	write_short(5<<14) //lasts this long
	write_short(255<<14) //frequency
	message_end()
	return PLUGIN_CONTINUE
}

public shake_screen(id)
{
	if(!is_user_alive(id) || is_user_bot(id)) 
		return PLUGIN_HANDLED
	new gmsgShake = get_user_msgid("ScreenShake")
	message_begin(MSG_ONE, gmsgShake, {0,0,0}, id)
	write_short(255<<14) //ammount
	write_short(5<<14) //lasts this long
	write_short(255<<14) //frequency
	message_end()
	return PLUGIN_CONTINUE
}

stock create_cylinder(origin[3], addrad, sprite, startfrate, framerate, life, width, amplitude, red, green, blue, brightness, speed)
{
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BEAMCYLINDER)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2] + addrad)
	write_short(sprite)
	write_byte(startfrate)
	write_byte(framerate)
	write_byte(life)
	write_byte(width)
	write_byte(amplitude)
	write_byte(red)
	write_byte(green)
	write_byte(blue)
	write_byte(brightness)
	write_byte(speed)
	message_end()
}