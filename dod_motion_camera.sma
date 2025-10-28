#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <fakemeta_util>

#define MAX_KEY_FRAMES 1000
#define TASK_RECORD 1001
#define TASK_PLAY 1002

// Отдельные массивы
new Float:g_track_origin[MAX_KEY_FRAMES][3];
new Float:g_track_angles[MAX_KEY_FRAMES][3];
new g_frame_count = 0;
new g_is_recording = 0;
new g_is_playing = 0;
new g_playback_index = 0;
new g_spectator_id = 0;
new g_camera_ent = 0;
new Float:g_record_interval = 0.1; // Уменьшил интервал для плавности

new Float:g_current_origin[3];
new Float:g_current_angles[3];
new Float:g_target_origin[3];
new Float:g_target_angles[3];
new Float:g_velocity[3];
new Float:g_avelocity[3];
new Float:g_time_to_next = 0.1; // Время между кадрами
new g_last_playback_index = -1; // Изменил на -1

public plugin_init()
{
    register_plugin("Camera Tracker", "1.0", "Your Name");
    register_clcmd("say /rec", "cmd_record");
    register_clcmd("say /stop", "cmd_stop");
    register_clcmd("say /play", "cmd_play");
    
    // Важно: регистрируем мыслитель для плавного движения
    register_think("camera_tracker", "camera_think");
}

public cmd_record(id)
{
    if (g_is_recording)
    {
        client_print(id, print_chat, "[CAM] Already recording!");
        return PLUGIN_HANDLED;
    }

    if (g_is_playing)
    {
        client_print(id, print_chat, "[CAM] Stop playback first!");
        return PLUGIN_HANDLED;
    }

    g_frame_count = 0;
    g_is_recording = 1;
    g_spectator_id = id;

    // Записываем первый кадр сразу
    record_frame();
    
    set_task(g_record_interval, "record_frame", TASK_RECORD, _, _, "b");

    client_print(id, print_chat, "[CAM] Recording started...");

    return PLUGIN_HANDLED;
}

public record_frame()
{
    if (!g_is_recording || !is_user_connected(g_spectator_id))
    {
        stop_recording();
        return;
    }

    if (g_frame_count >= MAX_KEY_FRAMES)
    {
        client_print(g_spectator_id, print_chat, "[CAM] Max frames reached.");
        stop_recording();
        return;
    }

    // Получаем origin и angles камеры
    new Float:origin[3], Float:angles[3];
    pev(g_spectator_id, pev_origin, origin);
    pev(g_spectator_id, pev_v_angle, angles); // Углы камеры

    // Сохраняем в массивы
    g_track_origin[g_frame_count] = origin;
    g_track_angles[g_frame_count] = angles;

    g_frame_count++;
    
    // Показываем прогресс каждые 50 кадров
    if (g_frame_count % 50 == 0)
    {
        client_print(g_spectator_id, print_chat, "[CAM] Recorded %d frames", g_frame_count);
    }
}

public cmd_stop(id)
{
    if (!g_is_recording && !g_is_playing)
    {
        client_print(id, print_chat, "[CAM] Not recording or playing.");
        return PLUGIN_HANDLED;
    }

    if (g_is_recording)
    {
        stop_recording();
        client_print(id, print_chat, "[CAM] Recording stopped. Frames: %d", g_frame_count);
    }
    
    if (g_is_playing)
    {
        stop_playback();
        client_print(id, print_chat, "[CAM] Playback stopped.");
    }

    return PLUGIN_HANDLED;
}

public cmd_play(id)
{
    if (g_frame_count <= 1) // Нужно минимум 2 кадра
    {
        client_print(id, print_chat, "[CAM] Not enough frames to play.");
        return PLUGIN_HANDLED;
    }

    if (g_is_playing)
    {
        client_print(id, print_chat, "[CAM] Already playing.");
        return PLUGIN_HANDLED;
    }
    
    if (g_is_recording)
    {
        client_print(id, print_chat, "[CAM] Stop recording first!");
        return PLUGIN_HANDLED;
    }

    // Создаём entity для камеры
    g_camera_ent = create_entity("info_target");
    if (!pev_valid(g_camera_ent))
    {
        client_print(id, print_chat, "[CAM] Failed to create camera entity.");
        return PLUGIN_HANDLED;
    }

    set_pev(g_camera_ent, pev_classname, "camera_tracker");
    set_pev(g_camera_ent, pev_solid, SOLID_NOT);
    set_pev(g_camera_ent, pev_movetype, MOVETYPE_FLY); // Изменил на FLY для лучшего контроля
    
    // Устанавливаем начальную позицию
    set_pev(g_camera_ent, pev_origin, g_track_origin[0]);
    set_pev(g_camera_ent, pev_angles, g_track_angles[0]);
    set_pev(g_camera_ent, pev_v_angle, g_track_angles[0]); // Важно для углов обзора

    // Устанавливаем вид игроку
    fm_attach_view(id, g_camera_ent);

    g_playback_index = 0;
    g_last_playback_index = -1;
    g_is_playing = 1;

    // Запускаем мыслитель для плавного движения
    set_pev(g_camera_ent, pev_nextthink, get_gametime() + 0.01);

    client_print(id, print_chat, "[CAM] Playback started... Total frames: %d", g_frame_count);

    return PLUGIN_HANDLED;
}

