#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>
#include <bitsum>
#include <dodx>
#include <dodfun>

#pragma semicolon 1

#define RegisterMenu(%1,%2) register_menucmd(register_menuid(%1), 1023, %2)	

public plugin_init()
{
    server_print("Server Menu");
    register_dictionary("1944menu.txt");
    register_clcmd("say", "Open_MainMenu");

    RegisterMenu("Open_MainMenu", "Close_MainMenu");

}

public Open_MainMenu(id)
{	
    // создаём первое главное основное менюs
    // правая цифра в iBitKeys активирует клавишу, 1<<6  это клавиша 7  (1<<x) x+1 = номер кнопки, 9==0
    new szMenu[512], iBitKeys = (1<<0|1<<1|1<<2|1<<3|1<<9);
    new iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "1944_MENU_MAIN_TITLE");
    // личный Кабинет
    iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \wЛичный кабинет^n");

    // Настройки 
    iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[4] \wНастро\dйки^n");

    // Выход
    formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[0] \w%L", id, "1944_MENU_EXIT");

    server_print("Open_MainMenu");
    return show_menu(id, iBitKeys, szMenu, -1, "Open_MainMenu");	
}

public Close_MainMenu(id, iKey)
{   

    // client_cmd(id, " hud_draw 0");
    server_print(" Key Pressed %d", iKey);
    switch(iKey)
    {	
        case 0: return PLUGIN_HANDLED;
        case 1: return PLUGIN_HANDLED;
        default: return PLUGIN_HANDLED;
    }
    
    return PLUGIN_CONTINUE;
}
