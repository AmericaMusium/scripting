/* 
   DOD ADVANCED DEPLOY
   by Wilson [29th ID]
   www.29th.org -- Revolutionizing Day of Defeat Realism
   
   DESCRIPTION
   If you have ever played Day of Defeat: Source, you know 
   how Machine Gun's deploy differently than our game. They 
   work based on the surface they're being deployed on rather 
   than "whether or not it's a sandbag/window cill."

   In DoD 1.3, MG's and BAR's require a specific object at 
   every "should be deployable" spot to tell the game you can
   deploy there. Source does it based on physics (ie. is it a 
   flat surface)

   Since the developers abandoned 1.3, the 29th ID created the 
   plugin that makes 1.3 match source yet again. You can now 
   deploy your MG or Heavy on damn near anything logical to 
   deploy on.
   
   USAGE CVARS
   dod_advanced_deploy <1/0>
	Enables or disables the plugin.
	
   dod_advanced_deploy_view <1/0>
	Just as DoD:Source does, if the object upon which you're 
	deploying is lower than your normal height, you drop down 
	a bit to meet it. This will enable/disable that function.

*/

#include <amxmodx>
#include <amxmisc>
#include <dodx>
#include <fakemeta>

#pragma semicolon 1

#define PLUGIN "DOD Advanced Deploy"
#define VERSION "1.0"
#define AUTHOR "29th ID"

// Trace Length from eye level
// It is this high so that you cannot look at the ground and deploy
#define TRACE_DIST_A 250.0

// Trace Length from hand/waist level
#define TRACE_DIST_B 30.0

// Vertical offset from eyes (up)
// This will account for the aim being a bit lower than realistic
#define TRACE_V_OFFSET 20.0

// Range you can stand from a dod_trigger_sandbag without
// overriding this plugin
#define SANDBAG_RANGE 25.0

new g_cvarEnabled, g_cvarViewOfs;
new g_szSandbag[32] = "dod_trigger_sandbag";
new Float:g_fBelowLines[3] = {-5.0, -10.0, -15.0};
new Float:g_ViewOfs[33];

public plugin_init() 
{
	register_plugin( PLUGIN, VERSION, AUTHOR );
	
	register_forward( FM_PlayerPreThink, "hook_PlayerPreThink" );
	register_forward( FM_UpdateClientData, "hook_UpdateClientData_post", 1 );
	
	g_cvarEnabled = register_cvar( "dod_advanced_deploy", "1" );
	g_cvarViewOfs = register_cvar( "dod_advanced_deploy_view", "1" );
	
}

// If client is not deployed already, and not touching a normal sandbag deploy spot,
// get their deploy ability and update them with it
public hook_PlayerPreThink( id ) 
{
	if( !is_user_alive( id ) || !get_pcvar_num( g_cvarEnabled ) || is_user_bot( id ) ) return PLUGIN_CONTINUE;
	
	if( dod_get_deploystate( id ) < 2 && !touching_sandbag( id ) )
	{
		dod_set_deploystate( id, get_deploy_ability( id ) );
	}
	
	return PLUGIN_CONTINUE;
}

// Runs the main test
public get_deploy_ability( id ) 
{
	if( dod_get_pronestate( id ) || pev( id, pev_button ) & IN_DUCK || !deployable_weapon( id ) )
		return 0;
	
	new bClear_Above = clear_path( id, TRACE_DIST_A, TRACE_V_OFFSET );
	
	if( bClear_Above && support_below( id, TRACE_DIST_B ) )
		return 1;
	
	g_ViewOfs[id] = 0.0;
	return 0;
}

// To adjust View Offset
public hook_UpdateClientData_post( id, sendweapons, cd_handle) 
{
	if( is_user_bot( id ) )
		return PLUGIN_CONTINUE;
		

		set_cd( cd_handle, CD_FOV, 80.0 );

	return PLUGIN_CONTINUE;
}

//////////////////////////////
// Stocks                   //
//////////////////////////////

