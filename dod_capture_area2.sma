#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <dodx>
#include <engine>

#pragma semicolon 1

#define PLUGIN "Dynamic Capture Areas"
#define VERSION "1.0"
#define AUTHOR "Your Name"

// Настройки захвата
#define REQUIRED_PLAYERS 1     // Требуемое количество игроков
#define CAPTURE_TIME 4        // Время захвата в секундах

public plugin_precache()
{
    // Предзагрузка спрайта для зоны захвата
    precache_model("sprites/mapsprites/caparea.spr");
    register_forward(FM_KeyValue, "forward_keyvalue");
    register_forward(FM_Spawn, "forward_spawn");
}

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR);
    
    // Регистрируем перехват создания контрольных точек

    // RegisterHam(Ham_Touch, "dod_control_point", "on_Ham_Touch_P",  0); // 
}

public forward_keyvalue(ent, const key[], const value[])
{
    static classname[32];
    pev(ent, pev_classname, classname, charsmax(classname));
    
    // Сохраняем информацию о контрольных точках
    if(equal(classname, "dod_control_point"))
    {
        static keyname[32];
        get_kvd(0, KV_KeyName, keyname, charsmax(keyname));
        
        // Запоминаем targetname контрольной точки
        if(equal(keyname, "targetname"))
        {
            // Создаем зону захвата для этой точки
            create_capture_area(ent, value);
        }
    }
    return FMRES_IGNORED;
}

public forward_spawn(ent)
{
    if(pev_valid(ent))
    {
        static classname[32];
        pev(ent, pev_classname, classname, charsmax(classname));
        
        // Для существующих контрольных точек при спавне
        if(equal(classname, "dod_control_point"))
        {
            static targetname[32];
            pev(ent, pev_targetname, targetname, charsmax(targetname));
            
            if(targetname[0])
            {
                // Создаем зону захвата с задержкой
                set_task(2.0, "delayed_capture_area", ent);
            }
        }
    }
    return FMRES_IGNORED;
}

public delayed_capture_area(ent)
{
    static targetname[32];
    pev(ent, pev_targetname, targetname, charsmax(targetname));
    create_capture_area(ent, targetname);
}

stock create_capture_area(control_point_ent, const targetname[])
{
    if(!pev_valid(control_point_ent))
        return 0;

    // Получаем позицию контрольной точки
    new Float:origin[3];
    pev(control_point_ent, pev_origin, origin);
    
    // Создаем сущность зоны захвата
    new capture_area = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "dod_capture_area"));
    
    if(!pev_valid(capture_area))
        return 0;

    // Основные параметры
    fm_set_kvd(capture_area, "target", targetname, "dod_capture_area");
    fm_set_kvd(capture_area, "area_hud_sprite", "sprites/mapsprites/caparea.spr", "dod_capture_area");
    
    // Параметры захвата
    fm_set_kvd(capture_area, "area_allies_numcap", fmt("%d", REQUIRED_PLAYERS), "dod_capture_area");
    fm_set_kvd(capture_area, "area_axis_numcap", fmt("%d", REQUIRED_PLAYERS), "dod_capture_area");
    fm_set_kvd(capture_area, "area_time_to_cap", fmt("%d", CAPTURE_TIME), "dod_capture_area");
    
    // Настройки видимости
    fm_set_kvd(capture_area, "area_axis_cancap", "1", "dod_capture_area");
    fm_set_kvd(capture_area, "area_allies_cancap", "1", "dod_capture_area");
    
    // Позиционирование

    new Float:Search_Origin[3];
    entity_get_vector(capture_area, EV_VEC_origin, Search_Origin);
    server_print (" Search_Origin %f %f %f", Search_Origin[0],Search_Origin[1],Search_Origin[2]);
    // engfunc(EngFunc_SetOrigin, capture_area, origin);
    dllfunc(DLLFunc_Spawn, capture_area);
    
    // Привязка к контрольной точке
    set_pev(capture_area, pev_owner, control_point_ent);
    
    return capture_area;
}

stock fm_set_kvd(entity, const key[], const value[], const class[])
{
    set_kvd(0, KV_ClassName, class);
    set_kvd(0, KV_KeyName, key);
    set_kvd(0, KV_Value, value);
    set_kvd(0, KV_fHandled, 0);
    return dllfunc(DLLFunc_KeyValue, entity, 0);
}


public on_Ham_Touch_P(this, idothis)
{   
    server_print("on_Ham_Touch_P dod_capture_area");
    return HAM_SUPERCEDE;
}
