#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <engine>
#include <dodx>
#include <dodfun>

#pragma semicolon 1

#define PLUGIN  "Airstrike on Killstreak"
#define VERSION "1.0"
#define AUTHOR  "Your Name"

#define MAX_KILLSTREAK 5
#define AIRSTRIKE_WEAPON "weapon_knife" // Выберете неиспользуемое оружие
#define AIRSTRIKE_MODEL "weapons/v_knife.mdl" // Модель для вызовной станции (можно заменить)
#define AIRSTRIKE_CHARGE_MODEL "sprites/laserbeam.spr" // Модель для отображения во время зарядки

new g_Killstreak[33];
new g_HasAirstrike[33];
new g_IsCharging[33];
new g_ChargeEntity[33];
new Float:g_ChargeOrigin[33][3];

public plugin_init() {
    register_plugin(PLUGIN, VERSION, AUTHOR);

    register_event(EV_HLDM_DEATH, "event_Death", "a", "1=userid", "2=attacker");
    register_event(EV_HLDM_KILL, "event_Kill", "a", "1=userid", "2=attacker");
    register_event(EV_HLDM_SPAWN, "event_Spawn", "a", "1=userid");

    register_clcmd("say /airstrike", "cmdAirstrikeInfo"); // Информационная команда
}

public plugin_precache() {
    precache_model(AIRSTRIKE_MODEL);
    precache_model(AIRSTRIKE_CHARGE_MODEL);
    precache_sound("weapons/mortarhit.wav"); // Звук взрыва
    precache_sound("weapons/rpg/rocketfire1.wav"); // Звук запуска ракеты
}

public cmdAirstrikeInfo(id) {
    client_print(id, print_chat, "[Airstrike] Убейте %d противников подряд, чтобы получить возможность вызвать авиаудар.", MAX_KILLSTREAK);
    return PLUGIN_HANDLED;
}

public event_Spawn(id) {
    g_Killstreak[id] = 0;
    g_HasAirstrike[id] = 0;
    g_IsCharging[id] = 0;
    g_ChargeEntity[id] = 0;
}

public event_Death(victim, attacker) {
    g_Killstreak[victim] = 0;
}

public event_Kill(victim, attacker) {
    if (attacker == victim)
        return;

    g_Killstreak[attacker]++;

    if (g_Killstreak[attacker] == MAX_KILLSTREAK && !g_HasAirstrike[attacker]) {
        g_HasAirstrike[attacker] = 1;
        client_print(attacker, print_center, "Вы достигли серии убийств %d! Возьмите вызовную станцию.", MAX_KILLSTREAK);
        give_airstrike_item(attacker);
    }
}

public give_airstrike_item(id) {
    give_item(id, AIRSTRIKE_WEAPON);
    fm_set_client_weapon_ammo(id, fm_get_weapon_index(AIRSTRIKE_WEAPON), 1);
    client_print(id, print_chat, "[Airstrike] Вам выдана вызовная станция. Нажмите R для зарядки, ЛКМ для вызова.");
}

public client_PreThink(id) {
    if (!is_user_alive(id) || !g_HasAirstrike[id])
        return;

    new weapon_index = get_user_weapon(id);
    new airstrike_weapon_index = fm_get_weapon_index(AIRSTRIKE_WEAPON);

    if (weapon_index == airstrike_weapon_index) {
        if (get_user_button(id) & IN_RELOAD && !g_IsCharging[id]) {
            g_IsCharging[id] = 1;
            entity_get_vector(id, EV_VEC_ORIGIN, g_ChargeOrigin[id]);

            g_ChargeEntity[id] = create_entity("env_sprite");
            if (pev_valid(g_ChargeEntity[id])) {
                dllfunc(DLLFunc_Think, g_ChargeEntity[id]); // Вызываем Think функцию для немедленного отображения
                entity_set_string(g_ChargeEntity[id], EV_SZ_MODEL, AIRSTRIKE_CHARGE_MODEL);
                entity_set_origin(g_ChargeEntity[id], g_ChargeOrigin[id]);
                entity_set_renderfx(g_ChargeEntity[id], kRenderFxGlowShell);
                entity_set_rendermode(g_ChargeEntity[id], kRenderTransAdd);
                entity_set_color(g_ChargeEntity[id], 255, 0, 0); // Красный цвет
                set_pev(g_ChargeEntity[id], pev_scale, 2.0);
                set_pev(g_ChargeEntity[id], pev_owner, entity_index(id)); // Делаем владельцем клиента
                set_pev(g_ChargeEntity[id], pev_movetype, MOVETYPE_NONE);
                set_pev(g_ChargeEntity[id], pev_solid, SOLID_NOT);
            }
        } else if (!(get_user_button(id) & IN_RELOAD) && g_IsCharging[id]) {
            g_IsCharging[id] = 0;
            if (pev_valid(g_ChargeEntity[id])) {
                remove_entity(g_ChargeEntity[id]);
                g_ChargeEntity[id] = 0;
            }
        }

        if (get_user_button(id) & IN_ATTACK && g_IsCharging[id]) {
            g_IsCharging[id] = 0;
            if (pev_valid(g_ChargeEntity[id])) {
                remove_entity(g_ChargeEntity[id]);
                g_ChargeEntity[id] = 0;
            }
            call_airstrike(id, g_ChargeOrigin[id]);
            remove_airstrike_item(id);
        }
    }
}

