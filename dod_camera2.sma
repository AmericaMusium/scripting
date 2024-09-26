/*****************************

Lagless 3RD person view

- make sure to have sv_cheats 1 in your server.cfg ;don't worry, cheat commands are blocked by plugin


- update log -

1.0.0
	- original release
	
1.0.1
	- added "notarget" cheat command as forbidden
	- player's model is now transparent
	
*****************************/
#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta_util>

#define VERSION "1.0.1"
#define MAX_PLAYERS    32

new g_iCount[MAX_PLAYERS+1]

public plugin_init()
{
	register_plugin("Lagless 3RD Camera", VERSION, "DK")
	register_forward(FM_AddToFullPack, "addToFullPack", 1)
	
	register_clcmd("say /cam2", "CameraChangerAdvanced")
	register_clcmd("say .cam2", "CameraChangerAdvanced")
	register_clcmd("say_team /cam2", "CameraChangerAdvanced")
	register_clcmd("say_team .cam2", "CameraChangerAdvanced")

	register_clcmd("god",	"BlockCommand")
	register_clcmd("fullupdate", 	"BlockCommand")
	register_clcmd("noclip", 	"BlockCommand")
	register_clcmd("notarget", 	"BlockCommand")
	
	register_impulse( 101, "BlockCommand" )
	register_impulse( 102, "BlockCommand" )
	register_impulse( 202, "BlockCommand" )
	
	set_task(3.0, "CheatsCheck", _, _, _, "b") 
}

public client_putinserver(id){
	g_iCount[id] = 0
}

public addToFullPack(es, e, ent, host, hostflags, player, pSet)
{
	if (player && ent == host && get_orig_retval())
    {
		set_es(es, ES_Solid, SOLID_SLIDEBOX)
		set_es(es, ES_RenderMode, kRenderTransAlpha)
		set_es(es, ES_RenderAmt, 254)
    }
}

public CameraChangerAdvanced(id){	
	query_client_cvar(id, "cam_snapto", "CameraChangerAdvancedHandler")
}

public CameraChangerAdvancedHandler(id, const cvar[], const value[]){ 
	if(str_to_num(value) != 0){
		client_cmd(id, "firstperson")
		client_cmd(id, "cam_snapto 0")
	}
	else
	{
		new ip[32]
		get_user_ip(0, ip, charsmax(ip))
		client_cmd(id, "cam_command 1")
		client_cmd(id, "cam_idealyaw 0")
		client_cmd(id, "cam_snapto 1")
		client_cmd(id, "thirdperson")
		client_print(id, print_chat, "[Lagless 3rd] You have to reconnect for the camera to work.") 
		//client_cmd(id, "wait;wait;wait;wait;wait;^"retry^" ") //doesn't work anymore
	}
}

public BlockCommand(id){
	return PLUGIN_HANDLED
}

public CheatsCheck()
{
	new players[MAX_PLAYERS], inum 
	get_players(players, inum, "ch") //don't collect BOTs & HLTVs 
	for(new i; i<inum; ++i) 
	{ 
		query_client_cvar(players[i] , "fakeloss" , "cvar_result")
		query_client_cvar(players[i] , "fakelag" , "cvar_result")
	}
}

public cvar_result(id, const cvar[], const value[]) 
{ 
    new Float:fValue = str_to_float(value)	
	
    if(!fValue) 
        return
    client_cmd(id, "fakeloss 0; fakelag 0") 
    client_print(id, print_chat, "Cheat commands are forbidden.") 
     
    if(++g_iCount[id] >= 2){ 
		server_cmd("kick #%d Cheat commands are forbidden.", get_user_userid(id)) 
    }
}
