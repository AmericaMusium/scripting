#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <fun>
#include <dodx>
#include <dodfun>
#include <hamsandwich>

enum _:COLOR_ARRAY_SIZE
{
     color_r, 
     color_g,
     color_b,
     a_effects,
     Float:a_fxtime,
     Float:a_holdtime,
     Float:a_fadeintime,
     Float:a_fadeouttime
}
enum _:COLOR_TYPE
{
     basic, // == 0
     basic_plus,
     medium,
     hard,
     top,
     allies,
     axis
}
new HWCT[COLOR_TYPE][COLOR_ARRAY_SIZE];

// охуеевшее переопделеение 
#define HUD_HELP2   255, 255, 0, -1.0, 0.25, 2, 1.0, 1.5, .fadeintime = 0.03
public Define_Widget_Colors()
{
     // basic  
     // 0 . 1 . 2 . 3, - 9 ;;; 
     HWCT[basic][color_r] = 255
     HWCT[basic][color_g] = 255
     HWCT[basic][color_b] = 255
     HWCT[basic][a_effects] = 0 // random_num(0, 2) просто , мерцание, матрца
     HWCT[basic][a_fxtime] = 0.0 // random_float(1.0,2.0)
     HWCT[basic][a_holdtime] = 3.0 //random_float(1.0,5.0)
     HWCT[basic][a_fadeintime] = 0.5 // random_float(0.0,1.0)
     HWCT[basic][a_fadeouttime] = 6.0 // random_float(0.0,1.0)
     // basic_plus
     HWCT[basic_plus][color_r] = 255
     HWCT[basic_plus][color_g] = 255
     HWCT[basic_plus][color_b] = 120
     HWCT[basic_plus][a_effects] = 1 // random_num(0, 2) просто , мерцание, матрца
     HWCT[basic_plus][a_fxtime] = 4.0 // random_float(1.0,2.0)
     HWCT[basic_plus][a_holdtime] = 3.0 //random_float(1.0,5.0)
     HWCT[basic_plus][a_fadeintime] = 0.0 // random_float(0.0,1.0)
     HWCT[basic_plus][a_fadeouttime] = 6.0 // random_float(0.0,1.0)
     // medium
     HWCT[medium][color_r] = 60
     HWCT[medium][color_g] = 100
     HWCT[medium][color_b] = 100
     HWCT[medium][a_effects] = 0 // random_num(0, 2) просто , мерцание, матрца
     HWCT[medium][a_fxtime] = 1.0 // random_float(1.0,2.0)
     HWCT[medium][a_holdtime] = 3.0 //random_float(1.0,5.0)
     HWCT[medium][a_fadeintime] = 0.0 // random_float(0.0,1.0)
     HWCT[medium][a_fadeouttime] = 6.0 // random_float(0.0,1.0)
     // hard
     HWCT[hard][color_r] = 160
     HWCT[hard][color_g] = 100
     HWCT[hard][color_b] = 0
     HWCT[hard][a_effects] = 0 // random_num(0, 2) просто , мерцание, матрца
     HWCT[hard][a_fxtime] = 2.0 // random_float(1.0,2.0)
     HWCT[hard][a_holdtime] = 3.0 //random_float(1.0,5.0)
     HWCT[hard][a_fadeintime] = 0.0 // random_float(0.0,1.0)
     HWCT[hard][a_fadeouttime] = 6.0 // random_float(0.0,1.0)
     // top
     HWCT[top][color_r] = 255
     HWCT[top][color_g] = 0
     HWCT[top][color_b] = 255
     HWCT[top][a_effects] = 1 // random_num(0, 2) просто , мерцание, матрца
     HWCT[top][a_fxtime] = 1.0 // random_float(1.0,2.0)
     HWCT[top][a_holdtime] = 3.0 //random_float(1.0,5.0)
     HWCT[top][a_fadeintime] = 0.0 // random_float(0.0,1.0)
     HWCT[top][a_fadeouttime] = 6.0 // random_float(0.0,1.0)
     // allies
     HWCT[allies][color_r] = 0
     HWCT[allies][color_g] = 255
     HWCT[allies][color_b] = 0
     HWCT[allies][a_effects] = 0 // random_num(0, 2) просто , мерцание, матрца
     HWCT[allies][a_fxtime] = 0.0 // random_float(1.0,2.0)
     HWCT[allies][a_holdtime] = 3.0 //random_float(1.0,5.0)
     HWCT[allies][a_fadeintime] = 0.5 // random_float(0.0,1.0)
     HWCT[allies][a_fadeouttime] = 6.0 // random_float(0.0,1.0)
     // axis
     HWCT[axis][color_r] = 255
     HWCT[axis][color_g] = 0
     HWCT[axis][color_b] = 0
     HWCT[axis][a_effects] = 0 // random_num(0, 2) просто , мерцание, матрца
     HWCT[axis][a_fxtime] = 0.0 // random_float(1.0,2.0)
     HWCT[axis][a_holdtime] = 3.0 //random_float(1.0,5.0)
     HWCT[axis][a_fadeintime] = 0.5 // random_float(0.0,1.0)
     HWCT[axis][a_fadeouttime] = 6.0 // random_float(0.0,1.0)
}

