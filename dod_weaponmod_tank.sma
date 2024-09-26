#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>
#include <fakemeta_util>
#include <fun>
#include <dodx>
#include <dodfun>
#include <dodconst>
#include <dodstats>
#include <dod_stocks>
#include <hamsandwich>


// Linux extra offsets
#define linux_diff_weapon 4
#define linux_diff_player 5
#define linux_diff_animation 4

// Dod CbaseWeapon offsets
#define m_flNextPrimaryAttack 103 	// float
#define m_flNextSecondaryAttack 104 // float
#define m_flTimeWeaponIdle 105 	// float	
#define m_flNextAttack 211 // float

#define m_iClip 108  			// int
/// WANTED! SETTER FOR AMMO
#define m_pPlayer 89 			// int returns owner's of weapon
#define m_knifeItem 272			// prt ножа 
#define m_pistolItem 273        //  ptr пистолета в инвентаре
#define m_rifleItem 274        //  ptr основы в инвентаре
#define m_pActiveItem 278 		// возвращает Entity id оружия в руках (не константу) + linux_diff_player
#define m_rgpPlayerItems 81		// Weaponbox ячейки
#define m_fInReload	111         //  Integer 
#define m_iWeaponState 115		// IS BAZOOKA/PIAT/PSCHREK Shouldered

///  AMMOTYPES FOR HUD_AMMO
#define AMMO_SMG 1 // thompson, greasegun, sten, mp40
#define AMMO_ALTRIFLE 2 // carbine, k43, mg34
#define AMMO_RIFLE 3 // garand, enfield, scoped enfield, k98, scoped k98
#define AMMO_PISTOL 4 // colt, webley, luger
#define AMMO_SPRING 5 // springfield
#define AMMO_HEAVY 6 // bar, bren, stg44, fg42, scoped fg42
#define AMMO_MG42 7    // mg42
#define AMMO_30CAL 8 // 30cal
#define AMMO_GREN 9 // grenades (should be all 3 types)
#define AMMO_ROCKET 13 // bazooka, piat, panzerschreck

////////////////// Переопределения 
// проверка на кастомность	
#define Is_custom_w(%0) (pev(%0, pev_impulse) == WEAPON_SPECIAL_CODE) 

new g_msgCurWeapon;
new g_msgAmmoX; 
new g_FhSetModel;

//// temp service data 
new bool:ready_to_shoot = false
new clsname[64];
new idowner;
new activeitem;
new bool: camrock = true

#define WEAPON_SPECIAL_CODE 20112022 // need to change if you make another sma file with new weapon.
#define WEAPON_REFERENCE "weapon_piat"
#define WEAPON_ITEM_NAME "TANK34"

#define HUD_CLIP_ICON DODW_MG34 	// HUD CLIP ICON 25 == Enfield // HUD AMMO is AMMO_RIFLE
//#define HUD_AMMO_ICON 20 	// NOT USED
#define WEAPON_DAMAGE 1  	// DAMAGE MULTIPLIER
#define FIRE_RATE 1.5   	// shooting speed per
#define WEAPON_ANIM_RELOAD_TIME 2.5	// ERROR
#define WEAPON_MAXCLIP 30
#define WEAPON_PUNCHAGNLE 0.01	// NOT USING YET

#define WEAPON_SOUND_SHOOT "weapons/red/avt40fire.wav"
new const WEAPON_MODEL_VIEW[] = "models/red/tiger/v_tiger_shit.mdl";
new const WEAPON_MODEL_PLAYER[] = "models/red/tiger/p_tiger.mdl";
new const WEAPON_MODEL_WORLD[] = "models/red/tiger/p_tiger_idle.mdl";


/*
- retun after all func
- reassigned giveweapon
- cleared reload pre
- weaponbox new rule

*/
#define AUTHOR "[America][TheVaskov]"

