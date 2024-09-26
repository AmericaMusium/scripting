
#include <amxmodx>
#include <fakemeta>
#include <fun>
#include <hamsandwich>
#include <dodx>
#include <dodfun>
#include <engine>

// настройки вывода текста HUD 
#define HUD_X 0.50 // 0.0 ; 1.0 ; -1=center
#define HUD_Y 0.40 // 0.0  верх; 1.0 низ
#define HUD_S 0.03 // расстояние между строками

///  Переменные режима рулетки
new g_spingame_player_bet[33] = -1 // Массив в который записываются ставка на число
new g_spingame_maxbets = 2
new g_spingame_curbets
new g_spingame_target_value
new bool:is_game_active = false
new bool:can_player_update_his_bet = true
new g_spingame_iteration = 0
new g_spingame_value_diapason = 20
#define ROLL_TRYS 28
new Float:TASK_INTERVAL = 0.4

#define S_ROLL_START "misc/dod_spin_start.wav"


//////// РЕЖИМ РАСПРЕДЕЛЕНИЯ .
new g_player_to_team[33] = 0
new g_swither_show_menu_to = 0
#define WINNER 0
#define LOSER 1
new g_idx_captain[2]
new bool: is_g_choosegame_mode_team_and_player = false 


#define CLASS_MASTER "dod_control_point_master"
#define CLASS_CNTPNT "dod_control_point"
#define CLASS_CPAREA "dod_capture_area"
#define CLASS_T_TELE "trigger_teleport"
#define CLASS_SCORES "dod_score_ent"
#define CLASS_T_HURT "trigger_hurt"
#define CLASS_F_TANK "func_tank"
#define m_iTeam 90


#define NEVER 0.0
#define PLUS1 1.0
#define POST 1
#define PRE 0
#define YES 1
#define NO 0
#define fm_find_ent_by_class(%1,%2) engfunc(EngFunc_FindEntityByString, %1, "classname", %2)


public plugin_precache()
{
    precache_sound(S_ROLL_START)
}

public plugin_init()
{
    register_plugin("DOD Adv Messages","0.0","America")


    // start Spingame
    register_clcmd("say /spin","Spingame_Start")


    register_clcmd("say", "Chat_msg_P")
    register_clcmd("say_team", "Chat_msg_P")


   
    // set_task(2.4, "spin_admin_check", 1)


}


public Spingame_Start(idx_player)
{   
    if(!is_game_active)
    {   
        // Заполнить массив для начала игры 
        is_game_active = true
        g_spingame_curbets = 0
        for (new id = 0; id < get_maxplayers() + 1 ; id ++)
        {
            g_spingame_player_bet[id]=-1
            move_player_to_team(id, 3)
        }

        client_cmd(0, "spk %s",S_ROLL_START)
        set_task(TASK_INTERVAL, "Spingame_Rotate", _, _, _, "b") //

    }

}


public Spingame_Rotate(idx_player)
{
    g_spingame_iteration++
    g_spingame_target_value = random_num(0, 20)


    if(g_spingame_iteration > ROLL_TRYS)
    {   
        g_spingame_iteration = 0
        remove_task(idx_player)
        is_game_active = false
        Spingame_Check_Values()   
    }

    Spingame_Hud_Monitor()
}


