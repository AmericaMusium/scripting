#include <amxmodx>
#include <dodx>
#include <fakemeta>
#include <hamsandwich>
#include <engine>

new g_EntScope; // переменная для хранения индекса entity нашего прицела

public plugin_init() 
{
    register_plugin("DOD SNIPER LEARNING", "0.0", "America")

    register_clcmd("say 1", "cmd_ScopeZoom");
    // ... другие регистрации
}

public plugin_precache()
{
    precache_model("models/v_garand_scope.mdl"); // предкэш модели с прицелом
}

public cmd_ScopeZoom(id)
{
    if (!is_user_alive(id))
        return PLUGIN_HANDLED;

    // Создание entity для прицела
    if (!g_EntScope)
    {
        g_EntScope = create_entity("info_target");
        if (pev_valid(g_EntScope))
        {
            set_pev(g_EntScope, pev_classname, "scope_entity");
            set_pev(g_EntScope, pev_owner, id);
            set_pev(g_EntScope, pev_solid, SOLID_NOT);
            set_pev(g_EntScope, pev_movetype, MOVETYPE_FOLLOW);
            set_pev(g_EntScope, pev_model, "models/v_garand_scope.mdl");
            set_pev(g_EntScope, pev_sequence, 0);
            set_pev(g_EntScope, pev_frame, 0.0);
            set_pev(g_EntScope, pev_framerate, 1.0);
            set_pev(g_EntScope, pev_nextthink, get_gametime() + 0.1);
            dllfunc(DLLFunc_Think, g_EntScope);
        }
    }

    // Показываем entity только текущему игроку
    fm_set_rendering(g_EntScope, kRenderNormal, 255, 255, 255, kRenderFxNone, 255);

    // Изменяем FOV
    change_FOV(id, 89); // установите желаемый угол обзора

    return PLUGIN_HANDLED;
}

public change_FOV(id, fov)
{
    // Использовать MSG_ONE, чтобы не затрагивать других игроков
    message_begin(MSG_ONE, get_user_msgid("SetFOV"), _, id);
    write_byte(fov);
    message_end();
}



public fm_set_rendering(ent, rendermode, renderamt, red, green, blue, renderfx, renderfxamt)
{
    static Float:color[3];
    color[0] = red;
    color[1] = green;
    color[2] = blue;

    engfunc(EngFunc_SetRenderColor, ent, red, green, blue);
    engfunc(EngFunc_SetRenderMode, ent, rendermode);
    engfunc(EngFunc_SetRenderAmt, ent, renderamt);
    engfunc(EngFunc_SetRenderFX, ent, renderfx);
    engfunc(EngFunc_SetRenderFXAmt, ent, renderfxamt);
}

// Не забудьте добавить код для think-функции entity, который следит за владельцем и обновляет позицию