public plugin_init()
{
	register_plugin("DOD Doors Blows","0.0","America")
		
	// register_clcmd("say info", "Info_weapon")
	register_clcmd("say /tiger", "CustomWeapon_Give")
	

	// User Messages for Hud_Update_Ammo
	g_msgCurWeapon = get_user_msgid("CurWeapon")
	g_msgAmmoX = get_user_msgid("AmmoX");

	// Register Event / Signals
	// Updates HUD ammo, v_, p_ models
	register_event("CurWeapon", "CurWeapon_Check", "be", "1=1")
	// after reloading, set WEAPON_CLIP
	register_event("ReloadDone", "CurWeapon_Reload_Done", "be", "1=1")
	
	// Attack1
	RegisterHam(Ham_Weapon_PrimaryAttack,	WEAPON_REFERENCE,	"CurWeapon_PrimaryAttack_Pre", true);
	RegisterHam(Ham_Weapon_SecondaryAttack,	WEAPON_REFERENCE,	"CurWeapon_SecondaryAttack_Pre", true);

	RegisterHam(Ham_Player_Jump, "player", "Player_Jump", 0) 
	RegisterHam(Ham_Player_Duck, "player", "Player_Duck", 0)

	// register_forward(FM_CmdStart,"block_button")
	// register_forward(FM_CmdStart,"fw_CmdStart")

	//  Reload Start
	// RegisterHam(Ham_Weapon_Reload,			WEAPON_REFERENCE,	"CurWeapon_Reload_Pre", false);

	// Spawn Weaponbox
	RegisterHam(Ham_Spawn, "weaponbox", "WeaponBox_Spawn", true)
	// Ham_Item_Drop /
	
	// Accept to drop out for any weapon_name
	//RegisterHam(Ham_DOD_Item_CanDrop, "weapon_stickgrenade","CurWeapon_Drop")

}

public plugin_precache()
{
	// Precache models
	engfunc(EngFunc_PrecacheModel, WEAPON_MODEL_VIEW);
	engfunc(EngFunc_PrecacheModel, WEAPON_MODEL_PLAYER);
	engfunc(EngFunc_PrecacheModel, WEAPON_MODEL_WORLD);
	// Precache sounds
	engfunc(EngFunc_PrecacheSound, WEAPON_SOUND_SHOOT);
}

public CurWeapon_SecondaryAttack_Pre(activeitem)
{
	if (!Is_custom_w(activeitem)) return HAM_IGNORED;
	else if (Is_custom_w(activeitem))
	{
		new shoulder = get_pdata_int( activeitem, m_iWeaponState , linux_diff_weapon );
		// client_print(0, print_chat, "2 m_iWeaponState %d", shoulder)
		// set_pdata_int( activeitem, m_iWeaponState , 1 ,linux_diff_weapon );  // 1 = SCOOPED
		if (shoulder)
		{	// UNBLOCK MOVE 
			//
			set_pev(idowner, pev_vuser1, {0.0 , 0.0 , 0.0} )
			set_pev(idowner, pev_weaponmodel2, WEAPON_MODEL_PLAYER);
			// set_pev( idowner, pev_iuser3, 0 )  // UN-DEploy at crouch!
		}
		else
		{
			// set DEPLOY -state STAND MG42  for block:  move , jump , crouch , prone
			set_pev(idowner, pev_vuser1, {2.0 , 0.0 , 0.0} )
			set_pev(idowner, pev_weaponmodel2, WEAPON_MODEL_WORLD);

			// set_pdata_int( activeitem, m_iWeaponState , 1 ,linux_diff_weapon );
			
			// set_pev( idowner, pev_iuser3, 3 )  // DEploy at crouch!
		}

		idowner = get_pdata_cbase(activeitem, m_pPlayer, linux_diff_weapon);
		// set_pev( idowner, pev_iuser3, 3 ); // 0 NOT PRONED , 1 = RPONE , prone deployd / 3 DEPLOY BLOCKS MOVE,DUCK,RPONE
		// 
		//static Float:origin[3], Float:view_ofs[3]
		//static Float:VEC_DUCK_VIEW[3] = {0.0, 0.0, 120.0}
		//pev(idowner, pev_origin, origin)
		//pev(idowner, pev_view_ofs, view_ofs)
		//set_pev(idowner, pev_view_ofs, VEC_DUCK_VIEW);

		return HAM_IGNORED;
	}
	return HAM_IGNORED;
 	
}


