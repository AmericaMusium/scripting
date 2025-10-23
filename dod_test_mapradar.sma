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


#define m_iMapMarker 526 

public plugin_init()
{
register_plugin("DOD Radar Testing","0.0","America")

register_clcmd("say mm", "map_market_test")
}


public map_market_test(idx_player)
{  
    new name[32]

    new mmark = get_pdata_int(idx_player, m_iMapMarker, 5);
    get_user_name(idx_player, name, charsmax(name))
    client_print(0, print_chat,"m_iMapMarker %d name %s", mmark , name);
}
