#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>
#include <fun>
#include <dodx>
#include <dodfun>
#include <hamsandwich>

// id // name // steam
new ar_player_data[33][32][64]


public plugin_init()
{
    register_plugin("Name Saver/", "0.0", "America")
}

public client_authorized(idx_player)
{   
    /* взять имя. сравнить айпи или стим айди. 
    взять стим айди, записать согласно подлючению, и записать ему имя. 

    проверить есть ли стим в списке. взять имя из спискаю 
    если стим не совпадает, перезаписать данные 
    */

    new current_steam_id[64];
    get_user_authid(idx_player, current_steam_id, charsmax(current_steam_id));

    // правильный цикл по maxpl
    new sovpadenie = 0 
    new temp_steam_id[64] 
    for(new id = 1 ; id < get_maxplayers() + 1 ; id++)
    {   
        
        if(equal(current_steam_id , ar_player_data[id][0] ))
        {
            // sovpadenie = 1 
            // reboot name
            // return
        }
    }

    if (!sovpadenie)
    {   
        // save steam
        format( ar_player_data[idx_player][0] , charsmax( ar_player_data[idx_player][0]) , "%s", current_steam_id) 
        // save name 
    }

}
 

