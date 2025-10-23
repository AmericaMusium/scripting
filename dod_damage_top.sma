#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>
#include <dodx>
#include <engine>

new g_iDamageDealt[33]; // Массив для урона, нанесенного игроками. 33 - макс. кол-во игроков включая ботов
new g_iDamageTaken[33]; // Массив для урона, полученного игроками

public plugin_init()
{
    register_plugin("Damage Tracker", "1.0", "YourName")
    
    // Регистрация команды для просмотра топа
    register_clcmd("say /topdamage", "cmdTopDamage")
    
    // Хуки для отслеживания урона
    RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage_Post", 1)
    
    // Хук начала раунда для сброса статистики
    register_event("RoundState", "event_new_round", "a", "1=1")
}

public event_new_round()
{
    // Очистка массивов в начале каждого раунда
    for(new i = 1; i <= 32; i++)
    {
        g_iDamageDealt[i] = 0
        g_iDamageTaken[i] = 0
    }
}

public fw_TakeDamage_Post(victim, inflictor, attacker, Float:damage, damagebits)
{
    if(is_user_connected(attacker) && attacker != victim)
    {
        g_iDamageDealt[attacker] += floatround(damage)
    }
    
    if(is_user_connected(victim))
    {
        g_iDamageTaken[victim] += floatround(damage)
    }
}

public cmdTopDamage(id)
{
    new players[32], pnum
    get_players(players, pnum, "ch") // Получаем список живых игроков
    
    // Сортировка игроков по урону (простой метод, для примера)
    for(new i = 0; i < pnum; i++)
    {
        for(new j = i + 1; j < pnum; j++)
        {
            if(g_iDamageDealt[players[i]] < g_iDamageDealt[players[j]])
            {
                new temp = players[i]
                players[i] = players[j]
                players[j] = temp
            }
        }
    }
    
    // Вывод топа
    client_print(id, print_chat, "Топ игроков по нанесенному урону:")
    for(new i = 0; i < pnum && i < 10; i++) // Показываем только топ 10
    {
        new name[32]
        get_user_name(players[i], name, 31)
        client_print(id, print_chat, "%d. %s - %d урона", i + 1, name, g_iDamageDealt[players[i]])
        server_print("%d. %s - %d урона", i + 1, name, g_iDamageDealt[players[i]])
    }
    
    return PLUGIN_HANDLED
}

public client_disconnected(id)
{
    // Обнуляем статистику при выходе игрока
    g_iDamageDealt[id] = 0
    g_iDamageTaken[id] = 0
}