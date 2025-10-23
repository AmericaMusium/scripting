#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <fun>
#include <dodx>
#include <dodfun>
#include <hamsandwich>

#pragma semicolon 1


/*
set_dhudmessage( red = 0, green = 160, blue = 0,
 Float:x = -1.0, Float:y = 0.65, effects = 2, Float:fxtime = 6.0, Float:holdtime = 3.0, 
 Float:fadeintime = 0.1, Float:fadeouttime = 1.5 
*/

#define MAX_LINES 9 // Масимальное количество строк в отдельном окне чата
#define UPDTIME_CHAT 9.0 // Время автосролла чата
#define print_time 2.0 // Не знаю 


// положение чата 
#define HUD_X 0.02 // 0.0 ; 1.0 ; -1=center
#define HUD_Y 0.40 // 0.0  верх; 1.0 низ
#define HUD_S 0.03 // расстояние между строками

#define HUD_FT 9.0 // Длительность медленного затухания сообщения в чате
#define HUD_HOLDTIME 1.0 // Длительность сообщения
new g_colorfade = 1; // редуцирование цвета
new g_fadeinfx = 0; // Файд ин в сообщениях чата попоярдку

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

new g_HUD_SCRL_BAR[MAX_LINES][LINE_DATA];

public plugin_init()
{
     register_plugin("HHS HUD MSG","0.0","America");
     server_print("HUD HUD MSG") ;
     register_clcmd("say", "Say_register");
     register_clcmd("say sp", "spam");
     
     g_colorfade = 1;
     g_fadeinfx = 0;


     //HUD_autoclear_mix()
}


public Say_register(id)
{
     server_print("message hoooked");

     new szMessage[192];
     read_args(szMessage, charsmax( szMessage ));
     remove_quotes(szMessage);
     if(!szMessage[0] || (equal(szMessage[0], " ")))
          return PLUGIN_CONTINUE;
     new i;
     new g_copy;
     for(g_copy = 0 ; g_copy < MAX_LINES-1; g_copy++)
     {
          new g_copyplus = g_copy;
          g_copyplus++;
          // g_HUD_SCRL_BAR[g_copy][msg] = g_HUD_SCRL_BAR[g_copyplus][msg]
          for(i = 0; i < 191; i++)
          { 
               g_HUD_SCRL_BAR[g_copy][msg][i] = g_HUD_SCRL_BAR[g_copyplus][msg][i];
          }
          g_HUD_SCRL_BAR[g_copy][r] = g_HUD_SCRL_BAR[g_copyplus][r];
          g_HUD_SCRL_BAR[g_copy][g] = g_HUD_SCRL_BAR[g_copyplus][g] ;
          g_HUD_SCRL_BAR[g_copy][b] = g_HUD_SCRL_BAR[g_copyplus][b];
          if(g_colorfade == 1) 
          {    
               new rr = g_HUD_SCRL_BAR[g_copy][r]-30;
               new gg = g_HUD_SCRL_BAR[g_copy][g]-30;
               new bb = g_HUD_SCRL_BAR[g_copy][b]-30;
               if(rr < 0) rr = 0;
               if(gg < 0) gg = 0;
               if(bb < 0) bb = 0;

               g_HUD_SCRL_BAR[g_copy][r] = rr;
               g_HUD_SCRL_BAR[g_copy][g] = gg;
               g_HUD_SCRL_BAR[g_copy][b] = bb;
             
          } 
          g_HUD_SCRL_BAR[g_copy][effects] = g_HUD_SCRL_BAR[g_copyplus][effects];
          g_HUD_SCRL_BAR[g_copy][fxtime] = g_HUD_SCRL_BAR[g_copyplus][fxtime];
          g_HUD_SCRL_BAR[g_copy][holdtime] = (g_HUD_SCRL_BAR[g_copyplus][holdtime] - 1.0 ); // - 1.0, 0.0, g_HUD_SCRL_BAR[g_copy][holdtime])
          g_HUD_SCRL_BAR[g_copy][fadeintime] = g_HUD_SCRL_BAR[g_copyplus][fadeintime];
          g_HUD_SCRL_BAR[g_copy][fadeouttime] = (g_HUD_SCRL_BAR[g_copyplus][fadeouttime] - 1.0 );//  - 1.0, 0.0, g_HUD_SCRL_BAR[g_copy][fadeouttime])
     }
     g_HUD_SCRL_BAR[MAX_LINES-1][msg] = szMessage;
     g_HUD_SCRL_BAR[MAX_LINES-1][r] = random_num(60, 254);
     g_HUD_SCRL_BAR[MAX_LINES-1][g] = random_num(60, 254);
     g_HUD_SCRL_BAR[MAX_LINES-1][b] = random_num(60, 254);
     g_HUD_SCRL_BAR[MAX_LINES-1][effects] = 0 ;// random_num(0, 2) просто , мерцание, матрца
     g_HUD_SCRL_BAR[MAX_LINES-1][fxtime] = 1.0 ;// random_float(1.0,2.0)
     g_HUD_SCRL_BAR[MAX_LINES-1][holdtime] = 3.0 ;//random_float(1.0,5.0)
     g_HUD_SCRL_BAR[MAX_LINES-1][fadeintime] = 0.0 ;// random_float(0.0,1.0)
     g_HUD_SCRL_BAR[MAX_LINES-1][fadeouttime] = 6.0 ;// random_float(0.0,1.0)
     // HUD_print_color_mix();

     HUD_print_simple();
     return PLUGIN_CONTINUE;
}

