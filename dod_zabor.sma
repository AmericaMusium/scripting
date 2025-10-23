//---------------------------------------------------------
// Пример плагина AMX Mod X для Day of Defeat.
// Простая демонстрация создания "деревянного забора".
//---------------------------------------------------------
#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <fakemeta_util>
#include <fakemeta_stocks>
#include <dodx>
#include <dodfun>
#include <fun>
#include <engine>

#define MODEL_FENCE "models/mapmodels/jed_kubelwagen_camo.mdl" // Путь к модели забора
#define FENCE_WIDTH 80.0               // ~2 метра в игровых юнитах (примерно 80 дюймов)
#define FENCE_HALF_WIDTH (FENCE_WIDTH / 2.0)
#define FENCE_THICKNESS 8.0            // Толщина забора
#define FENCE_HEIGHT 72.0              // Высота (чуть выше стандартного прыжка)

// Регистрация плагина
public plugin_init()
{
    register_plugin("DoD Fence Example", "1.0", "YourName");

    // Регистрируем консольную команду (или чат-команду) для теста
    register_clcmd("say bb", "cmd_build_fence");
}

// Прекачиваем модель, если есть
public plugin_precache()
{
    precache_model(MODEL_FENCE);
}

//---------------------------------------------------------
// Команда, которую можно вызвать из консоли: build_fence
// Для упрощения пример строит забор прямо перед игроком
//---------------------------------------------------------
public cmd_build_fence(id)
{
    if (!is_user_alive(id))
    {
        client_print(id, print_center, "Вы должны быть живы, чтобы строить забор!");
        return PLUGIN_HANDLED;
    }

    // Получаем позицию игрока и направление взгляда
    new Float:origin[3], Float:angles[3], Float:fforward[3];

    pev(id, pev_origin, origin);
    pev(id, pev_v_angle, angles);

    // Конвертируем углы во вектор направления
    angle_vector(angles, ANGLEVECTOR_FORWARD, fforward);

    // Делаем небольшое смещение вперёд (например, 100 юнитов), чтобы забор не появлялся "внутри" игрока
    origin[0] += fforward[0] * 100.0;
    origin[1] += fforward[1] * 100.0;
    origin[2] += fforward[2] * 100.0;

    // Создаём забор
    new ent = create_fence(origin, angles);

    client_print(id, print_center, "Вы построили простой забор!");

    return PLUGIN_HANDLED;
}

//---------------------------------------------------------
// Функция create_fence: Создаёт и настраивает энтити забора
//---------------------------------------------------------
public create_fence(const Float:pos[3], const Float:ang[3])
{
    // Создаём энтити типа func_wall (либо info_target — зависит от вашей логики)
    new iEnt = create_entity("func_breakable"); // Изменено на func_breakable

    if (!iEnt)
        return 0;

    // Устанавливаем класс-имя для удобства отладки
    entity_set_string(iEnt, EV_SZ_classname, "dod_fence_example");

    // Делаем его солидным
    entity_set_int(iEnt, EV_INT_solid, SOLID_BSP);

    // Указываем модель (должна быть заранее подготовлена)
    entity_set_model(iEnt, MODEL_FENCE);

    // Устанавливаем размеры коллизии (bounding box).
    // В этом примере "толщина" забора = FENCE_THICKNESS,
    // ширина ~2 метра (FENCE_WIDTH ≈ 80 юнитов), высота 72 юнита.
    new Float:mins[3], Float:maxs[3];
    // Половина ширины влево и вправо
    mins[0] = -FENCE_HALF_WIDTH;
    maxs[0] =  FENCE_HALF_WIDTH;
    // Толщина (это "глубина" забора)
    mins[1] = -FENCE_THICKNESS;
    maxs[1] =  FENCE_THICKNESS;
    // Высота от пола (допустим, от 0 до 72)
    mins[2] = 0.0;
    maxs[2] = FENCE_HEIGHT;

    entity_set_size(iEnt, mins, maxs);

    // Устанавливаем позицию (origin) и углы (angles)
    entity_set_origin(iEnt, pos);
    entity_set_vector(iEnt, EV_VEC_angles, ang);

    // На всякий случай укажем отсутствие движения
    entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_PUSH); // Использовать MOVETYPE_PUSH или MOVETYPE_NONE
    entity_set_int(iEnt, EV_INT_flags, FL_WORLDBRUSH);  // Важно для коллизии
    entity_set_float(iEnt, EV_FL_health, 99999.0);     // Сделаем неразрушаемым
    entity_set_int(iEnt, EV_INT_rendermode, kRenderNormal); // Сделать видимым
    // entity_set_int(iEnt, EV_INT_renderamt, 255);     // Полная видимость

    // Активируем энтити
    DispatchSpawn(iEnt);
    entity_set_int(iEnt, EV_INT_effects, entity_get_int(iEnt, EV_INT_effects) & ~EF_NODRAW);

    return iEnt;
}