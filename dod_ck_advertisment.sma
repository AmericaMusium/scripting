
/*picture 1 - add us to your favorites:: ip here
picture 2 - just like it says visit our forums - donate - and join our discord channel
picture 3 - donate to your favorite server
picture 4 - only admins can spectate
picture 5 - round end stats juSt like it showing
picture 6 - pink writing sayingwelcome to ck server name and steam id
picture 7 - TK don’t count on death score
picture 8 - message when player leaves server like the welcome message
picture 4 , 5 , 6 , 7 , 8 - would need to be a plugin to do what it says
picture 1 , 2 , 3  just text in the lower bottom left

*/
#include <amxmodx>
#include <fakemeta>
#include <dodx>
#include <dodfun>


#define MAX_MESSAGES 8
new MESSAGES[5][128] = {
    "add us to your favorites:: ip here",
    "just like it says visit our forums - donate - and join our discord channel",
    "donate to your favorite server",
    "pink writing sayingwelcome to ck server name and steam id",
    "message when player leaves server like the welcome message" 
    }

#define m_iNumTKs 478

public plugin_init()
{
	register_plugin("DOD Adv Messages","0.0","America")
    //WhatsApp +79101483016
    // This is a simple plugin that resets the TeamKills counter and does not give the server a reason to kick the killer
    for (new i = 0; i < MAX_MESSAGES ; i++)
    {
        server_print(MESSAGES[i])
    }
}   
