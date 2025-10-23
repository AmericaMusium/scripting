#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>

#define MAX_PLAYERS 32
#define FADE_DURATION 2.0 // Базовое время затемнения
#define MAX_DARKNESS 255 // Максимальная альфа (непрозрачность)
#define TIME_THRESHOLD 4.0 // Временной порог для усиления эффекта

new Float:g_lastDamageTime[MAX_PLAYERS + 1];
new g_msgScreenFade;

public plugin_init() {
    register_plugin("Dynamic Damage Fade", "1.0", "Your Name");
    
    // Регистрируем сообщение ScreenFade
    g_msgScreenFade = get_user_msgid("ScreenFade");
    
    // Хук на получение урона
    RegisterHam(Ham_TakeDamage, "player", "OnPlayerTakeDamage");
}

public OnPlayerTakeDamage(victim, inflictor, attacker, Float:damage, damagebits) {
    if (!is_user_connected(victim))
        return HAM_IGNORED;
    
    new Float:currentTime = get_gametime();
    new Float:timeSinceLastDamage = currentTime - g_lastDamageTime[victim];
    
    // Сохраняем время последнего урона
    g_lastDamageTime[victim] = currentTime;
    
    // Вызываем эффект затемнения
    CreateDamageFade(victim, timeSinceLastDamage, damage);
    
    return HAM_IGNORED;
}

CreateDamageFade(id, Float:timeSinceLastDamage, Float:damage) {
    // Рассчитываем интенсивность эффекта (0.0 - 1.0)
    new Float:intensity;
    
    if (timeSinceLastDamage < TIME_THRESHOLD) {
        // Чем меньше времени прошло, тем сильнее эффект
        intensity = 1.0 - (timeSinceLastDamage / TIME_THRESHOLD);
    } else {
        intensity = 0.3; // Базовый эффект для первого урона
    }
    
    // Усиливаем эффект в зависимости от полученного урона
    intensity += floatmin(damage / 100.0, 0.7); // Не больше 70% от урона
    
    // Ограничиваем диапазон
    intensity = floatclamp(intensity, 0.3, 1.0);
    
    // Рассчитываем цветовые компоненты
    new red = floatround(200.0 * intensity); // Красный компонент
    new green = floatround(100.0 * (1.0 - intensity)); // Желтый уходит со временем
    new blue = 0;
    new alpha = floatround(MAX_DARKNESS * intensity); // Непрозрачность
    
    // Продолжительность эффекта зависит от интенсивности
    new Float:fadeDuration = FADE_DURATION * (0.5 + intensity * 1.5);
    
    // Создаем сообщение ScreenFade
    message_begin(MSG_ONE, g_msgScreenFade, {0,0,0}, id);
    write_short(floatround(fadeDuration * 4096.0)); // Длительность
    write_short(floatround(fadeDuration * 1.5 * 4096.0)); // Время удержания
    write_short(1<<12); // Тип эффекта (FADE_IN)
    write_byte(red);    // R
    write_byte(green);  // G
    write_byte(blue);   // B
    write_byte(alpha);  // Альфа (непрозрачность)
    message_end();
    
    // Дополнительный эффект (если урон был совсем недавно)
    if (timeSinceLastDamage < 1.0) {
        set_task(0.1, "AdditionalShakeEffect", id);
    }
}

public AdditionalShakeEffect(id) {
    if (!is_user_connected(id)) 
        return;
    
    // Создаем эффект тряски экрана
    message_begin(MSG_ONE, get_user_msgid("ScreenShake"), {0,0,0}, id);
    write_short(floatround(255.0 * 4.0)); // Амплитуда
    write_short(floatround(255.0 * 2.0)); // Длительность
    write_short(floatround(255.0 * 10.0)); // Частота
    message_end();
}

public client_disconnected(id) {
    // Сбрасываем таймер при отключении игрока
    g_lastDamageTime[id] = 0.0;
}
/*
stock Float:floatclamp(Float:value, Float:min, Float:max) {
    return floatmin(floatmax(value, min), max);
}
*/