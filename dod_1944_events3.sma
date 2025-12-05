#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <fakemeta_util>
#include <fakemeta_stocks>
#include <dodx>
#include <dodfun>
#include <fun>
#include <engine>
#include <hud_widget>

#pragma semicolon 1

/*
УСТНОВИТЬ ЗНАЧЕНИЯ ОПОВЕЩЕНИЙ .

"weapons/clampdown.wav" "1" ;; - ПИЗДАТЫЙ ЗВУК ЗАВТОРА

проверить ещё раз, после последнего фикса . всё равно есть сообщение в консоль сервера:"SZ_GetSpace: overflow on #Nickname"
https://dev-cs.ru/threads/2264/page-3
https://github.com/rehlds/ReHLDS/issues/855
https://forums.alliedmods.net/showthread.php?t=334122   
Con_DPrintf
Con_Printf
Con_NetPrintf
*/

new cv_enable_sounds = 1;   // включить звуки событий
new cv_enable_chat = 1;     // включить чат событий
new cv_enable_fullchat = 1; // включить чат всех событий без ограничений по количествву килов и т.д.


new cv_enable_timer = 1;    // показывать время раунда в окне HUD_CHAT
new cv_write_stats = 1;     // записывать ли статистику ?
new cv_enable_top = 1;      // запускает функцию сортировки по топу. 
new cv_enable_dog_message = 1;  // Вкл\Выкл уведомления с собачкой
#define Dog_Message_Timer 45.0

new const S_RoundStart[][] = 
{   
    "1944/1944rd_adolf.wav",
    "1944/1944rd_partizan.wav",
    "1944/1944rd_levitan.wav",
    "1944/1944rd_levitan2.wav"
};

new const S_RoundEnd_Allies[][] = 
{   
    "1944/1944_toskaporodine.wav",
    "1944/1944_vstavaistrana.wav",
    "1944/1944_nabezvysot.wav",
    "1944/def_uswin.wav", 
    "1944/def_britwin.wav"
};

new const S_RoundEnd_Axis[][] = 
{   
    "1944/1944_batotai.wav",
    "1944/1944_erika.wav",
    "1944/1944_augustin.wav",
    "1944/def_germanwin.wav"
};

new const S_Capt_Allies[][] = 
{   
    "1944/1944cap_ussr0.wav",
    "1944/1944cap_ussr1.wav",
    "1944/def_uspointcaptured.wav",
    "1944/def_usareasecure.wav",
    "1944/def_britpointcaptured.wav",
    "1944/def_britobjectivesecure.wav"
};

new const S_Capt_Axis[][] = 
{   
    "1944/def_gerpointcaptured.wav",
    "1944/def_gerobjectivesecure.wav",
    "1944/def_gerareasecure.wav"
};

new const S_FirstBlood[][] = 
{
    "1944/1944firstblood.wav"
};

/*
new const S_DoubleKill[][] = 
{
    "server/dk1.wav",
    "server/dk2.wav"
};
*/
new const S_MeleeAndButt[][] = 
{
    "1944/1944ev_knife.wav",
    "1944/1944ev_kass.wav",
    "1944/1944ev_dolp.wav"    
};

new const S_HeadShot[][] = 
{
    "1944/1944headshot.wav",
    "1944/1944headshot1.wav",
    "1944/1944headshot2.wav"    
};

new const S_Suicide1[] = "1944/1944taps.wav";
new const S_Grenkill[] = "1944/1944grenkill.wav";


new bool:is_first_blood = false;
new Float:last_kill_time[MAX_PLAYERS+1];
new bool:g_switcher_scoreboatd_damage = false;
new g_score_win[3];


#define MAX_STING_SIZE
#define HUDW_BAZOOKA 29
#define HUDW_PANZERSCHRECK 30
#define HUDW_PIAT 31

#define EV_FIRSTBLOOD 1
#define EV_ROUNDEND 2

enum _:EVENT_TIME
{
    life, // = 0
    round,
    match
};

// Константы для EVENT_TYPE
#define EV_DAMAGEDEALT          0
#define EV_DAMAGETAKEN          1
#define EV_TOTALKILLS           2
#define EV_KNIFEKILLS           3
#define EV_BUTTKILLS            4
#define EV_GRENADEKILLS         5
#define EV_TEAMKILLS            6
#define EV_SUICIDES             7
#define EV_PLAYERFLAGCAPTURES   8
#define EV_TEAMFLAGCAPTURES     9
#define EV_HEADSOTS             10
#define EV_BAZOOKAKILLS         11


// Перечисление EVENT_TYPE с назначенными константами
enum _:EVENT_TYPE
{
    DamageDealt = EV_DAMAGEDEALT,          // 0
    DamageTaken = EV_DAMAGETAKEN,          // 1
    TotalKills = EV_TOTALKILLS,            // 2
    KnifeKills = EV_KNIFEKILLS,            // 3
    ButtKills = EV_BUTTKILLS,              // 4
    GrenadeKills = EV_GRENADEKILLS,        // 5
    TeamKills = EV_TEAMKILLS,              // 6
    Suicides = EV_SUICIDES,                // 7
    PlayerFlagCaptures = EV_PLAYERFLAGCAPTURES, // 8
    TeamFlagCaptures = EV_TEAMFLAGCAPTURES,     // 9
    HeadShots = EV_HEADSOTS,               // 10
    BazookaKills = EV_BAZOOKAKILLS         // 11
};

