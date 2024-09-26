/**
 *
 * Bomb/Death/CSS Radar
 *  by eDark & Numb
 *
 *
 * Description:
 *  This plugin pops out on radar where your team mate just died, and in CT case
 *  where dropped bomb is located if it's visible for any of your CTs. Also has
 *  same support for planted bomb, only in this case scenario it remains on radar
 *  once seen.
 *
 *
 * Requires:
 *  FakeMeta
 *  HamSandWich
 *  Cstrike (optional)
 *
 *
 * Additional info:
 *  Tested in Counter-Strike 1.6 with amxmodx 1.8.2 (dev build hg21).
 *
 *
 * Notes:
 *  - Check for bomb visibility comes every 0.5 seconds, and 1.0 seconds after
 *   last update.
 *  - Update 1 second after last check can be disturbing if bomb was moved and
 *   not picked up. This can happen if terrorists drop or plant the bomb in a car
 *   and drive it away.
 *  - This plugin supports only one bomb at a time, so I wont recommend you using
 *   it if you have some vip plugin what gives C4 to every terrorist in every map.
 *  - For coders: I included some useful angle functions at the end of this plugin,
 *   so you might want to check them out.
 *
 *
 * Credits:
 *  Special thanks to eDark for calculation functions!
 *
 *
 * Change-Log:
 *
 *  + 1.2
 *  - Changed: Optimized the code (changed pdata offset names).
 *
 *  + 1.1
 *  - Added: Support for custom c4 model.
 *  - Changed: Time delay between updates is now 1 second - not 2.
 *  - Fixed: Radar location messages weren't always sent due to unreliable messages.
 *
 *  + 1.0
 *  - First release.
 *
 *
 * Downloads:
 *  Amx Mod X forums: http://forums.alliedmods.net/showthread.php?p=1333911#post1333911
 *
**/

// ----------------------------------------- CONFIG START -----------------------------------------

// Comment "#define DONT_USE_CSTRIKE" line if you don't want to use FakeMeta module for Cstrike
// functions. NOTE: FakeMeta will still be needed and used no matter what.
#define DONT_USE_CSTRIKE // default: (uncommented)

// If you are having trouble with radar what can be caused by many hostages or other
// plugins what use hostage system to show something on radar - please change this value to a
// higher one. NOTE: Highest value what you can use is 255-maxplayers, and lowest value should be
// maximal number of hostages +1 what you can have on your server in some specific map.
#define RADARID_OFFSET 16 // default: 16

// If you are having problems, that not everyone recieves radar updates, that can be due to message
// type and ping. Using "MSG_ONE_UNRELIABLE" is better for server stability, however using "MSG_ONE"
// garanties that client will recieve the update.
#define MSG_TYPE MSG_ONE // default: (uncommented)
//#define MSG_TYPE MSG_ONE_UNRELIABLE // default: (commented)

// ------------------------------------------ CONFIG END ------------------------------------------


#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <dodx>
#include <dodfun>
#if defined DONT_USE_CSTRIKE
enum CsTeams
{
	CS_TEAM_UNASSIGNED = 0,
	CS_TEAM_T = 1,
	CS_TEAM_CT = 2,
	CS_TEAM_SPECTATOR = 3
};
#define m_iTeam 114
CsTeams:cs_get_user_team(iPlrId)
	return (CsTeams:get_pdata_int(iPlrId, m_iTeam, 5));
#else
#include <cstrike>
#endif


#define PLUGIN_NAME    "Bomb/Death/CSS Radar"
#define PLUGIN_VERSION "1.2"
#define PLUGIN_AUTHOR  "eDark & Numb"

#define m_bIsC4 96
#define IS_C4   (1<<8)

#define SetPlayerBit(%1,%2)    ( %1 |=  ( 1 << ( %2 & 31 ) ) )
#define ClearPlayerBit(%1,%2)  ( %1 &= ~( 1 << ( %2 & 31 ) ) )
#define CheckPlayerBit(%1,%2)  ( %1 &   ( 1 << ( %2 & 31 ) ) )

new g_iMaxPlayers;

new g_iMsgId_HostagePos;
new g_iMsgId_HostageK;

new g_iC4TaskNum;
new bool:g_bBombPlanted;
new bool:g_bBombDropped;
new bool:g_bPosKnown;
new Float:g_fLastKnownPos[3];
new Float:g_fBombOrigin[3];
new Float:g_fLastUpdate;
new g_iLocationSend;


