#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <fakemeta_util>
#include <dodx>
#include <dodfun>
#include <fun>
#include <engine>

#define m_knifeItem 272
//// Fakameta-engine interpriter
/*
#define pev(%1, %2, %3, %4) entity_get_string(%1 ,EV_SZ_classname,%3, %4)
#define set_pev(%1, %2, %3) entity_set_string(%1 ,EV_SZ_classname,%3)
#define set_pev(%1, pev_movetype, %2) entity_set_int(%1,EV_INT_movetype, %2) // EV_INT_movetype
#define set_pev(%1, pev_solid, %2) entity_set_int(%1,EV_INT_solid, %2) // EV_INT_solid
#define set_pev(%1, pev_angles, %2) entity_set_vector(%1, EV_VEC_angles, %2)
*/

/// Register arraty of names and models
new KNIVES_NAMES[3][] = {"weapon_amerknife","weapon_gerknife","weapon_spade"}
new KNIVES_MODELS[3][] = {"models/w_amerk.mdl","models/w_paraknife.mdl","models/w_spade.mdl"}
/// Register array of sounds
new const g_ThrowSound[] = "weapons/knifeswing2.wav"
new const g_ThrowFlySound[] = "weapons/knifeswing2.wav"
new const g_ThrowHitwallSound[] = "weapons/cbar_hit1.wav"
new const g_ThrowHitHumanSound[] = "weapons/hit_grass2.wav"
// Register player trigger


//                            spade 19/gerknife 2/amerk 1/britk 37
// Register messages 
new g_SpriteBlood
new g_SpriteBlood2
new g_msgBloodPuff // bloodpuff by touching knife to player
new g_MsgDeathMsg  // register hud message who kills with knifetype
new g_FhSetModel  // id for register event to setmodel by FAKEMETA in weaponboxspawn 
// CVars
new cv_stackinwall //  Stack 1 = 0, no stack in wall = 0
new cv_bldsprt // bonus boold splashes 1 on . 0 = off 
new cv_angpitch // angle-up by throw 
new cv_spspeed // speed fly spade
new cv_sprot // rotation speed
new cv_trail // trail for knife
//// Function list 
/*
plugin_precache
plugin_init
player_Spawn_P // block drop knife by G button (drop command)
DeathMsg_P //  block drop knife by G button (drop command)
CurWeapon_P // parse knife name for drop this is fix for drop only knife without pistol or else.
client_connect // block drop knife by G button (drop command)
client_PreThink  // oldway +attack2 to throwknife
Ham_Weapon_P //  +attack to throwknife
WeaponBox_Drop_P  // accepting for drop knife
WeaponBox_Spawn  // register weaponbox with knife to make it throw
Weaponbox_Retune  // set movetype, new classname, set rotation, set velocity
WeaponBox_Touch   // register touch
Particle_Fx    // fx when you stab the wall hands with knife to make sparkle :D
WeaponBox_Unstuck   // Back movetype after stack in wall
WeaponBox_Sound // Repeats rotation sound whe knife flyes
*/
// Playe's Array
// многоуровневый массив с указателем
enum _:PLAYER_DATA
{
    bool:accept_throw,  // if (get_user_weapon(i_player,_,_) == any knife or spade) {accepttofly = true}
    bool:input_b, // bool for mouse2 button
    knifetype, //  = get_user_weapon(i_player,_,_) ; = knifetype  - SET HUD KILL ICON AND W_MODEL
	knifename[17], 
	team
}

new Float:TumbleVector[3]

// server data
new g_maxpl // need for difference touch index nums
new g_FriendlyFire
// создаём массив в с указательным массивом
new g_arr[33][PLAYER_DATA]


public plugin_precache()
{
	precache_model(KNIVES_MODELS[0])
	precache_model(KNIVES_MODELS[1])
	precache_model(KNIVES_MODELS[2])
	precache_sound(g_ThrowSound)
	precache_sound(g_ThrowFlySound)
	precache_sound(g_ThrowHitwallSound)
	precache_sound(g_ThrowHitHumanSound)
	
	g_SpriteBlood = precache_model("sprites/blood-narrow.spr")
	g_SpriteBlood2 = precache_model("sprites/effects/debris_tile1.spr")
	
}

