#include <amxmodx>
#include <fakemeta>
#include <dodx>
#include <dodfun>
#include <hamsandwich>
#include <hud_widget>
#pragma semicolon 1

///// Assign SoundFiles
new const S_RoundStart[][] = 
{   
    "server/rd1.wav",
    "server/rd2.wav",
    "server/rd3.wav"
};

new const S_FirstBlood[][] = 
{
    "server/fb1.wav",
    "server/fb2.wav",
    "server/fb3.wav",
    "server/rk1.wav",
    "server/rk2.wav",
    "server/rk3.wav",
    "server/rk4.wav",
    "server/rk5.wav",
    "server/rk6.wav",
    "server/rk7.wav"
};

new const S_DoubleKill[][] = 
{
    "server/dk1.wav",
    "server/dk2.wav"
};

new const S_KnifeKill1[] = "server/kn1.wav";
new const S_Suicide1[] = "server/su1.wav";
new const S_Grenkill[] = "server/gr1.wav";

new bool:is_first_blood = false;
new Float:last_kill_time[MAX_PLAYERS+1];

enum _:EVENT_TYPE
{
    DamageDealt, // Массив для урона, нанесенного игроками. 33 - макс. кол-во игроков включая ботов
    DamageTaken, // Массив для урона, полученного игроками
    KillStreaks, // Серия убийств
    KnifeKills,  // Убийства с ножа
    ButtKills,
    GrenadeKills, // Убийство Гранатой
    // NoScopeKills,    // Убийства NoScope
    TeamKills,   // Количество Тимкиллов
    Suicides,    // Количество Суицидов
    PlayerFlagCaptures,  // Сколько флагов захватил игрок
    TeamFlagCaptures, // Сколько флагов захватила команда
    // LifeTime,    // Длина в жизни . в секундах
    // BazookaKills // Убийства с базуки
};

enum _:EVENT_MODE
{
    life, // = 0
    round,
    match
};

new g_[EVENT_MODE][EVENT_TYPE][MAX_PLAYERS+1];
new g_top[EVENT_MODE][EVENT_TYPE][MAX_PLAYERS+1];


new g_Winner = 0; 
new g_msgHudText; // EventHutText DogMessage


new cv_enable_sounds = 1; // включить звуки событий
new cv_enable_timer = 1; // показывать время раунда в окне HUD_CHAT
new cv_enable_top = 0; // запускает функцию сортировки по топу. 

// выношу текущие показатели времени
new g_ServerTime;
new g_RoundStart_time; // Сохраняем секунду серверного таймера, на котором начался раунд.  =26
new g_RoundTime; // Длина раунда
new g_minutes;
new g_seconds;

public plugin_precache()
{
    // Прокешируем звуки начала раунда
    if(cv_enable_sounds)
    {
            
        for (new i = 0; i < sizeof(S_RoundStart); i++)
        {
            precache_sound(S_RoundStart[i]);
        }

        // Прокешируем звуки первого убийства
        for (new i = 0; i < sizeof(S_FirstBlood); i++)
        {
            precache_sound(S_FirstBlood[i]);
        }
        // Прокешируем звуки первого убийства
        for (new i = 0; i < sizeof(S_DoubleKill); i++)
        {
            precache_sound(S_DoubleKill[i]);
        }

        precache_sound(S_KnifeKill1);
        precache_sound(S_Suicide1);
        precache_sound(S_Grenkill);
    }
}

public plugin_init()
{
    register_plugin("DOD Event Sounds","0.0","America");
    // WhatsApp +79101483016

    // Round Start and End
    // register_event("HLTV", "on_RoundStart", "a", "1=0", "2=0");
    register_event("RoundState", "on_RoundStart", "a", "1=1");  // НАЧАЛО раунжа
    register_event("RoundState","on_RoundEnd","a","1=3","1=4","1=5"); // КОНЕЦ раунда

    RegisterHam(Ham_Use, "dod_score_ent", "on_Ham_Use_P"); // Отлавливает последнего кто трогал флаг ?? 

    register_event("CapMsg","on_CapMsg_P","a"); // Событие событие после захвата флага
    // register_event("DeathMsg", "on_DeathMsg", "a"); // Событие после смерти игрока [заменил на форвард]

    RegisterHam(Ham_TakeDamage, "player", "on_TakeDamage_P", 1); // Хуки для отслеживания урона



    // Регистрация команды для просмотра топа
    register_clcmd("say /topdamage", "cmdTopDamage");

    HW_Upload_Colors();
    register_clcmd("say", "Say_register");

}   