public remove_airstrike_item(id) {
    new airstrike_weapon_index = fm_get_weapon_index(AIRSTRIKE_WEAPON);
    if (get_user_weapon(id) == airstrike_weapon_index) {
        weapon_strip(id, AIRSTRIKE_WEAPON);
    } else {
        // Если по какой-то причине не в руках, просто удаляем из инвентаря
        user_get_weapon(id, airstrike_weapon_index);
        dllfunc(DLLFunc_Weapon_Drop, id);
    }
    g_HasAirstrike[id] = 0;
}

public call_airstrike(id, Float:origin[3]) {
    client_print(id, print_center, "Вы вызвали авиаудар!");
    emit_sound(id, CHAN_AUTO, "weapons/mortarhit.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);

    // Настраиваем параметры ракетной атаки
    new Float:start_point[3];
    new Float:target_point[3];
    new Float:angle[3];

    // Задаем точку начала атаки выше текущей позиции
    start_point[0] = origin[0];
    start_point[1] = origin[1];
    start_point[2] = origin[2] + 500.0;

    // Задаем цель немного впереди и ниже текущей позиции
    target_point[0] = origin[0] + random_float(-100.0, 100.0);
    target_point[1] = origin[1] + random_float(-100.0, 100.0);
    target_point[2] = origin[2];

    // Рассчитываем угол для ракеты
    vector_angles(Float:{target_point[0] - start_point[0], target_point[1] - start_point[1], target_point[2] - start_point[2]}, angle);

    // Запускаем несколько ракет
    new i;
    for (i = 0; i < 5; i++) {
        set_task(1.0 + float(i) * 0.2, "launch_rocket", id + 1000 + i, start_point, target_point);
    }
}

public launch_rocket(taskid) {
    new id = taskid - 1000;
    new Float:start_point[3], Float:target_point[3];
    task_args(start_point, 12); // 3 floats * 4 bytes
    task_args(target_point, 12, 12);

    new pRocket = create_entity("rpg_rocket");
    if (pev_valid(pRocket)) {
        emit_sound(pRocket, CHAN_WEAPON, "weapons/rpg/rocketfire1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
        entity_set_origin(pRocket, start_point);
        entity_set_vector(pRocket, EV_VEC_ANGLES, calculate_angle(start_point, target_point));
        set_pev(pRocket, pev_owner, 0); // Мир владеет ракетой
        set_pev(pRocket, pev_velocity, vector_mul_scalar(vector_forward(calculate_angle(start_point, target_point)), 1500.0));
        set_pev(pRocket, pev_gravity, 0.3);
        set_pev(pRocket, pev_nextthink, get_gametime() + 0.1);
        set_pev(pRocket, pev_think, "rocket_think");
        set_pev(pRocket, pev_dmg, 100.0); // Урон от ракеты
    }
}

public rocket_think(entity) {
    if (!pev_valid(entity))
        return;

    new Float:origin[3];
    entity_get_origin(entity, origin);

    new tr = create_tr2();
    fp_set_origin(tr, origin);
    fp_set_tr2_vector(tr, EV_VEC_VELOCITY, get_pev(entity, pev_velocity));
    trace_hull(origin, Float: { 0.0, 0.0, 0.0 }, Float: { 0.0, 0.0, 0.0 }, tr, 1, get_pdata_cbase(entity, 41)); // ignore owner

    if (fp_pointcontents(tr) & MASK_SOLID || fp_fraction(tr) < 1.0) {
        // Ракета столкнулась
        new Float:hit_origin[3];
        get_tr2_endpos(hit_origin, tr);
        radius_damage(hit_origin, 150.0, 200.0, "world"); // Взрыв
        engfunc(EngFunc_EmitSound, -1, gpvsul_nullent, CHAN_WEAPON, "weapons/mortarhit.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
        remove_entity(entity);
        free_tr2(tr);
        return;
    }

    free_tr2(tr);
    set_pev(entity, pev_nextthink, get_gametime() + 0.1);
}

stock Float:vector_distance(Float:v1[3], Float:v2[3]) {
    new Float:dx = v1[0] - v2[0];
    new Float:dy = v1[1] - v2[1];
    new Float:dz = v1[2] - v2[2];
    return floatsqroot(dx * dx + dy * dy + dz * dz);
}

stock Float:calculate_distance(Float:origin1[3], Float:origin2[3]) {
        new Float:FloatDist;
        FloatDist = floatsqroot(
                (origin1[0] - origin2[0]) * (origin1[0] - origin2[0]) +
                (origin1[1] - origin2[1]) * (origin1[1] - origin2[1]) +
                (origin1[2] - origin2[2]) * (origin1[2] - origin2[2])
        );
        return FloatDist;
}

stock Float:calculate_angle(Float:start[3], Float:end[3]) {
    new Float:angles[3];
    vector_angles(Float:{end[0] - start[0], end[1] - start[1], end[2] - start[2]}, angles);
    return angles;
}

stock Float:vector_mul_scalar(Float:vec[3], Float:scalar) {
    return Float:{vec[0] * scalar, vec[1] * scalar, vec[2] * scalar};
}

stock Float:vector_forward(Float:angles[3]) {
    new Float:forward[3];
    angle_vector(angles, forward);
    return forward;
}