new g_[EVENT_TIME][EVENT_TYPE][MAX_PLAYERS+1];
new g_top[EVENT_TIME][EVENT_TYPE][MAX_PLAYERS+1];


new g_Winner = 0; 
new g_msgHudText; // EventHutText DogMessage


#define iszHudText 190


// выношу текущие показатели времени
new g_ServerTime; // он же MatchTime
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
            /*
            // Прокешируем звуки первого убийства
            for (new i = 0; i < sizeof(S_DoubleKill); i++)
            {
                // precache_sound(S_DoubleKill[i]);
            }
            */
            // Прокешируем звуки убийства ближнего боя
        for (new i = 0; i < sizeof(S_MeleeAndButt); i++)
            {
                precache_sound(S_MeleeAndButt[i]);
            }
            // Захват флага Allies
        for (new i = 0; i < sizeof(S_Capt_Allies); i++)
            {
                precache_sound(S_Capt_Allies[i]);
            }
            // Захват флага Axis
        for (new i = 0; i < sizeof(S_Capt_Axis); i++)
            {
                precache_sound(S_Capt_Axis[i]);
            }
            // Победа Allies
        for (new i = 0; i < sizeof(S_RoundEnd_Allies); i++)
            {
                precache_sound(S_RoundEnd_Allies[i]);
            }
            // Победа Axis
        for (new i = 0; i < sizeof(S_RoundEnd_Axis); i++)
            {
                precache_sound(S_RoundEnd_Axis[i]);
            }
            // headshot
        for (new i = 0; i < sizeof(S_HeadShot); i++)
            {
                precache_sound(S_HeadShot[i]);
            }

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
    //      1=3 — раунд завершён (Round End).
    //      1=4 — раунд начат (Round Start).
    //      1=5 — раунд в процессе (Round Active).

    RegisterHam(Ham_Use, "dod_score_ent", "on_Ham_Use_P"); // Отлавливает последнего кто трогал флаг ?? 
    register_event("CapMsg","on_CapMsg_P","a"); // Событие событие после захвата флага

    // Оказывается в Forward ClientDeath не учитывается TK, по этому приходится лоавить DeathMessage
    register_event("DeathMsg", "on_DeathMsg", "a"); // Дополнительное  Событие после смерти игрока , т.к. основной форвард client_death не читает ID патрона от базуки
    // RegisterHam(Ham_TakeDamage, "player", "on_TakeDamage_P", true); // Хуки для отслеживания урона

    // set_task(4.0, "ScoreBoard_damage_switch", 0, _, _, "b");

    g_msgHudText = get_user_msgid("HudText");
    set_task( 5.0, "HUD_Dog_Notificator");
    
    // Регистрация команды для просмотра топа
    register_clcmd("say /topdamage", "cmdTopDamage");



    HW_init();
    
    register_clcmd("say", "Say_register");

}

public Say_register(id)
{
    new szMessage[MAX_CHARS];
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
    g_score_win[g_Winner]++;
    Stats_ResetArrays(life, 0);
    Stats_ResetArrays(round, 0);
    g_Winner = 0;

    is_first_blood = true;
    if (cv_enable_sounds)
        emit_sound(0, CHAN_AUTO, S_RoundStart[random_num(0, sizeof(S_RoundStart)-1)] , 1.0, ATTN_NORM, 0, PITCH_NORM);
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
    new arg1 = read_data(1);
    // server_print(" on_RoundEnd Winer: %d Arg1: %d ", g_Winner, arg1 );
    if(g_Winner != ALLIES && g_Winner != AXIS) return; // Добавить
    switch(g_Winner)
    {
        case ALLIES: emit_sound(0, CHAN_AUTO, S_RoundEnd_Allies[random_num(0, sizeof(S_RoundEnd_Allies)-1)], 0.8, ATTN_NORM, 0, PITCH_NORM);
        case AXIS:  emit_sound(0, CHAN_AUTO, S_RoundEnd_Axis[random_num(0, sizeof(S_RoundEnd_Axis)-1)], 0.8, ATTN_NORM, 0, PITCH_NORM);
        default: arg1 = 0; // void  server_print("Event Plugin: on_RoundEnd() default case called");
    }
    if(g_Winner)    HUD_Chat_Message_Pre(0, EVENT_TYPE + EV_ROUNDEND, g_Winner);

    //Top_Restruct_Full();
    Stats_ResetArrays(round, 0);
}



public on_CapMsg_P(idx)
{
    // Player capture register info
    // Событие событие после захвата флага
    new idx_player =  read_data(1);
    new idx_team =  read_data(3);

    g_[life][PlayerFlagCaptures][idx_player]++;
    g_[round][PlayerFlagCaptures][idx_player]++;
    g_[match][PlayerFlagCaptures][idx_player]++;

    g_[round][TeamFlagCaptures][idx_team]++;
    g_[match][TeamFlagCaptures][idx_team]++;

    if(g_[life][PlayerFlagCaptures][idx_player] > 2)
    {
        HUD_Chat_Message_Pre(0, PlayerFlagCaptures, idx_player);
    }

    if (cv_enable_sounds)
    {
        switch(idx_team)
        {
            case ALLIES: emit_sound(0, CHAN_AUTO, S_Capt_Allies[random_num(0, sizeof(S_Capt_Allies)-1)] , 1.0, ATTN_NORM, 0, PITCH_NORM);
            case AXIS:  emit_sound(0, CHAN_AUTO, S_Capt_Axis[random_num(0, sizeof(S_Capt_Axis)-1)] , 1.0, ATTN_NORM, 0, PITCH_NORM);
            default: return;
        }
    }
        
}

