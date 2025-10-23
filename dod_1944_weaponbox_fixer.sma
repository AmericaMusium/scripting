#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>
#include <dodx>
#include <engine>
/*
плагин работает в паре с освободителем прекеша, назначает weaponbox w_model один файл с разными субмоделями, 
добавляет звук прицеливания и звук подбора  патронов
*/

#pragma semicolon 1

#define TAKS_OFFSET 2256

/// переопределяем смещения 
// Linux extra offsets
#define linux_diff_weapon 4
#define m_rgpPlayerItems 81		// Weaponbox ячейки
#define m_iId 91 // CbasePlayerItem
#define ZoomIn 1
#define ZoomOut 0
new const sound_wbox_throw[] = "1944/1944wbox_throw.wav";
new const sound_wbox_touch[] = "1944/1944wbox_touch.wav";
new const sound_abox_touch[] = "1944/1944ammobox_touch.wav";
new const sound_zoomin[] = "1944/1944zoom_in.wav";
new const sound_zoomout[] = "1944/1944zoom_out.wav";


public plugin_precache()
{
    precache_sound(sound_wbox_touch);
    precache_sound(sound_wbox_throw);
    precache_sound(sound_abox_touch);
    precache_sound(sound_zoomin);
    precache_sound(sound_zoomout);   
}

public plugin_init()
{  
    register_plugin("weaponbox w_model", "0.0", "America");
    RegisterHam(Ham_Spawn, "weaponbox", "Weaponbox_Spawn_Post", true);
    RegisterHam(Ham_Touch, "weaponbox", "Weaponbox_Touch_Post", true);
    RegisterHam(Ham_Touch, "ammo_generic_german",   "Ammobox_Touch_Post", true);
    RegisterHam(Ham_Touch, "ammo_generic_american", "Ammobox_Touch_Post", true);
    RegisterHam(Ham_Touch, "ammo_generic_british",  "Ammobox_Touch_Post", true);
}


public Weaponbox_Spawn_Post(ptr_weaponbox)
{   
    set_task(0.1, "Weaponbox_Retune", ptr_weaponbox + TAKS_OFFSET);
}

public Weaponbox_Retune(ptr_weaponbox)
{   
    
    ptr_weaponbox -= TAKS_OFFSET;

    new ptr_idx_weapon;
    for (new i = 0; i < 6; i++)
    {   
        ptr_idx_weapon = get_pdata_cbase(ptr_weaponbox, m_rgpPlayerItems + i, linux_diff_weapon); // oofset 4
        if(pev_valid(ptr_idx_weapon))
        {   
            new dodw_id = get_dodw_id_from_ptr_idx_weapon(ptr_idx_weapon);
            // set_pev(ptr_weaponbox, pev_body, dodw_id); 
            entity_set_int(ptr_weaponbox, EV_INT_body, dodw_id);
        }
    }
}

public Weaponbox_Touch_Post(ptr_weaponbox, ptr_toucher)
{   
    if(pev_valid(ptr_weaponbox))
    {   
        if (pev(ptr_weaponbox, pev_flags) & FL_ONGROUND &&  ptr_toucher == 0)
        {   
            // weaponbox touch world 
            emit_sound(ptr_weaponbox, CHAN_AUTO , sound_wbox_touch,  1.0,    ATTN_NORM,  0,  PITCH_NORM);
        }
    }
}

public Ammobox_Touch_Post(ptr_weaponbox, ptr_toucher)
{   
    if(pev_valid(ptr_weaponbox))
    {   
        if (pev(ptr_weaponbox, pev_flags) & FL_ONGROUND &&  ptr_toucher == 0)
        {   
            // ammobox touch world 
            emit_sound(ptr_weaponbox, CHAN_AUTO , sound_abox_touch,  0.8,    ATTN_NORM,  0,  PITCH_NORM );
        }
    }
}


public dod_client_weaponpickup(id, weapon, value)
{
	if(weapon && !value)
    {   
        // Sound when Weapon dropped ( weaponbox ) +
        emit_sound(id, CHAN_AUTO, sound_wbox_throw, 0.6, ATTN_NORM, 0, PITCH_NORM);
    }
		
}

public dod_client_scope(id, value)
{
    switch (value)
    {
        case ZoomIn:
        {
            emit_sound(id, CHAN_AUTO, sound_zoomin, 0.5, ATTN_NORM, 0, PITCH_NORM);
        }
        case ZoomOut:
        {   
            emit_sound(id, CHAN_AUTO, sound_zoomout, 0.3, ATTN_NORM, 0, PITCH_NORM);
        }
        default: return PLUGIN_CONTINUE;
    }
    return PLUGIN_CONTINUE;
}

///////
public get_dodw_id_from_ptr_idx_weapon(ptr_idx_weapon)
{   
    if(ptr_idx_weapon == -1 || !pev_valid(ptr_idx_weapon)) return -1;
    return get_pdata_int(ptr_idx_weapon, m_iId, linux_diff_weapon);
}

