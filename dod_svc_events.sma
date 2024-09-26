#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <dodx>
#include <dodfun>

#define PLUGINNAME	"AMXX SVC Events"
#define VERSION		"1.0"
#define AUTHOR		"America"



public plugin_init()
{
	register_plugin( PLUGINNAME, VERSION, AUTHOR )

	
	register_event( "5" , "event_resethud", "a" )

}


public event_resethud()
{

    	client_print(0,print_chat,"=))))))))))) ")
}