public Say_register(id)
{
    new szMessage[192];
    read_args(szMessage, charsmax( szMessage ));
    remove_quotes(szMessage);
    HW_Message_Print(szMessage , random_num(0, COLOR_TYPE));
    return PLUGIN_CONTINUE;
}



public on_RoundStart() 
{   
    // Событие запускается. когда игроки уже могут двигаться.
    // Сохраняем секунду серверного таймера, на котором начался раунд.  
    g_RoundStart_time = floatround(get_gametime());
    
    Event_ResetArrays(life, 0);
    Event_ResetArrays(round, 0);


    is_first_blood = true;
    if (cv_enable_sounds)
        emit_sound(0, CHAN_AUTO, S_RoundStart[random_num(0,2)] , 1.0, ATTN_NORM, 0, PITCH_NORM);
}


public on_RoundEnd() 
{       
    /*
    // Регистрация длины раунда в секундах
    new ServerTime;
    ServerTime = floatround(get_gametime());
    g_RoundTIme = ServerTime - g_RoundStart_time; // Вот оно
    new minutes = g_RoundTIme / 60;
    new seconds = g_RoundTIme % 60; 

    // server_print("Round Time: %d min. %d sec. ^n ", minutes, seconds);
    */
    Top_Restruct_Full();
    Event_ResetArrays(round, 0);
}



public on_CapMsg_P(idx)
{
    // Player capture register info
    new idx_player =  read_data(1);
    new idx_team =  read_data(3);

    g_[life][PlayerFlagCaptures][idx_player]++;
    g_[round][PlayerFlagCaptures][idx_player]++;
    g_[match][PlayerFlagCaptures][idx_player]++;

    g_[round][TeamFlagCaptures][idx_team]++;
    g_[match][TeamFlagCaptures][idx_team]++;

    if(g_[life][PlayerFlagCaptures][idx_player] > 2)
    {
        Event_PrepairMessage(0, PlayerFlagCaptures, idx_player);
    }
}

public on_Ham_Use_P(ent)
{   
    // Отлавливает последнего кто трогал флаг
	g_Winner = pev(ent, pev_team);
}

public on_TakeDamage_P(victim, inflictor, attacker, Float:damage, damagebits)
{   
    // ++ Is_user_connected можно заменить на массив Alive
    if(is_user_connected(attacker) && attacker != victim)
    {   
        // Регистрируем нанесённый и полученный урон Damage
        new int_Damage = floatround(damage);
        g_[life][DamageDealt][attacker]+= int_Damage;
        g_[round][DamageDealt][attacker]+= int_Damage;
        g_[match][DamageDealt][attacker]+= int_Damage;

        g_[life][DamageTaken][victim]+= int_Damage;
        g_[round][DamageTaken][victim]+= int_Damage;
        g_[match][DamageTaken][victim]+= int_Damage;
        return HAM_IGNORED;

    }
    return HAM_IGNORED;
}