#pragma semicolon 1
#define MAX_LINES 8 // Масимальное количество строк в отдельном окне чата 8
#define MAX_CHARS 192 // Масимальное количество строк в отдельном окне чата 8
#define UPDTIME_CHAT 9.0 // Время автосролла чата
#define print_time 2.0 // 

// положение чата 
#define HUD_X 0.01 // 0.0 ; 1.0 ; -1=center
#define HUD_Y 0.18 // 0.0  верх; 1.0 низ
#define HUD_S 0.02 // расстояние между строками

#define HUD_FADEOUT 25
new g_colorfade = 1; // редуцирование цвета
new g_fadeinfx = 0; // Файд ин в сообщениях чата попоярдку

enum _:LINE_DATA
{
     msg[MAX_CHARS],
     r,
     g,
     b,
     effects,
     Float:fxtime,
     Float:holdtime,
     Float:fadeintime,
     Float:fadeouttime
}

new g_HUD_SCRL_BAR[MAX_LINES+1][LINE_DATA];

public plugin_init()
{
     register_plugin("HHS HUD MSG","0.0","America");
     server_print("HUD HUD MSG") ;
     register_clcmd("say", "Say_register");
     register_clcmd("say sp", "spam");
     
     g_colorfade = 1;
     g_fadeinfx = 0;
     Define_Widget_Colors();
     plugin_natives();


}

// Регистрируем функцию как native для других плагинов
public plugin_natives()
{
     register_native("HW_income_message_native", "HW_income_message");
}



