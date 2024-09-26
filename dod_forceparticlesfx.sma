//////////////////////////////////////////////////////////////////////////////////
//
//	dod force particlefx
//		- Version 1.1
//		- 04.06.2008
//		- diamond-optic
//
//////////////////////////////////////////////////////////////////////////////////
//
// Information:
//
// - Force clients to use a specific cl_particlefx value
//
//////////////////////////////////////////////////////////////////////////////////
//
// CVARs:
//
//	dod_forceparticlefx "1"		//turn ON(1)/OFF(0)
// 	dod_forceparticlefx_value "2"	//lock particlefx to this setting
//
//////////////////////////////////////////////////////////////////////////////////
//
// Changelog:
//
// - 09.28.2006 Version 1.0
//	Initial Release
//
// - 01.07.2006 Version 1.1
//	Plugin now works again :-)
//
// - 04.06.2008 Version 1.1
//	Plugin re-release
//
//////////////////////////////////////////////////////////////////////////////////

#include <amxmodx>

#define VERSION "1.1"
#define SVERSION "v1.1 - by diamond-optic (www.AvaMods.com)"

new p_onoff, p_particlefx

public plugin_init()
{
	register_plugin("Dod Force Particlefx",VERSION,"AMXX DoD Team")
	register_cvar("dod_forceparticlefx_stats",SVERSION,FCVAR_SERVER|FCVAR_SPONLY)
	
	p_onoff = register_cvar("dod_forceparticlefx","1")
	p_particlefx = register_cvar("dod_forceparticlefx_value","2")
	
	register_concmd("particle_block","funcBlock")
}

public client_putinserver(id)
	if(is_user_connected(id) && !is_user_bot(id) && get_pcvar_num(p_onoff))
		set_task(1.0,"funcSetParticleFX",id)

public funcSetParticleFX(id)
	if(is_user_connected(id) && !is_user_bot(id) && get_pcvar_num(p_onoff))
		client_cmd(id,"cl_particlefx %d ; alias cl_particlefx particle_block",get_pcvar_num(p_particlefx))	

public funcBlock(id)
{
	client_print(id,print_console,"Sorry but cl_particlefx is locked at %d by the server...",get_pcvar_num(p_particlefx))
	
	return PLUGIN_HANDLED
}