public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
	
	RegisterHam(Ham_Killed, "player", "Ham_Killed_player_Pre", 0);
	
	register_event("BombDrop",   "Event_BombPlanted", "a", "4=1");
	register_event("BombDrop",   "Event_BombDropped", "b", "4=0");
	register_event("BombPickup", "Event_BombPickup",  "a");
	register_event("ResetHUD",   "Event_ResetHUD",    "b");
	
	g_iMsgId_HostagePos = get_user_msgid("HostagePos");
	g_iMsgId_HostageK   = get_user_msgid("HostageK");
	
	g_iMaxPlayers = clamp(get_maxplayers(), 1, 32);
	
	register_event("HLTV", "Event_NewRound", "a", "1=0", "2=0");
}

public client_disconnect(iPlrId)
	ClearPlayerBit(g_iLocationSend, iPlrId);

public Event_ResetHUD(iPlrId)
	ClearPlayerBit(g_iLocationSend, iPlrId);

public Ham_Killed_player_Pre(iPlrId, iAttackerId, iShouldGib)
{
	ClearPlayerBit(g_iLocationSend, iPlrId);
	new CsTeams:iTeam = cs_get_user_team(iPlrId);
	new Float:fOrigin[3], iRadarOffset;
	pev(iPlrId, pev_origin, fOrigin);
	iRadarOffset = (RADARID_OFFSET+iPlrId);
	
	for( new iPlayer=1; iPlayer<=g_iMaxPlayers; iPlayer++ )
	{
		if( is_user_alive(iPlayer) )
		{
			if( cs_get_user_team(iPlayer)==iTeam )
			{
				message_begin(MSG_TYPE, g_iMsgId_HostagePos, _, iPlayer);
				write_byte(1);
				write_byte(iRadarOffset);
				engfunc(EngFunc_WriteCoord, fOrigin[0]);
				engfunc(EngFunc_WriteCoord, fOrigin[1]);
				engfunc(EngFunc_WriteCoord, fOrigin[2]);
				message_end();
				
				message_begin(MSG_TYPE, g_iMsgId_HostageK, _, iPlayer);
				write_byte(iRadarOffset);
				message_end();
			}
		}
	}
}

public Event_BombPlanted()
{
	if( !g_bBombPlanted ) // 2 bombs planted? Ow, sry, but **** you - I do not support VIP plugins!
	{
		reset_all_data();
		g_bBombPlanted = true;
		
		g_iC4TaskNum = 6;
		set_task(0.1, "find_c4", 1, "", 0, "b");
	}
}

public Event_BombDropped()
{
	if( !g_bBombPlanted && !g_bBombDropped ) // bomb dropped. And no - I wont support 2 bombs on radar
	{
		reset_all_data();
		g_bBombDropped = true;
		
		g_iC4TaskNum = 6;
		set_task(0.1, "find_c4", 1, "", 0, "b");
	}
}

public Event_BombPickup()
{
	if( !g_bBombPlanted ) // without this check if there are 2 bombs for some reason, it could really become a problem
		reset_all_data();
}

public Event_NewRound()
	reset_all_data();

