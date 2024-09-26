#include <amxmodx>


new idx_adv = 0
new idx_adv_random_mode = 0
/* idx_adv_random_mode
0 = just cycle from first to last message
1 = random message every ADV_INTERVAL_INSECONDS seconds
*/

#define ADV_INTERVAL_INSECONDS 45.0 // advertisment every 45 seconds
#define ADV_MAX_MESSAGES 2 // advertisment every 45 seconds

public plugin_init()
{
    register_plugin("DOD CK ADDVERTUSMENT", "2024", "America")
    set_task(ADV_INTERVAL_INSECONDS, "advertizement", _, _, _, "b") //
    
}

public advertizement()
{   
    idx_adv++
    if(idx_adv>ADV_MAX_MESSAGES)
        idx_adv = 0

    if(idx_adv_random_mode)
        idx_adv = random_num(0,2) // from zero to maximal CASE number , this is random cycle
    
    switch(idx_adv)
    {
        case 0:
        {
            client_print(0, print_chat, " [ck]  TODAY IS A LOVELY DAY ") // Put your text in "_THIS_PLACE_"
        }
        case 1:
        {
            client_print(0, print_chat, " [ck]  U HAVE IP BANNED ")
        }
        case 2:
        {
            client_print(0, print_chat, " [ck] ADD TO FAVORITES ")
        }
        default: // this is def case not used, but need create.
        {
            return PLUGIN_CONTINUE
        }
    }    
    return PLUGIN_CONTINUE
}