public plugin_init()
{
	register_plugin("DOD THROW KNIFES", "2023", "America")
	
	cv_stackinwall = register_cvar("stack1_nostack0","0")
	cv_bldsprt = register_cvar("bloodspash1_no0","0")
	
	cv_angpitch = register_cvar("sp_angle_pitch","200")
	cv_spspeed = register_cvar("sp_speed","1100")
	cv_sprot = register_cvar("sp_rotation","800")
    cv_trail = register_cvar("fx_trail","1")
	
	
	g_maxpl = get_maxplayers()
	g_FriendlyFire = get_cvar_num ( "mp_friendlyfire")

    // accepty to drop'n fly
    register_event("CurWeapon","CurWeapon_P","be", "1=1");
	RegisterHam(Ham_DOD_Item_CanDrop,KNIVES_NAMES[0],"WeaponBox_Drop_P")
	RegisterHam(Ham_DOD_Item_CanDrop,KNIVES_NAMES[1], "WeaponBox_Drop_P")
	RegisterHam(Ham_DOD_Item_CanDrop,KNIVES_NAMES[2],"WeaponBox_Drop_P")
	RegisterHam(Ham_Spawn, "weaponbox", "WeaponBox_Spawn", 1)
	RegisterHam(Ham_Spawn, "player", "Player_Spawn_P", 1)
	RegisterHam(Ham_Item_PreFrame,KNIVES_NAMES[0],"Ham_Weapon_P")
	RegisterHam(Ham_Item_PreFrame,KNIVES_NAMES[1], "Ham_Weapon_P")
	RegisterHam(Ham_Item_PreFrame,KNIVES_NAMES[2],"Ham_Weapon_P")
	register_touch("fly_knife", "", "WeaponBox_Touch")
    
	// tempentity event - decal applied to world or entity // register event wall sprite
	register_event("DeathMsg", "DeathMsg_P", "a")
	register_event("23", "Particle_Fx", "a", "1=116", "1=104")
	
	g_msgBloodPuff = get_user_msgid("BloodPuff")
	g_MsgDeathMsg = get_user_msgid("DeathMsg")
    
}

public Player_Spawn_P(id)
{	
	if(is_user_alive(id))
	{
	g_arr[id][team] = get_user_team(id) 
	}
} 
public DeathMsg_P()
{
	new victim = read_data(2)
	g_arr[victim][accept_throw] = false
	// 
	// client_print(0, print_chat, "event deatn")
}

public CurWeapon_P(id)
{
	new weapon = read_data(2)

    
	if(weapon == DODW_AMERKNIFE || weapon == DODW_GERKNIFE || weapon == DODW_SPADE || weapon == DODW_BRITKNIFE)
	{
	// взять гранаты индекс
	g_arr[id][accept_throw] = false
    g_arr[id][input_b] = true
    g_arr[id][knifetype] = weapon

	
	new en = get_pdata_cbase(id, m_knifeItem)
	pev(en,pev_classname,g_arr[id][knifename],16)
	TumbleVector[0] = float (get_pcvar_num(cv_sprot)) // = 1320.0  // Wheel
	// TumbleVector[1] // = random_float(800.0,100.0)  // TEA
	TumbleVector[2] = random_float(-10.0,10.0) // 400.0 // = random_float(2.0,0.0) //  HOURS


    return PLUGIN_CONTINUE
	}
	else
	{
    
    	g_arr[id][accept_throw] = false
		return PLUGIN_CONTINUE
	}
	return PLUGIN_CONTINUE
}
public client_connect(id)
{
    g_arr[id][input_b] = true
    g_arr[id][accept_throw] = false
}

