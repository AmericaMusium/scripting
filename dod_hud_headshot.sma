#include <amxmodx>
#include <hamsandwich>

#define TASK_Death 1500

new g_msgDeathMsg, gmsgVGUIMenu, gmsgPTeam, gmsgText, g_msgSayText;

new TrueName[33][32];
new DeathData[33][3]; // [killer, victim, weapon]

public plugin_init()
{
    register_plugin("HUD HeadShot", "1.0", "ACF Deluxe");
    register_message(gmsgVGUIMenu,"block_menu");

    g_msgDeathMsg = get_user_msgid("DeathMsg");
    set_msg_block(g_msgDeathMsg, BLOCK_SET);
}

public client_putinserver(idx_player)
{
    get_user_name(idx_player, TrueName[idx_player], 31);
}

public client_disconnected(id)
{
    // Удаляем задачу если игрок отключился
    if(task_exists(TASK_Death + id))
    {
        remove_task(TASK_Death + id);
    }
}


public client_death(idx_killer, idx_victim, id_weapon, hitplace, TK)
{   
    if(hitplace == HIT_HEAD && idx_killer)
    {
        // Меняем никнейм убийцы сразу
        client_cmd(idx_killer, "name ^"%s[°_°]^"", TrueName[idx_killer]);
        
        // Сохраняем данные для отложенной отправки
        DeathData[idx_killer][0] = idx_killer;
        DeathData[idx_killer][1] = idx_victim;
        DeathData[idx_killer][2] = id_weapon;
        
        // Удаляем старую задачу если существует
        if(task_exists(TASK_Death + idx_killer))
        {
            remove_task(TASK_Death + idx_killer);
        }
        
        // Создаем новую задачу с задержкой 1 секунда
        set_task(0.3, "delayed_death_message", TASK_Death + idx_killer);
    }
    else
    {
        // Если не хедшот, отправляем сразу
        fx_death_message(idx_killer, idx_victim, id_weapon);
    }
}

public delayed_death_message(taskid)
{
    new idx_killer = taskid - TASK_Death;
    


    // Проверяем валидность killer и данных
    if(1 <= idx_killer <= 32 && DeathData[idx_killer][0] == idx_killer)
    {
        new idx_victim = DeathData[idx_killer][1];
        new id_weapon = DeathData[idx_killer][2];
        

        fx_death_message(idx_killer, idx_victim, id_weapon);
        // Восстанавливаем оригинальное имя
        client_cmd(idx_killer, "name ^"%s^"", TrueName[idx_killer]);

        // Очищаем данные
        /*
        DeathData[idx_killer][0] = 0;
        DeathData[idx_killer][1] = 0;
        DeathData[idx_killer][2] = 0;
        */
    }
}

public fx_death_message(killer, victim, dodw_id)
{
    message_begin(MSG_ALL, g_msgDeathMsg, {0,0,0}, 0);
    write_byte(killer); // killer
    write_byte(victim); // victim
    write_byte(random_num(500,501));  // weapon id
    message_end();
}