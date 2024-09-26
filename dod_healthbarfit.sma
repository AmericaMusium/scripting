#include <amxmodx>
#include <hamsandwich>

#define PLUGIN "Hud Health Bar Fit"
#define VERSION "1.1"
#define AUTHOR "SnoW"
#define BAR_SIZE 2

new gBar[ ] = "Xxxxxxxxxx1xxxxxxxxx2xxxxxxxxx3xxxxxxxxx4xxxxxxxxx5xxxxxxxxx6xxxxxxxxx7xxxxxxxxx8xxxxxxxxx9xxxxxxxxx";
new gMaxHealth[ 33 ];
public plugin_init( ) 
{
	register_plugin( PLUGIN, VERSION, AUTHOR );
	register_event( "Health", "eHealth", "be" );
	RegisterHam( Ham_Spawn, "player", "ham_Spawn", 1 );
}

public eHealth( id )
{
	static health, max_health; 
	health = read_data( 1 );
	max_health = gMaxHealth[ id ];
	if( health > max_health )
		gMaxHealth[ id ] = max_health = health;
	show_bar( id, health * 100 / max_health );
}
	
public ham_Spawn( id )
{
	if( is_user_alive( id ) )
	{
		gMaxHealth[ id ] = get_user_health( id );
		show_bar( id, 100 );
		return HAM_HANDLED;
	}
	return HAM_IGNORED;
}

show_bar( id, health_percent )
{
	set_hudmessage( 255 - health_percent * 2, health_percent * 2, 0, 0.1, 0.9, 0, 6.0, 999.9, 0.0, 0.0, 3 );
	show_hudmessage( id, "%s", gBar[ min( 99, 100 - health_percent / BAR_SIZE ) ] );
}
