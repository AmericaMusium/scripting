#include <amxmodx>
#include <dodx>
#include <engine>
#include <fakemeta>
#include <hamsandwich>

#define PLUGIN "DoD Bomb Mode"
#define VERSION "1.0"
#define AUTHOR "Your Name"

// Настройки
#define BOMB_TIME 45       // Время до взрыва (сек)
#define DEFUSE_TIME 5      // Время разминирования (сек)
#define BOMB_RADIUS 500    // Радиус поражения взрыва

// Переменные
new g_hasBomb[33], g_bombPlanted, g_bombTimer, g_defusing[33];
new g_bombSite[3], g_msgSayText, g_spriteExplode;
new g_BombEnt;

public plugin_init() {
    register_plugin(PLUGIN, VERSION, AUTHOR);
    
    // Регистрация команд
    register_clcmd("say /plant", "cmd_plant");
    register_clcmd("say /defuse", "cmd_defuse");
    
    // События
    register_event("DeathMsg", "event_death", "a");
    RegisterHam(Ham_Killed, "player", "event_death", 1);
    
    // Инициализация точек установки бомбы (настраивайте под карту)
    g_bombSite[0] = 100;  // X
    g_bombSite[1] = 200;  // Y
    g_bombSite[2] = 50;   // Z
    
    // Сообщения
    g_msgSayText = get_user_msgid("SayText");
}

public plugin_precache() {
    // Спрайт взрыва
    g_spriteExplode = precache_model("sprites/zerogxplode.spr");
}

public client_putinserver(id) {
    g_hasBomb[id] = 0;
    g_defusing[id] = 0;
}

public event_death() {
    new victim = read_data(2);
    if (g_hasBomb[victim]) {
        // Бомба выпадает при смерти
        drop_bomb(victim);
    }
}

public cmd_plant(id) {
    if (get_user_team(id) != ALLIES) {
        client_print(id, print_chat, "[Bomb] Только союзники могут установить бомбу!");
        return PLUGIN_HANDLED;
    }
    
    if (g_bombPlanted) {
        client_print(id, print_chat, "[Bomb] Бомба уже установлена!");
        return PLUGIN_HANDLED;
    }
    
    new Float:origin[3];
    pev(id, pev_origin, origin);
    
    /*
    // Проверка расстояния до точки установки
    if (vector_distance(origin, Float:g_bombSite) > 100.0) {
        client_print(id, print_chat, "[Bomb] Вы не в зоне установки!");
        return PLUGIN_HANDLED;
    }
    */
    
    // Установка бомбы
    g_bombPlanted = 1;
    g_hasBomb[id] = 0;
    
    // Таймер до взрыва
    g_bombTimer = BOMB_TIME;
    set_task(1.0, "update_timer", _, _, _, "a", BOMB_TIME);
    
    // Оповещение
    send_message(0, "Бомба установлена! Время до взрыва: %d сек", BOMB_TIME);
    return PLUGIN_HANDLED;
}

public cmd_defuse(id) {
    if (get_user_team(id) != AXIS) {
        client_print(id, print_chat, "[Bomb] Только Ось может разминировать бомбу!");
        return PLUGIN_HANDLED;
    }
    
    if (!g_bombPlanted) {
        client_print(id, print_chat, "[Bomb] Бомба не установлена!");
        return PLUGIN_HANDLED;
    }
    
    // Начало разминирования
    g_defusing[id] = 1;
    set_task(DEFUSE_TIME, "defuse_complete", id);
    client_print(id, print_chat, "[Bomb] Разминирование...");
    return PLUGIN_HANDLED;
}

public defuse_complete(id) {
    if (!g_defusing[id]) return;
    
    g_bombPlanted = 0;
    remove_task();
    send_message(0, "Бомба разминирована!");
    g_defusing[id] = 0;
}

public update_timer() {
    if (--g_bombTimer <= 0) {
        // Взрыв
        new Float:origin[3];
        origin[0] = g_bombSite[0];
        origin[1] = g_bombSite[1];
        origin[2] = g_bombSite[2];
        
        // Эффект взрыва
        message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
        write_byte(TE_EXPLOSION);
        write_coord(floatround(origin[0]));
        write_coord(floatround(origin[1]));
        write_coord(floatround(origin[2]));
        write_short(g_spriteExplode);
        write_byte(50); // scale
        write_byte(15); // framerate
        write_byte(0);  // flags
        message_end();
        
        // Урон игрокам
        new players[32], num;
        get_players(players, num, "a");
        for (new i = 0; i < num; i++) {
            if (entity_range(players[i], g_BombEnt) < BOMB_RADIUS) {
                user_kill(players[i]);
            }
        }
        
        send_message(0, "Бомба взорвалась! Победа союзников.");
        g_bombPlanted = 0;
    } else {
        send_message(0, "До взрыва осталось: %d сек", g_bombTimer);
    }
}

public drop_bomb(id) {
    new Float:origin[3];
    pev(id, pev_origin, origin);
    
    // Создание бомбы как объекта
    new ent = create_entity("info_target");
    set_pev(ent, pev_classname, "dod_bomb");
    set_pev(ent, pev_solid, SOLID_TRIGGER);
    set_pev(ent, pev_origin, origin);
    engfunc(EngFunc_SetModel, ent, "models/w_c4.mdl");
    g_BombEnt = ent;
    g_hasBomb[id] = 0;
}

stock send_message(id, const message[], any:...) {
    new msg[192];
    vformat(msg, charsmax(msg), message, 3);
    
    message_begin(id ? MSG_ONE : MSG_ALL, g_msgSayText, _, id);
    write_byte(id);
    write_string(msg);
    message_end();
}