/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <fakemeta_util>
#include <dodx>
#include <dodfun>
#include <fun>
#include <engine>
#include <xs>

#define PLUGIN "DOD TEST EXAMPLES"
#define VERSION "12apr2222"
#define AUTHOR "[America][TheVaskov]"


#define OFFSET_WPN_ID			91
#define OFFSET_WPN_CLIP 		108
#define OFFSET_PISTOL_BPAMMO_LINUX	52
#define OFFSET_PISTOL_BPAMMO_WIN32	53
#define OFFSET_LINUX 			4
#define COUNTFLOTA 	0.2

new g_msgIconstatus
new g_msgIcstSprite
new g_msgHudText
new g_msgStatusValue

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	
	register_clcmd("say clip", "set_clip") // установить  clip current
	register_clcmd("say mdl", "set_model_byfindclass") // установить  clip current
	register_clcmd("say parser", "parser_string_ent") // pars String , edict , integer
	register_clcmd("say stic", "ex_statusicon")     /// 
	register_clcmd("say zenit", "setnoclip")           // 
	register_clcmd("say pvo", "setnonoclip")         // 
	register_clcmd("say weap0", "forceweapon0")         // 
	register_clcmd("say ha1", "parse_weapon_offset")  // parse weapon offsets shoottime sound 
	
	register_clcmd("say huddog", "func_hudmessage")   // HUD MESSAGE BY DOG WBARK
	register_clcmd("say stva", "func_StatusValue")
	register_clcmd("say som", "func_eventbulletwall")   // WALLSHOT WITH SOUND AND SPRITES AND PARCTICLES 
	register_clcmd("say gaim", "func_getuseraiming")     // GET AIM USER NAME AND TYPE HUD MESSAGE CENTER
	register_clcmd("say pmodel1", "set_p_weapon_submodel") // SETS BODYMODEL FOR PLAYER AXIS ALLIES
	register_clcmd("say strip", "func_weapon_strip") // WEAPON STRIP USER
	register_clcmd("say shake", "func_scrshake") // SCREENSHAEK
	 
	
	
	
	
	register_clcmd("say winfo", "func_weapon_info_full") // Gives weaponinfo id clip etc
	register_clcmd("say wcb", "func_cbase_pdata") 
	g_msgHudText = get_user_msgid("HudText")
	g_msgStatusValue = get_user_msgid("StatusValue")
	
	
	g_msgIconstatus = get_user_msgid("StatusIcon")
	
}

public plugin_precache(){
	g_msgIcstSprite = precache_model("sprites/german.spr")

}
////////// CLIP SETTER
public set_clip(id){
	// id = player , weapon_name[] , clip = 0
	set_clip_stock(id,"weapon_luger",0) 
}
public  set_clip_stock(id,const weapon[],clip) 
{
	new currentent = -1, gunid = 0
	// get origin
	new Float:origin[3];
	entity_get_vector(id,EV_VEC_origin,origin);
	
	while((currentent = find_ent_in_sphere(currentent,origin,Float:1.0)) != 0)
	{
		new classname[32];
		entity_get_string(currentent,EV_SZ_classname,classname,31);
		
		if(equal(classname,weapon))
			gunid = currentent
	}
	
	set_pdata_int(gunid,108,clip,4); // set their ammo (4 is linux update setting)
	return PLUGIN_CONTINUE
} 


////////////// ENTITY FIND BY NAME AND REPLACE MODEL 

public set_model_byfindclass()
{		
	new ent = -1
	while((ent = find_ent_by_class(ent,"weapon_spade")) != 0)
	{
		entity_set_model(ent,"models/w_98k.mdl")
		
		client_print(0,print_chat, "[SETMODEL] +")
		
		
		///// CAN REMOVE_ENTITY WEAPONBOX
	}
}


