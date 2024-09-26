#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <fakemeta_util>
#include <xs>
#include <dodx>
#include <dodfun>
#include <fun>
#include <engine>

#pragma semicolon 1

#define PLUGIN_NAME "Tutorial Plugin"
#define PLUGIN_VERSION "1.0"
#define PLUGIN_AUTHOR "JoRoPiTo"

#define STR 32
#define LOG 128

#define TUT_PREFIX "[AMXX TUT]"
#define DIVISOR "======================================================="

static g_beamSprite;
static g_maxEntities;
static g_maxClients;
static g_msgSayText;


public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);

	// Console commands
	register_concmd("con_showents", "con_showents");

	// Client commands
	register_clcmd("tutorial1", "tut_FindEntityByString");
	register_clcmd("tutorial2", "tut_FindEntityInSphere");
	register_clcmd("tutorial3", "tut_FindClientInPVS");
	register_clcmd("tutorial4", "tut_TraceLine");
	register_clcmd("tutorial5", "tut_TraceModel");

	g_maxEntities = global_get(glb_maxEntities);
	g_maxClients = global_get(glb_maxClients);
	g_msgSayText = get_user_msgid("SayText");
}

public plugin_precache()
{
	g_beamSprite = precache_model("sprites/zbeam1.spr");
}


//------------------------------------------------------------------------
//Internal functions
//------------------------------------------------------------------------
stock fn_log_con(name[], msg[])
{
	server_print("%s %s: %s", TUT_PREFIX, name, msg);
}

stock fn_log_cli(id, name[], msg[])
{
	static text[LOG];
	formatex(text, charsmax(text), "^x04%s %s:^x01 %s", TUT_PREFIX, name, msg);
	if(id != 0)
	{
		message_begin(MSG_ONE, g_msgSayText, {0,0,0}, id);
		write_byte(id);
		write_string(text);
		message_end();
	}
	else
	{
		client_print(0, print_chat, text);
	}
}

stock fn_create_beam(Float:origin[3], Float:end[3], t, r, g, b)
{
        message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
        write_byte(TE_BEAMPOINTS);
	engfunc(EngFunc_WriteCoord, origin[0]);
	engfunc(EngFunc_WriteCoord, origin[1]);
	engfunc(EngFunc_WriteCoord, origin[2]);
	engfunc(EngFunc_WriteCoord, end[0]);
	engfunc(EngFunc_WriteCoord, end[1]);
	engfunc(EngFunc_WriteCoord, end[2]);
        write_short(g_beamSprite);
	write_byte(1);
	write_byte(5);
	write_byte(t);
	write_byte(20);
	write_byte(0);
	write_byte(r);
	write_byte(g);
	write_byte(b);
	write_byte(200);
	write_byte(200);
        message_end();
}

//------------------------------------------------------------------------
//Console functions
//------------------------------------------------------------------------

public con_showents()
{
	new class[STR], str[LOG];
	new origin[3];
	new ent, owner;
	for(ent=1; ent < g_maxEntities; ++ent)
	{
		if(!pev_valid(ent))
			continue;

		pev(ent, pev_origin, origin);
		pev(ent, pev_classname, class, charsmax(class));
		owner = pev(ent, pev_owner);
		formatex(str, charsmax(str), "%i %s (owner:%i) (%f,%f,%f)", ent, class, owner, origin[0], origin[1], origin[2]);
		fn_log_con("Entity", str);
	}
	return PLUGIN_HANDLED;
}

//------------------------------------------------------------------------
//Client functions
//------------------------------------------------------------------------

