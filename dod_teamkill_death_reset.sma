#include <amxmodx>
#include <fakemeta>
#include <dodx>
#include <dodfun>

#define m_iNumTKs 478

public plugin_init()
{
	register_plugin("DOD TK Antikick","0.0","America")
    //WhatsApp +79101483016
    // This is a simple plugin that resets the TeamKills counter and does not give the server a reason to kick the killer
}   

public client_death(killer,victim,wpnindex,hitplace,TK)
{
    if(TK)
    {
        new deathcount = dod_get_pl_deaths(victim)
        deathcount--
        dod_set_pl_deaths(victim, deathcount, 1)
        // set_pdata_int(killer,m_iNumTKs, 0, 5) // RESET TEAMKILLS
        client_print( victim , print_chat, "TK's Dont Count on your Death Score!!")
    }
    else
    {
           return;
    }

}
