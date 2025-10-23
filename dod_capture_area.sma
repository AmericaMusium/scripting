#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <engine>
#pragma semicolon 1

#define PLUGIN "Create DOD Capture Area"
#define VERSION "1.0"
#define AUTHOR "Your Name"

#define MAX_FLAGS 9

/*
после удаления энтити и создание подобной сервер упал и пизданулся
Control_Point_Area всегда в паре с dod_Control_Point
target == targetname
*/

enum Enum_Control_Point_Data
{
    origin,
    point_team_points,
    point_win_string,
    point_default_owner,
    point_reset_model_bodygroup,
    point_allies_model_bodygroup,
    angles,
    point_index,
    point_allies_capsound,
    point_axis_capsound,
    point_group,
    point_reset_model,
    point_axis_model,
    point_allies_model,
    point_points_for_cap,
    point_pointvalue,
    point_name,
    point_can_axis_touch,
    point_can_allies_touch,
    targetname
};

new g_flags_count;
new g_idx_flag[MAX_FLAGS + 1];
new CP_Data[MAX_FLAGS + 1][Enum_Control_Point_Data][32];

public plugin_precache()
{
    register_forward(FM_KeyValue, "forward_keyvalue");
}

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR);
    
    
    // Регистрируем команду для создания dod_capture_area
    // register_clcmd("cca", "cmd_create_capture_area");
    register_clcmd("cca2", "cmd_create_capture_area2");


    // RegisterHam(Ham_Touch, "dod_capture_area", "on_Ham_Touch_P",  1); // 
}


public cmd_create_capture_area2(id)
{
        // Создаём сущность dod_capture_area
    new Float:fOrigin[3];
    pev(id, pev_origin, fOrigin);

    new ent = create_capture_area2(3, 3, 10, fOrigin); // allies_num = 3, axis_num = 3, capture_time = 10

    if (ent) {
        client_print(id, print_chat, "Создана сущность dod_capture_area с ID %d", ent);
    } else {
        client_print(id, print_chat, "Не удалось создать сущность dod_capture_area");
    }

    return PLUGIN_HANDLED;
}


stock create_capture_area2(allies_num, axis_num, capture_time, Float:origin[3]) {

    new ent = engfunc( EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString,"dod_capture_area") );
    if (!pev_valid(ent)) 
    {
        return 0;
    }
    // Устанавливаем параметры
    fm_set_kvd(ent , "model", "*17", "dod_capture_area"); // работает без указателя модели
    fm_set_kvd(ent , "area_hud_sprite", "sprites/mapsprites/caparea.spr", "dod_capture_area");
    fm_set_kvd(ent , "target", "mainstreetflag", "dod_capture_area"); // mainstreetflag указывать targetname от controlpoin 
    fm_set_kvd(ent , "area_axis_endcap", "mainstreetaxis", "dod_capture_area");
    fm_set_kvd(ent , "area_allies_endcap", "mainstreetallies", "dod_capture_area");
    fm_set_kvd(ent , "area_time_to_cap", "2", "dod_capture_area");
    fm_set_kvd(ent , "area_axis_numcap", "1", "dod_capture_area");
    fm_set_kvd(ent , "area_allies_numcap", "1", "dod_capture_area");
    fm_set_kvd(ent , "area_axis_cancap", "1", "dod_capture_area");
    fm_set_kvd(ent , "area_allies_cancap", "1", "dod_capture_area");
    fm_set_kvd(ent , "classname", "dod_capture_area", "dod_capture_area");
    set_pev(ent, pev_origin, origin);
    dllfunc(DLLFunc_Spawn, ent);
    // Устанавливаем позицию

    

    // Спавним сущность
    

    return ent;
}


stock fm_set_kvd(entity, const key[], const value[], const class[])
{
	set_kvd(0, KV_ClassName, class);
	set_kvd(0, KV_KeyName, key);
	set_kvd(0, KV_Value, value);
	set_kvd(0, KV_fHandled, 0);

	return dllfunc(DLLFunc_KeyValue, entity, 0);
}


public forward_keyvalue(ent, handle)
{
    static temp_KV_KeyName[32], temp_KV_ClassName[32], temp_KV_Value[32];

    if (!pev_valid(ent))			// exit if invalid entity
        return FMRES_IGNORED;
    
    get_kvd(handle, KV_ClassName, temp_KV_ClassName, charsmax(temp_KV_ClassName));

    if(equal(temp_KV_ClassName, "dod_control_point") || equal(temp_KV_ClassName, "dod_capture_area"))
    {   
        get_kvd(handle, KV_KeyName, temp_KV_KeyName, charsmax(temp_KV_KeyName));
        get_kvd(handle, KV_Value, temp_KV_Value, charsmax(temp_KV_Value));


        server_print ("%d %s %s %s", ent, temp_KV_ClassName ,temp_KV_KeyName, temp_KV_Value);

        /*
        if(equal(temp_KV_KeyName, "origin"))
        {
            
        }
 

        if(g_idx_flag[g_flags_count] != )
        if(g_flags_count)
        */
    }
        
    return FMRES_IGNORED;
}









/*

public on_Ham_Touch_P(this, idothis)
{   
    server_print("on_Ham_Touch_P dod_capture_area");
    //  return HAM_SUPERCEDE;
}



public cmd_create_capture_area(id) {
    // Создаём сущность dod_capture_area
    new ent = create_capture_area(3, 3, 10); // allies_num = 3, axis_num = 3, capture_time = 10

    if (ent) {
        client_print(id, print_chat, "Создана сущность dod_capture_area с ID %d", ent);
    } else {
        client_print(id, print_chat, "Не удалось создать сущность dod_capture_area");
    }

    return PLUGIN_HANDLED;
}


stock create_capture_area(allies_num, axis_num, capture_time) {
    // Выделяем строку для класса сущности
    new classname = engfunc(EngFunc_AllocString, "dod_capture_area");

    // Создаём сущность
    new ent = engfunc(EngFunc_CreateNamedEntity, classname);

    if (!pev_valid(ent)) 
    {
        return 0; // Если сущность не создана, возвращаем 0
    }

    // Устанавливаем параметры сущности

    set_kvd(0, KV_KeyName, "area_allies_numcap");
    set_kvd(0, KV_Value, fmt("%d", allies_num));
    dllfunc(DLLFunc_KeyValue, ent, 0);

    set_kvd(0, KV_KeyName, "area_axis_numcap");
    set_kvd(0, KV_Value, fmt("%d", axis_num));
    dllfunc(DLLFunc_KeyValue, ent, 0);

    set_kvd(0, KV_KeyName, "area_capture_time");
    set_kvd(0, KV_Value, fmt("%d", capture_time));
    dllfunc(DLLFunc_KeyValue, ent, 0);

    // Спавним сущность
    dllfunc(DLLFunc_Spawn, ent);

    return ent; // Возвращаем ID созданной сущности
}
*/