public find_c4()
{
	if( !(g_iC4TaskNum%5) ) // when bomb position wasn't updated for too long, search and check for it every 0.5sec
	{
		new Float:fGametime = get_gametime();
		
		if( (fGametime-1.0)>g_fLastUpdate ) // it's also when g_iC4TaskNum>10, but just in case...
			g_iC4TaskNum = 10;
	}
	
	g_iC4TaskNum++;
	
	if( g_iC4TaskNum>10 )
	{
		g_iC4TaskNum = 1;
		
		if( g_bBombPlanted )
		{
			new iEnt;
			while( (iEnt=engfunc(EngFunc_FindEntityByString, iEnt, "classname", "grenade"))>0 )
			{
				if( pev_valid(iEnt) )
				{
					if( get_pdata_int(iEnt, m_bIsC4, 5)&IS_C4 ) // I readlly don't have a clue how to name this pdata and value related to it
					{
						pev(iEnt, pev_origin, g_fBombOrigin);
						g_fBombOrigin[2] += 4.0;
						
						if( should_allow_update() ) // well, I should add support for case when c4 is driven away, but you know what...
							send_bomb_location(g_fLastKnownPos, get_gametime()); // stop using ****y maps what can move the bomb
						
						break;
					}
				}
			}
			if( g_bPosKnown && iEnt<=0 && g_iLocationSend )
				reset_update();
		}
		else if( g_bBombDropped )
		{
			new iEnt, iOwner;
			while( (iEnt=engfunc(EngFunc_FindEntityByString, iEnt, "classname", "weapon_c4"))>0 )
			{
				if( pev_valid(iEnt) )
				{
					iOwner = pev(iEnt, pev_owner);
					if( iOwner>g_iMaxPlayers && pev_valid(iOwner) )
					{
						pev(iOwner, pev_origin, g_fBombOrigin);
						g_fBombOrigin[2] += 4.0;
						
						if( should_allow_update() ) // well, I should add support for case when c4 is driven away, but you know what...
							send_bomb_location(g_fLastKnownPos, get_gametime()); // stop using ****y maps what can move the bomb
						else if( g_iLocationSend )
							reset_update();
						break;
					}
				}
			}
		}
	}
}

reset_update()
{
	for( new iPlrId=1; iPlrId<=g_iMaxPlayers; iPlrId++ )
	{
		if( CheckPlayerBit(g_iLocationSend, iPlrId) )
		{
			message_begin(MSG_TYPE, g_iMsgId_HostageK, _, iPlrId);
			write_byte((RADARID_OFFSET-1));
			message_end();
		}
	}
	g_iLocationSend = 0;
}

bool:should_allow_update()
{
	if( g_bBombPlanted )
	{
		if( g_bPosKnown )
		{
			if( is_bomb_visisble(g_fBombOrigin) ) // did you know that it's possible to plant c4 in a car and drive it away?
			{
				g_fLastKnownPos[0] = g_fBombOrigin[0]; // so I'm adding a small, but not perfect support for that
				g_fLastKnownPos[1] = g_fBombOrigin[1]; // not perfect cause check for new visible position of c4 goes
				g_fLastKnownPos[2] = g_fBombOrigin[2]; // every 1 seconds, and not every 0.5 what would be acceptable
			} // best thing you could do is remove ****y maps where you can exploit this bug
			
			return true;
		}
		else
		{
			if( is_bomb_visisble(g_fBombOrigin) )
			{
				g_fLastKnownPos[0] = g_fBombOrigin[0];
				g_fLastKnownPos[1] = g_fBombOrigin[1];
				g_fLastKnownPos[2] = g_fBombOrigin[2];
				g_bPosKnown = true;
				
				return true;
			}
		}
	}
	else if( g_bBombDropped )
	{
		if( is_bomb_visisble(g_fBombOrigin) )
		{
			g_fLastKnownPos[0] = g_fBombOrigin[0];
			g_fLastKnownPos[1] = g_fBombOrigin[1];
			g_fLastKnownPos[2] = g_fBombOrigin[2];
			
			return true;
		}
	}
	
	return false;
}

send_bomb_location(Float:fOrigin[3], Float:fGameTime)
{
	for( new iPlrId=1; iPlrId<=g_iMaxPlayers; iPlrId++ )
	{
		if( is_user_alive(iPlrId) )
		{
			if( cs_get_user_team(iPlrId)==CS_TEAM_T )
				continue;
			
			SetPlayerBit(g_iLocationSend, iPlrId);
			
			message_begin(MSG_TYPE, g_iMsgId_HostagePos, _, iPlrId);
			write_byte(1);
			write_byte(RADARID_OFFSET);
			engfunc(EngFunc_WriteCoord, fOrigin[0]);
			engfunc(EngFunc_WriteCoord, fOrigin[1]);
			engfunc(EngFunc_WriteCoord, fOrigin[2]);
			message_end();
			
			message_begin(MSG_TYPE, g_iMsgId_HostageK, _, iPlrId);
			write_byte(RADARID_OFFSET);
			message_end();
			
			message_begin(MSG_TYPE, g_iMsgId_HostageK, _, iPlrId);
			write_byte((RADARID_OFFSET-1));
			message_end();
			
			message_begin(MSG_TYPE, g_iMsgId_HostagePos, _, iPlrId);
			write_byte(0);
			write_byte((RADARID_OFFSET-1));
			engfunc(EngFunc_WriteCoord, fOrigin[0]);
			engfunc(EngFunc_WriteCoord, fOrigin[1]);
			engfunc(EngFunc_WriteCoord, fOrigin[2]);
			message_end();
		}
	}
	
	g_fLastUpdate = fGameTime;
}