public CurWeapon_PrimaryAttack_Pre(idWeapon)
{
	
	new Float:time = get_pdata_float( idWeapon, m_flNextPrimaryAttack );
	if (!Is_custom_w(idWeapon)) return HAM_IGNORED;
	else if (ready_to_shoot == true && time > 0.0) 
	{
// idWeapon == id Entity of weapon_name == activeitem
// получить id выстреливаюшего
idowner = get_pdata_cbase(idWeapon, m_pPlayer, linux_diff_weapon);

// назначить звук выстрела
// emit_sound(idowner, CHAN_WEAPON, WEAPON_SOUND_SHOOT, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
// установить скорость выстрела
set_pdata_float(idWeapon, m_flNextPrimaryAttack, FIRE_RATE, linux_diff_weapon);

// Используем множитель атаки 
// RegisterHam(Ham_TraceAttack, "func_breakable",	"Register_damage", 0);
/*
// получить entity id текущего оружия
activeitem = get_pdata_cbase(idowner, m_pActiveItem, linux_diff_player);
// устнаовить количество патронов
set_pdata_int(idWeapon, m_iClip, 15, linux_diff_weapon);
/// назначит оружие специальный код
set_pev(activeitem, pev_impulse, WEAPON_SPECIAL_CODE);;
	*/
	
	return HAM_SUPERCEDE;
	}
	return HAM_IGNORED;
}
public CurWeapon_Reload_Pre(activeitem)
{	
	if (!Is_custom_w(activeitem)) return HAM_IGNORED; // не вносит изменения.
	else 
	{
	/*
	// client_print(0, print_chat, "RELOAD START FOR CUSTOM WEAPON")
	set_pdata_float(activeitem, m_flTimeWeaponIdle, WEAPON_ANIM_RELOAD_TIME, linux_diff_weapon);

	// получить id выстреливаюшего
	idowner = get_pdata_cbase(activeitem, m_pPlayer, linux_diff_weapon);

	// ERROR: Reloading animation breaks to idle , need to set time before register_event("ReloadDone",
	
	set_pdata_float(activeitem, m_flNextPrimaryAttack, WEAPON_ANIM_RELOAD_TIME, linux_diff_weapon);
	set_pdata_float(activeitem, m_flNextSecondaryAttack, WEAPON_ANIM_RELOAD_TIME, linux_diff_weapon);
	set_pdata_float(activeitem, m_flTimeWeaponIdle, WEAPON_ANIM_RELOAD_TIME, linux_diff_weapon);
	set_pdata_float(idowner, m_flNextAttack, WEAPON_ANIM_RELOAD_TIME, linux_diff_player);

	//set_pdata_float(get_pdata_cbase(ent, m_pPlayer, 4), m_flNextAttack, 2.9, 5);
	// set_pdata_float(idowner, m_flNextAttack, 2.9, 5);
	// полностью блокирует отловленное событие
	//return HAM_SUPERCEDE; 
	// незнаю set_pdata_int(activeitem, m_fInReload, 0, linux_diff_weapon);
	*/
	return HAM_IGNORED;
	}
	return HAM_IGNORED;
}

public CurWeapon_Reload_Done(idowner)
{	
	if (!is_user_connected(idowner) || !is_user_alive(idowner)) return;

	// получить entity id текущего оружия
	activeitem = get_pdata_cbase(idowner, m_pActiveItem, linux_diff_player);
	if (!Is_custom_w(activeitem)) return;
	else {
	
	// устнаовить количество патронов
	set_pdata_int(activeitem, m_iClip, WEAPON_MAXCLIP, linux_diff_weapon);
	ready_to_shoot = true
	// client_print(idowner, print_chat, "Reload_Custom_CurWeapon  END id: %d", idowner)
	}
	return;
}


//////////////////  WEAPONBOX SPAWEND NEED 
public WeaponBox_Spawn(weaponbox)
{	
	/*
	pev(weaponbox, pev_classname, clsname, 63)
	client_print(0, print_chat, "[Weaponbox] id: %d , Classname: %s  " , weaponbox, clsname ) ;
	entity_get_string(weaponbox, EV_SZ_model , clsname, 63) // ----.mdl	
	client_print(0, print_chat, "[Weaponbox] id: %d , MODEL: %s  " , weaponbox, clsname ) ;
	new ent = -1
	while((ent = find_ent_by_class(ent, WEAPON_REFERENCE)) != 0)
	{		
		client_print(0, print_chat, "[Weaponbox] WEAPON_STEN IS %d " , ent );
	}
	*/
		// Запускаем фукнцию регистрации смены модели
	g_FhSetModel = register_forward(FM_SetModel, "WeaponBox_Retune")

	// client_print(0, print_chat, "[g_FhSetModel] %d " , g_FhSetModel ) ;
	//WeaponBox_Retune(weaponbox)
	return HAM_SUPERCEDE;

}

