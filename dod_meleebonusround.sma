//////////////////////////////////////////////////////////////////////////////////
//
//	DoD Melee Bonus
//		- Version 1.0
//		- 06.28.2008
//		- original: FireStorm
//		- updated: diamond-optic
//
//////////////////////////////////////////////////////////////////////////////////
//
// Information:
//
// 	- Gain health for melee kills
//
// CVARs: 
//
//	dod_meleebonus "1" 		//Turn On(1)/Off(0)
//	dod_meleebonus_hp "10"		//health to add for each melee kill
//
// Changelog:
//
//	- unknown date Version 0.5beta
//		FireStorm's version
//
//	- 08.16.2006 Version 0.6beta
//		Reposted plugin
//		Added pcvars
//		Got rid of extra code
//		Added is_user_connected check
//
//	- 06.28.2008 Version 1.0
//		Removed beta status
//		Removed an incorrect (and unneccesary) return
//		Improved code a little bit
//		Renamed CVARs
//		Changed a variable to a static
//
//////////////////////////////////////////////////////////////////////////////////


#include <amxmodx>
#include <fun>
#include <dodx>

#define VERSION "1.0"
#define SVERSION "v1.0 - by diamond-optic (www.AvaMods.com)"

new p_enabled, p_givehealth

public plugin_init()
{
	register_plugin("DoD Melee Bonus",VERSION,"AMXX DoD Team")
	register_cvar("dod_meleebonus_stats",SVERSION,FCVAR_SERVER|FCVAR_SPONLY)
	
	p_enabled = register_cvar("dod_meleebonus","1")
	p_givehealth = register_cvar("dod_meleebonus_hp","10")
}

public client_death(killer,victim,wpnindex,hitplace,TK)
{
	if(get_pcvar_num(p_enabled) && is_user_connected(killer) && is_user_alive(killer) && !TK)
		{
		if(wpnindex == DODW_GARAND_BUTT || wpnindex == DODW_K43_BUTT || wpnindex == DODW_KAR_BAYONET || wpnindex == DODW_AMERKNIFE || wpnindex == DODW_BRITKNIFE || wpnindex == DODW_GERKNIFE || wpnindex == DODW_SPADE)
			{
			static killername[32]
			get_user_name(killer,killername,31)
			new addition = get_pcvar_num(p_givehealth)
			
			set_user_health(killer,(get_user_health(killer)+addition))
			
			client_print(0,print_chat,"[Melee Bonus] %s received an additional %dhp for a melee kill!",killername,addition)
			
			set_hudmessage(36,39,192,-1.0,0.9,0,6.0,4.0,0.1,0.2,-1)
			show_hudmessage(killer,"+%dhp",addition)
			}
		}
}
