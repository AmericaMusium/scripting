#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>
#include <dodx>
#include <hamsandwich>

#define PLUGIN "DoD Bomb/Flag Hybrid"
#define VERSION "1.0"
#define AUTHOR "Your Name"

// Настройки
#define BOMB_TIME 45       // Время до "взрыва" (захвата)
#define DEFUSE_TIME 5      // Время разминирования
#define TARGET_FLAG "central_flag" // Имя целевого флага
#define FLAG_CLASSNAME "dod_control_point"

// Переменные
new g_bombPlanted, g_bombTimer;
new g_defusing[33], g_bombEnt;
new g_msgSayText, g_originalOwner;

public plugin_init() 
{
    register_plugin(PLUGIN, VERSION, AUTHOR);
    
    // Регистрация команд
    register_clcmd("say /plant", "cmd_plant");
    register_clcmd("say /defuse", "cmd_defuse");
    
    // События
    register_event("DeathMsg", "event_death", "a");
    RegisterHam(Ham_Killed, "player", "event_death", 1);
    
    // Сообщения
    g_msgSayText = get_user_msgid("SayText");
    
    // Инициализация флагов
    set_task(1.0, "find_target_flag");
}

public find_target_flag()
{
    new ent = -1;
    while((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", FLAG_CLASSNAME)) != 0)
    {
        static targetname[32];
        pev(ent, pev_targetname, targetname, charsmax(targetname));
        
        if(equal(targetname, TARGET_FLAG))
        {
            g_bombEnt = ent;
            g_originalOwner = pev(ent, pev_team); // Сохраняем исходного владельца
            reset_flag_properties();
            break;
        }
    }
}

public reset_flag_properties()
{
    if(!pev_valid(g_bombEnt)) return;
    
    // Сброс иконок и свойств флага
    set_pev(g_bombEnt, pev_team, 0); // Нейтральный статус
    set_pev(g_bombEnt, pev_iuser3, 201); // Специальная иконка
    set_pev(g_bombEnt, pev_iuser4, 201);
    set_pev(g_bombEnt, pev_iuser2, 201);
}

public cmd_plant(id) 
{
    if(get_user_team(id) != ALLIES)
    {
        client_print(id, print_chat, "[Bomb] Только союзники могут захватывать флаг!");
        return PLUGIN_HANDLED;
    }
    
    if(g_bombPlanted)
    {
        client_print(id, print_chat, "[Bomb] Флаг уже захвачен!");
        return PLUGIN_HANDLED;
    }
    
    if(!is_user_near_flag(id))
    {
        client_print(id, print_chat, "[Bomb] Вы не у целевого флага!");
        return PLUGIN_HANDLED;
    }
    
    // Начало захвата
    g_bombPlanted = 1;
    g_bombTimer = BOMB_TIME;
    set_task(1.0, "update_timer", _, _, _, "a", BOMB_TIME);
    
    // Визуальные изменения
    set_pev(g_bombEnt, pev_team, ALLIES);
    send_message(0, "Захват флага начат! Время до победы: %d сек", BOMB_TIME);
    return PLUGIN_HANDLED;
}

public cmd_defuse(id) 
{
    if(get_user_team(id) != AXIS)
    {
        client_print(id, print_chat, "[Bomb] Только Ось может защищать флаг!");
        return PLUGIN_HANDLED;
    }
    
    if(!g_bombPlanted)
    {
        client_print(id, print_chat, "[Bomb] Флаг не захвачен!");
        return PLUGIN_HANDLED;
    }
    
    if(!is_user_near_flag(id))
    {
        client_print(id, print_chat, "[Bomb] Вы не у целевого флага!");
        return PLUGIN_HANDLED;
    }
    
    // Начало разминирования
    g_defusing[id] = 1;
    set_task(DEFUSE_TIME, "defuse_complete", id);
    client_print(id, print_chat, "[Bomb] Защита флага...");
    return PLUGIN_HANDLED;
}

public defuse_complete(id) 
{
    if(!g_defusing[id]) return;
    
    g_bombPlanted = 0;
    remove_task();
    reset_flag_properties();
    send_message(0, "Захват флага предотвращен!");
    g_defusing[id] = 0;
}

public update_timer() 
{
    if(--g_bombTimer <= 0)
    {
        // Победа союзников
        send_message(0, "Флаг захвачен! Победа союзников.");
        trigger_victory(ALLIES);
        reset_game();
    }
    else
    {
        send_message(0, "До захвата флага: %d сек", g_bombTimer);
    }
}

public event_death() 
{
    new victim = read_data(2);
    if(g_defusing[victim])
    {
        g_defusing[victim] = 0;
        send_message(victim, "Защита флага прервана!");
    }
}

stock is_user_near_flag(id)
{
    if(!pev_valid(g_bombEnt)) return 0;
    
    static Float:flOrigin[3], Float:flFlagOrigin[3];
    pev(id, pev_origin, flOrigin);
    pev(g_bombEnt, pev_origin, flFlagOrigin);
    
    return vector_distance(flOrigin, flFlagOrigin) < 100.0;
}

stock trigger_victory(team)
{
    // Логика завершения раунда
    new players[32], num;
    get_players(players, num);
    
    for(new i = 0; i < num; i++)
    {
        if(get_user_team(players[i]) == team)
        {   
            send_message(0, "ЭТО победа ");
            // dod_set_winner(players[i], 1);
        }
    }
}

stock reset_game()
{
    g_bombPlanted = 0;
    remove_task();
    set_task(5.0, "find_target_flag");
}

stock send_message(id, const message[], any:...)
{
    new msg[192];
    vformat(msg, charsmax(msg), message, 3);
    
    message_begin(id ? MSG_ONE : MSG_ALL, g_msgSayText, _, id);
    write_byte(id);
    write_string(msg);
    message_end();
}