// FindEntityByString
// This tutorial makes lines from the player to every player in the map
public tut_FindEntityByString(id)
{
	static Float:origin[3];
	static Float:point[3];
	static text[LOG];
	static ent;
	static const class[] = "player";	// We are going to find "player" entitities

	pev(id, pev_origin, origin);
	pev(id, pev_view_ofs, point); 
	xs_vec_add(origin, point, origin);

	fn_log_cli(id, "FindEntityInSphere", DIVISOR);
	ent = -1;
	while((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", class)))
	{
		// We don't want our own entity
		if(ent == id)
			continue;

		if(!pev_valid(ent))
			continue;

		pev(ent, pev_origin, point);
		fn_create_beam(origin, point, 60, 255, 0, 0);	// Create red line from ID to ENT for 60 seconds
		formatex(text, charsmax(text), "Found entity 'player' (ent:%i)", ent);
		fn_log_cli(id, "FindEntityInSphere", text);
	}

	return PLUGIN_HANDLED;
}

// FindEntityInSphere
// This tutorial makes lines from a player to every entity found in sphere radius
public tut_FindEntityInSphere(id)
{
	static Float:origin[3];
	static Float:point[3];
	static text[LOG];
	static class[STR];
	static ent;
	static const radius = 2000;	// We are going to find entities using this sphere radius

	pev(id, pev_origin, origin);
	pev(id, pev_view_ofs, point); 
	xs_vec_add(origin, point, origin);

	fn_log_cli(id, "FindEntityInSphere", DIVISOR);
	ent = -1;
	while((ent = engfunc(EngFunc_FindEntityInSphere, ent, origin, radius)))
	{
		// We don't want worldspawn entity
		if(ent == 0)
			continue;

		// We don't want our own entity
		if(ent == id)
			continue;

		if(!pev_valid(ent))
			continue;

		pev(ent, pev_origin, point);
		pev(ent, pev_classname, class, charsmax(class));
		if(equal(class, "weaponbox") || equal(class, "player"))
		{
			fn_create_beam(origin, point, 60, 0, 255, 0);	// Create green line from ID to ENT for 60 seconds
			formatex(text, charsmax(text), "Found entity in sphere (ent:%i class:%s)", ent, class);
			fn_log_cli(id, "FindEntityInSphere", text);
		}
	}
	return PLUGIN_HANDLED;
}

// FindClientInPVS
// This tutorial makes lines from a player to every entity found in PVS
public tut_FindClientInPVS(id)
{
	static Float:origin[3];
	static Float:point[3];
	static class[STR];
	static text[LOG];
	static ent, chain;

	pev(id, pev_origin, origin);
	pev(id, pev_view_ofs, point); 
	xs_vec_add(origin, point, origin);

	fn_log_cli(id, "FindClientInPVS", DIVISOR);

	ent = engfunc(EngFunc_EntitiesInPVS, id);
	while(ent)
	{
		chain = pev(ent, pev_chain);
		pev(ent, pev_origin, point);
		pev(ent, pev_classname, class, charsmax(class));
		if(!equal(class, ""))
		{
			fn_create_beam(origin, point, 60, 0, 0, 255);	// Create blue line from ID to ENT for 60 seconds
			formatex(text, charsmax(text), "Found entity in PVS (ent:%i class:%s)", ent, class);
			fn_log_con("FindClientInPVS", text);
		}

		if(!chain)
			break;

		ent = chain;
	}
	return PLUGIN_HANDLED;
}

// TraceLine
// This tutorial makes 2 lines, one of them stoping on entities.
public tut_TraceLine(id)
{
	static Float:origin[3];
	static Float:aim[3];
	static Float:point[3];
	static text[LOG];
	static const tr = 0;

	pev(id, pev_origin, origin);
	pev(id, pev_view_ofs, aim); 
	xs_vec_add(origin, aim, origin);

	fm_get_aim_origin(id, aim);
	// Multiply vector to make it larger
	xs_vec_sub(aim, origin, aim);
	xs_vec_mul_scalar(aim, 10.0, aim);
	xs_vec_add(origin, aim, aim);

	engfunc(EngFunc_TraceLine, origin, aim, 0, id, tr);

	fn_log_cli(id, "TraceLine", DIVISOR);
	fn_create_beam(origin, aim, 60, 255, 0, 0);	// Create red line from ID to aim point for 60 seconds
	formatex(text, charsmax(text), "Created red line to aim point");
	fn_log_cli(id, "TraceLine", text);

	get_tr2(tr, TR_vecEndPos, point);
	fn_create_beam(origin, point, 60, 0, 255, 0);	// Create green line from ID to hit point for 60 seconds
	formatex(text, charsmax(text), "Created green line to hit point");
	fn_log_cli(id, "TraceLine", text);

	return PLUGIN_HANDLED;
}

// TraceModel
// This tutorial makes one line to where you are aiming. The color of the line depends on the model you hit.
public tut_TraceModel(id)
{
	static Float:origin[3];
	static Float:aim[3];
	static Float:point[3];
	static class[STR];
	static text[LOG];
	static ent;
	static const tr = 0;

	pev(id, pev_origin, origin);
	pev(id, pev_view_ofs, aim); 
	xs_vec_add(origin, aim, origin);

	fm_get_aim_origin(id, aim);
	// Multiply vector to make it larger
	xs_vec_sub(aim, origin, aim);
	xs_vec_mul_scalar(aim, 2.0, aim);

	for(ent=g_maxClients+1; ent<g_maxEntities; ent++)
	{
		if(!pev_valid(ent))
			continue;

		pev(ent, pev_classname, class, charsmax(class));
		if(equal(class, "weaponbox") || equal(class, "armoury_entity") || equal(class, "player")
			|| equal(class, "func_breakable") || equal(class, "func_door"))
		{
			engfunc(EngFunc_TraceModel, origin, aim, HULL_POINT, ent, tr);
			if((ent > 0) && (get_tr2(tr, TR_pHit) == ent))
			{
				fn_log_cli(id, "TraceModel", DIVISOR);
				formatex(text, charsmax(text), "Found model by aim (ent:%i class:%s)", ent, class);
				fn_log_cli(id, "TraceModel", text);
				get_tr2(tr, TR_vecEndPos, point);
				fn_create_beam(origin, point, 60, 0, 255, 0);	// Create green line from ID to hit point for 60 seconds
			}
		}
	}

	return PLUGIN_HANDLED;
}