public parser_string_ent()
{		
	new ent = -1
	while((ent = find_ent_by_class(ent,"weapon_bren")) != 0) {
		
		// FOUNDED IN AIR AND FLOOR
		// entity_set_model(ent,"models/w_98k.mdl")
		// new Rent = engfunc(EngFunc_FindEntityByString, ent , "model", KNIVES_MODELS[2] )
		/////////// 
		/*
		entity_get_string(ent, EV_SZ_classname , classname, 63) // weaponbox
		
		
		EV_SZ_classname  == weaponbox
		EV_SZ_globalname == 
		
		*/
		// EV_ENT_pContainingEntity
		
		new containent
		entity_get_edict(ent, containent)
		new bxclassname[64], bxglobalname[32], bxmodel[64] , bxtarget[64] , bxtargetnm[64], bxnetname[64], bxmessage[64], bxn[64] , bxn1[64], bxn2[64] , bxn3[64], bxvievmodel[64], bxweapmodel[64]
		entity_get_string(ent, EV_SZ_classname , bxclassname, 63) // weaponbox		
		pev(ent, pev_globalname, bxglobalname, 31 ) // null
		entity_get_string(ent, EV_SZ_model , bxmodel, 63) // ----.mdl	
		entity_get_string(ent, EV_SZ_target , bxtarget, 63)
		entity_get_string(ent, EV_SZ_targetname , bxtargetnm, 63)
		entity_get_string(ent, EV_SZ_netname , bxnetname, 63)
		entity_get_string(ent, EV_SZ_message , bxmessage, 63)
		entity_get_string(ent, EV_SZ_noise , bxn, 63)
		entity_get_string(ent, EV_SZ_noise1 , bxn1, 63)
		entity_get_string(ent, EV_SZ_noise2 , bxn2, 63)
		entity_get_string(ent, EV_SZ_noise3 , bxn3, 63)
		entity_get_string(ent, EV_SZ_viewmodel , bxvievmodel, 63)
		entity_get_string(ent, EV_SZ_weaponmodel , bxweapmodel, 63)
		client_print(0, print_console, "[S] id %d clnm_ %s / glbnm_ %s / model_ %s / trg_ %s / tgnm_ %s ", ent, bxclassname , bxglobalname , bxmodel , bxtarget, bxtargetnm)
		client_print(0, print_console, "[S2] netname %s / msg_ %s / bnx %s %s %s %s / viewmdl %s / wpndml %s ", bxnetname, bxmessage, bxn , bxn1, bxn2 , bxn3 , bxvievmodel, bxweapmodel)
		//remove_entity(ent)
		
		new bx_chain ,bxdmg_inflictor, bx_enemy, bx_aiment,bx_owner, bx_groundentity, bx_pContainingEntity, bx_euser1, bx_euser2, bx_euser3, bx_euser4
		bx_chain = entity_get_edict2(ent, EV_ENT_chain )
		bxdmg_inflictor = entity_get_edict2(ent, EV_ENT_dmg_inflictor )
		bx_enemy = entity_get_edict2(ent, EV_ENT_enemy )
		bx_aiment = entity_get_edict2(ent, EV_ENT_aiment )
		bx_owner = entity_get_edict2(ent, EV_ENT_owner )
		bx_groundentity = entity_get_edict2(ent, EV_ENT_groundentity )
		bx_pContainingEntity = entity_get_edict2(ent, EV_ENT_pContainingEntity )
		bx_euser1 = entity_get_edict2(ent, EV_ENT_euser1 )
		bx_euser2 = entity_get_edict2(ent, EV_ENT_euser2 )
		bx_euser3 = entity_get_edict2(ent, EV_ENT_euser3 )
		bx_euser4 = entity_get_edict2(ent, EV_ENT_euser4 )
		
		client_print(0,print_console, "[e] chain %d dmginf %d enemy %d aiment %d owner %d groundentity %d pContainingEntity %d euser1 %d euser2 %d euser3 %d euser4 %d", bx_chain, bxdmg_inflictor, bx_enemy, bx_aiment,bx_owner, bx_groundentity, bx_pContainingEntity, bx_euser1, bx_euser2, bx_euser3, bx_euser4)
		
		///////////////////
		
		
		new BXINT_gamestate, BXINT_oldbuttons, BXINT_groupinfo, BXINT_iuser1, BXINT_iuser2, BXINT_iuser3, BXINT_iuser4
		new BXINT_weaponanim, BXINT_pushmsec, BXINT_bInDuck, BXINT_flTimeStepSound, BXINT_flSwimTime, BXINT_flDuckTime
		new BXINT_iStepLeft, BXINT_movetype, BXINT_solid, BXINT_skin,  BXINT_body, BXINT_effects, BXINT_light_level
		new BXINT_sequence, BXINT_gaitsequence, BXINT_modelindex, BXINT_playerclass, BXINT_waterlevel, BXINT_watertype, BXINT_spawnflag,BXINT_flags
		new BXINT_colormap, BXINT_team, BXINT_fixangle, BXINT_weapons, BXINT_rendermode, BXINT_renderfx, BXINT_button, BXINT_impulse,  BXINT_deadflag
		
		
		BXINT_gamestate = entity_get_int(ent,EV_INT_gamestate)
		BXINT_oldbuttons = entity_get_int(ent,EV_INT_oldbuttons)
		BXINT_groupinfo = entity_get_int(ent,EV_INT_groupinfo)
		BXINT_iuser1 = entity_get_int(ent,EV_INT_iuser1)
		BXINT_iuser2 = entity_get_int(ent,EV_INT_iuser2)
		BXINT_iuser3 = entity_get_int(ent,EV_INT_iuser3)
		BXINT_iuser3 = entity_get_int(ent,EV_INT_iuser4)
		BXINT_weaponanim = entity_get_int(ent,EV_INT_weaponanim)
		BXINT_pushmsec = entity_get_int(ent,EV_INT_pushmsec)
		BXINT_bInDuck = entity_get_int(ent,EV_INT_bInDuck)
		BXINT_flTimeStepSound = entity_get_int(ent,EV_INT_flTimeStepSound)
		BXINT_flSwimTime = entity_get_int(ent,EV_INT_flSwimTime)
		BXINT_flDuckTime = entity_get_int(ent,EV_INT_flDuckTime)
		BXINT_iStepLeft = entity_get_int(ent,EV_INT_iStepLeft)
		BXINT_movetype = entity_get_int(ent,EV_INT_movetype)
		BXINT_solid = entity_get_int(ent,EV_INT_solid)
		BXINT_skin = entity_get_int(ent,EV_INT_skin)
		BXINT_body = entity_get_int(ent,EV_INT_body)
		BXINT_effects = entity_get_int(ent,EV_INT_effects)
		BXINT_light_level = entity_get_int(ent,EV_INT_light_level)
		BXINT_sequence = entity_get_int(ent,EV_INT_sequence)
		BXINT_gaitsequence = entity_get_int(ent,EV_INT_gaitsequence)
		BXINT_modelindex = entity_get_int(ent,EV_INT_modelindex)
		BXINT_playerclass = entity_get_int(ent,EV_INT_playerclass)
		BXINT_waterlevel = entity_get_int(ent,EV_INT_waterlevel)
		BXINT_watertype = entity_get_int(ent,EV_INT_watertype)
		BXINT_spawnflag = entity_get_int(ent,EV_INT_spawnflags)
		BXINT_flags = entity_get_int(ent,EV_INT_flags)
		BXINT_colormap = entity_get_int(ent,EV_INT_colormap)
		BXINT_team = entity_get_int(ent,EV_INT_team)
		BXINT_fixangle = entity_get_int(ent,EV_INT_fixangle)
		BXINT_weapons = entity_get_int(ent,EV_INT_weapons)
		BXINT_rendermode = entity_get_int(ent,EV_INT_rendermode)
		BXINT_renderfx = entity_get_int(ent,EV_INT_renderfx)
		BXINT_button = entity_get_int(ent,EV_INT_button)
		BXINT_impulse = entity_get_int(ent,EV_INT_impulse)
		BXINT_deadflag = entity_get_int(ent,EV_INT_deadflag)
		
		client_print(0,print_console, "[i1]gamestate %d oldbuttons %d groupinfo %d iuser1 %d iuser2 %d iuser3 %d iuser4 %d", BXINT_gamestate, BXINT_oldbuttons, BXINT_groupinfo, BXINT_iuser1, BXINT_iuser2, BXINT_iuser3, BXINT_iuser4)
		client_print(0,print_console, "[i2]weaponanim %d pushmsec %d bInDuck %d flTimeStepSound %d flSwimTime %d flDuckTime %d", BXINT_weaponanim, BXINT_pushmsec, BXINT_bInDuck, BXINT_flTimeStepSound, BXINT_flSwimTime, BXINT_flDuckTime )
		client_print(0,print_console, "[i3]iStepLeft %d movetype %d solid %d skin %d body %d effects %d light_level %d", BXINT_iStepLeft, BXINT_movetype, BXINT_solid, BXINT_skin,  BXINT_body, BXINT_effects, BXINT_light_level)
		client_print(0,print_console, "[i4]sequence %d gaitsequence %d modelindex %d playerclass %d waterlevel %d watertype %d spawnflag %d flags %d", BXINT_sequence, BXINT_gaitsequence, BXINT_modelindex, BXINT_playerclass, BXINT_waterlevel, BXINT_watertype, BXINT_spawnflag,BXINT_flags )
		client_print(0,print_console, "[i5]colormap %d team %d fixangle %d weapons %d rendermode %d renderfx %d button %d impulse %d deadflag %d", BXINT_colormap, BXINT_team, BXINT_fixangle, BXINT_weapons, BXINT_rendermode, BXINT_renderfx, BXINT_button, BXINT_impulse,  BXINT_deadflag )
		
		func_FixMapGuns2(bx_owner)
		// set_pdata_int(ent,108,2,4)
		
	}
}

