#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <dodx>
#include <dodfun>
#include <fun>
#include <engine>
#include <okapi>
#include <reapi>


// Linux extra offsets
#define linux_diff_weapon 4
#define linux_diff_player 5
#define linux_diff_animation 4


#define m_iClientWeaponState 110	
#define m_iWeaponState 115		// IS BAZOOKA/PIAT/PSCHREK Shouldered

#define Is_custom_w(%0) (pev(%0, pev_impulse) == WEAPON_SPECIAL_CODE) 

new g_rifle = 0;

public plugin_init()
{
    register_forward( FM_UpdateClientData, "hook_UpdateClientData_post", 1 );
    register_forward( FM_AddToFullPack,    "hook_AddToFullPack_post", 1 );

    RegisterHam(Ham_Weapon_SecondaryAttack,	"weapon_spring",	"CurWeapon_SecondaryAttack_Pre", false);
    register_clcmd("say ws", "some_fix")
}

public some_fix(idx_player)
{   
    set_pdata_int( g_rifle, m_iWeaponState , 1 ,linux_diff_weapon );
    set_pdata_int( g_rifle, m_iClientWeaponState , 1 ,linux_diff_weapon );
}


public CurWeapon_SecondaryAttack_Pre(activeitem)
{   


    new classname[32];
    entity_get_string(activeitem,EV_SZ_classname,classname,31);
	new shoulder = get_pdata_int( activeitem, m_iWeaponState , linux_diff_weapon );
    client_print(0, print_chat, "m_iWeaponState %d %s", shoulder , classname )
    // set_pdata_int( activeitem, m_iWeaponState , 1 ,linux_diff_weapon );  // 1 = SCOOPED
    
}
/*
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



public hook_UpdateClientData_post( entid, sendweapons, cd_handle ) {
	new id = find_id_value( entid, "cd" );
	if( !g_cdhook[id][ent] || !g_cdhook[id][type] ) return FMRES_IGNORED;
	
	// Retrieve data from global variable
	//new m_ent    = g_cdhook[id][ent];
	new m_type   = g_cdhook[id][type];
	new m_member = g_cdhook[id][member];
	new m_arg1   = g_cdhook[id][arg1];
	new m_arg2   = g_cdhook[id][arg2];
	new m_arg3   = g_cdhook[id][arg3];
	
	// Get const version of member
	new m_szmember[32];
	copy( m_szmember, 31, g_cdlist[m_member][0] );
	
	// Integer
	if( m_type == TYPE_INTEGER && m_member )
	{
		if( m_arg1 != VALUE_READ )
		{
			set_cd( cd_handle, ClientData:m_member, m_arg1 );
			if( cvar_debug() ) console_print( id, "[Ent %i] Set %s Integer to %i", entid, m_szmember, m_arg1 );
			return FMRES_HANDLED;
		}
		else
		{
			new m_get = get_cd( cd_handle, ClientData:m_member );
			console_print( id, "[Ent %i] Get %s Integer is set to %i", entid, m_szmember, m_get, m_arg1 );
		}
	}
	// Float
	else if( m_type == TYPE_FLOAT && m_member )
	{
		if( m_arg1 != VALUE_READ )
		{
			set_cd( cd_handle, ClientData:m_member, float( m_arg1 ) );
			if( cvar_debug() ) console_print( id, "[Ent %i] Set %s Float to %f", entid, m_szmember, float( m_arg1 ) );
			return FMRES_HANDLED;
		}
		else
		{
			new Float:m_get;
			get_cd( cd_handle, ClientData:m_member, m_get );
			console_print( id, "[Ent %i] Get %s Float is set to %f", entid, m_szmember, m_get, m_arg1 );
		}
	}
	// Vector
	else if( m_type == TYPE_VECTOR && m_member )
	{
		// Use "OR" (||) in case an arg is supposed to be 0
		if( m_arg1 != VALUE_READ || m_arg2 != VALUE_READ || m_arg3 != VALUE_READ )
		{
			new Float:m_set[3];
			m_set[0] = float( m_arg1 );
			m_set[1] = float( m_arg2 );
			m_set[2] = float( m_arg3 );
			set_cd( cd_handle, ClientData:m_member, m_set );
			if( cvar_debug() ) console_print( id, "[Ent %i] Set %s Vector to {%f, %f, %f}", entid, m_szmember, m_set[0], m_set[1], m_set[2] );
			return FMRES_HANDLED;
		}
		else
		{
			new Float:m_get[3];
			get_cd( cd_handle, ClientData:m_member, m_get );
			console_print( id, "[Ent %i] Get %s Vector is set to {%f, %f, %f}", entid, m_szmember, m_get[0], m_get[1], m_get[2], m_arg1, m_arg2, m_arg3 );
		}
	}
	// String
	else if( m_type == TYPE_STRING && m_member )
	{
		if( m_arg1 != VALUE_READ )
		{
			set_cd( cd_handle, ClientData:m_member, m_arg1 );
			if( cvar_debug() ) console_print( id, "[Ent %i] Set %s String to %s", entid, m_szmember, m_arg1 );
			return FMRES_HANDLED;
		}
		else
		{
			new m_get[64];
			get_cd( cd_handle, ClientData:m_member, m_get );
			console_print( id, "[Ent %i] Get %s String is set to %s", entid, m_szmember, m_get );
		}
	}
	// Only gets called if "Getting"
	// Set values to 0 so it isn't called again
	g_cdhook[id][ent] = 0;
	g_cdhook[id][type] = 0;
	g_cdhook[id][member] = 0;
	g_cdhook[id][arg1] = 0;
	g_cdhook[id][arg2] = 0;
	g_cdhook[id][arg3] = 0;
	
	return FMRES_IGNORED;
	
}


public hook_AddToFullPack_post( es_handle, e, entid, host, hostflags, player, pSet ) {
	new id = find_id_value( entid, "es" );
	if( !g_eshook[id][ent] || !g_eshook[id][type] ) return FMRES_IGNORED;
	
	// Retrieve data from global variable
	//new m_ent    = g_eshook[id][ent];
	new m_type   = g_eshook[id][type];
	new m_member = g_eshook[id][member];
	new m_arg1   = g_eshook[id][arg1];
	new m_arg2   = g_eshook[id][arg2];
	new m_arg3   = g_eshook[id][arg3];
	
	// Get const version of member
	new m_szmember[32];
	copy( m_szmember, 31, g_eslist[m_member][0] );
	
	// Integer
	if( m_type == TYPE_INTEGER )
	{
		if( m_arg1 != VALUE_READ )
		{
			set_es( es_handle, EntityState:m_member, m_arg1 );
			if( cvar_debug() ) console_print( id, "[Ent %i] Set %s Integer to %i", entid, m_szmember, m_arg1 );
			return FMRES_HANDLED;
		}
		else
		{
			new m_get = get_es( es_handle, EntityState:m_member );
			console_print( id, "[Ent %i] Get %s Integer is set to %i", entid, m_szmember, m_get, m_arg1 );
		}
	}
	// Float
	else if( m_type == TYPE_FLOAT )
	{
		if( m_arg1 != VALUE_READ )
		{
			set_es( es_handle, EntityState:m_member, float( m_arg1 ) );
			if( cvar_debug() ) console_print( id, "[Ent %i] Set %s Float to %f", entid, m_szmember, float( m_arg1 ) );
			return FMRES_HANDLED;
		}
		else
		{
			new Float:m_get;
			get_es( es_handle, EntityState:m_member, m_get );
			console_print( id, "[Ent %i] Get %s Float is set to %f", entid, m_szmember, m_get, m_arg1 );
		}
	}
	// Vector
	else if( m_type == TYPE_VECTOR )
	{
		// Use "OR" (||) in case an arg is supposed to be 0
		if( m_arg1 != VALUE_READ || m_arg2 != VALUE_READ || m_arg3 != VALUE_READ )
		{
			new Float:m_set[3];
			m_set[0] = float( m_arg1 );
			m_set[1] = float( m_arg2 );
			m_set[2] = float( m_arg3 );
			set_es( es_handle, EntityState:m_member, m_set );
			if( cvar_debug() ) console_print( id, "[Ent %i] Set %s Vector to {%f, %f, %f}", entid, m_szmember, m_set[0], m_set[1], m_set[2] );
			return FMRES_HANDLED;
		}
		else
		{
			new Float:m_get[3];
			get_es( es_handle, EntityState:m_member, m_get );
			console_print( id, "[Ent %i] Get %s Vector is set to {%f, %f, %f}", entid, m_szmember, m_get[0], m_get[1], m_get[2], m_arg1, m_arg2, m_arg3 );
		}
	}
	// String
	else if( m_type == TYPE_STRING )
	{
		if( m_arg1 != VALUE_READ )
		{
			set_es( es_handle, EntityState:m_member, m_arg1 );
			if( cvar_debug() ) console_print( id, "[Ent %i] Set %s String to %s", entid, m_szmember, m_arg1 );
			return FMRES_HANDLED;
		}
		else
		{
			new m_get[64];
			get_es( es_handle, EntityState:m_member, m_get );
			console_print( id, "[Ent %i] Get %s String is set to %s", entid, m_szmember, m_get );
		}
	}
	// Only gets called if "Getting"
	// Set values to 0 so it isn't called again
	g_eshook[id][ent] = 0;
	g_eshook[id][type] = 0;
	g_eshook[id][member] = 0;
	g_eshook[id][arg1] = 0;
	g_eshook[id][arg2] = 0;
	g_eshook[id][arg3] = 0;
	
	return FMRES_IGNORED;
	
}

*/