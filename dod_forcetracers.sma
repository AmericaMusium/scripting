//////////////////////////////////////////////////////////////////////////////////
//
//	DoD Force Tracers
//		- Version 1.0
//		- 04.06.2008
//		- diamond-optic
//
//////////////////////////////////////////////////////////////////////////////////
//
// Information:
//
// - Force all clients to use your tracer settings
// - Thanks to Wilson [29th ID] for the new method of locking the cmds
// - Thanks to Zor, teame06, and the others from #amxmodx that helped me
//
// CVARs & Commands:
//
//	dod_forcetracers  //Turn on(1)/off(0) forcing of tracer settings
//	dod_reloadtracers //Manually force tracer settings to clients (use after making changes ingame, OLD_METHOD define must be 1)
//	
//	//These control what values are set to the client:
//		dod_traceralpha "0.35"
//		dod_tracerblue "2.50"
//		dod_tracergreen "0.5"
//		dod_tracerlength "1.5"
//		dod_traceroffset "10"
//		dod_tracerred "0.5"
//		dod_tracerspeed "1000"
//
// EXTRA:
//
//	Change OLD_METHOD define:
//		0 = new method (more effecient)
//		1 = old method (allow on the fly changing)
//
// Changelog:
//
// - 12.19.2005 Version 0.0a
//	actually got it to work lol...
//	fixed testing bugs
//
// - 12.21.2005 Version 0.0b
//	added cvar "dod_forcetracers"
//	removed extra testing code
//
// - 12.25.2005 Version 0.1
//	added cvar's for each tracer setting
//	removed client_print lines
//
// - 01.11.2006 Version 0.2
//	catches respawn to reforce settings
//
// - 03.05.2006 Version 0.3
//	updated to 1.70 CVAR pointers
//
// - 03.15.2006 Version 0.4
//	added dod_reloadtracers to manually force tracer settings
//
// - 04.18.2006 Version 0.5
//	dont bother if they're not connected or bots
//
// - 06.07.2006 Version 0.6
//	fixed some mistakes with the return values
//
// - 07.24.2006 Version 0.6b
//	cleaned up code a bit
//
// - 08.28.2006 Version 0.7
//	much better way of locking cmds (thanks Wilson [29th ID])
//	added OLD_METHOD define for selecting method of setting tracers
//	changed some returns
//
// - 04.06.2008 Version 1.0
//	Code Improvements
//
//////////////////////////////////////////////////////////////////////////////////

#include <amxmodx>

#define VERSION "1.0"
#define SVERSION "v1.0 - by diamond-optic (www.AvaMods.com)"

#define OLD_METHOD 	0

new p_dod_forcetracers
new p_dod_traceralpha, p_dod_tracerblue, p_dod_tracergreen, p_dod_tracerlength, p_dod_traceroffset, p_dod_tracerred, p_dod_tracerspeed

public plugin_init()
{
	register_plugin("DoD Force Tracers",VERSION,"AMXX DoD Team")
	register_cvar("dod_forcetracers_stats",SVERSION,FCVAR_SERVER|FCVAR_SPONLY)
	
	p_dod_forcetracers = register_cvar("dod_forcetracers", "1")
	p_dod_traceralpha = register_cvar("dod_traceralpha", "0.35")
	p_dod_tracerblue = register_cvar("dod_tracerblue", "0.50")
	p_dod_tracergreen = register_cvar("dod_tracergreen", "1.5")
	p_dod_tracerlength = register_cvar("dod_tracerlength", "1.5")
	p_dod_traceroffset = register_cvar("dod_traceroffset", "10")
	p_dod_tracerred = register_cvar("dod_tracerred", "0.5")
	p_dod_tracerspeed = register_cvar("dod_tracerspeed", "3000")
	
	register_concmd("dod_reloadtracers","force_manual",ADMIN_CVAR,"Manually force tracer settings")
	
	register_concmd("tracer_block", "block_cmd")
}

public client_putinserver(id)	
	if(get_pcvar_num(p_dod_forcetracers) && is_user_connected(id) && !is_user_bot(id))
		set_task(5.0,"force_tracers",id)	//set the task

public force_tracers(id)
{
	if(get_pcvar_num(p_dod_forcetracers) && is_user_connected(id) && !is_user_bot(id))
		{
		
#if OLD_METHOD == 0
		
		client_cmd(id,"traceralpha %f;alias traceralpha tracer_block",get_pcvar_float(p_dod_traceralpha))
		client_cmd(id,"tracerblue %f;alias tracerblue tracer_block",get_pcvar_float(p_dod_tracerblue))
		client_cmd(id,"tracergreen %f;alias tracergreen tracer_block",get_pcvar_float(p_dod_tracergreen))
		client_cmd(id,"tracerlength %f;alias tracerlength tracer_block",get_pcvar_float(p_dod_tracerlength))
		client_cmd(id,"traceroffset %f;alias traceroffset tracer_block",get_pcvar_float(p_dod_traceroffset))
		client_cmd(id,"tracerred %f;alias tracerred tracer_block",get_pcvar_float(p_dod_tracerred))
		client_cmd(id,"tracerspeed %f;alias tracerspeed tracer_block",get_pcvar_float(p_dod_tracerspeed))

#else

		client_cmd(id,"traceralpha %f",get_pcvar_float(p_dod_traceralpha))
		client_cmd(id,"tracerblue %f",get_pcvar_float(p_dod_tracerblue))
		client_cmd(id,"tracergreen %f",get_pcvar_float(p_dod_tracergreen))
		client_cmd(id,"tracerlength %f",get_pcvar_float(p_dod_tracerlength))
		client_cmd(id,"traceroffset %f",get_pcvar_float(p_dod_traceroffset))
		client_cmd(id,"tracerred %f",get_pcvar_float(p_dod_tracerred))
		client_cmd(id,"tracerspeed %f",get_pcvar_float(p_dod_tracerspeed))

#endif
		
		}
}
public force_manual(id)
{
	if(get_pcvar_num(p_dod_forcetracers))
		{
		
#if OLD_METHOD == 0
		
		console_print(id,"You cannot re-force tracer settings while using the new method define!!!")

#else
		
		new id,iPlayer[32],iNumPlayers
		get_players(iPlayer,iNumPlayers)
				
		for(new i = 0; i < iNumPlayers; i++)
			{
			id = iPlayer[i]

			client_cmd(id,"traceralpha %f",get_pcvar_float(p_dod_traceralpha))
			client_cmd(id,"tracerblue %f",get_pcvar_float(p_dod_tracerblue))
			client_cmd(id,"tracergreen %f",get_pcvar_float(p_dod_tracergreen))
			client_cmd(id,"tracerlength %f",get_pcvar_float(p_dod_tracerlength))
			client_cmd(id,"traceroffset %f",get_pcvar_float(p_dod_traceroffset))
			client_cmd(id,"tracerred %f",get_pcvar_float(p_dod_tracerred))
			client_cmd(id,"tracerspeed %f",get_pcvar_float(p_dod_tracerspeed))
			}
			
		console_print(id, "Tracer settings have been forced to all clients")

#endif

		}
	
	return PLUGIN_HANDLED
}

#if OLD_METHOD == 0

public block_cmd(id)
{
	client_print(id, print_console, "Sorry but that command is locked by the server...")
	
	return PLUGIN_HANDLED
}

#endif