public func_FixMapGuns2(ent)
{		
	
	// FOUNDED IN AIR AND FLOOR
	// entity_set_model(ent,"models/w_98k.mdl")
	// new Rent = engfunc(EngFunc_FindEntityByString, ent , "model", KNIVES_MODELS[2] )
	/////////// 
	/*
	entity_get_string(ent, EV_SZ_classname , classname, 63) // weaponbox
	
	
	EV_SZ_classname  == weaponbox
	EV_SZ_globalname == 
	
	*/
	// EV_ENT_pContainingEntity
	
	
	new bxclassname[64], bxglobalname[32], bxmodel[64] , bxtarget[64] , bxtargetnm[64], bxnetname[64], bxmessage[64], bxn[64] , bxn1[64], bxn2[64] , bxn3[64], bxvievmodel[64], bxweapmodel[64]
	entity_get_string(ent, EV_SZ_classname , bxclassname, 63) // weaponbox		
	pev(ent, pev_globalname, bxglobalname, 31 ) // null
	entity_get_string(ent, EV_SZ_model , bxmodel, 63) // ----.mdl	
	entity_get_string(ent, EV_SZ_target , bxtarget, 63)
	entity_get_string(ent, EV_SZ_targetname , bxtargetnm, 63)
	entity_get_string(ent, EV_SZ_netname , bxnetname, 63)
	entity_get_string(ent, EV_SZ_message , bxmessage, 63)
	entity_get_string(ent, EV_SZ_noise , bxn, 63)
	entity_get_string(ent, EV_SZ_noise1 , bxn1, 63)
	entity_get_string(ent, EV_SZ_noise2 , bxn2, 63)
	entity_get_string(ent, EV_SZ_noise3 , bxn3, 63)
	entity_get_string(ent, EV_SZ_viewmodel , bxvievmodel, 63)
	entity_get_string(ent, EV_SZ_weaponmodel , bxweapmodel, 63)
	client_print(0, print_console, "[S] id %d clnm_ %s / glbnm_ %s / model_ %s / trg_ %s / tgnm_ %s ", ent, bxclassname , bxglobalname , bxmodel , bxtarget, bxtargetnm)
	client_print(0, print_console, "[S2] netname %s / msg_ %s / bnx %s %s %s %s / viewmdl %s / wpndml %s ", bxnetname, bxmessage, bxn , bxn1, bxn2 , bxn3 , bxvievmodel, bxweapmodel)
	//remove_entity(ent)
	
	new bx_chain ,bxdmg_inflictor, bx_enemy, bx_aiment,bx_owner, bx_groundentity, bx_pContainingEntity, bx_euser1, bx_euser2, bx_euser3, bx_euser4
	bx_chain = entity_get_edict2(ent, EV_ENT_chain )
	bxdmg_inflictor = entity_get_edict2(ent, EV_ENT_dmg_inflictor )
	bx_enemy = entity_get_edict2(ent, EV_ENT_enemy )
	bx_aiment = entity_get_edict2(ent, EV_ENT_aiment )
	bx_owner = entity_get_edict2(ent, EV_ENT_owner )
	bx_groundentity = entity_get_edict2(ent, EV_ENT_groundentity )
	bx_pContainingEntity = entity_get_edict2(ent, EV_ENT_pContainingEntity )
	bx_euser1 = entity_get_edict2(ent, EV_ENT_euser1 )
	bx_euser2 = entity_get_edict2(ent, EV_ENT_euser2 )
	bx_euser3 = entity_get_edict2(ent, EV_ENT_euser3 )
	bx_euser4 = entity_get_edict2(ent, EV_ENT_euser4 )
	
	client_print(0,print_console, "[e] chain %d dmginf %d enemy %d aiment %d owner %d groundentity %d pContainingEntity %d euser1 %d euser2 %d euser3 %d euser4 %d", bx_chain, bxdmg_inflictor, bx_enemy, bx_aiment,bx_owner, bx_groundentity, bx_pContainingEntity, bx_euser1, bx_euser2, bx_euser3, bx_euser4)
	
	///////////////////
	
	
	new BXINT_gamestate, BXINT_oldbuttons, BXINT_groupinfo, BXINT_iuser1, BXINT_iuser2, BXINT_iuser3, BXINT_iuser4
	new BXINT_weaponanim, BXINT_pushmsec, BXINT_bInDuck, BXINT_flTimeStepSound, BXINT_flSwimTime, BXINT_flDuckTime
	new BXINT_iStepLeft, BXINT_movetype, BXINT_solid, BXINT_skin,  BXINT_body, BXINT_effects, BXINT_light_level
	new BXINT_sequence, BXINT_gaitsequence, BXINT_modelindex, BXINT_playerclass, BXINT_waterlevel, BXINT_watertype, BXINT_spawnflag,BXINT_flags
	new BXINT_colormap, BXINT_team, BXINT_fixangle, BXINT_weapons, BXINT_rendermode, BXINT_renderfx, BXINT_button, BXINT_impulse,  BXINT_deadflag
	
	
	BXINT_gamestate = entity_get_int(ent,EV_INT_gamestate)
	BXINT_oldbuttons = entity_get_int(ent,EV_INT_oldbuttons)
	BXINT_groupinfo = entity_get_int(ent,EV_INT_groupinfo)
	BXINT_iuser1 = entity_get_int(ent,EV_INT_iuser1)
	BXINT_iuser2 = entity_get_int(ent,EV_INT_iuser2)
	BXINT_iuser3 = entity_get_int(ent,EV_INT_iuser3)
	BXINT_iuser3 = entity_get_int(ent,EV_INT_iuser4)
	BXINT_weaponanim = entity_get_int(ent,EV_INT_weaponanim)
	BXINT_pushmsec = entity_get_int(ent,EV_INT_pushmsec)
	BXINT_bInDuck = entity_get_int(ent,EV_INT_bInDuck)
	BXINT_flTimeStepSound = entity_get_int(ent,EV_INT_flTimeStepSound)
	BXINT_flSwimTime = entity_get_int(ent,EV_INT_flSwimTime)
	BXINT_flDuckTime = entity_get_int(ent,EV_INT_flDuckTime)
	BXINT_iStepLeft = entity_get_int(ent,EV_INT_iStepLeft)
	BXINT_movetype = entity_get_int(ent,EV_INT_movetype)
	BXINT_solid = entity_get_int(ent,EV_INT_solid)
	BXINT_skin = entity_get_int(ent,EV_INT_skin)
	BXINT_body = entity_get_int(ent,EV_INT_body)
	BXINT_effects = entity_get_int(ent,EV_INT_effects)
	BXINT_light_level = entity_get_int(ent,EV_INT_light_level)
	BXINT_sequence = entity_get_int(ent,EV_INT_sequence)
	BXINT_gaitsequence = entity_get_int(ent,EV_INT_gaitsequence)
	BXINT_modelindex = entity_get_int(ent,EV_INT_modelindex)
	BXINT_playerclass = entity_get_int(ent,EV_INT_playerclass)
	BXINT_waterlevel = entity_get_int(ent,EV_INT_waterlevel)
	BXINT_watertype = entity_get_int(ent,EV_INT_watertype)
	BXINT_spawnflag = entity_get_int(ent,EV_INT_spawnflags)
	BXINT_flags = entity_get_int(ent,EV_INT_flags)
	BXINT_colormap = entity_get_int(ent,EV_INT_colormap)
	BXINT_team = entity_get_int(ent,EV_INT_team)
	BXINT_fixangle = entity_get_int(ent,EV_INT_fixangle)
	BXINT_weapons = entity_get_int(ent,EV_INT_weapons)
	BXINT_rendermode = entity_get_int(ent,EV_INT_rendermode)
	BXINT_renderfx = entity_get_int(ent,EV_INT_renderfx)
	BXINT_button = entity_get_int(ent,EV_INT_button)
	BXINT_impulse = entity_get_int(ent,EV_INT_impulse)
	BXINT_deadflag = entity_get_int(ent,EV_INT_deadflag)
	
	client_print(0,print_console, "[2i1]gamestate %d oldbuttons %d groupinfo %d iuser1 %d iuser2 %d iuser3 %d iuser4 %d", BXINT_gamestate, BXINT_oldbuttons, BXINT_groupinfo, BXINT_iuser1, BXINT_iuser2, BXINT_iuser3, BXINT_iuser4)
	client_print(0,print_console, "[2i2]weaponanim %d pushmsec %d bInDuck %d flTimeStepSound %d flSwimTime %d flDuckTime %d", BXINT_weaponanim, BXINT_pushmsec, BXINT_bInDuck, BXINT_flTimeStepSound, BXINT_flSwimTime, BXINT_flDuckTime )
	client_print(0,print_console, "[2i3]iStepLeft %d movetype %d solid %d skin %d body %d effects %d light_level %d", BXINT_iStepLeft, BXINT_movetype, BXINT_solid, BXINT_skin,  BXINT_body, BXINT_effects, BXINT_light_level)
	client_print(0,print_console, "[2i4]sequence %d gaitsequence %d modelindex %d playerclass %d waterlevel %d watertype %d spawnflag %d flags %d", BXINT_sequence, BXINT_gaitsequence, BXINT_modelindex, BXINT_playerclass, BXINT_waterlevel, BXINT_watertype, BXINT_spawnflag,BXINT_flags )
	client_print(0,print_console, "[2i5]colormap %d team %d fixangle %d weapons %d rendermode %d renderfx %d button %d impulse %d deadflag %d", BXINT_colormap, BXINT_team, BXINT_fixangle, BXINT_weapons, BXINT_rendermode, BXINT_renderfx, BXINT_button, BXINT_impulse,  BXINT_deadflag )
	
	/*
	
	
	if(equal(bxclassname, "weaponbox")){
		remove_entity(ent)
		
	}
	*/
	
}