public WeaponBox_Retune(weaponbox)
{
	/*
	entity_get_string(weaponbox, EV_SZ_model , clsname, 63) // ----.mdl	
	client_print(0, print_chat, "[retune] id %d , model: %s" , weaponbox, clsname ) ;
	*/
	
	pev(weaponbox, pev_classname, clsname, 31)
	if(!equal(clsname, "weaponbox")) return FMRES_IGNORED;
	/// ЧТО лежит в weaponbox ? 
	new cbase = 82
	for ( cbase = 82; cbase < 86; cbase++ ) 
	{
		activeitem = get_pdata_cbase(weaponbox, cbase, 4);
		if (activeitem > 32)
		{
			if Is_custom_w(activeitem)
			{
			unregister_forward(FM_SetModel, g_FhSetModel)
			engfunc(EngFunc_SetModel, weaponbox, WEAPON_MODEL_WORLD) 
			// client_print(0, print_chat, "[WeaponBox_Retune] Custom weapon is id: %d ,in box offset cbase %d ; weaponbox %d " , activeitem , cbase , weaponbox);
			// блокирует функцию, возвращает нужное значение.
			
			return FMRES_SUPERCEDE;
			}
		}
	}
	// unregister_forward(FM_SetModel, g_FhSetModel)
	return FMRES_IGNORED; // +++++
}


public CurWeapon_Drop(weapon_id)
{
	if(is_valid_ent(weapon_id))
	{	
		SetHamReturnInteger(1)
		return HAM_SUPERCEDE
	}
	return HAM_IGNORED
}