public Say_register(id)
{
     new szMessage[192];
     read_args(szMessage, charsmax( szMessage ));
     remove_quotes(szMessage);
     HW_Message_Print(szMessage , random_num(0,6));
     return PLUGIN_CONTINUE;
     if(!szMessage[0] || (equal(szMessage[0], " ")))
          return PLUGIN_CONTINUE;
     new i;
     new line_string_num;
     for(line_string_num = 0 ; line_string_num < MAX_LINES; line_string_num++)
     {    
          
          new line_string_numplus = line_string_num + 1;

          copy(g_HUD_SCRL_BAR[line_string_num][msg][i], MAX_CHARS-1, g_HUD_SCRL_BAR[line_string_numplus][msg][i]);
          /* старый способ ручного посимвольного копипрования.
          for(i = 0; i < MAX_CHARS-1; i++)
          { 
               g_HUD_SCRL_BAR[line_string_num][msg][i] = g_HUD_SCRL_BAR[line_string_numplus][msg][i];
          }
          */
          g_HUD_SCRL_BAR[line_string_num][r] = g_HUD_SCRL_BAR[line_string_numplus][r];
          g_HUD_SCRL_BAR[line_string_num][g] = g_HUD_SCRL_BAR[line_string_numplus][g] ;
          g_HUD_SCRL_BAR[line_string_num][b] = g_HUD_SCRL_BAR[line_string_numplus][b];
          if(g_colorfade == 1) 
          {    
               new rr = g_HUD_SCRL_BAR[line_string_num][r]-1;
               new gg = g_HUD_SCRL_BAR[line_string_num][g]-1;
               new bb = g_HUD_SCRL_BAR[line_string_num][b]-1;
               if(rr < 0) rr = 0;
               if(gg < 0) gg = 0;
               if(bb < 0) bb = 0;

               g_HUD_SCRL_BAR[line_string_num][r] = rr;
               g_HUD_SCRL_BAR[line_string_num][g] = gg;
               g_HUD_SCRL_BAR[line_string_num][b] = bb;
             
          }
          g_HUD_SCRL_BAR[line_string_num][effects] = g_HUD_SCRL_BAR[line_string_numplus][effects];
          g_HUD_SCRL_BAR[line_string_num][fxtime] = g_HUD_SCRL_BAR[line_string_numplus][fxtime];
          g_HUD_SCRL_BAR[line_string_num][holdtime] = (g_HUD_SCRL_BAR[line_string_numplus][holdtime]); // - 1.0, 0.0, g_HUD_SCRL_BAR[line_string_num][holdtime])
          g_HUD_SCRL_BAR[line_string_num][fadeintime] = g_HUD_SCRL_BAR[line_string_numplus][fadeintime];
          g_HUD_SCRL_BAR[line_string_num][fadeouttime] = (g_HUD_SCRL_BAR[line_string_numplus][fadeouttime]);//  - 1.0, 0.0, g_HUD_SCRL_BAR[line_string_num][fadeouttime])
     }
     // Заполняем массив наисвежайшей строкой
     copy(g_HUD_SCRL_BAR[MAX_LINES-1][msg], MAX_CHARS-1, szMessage);
     g_HUD_SCRL_BAR[MAX_LINES-1][r] = random_num(60, 254);
     g_HUD_SCRL_BAR[MAX_LINES-1][g] = random_num(60, 254);
     g_HUD_SCRL_BAR[MAX_LINES-1][b] = random_num(60, 254);
     g_HUD_SCRL_BAR[MAX_LINES-1][effects] = 0 ;// random_num(0, 2) просто , мерцание, матрца
     g_HUD_SCRL_BAR[MAX_LINES-1][fxtime] = 1.0 ;// random_float(1.0,2.0)
     g_HUD_SCRL_BAR[MAX_LINES-1][holdtime] = 3.0 ;//random_float(1.0,5.0)
     g_HUD_SCRL_BAR[MAX_LINES-1][fadeintime] = 0.0 ;// random_float(0.0,1.0)
     g_HUD_SCRL_BAR[MAX_LINES-1][fadeouttime] = 6.0 ;// random_float(0.0,1.0)
     HUD_print_color_mix();

     return PLUGIN_CONTINUE;
}

public HUD_print_color_mix()
{
     new str;
     for(str = MAX_LINES-1; str >= 0; str-- )
     {    
          if(g_fadeinfx == 1)
          {
               new Float: fin = g_HUD_SCRL_BAR[str][fadeintime];
               fin = float((MAX_LINES-1)-str)*0.05;
               g_HUD_SCRL_BAR[str][fadeintime] = fin;
          }
     
          set_dhudmessage(g_HUD_SCRL_BAR[str][r],g_HUD_SCRL_BAR[str][g],g_HUD_SCRL_BAR[str][b], HUD_X , (HUD_Y + (HUD_S * float(str))) , g_HUD_SCRL_BAR[str][effects], g_HUD_SCRL_BAR[str][fxtime], g_HUD_SCRL_BAR[str][holdtime], g_HUD_SCRL_BAR[str][fadeintime], g_HUD_SCRL_BAR[str][fadeouttime]);
          show_dhudmessage(0, g_HUD_SCRL_BAR[str][msg]);
     }

}