public on_Ham_Use_P(ent)
{   
    // Отлавливает последнего кто трогал флаг
    if (pev_valid(ent)) g_Winner = pev(ent, pev_team);
}

public on_TakeDamage_P(victim, inflictor, attacker, Float:damage, damagebits)
{   
    // ++ Is_user_connected можно заменить на массив Alive
    if(!cv_write_stats) return HAM_IGNORED;

    if(is_user_connected(victim) && is_user_connected(attacker) && (attacker != victim))
    {   
        // Регистрируем нанесённый и полученный урон Damage
        new int_Damage = floatround(damage);
        g_[life][DamageDealt][attacker]+= int_Damage;
        g_[round][DamageDealt][attacker]+= int_Damage;
        g_[match][DamageDealt][attacker]+= int_Damage;

        g_[life][DamageTaken][victim]+= int_Damage;
        g_[round][DamageTaken][victim]+= int_Damage;
        g_[match][DamageTaken][victim]+= int_Damage;

        // HUD_Chat_Message_Pre(EVENT_TIME, DamageDealt, attacker);
        // HUD_Chat_Message_Pre(EVENT_TIME, DamageTaken, attacker);
        return HAM_IGNORED;

    }
    return HAM_IGNORED;
}

public client_putinserver(idx_player)
{
    Stats_ResetArrays(life, idx_player);
    Stats_ResetArrays(round, idx_player);
    Stats_ResetArrays(match, idx_player);
    last_kill_time[idx_player] = 0.0;
}


public client_death(idx_killer, idx_victim, id_weapon, hitplace, TK)
{
    // server_print(" some one killed");
    // server_print("client_death idx_killer %d || idx_victim  %d || id_weapon  %d || HIT %d TK %d",
    // idx_killer, idx_victim, id_weapon, hitplace, TK);

    if (hitplace < 0 || hitplace > 7) return;

    // idx_victim всегда должен быть валидным игроком
    if (!idx_victim || idx_victim > MAX_PLAYERS || !is_user_connected(idx_victim))
        return;

    // idx_killer может быть 0 (мирный игрок)
    if (idx_killer > 0 && idx_killer <= MAX_PLAYERS && !is_user_connected(idx_killer))
        return;

    // id_weapon проверка
    if (id_weapon < 0 || id_weapon > 42) return;

    // Cброс Жертве
    if (cv_write_stats)
    {
        Stats_ResetArrays(life, idx_victim);
    }
    Stats_Write(idx_killer, TotalKills);
    
    // first_blood
    if (is_first_blood == true && idx_killer != idx_victim)
    {
        is_first_blood = false;

        if(cv_enable_sounds)
            emit_sound(0, CHAN_AUTO, S_FirstBlood[0] , 1.0, ATTN_NORM, 0, PITCH_NORM);

        HUD_Chat_Message_Pre(0, EVENT_TYPE + EV_FIRSTBLOOD, idx_killer);
        return;
    }

    //// TeamKill
    if  (get_user_team(idx_killer) == get_user_team(idx_victim) || TK)
    {   
        Stats_Write(idx_killer, TeamKills);

        if(cv_enable_sounds)
            emit_sound(0, CHAN_AUTO, S_FirstBlood[0] , 1.0, ATTN_NORM, 0, PITCH_NORM);

        HUD_Chat_Message_Pre(EVENT_TIME, TeamKills, idx_killer);
        return;
    }
    // Doublekill!
    /*
    if (((get_gametime() - last_kill_time[idx_killer]) < 0.8))
    {
        
        if(cv_enable_sounds)
            emit_sound(0, CHAN_AUTO, S_DoubleKill[random_num(0,1)] , 1.0, ATTN_NORM, 0, PITCH_NORM);
        last_kill_time[idx_killer] = get_gametime();
        return;
    }
    last_kill_time[idx_killer] = get_gametime();
    */

    /*
    //// Suicides
    if (idx_victim == idx_killer || idx_killer == 0)
    {   
        Stats_Write(idx_victim, Suicides);
        
        if(cv_enable_sounds)
            emit_sound(0, CHAN_AUTO, S_Suicide1 , 0.3, ATTN_NORM, 0, PITCH_NORM);

        HUD_Chat_Message_Pre(0, Suicides, idx_victim);
        return;
    }
    */

    /// HEADSHOT
    if(hitplace==1)
    {   
        Stats_Write(idx_killer, HeadShots);

        if(cv_enable_sounds)
            emit_sound(0, CHAN_AUTO, S_HeadShot[random_num(0, sizeof(S_HeadShot)-1)] , 1.0, ATTN_NORM, 0, PITCH_NORM);
        

        // Register Universal data
        /*
        надо ловить положение головы, если жертва лежит на земле
        new Float:f_Ori[3], i_Ori[3];
        pev(idx_victim, pev_origin, f_Ori);
        FVecIVec(f_Ori, i_Ori);
        i_Ori[2]+=30;
        fx_bloodpuff(i_Ori);
        */
        HUD_Chat_Message_Pre(EVENT_TIME, HeadShots, idx_killer);
    }

    switch (id_weapon)
    {
        case DODW_MILLS_BOMB, 
        DODW_HANDGRENADE, 
        DODW_HANDGRENADE_EX, 
        DODW_STICKGRENADE, 
        DODW_STICKGRENADE_EX:
        {
            ///////////////////////  Grenade Kills
            Stats_Write(idx_killer, GrenadeKills);

            if(cv_enable_sounds)
                emit_sound(0, CHAN_AUTO, S_Grenkill , 1.0, ATTN_NORM, 0, PITCH_NORM);

            HUD_Chat_Message_Pre(0, GrenadeKills, idx_killer);
            return;
        }

        //////////////////// BUTKILL
        case DODW_GARAND_BUTT, DODW_K43_BUTT, 42: // NEW DODW_GARAND_BUTT==42 == DODW_K43_BUTT
        {
            // суммировать ButtKills 
            Stats_Write(idx_killer, ButtKills);

            if(cv_enable_sounds)
                emit_sound(0, CHAN_AUTO, S_MeleeAndButt[random_num(1 , sizeof(S_MeleeAndButt)-1)] , 1.0, ATTN_NORM, 0, PITCH_NORM);
            
            HUD_Chat_Message_Pre(EVENT_TIME, ButtKills, idx_killer);
            return;
        }

        case DODW_AMERKNIFE, DODW_KAR_BAYONET, DODW_ENFIELD_BAYONET,
        DODW_GERKNIFE, DODW_BRITKNIFE, //  43, 37, //
        DODW_SPADE:
        {
            // суммировать KnifeKills
            Stats_Write(idx_killer, KnifeKills);

            if(cv_enable_sounds)
                emit_sound(0, CHAN_AUTO, S_MeleeAndButt[0] , 0.4, ATTN_NORM, 0, PITCH_NORM);

            HUD_Chat_Message_Pre(EVENT_TIME, KnifeKills, idx_killer);
            return;
        }
        default: return;// server_print("client_death DEAFAULT CASE WEAPON ");
    }

    // Если ничего не сработало, просто покажем нанесённый урон
    // HUD_Chat_Message_Pre(0, TotalKills, idx_killer);
    // HUD_Chat_Message_Pre(0, DamageDealt, idx_killer);
}