// Thanks P34nut for help with this stock
stock clear_path( id, Float:fDist, Float:fZOffset ) 
{
	
	new Float:fStartOrigin[3], Float:fAngle[3], Float:fSize[3];
	pev(id, pev_origin, fStartOrigin);
	pev(id, pev_v_angle, fAngle);
	pev(id, pev_size, fSize);
	
	// Adjust for Z Offset
	fStartOrigin[2] += fZOffset;
	
	new Float:fEndOrigin[3];
	fEndOrigin[0] = fStartOrigin[0] + floatcos(fAngle[1], degrees) * (fDist + fSize[0]);
	fEndOrigin[1] = fStartOrigin[1] + floatsin(fAngle[1], degrees) * (fDist + fSize[1]);
	fEndOrigin[2] = (fStartOrigin[2] - floatsin(fAngle[0], degrees) * (fDist + fSize[2])) + 5;
	
	new Float:fStop[3];
	fm_trace_line( id, fStartOrigin, fEndOrigin, fStop );
	
	return vectors_equal( fEndOrigin, fStop );
}

// Returns if there is a support object below weapon deploy point
stock support_below( id, Float:fZOffset ) 
{
	for( new i; i < sizeof g_fBelowLines; i++ )
	{
		if( !clear_path( id, fZOffset, g_fBelowLines[i] ) )
		{
			g_ViewOfs[id] = g_fBelowLines[i];
			return 1;
		}
	}
	return 0;
}

// Cleanliness is next to sawcelyness
stock get_view_ofs( id, Float:fNewView[3] ) 
{	
	fNewView[2] = 22.0 + g_ViewOfs[id];
}

stock vectors_equal( Float:vec_a[3], Float:vec_b[3] ) {
	if( vec_a[0] == vec_b[0]
	 && vec_a[1] == vec_b[1]
	 && vec_a[2] == vec_b[2] )
		return 1;
	return 0;
}

stock touching_sandbag( id ) 
{
	new m_curEnt = -1, m_flOrigin[3];
	pev( id, pev_origin, m_flOrigin );
	
	while( ( m_curEnt = engfunc( EngFunc_FindEntityInSphere, m_curEnt, m_flOrigin, SANDBAG_RANGE ) ) != 0 ) {
		
		new m_szClassname[32];
		pev( m_curEnt, pev_classname, m_szClassname, 31 );
    
		if( equal( m_szClassname, g_szSandbag ) )
			return m_curEnt;
	}
	return 0;
}

stock deployable_weapon( id ) 
{
	new clip, ammo, wpn = get_user_weapon( id, clip, ammo );
	if( wpn == DODW_30_CAL
	 || wpn == DODW_MG34
	 || wpn == DODW_MG42
	 || wpn == DODW_BAR
	 || wpn == DODW_FG42
	 || wpn == DODW_BREN )
		return 1;
	return 0;
}

// From FM Utilities by VEN
stock fm_trace_line(ignoreent, const Float:start[3], const Float:end[3], Float:ret[3]) 
{
	engfunc(EngFunc_TraceLine, start, end, ignoreent == -1 ? 1 : 0, ignoreent, 0);

	new ent = get_tr2(0, TR_pHit);
	get_tr2(0, TR_vecEndPos, ret);

	return pev_valid(ent) ? ent : 0;
}

/* The following 2 are mock natives that
   I will one day get Zor to put in DoDX */

/* DOD Set Deploy State
   by Wilson [29th ID]
   Flag Values: 0 = Not Deployed
		1 = DeployABLE
		2 = Fully Deployed */
stock dod_set_deploystate( id, flag ) 
{
	new Float:m_vector[3];
	m_vector[0] = float( flag );
	set_pev( id, pev_vuser1, m_vector );
}

/* DOD Get Deploy State
   by Wilson [29th ID]
   Returns Flags like "Set Deploy" */
stock dod_get_deploystate( id ) 
{
	new Float:m_vector[3];
	pev( id, pev_vuser1, m_vector );
	
	return floatround(m_vector[0]);
}
