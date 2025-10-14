






#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <engine>
#include <dodx>
#include <dodfun>
#include <dod_stocks>
#include <fun>


public plugin_init()
{
    register_plugin("DOD KeyValue", "0.0", "America");
    // register_native("DispatchKeyValue",		"__DispatchKeyValue")
}

// Done in precache so it is caught before the entities are spawned
public plugin_precache() 
{
	register_forward(FM_KeyValue, "forward_keyvalue")
}





public forward_keyvalue(ent, handle) 
{
	// new ent = get_param(1)
	
	new szClassname[32], szKey[32], szValue[32]
	
	if (pev_valid(ent))
	{
		get_string(2, szKey, 31)
		get_string(3, szValue, 31)
		pev(ent, pev_classname, szClassname, 31)
		
		set_kvd(0, KV_ClassName, szClassname)
		set_kvd(0, KV_KeyName, szKey)
		set_kvd(0, KV_Value, szValue)
		set_kvd(0, KV_fHandled, 0)
		
		dllfunc(DLLFunc_KeyValue, ent, 0)
        server_print("%s %s %s", szClassname, szKey, szValue)
	}
	
	return 1
}