public ex_statusicon(id)
{
	message_begin(MSG_ONE,g_msgIconstatus,{0,0,0},id);
	write_byte(1); // status (0=hide, 1=show, 2=flash)
	write_string("weapons2") // sprite name
	write_byte(0); // red
	write_byte(255); // green
	write_byte(0); // blue
	message_end();
	
	client_print(0,print_chat, "[statusicon] +")
	
} 

public setnoclip(id){
	set_pev(id, pev_movetype, MOVETYPE_NOCLIP)
}

public setnonoclip(id){
	set_pev(id, pev_movetype, MOVETYPE_WALK)
}

public forceweapon0(id){
	set_pdata_int(id,264,0)
}
////////////////////////////////  STOCK 
stock dod_get_weapon_ent(id,wpnid)
{
	new ent = -1,entid

	new Float:origin[3]
	entity_get_vector(id,EV_VEC_origin,origin)
	
	while((ent = find_ent_in_sphere(ent,origin,0.4)) != 0)
			
		{
		if(is_valid_ent(ent))
			{
			entid = get_pdata_int(ent,OFFSET_WPN_ID,OFFSET_LINUX)
			
			if(wpnid == entid)
				return ent
			}
		}
		
	return 0
}


public parse_weapon_offset(id){
	
	new clipg, ammog
	new wpnid = dod_get_user_weapon(id, clipg, ammog)
	new wpnent = dod_get_weapon_ent(id,wpnid)
	
	new emptysound
	new Float:nextattackparse
	emptysound = get_pdata_int(wpnent, 100, 4)
	nextattackparse = get_pdata_float(wpnent, 103, 4)
	client_print(0,print_chat, "[WaponParse] %d  , sound %d , attack %f", wpnent, emptysound, nextattackparse)
	new emptysound2 
	new emptysound3
	emptysound2 = get_pdata_int(wpnent, 117, 4)
	emptysound3 = get_pdata_int(wpnent, 132, 4)
	
	
	client_print(0,print_chat, "[WaponParse] %d  , sound %d , attack %f", wpnent, emptysound2, emptysound3)
	
	
	
}

