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
#include <hamsandwich>

#define MAX_LINES 6
enum _:LINE_DATA
{
    msg[192],
    pos,
    status
}
new g_HUD_SCRL_BAR[MAX_LINES][LINE_DATA]
public plugin_init()
{
	register_plugin("HHS HUD MSG","0.0","America")
	server_print("HUD HUD MSG")
    HUD_autoclear()
    register_clcmd("say", "NewSay")
}

public NewSay(id)
{
        new szMessage[192]
        read_args(szMessage, charsmax( szMessage ))
        remove_quotes(szMessage)
        new i
        /// 1 strka
        for(i = 0; i < 191; i++)
        {
             g_HUD_SCRL_BAR[0][msg][i] = g_HUD_SCRL_BAR[1][msg][i]
        }
               for(i = 0; i < 191; i++)
        {
             g_HUD_SCRL_BAR[1][msg][i] = g_HUD_SCRL_BAR[2][msg][i]
        }
                for(i = 0; i < 191; i++)
        {
             g_HUD_SCRL_BAR[2][msg][i] = g_HUD_SCRL_BAR[3][msg][i]
        }
                for(i = 0; i < 191; i++)
        {
             g_HUD_SCRL_BAR[3][msg][i] = g_HUD_SCRL_BAR[4][msg][i]
        }
        for(i = 0; i < 191; i++)
        {
             g_HUD_SCRL_BAR[4][msg][i] = g_HUD_SCRL_BAR[5][msg][i]
        }
        g_HUD_SCRL_BAR[5][msg] = szMessage
        HUD_print()
}

public HUD_print()
{
    // 0.60 = 6я строка
    set_hudmessage(0, 255, 0, 0.0, 0.40 , 0, 6.0, 6.0)
    show_hudmessage(0, "%s ^n %s ^n %s ^n %s ^n %s ^n %s", g_HUD_SCRL_BAR[0][msg],  g_HUD_SCRL_BAR[1][msg],  g_HUD_SCRL_BAR[2][msg],  g_HUD_SCRL_BAR[3][msg],  g_HUD_SCRL_BAR[4][msg],  g_HUD_SCRL_BAR[5][msg]  )

}

public HUD_autoclear()
{
        new i
        /// 1 strka
        for(i = 0; i < 191; i++)
        {
             g_HUD_SCRL_BAR[0][msg][i] = g_HUD_SCRL_BAR[1][msg][i]
        }
               for(i = 0; i < 191; i++)
        {
             g_HUD_SCRL_BAR[1][msg][i] = g_HUD_SCRL_BAR[2][msg][i]
        }
                for(i = 0; i < 191; i++)
        {
             g_HUD_SCRL_BAR[2][msg][i] = g_HUD_SCRL_BAR[3][msg][i]
        }
                for(i = 0; i < 191; i++)
        {
             g_HUD_SCRL_BAR[3][msg][i] = g_HUD_SCRL_BAR[4][msg][i]
        }
        for(i = 0; i < 191; i++)
        {
             g_HUD_SCRL_BAR[4][msg][i] = g_HUD_SCRL_BAR[5][msg][i]
        }
        g_HUD_SCRL_BAR[5][msg] = " "
        HUD_print()
        set_task(6.0,"HUD_autoclear")
}