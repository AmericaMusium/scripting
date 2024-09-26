#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <fakemeta_util>
#include <dodx>
#include <dodfun>
#include <fun>
#include <engine>
#include <amxmisc>

#define PLUGIN "DOD ThrowKnife"
#define VERSION "1.3"
#define AUTHOR "[America][TheVaskov]"

/// Register arraty of names and models
new KNIVES_NAMES[3][] = {"weapon_amerknife","weapon_gerknife","weapon_spade"}
new KNIVES_MODELS[3][] = {"models/w_amerk.mdl","models/w_paraknife.mdl","models/w_spade.mdl"}

/// Register array of sounds
new const g_ThrowSound[] = "weapons/knifeswing2.wav"
new const g_ThrowFlySound[] = "weapons/whizz11.wav"
new const g_ThrowHitwallSound[] = "weapons/cbar_hit1.wav"
new const g_ThrowHitHumanSound[] = "weapons/hit_grass2.wav"

// Register messages 
new g_msgBloodPuff // bloodpuff by touching knife to player
new g_MsgDeathMsg  // register hud message who kills with knifetype
new g_FhSetModel  // id for register event to setmodel by FAKEMETA in weaponboxspawn 


// Register player trigger
new bool:accepttofly[33]  // if (get_user_weapon(i_player,_,_) == any knife or spade) {accepttofly = true}
new g_dropboxclass[33]    //  = get_user_weapon(i_player,_,_) ; = knifetype
/*
spade 19
gerknife 2
amerk 1
britk 37
*/ 

//// Function list 
/*
plugin_precache
plugin_init
client_PreThink  // +attack2 to start throwknife
func_WeaponDrop  // accepting for drop knife
WeaponBox_Spawn  // register weaponbox with knife to make it throw
RetuneWeaponbox  // set movetype, new classname, set rotation, set velocity
flyknife_touch   // register touch
weapon_sprite    // fx when you stab the wall hands with knife to make sparkle :D

*/
public plugin_precache()
{
	precache_model("models/w_spade.mdl")
	precache_model("models/w_paraknife.mdl")
	precache_model("models/w_amerk.mdl")
	precache_sound(g_ThrowSound)
	precache_sound(g_ThrowFlySound)
	precache_sound(g_ThrowHitwallSound)
	precache_sound(g_ThrowHitHumanSound)
}

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	
	// RegisterHam(Ham_Touch,"fly_knife","flyknife_touch")
	
	RegisterHam(Ham_DOD_Item_CanDrop,KNIVES_NAMES[0],"func_WeaponDrop")
	RegisterHam(Ham_DOD_Item_CanDrop, KNIVES_NAMES[1], "func_WeaponDrop")
	RegisterHam(Ham_DOD_Item_CanDrop,KNIVES_NAMES[2],"func_WeaponDrop")
	
	
	RegisterHam(Ham_Spawn, "weaponbox", "WeaponBox_Spawn", 1)
	register_forward(FM_Touch,"flyknife_touch")
	
	//tempentity event - decal applied to world or entity // register event wall sprite
	register_event("23", "weapon_sprite", "a", "1=116", "1=104")
	
	g_msgBloodPuff = get_user_msgid("BloodPuff")
	g_MsgDeathMsg = get_user_msgid("DeathMsg")
	
}



/////////////////////     +attack2 to start throwknife
static bool:g_i_status[33]
public client_connect(i_player)
	g_i_status[i_player]=false

public client_PreThink(i_player){
	
	if(pev(i_player,pev_button)&IN_ATTACK2)
	{
		if(g_i_status[i_player]==false)
		{
			g_i_status[i_player]=true // Игрок  i_player послал +attack2
			
			
			accepttofly[i_player]=false
			new knifetype = get_user_weapon(i_player,_,_)
			if(knifetype == 1 || knifetype == 2 || knifetype == 19 || knifetype == 37){
				
				
				
				g_dropboxclass[i_player] = knifetype
				
				client_cmd(i_player,"drop")
				
			
				accepttofly[i_player]=true
				
			// PLUGIN_HANDLED
		}
		}
	}      
	else {
		if(g_i_status[i_player]==true)
		{
			g_i_status[i_player]=false // Игрок i_player послал -attack2
			
		}
	}
}


//////////// ACCEPT DROP (List of DODW to accept is in public plugin_init)
public func_WeaponDrop(id)
{
	if(is_valid_ent(id))
	{
		
		SetHamReturnInteger(1)
		return HAM_SUPERCEDE
	}
	return HAM_IGNORED
}

//////////////////  WEAPONBOX SPAWEND NEED 
public WeaponBox_Spawn(ent)
{	
	new bx_owner = entity_get_edict2(ent, EV_ENT_owner )
	if(is_user_alive(bx_owner) &&  accepttofly[bx_owner])
		{

		g_FhSetModel = register_forward(FM_SetModel, "RetuneWeaponbox")
		// set_pev(ent,pev_classname,"fly_knife")
		accepttofly[bx_owner]=false
	
		}
}
/////////////////////