///////// HUD AMMO PICTURES
public Hud_Update_ammo(id,ammo)
{	
	// CLIP HUD ICON	
	message_begin(MSG_ONE, g_msgCurWeapon, {0, 0, 0}, id)
	write_byte(1)
	write_byte(HUD_CLIP_ICON)
	write_byte(0)
	message_end()
	
	
	message_begin(MSG_ONE, g_msgAmmoX,{0,0,0},id)
	write_byte(AMMO_ROCKET);
	write_byte(ammo);
	message_end();
	
	/*
	set_hudmessage(190, 255, 190, 0.9, 0.89, .effects= 1 , .holdtime= 3.0)
	show_hudmessage(0, "%d / %d ", clip, ammo)
	*/
	return;
}
public CurWeapon_Check(idowner)
{	
	
	if (!is_user_connected(idowner) || !is_user_alive(idowner)) return;
	// It runs in every Event(CurWeapon)
	activeitem = get_pdata_cbase(idowner, m_pActiveItem, linux_diff_player);
	if (activeitem < 1 ) return;
	if (!Is_custom_w(activeitem)) 
	{	
		// unregister_forward(FM_EmitSound, 1)
		return;
	}
	else if (Is_custom_w(activeitem)) 
	{
	// обновить HUD
	new clip, ammo, myWeapon = dod_get_user_weapon(idowner, clip, ammo)
	if (clip < 1) ready_to_shoot = false
	Hud_Update_ammo(idowner,ammo)
	set_pev(idowner, pev_viewmodel2, WEAPON_MODEL_VIEW);
	set_pev(idowner, pev_weaponmodel2, WEAPON_MODEL_PLAYER);
	// dod_clear_model(idowner)
	// dod_set_model(idowner, WEAPON_MODEL_WORLD)
	/// create an Entity Sized
	// new shoulder = get_pdata_cbase(activeitem, m_iWeaponState, linux_diff_weapon);
	//new shoulder = dod_shouldered(idowner, -1)
	//client_print( 0 , print_chat, "sholuder is %d", shoulder)
	// set_pdata_int( activeitem, m_iWeaponState , 1 ,linux_diff_weapon );  // 1 = SCOOPED


	// set sTAND POSE STATE
	// set_pev( idowner, pev_iuser3, 0 )
	/////////////////////
	new shoulder = get_pdata_int( activeitem, m_iWeaponState , linux_diff_weapon );
		// client_print(0, print_chat, "2 m_iWeaponState %d", shoulder)
		// set_pdata_int( activeitem, m_iWeaponState , 1 ,linux_diff_weapon );  // 1 = SCOOPED
		if (shoulder)
		{	// UNBLOCK MOVE 
			//
			set_pev(idowner, pev_vuser1, {0.0 , 0.0 , 0.0} )
			pev(idowner, pev_weaponmodel2, clsname)
			if (!equal( clsname , WEAPON_MODEL_PLAYER))
			{
				set_pev(idowner, pev_weaponmodel2, WEAPON_MODEL_PLAYER);	
			}
			
			// set_pev( idowner, pev_iuser3, 0 )  // UN-DEploy at crouch!
		}
		else
		{
			
			pev(idowner, pev_weaponmodel2, clsname)
			if (equal( clsname , WEAPON_MODEL_PLAYER))
			{
				set_pev(idowner, pev_weaponmodel2, WEAPON_MODEL_WORLD);	
			}

			// set DEPLOY -state STAND MG42  for block:  move , jump , crouch , prone
			set_pev(idowner, pev_vuser1, {2.0 , 0.0 , 0.0} )
			

			// set_pdata_int( activeitem, m_iWeaponState , 1 ,linux_diff_weapon );
			
			// set_pev( idowner, pev_iuser3, 3 )  // DEploy at crouch!
		}





	//////////////////

	new attach = 0
	if (attach == 1)
	{	
		attach = create_entity("info_target")
    	dllfunc(DLLFunc_Spawn, attach);
    	set_pev(attach, pev_classname, "object_tank");
    	engfunc(EngFunc_SetModel, attach, WEAPON_MODEL_WORLD);
		set_pev(attach, pev_owner, idowner);
		set_pev(attach, pev_aiment, idowner);
		set_pev(attach, pev_movetype, MOVETYPE_FOLLOW);
	}
	/*

	engfunc(EngFunc_SetSize, idowner, Float:{-162.0, -162.0, -0.0}, Float:{162.0, 162.0, 124.0});
	*/

	return;
	}
	else return;
}
public CustomWeapon_Give(idowner)
{
	if (!is_user_connected(idowner) || !is_user_alive(idowner)) return;
	// Get weapon entity ID of client's primary weapon - returns -1 on none
	new temp_cur_weapon_ent_id = get_pdata_cbase(idowner, m_rifleItem) // to frop pistol use m_pistolItem
	if (temp_cur_weapon_ent_id != -1)
	{
	new temp_class_name[17]
	pev(temp_cur_weapon_ent_id,pev_classname,temp_class_name,16)
	// client_print(0, print_chat, "GIVE: temp cur = %d classname is %s .", temp_cur_weapon_ent_id, temp_class_name );
	engclient_cmd(idowner,"drop",temp_class_name)
	}

	temp_cur_weapon_ent_id = give_item(idowner, WEAPON_REFERENCE)
	// client_print(0, print_chat, "Player: %d , id=gived: %d", idowner, temp_cur_weapon_ent_id)
	engclient_cmd(idowner, WEAPON_REFERENCE )
	CustomWeapon_Retune(temp_cur_weapon_ent_id)
	return;

}

////////////////// Retune Weapon Set Custom Code to Impulse
public CustomWeapon_Retune(activeitem)
{

	// получить entity id текущего оружия
	// activeitem = get_pdata_cbase(idowner, m_pActiveItem, linux_diff_player);
	/// назначит оружие специальный код
	set_pev(activeitem, pev_impulse, WEAPON_SPECIAL_CODE)
	// устнаовить количество патронов
	set_pdata_int(activeitem, m_iClip, WEAPON_MAXCLIP, linux_diff_weapon);
	
	/*
	// обновить HUD
	new clip, ammo, myWeapon = dod_get_user_weapon(idowner, clip, ammo)
	Hud_Update_ammo(idowner,ammo)
	*/
	ready_to_shoot = true
	//// meesage
	// client_print(idowner, print_chat, "Player: %d , WeaponID: %d , retuned to CUSTOM", idowner, activeitem);
	return;
}

public Register_damage(iVictim, iAttacker, Float:flDamage)
{
	return HAM_IGNORED; // НЕ вносит изенения
	// SetHamParamFloat(3, flDamage * WEAPON_DAMAGE);
	// client_print( 0 , print_chat, " DAMAGE : victim %d, Attacke %d , DAmage %f ", iVictim, iAttacker, flDamage)

}