public client_death(idx_killer, idx_victim, id_weapon, hitplace,TK)
{
    // Вызывает на сервере . когда пришло сообщение от игрока
    // new idx_killer = killer;  // KILLER
    // new idx_victim = victim; // WEAPON
    // new id_weapon = wpnindex; // WEAPON

    // Cброс Жертве
    Event_ResetArrays(life, idx_victim);
    

    // KillStreaks суммировать KillStreaks
    for (new size_EVENT_MODE = 0 ; size_EVENT_MODE < EVENT_MODE; size_EVENT_MODE++)
    {   
        // поиск по времени регистрации работает корректно.
        g_[size_EVENT_MODE][KillStreaks][idx_killer]++;
    }
    if(g_[life][KillStreaks][idx_killer] > 5)
    {
        // проверить топку, проверить ACE 
        Event_PrepairMessage(EVENT_MODE, KillStreaks, idx_killer);
        Top_Restruct(life, KillStreaks);
    }
    if(g_[round][KillStreaks][idx_killer] > 20)
    {   
        // QuadAce
        Event_PrepairMessage(EVENT_MODE, KillStreaks, idx_killer);
        Top_Restruct(round, KillStreaks);
    }

    if(TK)
    {   
        // суммировать TeamKills
        for (new size_EVENT_MODE = 0 ; size_EVENT_MODE < EVENT_MODE; size_EVENT_MODE++)
        {   
            // поиск по времени регистрации работает корректно.
            g_[size_EVENT_MODE][TeamKills][idx_killer]++;
        }
        if (g_[round][TeamKills][idx_killer] > 10)
        {   
            Event_PrepairMessage(EVENT_MODE, TeamKills, idx_killer);
            Top_Restruct(match, TeamKills);
        }
    }


    // event_sounds block
    if (is_first_blood == true && idx_killer != idx_victim)
    {
        is_first_blood = false;
        if(cv_enable_sounds)
            emit_sound(0, CHAN_AUTO, S_FirstBlood[random_num(0,9)] , 1.0, ATTN_NORM, 0, PITCH_NORM);
        return;
    }
    if (idx_killer == idx_victim)
    {   
        // суммировать Suicide
        for (new size_EVENT_MODE = 0 ; size_EVENT_MODE < EVENT_MODE; size_EVENT_MODE++)
        {   
            g_[size_EVENT_MODE][Suicides][idx_killer]++;
        }

        Event_PrepairMessage(EVENT_MODE, Suicides, idx_killer);

        if(cv_enable_sounds)
            emit_sound(0, CHAN_AUTO, S_Suicide1 , 1.0, ATTN_NORM, 0, PITCH_NORM);
        return;
    }
    if (((get_gametime() - last_kill_time[idx_killer]) < 0.8))
    {
        // Doublekill!


        if(cv_enable_sounds)
            emit_sound(0, CHAN_AUTO, S_DoubleKill[random_num(0,1)] , 1.0, ATTN_NORM, 0, PITCH_NORM);
        last_kill_time[idx_killer] = get_gametime();
        return;
    }
    last_kill_time[idx_killer] = get_gametime();

    switch (id_weapon)
    {
        case DODW_MILLS_BOMB, 
        DODW_HANDGRENADE, 
        DODW_HANDGRENADE_EX, 
        DODW_STICKGRENADE, 
        DODW_STICKGRENADE_EX:
        {
            ///////////////////////  суммировать GrenadeKills
            for (new size_EVENT_MODE = 0 ; size_EVENT_MODE < EVENT_MODE; size_EVENT_MODE++)
            {   
                g_[size_EVENT_MODE][GrenadeKills][idx_killer]++;
            }

            Event_PrepairMessage(0, GrenadeKills, idx_killer);
            if(cv_enable_sounds)
                emit_sound(0, CHAN_AUTO, S_Grenkill , 1.0, ATTN_NORM, 0, PITCH_NORM);
            return;
        }
        //////////////////////////  
        case 42: // NEW DODW_GARAND_BUTT==42 == DODW_K43_BUTT
        {
            // суммировать ButtKills 
            for (new size_EVENT_MODE = 0 ; size_EVENT_MODE < EVENT_MODE; size_EVENT_MODE++)
            {   
                g_[size_EVENT_MODE][ButtKills][idx_killer]++;
                Event_PrepairMessage(EVENT_MODE, ButtKills, idx_killer);
                if(cv_enable_sounds)
                    emit_sound(0, CHAN_AUTO, S_KnifeKill1 , 1.0, ATTN_NORM, 0, PITCH_NORM);

                return;
            }   

        } 
        case 43, // DODW_ENFIELD_BAYONET
        37, // DODW_KAR_BAYONET + // DODW_BRITKNIFE
        DODW_AMERKNIFE,
        DODW_GERKNIFE,
        DODW_SPADE:
        {
            // суммировать KnifeKills
            for (new size_EVENT_MODE = 0 ; size_EVENT_MODE < EVENT_MODE; size_EVENT_MODE++)
            {   
                g_[size_EVENT_MODE][KnifeKills][idx_killer]++;
            }

            Event_PrepairMessage(EVENT_MODE, KnifeKills, idx_killer);
            if(cv_enable_sounds)
                emit_sound(0, CHAN_AUTO, S_KnifeKill1 , 1.0, ATTN_NORM, 0, PITCH_NORM);
            return;
        }
    }
    
    // Если ничего не сработало, просто покажем урон 
    
    if(g_[life][DamageDealt][idx_killer] > 500)
    {
        Event_PrepairMessage(0, DamageDealt, idx_killer);
        Top_Restruct(life, DamageDealt);
    }

}

