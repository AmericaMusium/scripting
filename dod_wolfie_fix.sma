

#include <amxmodx>
#include <hamsandwich>

new g_pAxisKiller

/* DoD teams */
#define ALLIES 1
#define AXIS 2

public plugin_init()
{
	register_plugin("dod_wolfie mortar fix", "0.2", "Fysiks")
	g_pAxisKiller = register_cvar("wolfie_mortarkiller", "1") // Change to 0 for worldspawn killer (won't show mortar symbol as weapon)
	RegisterHam(Ham_Use, "func_mortar_field", "hamUsed_func_mortar_field", 0)
}

public hamUsed_func_mortar_field(this, idcaller, idactivator, use_type, Float:value)
{
	if( get_pcvar_num(g_pAxisKiller) )
	{
		// Search for an Axis player
		static iNewCaller, iPlayers[32], iNumPlayers, iAxisPlayers
		get_players(iPlayers, iNumPlayers)
		if( iNumPlayers )
		{
			iAxisPlayers = 0
			for( new i = 0; i < iNumPlayers; i++ )
			{
				if( get_user_team(iPlayers[i]) == AXIS )
				{
					iPlayers[iAxisPlayers] = iPlayers[i]
					iAxisPlayers++
				}
			}
			iNewCaller = iAxisPlayers ? iPlayers[random(iAxisPlayers)] : 0
		}
		else
		{
			iNewCaller = 0
		}
		SetHamParamEntity(2, iNewCaller)  // set new idcaller
	}
	else
	{
		SetHamParamEntity(2, 0)  // set new idcaller as worldspawn
	}
	return HAM_HANDLED
}