public on_DeathMsg(idx_killer, idx_victim, id_weapon)
{       
    // здесь нужно быть внимательным, т.к. ID_WEAPON HUD не соотвествует DODW_CONST
    // server_print("on_DeathMsg KILLER:%d, VICTIM:%d, HUDW %d", idx_killer, idx_victim, id_weapon);

    // idx_victim всегда должен быть игроком (1-32), иначе событие не имеет смысла
    if (idx_victim < 1 || idx_victim > MAX_PLAYERS || !is_user_connected(idx_victim))
        return;

    // idx_killer может быть 0 (мирный игрок)
    if (idx_killer > 0 && idx_killer <= MAX_PLAYERS && !is_user_connected(idx_killer))
        return;

    // idx_killer == 0 означает мирное убийство (trigger_hurt, worldspawn и т.п.)

    // Остальная логика
    switch (id_weapon)
    {   
        ///////////////////////  BazookaKills
        case HUDW_BAZOOKA, HUDW_PANZERSCHRECK, HUDW_PIAT:
        {
            Stats_Write(idx_killer, BazookaKills);

            if(cv_enable_sounds)
                emit_sound(0, CHAN_AUTO, S_Grenkill, 1.0, ATTN_NORM, 0, PITCH_NORM);

            HUD_Chat_Message_Pre(0, BazookaKills, idx_killer);
            return;
        }

        default:
        {   
            return;
            // server_print("on_DeathMsg default case: killer %d, victim %d id_weapon: %d", idx_killer, idx_victim, id_weapon);
        }
    }
    
}


public client_disconnected(idx_player)
{   

    // Удалить все задачи для игрока
    // remove_task(idx_player); // Основная задача
    // remove_task(idx_player + VOL_TASK); // Если есть другие задачи
    // Обнуляем статистику при выходе игрока
    for (new size_EVENT_TIME = 0 ; size_EVENT_TIME < EVENT_TIME; size_EVENT_TIME++)
    {   
        Stats_ResetArrays(size_EVENT_TIME, idx_player);
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
        // server_print("%d. %s - %d урона", i + 1, name, g_[round][DamageDealt][players[i]]);
    }
    
    return PLUGIN_HANDLED;
}