public client_disconnected(idx_player)
{
    // Обнуляем статистику при выходе игрока
    for (new size_EVENT_MODE = 0 ; size_EVENT_MODE < EVENT_MODE; size_EVENT_MODE++)
    {   
        Event_ResetArrays(size_EVENT_MODE, idx_player);
    }
}



public cmdTopDamage(id)
{
    new players[32], pnum;
    get_players(players, pnum, "ch"); // Получаем список живых игроков
    
    // Сортировка игроков по урону (простой метод, для примера)
    for(new i = 0; i < pnum; i++)
    {
        for(new j = i + 1; j < pnum; j++)
        {   
            
            if(g_[round][DamageDealt][players[i]] < g_[round][DamageDealt][players[j]])
            {
                new temp = players[i];
                players[i] = players[j];
                players[j] = temp;
            }
        }
    }
    
    // Вывод топа
    client_print(id, print_chat, "Топ игроков по нанесенному урону:");
    for(new i = 0; i < pnum && i < 10; i++) // Показываем только топ 10
    {
        new name[32];
        get_user_name(players[i], name, 31);
        client_print(id, print_chat, "%d. %s - %d урона", i + 1, name, g_[round][DamageDealt][players[i]]);
        server_print("%d. %s - %d урона", i + 1, name, g_[round][DamageDealt][players[i]]);
    }
    
    return PLUGIN_HANDLED;
}



public RoundEnd_Stats()
{   
    /*
    new ServerTime;
    ServerTime = floatround(get_gametime());
    new roundTime = ServerTime - g_RoundStart_time;
    new minutes = roundTime / 60;
    new seconds = roundTime % 60; 
    new msg[256];
    new msg_top[256];

    if(g_enable_toplist)
    {
        new top_1;
        new i;
        new name[32];
        for(i=1; i<31; i++)
        {   
            if(g_[round][PlayerFlagCaptures][i] > g_[round][PlayerFlagCaptures][i-1])
            {
                top_1 = i;
                
                get_user_name(top_1, name, 31);
                server_print(" best is %s ,  captures %d", name , g_[round][PlayerFlagCaptures][top_1]);
                format( msg_top, 255 , "Best flag capturer : %s with %d flags", name, g_[round][PlayerFlagCaptures][top_1]);
            }
        }
        
    }

    switch(g_Winner)
    {
        case ALLIES: 
        {   
            format(msg, 255, "[RoundEnd Stats] ^n The Allies win captured: %d flags ^n The Axis captured: %d flags ^n Round Time: %d min. %d sec. ^n %s " , g_[round][TeamFlagCaptures][ALLIES] , g_[round][TeamFlagCaptures][AXIS] , minutes, seconds, msg_top);
        }
        case AXIS: 
        {   
            format(msg, 255, "[RoundEnd Stats] ^n The Axis win captured: %d flags ^n The Allies captured: %d flags ^n Round Time: %d min. %d sec. ^n %s ", g_[round][TeamFlagCaptures][AXIS] , g_[round][TeamFlagCaptures][ALLIES] , minutes, seconds, msg_top);
        }
    }

    server_print(msg);
    client_print(0, print_console, msg);

    message_begin(MSG_ALL,g_msgHudText, "");
    write_string(msg); //
    write_byte(g_Winner); // Dog Icon
    message_end();
    */
}

public Event_ResetArrays(ev_mode, idx_player)
{   
    // время учёта ev_mode, индекс игрока
    if (idx_player)
    {
        // узнать размер массива
        for (new i_event_types = 0 ; i_event_types < EVENT_TYPE; i_event_types++)
        {   
            // очистить события
            g_[ev_mode][i_event_types][idx_player] = 0;
        }
    }
    else 
    {
        for (new i_event_types = 0 ; i_event_types < EVENT_TYPE; i_event_types++)
        {   
            for (new player = 0 ; player < get_maxplayers() + 1; player++ )
            {
                g_[ev_mode][i_event_types][player] = 0;
            }
        }
        
    }
}


