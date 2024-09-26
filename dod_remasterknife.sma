/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <dodx>
#include <dodfun>
#include <fun>
#include <engine>


#define PLUGIN "DOD_KNIFENEWDROP TON"
#define VERSION "1.0"
#define AUTHOR "TONY"

#define KNIFE_ID 1982


new p_on, p_wpn_damage, p_wpn_speed, p_wpn_time_alive, wpn_id

new maxplayers
new gMsgAmmoX


new bool:g_can_throw[33] // ���������� �� �������
new g_FhSetModel  
new KNIVES_NAMES[3][] = {"weapon_amerknife","weapon_gerknife","weapon_spade"}
new KNIVES_MODELS[3][] = {"models/w_amerk.mdl","models/w_paraknife.mdl","models/w_spade.mdl"}

new const g_szAxisParaKnife2[] = "models/w_spade.mdl"


new const g_szClassName[] = "thrown_weapon"
new const g_szOrgClassName[] = "weaponbox"
new const g_ThrowSound[] = "weapons/knifeswing2.wav"
new const g_ThrowFlySound[] = "weapons/whizz11.wav"
new const g_ThrowHitwallSound[] = "weapons/hit_wood1.wav"
new const g_ThrowHitHumanSound[] = "weapons/hit_grass2.wav"

public plugin_precache()
{
	precache_model("models/w_spade.mdl")
	precache_sound(g_ThrowSound)
	precache_sound(g_ThrowFlySound)
	precache_sound(g_ThrowHitwallSound)
	precache_sound(g_ThrowHitHumanSound)
	
}


public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	for(new i = 0; i < 3; i++)
	{
		RegisterHam(Ham_DOD_Item_CanDrop,KNIVES_NAMES[i],"func_WeaponDrop")
	}
	RegisterHam(Ham_Spawn, "weaponbox", "WeaponBox_Spawn", 1)
	
	gMsgAmmoX = get_user_msgid("AmmoX")
	maxplayers = get_maxplayers()
	
	p_on = 1
	p_wpn_damage  = 200
	p_wpn_speed  =  700.0
	p_wpn_time_alive = 1.0
	// Add your code here...
}


/// �������� ������ ������ 2
static bool:g_i_status[33]
public client_connect(i_player)
	g_i_status[i_player]=false

public client_PreThink(i_player){
	if(pev(i_player,pev_button)&IN_ATTACK2)
	{
		if(g_i_status[i_player]==false)
		{
			g_i_status[i_player]=true // �����  i_player ������ +attack2
			
			throw_wpn(i_player)
			PLUGIN_HANDLED;
		}
	}      
	else {
		if(g_i_status[i_player]==true)
		{
			g_i_status[i_player]=false // ����� i_player ������ -attack2
		}
	}
}
///////////////////////////////////////////

///// ��������� ������ �� ��� BASE CALL
public throw_wpn(id)
{
	if(is_user_alive(id) && !is_wpn_heavy(id))
	{
		g_can_throw[id]=true
		client_cmd(id,"drop")
		client_print(id,print_chat, "mouse2+")
		// client_cmd(id,"slot3")

		emit_sound(id,CHAN_BODY,g_ThrowSound,0.9,ATTN_NORM,0,PITCH_NORM)
		
		/////////
				
		return PLUGIN_HANDLED	
		
	}
}


///  CHECK
stock is_wpn_heavy(id)  
{     
	new clip, ammo, 
	wpn = get_user_weapon(id, clip, ammo)     
	if(wpn == DODW_MORTAR
	//	|| wpn == DODW_AMERKNIFE
	//	|| wpn == DODW_GERKNIFE
	|| wpn == DODW_COLT
	|| wpn == DODW_LUGER
	|| wpn == DODW_GARAND
	|| wpn == DODW_SCOPED_KAR
	|| wpn == DODW_THOMPSON
	|| wpn == DODW_STG44
	|| wpn == DODW_SPRINGFIELD
	|| wpn == DODW_KAR
	|| wpn == DODW_BAR
	|| wpn == DODW_MP40
	|| wpn == DODW_HANDGRENADE
	|| wpn == DODW_STICKGRENADE
	|| wpn == DODW_STICKGRENADE_EX
	|| wpn == DODW_HANDGRENADE_EX
	|| wpn == DODW_MG42
	|| wpn == DODW_30_CAL
	//	|| wpn == DODW_SPADE 
	|| wpn == DODW_M1_CARBINE
	|| wpn == DODW_MG34
	|| wpn == DODW_GREASEGUN
	|| wpn == DODW_FG42
	|| wpn == DODW_K43
	|| wpn == DODW_ENFIELD
	|| wpn == DODW_STEN
	|| wpn == DODW_BREN
	|| wpn == DODW_WEBLEY
	|| wpn == DODW_BAZOOKA
	|| wpn == DODW_PANZERSCHRECK
	|| wpn == DODW_PIAT
	|| wpn == DODW_SCOPED_FG42
	|| wpn == DODW_KAR_BAYONET
	|| wpn == DODW_SCOPED_ENFIELD
	|| wpn == DODW_MILLS_BOMB
	//	|| wpn == DODW_BRITKNIFE
	|| wpn == DODW_GARAND_BUTT
	|| wpn == DODW_ENFIELD_BAYONET
	|| wpn == DODW_K43_BUTT)
	return 1  
	return 0
}