public HUD_print_simple()
{
    // 0.60 = 6я строка

     // set_dhudmessage(255, 255, 0, -1.0, 0.22, 1, 10.0, 10.0, 2.0, 2.0);
     // set_dhudmessage(0, 255, 0, 0.3, 0.40 , 0, 6.0, 6.0);
     // show_dhudmessage(0, " %s ^n %s ^n %s ^n %s ^n %s ^n %s", g_HUD_SCRL_BAR[0][msg],  g_HUD_SCRL_BAR[1][msg],  g_HUD_SCRL_BAR[2][msg],  g_HUD_SCRL_BAR[3][msg],  g_HUD_SCRL_BAR[4][msg],  g_HUD_SCRL_BAR[5][msg]  );

}

public HUD_autoclear()
{
     new i;
     /// 1 strka
     /*
     for(i = 0; i < MAX_CHARS-1; i++)
     {
          g_HUD_SCRL_BAR[0][msg][i] = g_HUD_SCRL_BAR[1][msg][i];
     }
     for(i = 0; i < MAX_CHARS-1; i++)
     {
          g_HUD_SCRL_BAR[1][msg][i] = g_HUD_SCRL_BAR[2][msg][i];
     }
     for(i = 0; i < MAX_CHARS-1; i++)
     {
          g_HUD_SCRL_BAR[2][msg][i] = g_HUD_SCRL_BAR[3][msg][i];
     }
     for(i = 0; i < MAX_CHARS-1; i++)
     {
          g_HUD_SCRL_BAR[3][msg][i] = g_HUD_SCRL_BAR[4][msg][i];
     }
     for(i = 0; i < MAX_CHARS-1; i++)
     {
          g_HUD_SCRL_BAR[4][msg][i] = g_HUD_SCRL_BAR[5][msg][i];
     }
     g_HUD_SCRL_BAR[5][msg] = " ";
     */
        // HUD_print_simple()
        // set_task(UPDTIME_CHAT,"HUD_autoclear")
}

public HUD_autoclear_mix()
{
     new i;
     new line_string_num;
     for(line_string_num = 0 ; line_string_num < MAX_LINES-1; line_string_num++)
     {
          new line_string_numplus = line_string_num + 1;
          // g_HUD_SCRL_BAR[line_string_num][msg] = g_HUD_SCRL_BAR[line_string_numplus][msg]
          for(i = 0; i < MAX_CHARS-1; i++)
          { 
               g_HUD_SCRL_BAR[line_string_num][msg][i] = g_HUD_SCRL_BAR[line_string_numplus][msg][i];
          }
          g_HUD_SCRL_BAR[line_string_num][r] = g_HUD_SCRL_BAR[line_string_numplus][r];
          g_HUD_SCRL_BAR[line_string_num][g] = g_HUD_SCRL_BAR[line_string_numplus][g];
          g_HUD_SCRL_BAR[line_string_num][b] = g_HUD_SCRL_BAR[line_string_numplus][b];
          g_HUD_SCRL_BAR[line_string_num][effects] = g_HUD_SCRL_BAR[line_string_numplus][effects];
          g_HUD_SCRL_BAR[line_string_num][fxtime] = g_HUD_SCRL_BAR[line_string_numplus][fxtime];
          g_HUD_SCRL_BAR[line_string_num][holdtime] = g_HUD_SCRL_BAR[line_string_numplus][holdtime];
          g_HUD_SCRL_BAR[line_string_num][fadeintime] = g_HUD_SCRL_BAR[line_string_numplus][fadeintime];
          g_HUD_SCRL_BAR[line_string_num][fadeouttime] = g_HUD_SCRL_BAR[line_string_numplus][fadeouttime];

     }
     g_HUD_SCRL_BAR[MAX_LINES-1][msg] = " ";
     // HUD_print_color_mix()
     set_task(UPDTIME_CHAT,"HUD_autoclear_mix");
}