public Chat_msg_P(idx_player)
{   
    if(is_game_active) // проверили режим игры
    {   
        new text[12] // взяли текстовый массив , что бы взять из чата текст
        read_argv(1, text, charsmax(text))
        new value = str_to_num(text) // получили значение.
        
        if (is_str_num(text))
        {
        g_spingame_curbets = 0 // обнуляем счётчик количества ставок для подсчёта
        
        // ПРОВЕРИМ КОЛИЧЕСТВО ЗАНЯТЫХ ЯЧЕЕК
        for(new id = 0 ; id < get_maxplayers()+1 ; id++)
        {
            if(g_spingame_player_bet[id]!=-1)
            {
                g_spingame_curbets++
            }
        }

        
        if(g_spingame_curbets<g_spingame_maxbets)
        {   
            if(g_spingame_player_bet[idx_player]==-1)
            {
                // // ЕСЛИ ЕЩЁ ЕСТЬ ЯЧЕЙКА, ПИШЕМСЯ. записываем ставку
                g_spingame_player_bet[idx_player] = clamp(value, 0 , g_spingame_value_diapason)
                client_print(0, print_chat,"STAVKA SDELANA-++")
                // g_spingame_player_bet[idx_player+1] = random_num(1,19) // debug

            }
            else if(can_player_update_his_bet)
            {
                g_spingame_player_bet[idx_player] = clamp(value, 0 , g_spingame_value_diapason)
                client_print(0, print_chat," BETS  update")
            }  
        }
        else 
        {   
            if(can_player_update_his_bet && g_spingame_player_bet[idx_player]!=-1)
            {
                g_spingame_player_bet[idx_player] = clamp(value, 0 , g_spingame_value_diapason)
                client_print(0, print_chat,"Bet Updated")
            }
            else 
            {
                client_print(0, print_chat,"All bets complete")
                
            }
    
        }

        }
       
    }
    g_spingame_curbets = 0
    // ПРОВЕРИМ КОЛИЧЕСТВО ЗАНЯТЫХ ЯЧЕЕК
    for(new id = 0 ; id < get_maxplayers()+1 ; id++)
    {
    if(g_spingame_player_bet[id]!=-1)
    {
        g_spingame_curbets++
    }
    }
    return PLUGIN_CONTINUE
}



public Spingame_Check_Values()
{
    client_print(0 , print_chat, "Spingame_Check_Values run")
    if(g_spingame_curbets==0)
    {
        client_print(0 , print_chat, "spingame failed")
    }
    else 
    {
    
    // Находим строку с ближайшим числом
    new closest_index = 0;
    
    new closest_distance = g_spingame_value_diapason+1
    
    for(new id = 0 ; id < get_maxplayers()+1 ; id++)
    {
        if(g_spingame_player_bet[id]!=-1)
        {
        new distance = abs(g_spingame_player_bet[id] - g_spingame_target_value);
        if (distance <= closest_distance)
            {   

                g_idx_captain[WINNER] = id
                g_idx_captain[LOSER] = closest_index

                closest_index = id;
                closest_distance = distance;

                

                // debug
                is_g_choosegame_mode_team_and_player = false
                if((g_idx_captain[WINNER]!=g_idx_captain[LOSER]) && ( closest_distance == 0))
                {
                    is_g_choosegame_mode_team_and_player = true
                }
            }
        }
    }

    

    new text_msg[128]
    new winner_name[32]
    get_user_name(closest_index, winner_name, charsmax(winner_name))
    
    format(text_msg, charsmax(text_msg), "Check_Values:  Winner: %s, bet: %d , target_spin: %d", winner_name, g_spingame_player_bet[closest_index] , g_spingame_target_value )

    if (is_g_choosegame_mode_team_and_player)
    {
        /// WOW 
    }
    client_print(0 , print_chat, "%s" , text_msg)
    server_print(text_msg)
    set_dhudmessage(0, 1, 255, 0.2 , 0.6 , 0 , 0.0 , 4.4 , 0.2, 0.2 )
    show_dhudmessage(0, text_msg)
    //// опредедлился победитель вывод информации. выбор режима 
    Choosegame_start()
    }            
}


