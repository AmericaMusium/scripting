#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>
#include <fun>
#include <dodx>
#include <dodfun>
#include <hamsandwich>
#include <dhudmessage>


#define MAX_LINES 7 // Масимальное количество строк в отдельном окне чата
#define HUD_UPDATE_TIME 9.0 // Время автосролла чата
#define HUD_PRINT_TIME 2.0 // Не знаю 

// положение чата 
#define HUD_X 0.02 // 0.0 ; 1.0 ; -1=center
#define HUD_Y 0.40 // 0.0  верх; 1.0 низ
#define HUD_S 0.03 // расстояние между строками

#define HUD_FT 9.0 // Длительность медленного затухания сообщения в чате
#define HUD_HOLDTIME 1.0 // Длительность сообщения

enum _:CLASSES
{
    zero,
    soldier,
    medic,
    mgguner,
    engineer,
    builder
}
enum _:LINE_DATA
{
     msg[192],
     r,
     g,
     b,
     effects,
     Float:fxtime,
     Float:holdtime,
     Float:fadeintime,
     Float:fadeouttime
}

new g_HUD_Allies_bar[CLASSES][LINE_DATA]
new g_HUD_Axis[CLASSES][LINE_DATA]

public plugin_init()
{
	register_plugin("DOD HUD Stats Bar","0.0","America")
    server_print("DOD HUD Stats Bar")

    register_clcmd("weapon_spade","slot1_post") // вместо slot1 он отправляен класснэйм птр предмета в инвентаре
    
    
}

public plugin_precache()
{
	// precache_model( g_award_cam_model ) 
}

public slot1_post()
{
    client_print(0, print_chat, "iOrigin:")
}



/* В первой строке отображает инфа основная. 
строка 
Солдат-Захватчик
Пулеметчик: патроны 
Артеллирист: Патроны
Захватчик: здоровье. + расстояние до ближ флага
Строитель: стройматериалы
Медик комлпекты оздоровления
Доставщик Инвентарь 

*/



public HUD_print_mix()
{
     new str // = MAX_LINES-1
     for(str = CLASSES-1; str >= 0; str-- )
     {    
          set_dhudmessage(g_HUD_Allies_bar[str][r],g_HUD_Allies_bar[str][g],g_HUD_Allies_bar[str][b], HUD_X , (HUD_Y + (HUD_S * float(str))) , g_HUD_Allies_bar[str][effects], g_HUD_Allies_bar[str][fxtime], g_HUD_Allies_bar[str][holdtime], g_HUD_Allies_bar[str][fadeintime], g_HUD_Allies_bar[str][fadeouttime], true)
          show_dhudmessage(0, g_HUD_Allies_bar[str][msg])
     }

}


public HUD_info_update()
{





}