public rocket_shoot(id, rocketindex, wId)
{ 
    
   
	new rocket = engfunc(EngFunc_FindEntityByString, 0, "model", "models/w_piat_rocket.mdl")
	if (!rocket) return;
	///////////////////

	new iOrigin[3], Float:fOrigin[3], Float:Vel[3], Float:Angles[3]
	if (camrock) 
	{
		fm_attach_view(id,rocket)
		camrock = false
	}
	else if(!camrock)
	{
		camrock = true
	}
	// ROTATE ROCKET -100 for Attach camera 
	velocity_by_aim(id, -100, Vel)
	vector_to_angle(Vel, Angles)
	set_pev(rocket, pev_angles, Angles)
	set_pev(rocket, pev_fixangle, 1)

	////////////////// set origin rocket Higher 
	new Float:pOrigin[3];
	pev(rocket, pev_origin, pOrigin)
	pOrigin[2] += 60.0
	set_pev(rocket, pev_origin, pOrigin)
	


}


public Ham_Block(idowner)
{
	new iu3 = pev( idowner, pev_iuser3)   // Values: 0=Not Proned, 1=Proned, 2=Proned and Deployed
	// set_pev(idowner, pev_vuser1, {2.0 , 0.0 , 0.0} ) // 2.0 = Stay and deploy mg42 , mg34
	new Float:fOriginE[3] //
	pev(idowner, pev_vuser1, fOriginE) //
	client_print(0,print_chat," iu3: %d , vu1: %f , %f , %f ", iu3 , fOriginE[0], fOriginE[1], fOriginE[2])
	
	///
	

	if (entity_get_float(idowner, EV_FL_gravity) > 2.0)
	{
		 entity_set_float(idowner, EV_FL_gravity, 1.0)
	}
	else entity_set_float(idowner, EV_FL_gravity, 30.0)
	// set_pev( idowner, pev_iuser3, 0 ) 

	// set DEPLOY -state STAND MG42  for block:  move , jump , crouch , prone
	// set_pev(idowner, pev_vuser1, {2.0 , 0.0 , 0.0} )

	return HAM_SUPERCEDE;
}

public dod_client_prone(idowner, value)
{
	// block prone
	/*
	Called whenever the the player goes to or comes from prone position
	value = 1 going down , value = 0 getting up
	client_print(0,print_chat," prone :%d ", value )
	*/
	set_pev( idowner, pev_iuser3, 0 ) 
	// set_pev(idowner, pev_vuser1, {2.0 , 0.0 , 0.0} )
	set_pev(idowner, pev_weaponmodel2, WEAPON_MODEL_WORLD);
}
/*
public dod_client_weaponswitch(id, wpnew, wpnold)
{	
	// wnew == 19 == DODW_SPADE
	client_print(0,print_chat," dod_client_weaponswitch :%d old - %d", wpnew, wpnold )

}
*/


////// NOT USED
public block_button(idowner, uc_handle, random_seed )
{
	static button; button = get_uc( uc_handle, UC_Buttons );
    
    if( button & IN_JUMP )
    { 
		set_pev( idowner, pev_iuser3, 0 ) 
		/*
        new Float:fVel[ 3 ];
        pev( id, pev_velocity, fVel );
        fVel[ 2 ] = -200.0 // float( -abs( floatround( fVel[ 2 ] ) ) ) 
        set_pev( id, pev_velocity, fVel )
		//  buttons &= ~IN_JUMP;
		*/
    } 
}


/// WORKED
public Player_Jump(id)
{
    static iOldbuttons ; iOldbuttons = entity_get_int(id, EV_INT_oldbuttons)
    if( !(iOldbuttons & IN_JUMP) )
    {
        entity_set_int(id, EV_INT_oldbuttons, iOldbuttons | IN_JUMP)
        return HAM_HANDLED
    }
    return HAM_IGNORED
} 

/// WORKED CALL 
public Player_Duck(id)
{	

	// set_pev(idowner, pev_vuser1, {2.0 , 0.0 , 0.0} )
	set_pev(idowner, pev_weaponmodel2, WEAPON_MODEL_WORLD);

	//set_pev(id, pev_button, pev(id, pev_button) & ~IN_DUCK)
	// set_pev(id, pev_oldbuttons, pev(id, pev_oldbuttons) | IN_DUCK)
	//set_pev(id, pev_flags, pev(idowner, pev_flags) | FL_DUCKING)
} 