public Spingame_Hud_Monitor()
{
    new text_msg[128], player_name[32]
    
    for(new id = 0 ; id < get_maxplayers()+1 ; id++)
    {
        if(g_spingame_player_bet[id]!=-1)
        {
        // нашли
        get_user_name(id, player_name, charsmax(player_name))
        format(text_msg, charsmax(text_msg), "%s ^n  %s : %d", text_msg,  player_name , g_spingame_player_bet[id])
        }
    }

    format(text_msg, charsmax(text_msg), "%s ^n Spinvalue: %d", text_msg,  g_spingame_target_value)

    new color_red, color_green

    color_red = clamp( g_spingame_iteration*10 , 0 , 255)
    color_green = clamp( 255 - color_red, 0 , 255)

    if(is_game_active)
    {
        set_dhudmessage(color_red, color_green, 0, HUD_X , HUD_Y , 0 , 0.0 , 0.4 , 0.2, 0.2 )
    }
    else 
    {
        set_dhudmessage(color_red, color_green, 255, HUD_X , HUD_Y , 0 , 0.0 , 6.0 , 0.2, 0.2 )
    }
    show_dhudmessage(0, text_msg)
    
}


///////////////////// 

public Choosegame_start()
{
    new menu = menu_create( "\rChoose Team", "Choosegame_team_menu_click" );
    menu_additem( menu, "Allies", "", 0)
    menu_additem( menu, "Axis", "", 0)
    menu_additem( menu, "Random team", "", 0)
    menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );
    menu_display( g_idx_captain[WINNER], menu, 0 );
}

public Choosegame_team_menu_click(idx_player, menu, item)
{

    item++
    switch (item)
    {
        case 1:
        {
            g_player_to_team[g_idx_captain[WINNER]] = ALLIES
        }
        case 2:
        {
            g_player_to_team[g_idx_captain[WINNER]] = AXIS
        }
        default:
        {
            g_player_to_team[g_idx_captain[WINNER]] = random_num(1,2)
        }
    }
    client_print(0 , print_chat, "menu Item: %d", item)
    menu_destroy(menu)

    g_swither_show_menu_to = LOSER

    if(is_g_choosegame_mode_team_and_player)
    {
        g_swither_show_menu_to = WINNER
    }
    Choosegame_player_menu()
}


public Choosegame_player_menu()
{
    new menu = menu_create( "\rChoose player to your team", "Choosegame_player_menu_click" )

    // find not sorted players
    new counter
    for(new id = 1 ; id < get_maxplayers()+1 ; id++)
    {

        if ((g_player_to_team[id] < 1) && is_user_connected(id))
        {   
            new p_name[32]
            new s_num[4]

            num_to_str(id, s_num, charsmax(s_num))
            get_user_name(id, p_name, charsmax(p_name))
            menu_additem( menu, p_name , s_num, 0)
            counter++
        }
    }
    if(counter == 0)
    {
        Choosegame_end_and_start_mm()
        return PLUGIN_CONTINUE
    }
    menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );

    new show_to_id = g_idx_captain[g_swither_show_menu_to]
    menu_display( show_to_id, menu, 0 )
    return 1
}

public Choosegame_player_menu_click(idx_player, menu, item)
{
    new m_Data[64], m_Name[64], i_Access, i_Callback;
    menu_item_getinfo(menu, item, i_Access, m_Data, charsmax(m_Data), m_Name, charsmax(m_Name), i_Callback);

    client_print(0, print_chat, " MDATA %s MNAME %s", m_Data , m_Name)
    
    g_player_to_team[str_to_num(m_Data)] = 1
    menu_destroy(menu)
    switch (g_swither_show_menu_to)
    {
        case WINNER: g_swither_show_menu_to = WINNER
        case LOSER: g_swither_show_menu_to = WINNER
    }

    Choosegame_player_menu()

}

public Choosegame_end_and_start_mm()
{   
    for(new id = 1 ; id < get_maxplayers()+1 ; id++)
    {
        move_player_to_team(id, g_player_to_team[id])
    }
    restart_round()
}

