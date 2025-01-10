#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <engine>
#include <dodx>
#include <dodfun>

#pragma semicolon 1

#define PLUGIN_VERSION			"1.0"

#define AMBIENT_SOUND_LARGERADIUS	8

new const szChristmasTreeModels[][] =
{
	"models/475/475xtr.mdl",
    "models/475/475xtr.mdl"
};

new const szChristmasTreeSong[] = "misc/ks_batotai.wav";

public plugin_init()
{
	register_plugin("Cristmas Tree", PLUGIN_VERSION, "tuty");
	RegisterHam(Ham_Think, "ambient_generic", "bacon_TreeThink", true);
}

public plugin_cfg() {
	UTIL_FindSpawnPoints();
}

public plugin_precache()
{
	for(new i = 0; i < sizeof szChristmasTreeModels; i++)
		precache_model(szChristmasTreeModels[i]);
	
	precache_sound(szChristmasTreeSong);
}

public bacon_TreeThink(iEntity) {
	if(pev_valid(iEntity))
	{
		set_pev(iEntity, pev_nextthink, get_gametime() + 0.8);
		
		static Float:flOrigin[3];
		pev(iEntity, pev_origin, flOrigin);

		UTIL_DynamicLight(flOrigin, random(255), random(255), random(255), 255 );
		set_rendering(iEntity, kRenderFxGlowShell, random(255), random(255), random(255), kRenderNormal, random_num(1, 50));
	}
}

UTIL_FindSpawnPoints()
{
	new iCounterTerroristSpawn = engfunc( EngFunc_FindEntityByString, FM_NULLENT, "classname", "dod_control_point");

	if(!iCounterTerroristSpawn)
		return;
	
	new Float:flCounterTerroristOrigin[3];
	pev(iCounterTerroristSpawn, pev_origin, flCounterTerroristOrigin);
	
	UTIL_CreateChristmasTree(flCounterTerroristOrigin);
	
	new iTerroristSpawn = engfunc(EngFunc_FindEntityByString, FM_NULLENT, "classname", "dod_control_point");
	
	if( !iTerroristSpawn )
		return;
	
	new Float:flTerroristOrigin[3];
	pev(iTerroristSpawn, pev_origin, flTerroristOrigin);
	
	UTIL_CreateChristmasTree(flTerroristOrigin);
}

UTIL_CreateChristmasTree(Float:flOrigin[3]) 
{	
	new iEntity = engfunc(EngFunc_CreateNamedEntity, engfunc( EngFunc_AllocString, "ambient_generic"));
	
	if(!pev_valid(iEntity))
		return;

	new Float:flAngles[3];
	flAngles[1] += random_float(1.0, 360.0);

	set_pev(iEntity, pev_message, szChristmasTreeSong);
	set_pev(iEntity, pev_spawnflags, AMBIENT_SOUND_LARGERADIUS);
	set_pev(iEntity, pev_effects, EF_BRIGHTFIELD);
	set_pev(iEntity, pev_origin, flOrigin);
	set_pev(iEntity, pev_movetype, MOVETYPE_TOSS);
	set_pev(iEntity, pev_health, 1.0);
	set_pev(iEntity, pev_angles, flAngles);
	set_pev(iEntity, pev_nextthink, get_gametime() + 0.8);
	
	ExecuteHam(Ham_Spawn, iEntity);

	engfunc(EngFunc_SetModel, iEntity, szChristmasTreeModels[random_num(0, charsmax(szChristmasTreeModels))]);
	engfunc(EngFunc_DropToFloor, iEntity);
}

UTIL_DynamicLight(Float:flOrigin[3], r, g, b, a)
{
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, flOrigin);
	write_byte(TE_DLIGHT);
	engfunc(EngFunc_WriteCoord, flOrigin[0]);
	engfunc(EngFunc_WriteCoord, flOrigin[1]);
	engfunc(EngFunc_WriteCoord, flOrigin[2]);
	write_byte(30);
	write_byte(r);
	write_byte(g);
	write_byte(b);
	write_byte(a);
	write_byte(40);
	message_end();
}