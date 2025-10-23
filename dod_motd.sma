#include <amxmodx>
#include <engine>

public plugin_init() {
    register_plugin("Dynamic MOTD", "1.0", "YourName")
    
    // Регистрируем команду для обновления MOTD
    register_clcmd("say /motd", "cmdShowMOTD")
}

public cmdShowMOTD(id) {
    // Создаем MOTD окно
    show_motd(id, "<html><body><h1>Welcome to Our Server</h1><p>This is a custom MOTD for Day of Defeat.</p></body></html>", "Welcome")
    return PLUGIN_HANDLED
}

// Если вы хотите изменять MOTD для всех игроков при их подключении:
public client_putinserver(id) {
    // Задержка, чтобы убедиться, что клиент полностью подключился
    set_task(2.0, "showWelcomeMOTD", id)
}

public showWelcomeMOTD(id) {
    if(is_user_connected(id)) {
        show_motd(id, "<html><body><h1>Welcome!</h1><p>Enjoy your game on our server!</p></body></html>", "Server Welcome")
    }
}