/// ANSWER from HAM	

public func_WeaponDrop(ent)
{
	if(pev_valid(ent))
		{
		// set_task(0.1,"func_ChangeModel",ent)
		new world_ent = pev(ent,pev_owner) // get ammobox owner
		static classname[32]  // ������ ����������� ����� 
		pev(ent,pev_classname,classname,31)
		client_print(world_ent,print_chat, "ammobox: %s %d",classname , ent )
		set_pev(ent, pev_velocity, 500.0)
		SetHamReturnInteger(1)

		return HAM_SUPERCEDE
		}
		
	return HAM_IGNORED
}

public WeaponBox_Spawn(iEnt)
{
	g_FhSetModel = register_forward(FM_SetModel, "SetModel")
}
////////////////////////////////////////////////////////////////////////////////////////////////////
public SetModel(iEnt)
{
	new id = pev(iEnt, pev_owner)
	
	if(is_user_alive(id) && !is_wpn_heavy(id) && g_can_throw[id])
	{
		new Float:fVelocity[3]
		velocity_by_aim(id,500.0, fVelocity)
		// fVelocity[2] += 180.0
		set_pev(iEnt, pev_velocity, fVelocity)
		
		/// rotation 
		new Float:TumbleVector[3]			
		TumbleVector[0] = random_float(-500.0,-501.0) // = 1320.0  // Wheel
		// TumbleVector[1] // = random_float(800.0,100.0)  // TEA
		TumbleVector[2] = random_float(-60.0,60.0) // 400.0 // = random_float(2.0,0.0) //  HOURS
		
		
		new Float:f5Angles[3], Float:f5Origin[3]
		
		vector_to_angle(fVelocity, f5Angles)
		pev(id, pev_origin, f5Origin)
		
		f5Angles[0] += 55.0
		// f5Angles[1] // 
		f5Angles[2] += 90.0
		
		set_pev(iEnt, pev_angles, f5Angles)
		
		set_pev(iEnt, pev_avelocity, TumbleVector)
		engfunc(EngFunc_SetSize, iEnt, Float:{-6.0, -6.0, -6.0}, Float:{6.0, 6.0, 6.0})
		// set_pev(iEnt, pev_classname, g_szClassName)
		set_pev(iEnt, pev_solid, SOLID_TRIGGER)
		g_can_throw[id]=false
		// set_task(get_pcvar_float(p_wpn_time_alive),"BackToNormal",iEnt)
		
		// thwrowspadeani(id)
		
		
		new world_ent = pev(iEnt,pev_owner) // get ammobox owner
		static classname[32]  // ������ ����������� ����� 
		pev(iEnt,pev_classname,classname,31) 
		
		/// now classname weaponbox 
		static  wbCont[32]
		pev(iEnt,pev_globalname,wbCont,31)
		client_print(0,print_chat, "ammobox2: %s %d  22 %s",classname , iEnt , wbCont)
		
		
		emit_sound(id,CHAN_BODY,g_ThrowSound,0.9,ATTN_NORM,0,PITCH_NORM)
		
		emit_sound(iEnt,CHAN_AUTO,g_ThrowFlySound,0.4,ATTN_IDLE ,0,PITCH_NORM)
		
	//	custom_weapon_shot(wpn_id,id)
		
		
		
	}
	unregister_forward(FM_SetModel, g_FhSetModel)
}
////////////////////////////////////////////////////////////////////////////////////////////////////
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1049\\ f0\\ fs16 \n\\ par }
*/