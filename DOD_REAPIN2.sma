#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <dodx>
#include <dodfun>
#include <fun>
#include <engine>
#include <okapi>
#include <reapi>

/// переопределяем смещения 
// Linux extra offsets
#define linux_diff_weapon 4
#define linux_diff_player 5
#define linux_diff_animation 4

new g_idx_player 
new g_idx_camera

public OnPlayerKilled(filename[]) 
{
    
    if (equal(filename, "weapons/spring_shoot.wav"))
    {
        server_print( "Игрок %s", filename)
        return HC_BREAK
    }
    else 
       return HC_CONTINUE
}
public plugin_init()
{   


    server_print("ReAPI Runs :::::: ")
    register_think("iron_sight", "iron_sight_think")

    register_clcmd("say ss","set_Vmodel_")
    register_event("CurWeapon", "CurWeapon_Post_Check", "be", "1=1");
}

public set_Vmodel_(idx_player)
{
    server_print("ReAPI Runs :::::: ")
    
    set_entvar(idx_player,var_fov, 70.0)
    set_entvar(idx_player,var_viewmodel, "models/v_garand.mdl");
    target_create(idx_player)
    
}

public target_create(idx_player)
{     
        // new iOrigin[3];
        new iOrigin_target[3]; //  
        // get_user_origin(idx_player, iOrigin, 0); //    looks
        get_user_origin(idx_player, iOrigin_target, 1); //  
        // iOrigin_target[2] = iOrigin_target[2] + 20;
        new Float:fOrigin[3]; //   float 
        IVecFVec(iOrigin_target, fOrigin); //     

        //// CREATE ENITY 
        //engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "player"));
        //  new idx_target= create_entity("player");    
        new idx_target = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "trigger_camera"));
        server_print(" ENTITY CRETAED AS ID idx_target %d", idx_target )
        set_pev(idx_target, pev_classname, "iron_sight");
        set_pev(idx_target, pev_solid, SOLID_NOT);   
        set_pev(idx_target, pev_movetype, MOVETYPE_NONE);
        set_pev(idx_target, pev_owner, idx_player);

        
        entity_set_edict(idx_target, EV_ENT_owner, idx_player);

        set_pev(idx_target, pev_origin, fOrigin);
        engfunc(EngFunc_SetModel, idx_target, "models/v_garand.mdl")// 
        if(!pev_valid(idx_target)) 
        {
            return;
        }

        
        attach_view(idx_player, idx_target)

        g_idx_player = idx_player
        g_idx_camera = idx_target

        set_task(1.0, "retune_pl")
}

public retune_pl()
{

    
        message_begin(MSG_ONE, get_user_msgid("SetFOV"), _, g_idx_player);
        write_byte(60);
        message_end();

        entity_set_edict(g_idx_camera, EV_ENT_aiment, g_idx_player)
        set_pev(g_idx_camera, pev_nextthink, halflife_time() + 0.01)

        /*
        static Float:VEC_DUCK_VIEW[3] = {0.0, 0.0, 200.0}
        set_pev(g_idx_camera, pev_view_ofs, VEC_DUCK_VIEW)
        set_pev(g_idx_player, pev_flags, pev_flags | SF_CAMERA_PLAYER_TAKECONTROL);
        */
}


/*
SF_CAMERA_PLAYER_TAKECONTROL
*/

public iron_sight_think()
{
    static Float:flAngles[3]
    pev(g_idx_player, pev_angles, flAngles)
    // server_print(" Z== %f", flAngles[2])
    flAngles[0] *=(-1.0)  /// отредактировать Z // инвертировать. вохможно бралось из другой функции
    set_pev(g_idx_camera, pev_angles, flAngles)
    flAngles[0] *=(-1.0)
    set_pev(g_idx_camera, pev_v_angle, flAngles)

    set_pev(g_idx_camera, pev_nextthink, halflife_time() + 0.01)
}



public CurWeapon_Post_Check(id_owner)
{	
    if (!is_user_alive(id_owner)) return;
    new valie = get_pdata_int(id_owner, m_iWeaponVolume, linux_diff_player);
    new m_iWeaponVolume = 234
    
    server_print("VALIE d %d f %f s %s",  valie,valie,valie)
}
