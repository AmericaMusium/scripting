#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <fakemeta_util>
#include <dodx>
#include <dodfun>
#include <fun>
#include <engine>


#define PLUGIN "DOD CAMDROP"
#define VERSION "1.7 nov2022"
#define AUTHOR "[America][TheVaskov]"

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
    register_clcmd("say cd", "new_flycam")
}

public new_flycam(id)
{
    // Try to create a new entity
    new rocket = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
    if(!rocket) return PLUGIN_CONTINUE
    // Strings
    set_pev(rocket, pev_classname, "3dcamera")
    // engfunc(EngFunc_SetModel, rocket, ROCKET_MDL)
    // Integer
    set_pev(rocket, pev_owner, id)
    set_pev(rocket, pev_movetype, MOVETYPE_NOCLIP)
    set_pev(rocket, pev_solid, SOLID_BBOX)
    // Floats
    set_pev(rocket, pev_mins, Float:{-2.0, -2.0, -2.0})
    set_pev(rocket, pev_maxs, Float:{2.0, 2.0, 2.0})

    // Calculate start position and view of the rocket
    new Float:fAim[3], Float:fAngles[3], Float:fOrigin[3]
    velocity_by_aim(id, 20, fAim)
    vector_to_angle(fAim, fAngles)
    pev(id, pev_origin, fOrigin)

    
    fOrigin[0] += fAim[0]
    fOrigin[1] += fAim[1]
    fOrigin[2] += fAim[2]
    

    // Set the origin and view
    set_pev(rocket, pev_origin, fOrigin)
    set_pev(rocket, pev_angles, fAngles)

    // If we used secondary fire (mode 1), the user view's attached to the rocket
    // engfunc(EngFunc_SetView, id, rocket)
    cameratorocket(id, rocket)
    return PLUGIN_CONTINUE
}

public cameratorocket(id, rocket)
{
    fm_attach_view(id,rocket)

}
