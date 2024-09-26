#include <amxmisc>
#include <dodx>
#include <dodfun>
#include <fakemeta>
#include <hamsandwich>


public plugin_init()
{
register_plugin("DOD Round Start 3 ", "0", "America")


// Round Start and End
register_event("HLTV", "event_new_round", "a", "1=0", "2=0") 



}

public event_new_round()
{


    server_print("-----------------------------------round started")

}