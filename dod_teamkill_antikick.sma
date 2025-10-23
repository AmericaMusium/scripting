#include <amxmodx>
#include <fakemeta>

#define m_iNumTKs 478
#define HUDW_BAZOOKA 29
#define HUDW_PANZERSCHRECK 30
#define HUDW_PIAT 31


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
        
        set_pdata_int(killer,m_iNumTKs, 0, 5) // RESET TEAMKILL
    }
    else
    {
        return;
    }
}

public on_DeathMsg()
{       
    // здесь нужно быть внимательным, т.к. ID_WEAPON HUD не соотвествует DODW_CONST
    new idx_killer = read_data(1);  // KILLER
    // new idx_victim = read_data(2); // WEAPON
    new id_weapon = read_data(3); // WEAPON
    switch (id_weapon)
    {
        case HUDW_BAZOOKA, HUDW_PANZERSCHRECK, HUDW_PIAT:
        {
            set_pdata_int(idx_killer, m_iNumTKs, 0, 5) // RESET TEAMKILL
        }
        default: return;
    }
}