/*  Item_fram would be better, cause it call only when weapon in arms
public client_PreThink(i_player)
{
	
    if(g_arr[i_player][accept_throw]==true)
    {   
        if(pev(i_player,pev_button)&IN_ATTACK2)
        {   
			engclient_cmd(i_player,"drop",g_arr[i_player][knifename])
			g_arr[i_player][input_b] = false
            return PLUGIN_CONTINUE
        }
		return PLUGIN_CONTINUE
    }
    return PLUGIN_CONTINUE
	
}
*/
public Ham_Weapon_P(id)
{	
	new i_player = pev(id, pev_owner)
	if(!is_user_bot(i_player))
	{
	    if(pev(i_player,pev_button)&IN_ATTACK2)
        {   
            g_arr[i_player][accept_throw] = true
			engclient_cmd(i_player,"drop",g_arr[i_player][knifename])
			g_arr[i_player][input_b] = false
        }
		
    }
   
}

public WeaponBox_Drop_P(id)
{

    /// запстить проверк на разрешение выброса ножа методом броска
	new id_owner
	id_owner = pev(id,pev_owner)
	if(is_valid_ent(id) && g_arr[id_owner][accept_throw] == true)
	{
        g_arr[id_owner][accept_throw] = false
		SetHamReturnInteger(1)
		return HAM_SUPERCEDE
	}
	return HAM_IGNORED
}

public WeaponBox_Spawn(weaponbox)
{	

	g_FhSetModel = register_forward(FM_SetModel, "WeaponBox_Spawn2")

	//client_print(0, print_chat, "[g_FhSetModel] %d for %d " , g_FhSetModel , weaponbox) ;
	return HAM_IGNORED;

}


public WeaponBox_Spawn2(weaponbox)
{	   
	// 82 = spades // 84 rifles
	new activeitem
	new cls[32]
	pev(weaponbox ,pev_classname, cls, 31 )
	if(equal(cls,"weaponbox"))
	{
		activeitem = get_pdata_cbase(weaponbox, 82, 4);
		if(activeitem > 1)
		{
			pev(activeitem ,pev_classname, cls, 16 )
			unregister_forward(FM_SetModel, g_FhSetModel)
			//client_print(0, print_chat, "[spawn2] weaponbox %d contain  %s , item %d ", weaponbox , cls, activeitem)
			set_pev(weaponbox,pev_classname,"fly_knife")
			WeaponBox_Retune(weaponbox)
			return FMRES_HANDLED;	
		}
		return FMRES_IGNORED
	}
	
	// unregister_forward(FM_SetModel, g_FhSetModel)
	return FMRES_IGNORED
	
}	

public WeaponBox_Retune(weaponbox)
{
	new id_owner 
	id_owner = pev(weaponbox,pev_owner)
    if(!is_user_alive(id_owner) || is_user_bot(id_owner))
        {
            return PLUGIN_HANDLED
        }
	new float:vlc[3], float:ang[3]
	velocity_by_aim(id_owner, get_pcvar_num(cv_spspeed), vlc )
	//velocity_by_aim(id_owner, 1600, vlc )
	//server_print("%f %f %f ", vlc[0],vlc[1],vlc[2])		
	vector_to_angle(vlc, ang)	
	
	ang[0] += 45.0
	ang[2] += 80.0

	emit_sound(weaponbox,CHAN_AUTO,g_ThrowSound,0.9,ATTN_NORM,0,PITCH_NORM)
	set_pev(weaponbox, pev_angles, ang)
	engfunc(EngFunc_SetSize, weaponbox, Float:{-2.0, -2.0, -2.0}, Float:{2.0, 2.0, 2.0})
	set_pev(weaponbox,pev_movetype,MOVETYPE_TOSS)	
	set_pev(weaponbox,pev_solid,SOLID_TRIGGER)
	set_pev(weaponbox,pev_velocity, vlc)
	set_pev(weaponbox,pev_avelocity,TumbleVector)	
	//set_pev(weaponbox,pev_gravity, 0.1)
    if(cv_trail)
    {
        message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
        write_byte(TE_BEAMFOLLOW)	// Temp entity type
        write_short(weaponbox)		// entity
        write_short(g_SpriteBlood2)	// sprite index
        write_byte(4)	// life time in 0.1's
        write_byte(2)	// line width in 0.1's
        write_byte(63)	// red (RGB)
        write_byte(63)	// green (RGB)
        write_byte(63)	// blue (RGB)
        write_byte(20)	// brightness 0 invisible, 255 visible
        message_end()
    }

	
	set_task(0.13, "WeaponBox_Sound", weaponbox)
}

