#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <fakemeta_util>
#include <fakemeta_stocks>
#include <dodx>
#include <dodfun>
#include <fun>
#include <engine>

#pragma semicolon 1

enum _:SOUNDS
{
    SOUND_KWAK,
	SOUND_SCREAM,
	SOUND_TILT
};

new const snd_chicken[][] = 
{
    "ck/ck_chick0.wav",
    "ck/ck_chicken1_hd.wav",
    "ck/ck_chicken2_hd.wav"    
};

public plugin_precache()
{
    // Прокешируем звуки начала раунда
    for (new i = 0; i < sizeof(snd_chicken); i++)
        {
            precache_sound(snd_chicken[i]);
        }
}

public dod_rocket_explosion(id_owner, Float:pos[3], idx_wpn)  
{   
    // event on Rocket_Explission
    fm_attach_view(id_owner, id_owner);
    emit_sound(id_owner, CHAN_AUTO, snd_chicken[0], VOL_NORM, ATTN_NORM, 0, 85);
    client_print(0, print_chat, "rocket expolded");
}