/*
		//get hand origin
		//engfunc(EngFunc_GetBonePosition,id,20,PlayerOrigin,junk)
		//PlayerOrigin[2] += 12
		// pev(id,pev_origin,PlayerOrigin)
		// PlayerOrigin[2] += 10
*/

public func_hudmessage(id){
	
	message_begin(MSG_ONE,g_msgHudText,{0,0,0},id);
	write_string("huuhfhuhuhfuheuhfuehufheuhfu") // sprite name
	write_byte(1); // red
	message_end();
	
}
public func_StatusValue(id){
	/// worked replace health value
	message_begin(MSG_ONE,g_msgStatusValue,{0,0,0},id);
	write_byte(88)
	message_end();
	
	
	
	
}

public func_eventbulletwall(id){
	
	new i2Origin[3]  
	get_user_origin(id, i2Origin, 3)
	
	
	message_begin(MSG_PVS,SVC_TEMPENTITY)
	write_byte(109)
	write_coord(i2Origin[0])
	write_coord(i2Origin[1])
	write_coord(i2Origin[2])
	write_short(0)
	write_byte(58)
	message_end()
	
}
public func_getuseraiming(id){
	new victim, body
	get_user_aiming(id, victim, body)

	new playername12[32]
	get_user_name(victim,playername12,31)
	// client_print(id, print_center, "aim is %d name is %s  body %d", victim, playername12, body)
	
	 set_hudmessage(0, 255, 0, -1.0, -1.0, 0, 0.1, 0.2)
	show_hudmessage(id, "aim is %d name is %s  body %d", victim, playername12, body)

}


