#include <amxmodx>
#include <fakemeta>
#include <dodx>
#include <dodfun>
#include <hamsandwich>
#include <engine>

#define DODW_GARAND_BUTT 42
#define DODW_K43_BUTT 42
#define DODW_ENFIELD_BAYONET 43
#define DODW_KAR_BAYONET 37

new const s_Dolph[64] = "misc/butt_dolph.wav"
new const s_Kassa[64] = "misc/butt_kassa.wav"

public plugin_init()
{
	register_plugin("DOD BUTT YOU", "0.0","America")	
	register_event("DeathMsg", "player_died", "a") // private E event
}

public plugin_precache()
{
precache_sound(s_Dolph)
precache_sound(s_Kassa)
}

public player_died()
{	
	// new killer = read_data(1)
	// new victim = read_data(2)
	new weapon_id = read_data(3)
    
	if( weapon_id == DODW_GARAND_BUTT || weapon_id == DODW_ENFIELD_BAYONET || weapon_id == DODW_K43_BUTT || weapon_id == DODW_KAR_BAYONET )
	{
		new soundwill = random_num(1,2)
		switch (soundwill)
		{
			case 1: emit_sound(0,CHAN_AUTO,s_Dolph,0.8,ATTN_NORM,0,PITCH_NORM)
			case 2: emit_sound(0,CHAN_AUTO,s_Kassa,1.2,ATTN_NORM,0,PITCH_NORM)
		}
      
	}
}