public HUD_Dog_Notificator()
{   
    if (!cv_enable_dog_message) return;

    new ExportMessage[iszHudText];
    g_ServerTime = floatround(get_gametime());
    g_RoundTime = g_ServerTime - g_RoundStart_time;
    new match_minutes = g_ServerTime / 60;
    new match_seconds = g_ServerTime % 60; 
    g_minutes = g_RoundTime / 60;
    g_seconds = g_RoundTime % 60; 

    format(ExportMessage, sizeof(ExportMessage)-1, "Match: [%02d:%02d] | Round: [%02d:%02d] | Allies [ %d : %d ] Axis", match_minutes, match_seconds, g_minutes, g_seconds , g_score_win[ALLIES], g_score_win[AXIS] );
 
    if(cv_write_stats || cv_enable_top)
    {
        // Новый блок листать страницы
        // Статическая переменная для хранения текущей категории
        static top_page = 0;
        // Обновляем топ по урону за раунд
        new target_ev_time = top_page / EVENT_TYPE; // Вычисляем время (life, round, match)
        new target_ev_type = top_page % EVENT_TYPE; // Вычисляем тип (DamageDealt, DamageTaken, и т.д.)
        // Переход к следующей категории
        top_page = (top_page + 1) % (EVENT_TIME * EVENT_TYPE);

        /*
        // Обновляем топ по урону за раунд
        new target_ev_time = random_num(0, EVENT_TIME-1); 
        new target_ev_type = random_num(0, EVENT_TYPE-1);

        //server_print(" %d %d", target_ev_time , target_ev_type);
        */
        Stats_Restruct_Top(target_ev_time, target_ev_type);

        new word_ev_time[16];
        new word_ev_type[16];
        switch (target_ev_time)
        {
            case life: copy(word_ev_time, 15, "жизнь");
            case round: copy(word_ev_time, 15, "раунд");
            case match: copy(word_ev_time, 15, "матч");
            default: copy(word_ev_time, 15, " ");
        }
        switch (target_ev_type)
        {
            case DamageDealt: copy(word_ev_type, 15, "Damage Dealt");
            case DamageTaken: copy(word_ev_type, 15, "Damage Taken");
            case TotalKills:  copy(word_ev_type, 15, "Total Kills");
            case KnifeKills:  copy(word_ev_type, 15, "Knife Kills");
            case ButtKills:   copy(word_ev_type, 15, "Butt Kills");
            case GrenadeKills: copy(word_ev_type, 15, "Grenade Kills");
            case TeamKills:   copy(word_ev_type, 15, "Team Kills");
            case Suicides:    copy(word_ev_type, 15, "Suicides");
            case PlayerFlagCaptures: copy(word_ev_type, 15, "Player Flag Captures");
            case TeamFlagCaptures: copy(word_ev_type, 15, "Team Flag Captures");
            case HeadShots:   copy(word_ev_type, 15, "Headshots");
            case BazookaKills: copy(word_ev_type, 15, "Bazooka Kills");
            default: copy(word_ev_type, 15, "No discipline");
        }

        format(ExportMessage, sizeof(ExportMessage)-1, "^n %s Награда: %s за %s",ExportMessage, word_ev_type, word_ev_time);

        // Выводим топ-3 игроков по урону за раунд
        new top_player_count = 0;
        for (new i = 1; i <= 3; i++)
        {
            new player = g_top[target_ev_time][target_ev_type][i];

            if (g_[target_ev_time][target_ev_type][player] > 0 && is_user_connected(player))
            {   
                new name[32];
                get_user_name(player, name, charsmax(name));
                format(ExportMessage, sizeof(ExportMessage)-1, "%s^n%d: %s : %d", ExportMessage, i, name , g_[target_ev_time][target_ev_type][player]);
                top_player_count++;
            }
        }

        if (!top_player_count)
        {  
            format(ExportMessage, sizeof(ExportMessage)-1, "%s ^n -= в этом списке нет героев =-", ExportMessage);
            // set_task( 0.5, "HUD_Dog_Notificator");
            // return;
        }
        
    }

    // emit_sound(0, CHAN_AUTO, "weapons/weaponempty.wav" , 1.0, ATTN_NORM, 0, PITCH_NORM);
    // update: сдесь сделать на битсуммы для тех не желает догмесседж от сервер меню
    message_begin(MSG_ALL, g_msgHudText, "");
    write_string(ExportMessage); //
    write_byte(true); // Dog Icon
    message_end();

    // set_task( Dog_Message_Timer, "HUD_Dog_Notificator");
    set_task( 1.4, "HUD_Dog_Notificator");
}