public camera_think(ent)
{
    if (!g_is_playing || ent != g_camera_ent)
        return;
    
    if (g_playback_index >= g_frame_count - 1)
    {
        client_print(0, print_chat, "[CAM] Playback finished.");
        stop_playback();
        return;
    }

    // Если перешли на следующий кадр - пересчитываем векторы
    if (g_playback_index != g_last_playback_index)
    {
        g_last_playback_index = g_playback_index;

        // Текущая позиция камеры
        pev(g_camera_ent, pev_origin, g_current_origin);
        pev(g_camera_ent, pev_angles, g_current_angles);

        // Следующая целевая точка
        g_target_origin = g_track_origin[g_playback_index + 1];
        g_target_angles = g_track_angles[g_playback_index + 1];

        // Рассчитываем скорость для достижения цели за g_time_to_next секунд
        g_velocity[0] = (g_target_origin[0] - g_current_origin[0]) / g_time_to_next;
        g_velocity[1] = (g_target_origin[1] - g_current_origin[1]) / g_time_to_next;
        g_velocity[2] = (g_target_origin[2] - g_current_origin[2]) / g_time_to_next;

        // Рассчитываем угловую скорость
        g_avelocity[0] = (g_target_angles[0] - g_current_angles[0]) / g_time_to_next;
        g_avelocity[1] = (g_target_angles[1] - g_current_angles[1]) / g_time_to_next;
        g_avelocity[2] = (g_target_angles[2] - g_current_angles[2]) / g_time_to_next;
    }

    // Применяем движение
    new Float:new_origin[3], Float:new_angles[3];
    pev(g_camera_ent, pev_origin, new_origin);
    pev(g_camera_ent, pev_angles, new_angles);
    
    // Двигаем к цели
    new_origin[0] += g_velocity[0] * 0.01;
    new_origin[1] += g_velocity[1] * 0.01;
    new_origin[2] += g_velocity[2] * 0.01;
    
    new_angles[0] += g_avelocity[0] * 0.01;
    new_angles[1] += g_avelocity[1] * 0.01;
    new_angles[2] += g_avelocity[2] * 0.01;
    
    set_pev(g_camera_ent, pev_origin, new_origin);
    set_pev(g_camera_ent, pev_angles, new_angles);
    set_pev(g_camera_ent, pev_v_angle, new_angles);

    // Проверяем достижение целевой точки
    new Float:distance = vector_distance(new_origin, g_target_origin);
    if (distance < 5.0) // Если близко к цели
    {
        g_playback_index++;
        
        // Если есть следующий кадр - обновляем цель
        if (g_playback_index < g_frame_count - 1)
        {
            g_target_origin = g_track_origin[g_playback_index + 1];
            g_target_angles = g_track_angles[g_playback_index + 1];
        }
    }

    // Продолжаем думать
    set_pev(g_camera_ent, pev_nextthink, get_gametime() + 0.01);
}

// Вспомогательные функции
stock stop_recording()
{
    g_is_recording = 0;
    remove_task(TASK_RECORD);
}

stock stop_playback()
{
    g_is_playing = 0;
    g_playback_index = 0;
    g_last_playback_index = -1;
    
    if (pev_valid(g_camera_ent))
    {
        // Возвращаем вид игроку
        if (is_user_connected(g_spectator_id))
        {
            fm_attach_view(g_spectator_id, g_camera_ent);
            // fm_set_user_viewpoint(g_spectator_id, g_spectator_id);
        }
        remove_entity(g_camera_ent);
        g_camera_ent = 0;
    }
}


public client_disconnect(id)
{
    if (id == g_spectator_id)
    {
        if (g_is_recording)
            stop_recording();
            
        if (g_is_playing)
            stop_playback();
            
        g_spectator_id = 0;
    }
}