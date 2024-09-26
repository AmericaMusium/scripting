#include <amxmisc>
#include <dodx>
#include <dodfun>
#include <fakemeta>
#include <hamsandwich>

// Define globals 



/* DoD teams */
#define ALLIES			1
#define AXIS 			2


public plugin_init()
{
register_plugin("DOD Medic Kit ", "2", "America")


// Round Start and End
register_event("RoundState", "event_RoundStart", "a", "1=1");
register_event("RoundState","event_RoundEnd","a","1=3","1=4","1=5");
register_event("CapMsg","event_CapMsg_P","a") // Событие событие после захвата флага

RegisterHam(Ham_Use, "dod_score_ent", "Ham_Use_P") // 


g_msgHudText = get_user_msgid("HudText")

//register_clcmd("say end", "server_menu")

}
