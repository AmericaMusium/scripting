/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <fakemeta_util>
#include <dodx>
#include <dodfun>
#include <fun>
#include <engine>

#define PLUGIN "DOD PARSER ENTITY"
#define VERSION "12apr22"
#define AUTHOR "[America][TheVaskov]"


public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_clcmd("say /playerdata", "func_get_pev_player") // pars String , edict , integer
	register_clcmd("say /parser", "func_FixMapGuns") // pars String , edict , integer
	register_clcmd("say /colormap", "func_colormap") // pars String , edict , integer
	register_clcmd("say /move", "func_movety44") // pars String , edict , integer
	
	register_clcmd( "say /aiminfo", "ShowAimInfo")
	register_forward(FM_EmitSound, "fw_emit_sound")
}

public func_colormap(id){
	client_print(0,print_chat, "colormap") 
	entity_set_int(id,EV_INT_colormap,0)
}

public func_movety44(id){
	
	entity_set_int(id,EV_INT_movetype, 8)
	
}

public func_FixMapGuns(id)
{		
	new ent = -1
	while((ent = find_ent_by_class(ent,"shell_pschreck")) != 0) {
		
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
		
		
		
		entity_get_string(bx_owner, EV_SZ_classname , bxclassname, 63) // weaponbox
		
		if(equal(bxclassname, "weaponbox")){
			
			//client_print(0,print_chat, "SET CLIP 222222222")
			// set_pdata_int(ent,108,2,4)
			// remove_entity(bx_owner)
		}
		
	}
}

public func_FixMapGuns2(ent)
{		
	
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
	
	
	
	if(equal(bxclassname, "weaponbox")){
		// remove_entity(ent)
	}
	
	
}

public ShowAimInfo(id)
{
	new ent, aux, classname[32]
	get_user_aiming(id , ent, aux)
	pev(ent, pev_classname, classname, 31)
	// m_fAutoWeaponSwitch 509
	new zoomtype
	zoomtype = get_pdata_int(id, 45, 4)
	client_print(id, print_chat, "EntityId= %d Class=%s Weapons= %d", ent, classname , zoomtype)
	
	
	// set_pdata_
	

} 


public func_get_pev_player(id)
{		
	new ent = -1
	while((ent = find_ent_by_class(ent,"player")) != 0) {
		
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
		
			
	}
}


public fw_emit_sound(id,channel,const sound[])
{	
	if(equal(sound,"player/usstartround2.wav")) // проверяем,тот ли звук мы поймали
    {
	client_print(0, print_chat, "[emitsound] CAAAAAATCH !!")
	
	
	}
	client_print(0, print_chat, "[emitsound] ID %d, channgel %d, sound %s", id, channel, sound);
	emit_sound(id,CHAN_AUTO, "player/usstartround2.wav" ,0.6, ATTN_NORM, SND_STOP, PITCH_NORM)
}