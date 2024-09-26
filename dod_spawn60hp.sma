#include <amxmodx> 
#include <fakemeta_util> 
#include <hamsandwich> 
#include <fun>

#define PLUGIN "Realistic HP Damager"
#define VERSION "1.0"
#define AUTHOR "PROLSROCK"
#define AXIS 2 
#define ALLIES 1
#define HEALTH 60



public plugin_init(){
register_plugin(PLUGIN, VERSION, AUTHOR) 
RegisterHam(Ham_Spawn, "player", "hamSpawn", 1)
}

public hamSpawn(id) 
{ 
if (!is_user_alive(id) || get_user_team(id) != AXIS)
if (!is_user_alive(id) || get_user_team(id) != ALLIES)
return
set_user_health(id,HEALTH)
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1049\\ f0\\ fs16 \n\\ par }
*/