public Event_PrepairMessage(ev_mode, ev_type, idx_player)
{   
    // server_print("ev_mode = %d, ev_type = %d, idx_Player = %d ", ev_mode, ev_type, idx_player);
    // принимаем аргументы, генерируем текстовое сообщение, передаём цвет
    new ExportMessage[192];
    if(cv_enable_timer)
    {
        g_ServerTime = floatround(get_gametime());
        g_RoundTime = g_ServerTime - g_RoundStart_time;
        g_minutes = g_RoundTime / 60;
        g_seconds = g_RoundTime % 60; 
        format(ExportMessage, 191, "%02d:%02d", g_minutes, g_seconds);
    }
    // server_print("%s", ExportMessage);
    
    // получаем имя игрока
    new sz_UserName[32];
    new idx_team = pev(idx_player, pev_team);
    get_user_name(idx_player, sz_UserName, charsmax(sz_UserName));

    switch (ev_type)
    {
        case DamageDealt:
        {   
            // Вызывается при смерти игрока, если условия другие не сработали
            // Будет показывать только рассчёт по позицим топа
            
            format(ExportMessage, 191, "%s %s Нанёс %d урона в жизни! За раунд: %d | За матч: %d", ExportMessage, sz_UserName,
            g_[life][DamageDealt][idx_player],
            g_[round][DamageDealt][idx_player],
            g_[match][DamageDealt][idx_player]);
        

            //++
            return;
        }
        case DamageTaken:
        {
            format(ExportMessage, 191, "%s %s Получил %d урона в жизни! За раунд: %d | За матч: %d", ExportMessage, sz_UserName,
            g_[life][DamageTaken][idx_player],
            g_[round][DamageTaken][idx_player],
            g_[match][DamageTaken][idx_player]);

            return;

        }
        case KillStreaks: 
        {   
            format(ExportMessage, 191, "%s %s Убил %d человек в жизни! За раунд: %d | За матч: %d", ExportMessage, sz_UserName, 
            g_[life][KillStreaks][idx_player], 
            g_[round][KillStreaks][idx_player], 
            g_[match][KillStreaks][idx_player]);

        }
        case GrenadeKills:
        {
            format(ExportMessage, 191, "%s %s Убил  %d человек гранатой в жизни! За раунд: %d | За матч: %d", ExportMessage, sz_UserName, 
            g_[life][GrenadeKills][idx_player], 
            g_[round][GrenadeKills][idx_player], 
            g_[match][GrenadeKills][idx_player]);

        }
        case KnifeKills:
        {   
            format(ExportMessage, 191, "%s %s Убил %d человек ножом в жизни! За раунд: %d | За матч: %d", ExportMessage, sz_UserName, 
            g_[life][KnifeKills][idx_player], 
            g_[round][KnifeKills][idx_player], 
            g_[match][KnifeKills][idx_player]);

            HW_Message_Print(ExportMessage, basic);
            return;

        }
        case TeamKills:
        {   
            format(ExportMessage, 191, "%s %s Убил %d товарищей по команде в жизни! За раунд: %d | За матч: %d", ExportMessage, sz_UserName, 
            g_[life][TeamKills][idx_player], 
            g_[round][TeamKills][idx_player], 
            g_[match][TeamKills][idx_player]);
            HW_Message_Print(ExportMessage, idx_team);
            return;
        }
        case Suicides:
        {   
            format(ExportMessage, 191, "%s %s Убил себя сам %d раз за раунд | За матч: %d", ExportMessage, sz_UserName, 
            // g_[life][Suicides][idx_player], // несколько раз за жизнь не умрёшь ))
            g_[round][Suicides][idx_player], 
            g_[match][Suicides][idx_player]);

        }
        case PlayerFlagCaptures:
        {
            format(ExportMessage, 191, "%s %s Захватил %d флаг за жизнь ! За раунд: %d ", ExportMessage, sz_UserName,
            g_[life][PlayerFlagCaptures][idx_player],
            g_[round][PlayerFlagCaptures][idx_player]);
            // g_[match][PlayerFlagCaptures][idx_player]);  за матч есть статистика в Tab

            HW_Message_Print(ExportMessage, idx_team);
            return;
        }
        case TeamFlagCaptures:
        {   
            /*
            format(ExportMessage, 191, "%s %s Захватил %d флаг за жизнь ! За раунд: %d | За матч: %d", ExportMessage, sz_UserName,
            g_[life][PlayerFlagCaptures][idx_player],
            g_[round][PlayerFlagCaptures][idx_player],
            g_[match][PlayerFlagCaptures][idx_player]);
            HW_Message_Print(ExportMessage, idx_team);
            */
            return;
        }        
    }

    HW_Message_Print(ExportMessage, basic);
}

