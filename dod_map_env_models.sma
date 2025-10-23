#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>


new const sz_map_model[][] = 
{	
	"models/1944/donner_cube.mdl",
}


public plugin_precache()
{
    engfunc(EngFunc_PrecacheModel, sz_map_model[0]);
}

public plugin_init()
{
    register_plugin("DOD MAP ENV MODELS", "0.0", "America/TheVaskov");
    env_model_create();
}


public env_model_create()
{
	new iEntity = create_entity("info_target");
	
	if(!pev_valid(iEntity))
		return;
	
	set_pev(iEntity, pev_classname, "tupe");
	set_pev(iEntity, pev_movetype, MOVETYPE_NOCLIP);
	set_pev(iEntity, pev_solid, SOLID_NOT);
	set_pev(iEntity, pev_sequence, 0);
	set_pev(iEntity, pev_angles, {0.0, 0.0, 0.0});

	set_pev(iEntity, pev_rendermode, kRenderTransTexture); // Render alpha
	set_pev(iEntity, pev_renderamt, 200.0); // 100 наверно крайнее значение
	set_pev(iEntity, pev_renderfx, kRenderFxNone); // kRenderFxFadeFast 2 
	set_pev(iEntity, pev_rendercolor, {0.0, 0.0, 0.0} );
    engfunc(EngFunc_SetModel, iEntity, sz_map_model[0]);
    
    set_pev(iEntity, pev_angles, {0.0, 0.0, 0.0});
    engfunc(EngFunc_SetOrigin, iEntity,	{0.0, 0.0, 0.0});
    engfunc(EngFunc_SetSize, iEntity, Float:{-4096.0, -4096.0, -4096.0}, Float:{4096.0, 4096.0, 4096.0});

}

