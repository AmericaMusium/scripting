#include <amxmodx>
#include <fakemeta>
#include <dhudmessage>

public plugin_init()
{
	register_plugin("DOD HXDX","0.0","America")
	server_print("DOD HXDX")
	register_concmd("knife", "KnifeCommand");
	
    register_clcmd( "say /test", "ClientCommand_Test" );

}
public KnifeCommand(client)
{
    new iPlayers[32], iPnum;
    get_players(iPlayers, iPnum, "ch");
    set_dhudmessage(255, 255, 0, -1.0, 0.22, 1, 10.0, 10.0, 2.0, 2.0);
    
    for(new i; i < iPnum; i++)
        show_dhudmessage(iPlayers[i], "KNIFE Round!!!");
} 




public ClientCommand_Test( client )
{
    set_dhudmessage( 0, 160, 0, -1.0, 0.25, 2, 6.0, 3.0, 0.1, 1.5 );
    show_dhudmessage( client, "Welcome, Gordon Freeman." );
    
}
