/* DOD STEAMID MESSAGE
 * Created by the 29th Infantry Division
 * www.29th.org (A Realism Unit)
 * www.dodrealism.branzone.com -- Revolutionizing Day of Defeat Realism
 *
 * DESCRIPTION
 * Will change "[xn]Fuzzy Bunny has joined the game" to
 * "[xn]Fuzzy Bunny (STEAM_0:1:32356) has joined the game"
 * as well as "has left the game" messages. Both messages can
 * be enabled or disabled with a CVAR
 *
 * CREDITS
 * diamond-optic - a lot of the code was based off the foundation of
 * his joinquitswitch msgs cause it was right in front of me and they
 * hook the same way :-P
 *
 * CVARs
 * dod_steamidmsg <0/1>
 *   Enables or disables the overall plugin
 *
 * dod_steamidmsg_connect <0/1>
 *   Enables or disables logging steamid's when someone connects
 *
 * dod_steamidmsg_disconnect <0/1>
 *   Enables or disables logging steamid's when someone disconnects
 */

#include <amxmodx>
#include <amxmisc>

#pragma semicolon 1

#define PLUGIN "STEAMID Msg"
#define VERSION "1.0"
#define AUTHOR "29th ID"

new g_msgTextMsg;
new g_cvarEnabled, g_cvarConnect, g_cvarDisconnect;

public plugin_init() {
	register_plugin( PLUGIN, VERSION, AUTHOR );
	
	// Register CVARs
	g_cvarEnabled = register_cvar( "dod_steamidmsg", "1" );
	g_cvarConnect = register_cvar( "dod_steamidmsg_connect", "1" );
	g_cvarDisconnect = register_cvar( "dod_steamidmsg_disconnect", "1" );
	
	// Register Message
	g_msgTextMsg = get_user_msgid( "TextMsg" );
	register_message( g_msgTextMsg, "handle_textmsg" );
}

public handle_textmsg() {
	if( !get_pcvar_num( g_cvarEnabled ) ) return PLUGIN_CONTINUE;
	if( get_msg_args() < 3 ) return PLUGIN_CONTINUE;
	
	if( get_msg_argtype( 2 ) == ARG_STRING && get_msg_argtype( 3 ) == ARG_STRING )
	{
		new m_szMsg[64];
		get_msg_arg_string( 2, m_szMsg, 63 );
		new m_szName[64];
		get_msg_arg_string( 3, m_szName, 63 );
		
		// Generate New Message
		new id = get_user_index( m_szName );
		new m_szSteamid[32], m_szNewName[64];
		get_user_authid( id, m_szSteamid, 31 );
		format( m_szNewName, 63, "%s (%s)", m_szName, m_szSteamid );
		
		if( equal( m_szMsg, "#game_joined_game" ) && get_pcvar_num( g_cvarConnect ) )
		{
			set_msg_arg_string( 3, m_szNewName );
		}
		else if( equal( m_szMsg, "#game_disconnected" ) && get_pcvar_num( g_cvarDisconnect ) )
		{
			set_msg_arg_string( 3, m_szNewName );
		}
	}
	return PLUGIN_CONTINUE;
}
