#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <dodx>
#include <dodfun>
#include <fun>
#include <xs>

#define PLUGIN "DOD RUKOPASH"
#define VERSION "1.0"
#define AUTHOR "[America][TheVaskov]"


public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR) 
	
	
	register_clcmd("say /ru", "rupash_func") 
	
	
}

public rupash_func(id) {
	
	
	
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1049\\ f0\\ fs16 \n\\ par }
*/