public RetuneWeaponbox(flyknife)
{	
	set_pev(flyknife,pev_classname,"fly_knife")
	new id = pev(flyknife, pev_owner)
	accepttofly[id]=false

	
	if(is_user_alive(id))
	{
		
		
		emit_sound(id,CHAN_BODY,g_ThrowSound,0.9,ATTN_NORM,0,PITCH_NORM)
		
		
		new Float:velocity[3],Float:f5Angles[3]
		

		
		velocity_by_aim(id, 1800, velocity)	
		vector_to_angle(velocity, f5Angles)		
		f5Angles[0] += 55.0
		// f5Angles[1] // 
		f5Angles[2] += 90.0
		set_pev(flyknife, pev_angles, f5Angles)
		set_pev(flyknife, pev_globalname, "damager")

		engfunc(EngFunc_SetSize, flyknife, Float:{-1.0, -1.0, -1.0}, Float:{1.0, 1.0, 1.0})
		set_pev(flyknife,pev_movetype,MOVETYPE_TOSS)	
		set_pev(flyknife,pev_solid,SOLID_TRIGGER)
		new Float:TumbleVector[3]			
		TumbleVector[0] = random_float(-800.0,-801.0) // = 1320.0  // Wheel
		// TumbleVector[1] // = random_float(800.0,100.0)  // TEA
		TumbleVector[2] = random_float(-60.0,60.0) // 400.0 // = random_float(2.0,0.0) //  HOURS
		
		set_pev(flyknife,pev_velocity,velocity)	
		set_pev(flyknife,pev_avelocity,TumbleVector)	
		
	}
	unregister_forward(FM_SetModel, g_FhSetModel)
}
public flyknife_touch(flyknifeid,touchid)
{
	//if(!pev_valid(flyknifeid))
	// 	return HAM_IGNORED
	if(flyknifeid > 32 &&  touchid <= 32){ 
		//////////////////// REGISTER  DATA
		new idAttacker = pev(flyknifeid, pev_owner)
		new classname[32] // weapon_spade/knife/gerknife
		pev(flyknifeid, pev_classname,  classname,31)
		new status[32]   // damager or weaponbox
		pev(flyknifeid, pev_globalname, status,31 )
		
		new Float:iOrigin[3]
		new i2Origin[3]
		entity_get_vector(flyknifeid,EV_VEC_origin,iOrigin)
		FVecIVec(iOrigin,i2Origin)
		
		
		//////////// MODEL SET for FLY KNIFE if it needs
		
		/*
		if(g_dropboxclass[idAttacker] == 1 && equal(classname,"fly_knife"){
			// engfunc(EngFunc_SetModel,flyknife,KNIVES_MODELS[0])
			// set_pev(flyknife,pev_classname,"weapon_amerknife")
		}
		
		if(g_dropboxclass[idAttacker]  == 2 && equal(classname,"fly_knife"){
			// engfunc(EngFunc_SetModel,flyknife,KNIVES_MODELS[1])
			// set_pev(flyknife,pev_classname,"weapon_gerknife")
		}
		
		*/
		
		if(g_dropboxclass[idAttacker] == 37 && equal(classname,"fly_knife")){
			//engfunc(EngFunc_SetModel,flyknife,KNIVES_MODELS[0])
			// set_pev(flyknife,pev_classname,"weapon_amerknife")
			g_dropboxclass[idAttacker] = 1  // ned to register hud kill message icon
		}
		
		if(g_dropboxclass[idAttacker]  == 19 && equal(classname,"fly_knife") ){
			// set_pev(flyknife,pev_classname,"weapon_spade")
			engfunc(EngFunc_SetModel,flyknifeid,KNIVES_MODELS[2])  // need to replace weaponbox model
			// set_pev(flyknife,pev_classname,"weapon_spade")
		}
		
	
		////////////////////                    HIT WALL    
		//  need  to fix how destroy glasses or func_berakeble || touchid > 32
		
		if(touchid == 0 && equal(status,"damager") && equal(classname,"fly_knife") ) {
						
			message_begin(MSG_PVS,SVC_TEMPENTITY)
			write_byte(TE_SPARKS)
			write_coord(i2Origin[0])
			write_coord(i2Origin[1])
			write_coord(i2Origin[2])
			message_end()
			
			set_pev(flyknifeid, pev_classname, "weaponbox")
			set_pev(flyknifeid, pev_globalname,"nifebox")
			emit_sound(flyknifeid,CHAN_AUTO,g_ThrowHitwallSound,0.4,ATTN_IDLE ,0,PITCH_NORM + 50)
			
			}
		
		//////////////////// HIT DAMAGE PLAYER OR FRIEND
		if( is_user_connected(touchid) && is_user_alive(touchid)) {
			
			
			if(equal(status,"damager") &&  equal(classname,"fly_knife")) {
				
				////////////  FRIENDLY FIRE IGNORER 
				
				if(get_user_team(idAttacker) == get_user_team(touchid)
				|| !is_user_alive(idAttacker) 
				|| !is_user_alive(touchid))
				return FMRES_IGNORED
				//////////// 
				
				user_silentkill(touchid)
				new fragcount = dod_get_user_kills(idAttacker)
				fragcount++
				dod_set_user_kills(idAttacker, fragcount, 1)
				
				message_begin(MSG_PVS,g_msgBloodPuff,{0,0,0},0)
				write_coord(i2Origin[0])
				write_coord(i2Origin[1])
				write_coord(i2Origin[2])
				message_end()
				
				message_begin(MSG_ALL,g_MsgDeathMsg,{0,0,0},0)
				write_byte(idAttacker) // killer
				write_byte(touchid) // victim
				write_byte(g_dropboxclass[idAttacker])  // 42 is smash
				message_end()
				
				emit_sound(flyknifeid,CHAN_AUTO,g_ThrowHitHumanSound,0.8,ATTN_IDLE ,0,PITCH_NORM)				
				set_pev(flyknifeid, pev_classname, "weaponbox")
				set_pev(flyknifeid, pev_globalname,"nifebox")
				
				
			}	
		}
	}
	return PLUGIN_HANDLED
}
public weapon_sprite()
{
	static Float:origin[3]
	
	switch (read_data(5)) {
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
