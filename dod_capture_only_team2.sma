#include <amxmisc>
#include <fakemeta>

#define PLUGIN "DOD_FourManCaps"
#define VERSION "1.0"
#define AUTHOR "Vet(3TT3V)"

#define CL_CAPAREA "dod_control_point"
#define KEY_ALLYNUM "area_allies_numcap"
#define KEY_AXISNUM "area_axis_numcap"

new g_capally[32]		// Ally # to cap
new g_capaxis[32]		// Axis # to cap
new g_capent[32]		// Entity #
new g_capcnt		// Count

public plugin_precache()
{
	register_forward(FM_KeyValue, "forward_keyvalue")
	return PLUGIN_CONTINUE
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	// Принудительно устанавливаем захват флагов только для 4 игроков
	set_task(1.0, "force_four_man_caps")
	return PLUGIN_CONTINUE
}

public forward_keyvalue(ent, handle)
{
	static keyname[32], keyvalue[8], tmpint, temp_KV_ClassName[32]

	if (!pev_valid(ent))			// exit if invalid entity
		return FMRES_IGNORED


    get_kvd(handle, KV_ClassName, temp_KV_ClassName, 31)
	get_kvd(handle, KV_KeyName, keyname, 31)
    get_kvd(handle, KV_Value, keyvalue, 7)
    if(equal(temp_KV_ClassName, "dod_control_point"))
    {
        set_kvd(0, KV_ClassName, "dod_capture_area")
        set_kvd(0, KV_KeyName, KEY_AXISNUM)
        set_kvd(0, KV_Value, "8")
        set_kvd(0, KV_fHandled, 0)
        dllfunc(DLLFunc_KeyValue, ent, 0)

        set_kvd(0, KV_ClassName, "dod_capture_area")
        set_kvd(0, KV_KeyName, KEY_ALLYNUM)
        set_kvd(0, KV_Value, "7")
        set_kvd(0, KV_fHandled, 0)
        dllfunc(DLLFunc_KeyValue, ent, 0)
    }

	if (equali(keyname, KEY_ALLYNUM)) {
		get_kvd(handle, KV_Value, keyvalue, 7)
		tmpint = str_to_num(keyvalue)
		g_capally[g_capcnt] = tmpint
		g_capent[g_capcnt] = ent
		++g_capcnt
	} else if (equali(keyname, KEY_AXISNUM)) {
		get_kvd(handle, KV_Value, keyvalue, 7)
		tmpint = str_to_num(keyvalue)
		g_capaxis[g_capcnt] = tmpint
		g_capent[g_capcnt] = ent
		++g_capcnt

	}
	return FMRES_IGNORED
}

public force_four_man_caps()
{
	for (new i = 0; i < g_capcnt; i++) {
		if (g_capally[i])
			fm_set_kvd(g_capent[i], KEY_ALLYNUM, "4", CL_CAPAREA)
		if (g_capaxis[i])
			fm_set_kvd(g_capent[i], KEY_AXISNUM, "4", CL_CAPAREA)
	}

	// Уведомление о том, что флаги захватываются только четырьмя игроками
	set_hudmessage(255, 128, 255, -1.0, 0.40, 0, 4.0, 5.0, 0.5, 0.15, 4)
	show_hudmessage(0, "Флаги захватываются только группой из четырёх игроков!")
}

stock fm_set_kvd(entity, const key[], const value[], const class[])
{
	set_kvd(0, KV_ClassName, class)
	set_kvd(0, KV_KeyName, key)
	set_kvd(0, KV_Value, value)
	set_kvd(0, KV_fHandled, 0)

	return dllfunc(DLLFunc_KeyValue, entity, 0)
}