public HUD_print_color_mix()
{
     new str ;// = MAX_LINES-1
     // new float:ypos ;// HUD_S 0.3
     //new float:f_tmp;
     // new float:f_tmpd;
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
     set_dhudmessage(0, 255, 0, 0.3, 0.40 , 0, 6.0, 6.0);
     show_dhudmessage(0, " %s ^n %s ^n %s ^n %s ^n %s ^n %s", g_HUD_SCRL_BAR[0][msg],  g_HUD_SCRL_BAR[1][msg],  g_HUD_SCRL_BAR[2][msg],  g_HUD_SCRL_BAR[3][msg],  g_HUD_SCRL_BAR[4][msg],  g_HUD_SCRL_BAR[5][msg]  );

}

public HUD_autoclear()
{
     new i;
     /// 1 strka
     for(i = 0; i < 191; i++)
     {
          g_HUD_SCRL_BAR[0][msg][i] = g_HUD_SCRL_BAR[1][msg][i];
     }
     for(i = 0; i < 191; i++)
     {
          g_HUD_SCRL_BAR[1][msg][i] = g_HUD_SCRL_BAR[2][msg][i];
     }
     for(i = 0; i < 191; i++)
     {
          g_HUD_SCRL_BAR[2][msg][i] = g_HUD_SCRL_BAR[3][msg][i];
     }
     for(i = 0; i < 191; i++)
     {
          g_HUD_SCRL_BAR[3][msg][i] = g_HUD_SCRL_BAR[4][msg][i];
     }
     for(i = 0; i < 191; i++)
     {
          g_HUD_SCRL_BAR[4][msg][i] = g_HUD_SCRL_BAR[5][msg][i];
     }
     g_HUD_SCRL_BAR[5][msg] = " ";
        // HUD_print_simple()
        // set_task(UPDTIME_CHAT,"HUD_autoclear")
}

public HUD_autoclear_mix()
{
     new i;
     new g_copy;
     for(g_copy = 0 ; g_copy < MAX_LINES-1; g_copy++)
     {
          new g_copyplus = g_copy;
          g_copyplus++;
          // g_HUD_SCRL_BAR[g_copy][msg] = g_HUD_SCRL_BAR[g_copyplus][msg]
          for(i = 0; i < 191; i++)
          { 
               g_HUD_SCRL_BAR[g_copy][msg][i] = g_HUD_SCRL_BAR[g_copyplus][msg][i];
          }
          g_HUD_SCRL_BAR[g_copy][r] = g_HUD_SCRL_BAR[g_copyplus][r];
          g_HUD_SCRL_BAR[g_copy][g] = g_HUD_SCRL_BAR[g_copyplus][g];
          g_HUD_SCRL_BAR[g_copy][b] = g_HUD_SCRL_BAR[g_copyplus][b];
          g_HUD_SCRL_BAR[g_copy][effects] = g_HUD_SCRL_BAR[g_copyplus][effects];
          g_HUD_SCRL_BAR[g_copy][fxtime] = g_HUD_SCRL_BAR[g_copyplus][fxtime];
          g_HUD_SCRL_BAR[g_copy][holdtime] = g_HUD_SCRL_BAR[g_copyplus][holdtime];
          g_HUD_SCRL_BAR[g_copy][fadeintime] = g_HUD_SCRL_BAR[g_copyplus][fadeintime];
          g_HUD_SCRL_BAR[g_copy][fadeouttime] = g_HUD_SCRL_BAR[g_copyplus][fadeouttime];

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