bool:is_bomb_visisble(Float:fC4Origin[3])
{
	new Float:fTemp[3], Float:fOrigin[3], Float:fAngle[3], Float:fFov, bool:bAwpZoom, Float:fObjectPos[3];
	new Float:fScreenWidth, Float:fScreenHigh;
	
	for( new iPlrId=1; iPlrId<=g_iMaxPlayers; iPlrId++ )
	{
		if( is_user_alive(iPlrId) )
		{
			if( cs_get_user_team(iPlrId)==CS_TEAM_T )
				continue;
			
			pev(iPlrId, pev_origin, fOrigin);
			pev(iPlrId, pev_view_ofs, fTemp);
			fOrigin[0] += fTemp[0];
			fOrigin[1] += fTemp[1];
			fOrigin[2] += fTemp[2];
			pev(iPlrId, pev_v_angle, fAngle);
			pev(iPlrId, pev_fov, fFov);
			if( fFov>90.0 || fFov<=0.0 )
			{
				fFov = 90.0;
				bAwpZoom = false;
			}
			else if( fFov<45.0 )
			{
				if( fFov<10.0 )
					fFov = 10.0;
				bAwpZoom = true; // offset for fov sniper circle is 0.654
			}
			else
				bAwpZoom = false;
			
			fAngle[0] *= (M_PI/180.0);
			fAngle[1] *= (M_PI/180.0);
			fFov *= (M_PI/180.0);
			
			fObjectPos[0] = (fC4Origin[0]-fOrigin[0]);
			fObjectPos[1] = (fC4Origin[1]-fOrigin[1]);
			fObjectPos[2] = (fC4Origin[2]-fOrigin[2]);
			
			fTemp[0] = (fObjectPos[0]*floatcos(fAngle[1])*floatcos(fAngle[0]));
			fTemp[0] += (fObjectPos[1]*floatsin(fAngle[1])*floatcos(fAngle[0]));
			fTemp[0] -= (fObjectPos[2]*floatsin(fAngle[0]));
			
			if( fTemp[0]<0.0 ) // object is somewhere behind you
				continue;
			
			fTemp[1] = (fObjectPos[1]*floatcos(fAngle[1]));
			fTemp[1] -= (fObjectPos[0]*floatsin(fAngle[1]));
			
			fTemp[2] = (fObjectPos[0]*floatcos(fAngle[1])*floatsin(fAngle[0]));
			fTemp[2] += (fObjectPos[1]*floatsin(fAngle[1])*floatsin(fAngle[0]));
			fTemp[2] += (fObjectPos[2]*floatcos(fAngle[0]));
			
			fScreenWidth = (2.0*fTemp[0]*floattan((fFov*0.5)));
			//fScreenHigh = (fScreenWidth*3.0/4.0);  // normal screen video option
			////fScreenHigh = (fScreenWidth*9.0/16.0); // wide screen video option
			
			if( bAwpZoom )
			{
				if( ((fTemp[1]*fTemp[1])+(fTemp[2]*fTemp[2]))>=floatpower((fScreenWidth*0.327), 2.0) ) // 0.654*0.5
					continue; // object is not in awp circle zoom
			}
			else
			{
				fScreenHigh = (fScreenWidth*3.0/4.0); // normal screen video option
				//fScreenHigh = (fScreenWidth*9.0/16.0); // wide screen video option
				
				if( (fTemp[1]>(fScreenWidth*0.5) || fTemp[1]<(fScreenWidth*-0.5))
				 || (fTemp[2]>(fScreenHigh*0.5) || fTemp[2]<(fScreenHigh*-0.5)) )
					continue;
			}
			
			//new Float:fScreenPosX = (0.5-(fTemp[1]/fScreenWidth));
			//new Float:fScreenPosY = (0.5-(fTemp[2]/fScreenHigh));
			
			engfunc(EngFunc_TraceLine, fOrigin, fC4Origin, iPlrId, DONT_IGNORE_MONSTERS, 0);
			get_tr2(0, TR_flFraction, fFov);
			
			if( fFov>=1.0 )
				return true;
		}
	}
	
	return false;
}