public WeaponBox_Touch(id_knife,id_target)
{	
	// Register Universal data
	new Float:f_Ori[3]
	new i_Ori[3]
	entity_get_vector(id_knife,EV_VEC_origin,f_Ori)
	FVecIVec(f_Ori,i_Ori)
	new id_owner = pev(id_knife, pev_owner)
	
	switch(g_arr[id_owner][knifetype])
	{
		case DODW_AMERKNIFE:
		{
			//engfunc(EngFunc_SetModel,id_knife,KNIVES_MODELS[0])

		}
		case DODW_GERKNIFE:
		{
			// 
		}
		case DODW_SPADE:
		{
			engfunc(EngFunc_SetModel,id_knife,KNIVES_MODELS[2])  // need to replace weaponbox model
		}
		case DODW_BRITKNIFE:
		{
			// g_arr[id_owner][knifetype] = 1  // need to register hud kill message icon
		}
	}
	if(id_owner==id_target) return PLUGIN_CONTINUE	
	// Start Difference touch
	// PLAYERS
	if(id_target >= 1 && id_target <= g_maxpl)
	{
		// hits players
		// FX 
		emit_sound(id_knife,CHAN_AUTO,g_ThrowHitHumanSound,0.4,ATTN_IDLE ,0,PITCH_NORM)
		if(get_pcvar_num(cv_bldsprt) == 1)
		{
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY) 
			write_byte(TE_BLOODSPRITE)
			write_coord(i_Ori[0])
			write_coord(i_Ori[1])
			write_coord(i_Ori[2])
			write_short(g_SpriteBlood)
			write_short(g_SpriteBlood)
			write_byte(248)
			write_byte(2)
			message_end()
		}
		else
		{
			message_begin(MSG_BROADCAST,g_msgBloodPuff,{0,0,0},0)
			write_coord(i_Ori[0])
			write_coord(i_Ori[1])
			write_coord(i_Ori[2])
			message_end()
		}

		if(g_FriendlyFire == 1 )
		{
			//kill qll

			user_silentkill(id_target)

			dod_set_user_kills(id_owner, (dod_get_user_kills(id_owner) + 1), 1)
			//dod_set_pl_deaths(id_target,(dod_get_pl_deaths(id_target) + 1), 1)
			//dod_set_user_score(id_target,(dod_get_user_score(id_target)),1)
			
			
			message_begin(MSG_ALL, g_MsgDeathMsg,{0,0,0},0)
			write_byte(id_owner) // killer
			write_byte(id_target) // victim
			write_byte(g_arr[id_owner][knifetype])  // 42 is smash
			message_end()

			
			
			set_pev(id_knife, pev_classname, "weaponbox")
			set_pev(id_knife, pev_avelocity,{60.0 , 50.0 , 150.0})
			set_pev(id_knife, pev_velocity,{60.0 , 50.0 , 50.0})
			return PLUGIN_CONTINUE
			
		}
		else if(g_arr[id_owner][team] != get_user_team(id_target) && g_FriendlyFire == 0)
		{
			//kill enemy only

			user_silentkill(id_target)
			
			dod_set_user_kills(id_owner, (dod_get_user_kills(id_owner) + 1),1)
			//dod_set_pl_deaths(id_target,(dod_get_pl_deaths(id_target) + 1),1)
			//dod_set_user_score(id_target,(dod_get_user_score(id_target)),1)
			message_begin(MSG_ALL, g_MsgDeathMsg,{0,0,0},0)
			write_byte(id_owner) // killer
			write_byte(id_target) // victim
			write_byte(g_arr[id_owner][knifetype])  // 42 is smash
			message_end()

			
			
			set_pev(id_knife, pev_classname, "weaponbox")
			set_pev(id_knife, pev_avelocity,{60.0 , 50.0 , 150.0})
			set_pev(id_knife, pev_velocity,{60.0 , 50.0 , 50.0})
			return PLUGIN_CONTINUE
		}
		else if (g_arr[id_owner][team] == get_user_team(id_target) && g_FriendlyFire == 0)
		{	

			set_pev(id_knife, pev_classname, "weaponbox")
			set_pev(id_knife, pev_avelocity,{60.0 , 50.0 , 150.0})
			set_pev(id_knife, pev_velocity,{60.0 , 50.0 , 50.0})
			return PLUGIN_CONTINUE
		}

	}
	else if (id_target==0)
	{
		// hit world or entities

		// FX	
		message_begin(MSG_ALL,SVC_TEMPENTITY)
		write_byte(TE_SPARKS)
		write_coord(i_Ori[0])
		write_coord(i_Ori[1])
		write_coord(i_Ori[2])
		message_end()
		emit_sound(id_knife, CHAN_AUTO, g_ThrowHitwallSound, 0.8, 1.0, 0, PITCH_NORM)
		
		set_pev(id_knife, pev_classname, "weaponbox")
		set_pev(id_knife, pev_avelocity,{60.0 , 50.0 , 150.0})
		set_pev(id_knife, pev_velocity,{60.0 , 50.0 , 50.0})

		if(get_pcvar_num(cv_stackinwall) == 1)
		{
			set_pev(id_knife, pev_movetype, MOVETYPE_NONE)
			set_task(2.0, "WeaponBox_Unstuck", id_knife)
			return PLUGIN_CONTINUE
		}
		return PLUGIN_CONTINUE
	}
	else if (id_target > g_maxpl)
	{
		///// IF ENTITY OR BREACABLE
		new clT[32]
		pev(id_target, pev_classname, clT, 31)
		
		// FX	
		message_begin(MSG_ALL,SVC_TEMPENTITY)
		write_byte(TE_SPARKS)
		write_coord(i_Ori[0])
		write_coord(i_Ori[1])
		write_coord(i_Ori[2])
		message_end()
		emit_sound(id_knife, CHAN_AUTO, g_ThrowHitwallSound, 0.8, 1.0, 0, PITCH_NORM)


		if(equal(clT,"func_breakable")) 
		{
			new tgn[32]
			entity_get_string(id_target,EV_SZ_targetname,tgn,31)

			// for example in DOD_CHARLIE or CAEN we have some breakeble object which has target name , 
			// thats why we shouldn't destriy this.
			if(!tgn[0])
			{
				emit_sound(id_knife, CHAN_AUTO, g_ThrowHitwallSound, 0.3, 1.0, 0, PITCH_NORM)
				// new idAttacker = pev(id_knife, pev_owner)
				ExecuteHam(Ham_TakeDamage,id_target, 1, 1, 30.0, DMG_BULLET)
				
			}
			//client_print(0, print_chat, "[FUNCBREAK] %s %s ",clT, tgn )
		}
		set_pev(id_knife, pev_classname, "weaponbox")
		set_pev(id_knife, pev_avelocity,{60.0 , 50.0 , 150.0})
		set_pev(id_knife, pev_velocity,{60.0 , 50.0 , 50.0})
		return PLUGIN_CONTINUE
	}
	return PLUGIN_CONTINUE
}

public WeaponBox_Unstuck(id_knife)
{
	
	if(pev_valid(id_knife))
	{	
		set_pev(id_knife,pev_movetype,MOVETYPE_TOSS)
		set_pev(id_knife,pev_avelocity,{60.0 , 50.0 , 150.0})
		set_pev(id_knife,pev_velocity,{0.0 , 0.0 , 0.0})
	}
}

public WeaponBox_Sound(id_knife)
{
	new classname[32] // weapon_spade/knife/gerknife
	if(pev_valid(id_knife)) 
	{
		pev(id_knife, pev_classname,  classname,31)
		if(equal(classname,"fly_knife")) 
		{
			emit_sound(id_knife,CHAN_AUTO,g_ThrowSound,0.5,ATTN_NORM,0,PITCH_HIGH)
			set_task(0.12, "WeaponBox_Sound", id_knife)
		}	
	}
}

public Particle_Fx()
{
	static Float:origin[3]
	
	switch (read_data(5)) 
	{
		case 54..58: 
		{		// is decal shot1-5?
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
		default: 
		{
			return
		}
	}	
}