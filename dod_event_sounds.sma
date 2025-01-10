#include <amxmodx>
#include <fakemeta>
#include <dodx>
#include <dodfun>

#pragma semicolon 1

new const S_RoundStart[][] = 
{   
    "server/rd1.wav",
    "server/rd2.wav",
    "server/rd3.wav"
};

new const S_FirstBlood[][] = 
{
    "server/fb1.wav",
    "server/fb2.wav",
    "server/fb3.wav",
    "server/rk1.wav",
    "server/rk2.wav",
    "server/rk3.wav",
    "server/rk4.wav",
    "server/rk5.wav",
    "server/rk6.wav",
    "server/rk7.wav"
};

new const S_DoubleKill[][] = 
{
    "server/dk1.wav",
    "server/dk2.wav"
};

new const S_KnifeKill1[] = "server/kn1.wav";
new const S_Suicide1[] = "server/su1.wav";
new const S_Grenkill[] = "server/gr1.wav";

new bool:is_first_blood = false;
new Float:last_kill_time[33];

public plugin_precache()
{
    // Прокешируем звуки начала раунда
    for (new i = 0; i < sizeof(S_RoundStart); i++)
    {
        precache_sound(S_RoundStart[i]);
    }

    // Прокешируем звуки первого убийства
    for (new i = 0; i < sizeof(S_FirstBlood); i++)
    {
        precache_sound(S_FirstBlood[i]);
    }
    // Прокешируем звуки первого убийства
    for (new i = 0; i < sizeof(S_DoubleKill); i++)
    {
        precache_sound(S_DoubleKill[i]);
    }

    precache_sound(S_KnifeKill1);
    precache_sound(S_Suicide1);
    precache_sound(S_Grenkill);
}

public plugin_init()
{
    register_plugin("DOD Event Sounds","0.0","America");
    // WhatsApp +79101483016

    // Round Start and End
    register_event("HLTV", "on_RoundStart", "a", "1=0", "2=0");
    // register_event("RoundState","on_RoundStart","a","1=3","1=4","1=5");
    register_event("DeathMsg", "on_DeathMsg", "a");
}   



public on_RoundStart()
{
    is_first_blood = true;
    emit_sound(0, CHAN_AUTO, S_RoundStart[random_num(0,2)] , 1.0, ATTN_NORM, 0, PITCH_NORM);
}

public on_DeathMsg()
{   
    new idx_killer = read_data(1);  // KILLER
    new idx_victim = read_data(2); // WEAPON
    new id_weapon = read_data(3); // WEAPON

    if (is_first_blood == true && idx_killer != idx_victim)
    {
        is_first_blood = false;
        emit_sound(0, CHAN_AUTO, S_FirstBlood[random_num(0,9)] , 1.0, ATTN_NORM, 0, PITCH_NORM);
        return;
    }
    if (idx_killer == idx_victim)
    {   
        emit_sound(0, CHAN_AUTO, S_Suicide1 , 1.0, ATTN_NORM, 0, PITCH_NORM);
        return;
    }
    if (((get_gametime() - last_kill_time[idx_killer]) < 0.8))
    {
        // Doublekill!
        emit_sound(0, CHAN_AUTO, S_DoubleKill[random_num(0,1)] , 1.0, ATTN_NORM, 0, PITCH_NORM);
        last_kill_time[idx_killer] = get_gametime();
        return;
    }
    last_kill_time[idx_killer] = get_gametime();
    if (
    id_weapon == DODW_MILLS_BOMB || 
    id_weapon == DODW_HANDGRENADE || 
    id_weapon == DODW_HANDGRENADE_EX || 
    id_weapon == DODW_STICKGRENADE ||
    id_weapon == DODW_STICKGRENADE_EX )
    {
        emit_sound(0, CHAN_AUTO, S_Grenkill , 1.0, ATTN_NORM, 0, PITCH_NORM);
        return;
    }
    if( 
    id_weapon == 42 || // NEW DODW_GARAND_BUTT==42 == DODW_K43_BUTT
    id_weapon == 43 || // DODW_ENFIELD_BAYONET
    id_weapon == 37 || // DODW_KAR_BAYONET
    id_weapon == DODW_AMERKNIFE ||
    id_weapon == DODW_GERKNIFE ||
    id_weapon == DODW_SPADE ||
    id_weapon == DODW_BRITKNIFE
    )
    {
        emit_sound(0, CHAN_AUTO, S_KnifeKill1 , 1.0, ATTN_NORM, 0, PITCH_NORM);
        return;
    }
}