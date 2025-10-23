#include <amxmodx>
#include <fakemeta>
#include <dodx>
#include <dodfun>
#include <hamsandwich>
#pragma semicolon 1

// --- Звуковые массивы ---
new const S_RoundStart[][] = 
{   
    "1944/1944rd_adolf.wav",
    "1944/1944rd_partizan.wav",
    "1944/1944rd_levitan.wav",
    "1944/1944rd_levitan2.wav"
};

new const S_RoundEnd_Allies[][] = 
{   
    "1944/1944_toskaporodine.wav",
    "1944/1944_vstavaistrana.wav",
    "1944/1944_nabezvysot.wav",
    "1944/def_uswin.wav", 
    "1944/def_britwin.wav"
};

new const S_RoundEnd_Axis[][] = 
{   
    "1944/1944_batotai.wav",
    "1944/1944_erika.wav",
    "1944/1944_augustin.wav",
    "1944/def_germanwin.wav"
};

new const S_Capt_Allies[][] = 
{   
    "1944/1944cap_ussr0.wav",
    "1944/1944cap_ussr1.wav",
    "1944/def_uspointcaptured.wav",
    "1944/def_usareasecure.wav",
    "1944/def_britpointcaptured.wav",
    "1944/def_britobjectivesecure.wav"
};

new const S_Capt_Axis[][] = 
{   
    "1944/def_gerpointcaptured.wav",
    "1944/def_gerobjectivesecure.wav",
    "1944/def_gerareasecure.wav"
};

new const S_FirstBlood[][] = 
{
    "1944/1944firstblood.wav"
};

new const S_DoubleKill[][] = 
{
    "server/dk1.wav",
    "server/dk2.wav"
};

new const S_MeleeAndButt[][] = 
{
    "1944/1944ev_knife.wav",
    "1944/1944ev_kass.wav",
    "1944/1944ev_dolp.wav"    
};

new const S_HeadShot[][] = 
{
    "1944/1944headshot.wav",
    "1944/1944headshot1.wav",
    "1944/1944headshot2.wav"    
};

new const S_Suicide1[] = "1944/1944taps.wav";
new const S_Grenkill[] = "1944/1944grenkill.wav";

#define HUDW_BAZOOKA 29
#define HUDW_PANZERSCHRECK 30
#define HUDW_PIAT 31

#define DODW_MILLS_BOMB 15
#define DODW_HANDGRENADE 13
#define DODW_HANDGRENADE_EX 16
#define DODW_STICKGRENADE 14
#define DODW_STICKGRENADE_EX 32
#define DODW_GARAND_BUTT 40
#define DODW_K43_BUTT 41
#define DODW_AMERKNIFE 1
#define DODW_KAR_BAYONET 36
#define DODW_ENFIELD_BAYONET 37
#define DODW_GERKNIFE 2
#define DODW_BRITKNIFE 43
#define DODW_SPADE 19
#define ALLIES 1
#define AXIS 2

new bool:is_first_blood = false;

public plugin_precache()
{
    for (new i = 0; i < sizeof(S_RoundStart); i++)
        precache_sound(S_RoundStart[i]);
    for (new i = 0; i < sizeof(S_FirstBlood); i++)
        precache_sound(S_FirstBlood[i]);
    for (new i = 0; i < sizeof(S_MeleeAndButt); i++)
        precache_sound(S_MeleeAndButt[i]);
    for (new i = 0; i < sizeof(S_Capt_Allies); i++)
        precache_sound(S_Capt_Allies[i]);
    for (new i = 0; i < sizeof(S_Capt_Axis); i++)
        precache_sound(S_Capt_Axis[i]);
    for (new i = 0; i < sizeof(S_RoundEnd_Allies); i++)
        precache_sound(S_RoundEnd_Allies[i]);
    for (new i = 0; i < sizeof(S_RoundEnd_Axis); i++)
        precache_sound(S_RoundEnd_Axis[i]);
    for (new i = 0; i < sizeof(S_HeadShot); i++)
        precache_sound(S_HeadShot[i]);
    precache_sound(S_Suicide1);
    precache_sound(S_Grenkill);
}

