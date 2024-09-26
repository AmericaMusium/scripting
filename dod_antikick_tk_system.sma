#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>
#include <fakemeta_util>
#include <fun>
#include <dodx>
#include <dodfun>
#include <dodconst>
#include <dodstats>
#include <dod_stocks>
#include <hamsandwich>

/* working log: 
2020 10.01.2023 Start plugin
pause about talks 
2050 continue work
2207 базовая версия проверки клиента по двуерным массивам и 
сихранением teamkills по стим id завершена
2114
2151 - база на следующий день собрана через двумерный массив
-- 
+ 6 часов
1949 начали ещё
*/


#define MAX_CONNECTIONS 1024 // определяем лимит подключений
new g_connections = 0        // счёт подключений за текушую сессию

// многоуровневый массив с указателем
enum _:PLAYER_DATA
{
    Netname[33], 
    tkills,
    zanyat
}

// создаём массив в с указательным массивом
new g_sessionlist[MAX_CONNECTIONS][PLAYER_DATA]
new player_id_to_sessionlist[50] // переопределяем номер строки для текущего игрока


public plugin_init()
{
    register_plugin("DOD ANTIKICK TK SYSTEM", "0.00", "America")
    register_srvcmd("list1", "sessionlist")

}

public client_connect(id)
{
// если не бот
if (!is_user_bot(id))
{
    new Array_sz[33]
    get_user_name(id, Array_sz, 32)
    // get_user_name
    // get_user_authid
    static i
    for (i=0; i < (g_connections +1); i++) 
    {   
        if( equal(Array_sz, g_sessionlist[i][Netname] ))
        {   
            // мы нашли человека который уже в этой сессии подключался.
            // В отдельном массиве текущей игры записываем ему адрес в реестре.
            player_id_to_sessionlist[id] = i
            server_print("________[session] Connected again # %d ; Name: %s , Teamkills in this session: %d", i ,Array_sz, g_sessionlist[i][tkills])
            // найти порядковый номер в ресстре, и
            //  на основе порядкового номера посчитать teamkills
            if( g_sessionlist[i][tkills] >= 10)
            {   
                server_print("________[session] Ban Player #%d , Name: %s , Teamkills in this session: %d / 10", i ,Array_sz, g_sessionlist[i][tkills])
                // ban kick
            }
            else
            {   
                server_print("________[session] Player #%d , Name: %s , Teamkills in this session: %d / 10", i ,Array_sz, g_sessionlist[i][tkills])
                /// message : если вы убьете больше 10 , вы будете забанены.
            }
            
            return PLUGIN_CONTINUE
        }
        else if(!equal(Array_sz, g_sessionlist[i][Netname]))
        {
            if(g_sessionlist[i][zanyat] != 1)
            {
                g_sessionlist[i][Netname]= Array_sz
                g_sessionlist[i][tkills]= 0
                g_sessionlist[i][zanyat] = 1
                g_connections++
                server_print("________[session] Registered new player # %d ; Name: %s", i ,Array_sz)
                return PLUGIN_CONTINUE
            }
        }

    }

    // get_user_ip(player, Array_sz, 32)
    // get_user_name(player, auth, 32)
    // просмотреть массив
    // если такой же steamid не найден, вписать себя в свободную ячейку.
    // если найден, взять порядковый номер , и узнать сколько засчитано тимкиллов
    // если их засчитано 10, то забанить на 1 час. 

}
}
public client_death(killer,victim,wpnindex,hitplace,TK)
{
    if (get_user_team(killer) == get_user_team(victim) && killer!=victim )
    {
        g_sessionlist[player_id_to_sessionlist[killer]][tkills] ++
        if( g_sessionlist[player_id_to_sessionlist[killer]][tkills] >= 10)
        {
            // BAN killer by steam ID
            // client_print(0 , print_chat, "OVER  10 kick ban !")
            // fx_ban_player(killer)
            // return PLUGIN_CONTINUE
        }
        //client_print(0 , print_chat, "TEAMK KILL :%d : %d", killer ,victim)
        // client_print(0 , print_chat, "TEEAM %d TEAM %d", get_user_team(killer) ,get_user_team(victim))
        server_print("________[session] Team kill!")
        // return PLUGIN_CONTINUE
    }
}


public sessionlist()
{
    static i
    for (i=0; i < g_connections; i++)
    {
        // g_sessionlist[i][Netname]
        server_print("________[session]_%d Name: %s", i, g_sessionlist[i][Netname] )

    }


}