public spam()
{

     for (new i = 0; i < 12; i++)
     {
          new szMessage[64];
          formatex(szMessage, sizeof(szMessage), "Message DHUD #%d", i);
          
          g_HUD_SCRL_BAR[i][msg] = szMessage;
          g_HUD_SCRL_BAR[i][r] = random_num(60, 254);
          g_HUD_SCRL_BAR[i][g] = random_num(60, 254);
          g_HUD_SCRL_BAR[i][b] = random_num(60, 254);
          g_HUD_SCRL_BAR[i][effects] = 0;// random_num(0, 2) просто , мерцание, матрца
          g_HUD_SCRL_BAR[i][fxtime] = 1.0 ;// random_float(1.0,2.0)
          g_HUD_SCRL_BAR[i][holdtime] = 3.0 ;//random_float(1.0,5.0)
          g_HUD_SCRL_BAR[i][fadeintime] = 0.0 ;// random_float(0.0,1.0)
          g_HUD_SCRL_BAR[i][fadeouttime] = 6.0 ;// random_float(0.0,1.0)

          //set_dhudmessage(g_HUD_SCRL_BAR[i][r], g_HUD_SCRL_BAR[i][g], g_HUD_SCRL_BAR[i][b], HUD_X, (HUD_Y + (HUD_S * float(i))), g_HUD_SCRL_BAR[i][effects], g_HUD_SCRL_BAR[i][fxtime], g_HUD_SCRL_BAR[i][holdtime], g_HUD_SCRL_BAR[i][fadeintime], g_HUD_SCRL_BAR[i][fadeouttime], true)
          set_dhudmessage(g_HUD_SCRL_BAR[i][r], g_HUD_SCRL_BAR[i][g], g_HUD_SCRL_BAR[i][b], random_float(0.1,0.9),random_float(0.1,0.9), g_HUD_SCRL_BAR[i][effects], g_HUD_SCRL_BAR[i][fxtime], g_HUD_SCRL_BAR[i][holdtime], g_HUD_SCRL_BAR[i][fadeintime], g_HUD_SCRL_BAR[i][fadeouttime]);
        
          show_dhudmessage(0, szMessage);
     }

     for (new i = 0; i < 12; i++)
     {
          new szMessage[64];
          formatex(szMessage, sizeof(szMessage), "Message HUD #%d", i);

          g_HUD_SCRL_BAR[i][msg] = szMessage;
          g_HUD_SCRL_BAR[i][r] = random_num(60, 254);
          g_HUD_SCRL_BAR[i][g] = random_num(60, 254);
          g_HUD_SCRL_BAR[i][b] = random_num(60, 254);
          g_HUD_SCRL_BAR[i][effects] = 0 ;// random_num(0, 2) просто , мерцание, матрца
          g_HUD_SCRL_BAR[i][fxtime] = 1.0 ;// random_float(1.0,2.0)
          g_HUD_SCRL_BAR[i][holdtime] = 3.0 ;//random_float(1.0,5.0)
          g_HUD_SCRL_BAR[i][fadeintime] = 0.0; // random_float(0.0,1.0)
          g_HUD_SCRL_BAR[i][fadeouttime] = 6.0; // random_float(0.0,1.0)

   
          set_hudmessage(0, 222,50, -1.0, 0.23, 1, 6.0, 6.0, 1.0, 1.0, 4);
          show_hudmessage(0, szMessage);
     }
}