reset_all_data()
{
	g_bBombPlanted = false;
	g_bBombDropped = false;
	g_bPosKnown = false;
	
	g_fLastUpdate = 0.0;
	g_iC4TaskNum = 0;
	
	if( task_exists(1) )
		remove_task(1);
	
	if( g_iLocationSend )
		reset_update();
}




/*

stock fm_cs_get_grenade_type(iEnt)
{
	// you can comment/remove this
	// if you are sure that the entity
	// with the given index are valid
	if( !pev_valid(iEnt) )
		return 0;
	
	// you can comment/remove this
	// if you are sure that the entity
	// with the given index are "grenade"
	new iClassname[9];
	pev(iEnt, pev_classname, iClassname, 8);
	if( !equal(classname, "grenade") )
		return 0;
	
	if( get_pdata_int(iEnt, 96, 5)&(1<<8) ) // m_bIsC4 & IS_C4
		return CSW_C4;
	
	new iBits = get_pdata_int(iEnt, 114, 5); // m_iGrenadeType
	if( iBits&(1<<0) )
		return CSW_HEGRENADE;
	else if( iBits&(1<<1) )
		return CSW_SMOKEGRENADE;
	else if( !iBits )
		return CSW_FLASHBANG;
	
	return 0
}


// Returns true whenever origin is visible from camera position. Also sets screen X and Y positions
//  of where object is on the screen. Special thanks to an alien called eDark, who escaped from
//  area 51 to give us this calculation formula and it's function. :D No, really, that guy is a genius.
//
// fCamPos[3]       - camera origin (for player use pev->origin + pev->view_ofs)
// fCamAngle[3]     - angle of camera (for player use pev->v_angle)
// ObjectOrigin[3]  - position what we check for visibility
// fScreenPosX      - sets value from 0.0 to 1.0 of object location on the screen (-1 if not visible)
// fScreenPosY      - sets value from 0.0 to 1.0 of object location on the screen (-1 if not visible)
// fCamFov          - field of view pev->fov (default: 90.0)
// bAwpSupport      - support for circle check in case of sniper zoom (default: true)
// fScreenSizeX     - horizontal size of the screen (4:3 - normal; 16:9 - wide; default: 4.0)
// fScreenSizeY     - vertical size of the screen (4:3 - normal; 16:9 - wide; default: 3.0)
//
// NOTES: If fov is less or equal 0, make sure you change it to 90. Fov higher than 180 is
//  not supported. Lowest fov possible for player view - 10. If screen size won't match
//  the real one - screen X and Y positions wont be 100% accurate. Ow, and yes - this formula
//  is much more accurate than any functions what you'll find in default .inc files and even hlsdk.
//  However it does not support angle[z].


bool:is_origin_in_fov(const Float:fCamPos[3], const Float:fCamAngle[3], const Float:fObjectOrigin[3], &Float:fScreenPosX, &Float:fScreenPosY, const Float:fCamFov=90.0, const bool:bAwpSupport=true, const Float:fScreenSizeX=4.0, const Float:fScreenSizeY=3.0)
{
	if( fCamFov>=180.0 )
	{
		fScreenPosX = -1.0;
		fScreenPosY = -1.0;
		
		return false;
	}
	
	new Float:fObjectPos[3], Float:fTemp[3], Float:fAngle[2], Float:fFov, bool:bCircleSniperZoom;
	
	if( fCamFov<45 )
		bCircleSniperZoom = true;
	
	fAngle[0] = (fCamAngle[0]*M_PI/180.0);
	fAngle[1] = (fCamAngle[1]*M_PI/180.0);
	fFov = (fCamFov*M_PI/180.0);
	
	fObjectPos[0] = (fObjectOrigin[0]-fCamPos[0]);
	fObjectPos[1] = (fObjectOrigin[1]-fCamPos[1]);
	fObjectPos[2] = (fObjectOrigin[2]-fCamPos[2]);
	
	fTemp[0] = (fObjectPos[0]*floatcos(fAngle[1])*floatcos(fAngle[0]));
	fTemp[0] += (fObjectPos[1]*floatsin(fAngle[1])*floatcos(fAngle[0]));
	fTemp[0] -= (fObjectPos[2]*floatsin(fAngle[0]));
	
	if( fTemp[0]<0.0 )
	{
		fScreenPosX = -1.0;
		fScreenPosY = -1.0;
		
		return false;
	}
	
	fTemp[1] = (fObjectPos[1]*floatcos(fAngle[1]));
	fTemp[1] -= (fObjectPos[0]*floatsin(fAngle[1]));
	
	fTemp[2] = (fObjectPos[0]*floatcos(fAngle[1])*floatsin(fAngle[0]));
	fTemp[2] += (fObjectPos[1]*floatsin(fAngle[1])*floatsin(fAngle[0]));
	fTemp[2] += (fObjectPos[2]*floatcos(fAngle[0]));
	
	
	new Float:fScreenWidth = (2.0*fTemp[0]*floattan((fFov*0.5)));
	if( bCircleSniperZoom && bAwpSupport )
	{
		if( ((fTemp[1]*fTemp[1])+(fTemp[2]*fTemp[2]))<floatpower((fScreenWidth*0.327), 2.0) ) // 0.654*0.5
		{
			fScreenPosX = (0.5-(fTemp[1]/fScreenWidth));
			fScreenPosY = (0.5-(fTemp[2]/(fScreenWidth*fScreenSizeY/fScreenSizeX)));
			
			return true;
		}
		
		fScreenPosX = -1.0;
		fScreenPosY = -1.0;
		
		return false;
	}
	
	new Float:fScreenHigh = (fScreenWidth*fScreenSizeY/fScreenSizeX);
	
	if( (fTemp[1]>(fScreenWidth*0.5) || fTemp[1]<(fScreenWidth*-0.5))
	 || (fTemp[2]>(fScreenHigh*0.5) || fTemp[2]<(fScreenHigh*-0.5)) )
	{
		fScreenPosX = -1.0;
		fScreenPosY = -1.0;
		
		return false;
	}
	
	fScreenPosX = (0.5-(fTemp[1]/fScreenWidth));
	fScreenPosY = (0.5-(fTemp[2]/fScreenHigh));
	
	return true;
}

// Original C++ function made by eDark:
//
// NOTE: This is easy (by his words) and small version of the calculation.
//  At the start we were working with much more complex calculations, formulas
//  of what I first though were alien symbols in wikipedia. :D

bool IsInScreen(vec obj, vec origin, svec view, float h_fov, vec &screen)
{
	view.ha *= PI/180;
	view.va *= PI/180;
	h_fov *= PI/180;
	
	obj.x -= origin.x;
	obj.y -= origin.y;
	obj.z -= origin.z;
	
	vec temp;
	
	temp.x = obj.x * cos(view.ha) * cos(view.va) + obj.y * sin(view.ha) * cos(view.va) - obj.z * sin(view.va);
	temp.y = obj.y * cos(view.ha) - obj.x * sin(view.ha);
	temp.z = obj.x * cos(view.ha) * sin(view.va) + obj.y * sin(view.ha) * sin(view.va) + obj.z * cos(view.va);
	
	if(temp.x <= 2) // min distance camera to actual screen
		return 0; // numbs comment: we tested this value and came to conclusion that it's not constant/cannot be found accurate enough. So amxx version I just use 0 instead of 2
	
	float screen_width = 2 * temp.x * tan(h_fov/2);
	float screen_hight = screen_width * 3/4; // numbs comment: 3/4 stands for screen size 4:3
	
	if((temp.y > screen_width/2 || temp.y < screen_width/-2) || (temp.z > screen_hight/2 || temp.z < screen_hight/-2))
		return 0;
	
	screen.x = 0.5-temp.y/screen_width;
	screen.y = 0.5-temp.z/screen_hight;
	
	return 1;
}


// Well... I'll add some more forumlas what we went through (they may be useful in the future if not for me, than for others)


// This function is useful cause when vertical angle isn't 0, horizontal angle isn't what we expect
//  it to be. Trust me - if we look up, than 45 degrees to the left isn't the edge of our screen,
//  but is directly up. Well, this one fixes it. Baiscally what it does is gives us a position what
//  we want to our cam-pos, cam-angle, and radius. Something like get_user_aiming(), but here we
//  can choose distance and angle what we want.
//
// dest   - return origin
// origin - cam position
// view   - cam angle
// anlge  - angle to where "dest" should be (![z] is the distance/radius we want - not angle!)
// h_fov  - field of view
//
// NOTES: ".ha" = horizontal (Y) or [1]; ".va" = vertical (X) or [0]; ".r" = (Z) or [2]
//  "angle.r" is angle[2] what actually is a radius or a distance we want from "origin" to "dest",
//  so don't get confused.

bool SphereToCartesian(vec &dest, vec origin, svec view, svec angle, float h_fov)
{
	angle.ha *= PI/180;
	h_fov *= PI/180;
 
        if(angle.ha < h_fov/-2 || angle.ha > h_fov/2)
                return false;
 
        float v_fov = PI/2 - acos( 1.5 / sqrt( 4 / (tan( h_fov / 2) * tan( h_fov / 2)) + 4 * tan(angle.ha) * tan(angle.ha) + 1.5*1.5));
 
        angle.va *= PI/180;
 
        if(angle.va < v_fov/-2 || angle.va > v_fov/2)
                return false;
 
        view.ha *= PI/180;
        view.va *= PI/180;
 
        dest.x = angle.r * sin(angle.va*PI/180 + PI/2) * cos(angle.ha*PI/180);
        dest.y = angle.r * sin(angle.va*PI/180 + PI/2) * sin(angle.ha*PI/180);
        dest.z = angle.r * cos(angle.va*PI/180 + PI/2);
 
        vec temp;
 
        temp.x = dest.x * cos(view.va) * cos(view.ha) - dest.y * sin(view.ha) + dest.z * sin(view.va) * cos(view.ha);
        temp.y = dest.x * cos(view.va) * sin(view.ha) + dest.y * cos(view.ha) + dest.z * sin(view.ha) * sin(view.va);
        temp.z = dest.z * cos(view.va) - dest.x * sin(view.va);
 
        dest = temp;
 
        dest.x += origin.x;
        dest.y += origin.y;
        dest.z += origin.z;
 
        return true;
}


// This forumla gives us angle on what we should look if we want object to be in the middle of our screen
//
//#define NUMBS_METHOD // I must say that my method (numbs) looks faster (uses less resources), but eDark recommends in using his one

bool:get_angle_to_origin(&Float:fAngle[3], const Float:fCamPos[3], const Float:fObjcetPos[3])
{
#if defined NUMBS_METHOD // Trust me, it works. eDark himself couldn't believe that at first. :D (I found this method by a lucky guess)
	if( fObjcetPos[2]<fCamPos[2] )
		fAngle[0] = floatatan2(floatabs(fObjcetPos[2]-fCamPos[2]), get_2d_distance((fObjcetPos[1]-fCamPos[1]), (fObjcetPos[0]-fCamPos[0])), degrees);
	else if( fObjcetPos[2]>fCamPos[2] )
		fAngle[0] = (floatatan2(floatabs(fObjcetPos[2]-fCamPos[2]), get_2d_distance((fObjcetPos[1]-fCamPos[1]), (fObjcetPos[0]-fCamPos[0])), degrees)*-1.0);
	else
		fAngle[0] = 0.0;
#else
	fAngle[0] = (floatacos(((fObjcetPos[2]-fCamPos[2])/floatsqroot(((fObjcetPos[0]-fCamPos[0])*(fObjcetPos[0]-fCamPos[0]))+((fObjcetPos[1]-fCamPos[1])*(fObjcetPos[1]-fCamPos[1]))+((fObjcetPos[2]-fCamPos[2])*(fObjcetPos[2]-fCamPos[2])))), degrees)-90.0);
#endif
	// "fAngle[0]" is 100% accurate vertical angle from "fCamPos" origin to "fObjcetPos" origin
	
	fAngle[1] = floatatan2((fObjcetPos[1]-fCamPos[1]), (fObjcetPos[0]-fCamPos[0]), degrees);
	// "fAngle[1]" is 100% accurate horizontal angle from "fCamPos" origin to "fObjcetPos" origin
}

#if defined NUMBS_METHOD
Float:get_2d_distance(Float:fDistanceX, Float:fDistanceY)
	return floatsqroot(((fDistanceX*fDistanceX)+(fDistanceY*fDistanceY)));
#endif


// Well, that should be enough functions for now. :D
// Now tell me, do you start to believe that eDark actually might be an extraterrestrial being? :D

*/
