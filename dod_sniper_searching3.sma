
#include <amxmodx>
#include <fakemeta>

new g_msgSetFOV;
new g_msgHideWeapon;

public plugin_init() {
    register_plugin("Fix FOV Viewmodel", "1.0", "You");
    g_msgSetFOV = get_user_msgid("SetFOV");
    g_msgHideWeapon = get_user_msgid("HideWeapon");
    register_forward(FM_PlayerPreThink, "OnPlayerPreThink");
}

public OnPlayerPreThink(id) {
    if (!is_user_alive(id)) {
        return;
    }

    new Float:fov;
    pev(id, pev_fov, fov);

    // Если FOV меньше 90, принудительно устанавливаем его на 90

    

    // Отправляем сообщение SetFOV
    message_begin(MSG_ONE, g_msgSetFOV, {0, 0, 0}, id);
    write_byte(70);
    message_end();

    // Отправляем сообщение HideWeapon с параметром 0 для отображения модели оружия
    message_begin(MSG_ONE, g_msgHideWeapon, {0, 0, 0}, id);
    write_byte(0);
    message_end();

    set_pev(id, pev_fov, 70.0);
}