/// приёмник сообщений 
public HW_Message_Print(const sz_Message[], const this_type)
{
     // принимаем соообщение, двигаем массив
     new line_string_num;

     for(line_string_num = 0 ; line_string_num < MAX_LINES-1; line_string_num++)
     {    
          new line_string_numplus = line_string_num + 1;
          // server_print("line_string_num %d | line_string_numplus %d | MAX_LINES %d |", line_string_num, line_string_numplus, MAX_LINES);
          copy(g_HUD_SCRL_BAR[line_string_num][msg], MAX_CHARS-1, g_HUD_SCRL_BAR[line_string_numplus][msg]);
          /* старый способ ручного посимвольного копипрования.
          for(new i = 0; i < MAX_CHARS-1; i++)
          { 
               g_HUD_SCRL_BAR[line_string_num][msg][i] = g_HUD_SCRL_BAR[line_string_numplus][msg][i];
          }
          */
          g_HUD_SCRL_BAR[line_string_num][r] = g_HUD_SCRL_BAR[line_string_numplus][r];
          g_HUD_SCRL_BAR[line_string_num][g] = g_HUD_SCRL_BAR[line_string_numplus][g];
          g_HUD_SCRL_BAR[line_string_num][b] = g_HUD_SCRL_BAR[line_string_numplus][b];
          switch (g_colorfade)
          {
               case 1:
               {
                    g_HUD_SCRL_BAR[line_string_num][r] = clamp(g_HUD_SCRL_BAR[line_string_num][r]-HUD_FADEOUT, 0, 254);
                    g_HUD_SCRL_BAR[line_string_num][g] = clamp(g_HUD_SCRL_BAR[line_string_num][g]-HUD_FADEOUT, 0, 254);
                    g_HUD_SCRL_BAR[line_string_num][b] = clamp(g_HUD_SCRL_BAR[line_string_num][b]-HUD_FADEOUT, 0, 254);
               }
               case 2:
               {    
                    new rr = g_HUD_SCRL_BAR[line_string_num][r]-HUD_FADEOUT;
                    new gg = g_HUD_SCRL_BAR[line_string_num][g]-HUD_FADEOUT;
                    new bb = g_HUD_SCRL_BAR[line_string_num][b]-HUD_FADEOUT;
                    if(rr < 0) rr = 0;
                    if(gg < 0) gg = 0;
                    if(bb < 0) bb = 0;

                    g_HUD_SCRL_BAR[line_string_num][r] = rr;
                    g_HUD_SCRL_BAR[line_string_num][g] = gg;
                    g_HUD_SCRL_BAR[line_string_num][b] = bb;
               
               }
          }
          g_HUD_SCRL_BAR[line_string_num][effects] = g_HUD_SCRL_BAR[line_string_numplus][effects];
          g_HUD_SCRL_BAR[line_string_num][fxtime] = g_HUD_SCRL_BAR[line_string_numplus][fxtime];
          g_HUD_SCRL_BAR[line_string_num][holdtime] = g_HUD_SCRL_BAR[line_string_numplus][holdtime]-0.5;  // - 1.0, 0.0, g_HUD_SCRL_BAR[line_string_num][holdtime])
          g_HUD_SCRL_BAR[line_string_num][fadeintime] = g_HUD_SCRL_BAR[line_string_numplus][fadeintime]+0.5; 
          g_HUD_SCRL_BAR[line_string_num][fadeouttime] = g_HUD_SCRL_BAR[line_string_numplus][fadeouttime]-0.5; //  - 1.0, 0.0, g_HUD_SCRL_BAR[line_string_num][fadeouttime])
     }
     // Заполняем массив наисвежайшей строкой
     copy(g_HUD_SCRL_BAR[MAX_LINES-1][msg], MAX_CHARS-1, sz_Message);
     g_HUD_SCRL_BAR[MAX_LINES-1][r] = HWCT[this_type][color_r];
     g_HUD_SCRL_BAR[MAX_LINES-1][g] = HWCT[this_type][color_g];
     g_HUD_SCRL_BAR[MAX_LINES-1][b] = HWCT[this_type][color_b];
     g_HUD_SCRL_BAR[MAX_LINES-1][effects] = HWCT[this_type][a_effects]; // random_num(0, 2) просто , мерцание, матрца
     g_HUD_SCRL_BAR[MAX_LINES-1][fxtime] = HWCT[this_type][a_fxtime];// random_float(1.0,2.0)
     g_HUD_SCRL_BAR[MAX_LINES-1][holdtime] = HWCT[this_type][a_holdtime];//random_float(1.0,5.0)
     g_HUD_SCRL_BAR[MAX_LINES-1][fadeintime] = HWCT[this_type][a_fadeintime]; // random_float(0.0,1.0)
     g_HUD_SCRL_BAR[MAX_LINES-1][fadeouttime] = HWCT[this_type][a_fadeouttime]; //
     
     HUD_print_color_mix();
     return PLUGIN_CONTINUE;
}


public HW_income_message(const IncomeMessage[], int_color_type)
{

     // Создаём локальную переменную для хранения строки
     new receivedMessage[192];

     // Копируем переданный массив в локальный
     copy(receivedMessage, charsmax(receivedMessage), IncomeMessage);

     HW_Message_Print(receivedMessage, 2);
}