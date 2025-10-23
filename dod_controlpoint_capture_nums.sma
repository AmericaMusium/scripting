#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <engine>
/*
Ключи для dod_control_point:
    origin
    point_team_points
    point_win_string
    point_default_owner
    point_reset_model_bodygroup
    point_allies_model_bodygroup
    angles
    point_index
    point_allies_capsound
    point_axis_capsound
    point_group
    point_reset_model
    point_axis_model
    point_allies_model
    point_points_for_cap
    point_pointvalue
    point_name
    point_can_axis_touch
    point_can_allies_touch
    targetname
Ключи для dod_capture_area:
    model
    area_hud_sprite
    target
    area_axis_endcap
    area_allies_endcap
    area_time_to_cap
    area_axis_numcap
    area_allies_numcap
    area_axis_cancap
    area_allies_cancap

/////////////// Заблокировать забор флагов и зон можно через 
    RegisterHam(Ham_Touch, "dod_control_point", "on_Ham_Touch_P",  0); // 
    RegisterHam(Ham_Touch, "dod_capture_area", "on_Ham_Touch_P",  0); // 
public on_Ham_Touch_P(this, idothis)
{       
    return HAM_SUPERCEDE;
*/

new g_idx_flag[32]; // Entity #
new g_flags_count;		// Count


public plugin_precache()
{
    register_forward(FM_KeyValue, "forward_keyvalue")
    //set_task(2.0, "flags_retune")
    RegisterHam(Ham_Use, "dod_control_point", "on_Ham_Use_P",  1); // 
    RegisterHam(Ham_Touch, "dod_control_point", "on_Ham_Touch_P",  0); // 
    RegisterHam(Ham_Touch, "dod_capture_area", "on_Ham_Touch_P",  0); // 
}


public forward_keyvalue(ent, handle)
{
    static temp_KV_KeyName[32], temp_KV_ClassName[32], temp_KV_Value[32];

    if (!pev_valid(ent))			// exit if invalid entity
        return FMRES_IGNORED
    
    get_kvd(handle, KV_ClassName, temp_KV_ClassName, 31)

    if(equal(temp_KV_ClassName, "dod_control_point") || equal(temp_KV_ClassName, "dod_capture_area"))
    {   
        get_kvd(handle, KV_KeyName, temp_KV_KeyName, 31)

        if(equal(temp_KV_KeyName, "origin"))
        {
            g_flags_count++
            g_idx_flag[g_flags_count] = ent
        }
        if(equal(temp_KV_KeyName, "target"))
        {   
            get_kvd(handle, KV_Value, temp_KV_Value, 31)
            server_print("temp_KV_Value %s", temp_KV_Value)
            g_flags_count++
            g_idx_flag[g_flags_count] = ent
        }

    }
        
    return FMRES_IGNORED
}

public flags_retune()
{   
    for (new i = 1; i < g_flags_count; i++) 
    {
        // ent . key , value , classname 
        fm_set_kvd(g_idx_flag[i], "area_axis_numcap", "13", "dod_capture_area")

    }
    server_print("Retune_complete")
    set_task(2.0, "flags_retune")
}


stock fm_set_kvd(entity, const key[], const value[], const class[])
{
	set_kvd(0, KV_ClassName, class)
	set_kvd(0, KV_KeyName, key)
	set_kvd(0, KV_Value, value)
	set_kvd(0, KV_fHandled, 0)

	return dllfunc(DLLFunc_KeyValue, entity, 0)
}





public on_Ham_Use_P(this, idcaller, idactivator, use_type, Float:value)
{   
    // Отлавливает последнего кто трогал флаг

    if(pev_valid(this) && pev_valid(idcaller) && pev_valid(idactivator))
    {
        static t_Clsname[32], t_Clsname2[32], t_Clsname3[32];
        entity_get_string(this, EV_SZ_classname , t_Clsname, charsmax(t_Clsname))
        entity_get_string(idcaller, EV_SZ_classname , t_Clsname2, charsmax(t_Clsname2))
        entity_get_string(idcaller, EV_SZ_classname , t_Clsname3, charsmax(t_Clsname3))


        server_print(" %s %s %s %d %f", t_Clsname, t_Clsname2, t_Clsname3, use_type , value)
    }
}

public on_Ham_Touch_P(this, idothis)
{       
    return HAM_SUPERCEDE;
}