public Event_Leader_Check()
{

}

public Top_Restruct(ev_mode, ev_type)
{   
    if(!cv_enable_top)
        return;

    if (ev_mode == EVENT_MODE || ev_type == EVENT_TYPE)
    {   // Если передавай аргумент ev_mode == EVENT_MODE , значит мы должны просмотреть весь массив режимов жизнь, раунд.
        Top_Restruct_Full();
        return;
    }
    // Временный массив для хранения индексов игроков
    new sorted_players[MAX_PLAYERS + 1];
    new player_scores[MAX_PLAYERS + 1]; // Массив для хранения значений событий игроков

    // Инициализируем массив индексами игроков (1-based)
    for (new i = 1; i <= MAX_PLAYERS; i++)
    {
        sorted_players[i] = i; // Заполняем индексами
        player_scores[i] = g_[ev_mode][ev_type][i]; // Храним значения для каждого игрока
    }

    // Сортировка пузырьком с выводом информации о поднятии игрока
    for (new i = 1; i < MAX_PLAYERS; i++)
    {
        for (new j = i + 1; j <= MAX_PLAYERS; j++)
        {
            // Сравниваем значения текущих игроков
            if (player_scores[sorted_players[j]] > player_scores[sorted_players[i]])
            {   
                // ***************************************************************************************************
                //  Улучшение:  Проверяем, действительно ли игрок поднялся в топ-3
                if(i < 3)
                {
                    // Проверяем, изменилась ли позиция игрока, сверяя с предыдущим топом.
                    // Если g_top пуст (т.е. это первая сортировка), то считаем, что изменения произошли.
                    if (g_top[ev_mode][ev_type][i] != sorted_players[j] || g_top[ev_mode][ev_type][i] == 0)
                    {

                        // Игрок j поднимается, игрок i смещается
                        new id_player_up = sorted_players[j]; // Игрок, который поднимается
                        new idx_player_down = sorted_players[i]; // Игрок, который смещается
                        new i_place = i; // Новая позиция игрока j

                        new id_player_up_name[32], idx_player_down_name[32];
                        get_user_name(id_player_up, id_player_up_name, 31);
                        get_user_name(idx_player_down, idx_player_down_name, 31);

                        // Выводим сообщение о том, что игрок j поднялся на позицию i

                        new top_message[192];
                        format( top_message, 191, "%s поднялся на %d место, сместив %s", id_player_up_name, i_place, idx_player_down_name);
                        HW_Message_Print(top_message, hard);
                    }
                }
                // ***************************************************************************************************

                // Меняем местами индексы игроков
                new temp = sorted_players[i];
                sorted_players[i] = sorted_players[j];
                sorted_players[j] = temp;
            }
        }
    }

    // Заполняем массив лидеров g_top на основе отсортированного списка
    for (new k = 1; k <= MAX_PLAYERS; k++)
    {
        g_top[ev_mode][ev_type][k] = sorted_players[k];
    }
}

