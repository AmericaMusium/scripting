// Original plugin ("dod_customize_flags") by =|[76AD]|= TatsuSaisei
// This version does not require a multi-body flag model

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>

new g_pFlagGerman, g_pFlagNeutral, g_pFlagAllies;

public plugin_init() 
{
	register_plugin("DOD Custom Flags", "1.0", "Fysiks");
}

public plugin_precache() 
{
	g_pFlagGerman = register_cvar("dod_flag_axis", "models/mapmodels/flags.mdl");
	g_pFlagNeutral = register_cvar("dod_flag_neutral", "models/w_wflag.mdl");
	g_pFlagAllies = register_cvar("dod_flag_allies", "models/w_aflag.mdl");
	register_forward(FM_KeyValue, "fm_keyvalue");
}

public fm_keyvalue(entid, handle) 
{
	if( pev_valid(entid) )
	{
		new szClassname[64], szKey[64], szValue[64];
		new szAxisFlagModel[64], szNeutralFlagModel[64], szAlliesFlagModel[64];
		
		get_kvd(handle, KV_ClassName, szClassname, charsmax(szClassname));
		get_kvd(handle, KV_KeyName, szKey, charsmax(szKey));
		get_kvd(handle, KV_Value, szValue, charsmax(szValue));
		
		if( equali(szClassname,"dod_control_point") )
		{	
			get_pcvar_string(g_pFlagGerman, szAxisFlagModel, charsmax(szAxisFlagModel));
			get_pcvar_string(g_pFlagNeutral, szNeutralFlagModel, charsmax(szNeutralFlagModel));
			get_pcvar_string(g_pFlagAllies, szAlliesFlagModel, charsmax(szAlliesFlagModel));

			if( equali(szKey, "point_reset_model") )
			{
				set_kvd(handle, KV_Value, szNeutralFlagModel);
			}
			else if( equali(szKey, "point_axis_model") )
			{
				set_kvd(handle, KV_Value, szAxisFlagModel);
			}
			else if( equali(szKey, "point_allies_model") )
			{
				set_kvd(handle, KV_Value, szAlliesFlagModel);
			}			
			else if( equal(szKey, "point_allies_model_bodygroup") || equal(szKey, "point_axis_model_bodygroup") || equal(szKey, "point_reset_model_bodygroup") )
			{
				set_kvd(handle, KV_Value, "0");
			}

		}
	}
}