public HUD_Chat_Message_Pre(ev_mode, ev_type, idx_player)
{   
    if (!cv_enable_chat) return;
    if (idx_player < 1 || idx_player > MAX_PLAYERS) return; // ✅ ПРАВИЛЬНО
    if (!is_user_connected(idx_player)) return; // ✅ ПРАВИЛЬНО

    
    new ExportMessage[MAX_CHARS];
    if(cv_enable_timer)
    {
        g_ServerTime = floatround(get_gametime());
        g_RoundTime = g_ServerTime - g_RoundStart_time;
        g_minutes = g_RoundTime / 60;
        g_seconds = g_RoundTime % 60; 
        format(ExportMessage, MAX_CHARS-1, "%02d:%02d", g_minutes, g_seconds);
    }

    new sz_UserName[32];
    new idx_team = pev(idx_player, pev_team);
    if(idx_team != ALLIES && idx_team != AXIS) return; // Добавит
    get_user_name(idx_player, sz_UserName, charsmax(sz_UserName));
    new bonus_impact = 0;

    switch (ev_type)
    {
        case DamageDealt:
        {   
            format(ExportMessage, MAX_CHARS-1, "%s %s Нанёс урон", ExportMessage, sz_UserName);
            if(cv_write_stats || cv_enable_top)
            {
                if(g_[life][DamageDealt][idx_player] > 1000)
                {   
                    format(ExportMessage, MAX_CHARS-1, "%s %d за жизнь", ExportMessage, g_[life][DamageDealt][idx_player]);
                    bonus_impact++;
                }
                if(g_[round][DamageDealt][idx_player] > 5000)
                {
                    format(ExportMessage, MAX_CHARS-1, "%s %d за раунд", ExportMessage, g_[round][DamageDealt][idx_player]);
                    bonus_impact++;
                }
                if(g_[match][DamageDealt][idx_player] > 10000)
                {
                    format(ExportMessage, MAX_CHARS-1, "%s %d за матч", ExportMessage, g_[match][DamageDealt][idx_player]);
                    bonus_impact++;
                }
            }
            if(bonus_impact)
            {
                HW_Message_Print(ExportMessage, basic_plus + bonus_impact);
            }
            else if(cv_enable_fullchat) 
            {
                HW_Message_Print(ExportMessage, basic);
            }
            return;
        }
        case DamageTaken:
        {   
            format(ExportMessage, MAX_CHARS-1, "%s %s получил урон", ExportMessage, sz_UserName);
            if(cv_write_stats || cv_enable_top)
            {
                if(g_[life][DamageTaken][idx_player] > 200)
                {
                    format(ExportMessage, MAX_CHARS-1, "%s %d за жизнь", ExportMessage, g_[life][DamageTaken][idx_player]);
                    bonus_impact++;
                }
                if(g_[round][DamageTaken][idx_player] > 5000)
                {
                    format(ExportMessage, MAX_CHARS-1, "%s %d за раунд", ExportMessage, g_[round][DamageTaken][idx_player]);
                    bonus_impact++;
                }
                if(g_[match][DamageTaken][idx_player] > 10000)
                {
                    format(ExportMessage, MAX_CHARS-1, "%s %d за матч", ExportMessage, g_[match][DamageTaken][idx_player]);
                    bonus_impact++;
                }
            }
            if(bonus_impact)
            {
                HW_Message_Print(ExportMessage, basic_plus + bonus_impact);
            }
            else if(cv_enable_fullchat) 
            {
                HW_Message_Print(ExportMessage, basic);
            }
            return;
        }
        case TotalKills: 
        {   
            format(ExportMessage, MAX_CHARS-1, "%s %s убил ", ExportMessage, sz_UserName);

            if(g_[life][TotalKills][idx_player] > 2)
            {
                format(ExportMessage, MAX_CHARS-1, "%s %d за жизнь", ExportMessage, g_[life][TotalKills][idx_player]);
                bonus_impact++;
            }
            if(g_[round][TotalKills][idx_player] > 4)
            {
                format(ExportMessage, MAX_CHARS-1, "%s %d за раунд", ExportMessage, g_[round][TotalKills][idx_player]);
                bonus_impact++;
            }
            if(g_[match][TotalKills][idx_player] > 8)
            {
                format(ExportMessage, MAX_CHARS-1, "%s %d за матч", ExportMessage, g_[match][TotalKills][idx_player]);
                bonus_impact++;
            }
            if(bonus_impact)
            {
                HW_Message_Print(ExportMessage, basic_plus + bonus_impact);
            }
            else if(cv_enable_fullchat) 
            {
                HW_Message_Print(ExportMessage, basic);
            }
            return;
        }
        case GrenadeKills:
        {
            format(ExportMessage, MAX_CHARS-1, "%s %s убил гранатой", ExportMessage, sz_UserName);
            if(g_[life][GrenadeKills][idx_player] > 5)
            {
                format(ExportMessage, MAX_CHARS-1, "%s %d за жизнь", ExportMessage, g_[life][GrenadeKills][idx_player]);
                bonus_impact++;
            }
            if(g_[round][GrenadeKills][idx_player] > 20)
            {
                format(ExportMessage, MAX_CHARS-1, "%s %d за раунд", ExportMessage, g_[round][GrenadeKills][idx_player]);
                bonus_impact++;
            }
            if(g_[match][GrenadeKills][idx_player] > 40)
            {
                format(ExportMessage, MAX_CHARS-1, "%s %d за матч", ExportMessage, g_[match][GrenadeKills][idx_player]);
                bonus_impact++;
            }
            if(bonus_impact)
            {
                HW_Message_Print(ExportMessage, basic_plus + bonus_impact);
            }
            else if(cv_enable_fullchat) 
            {
                HW_Message_Print(ExportMessage, basic);
            }
            return;
        }
        //// 
        case ButtKills:
        {   
            format(ExportMessage, MAX_CHARS-1, "%s %s убил прикладом", ExportMessage, sz_UserName);
            if(g_[life][ButtKills][idx_player] > 3)
            {
                format(ExportMessage, MAX_CHARS-1, "%s %d за жизнь", ExportMessage, g_[life][ButtKills][idx_player]);
                bonus_impact++;
            }
            if(g_[round][ButtKills][idx_player] > 15)
            {
                format(ExportMessage, MAX_CHARS-1, "%s %d за раунд", ExportMessage, g_[round][ButtKills][idx_player]);
                bonus_impact++;
            }
            if(g_[match][ButtKills][idx_player] > 30)
            {
                format(ExportMessage, MAX_CHARS-1, "%s %d за матч", ExportMessage, g_[match][ButtKills][idx_player]);
                bonus_impact++;
            }
            if(bonus_impact)
            {
                HW_Message_Print(ExportMessage, basic_plus + bonus_impact);
            }
            else if(cv_enable_fullchat) 
            {
                HW_Message_Print(ExportMessage, basic);
            }
            return;
        }

        case KnifeKills:
        {   
            format(ExportMessage, MAX_CHARS-1, "%s %s убил ножом", ExportMessage, sz_UserName);
            if(g_[life][KnifeKills][idx_player] > 3)
            {
                format(ExportMessage, MAX_CHARS-1, "%s %d за жизнь", ExportMessage, g_[life][KnifeKills][idx_player]);
                bonus_impact++;
            }
            if(g_[round][KnifeKills][idx_player] > 15)
            {
                format(ExportMessage, MAX_CHARS-1, "%s %d за раунд", ExportMessage, g_[round][KnifeKills][idx_player]);
                bonus_impact++;
            }
            if(g_[match][KnifeKills][idx_player] > 30)
            {
                format(ExportMessage, MAX_CHARS-1, "%s %d за матч", ExportMessage, g_[match][KnifeKills][idx_player]);
                bonus_impact++;
            }
            if(bonus_impact)
            {
                HW_Message_Print(ExportMessage, basic_plus + bonus_impact);
            }
            else if(cv_enable_fullchat) 
            {
                HW_Message_Print(ExportMessage, basic);
            }
            return;
        }
        case TeamKills:
        {   
            // Здесь ебаная ошибка ! 
            format(ExportMessage, MAX_CHARS-1, "%s %s убил своего", ExportMessage, sz_UserName);
            if(g_[life][TeamKills][idx_player] > 1)
            {
                format(ExportMessage, MAX_CHARS-1, "%s %d за жизнь", ExportMessage, g_[life][TeamKills][idx_player]);
                bonus_impact++;
            }
            if(g_[round][TeamKills][idx_player] > 10)
            {
                format(ExportMessage, MAX_CHARS-1, "%s %d за раунд", ExportMessage, g_[round][TeamKills][idx_player]);
                bonus_impact++;
            }
            if(g_[match][TeamKills][idx_player] > 20)
            {
                format(ExportMessage, MAX_CHARS-1, "%s %d за матч", ExportMessage, g_[match][TeamKills][idx_player]);
                bonus_impact++;
            }
            if(bonus_impact)
            {
                HW_Message_Print(ExportMessage, basic_plus + bonus_impact);
            }
            else if(cv_enable_fullchat) 
            {
                HW_Message_Print(ExportMessage, basic);
            }
            return;
        }
        case Suicides:
        {   
            format(ExportMessage, MAX_CHARS-1, "%s %s умер сам", ExportMessage, sz_UserName);
            if(g_[round][Suicides][idx_player] > 10)
            {
                format(ExportMessage, MAX_CHARS-1, "%s %d за раунд", ExportMessage, g_[round][Suicides][idx_player]);
                bonus_impact++;
            }
            if(g_[match][Suicides][idx_player] > 20)
            {
                format(ExportMessage, MAX_CHARS-1, "%s %d за матч", ExportMessage, g_[match][Suicides][idx_player]);
                bonus_impact++;
            }
            if(bonus_impact)
            {
                HW_Message_Print(ExportMessage, basic_plus + bonus_impact);
            }
            else if(cv_enable_fullchat) 
            {
                HW_Message_Print(ExportMessage, basic);
            }
            return;
        }
        case PlayerFlagCaptures:
        {
            format(ExportMessage, MAX_CHARS-1, "%s %s захватил флаг", ExportMessage, sz_UserName);
            if(g_[life][PlayerFlagCaptures][idx_player] > 5)
            {
                format(ExportMessage, MAX_CHARS-1, "%s %d за жизнь", ExportMessage, g_[life][PlayerFlagCaptures][idx_player]);
                bonus_impact++;
            }
            if(g_[round][PlayerFlagCaptures][idx_player] > 20)
            {
                format(ExportMessage, MAX_CHARS-1, "%s %d за раунд", ExportMessage, g_[round][PlayerFlagCaptures][idx_player]);
                bonus_impact++;
            }
            if(g_[match][PlayerFlagCaptures][idx_player] > 100)
            {
                format(ExportMessage, MAX_CHARS-1, "%s %d за матч", ExportMessage, g_[match][PlayerFlagCaptures][idx_player]);
                bonus_impact++;
            }
            if(bonus_impact)
            {
                HW_Message_Print(ExportMessage, idx_team);
            }
            else if(cv_enable_fullchat) 
            {
                HW_Message_Print(ExportMessage, idx_team);
            }
            return;
        }
        case TeamFlagCaptures:
        {   
            return;
        }
        case BazookaKills:
        {
            format(ExportMessage, MAX_CHARS-1, "%s %s убил ракетой", ExportMessage, sz_UserName);
            if(g_[life][BazookaKills][idx_player] > 5)
            {
                format(ExportMessage, MAX_CHARS-1, "%s %d за жизнь", ExportMessage, g_[life][BazookaKills][idx_player]);
                bonus_impact++;
            }
            if(g_[round][BazookaKills][idx_player] > 20)
            {
                format(ExportMessage, MAX_CHARS-1, "%s %d за раунд", ExportMessage, g_[round][BazookaKills][idx_player]);
                bonus_impact++;
            }
            if(g_[match][BazookaKills][idx_player] > 100)
            {
                format(ExportMessage, MAX_CHARS-1, "%s %d за матч", ExportMessage, g_[match][BazookaKills][idx_player]);
                bonus_impact++;
            }
            if(bonus_impact)
            {
                HW_Message_Print(ExportMessage, basic_plus + bonus_impact);
            }
            else if(cv_enable_fullchat) 
            {
                HW_Message_Print(ExportMessage, basic_plus);
            }
            return;
        }
        case HeadShots:
        {
            format(ExportMessage, MAX_CHARS-1, "%s %s убил, пробив голову ", ExportMessage, sz_UserName);
            if(g_[life][HeadShots][idx_player] > 2) // 5
            {
                format(ExportMessage, MAX_CHARS-1, "%s %d за жизнь", ExportMessage, g_[life][HeadShots][idx_player]);
                bonus_impact++;
            }
            if(g_[round][HeadShots][idx_player] > 4) // 
            {
                format(ExportMessage, MAX_CHARS-1, "%s %d за раунд", ExportMessage, g_[round][HeadShots][idx_player]);
                bonus_impact++;
            }
            if(g_[match][HeadShots][idx_player] > 6) //
            {
                format(ExportMessage, MAX_CHARS-1, "%s %d за матч", ExportMessage, g_[match][HeadShots][idx_player]);
                bonus_impact++;
            }
            if(bonus_impact)
            {
                HW_Message_Print(ExportMessage, basic_plus + bonus_impact);
            }
            else if(cv_enable_fullchat) 
            {
                HW_Message_Print(ExportMessage, basic_plus);
            }
            return;
        }
        case EVENT_TYPE + EV_FIRSTBLOOD:
        {
            format(ExportMessage, MAX_CHARS-1, "%s %s напал первым!", ExportMessage, sz_UserName);
            HW_Message_Print(ExportMessage, idx_team);
            return;
        }
        case EVENT_TYPE + EV_ROUNDEND:
        {
            format(ExportMessage, MAX_CHARS-1, "%s Раунд закончился", ExportMessage);
            switch (idx_player)
            {
                case ALLIES: format(ExportMessage, MAX_CHARS-1, "%s победой Allies", ExportMessage);
                case AXIS: format(ExportMessage, MAX_CHARS-1, "%s победой Axis", ExportMessage);
                default: format(ExportMessage, MAX_CHARS-1, "%s напрасно и безрезультатно", ExportMessage);
            }
            HW_Message_Print(ExportMessage, g_Winner);
            return;
        }
        default: 
        {
            format(ExportMessage, MAX_CHARS-1, "%s %s default case!  %d !", ExportMessage, sz_UserName, ev_type);
            HW_Message_Print(ExportMessage, basic);
        }
    }
}