public plugin_init()
{
    register_plugin("DOD Event Sounds Only","1.0","America");
    register_event("RoundState", "on_RoundStart", "a", "1=1");
    register_event("RoundState","on_RoundEnd","a","1=3","1=4","1=5");
    RegisterHam(Ham_Use, "dod_score_ent", "on_Ham_Use_P");
    register_event("CapMsg","on_CapMsg_P","a");
    register_event("DeathMsg", "on_DeathMsg", "a");
}

public on_RoundStart() 
{
    is_first_blood = true;
    emit_sound(0, CHAN_AUTO, S_RoundStart[random_num(0, sizeof(S_RoundStart)-1)] , 1.0, ATTN_NORM, 0, PITCH_NORM);
}

new g_Winner = 0;
public on_Ham_Use_P(ent)
{
    g_Winner = pev(ent, pev_team);
}

public on_RoundEnd() 
{
    switch(g_Winner)
    {
        case ALLIES: emit_sound(0, CHAN_AUTO, S_RoundEnd_Allies[random_num(0, sizeof(S_RoundEnd_Allies)-1)], 0.8, ATTN_NORM, 0, PITCH_NORM);
        case AXIS:  emit_sound(0, CHAN_AUTO, S_RoundEnd_Axis[random_num(0, sizeof(S_RoundEnd_Axis)-1)], 0.8, ATTN_NORM, 0, PITCH_NORM);
        default: return;
    }
}

public on_CapMsg_P(idx)
{
    new idx_team =  read_data(3);
    switch(idx_team)
    {
        case ALLIES: emit_sound(0, CHAN_AUTO, S_Capt_Allies[random_num(0, sizeof(S_Capt_Allies)-1)] , 1.0, ATTN_NORM, 0, PITCH_NORM);
        case AXIS:  emit_sound(0, CHAN_AUTO, S_Capt_Axis[random_num(0, sizeof(S_Capt_Axis)-1)] , 1.0, ATTN_NORM, 0, PITCH_NORM);
        default: return;
    }
}

public on_DeathMsg()
{
    new idx_killer = read_data(1);
    new idx_victim = read_data(2);
    new id_weapon = read_data(3);
    new hitplace = read_data(5);
    if(idx_killer < 1 || idx_victim < 1) return;
    if(idx_killer == idx_victim) // самоубийство
    {
        emit_sound(0, CHAN_AUTO, S_Suicide1 , 0.3, ATTN_NORM, 0, PITCH_NORM);
        return;
    }
    if (is_first_blood)
    {
        is_first_blood = false;
        emit_sound(0, CHAN_AUTO, S_FirstBlood[0] , 1.0, ATTN_NORM, 0, PITCH_NORM);
        return;
    }
    switch (id_weapon)
    {
        case DODW_MILLS_BOMB, DODW_HANDGRENADE, DODW_HANDGRENADE_EX, DODW_STICKGRENADE, DODW_STICKGRENADE_EX:
        {
            emit_sound(0, CHAN_AUTO, S_Grenkill , 1.0, ATTN_NORM, 0, PITCH_NORM);
            return;
        }
        case DODW_GARAND_BUTT, DODW_K43_BUTT, 42:
        {
            emit_sound(0, CHAN_AUTO, S_MeleeAndButt[random_num(1 , sizeof(S_MeleeAndButt)-1)] , 1.0, ATTN_NORM, 0, PITCH_NORM);
            return;
        }
        case DODW_AMERKNIFE, DODW_KAR_BAYONET, DODW_ENFIELD_BAYONET, DODW_GERKNIFE, DODW_BRITKNIFE, DODW_SPADE:
        {
            emit_sound(0, CHAN_AUTO, S_MeleeAndButt[0] , 0.4, ATTN_NORM, 0, PITCH_NORM);
            return;
        }
        case HUDW_BAZOOKA, HUDW_PANZERSCHRECK, HUDW_PIAT:
        {
            emit_sound(0, CHAN_AUTO, S_Grenkill, 1.0, ATTN_NORM, 0, PITCH_NORM);
            return;
        }
    }
    if(hitplace==1)
    {
        emit_sound(0, CHAN_AUTO, S_HeadShot[random_num(0, sizeof(S_HeadShot)-1)] , 1.0, ATTN_NORM, 0, PITCH_NORM);
        return;
    }
} 