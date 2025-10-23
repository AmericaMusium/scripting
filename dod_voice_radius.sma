
	/* 
		Plugin: Voice Radius
		Version: 1.0
		Author: H3avY Ra1n
		
		Description
		-----------
		
			This plugin allows you to restrict voice communication to 
			players within a certain radius. Instead of being able to
			talk to everybody in the server, you can only talk to the
			people that are close to you.
		
		Cvars
		-----
		
			vr_alive_distance			
				+	Max distance for alive players to communicate
				
			vr_alive_heardeadplayers 	
				+ Whether or not alive players can hear dead players
				
			vr_alive_alltalk			
				+ Whether or not alive players can hear the opposite team's players (dead or alive, within vr_alive_distance)
				
			vr_dead_hearliveplayers		
				+ Whether or not dead players can hear living players
				
			vr_dead_alltalk				
				+ Whether dead players can hear opposite team's players (dead or alive)
		
			vr_admin_allhear
				+ Whether everybody hears an admin or not
				
			vr_admin_hearall
				+ Whether an admin hears everybody or not
				
		Changelog
		---------
		
			October 22, 2011
			
				- v1.0 -
				
					+ Initial Release
	
					
		Credits
		-------
		
			alongub @sourcemod section
			
				+ Found his plugin, and ported it to AMXX
	
	*/
	
	/* Includes */
	
		#include < amxmodx >
		#include < fakemeta >
		// #include < cstrike >
	
	/* Defines */
		
		#define ADMIN_SPEAK		ADMIN_BAN
		#define ADMIN_LISTEN 	ADMIN_BAN
		
		#define VERSION 		"1.0"
		
	/* PCvars */
		
		new g_pAliveDistance;
		new g_pAliveHearDead;
		new g_pAliveAlltalk;
		
		new g_pDeadHearLiving;
		new g_pDeadAlltalk;
	
		new g_pAllHearAdmin;
		new g_pAdminHearsAll;
	
	public plugin_init()
	{
		register_plugin( "Voice Radius", VERSION, "H3avY Ra1n" );
		
		register_forward( FM_Voice_SetClientListening, "Forward_SetClientListening_Pre", 0 );
		
		g_pAliveDistance		= register_cvar( "vr_alive_distance", "1000" );
		g_pAliveHearDead		= register_cvar( "vr_alive_heardeadplayers", "0" );
		g_pAliveAlltalk			= register_cvar( "vr_alive_alltalk", "1" );
		
		g_pDeadHearLiving		= register_cvar( "vr_dead_hearliveplayers", "1" );
		g_pDeadAlltalk			= register_cvar( "vr_dead_alltalk", "1" );
		
		g_pAllHearAdmin			= register_cvar( "vr_admin_allhear", "1" );
		g_pAdminHearsAll		= register_cvar( "vr_admin_hearall", "1" );
		
	}
	
	public Forward_SetClientListening_Pre( iReceiver, iSender, bool:bListen )
	{
		if( !is_user_connected( iReceiver ) || !is_user_connected( iSender ) )
			return FMRES_IGNORED;
			
		if( ( get_user_flags( iSender ) & ADMIN_SPEAK && get_pcvar_num( g_pAllHearAdmin ) ) // Everybody hears admins
		|| ( get_user_flags( iReceiver ) & ADMIN_LISTEN && get_pcvar_num( g_pAdminHearsAll ) ) ) // Admin hears everybody
			return FMRES_IGNORED;
		
		/* Check User Teams */
		new iSenderTeam = get_user_team( iSender );
		new iReceiverTeam = get_user_team( iReceiver );
		
		/* Check user death status */
		new bool:bSenderAlive = bool:is_user_alive( iSender );
		new bool:bReceiverAlive = bool:is_user_alive( iReceiver );
		
		/* Player talking is dead */
		if( !bSenderAlive )
		{
			/* Player hearing is alive */
			if( bReceiverAlive )
			{
				/* If alive people hear dead people and alltalk is on or they are on the same team */
				if( get_pcvar_num( g_pAliveHearDead ) && ( iReceiverTeam == iSenderTeam || get_pcvar_num( g_pAliveAlltalk ) ) )
					return FMRES_IGNORED;
			}
			
			/* Player hearing is dead */
			else
			{
				/* Both are dead, so either same team or alltalk is on */
				if( get_pcvar_num( g_pDeadAlltalk ) || iReceiverTeam == iSenderTeam )
					return FMRES_IGNORED;
			}
		}
		
		/* Player talking is alive */
		else
		{
			/* Player hearing is alive */
			if( bReceiverAlive )
			{	
				/* Check distance */
				new Float:flSenderOrigin[ 3 ], Float:flReceiverOrigin[ 3 ], Float:flDistance;
				pev( iSender, pev_origin, flSenderOrigin );
				pev( iReceiver, pev_origin, flReceiverOrigin );
				flDistance = get_distance_f( flSenderOrigin, flReceiverOrigin );
				
				/* If distance is less than min distance and they are on same team or alltalk is on */
				if( get_pcvar_float( g_pAliveDistance ) < flDistance 
				&& ( iReceiverTeam == iSenderTeam 
				|| get_pcvar_num( g_pAliveAlltalk ) ) )
					return FMRES_IGNORED;
			}
			
			/* Player hearing is dead */
			else
			{
				/* If dead hear the living and they are either on the same team or alltalk is on */
				if( get_pcvar_num( g_pDeadHearLiving ) && ( iReceiverTeam == iSenderTeam || get_pcvar_num( g_pDeadAlltalk ) ) )
					return FMRES_IGNORED;
			}
		}

		/* Prevent communication */
		engfunc( EngFunc_SetClientListening, iReceiver, iSender, false );
		return FMRES_SUPERCEDE;
	}
	