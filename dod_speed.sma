#include <amxmodx>
#include <engine>
#include <fakemeta>

new const PLUGIN_NAME[] = "Speed Monitor";
new const PLUGIN_VERSION[] = "1.0";
new const PLUGIN_AUTHOR[] = "Your Name";

public plugin_init() {
    register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
    register_forward(FM_PlayerPreThink, "fw_PlayerPreThink");
}

public fw_PlayerPreThink(id) {
    if (!is_user_alive(id))
        return FMRES_IGNORED;
    
    // Получаем текущую скорость игрока
    new Float:velocity[3];
    get_user_velocity(id, velocity);
    
    // Вычисляем общую скорость (длину вектора скорости)
    new Float:speed = vector_length(velocity);
    
    
    // Выводим информацию в чат
    set_hudmessage(255, 255, 255, -1.0, 0.65, 0, 6.0, 0.001, 0.1, 0.1, -1);
    show_hudmessage(id, "Скорость: %.0f u/s", speed);
    
    return FMRES_IGNORED;
}

