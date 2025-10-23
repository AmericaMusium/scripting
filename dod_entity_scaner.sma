
#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>
#include <fakemeta_util>
#include <fun>
#include <hamsandwich>

#define PLUGIN "DOD ENT SCANNER"
#define VERSION "07Jan2023"
#define AUTHOR "[America][TheVaskov]"

#define m_Material 84
#define m_Explosion 85


#define m_iInitialHealth 91
#define m_iInitialRenderAmt 92

#define m_szTextureName 249 //13

/*
#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <xs>

#define PLUGIN "Show Aimed Texture Name"
#define VERSION "0.0.1"

public plugin_init()
{
    register_plugin( PLUGIN, VERSION, "ConnorMcLeod" )
}

public client_PreThink( id )
{
    if( is_user_alive(id) )
    {
        new Float:start[3], Float:end[3]
        pev(id, pev_origin, start)
        pev(id, pev_view_ofs, end)
        xs_vec_add(start, end, start)

        pev(id, pev_v_angle, end)
        engfunc(EngFunc_MakeVectors, end)
        global_get(glb_v_forward, end)
        xs_vec_mul_scalar(end, 9999.0, end)
        xs_vec_add(start, end, end)

        new tr = create_tr2()
        engfunc(EngFunc_TraceLine, start, end, true, id, tr)
        new pWorld, pHit = get_tr2(tr, TR_pHit)
        if( pHit >= 0 )
        {
            pWorld = pHit
        }

        new szTextureName[32]
        engfunc(EngFunc_TraceTexture, pWorld, start, end, szTextureName, charsmax(szTextureName))
        client_print(id, print_center, szTextureName)

        free_tr2(tr)
    }
}
*/

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	// register_clcmd("say /scan", "scan_entity_list")

	register_clcmd("say", "scan_entity_id");


	

	// register_srvcmd("pdata","scan_entity_pdata",ADMIN_CVAR,"scan offstets")

	// register_forward(FM_CmdStart,"anttroop_button")

	// RegisterHam(Ham_SetToggleState, "weapon_luger",  "toggle_state") не ясно ! 
	//  register_forward(FM_PlayerPreThink, "fwdPlayerPreThink", 0)

	register_clcmd("say pd", "scan_entity_pdata");
	register_clcmd("say mes", "find_ent_inPVSfor");
	
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

public m_ssss(id)
{
	message_begin(MSG_ONE,get_user_msgid("Scope"),{0,0,0}, id)
	write_byte(1)
	message_end()
			
}

public toggle_state(ent)
{
	client_print(0, print_chat, "ent %d state ", ent)
}
public fwdPlayerPreThink(id){
     
    new target, body
    new Float:dist = get_user_aiming(id, target, body, 9999)
	new sClsname[32]
	new sMessage[256]
	pev(target, pev_classname, sClsname, 31)

	set_hudmessage(0, 63, 127, -1.0, -1.0, 0, 0.0, 0.1, 0.0, 0.0, -1)
	show_hudmessage(id, "sClsname: %s ", sClsname)

	if(equal(sClsname, "func_breakable"))
	{
	//mat = get_pdata_cbase(target, m_Material)

	new mat = get_pdata_int(target, m_Material);
	new expl = get_pdata_int(target, m_Explosion);
	new health =  get_pdata_int(target, m_iInitialHealth);
	new renderamt = get_pdata_int(target, m_iInitialRenderAmt);
	// m_iInitialHealth == 91


	 new Float:fAngViev[3] 
	pev(id, pev_v_angle, fAngViev)

	
	

	
	}
    // client_print(id, print_chat,"id: %d , entity id: %d , classname: %s", id, target, sClsname )
	/*
    formatex(sMessage, 63, "class name:  %s ^n target id : %i, dist:%.2f matt %i", sClsname, target, dist , mat)
	set_hudmessage(0, 63, 127, -1.0, -1.0, 0, 0.0, 0.1, 0.0, 0.0, -1)
	show_hudmessage(id, "%s", sMessage)
    */
	/*
	if(body == 1){

		set_pev(id, pev_button,IN_ATTACK)

	}
	*/

    
}


// show entity list
public scan_entity_list()
{
	new iEntCount = entity_count()
	new iEntMax = global_get(glb_maxEntities)
	

	new sClsname[32]
	new id_ent
	for (id_ent = 0 ; id_ent < iEntMax; id_ent++ )
	{
		if(pev_valid(id_ent))
		{	
			pev(id_ent, pev_classname, sClsname, 31)
			// client_print(0, print_console, "id: %d ; classname: %s ", id_ent, sClsname)
			server_print("id: %d ; classname: %s ", id_ent, sClsname)
			
		}

	}
	server_print("%d entities in world (%d max!)", iEntCount, iEntMax)
}

public scan_entity_id()
{
    new szArgs[192]
    read_args(szArgs, charsmax(szArgs))
    if (containi(szArgs, "/scan") != -1)
    {
		read_argv(2, szArgs, 31)
		remove_quotes(szArgs)
		new f_integer = str_to_num(szArgs)
		if (f_integer == 0) 
			scan_entity_list()
		else
		{
			server_print("START SCAN ID: %d ", f_integer)
			if(pev_valid(f_integer))
				scan_entity_pev(f_integer)
				scan_entity_list()
				//scan_entity_pdata(f_integer)
			
		}
		
        
	}
	return PLUGIN_CONTINUE

}

public scan_entity_pev(ent)
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
				
		new bx_chain ,bxdmg_inflictor, bx_enemy, bx_aiment,bx_owner, bx_groundentity, bx_pContainingEntity, bx_euser1, bx_euser2, bx_euser3, bx_euser4
		bx_chain = entity_get_edict(ent, EV_ENT_chain )
		bxdmg_inflictor = entity_get_edict(ent, EV_ENT_dmg_inflictor )
		bx_enemy = entity_get_edict(ent, EV_ENT_enemy )
		bx_aiment = entity_get_edict(ent, EV_ENT_aiment )
		bx_owner = entity_get_edict(ent, EV_ENT_owner )
		bx_groundentity = entity_get_edict(ent, EV_ENT_groundentity )
		bx_pContainingEntity = entity_get_edict(ent, EV_ENT_pContainingEntity )
		bx_euser1 = entity_get_edict(ent, EV_ENT_euser1 )
		bx_euser2 = entity_get_edict(ent, EV_ENT_euser2 )
		bx_euser3 = entity_get_edict(ent, EV_ENT_euser3 )
		bx_euser4 = entity_get_edict(ent, EV_ENT_euser4 )
		
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
		
		new Float:fOrigin[3]
		pev(ent, pev_origin, fOrigin)
		fOrigin[2] += 36
		set_pev(ent, pev_origin, fOrigin)
		// engfunc(EngFunc_RemoveEntity,ent)
}

public scan_entity_pdata(ent)
{	
	new offset_num
	new offset_shift
	new data_i
	new float: data_f
	new data_s[128]
	new data_vec3_i[3]
	new data_vec3_f[3]

	offset_shift = 5
	// start scan 
	
	
	
}
	


public find_ent_inPVSfor(id)
{ 
	
	static class[32];
	static ent, chain;
	ent = engfunc(EngFunc_EntitiesInPVS, id);
	while(ent)
	{
		// chain = pev(ent, pev_chain);
		// pev(ent, pev_origin, point);
		pev(ent, pev_classname, class, charsmax(class));
	
		client_print(0,print_chat, "Found entity in PVS (ent:%i class:%s)", ent, class)
			
	}
	return PLUGIN_HANDLED;
}