public Stats_Write(idx_player, ev_type)
{   
    if(idx_player < 1 || idx_player > MAX_PLAYERS) return; // Добавить

    if(cv_write_stats)
    {
        for (new size_EVENT_TIME = 0 ; size_EVENT_TIME < EVENT_TIME; size_EVENT_TIME++)
        {   
            g_[size_EVENT_TIME][ev_type][idx_player]++;
        }
    }
}

public Stats_Restruct_Top(event_time, event_type)
{
    // Временный массив для хранения индексов игроков
    new sorted_players[MAX_PLAYERS + 1];
    new player_scores[MAX_PLAYERS + 1];

    // Инициализируем массив индексами игроков (1-based)
    for (new i = 1; i <= MAX_PLAYERS; i++)
    {
        sorted_players[i] = i; // Заполняем индексами
        player_scores[i] = g_[event_time][event_type][i]; // Храним значения для каждого игрока
    }

    // Сортировка пузырьком
    for (new i = 1; i < MAX_PLAYERS; i++)
    {
        if (!is_user_connected(sorted_players[i])) continue; // Пропустить невалидных игроков
        for (new j = i + 1; j <= MAX_PLAYERS; j++)
        {
            if (!is_user_connected(sorted_players[j])) continue; // Пропустить невалидных игроков
            if (player_scores[sorted_players[j]] > player_scores[sorted_players[i]])
            {
                new temp = sorted_players[i];
                sorted_players[i] = sorted_players[j];
                sorted_players[j] = temp;
            }
        }
    }

    // Заполняем массив g_top
    for (new k = 1; k <= MAX_PLAYERS; k++)
    {
        g_top[event_time][event_type][k] = sorted_players[k];
    }

    // Очищаем нулевой элемент (по вашему требованию)
    g_top[event_time][event_type][0] = 0;
}


