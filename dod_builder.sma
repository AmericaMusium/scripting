#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>
#include <fun>
#include <dodx>
#include <dodfun>
#include <hamsandwich>

new const W_MODEL1[] = "models/mapmodels/barbed_wire.mdl"
new const V_HAMMER[] = "models/v_hammer.mdl"
new const WIRE_CLSNAME[32] = "wire_guard"

public plugin_init()
{
    register_plugin("DOD BUILDER", "0.0", "America")
    register_clcmd("say bb", "debug_create_entity")

    register_touch(WIRE_CLSNAME,"player","debug_wire_touch_p")
}

public plugin_precache()
{
precache_model(W_MODEL1)
precache_model(V_HAMMER)
}


public debug_create_entity(idx_player)
{

    new iOrigin[3] //    
    new iOrigin1[3] //  
    get_user_origin(idx_player, iOrigin, 0) //    origin zero
    get_user_origin(idx_player, iOrigin1, 3) //   looks to


    iOrigin1[2] += 50
    new Float:fOrigin[3] //   float 
    IVecFVec(iOrigin1, fOrigin) //     

    //// CREATE ENITY 
    new idx_wire = create_entity("info_target")	
    set_pev(idx_wire, pev_classname, WIRE_CLSNAME) 

   
    set_pev(idx_wire, pev_solid, SOLID_TRIGGER)   
    set_pev(idx_wire, pev_movetype, MOVETYPE_STEP)
    // set_pev(idx_wire, pev_effects, EF_NODRAW)


    

    set_pev(idx_wire, pev_origin, fOrigin)

    debug_set_size(idx_wire , Float:{-160.0, -160.0, -16.0}, Float:{160.0, 160.0, 160.0});

    // Если нужно что бы разбивалось от пули , надо менять на 
    // SOLID_BBOX и менять точку старта, а то задевае игрока
    // set_pev(idx_wire, pev_health, 1.0);
    // set_pev(idx_wire, pev_takedamage, DAMAGE_YES);

    entity_set_edict(idx_wire, EV_ENT_owner, idx_player)

    emit_sound(idx_player ,CHAN_VOICE,"weapons/bazookareloadgetrocket.wav",1.0,ATTN_NORM,0,PITCH_NORM) //  
    engfunc(EngFunc_SetModel, idx_wire, W_MODEL1) // 
    




}

public debug_wire_touch_p(idx_wire, idx_player)
{
    client_print(0 , print_chat, "TPUCH WIREEEE ")
}

public debug_set_size(idx_wire, Float:mins[3], Float:maxs[3])
{

    engfunc(EngFunc_SetSize, idx_wire, mins, maxs)

}