public set_p_weapon_submodel(id){
	
	
	
	 set_pev(id, pev_body, 2);
	 
	 client_print(0,print_chat, "[modelset] body2 ")
	}
	
public client_command(id){
	 new Cmd[13];
    if( read_argv(0, Cmd, 12) > 11 ){
        return PLUGIN_CONTINUE
    }
     
      
        new PlayerName[32]
        get_user_name(id,PlayerName,31)
      
       server_print("[clientcommand] Player %d %s use command %s", id, PlayerName,Cmd)
         
       
    
 
    return PLUGIN_CONTINUE
}


public func_weapon_info_full(id){
	
	new clipg, ammog
	new wpnid = dod_get_user_weapon(id, clipg, ammog)
	new wpnent = dod_get_weapon_ent(id, wpnid)


	client_print(0,print_chat, "[WEAPONINFO] PLAYER %d WEAPON IDTYPE %d WEAPON ENT %d" , id, wpnid, wpnent)
	
	new pdata_i1
	pdata_i1 = get_pdata_cbase_safe(id, 373)
	
	
	
	client_print(0,print_chat, "[WEAPONINFO2] PDATA CBASE %d" , pdata_i1)
}

public func_cbase_pdata(id){
	
	new netnamesome[32]
	get_pdata_string(id, 350, netnamesome, 16, 0, 4)
	set_pdata_int(id,365, 95, 4)
	
	client_print(0,print_chat, "[CBASE] NAME %s" , netnamesome)
	
	
}
public func_weapon_strip(id){
	
	strip_user_weapons(id)
	
}
	
	
public func_scrshake(id)
{


new gmsgShake = get_user_msgid("ScreenShake")
message_begin(MSG_ONE, gmsgShake, {0,0,0}, id)
write_short(255<<14) //ammount
write_short(100<<14) //lasts this long
write_short(255<<14) //frequency
message_end()


}

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1049\\ f0\\ fs16 \n\\ par }
*/
