//////////////////////////////////////////////////////////////////////////////////
//
//	DoD Pistol Tracers
//		- Version 0.5
//		- 08.28.2006
//		- diamond-optic
//
//////////////////////////////////////////////////////////////////////////////////
//
// Information:
//
// 	- Pistols will now have tracers like MGs
//	- Works well with dod_forcetracers plugin
//
// CVAR: 
//
//	  dod_pistoltracers	//(1)ON or (0)OFF
//
// Credits:
//
//	- Jon for the original tracer plugin
//	- Firestorm for the dod port
//	- Modified to MG Tracer & Pistols only by diamond-optic
//
// Changelog:
//
//	 - 03.14.2006 Version 0.1
//		Changed the tracer from a lame sprite
//		to the tracers used by MGs
//		Made it pistols only
//
//	 - 05.06.2006 Version 0.2
//		Changed from MSG_ONE to MSG_ONE_UNRELIABLE
//
//	 - 07.04.2006 Version 0.3
//		Added is_user_connected check
//
//	 - 07.09.2006 Version 0.4
//		Fixed mistake in is_user_connected check
//		Changed end position get origin mode
//		Did a few other small adjustments...
//
//	 - 08.28.2006 Version 0.5
//		Cleaned up code a bit
//		Fixed tracer not showing for last bullet in clip
//
//////////////////////////////////////////////////////////////////////////////////

#include <amxmodx>
#include <fakemeta_util>
#include <hamsandwich>
#include <dodx>

new lastammo[33]
new lastweap[33]
new p_dod_pistoltracers
new m_spriteTexture
public plugin_init()
{
	register_plugin("DOD ALLTRACERS","0.6","America")
	
	register_cvar("dod_pistol_tracers_stats", "0.5", FCVAR_SERVER|FCVAR_SPONLY)
	
	register_event("CurWeapon","make_tracer","be","1=1")
	
	p_dod_pistoltracers = register_cvar("dod_pistoltracers","1")
}

public plugin_precache() 
{
	m_spriteTexture = precache_model("sprites/fog5.spr")		// smoke sprite
}
public show_tracer(id,team,vec1[3],vec2[3],weap){
	
	if(!is_user_connected(id))
		return PLUGIN_CONTINUE
	
	/*
	message_begin(MSG_ONE_UNRELIABLE,SVC_TEMPENTITY,vec1,id)	
	write_byte(TE_TRACER)   // = 6
	write_coord(vec1[0])
	write_coord(vec1[1])
	write_coord(vec1[2])
	write_coord(vec2[0])
	write_coord(vec2[1])
	write_coord(vec2[2])
	message_end()	
	
	*/
	
	
	
	//BEAMENTPOINTS
	
	message_begin( MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte (0) //TE_BEAMENTPOINTS 0
	write_coord(vec1[0])
	write_coord(vec1[1])
	write_coord(vec1[2])
	write_coord(vec2[0])
	write_coord(vec2[1])
	write_coord(vec2[2])
	write_short( m_spriteTexture )
	write_byte(1) // framestart
	write_byte(5) // framerate
	write_byte(1) // life
	write_byte(3) // width
	write_byte(10) // noise 66 IS BEATY
	write_byte( 255 ) // r, g, b
	write_byte( 242) // r, g, b
	write_byte( 70 ) // r, g, b
	write_byte(7) // brightness
	write_byte(160) // speed
	message_end()
	
	/*
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BEAMPOINTS);
	engfunc(EngFunc_WriteCoord, vec1[0]);
	engfunc(EngFunc_WriteCoord, vec1[1]);
	engfunc(EngFunc_WriteCoord, vec1[2]);
	engfunc(EngFunc_WriteCoord, vec2[0] + random_float(90.0, -90.0));
	engfunc(EngFunc_WriteCoord, vec2[1] + random_float(90.0, -90.0));
	engfunc(EngFunc_WriteCoord, vec2[2] + random_float(90.0, -90.0));
	write_short(m_spriteTexture);
	write_byte(0); // framestart
	write_byte(10); // framerate
	write_byte(1); // life
	write_byte(pev(id, pev_iuser2) ? 50:40); // width
	write_byte(pev(id, pev_iuser2) ? 100:90); // noise
	write_byte(255); // red
	write_byte(255); // green
	write_byte(255); // blue
	write_byte(255); // brightness
	write_byte(pev(id, pev_iuser2) ? 20:10); // speed
	message_end();
	
	*/
	
	
	
	message_begin(MSG_ALL, SVC_TEMPENTITY, vec1, 0); 
	write_byte(TE_IMPLOSION); 
	write_coord(vec1[0]); 
	write_coord(vec1[1]); 
	write_coord(vec1[2]); 
	write_byte(150); 
	write_byte(50); 
	write_byte(15); 
	message_end();
	
	
	
	return PLUGIN_CONTINUE
	// write_coord(random_num(vec2[0] - 10,vec2[0] + 10))
}

public make_tracer(id)
{
	if(get_pcvar_num(p_dod_pistoltracers) == 0 || !is_user_connected(id) || !is_user_alive(id))
		return PLUGIN_CONTINUE
	
	new weap = read_data(2)
	new ammo = read_data(3)
	
	if (lastweap[id] == 0)
		lastweap[id] = weap
	
	if((lastammo[id] > ammo) && (lastweap[id] == weap))
	{
		new team = get_user_team(id)
		new ammo, clip, zGun = dod_get_user_weapon(id,clip,ammo)
		new vec1[3], vec2[3] 
		get_user_origin(id,vec1,1)
		get_user_origin(id,vec2,3)
		
		new plist[32], pnum
		get_players(plist,pnum,"c")
		for(new i = 0; i < pnum; i++)
		{
			if (is_user_connected(plist[i]) && is_user_alive(plist[i]))
				show_tracer(plist[i],team,vec1,vec2,weap)
		}
	}
	
	lastammo[id] = ammo
	lastweap[id] = weap
	
	return PLUGIN_CONTINUE
}
