#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <dodx>
#include <dodfun>
#include <fun>
#include <engine>
#include <okapi>
#include <reapi>

/// переопределяем смещения 
// Linux extra offsets
#define linux_diff_weapon 4
#define linux_diff_player 5
#define linux_diff_animation 4

new g_idx_player 
new g_idx_camera
new gl_iszAllocString_ModelZoom;

public OnPlayerKilled(filename[]) 
{
    if (equal(filename, "weapons/spring_shoot.wav"))
    {
        server_print("Игрок %s", filename)
        return HC_BREAK
    }
    else 
        return HC_CONTINUE
}


public plugin_precache()
{
    gl_iszAllocString_ModelZoom = engfunc(EngFunc_AllocString, "models/v_garand.mdl");
}
public plugin_init()
{   
    server_print("ReAPI Runs :::::: ")
    register_think("iron_sight", "iron_sight_think")
    register_clcmd("say ss", "set_Vmodel_")
    register_forward(FM_AddToFullPack, "OnAddToFullPack");
}

public set_Vmodel_(idx_player)
{
    server_print("ReAPI Runs :::::: ")
    
    // Устанавливаем FOV и модель оружия
    set_entvar(idx_player, var_fov, 70.0)
    set_entvar(idx_player, var_viewmodel, "models/v_garand.mdl")
    
    // Скрываем модель игрока
    // set_pev(idx_player, pev_effects, pev(idx_player, pev_effects) | EF_NODRAW)
    
    // Создаем камеру
    target_create(idx_player)
}

public target_create(idx_player)
{     
    new iOrigin_target[3]
    get_user_origin(idx_player, iOrigin_target, 1) // Получаем позицию игрока

    new Float:fOrigin[3]
    IVecFVec(iOrigin_target, fOrigin) // Конвертируем в float

    // Смещаем камеру на 34 единицы выше
    fOrigin[2] += 34.0

    // Создаем камеру
    new idx_target = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "trigger_camera"))
    server_print(" ENTITY CREATED AS ID idx_target %d", idx_target)
    
    set_pev(idx_target, pev_classname, "iron_sight")
    set_pev(idx_target, pev_solid, SOLID_NOT)
    set_pev(idx_target, pev_movetype, MOVETYPE_NONE)
    set_pev(idx_target, pev_owner, idx_player)
    set_pev(idx_target, pev_origin, fOrigin)
    
    // Привязываем модель оружия к камере
    engfunc(EngFunc_SetModel, idx_target, "models/v_garand.mdl")
    engfunc(EngFunc_SetModel, g_idx_camera, "models/v_garand.mdl")
    if (!pev_valid(idx_target)) 
    {
        return
    }

    // Привязываем камеру к игроку
    attach_view(idx_player, idx_target)

    g_idx_player = idx_player
    g_idx_camera = idx_target

    // Устанавливаем FOV и начинаем синхронизацию углов
    set_task(1.0, "retune_pl")
}

public retune_pl()
{
    // Устанавливаем FOV для игрока
    message_begin(MSG_ONE, get_user_msgid("SetFOV"), _, g_idx_player)
    write_byte(60)
    message_end()

    // Привязываем камеру к игроку
    entity_set_edict(g_idx_camera, EV_ENT_aiment, g_idx_player)
    set_pev(g_idx_camera, pev_nextthink, halflife_time() + 0.01)
}

public iron_sight_think()
{
    static Float:flAngles[3]
    static Float:flVAngles[3]

    // Получаем углы игрока
    pev(g_idx_player, pev_angles, flAngles)
    pev(g_idx_player, pev_v_angle, flVAngles)

    // Инвертируем угол по оси X (вверх/вниз)
    flAngles[0] *= -1.0
    //flAngles[1] *= -1.0
    //flAngles[2] *= -1.0

    flVAngles[0] *= -1.0
    flVAngles[1] *= -1.0
    flVAngles[2] *= -1.0

    // Синхронизируем углы камеры и модели оружия
    set_pev(g_idx_camera, pev_angles, flAngles)
    set_pev(g_idx_camera, pev_v_angle, flVAngles)
    
    engfunc(EngFunc_CrosshairAngle, g_idx_player, random_float(-1.0,1.0), random_float(-100.0,100.0))
    // Продолжаем обновление
    set_pev(g_idx_camera, pev_nextthink, halflife_time() + 0.01)


    set_pev(g_idx_camera, pev_viewmodel2, "models/v_garand.mdl");
	set_pev(g_idx_camera, pev_viewmodel, "models/v_garand.mdl");
    set_pev_string(g_idx_camera, pev_viewmodel2, gl_iszAllocString_ModelZoom);
    set_pev(g_idx_player, pev_viewmodel2, "models/v_garand.mdl");
	set_pev(g_idx_player, pev_viewmodel, "models/v_garand.mdl");
    set_pev_string(g_idx_player, pev_viewmodel2, gl_iszAllocString_ModelZoom);
    
}


public OnAddToFullPack(es_handle, e, ent, host, hostflags, player, pSet) {
    if (player) {
        set_es(es_handle, ES_RenderMode, kRenderNormal);  // Принудительно отображать модель
        set_es(es_handle, ES_RenderAmt, 255);  // Установить полную видимость
    }
}