#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#pragma semicolon 1
#define PLUGIN "dod_customize_flags"
#define VERSION "76.1"
#define AUTHOR "=|[76AD]|= TatsuSaisei"

new flag_set, flag_n, flag_u;

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	//-----------------------------------------------------------
	new plugin_info[128];
	strcat (plugin_info, "Version: ", 127);
	strcat (plugin_info, VERSION, 127);
	strcat (plugin_info, " by: ", 127);
	strcat (plugin_info, AUTHOR, 127);
	register_cvar(PLUGIN, plugin_info, FCVAR_SERVER|FCVAR_SPONLY);
	//-----------------------------------------------------------
}

public plugin_precache() 
{
	flag_set = register_cvar("dod_cpflag_set", "models/76AD/AD76_Flags01.mdl");
	flag_n = register_cvar("dod_cpflag_n", "models/76AD/AD76_n.mdl");
	flag_u = register_cvar("dod_cpflag_u", "models/76AD/AD76_u.mdl");
	register_forward(FM_KeyValue, "fm_keyvalue");
}

public fm_keyvalue(entid,handle) 
{
	if ( pev_valid(entid) )
	{
		new classname[64], key[64], value[64];
		new flagset[64], flagn[64], flagu[64];
		
		get_kvd(handle, KV_ClassName, classname, 63);
		get_kvd(handle, KV_KeyName, key, 63);
		get_kvd(handle, KV_Value, value, 63);
		
		if(equali(classname,"dod_control_point"))
		{	
			get_pcvar_string(flag_set,flagset,63);
			get_pcvar_string(flag_n,flagn,63);
			get_pcvar_string(flag_u,flagu,63);

			if(equali(value,"models/flags.mdl") || equali(value,"models/mapmodels/flags.mdl")) set_kvd(handle,KV_Value, flagset) ;
			else if(!equali(value,"models/null.mdl") && !equali(value,"models/mapmodels/null.mdl"))
			{
				if(equali(key,"point_reset_model")) set_kvd(handle,KV_Value, flagn);
				else if(equali(key,"point_axis_model")) set_kvd(handle,KV_Value, flagset);
				else if(equali(key,"point_allies_model")) set_kvd(handle,KV_Value, flagu);
			}
		}
	}
}