public Stats_ResetArrays(ev_mode, idx_player)
{    
    // время учёта ev_mode, индекс игрока 
    // если игрок указан, то сбрасываем по указанному времени массив, если нет ,то обнуляем все события и всем, но в указанный ev_mode time
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


public Stats_RoundEnd()
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

    message_begin(MSG_ALL, g_msgHudText,"");
    write_string(msg); //
    write_byte(g_Winner); // Dog Icon
    message_end();
    */
}

public ScoreBoard_damage_switcher()
{   
    if(g_switcher_scoreboatd_damage == false)
    {   
        g_switcher_scoreboatd_damage = true;
        for (new player = 0 ; player < get_maxplayers() + 1; player++ )
        {   
            if(is_user_connected(player))
                dod_set_user_kills(player, g_[match][TotalKills][player], 1);
        }
    }
    else 
    {
        g_switcher_scoreboatd_damage = false;
        for (new player = 0 ; player < get_maxplayers() + 1; player++ )
        {   
            if(is_user_connected(player))
                dod_set_user_kills(player, g_[match][DamageDealt][player], 1);
        }
    }   
}


public fx_bloodpuff(i_Ori[3])
{   
    new g_msgBloodPuff = get_user_msgid("BloodPuff");
    message_begin(MSG_BROADCAST, g_msgBloodPuff, {0,0,0}, 0);
    write_coord(i_Ori[0]);
    write_coord(i_Ori[1]);
    write_coord(i_Ori[2]);
    message_end();
}

public dod_grenade_explosion(id, Float:pos[3], wpnid)
{
    //  
    new currentent = -1;
    while((currentent = find_ent_in_sphere(currentent,pos,Float:300.0)) != 0) 
    {
        if (pev_valid(currentent) && currentent > 0)
        {
                emit_sound(currentent, CHAN_AUTO, S_Grenkill , 1.0, ATTN_NORM, 0, PITCH_NORM); 
                break;
        }
    }
}

/*
public dod_grenade_explosion(id, Float:pos[3], wpnid)
{   
    for (new i = 1; i < get_maxplayers(); i++)
0,3
    {
        if(pev_valid(i) && is_user_alive(i))
        {          
            client_cmd( i,"spk 1944/1944grenkill" );
        }
    }
}
*/