stock move_player_to_team(idx_player, team)
{       
     // Как с помощью amxx в Dayf Of Defeat переместить игрока за спектаторов в плагине 
    // server_cmd("kick %d Spectator", idx_player)
    if(is_user_bot(idx_player))
    {
       server_cmd("kick #%d", idx_player)
    }

    
   

   
   
	switch (team)
	{
		case ALLIES:
            {
			    client_cmd(idx_player, "jointeam 1")
            }
        case AXIS:
            {
                client_cmd(idx_player, "jointeam 2")
            }
        case 3:
            {
                client_cmd(idx_player, "jointeam 3")
                set_user_spectator(idx_player)
                engclient_cmd(idx_player, "kill")

                set_pev(idx_player, pev_flags, pev(idx_player, pev_flags) | FL_SPECTATOR);

                entity_set_int(idx_player, EV_INT_team, 3);
                // dod_set_user_team(idx_player, 0, 0)
                pev(idx_player, pev_team , 3)
            }
        default: 
            {
                client_cmd(idx_player, "jointeam 3")
                set_user_spectator(idx_player)
                engclient_cmd(idx_player, "kill")

                set_pev(idx_player, pev_flags, pev(idx_player, pev_flags) | FL_SPECTATOR);

                entity_set_int(idx_player, EV_INT_team, 3);
                // dod_set_user_team(idx_player, 0, 0)
                pev(idx_player, pev_team , 3)
            }
	}
}



public menu_players_list(idx_player)
{   
    new menu = menu_create( "\rChoose player to your team", "menu_players_list_click" )

    // find not sorted players
    for(new id = 0 ; id < get_maxplayers()+1 ; id++)
    {
    
    if (g_player_to_team[id] == 0)
        {   
            new p_name[32]
            new s_num[4]

            num_to_str(id, s_num, charsmax(s_num))
            get_user_name(id, p_name, charsmax(p_name))
            menu_additem( menu, p_name , s_num, 0)
        }
    }
    menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );
    menu_display( idx_player, menu, 0 );
}

public restart_round()
{
    new ent
    new g_master_ent 
    new g_score_ent
	// Find the 'dod_control_point_master' entity
	g_master_ent = fm_find_ent_by_class(g_master_ent, CLASS_MASTER)
	if (!g_master_ent)
		return 1

    
	// Find 2 'dod_score_ent' entities - Fail if less
	for (ent = 0; ent < 2; ent++) {
		g_score_ent = fm_find_ent_by_class(g_score_ent, CLASS_SCORES)
		if (!g_score_ent)
			return 1
	}


    ExecuteHamB(Ham_Use, g_score_ent, g_master_ent, g_master_ent, 3, NEVER)

}


public menu_players_list_click( idx_player, menu, item )
{
	if (item == MENU_EXIT)
    {
		server_print("exit pressed")
		menu_destroy(menu)
		return PLUGIN_CONTINUE
	}

	new m_Data[64], m_Name[64], i_Access, i_Callback
	menu_item_getinfo(menu, item, i_Access, m_Data, charsmax(m_Data), m_Name, charsmax(m_Name), i_Callback)


	server_print("[menu_allmodels_click] item::index_current_model_list %d m_name::mdl name %s data:: empty sz %s ",item, m_Name, m_Data)

	menu_destroy( menu )

    str_to_num(m_Data)

	// получили имя файла из модели, создаём меню если кликнули нужное 
	return PLUGIN_CONTINUE
}


stock set_user_spectator(id)
{
    message_begin(MSG_ALL,get_user_msgid("Spectator"))
    write_byte(id)
    write_byte(1)
    message_end()
}

// ОСТАНОВИЛСЯ НА СТАДИИ НАЧАЛА ИГРЫ ПОСЛЕ ГОЛОСВАНИЙ 




public client_connect(idx_player)
{
	if(is_game_active)
    {
        g_player_to_team[idx_player] = 0
    }
    return PLUGIN_CONTINUE
}

public client_disconnected(idx_player)
{
    if(is_game_active)
    {
        g_player_to_team[idx_player] = 0
        g_spingame_player_bet[idx_player] = -1
    }
    return PLUGIN_CONTINUE
}