// Функция для создания таблицы лидеров если передан целевой аргумент.
public Top_Restruct_old(ev_mode, ev_type)
{   
    if(!cv_enable_top)
        return;

    if (ev_mode == EVENT_MODE || ev_type == EVENT_TYPE)
    {   // Если передавай аргумент ev_mode == EVENT_MODE , значит мы должны просмотреть весь массив режимов жизнь, раунд.
        Top_Restruct_Full();
        return;
    }
    // Временный массив для хранения индексов игроков
    new bool:notification_sended = false;
    new sorted_players[MAX_PLAYERS + 1];
    new player_scores[MAX_PLAYERS + 1]; // Массив для хранения значений событий игроков

    // Инициализируем массив индексами игроков (1-based)
    for (new i = 1; i <= MAX_PLAYERS; i++)
    {
        sorted_players[i] = i; // Заполняем индексами
        player_scores[i] = g_[ev_mode][ev_type][i]; // Храним значения для каждого игрока
    }

    // Сортировка пузырьком с выводом информации о поднятии игрока
    for (new i = 1; i < MAX_PLAYERS; i++)
    {
        for (new j = i + 1; j <= MAX_PLAYERS; j++)
        {
            // Сравниваем значения текущих игроков
            if (player_scores[sorted_players[j]] > player_scores[sorted_players[i]])
            {   
                if(!notification_sended && i < 4)
                {
                    // Игрок j поднимается, игрок i смещается
                    new id_player_up = sorted_players[j]; // Игрок, который поднимается
                    new idx_player_down = sorted_players[i]; // Игрок, который смещается
                    new i_place = i; // Новая позиция игрока j

                    new id_player_up_name[32], idx_player_down_name[32];
                    get_user_name(id_player_up, id_player_up_name, 31);
                    get_user_name(idx_player_down, idx_player_down_name, 31);

                    // Выводим сообщение о том, что игрок j поднялся на позицию i

                    new top_message[192];
                    format( top_message, 191, "%s поднялся на %d место, сместив %s", id_player_up_name, i_place, idx_player_down_name);
                    HW_Message_Print(top_message, basic_plus);
                    notification_sended = true;
                }
                // Меняем местами индексы игроков
                new temp = sorted_players[i];
                sorted_players[i] = sorted_players[j];
                sorted_players[j] = temp;
            }
        }
    }

    // Заполняем массив лидеров g_top на основе отсортированного списка
    for (new k = 1; k <= MAX_PLAYERS; k++)
    {
        g_top[ev_mode][ev_type][k] = sorted_players[k];
    }
}

public Top_Restruct_Full()
{   
    if(!cv_enable_top)
        return;
    new ev_mode;
    new ev_type;
    // Если передавай аргумент ev_mode == EVENT_MODE , значит мы должны просмотреть весь массив режимов жизнь, раунд.
    for (new size_EVENT_MODE = 0 ; size_EVENT_MODE < EVENT_MODE; size_EVENT_MODE++)
    {   
        ev_mode = size_EVENT_MODE;

        for (new size_EVENT_TYPE = 0; size_EVENT_TYPE < EVENT_TYPE; size_EVENT_TYPE++)
        {
            ev_type = size_EVENT_TYPE;
            // Временный массив для хранения индексов игроков
            new bool:notification_sended = false;
            new sorted_players[MAX_PLAYERS + 1];
            new player_scores[MAX_PLAYERS + 1]; // Массив для хранения значений событий игроков

            // Инициализируем массив индексами игроков (1-based)
            for (new i = 1; i <= MAX_PLAYERS; i++)
            {
                sorted_players[i] = i; // Заполняем индексами
                player_scores[i] = g_[ev_mode][ev_type][i]; // Храним значения для каждого игрока
            }

            // Сортировка пузырьком с выводом информации о поднятии игрока
            for (new i = 1; i < MAX_PLAYERS; i++)
            {
                for (new j = i + 1; j <= MAX_PLAYERS; j++)
                {
                    // Сравниваем значения текущих игроков
                    if (player_scores[sorted_players[j]] > player_scores[sorted_players[i]])
                    {   
                        if(!notification_sended && i < 4)
                        {
                            // Игрок j поднимается, игрок i смещается
                            new id_player_up = sorted_players[j]; // Игрок, который поднимается
                            new idx_player_down = sorted_players[i]; // Игрок, который смещается
                            new i_place = i; // Новая позиция игрока j

                            new id_player_up_name[32], idx_player_down_name[32];
                            get_user_name(id_player_up, id_player_up_name, 31);
                            get_user_name(idx_player_down, idx_player_down_name, 31);

                            // Выводим сообщение о том, что игрок j поднялся на позицию i

                            new top_message[192];
                            format( top_message, 191, "%s поднялся на %d место, сместив %s", id_player_up_name, i_place, idx_player_down_name);
                            HW_Message_Print(top_message, random_num(0,4));
                            notification_sended = true;
                        }
                        // Меняем местами индексы игроков
                        new temp = sorted_players[i];
                        sorted_players[i] = sorted_players[j];
                        sorted_players[j] = temp;
                    }
                }
            }

            // Заполняем массив лидеров g_top на основе отсортированного списка
            for (new k = 1; k <= MAX_PLAYERS; k++)
            {
                g_top[ev_mode][ev_type][k] = sorted_players[k];
            }
        } // закончили цикл по каждому типу
    }   // закончили цикл по каждому режиму
}
