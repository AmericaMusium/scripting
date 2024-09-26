#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <fakemeta_util>
#include <dodx>
#include <dodfun>
#include <fun>
#include <engine>
#include <amxmisc>

#define PLUGIN "DOD ZENIT"
#define VERSION "1.4"
#define AUTHOR "[America][TheVaskov]"

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_clcmd("say zenit", "setnoclip") 
	register_clcmd("say pvo", "setnonoclip") 
	register_clcmd(
	// Add your code here...
}

public setnoclip(id){
	set_pev(id, pev_movetype, MOVETYPE_NOCLIP)
}

public setnonoclip(id){
	set_pev(id, pev_movetype, MOVETYPE_WALK)
}


set_pdata_int(id,264,0)
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1049\\ f0\\ fs16 \n\\ par }
*/
