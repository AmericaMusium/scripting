#include <amxmisc>
#include <dodx>
#include <dodfun>
#include <fakemeta>
#include <hamsandwich>

// Define globals 

new g_RoundStart_time
new g_team_captures[3]
new g_enable_toplist=false
new g_players_captures[33]
new g_winner = 0
new g_msgHudText


/* DoD teams */
#define ALLIES			1
#define AXIS 			2


public plugin_init()
{
register_plugin("DOD RoundEnd Stats ", "2", "America")


// Round Start and End
register_event("RoundState", "event_RoundStart", "a", "1=1");
register_event("RoundState","event_RoundEnd","a","1=3","1=4","1=5");
register_event("CapMsg","event_CapMsg_P","a") // Событие событие после захвата флага

RegisterHam(Ham_Use, "dod_score_ent", "Ham_Use_P") // 


g_msgHudText = get_user_msgid("HudText")

//register_clcmd("say end", "server_menu")

}




/// When PLAYES UNLOCKED AND CAN MOOVE
public event_RoundStart() 
{
    // Сохраняем секунду серверного таймера, на котором начался раунд.  
    g_RoundStart_time = floatround(get_gametime());
    
    g_team_captures[ALLIES] = 0;
    g_team_captures[AXIS] = 0;
    //server_print( "+++++ Round start at: %d seconds os setver time", g_RoundStart_time);
    new i
    for (i=0; i < 31; i++)
    {
        g_players_captures[i] == 0
    }

}


public event_RoundEnd() 
{   
new ServerTime;
ServerTime = floatround(get_gametime())
new roundTime = ServerTime - g_RoundStart_time
new minutes = roundTime / 60;
new seconds = roundTime % 60; 

RoundEnd_Stats()
}

public event_CapMsg_P(idx)
{
    // Player capture register info
    new id_player =  read_data(1)
    new id_team =  read_data(3)

    g_players_captures[id_player]++

    switch(id_team)
    {
        case ALLIES: g_team_captures[ALLIES]++
        case AXIS: g_team_captures[AXIS]++
    }
}



public Ham_Use_P(ent)
{
	g_winner = pev(ent, pev_team)	
}


public cmd_Timer(id) 
{

    new ServerTime;
    ServerTime = floatround(get_gametime())
    server_print("Server time: %d seconds", ServerTime);
        new roundTime = ServerTime - g_RoundStart_time
    new minutes = roundTime / 60;
    new seconds = roundTime % 60; 
    /*
    server_print("Round time: %d seconds", roundTime);
    server_print("Round time: %d minutes %d seconds", minutes, seconds);
    server_print( "+++++ Total Axis caps %d , Total Allies caps %d", g_team_captures[AXIS], g_team_captures[ALLIES]);
    */
}



public RoundEnd_Stats()
{
new ServerTime;
ServerTime = floatround(get_gametime());
new roundTime = ServerTime - g_RoundStart_time;
new minutes = roundTime / 60;
new seconds = roundTime % 60; 
new msg[256];
new msg_top[256]

if(g_enable_toplist)
{
    new top_1
    new i
    new name[32]
    for(i=1; i<31; i++)
    {   
        
        if(g_players_captures[i]>g_players_captures[i-1])
        {
            top_1 = i
            
            get_user_name(top_1, name, 31)
            server_print(" best is %s ,  captures %d", name ,g_players_captures[top_1])
            format( msg_top, 255 , "Best flag capturer : %s with %d flags", name, g_players_captures[top_1])
        }
    }
    
}


switch(g_winner)
{
    case ALLIES: 
    {   
 
        format(msg, 255, "[RoundEnd Stats] ^n The Allies win captured: %d flags ^n The Axis captured: %d flags ^n Round Time: %d min. %d sec. ^n %s " , g_team_captures[ALLIES] , g_team_captures[AXIS] , minutes, seconds, msg_top);
    }
     case AXIS: 
    {   
       format(msg, 255, "[RoundEnd Stats] ^n The Axis win captured: %d flags ^n The Allies captured: %d flags ^n Round Time: %d min. %d sec. ^n %s ", g_team_captures[AXIS] , g_team_captures[ALLIES] , minutes, seconds, msg_top);
    }
}

server_print(msg)
client_print(0, print_console, msg)

message_begin(MSG_ALL,g_msgHudText, "");
write_string(msg) //
write_byte(g_winner); // Dog Icon
message_end();


}



/////////// 

// MENU CREATOR 

/*
public server_menu(id, msg_2[])

{

    new i_Menu = menu_create(msg_2, "menu_handler")

 

        menu_additem(i_Menu, "\wТекст", "1", 0)

        menu_additem(i_Menu, "\wТекст", "2", 0)

        menu_additem(i_Menu, "\wТекст", "3", 0)

       

        menu_addblank(i_Menu, 0)

        menu_additem(i_Menu, "\wВыход", "0", 0)

       

    menu_setprop(i_Menu, MPROP_PERPAGE, 0)

    menu_display(id, i_Menu, 0)

}

 

public menu_handler(id, menu, item)

{

    if (item == MENU_EXIT)

    {

        menu_destroy(menu)

        return PLUGIN_HANDLED

    }

    new s_Data[6], s_Name[64], i_Access, i_Callback

    menu_item_getinfo(menu, item, i_Access, s_Data, charsmax(s_Data), s_Name, charsmax(s_Name), i_Callback)

    new i_Key = str_to_num(s_Data)

    switch(i_Key)

    {

                case 1:

        {

           

        }

            case 2:

        {

           

        }

                case 3:

        {

           

        }

                case 0:

        {

            menu_destroy(menu)

        }

    }

    menu_destroy(menu)

    return PLUGIN_HANDLED

 }
 */