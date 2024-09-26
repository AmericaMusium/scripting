//////////////////////////////////////////////////////////////////////////////////
//
//	DoD Headshot Sounds
//		- Version 1.2
//		- 04.06.2008
//		- diamond-optic
//
//////////////////////////////////////////////////////////////////////////////////
//
// Information:
//
//    - Will play 1 of 3 (random) dod source headshot
//      sounds when a player dies from a headshot
//
// Extra:
//
//      Put the "headshot1.wav" in /dod/sound/misc/
//      Put the "headshot2.wav" in /dod/sound/misc/
//      Put the "headshot3.wav" in /dod/sound/misc/
//
// Changelog:
//
//    - 05.07.2006 Version 1.0
//  	   Initial Release
//
//    - 05.12.2006 Version 1.1
//  	   Changed emit_sound vol from 1.0 to 0.8 as it blends in better
//
//    - 06.07.2006 Version 1.2
//  	   Changed emit_sound vol from 0.8 to 0.75
//
//    - 04.06.2008 Version 1.2
//  	   Plugin re-release
//
//////////////////////////////////////////////////////////////////////////////////

#include <amxmodx>
#include <dodx>

#define VERSION "1.2"
#define SVERSION "v1.2 - by diamond-optic (www.AvaMods.com)"

new hs_sounds[3][] =
{
	"weapons/hit_leaves1.wav",
	"weapons/hit_wood1.wav",
	"weapons/hit_grass2.wav"
}

enum
{
	hs1,
	hs2,
	hs3
}

public plugin_init()
{
	register_plugin("DoD Headshot Sounds",VERSION,"AMXX DoD Team")
	register_cvar("dod_headshot_sounds_stats",SVERSION,FCVAR_SERVER|FCVAR_SPONLY)
}

public plugin_precache()
{
	precache_sound(hs_sounds[hs1])
	precache_sound(hs_sounds[hs2])
	precache_sound(hs_sounds[hs3])
}

public client_death(killer,victim,wpnindex,hitplace,TK)
	if(hitplace == HIT_HEAD)
		headshot_play(victim)

public headshot_play(victim)
{
	if(is_user_connected(victim))
		{
		switch(random_num(0,2))
			{
			case 0:	emit_sound(victim,CHAN_AUTO,hs_sounds[hs1],0.8,ATTN_NORM,0,PITCH_NORM)
			case 1:	emit_sound(victim,CHAN_AUTO,hs_sounds[hs2],0.8,ATTN_NORM,0,PITCH_NORM)
			case 2:	emit_sound(victim,CHAN_AUTO,hs_sounds[hs3],0.8,ATTN_NORM,0,PITCH_NORM)
			}
		}
}
