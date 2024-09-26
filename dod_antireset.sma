///////////////////////////////////////////////////////////////////////////////////////
//
//	DoD Anti Score Reset
//		- Version 2.0
//		- 07.26.2009
//		- diamond-optic
//
//////////////////////////////////////////////////////////////////////////////////
//
// Credits:
//
//	- HAWKEYE: plugin created due to his constant score resetting
//
//////////////////////////////////////////////////////////////////////////////////
//
// Information:
//
//	- Saves clients scores so if they reconnect before
//	  the map has changed, they will continue with the
//	  score they had when they left
//
//	- Prevents clients from reconnecting to reset their awful scores
//	- Saved information is removed on map change
//
//	- By default, 256 steam ids are stored before it starts
//	  overwriting. This should be more then plenty to stop
//	  players from reseting their scores in most cases
//
//	- Increasing the max stored names (SETTING_MAXUSERS define)
//	  could allow you to save the score for almost anyone that
//	  played as long as they rejoin before the map has changed
//
//////////////////////////////////////////////////////////////////////////////////
//
// Commands:
//
//	dod_resetscore		//Use this command to force your score to reset
//				//Default Admin Level: ADMIN_LEVEL_B (n flag)
//
//////////////////////////////////////////////////////////////////////////////////
//
// Compiler Defines:
//
//	SETTING_MAXUSERS	256		//Max # of clients to save the score of 
//	SETTING_ADMINLEVEL	ADMIN_LEVEL_B	//Default admin to use dod_resetscore cmd
//	SETTING_MAXPLAYERS 	32		//Max players allowed on server (slot count)
//
//////////////////////////////////////////////////////////////////////////////////
//
// Changelog:
//
// 	- 11.30.2007 Version 1.0
//		Initial Release
//
// 	- 06.28.2008 Version 1.1
//		Now saves data on kills & deaths instead of spawn
//		Added command to force your score to reset
//		Changed some variables to statics
//
// 	- 01.28.2009 Version 1.2
//		Fixed problem with deaths not always saving
//		Changed DoDx death forward to HamSandwich
//
// 	- 07.26.2009 Version 2.0
//		Removed CVAR
//		Added compiler defines to control settings
//
//////////////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////
// Includes
//
#include <amxmodx>
#include <amxmisc>
#include <dodfun>
#include <dodx>
#include <hamsandwich>

/////////////////////////////////////////////////
// Settings
//
#define SETTING_MAXUSERS	256
#define SETTING_ADMINLEVEL	ADMIN_LEVEL_B
#define SETTING_MAXPLAYERS 	32

/////////////////////////////////////////////////
// Version
//
#define VERSION "2.0"
#define SVERSION "2.0 by diamond-optic (www.avamods.com)"

new g_MaxUsers = SETTING_MAXUSERS
new dataSaved[SETTING_MAXUSERS][3]
new dataAuth[SETTING_MAXUSERS][32]
new dataPlace[SETTING_MAXPLAYERS+1]
new dataLast

public plugin_init()
{
	register_plugin("DoD Anti Score Reset",VERSION,"AMXX DoD Team")
	register_cvar("dod_antireset_stats",SVERSION,FCVAR_SERVER|FCVAR_SPONLY)
	
	register_concmd("dod_resetscore","force_reset",SETTING_ADMINLEVEL,"Manually Force Your Score To Reset")
	
	RegisterHam(Ham_Killed,"player","func_HamKilled")
}

public client_putinserver(id)
	if(is_user_connected(id) && !is_user_bot(id))
		set_task(5.0,"check_data",id)

public check_data(id)
{	
	if(is_user_connected(id))
		{
		static authid_check[32]
		get_user_authid(id,authid_check,31)
		
		for(new i = 0; i < g_MaxUsers; i++)
			{
			if(equal(dataAuth[i],authid_check))
				{
				dod_set_user_score(id,dataSaved[i][0])
				dod_set_user_kills(id,dataSaved[i][1])
				dod_set_pl_deaths(id,dataSaved[i][2])
				
				dataPlace[id] = i
				
				return PLUGIN_CONTINUE
				}
			}
			
		dataPlace[id] = 0
		}
		
	return PLUGIN_CONTINUE
}

public func_HamKilled(victim,killer,shouldgib)
{
	if(is_user_connected(killer) && !is_user_bot(killer))
		save_data(killer,0)
		
	if(is_user_connected(victim) && !is_user_bot(victim))
		save_data(victim,1)
}

public save_data(id,death)
{
	new score = dod_get_user_score(id)
	new kills = dod_get_user_kills(id)
	new deaths = dod_get_pl_deaths(id)
	
	if(death)
		 deaths += 1
	
	static authid_save[32]
	get_user_authid(id,authid_save,31)
	
	if(dataPlace[id])
		{
		if(equali(dataAuth[dataPlace[id]],authid_save))
			{
			dataSaved[dataPlace[id]][0] = score
			dataSaved[dataPlace[id]][1] = kills
			dataSaved[dataPlace[id]][2] = deaths
			
			return PLUGIN_CONTINUE
			}
		}
	else
		{			
		for(new i = 0; i < g_MaxUsers; i++)
			{
			if(equali(dataAuth[i],authid_save))
				{
				dataSaved[i][0] = score
				dataSaved[i][1] = kills
				dataSaved[i][2] = deaths
				
				dataPlace[id] = i
				
				return PLUGIN_CONTINUE
				}
			}
		
		dataAuth[dataLast] = authid_save
		dataSaved[dataLast][0] = score
		dataSaved[dataLast][1] = kills
		dataSaved[dataLast][2] = deaths
		
		if(dataLast >= g_MaxUsers-1)
			dataLast = 0
		else
			dataLast++
		}
	
	return PLUGIN_CONTINUE
}

////////////////////////////////////////////////////////////////
//	Manually Force Score Reset
//
public force_reset(id,level,cid)
{
	if(cmd_access(id,level,cid,1))
		{		
		dod_set_user_kills(id,0,1)
		dod_set_pl_deaths(id,0,1)
		dod_set_user_score(id,0,1)
		
		save_data(id,0)
		}
	
	return PLUGIN_HANDLED
}
