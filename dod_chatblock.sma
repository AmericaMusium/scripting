#include <amxmodx>

public plugin_init() {
    register_plugin("Hide Chat", "1.0", "Your Name");

    // Перехватываем все сообщения, которые могут быть отправлены в чат
    register_message(get_user_msgid("SayText"), "block_message"); // Сообщения от игроков
    register_message(get_user_msgid("TextMsg"), "block_message"); // Системные сообщения
    register_message(get_user_msgid("HudText"), "block_message"); // HUD-сообщения
    register_message(get_user_msgid("HudTextArgs"), "block_message"); // HUD-сообщения с аргументами
}

public block_message(msg_id, msg_dest, msg_entity) {
    // Блокируем все сообщения
    return PLUGIN_HANDLED;
}