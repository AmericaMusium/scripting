#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <fakemeta_util>
#include <dodx>
#include <dodfun>
#include <fun>
#include <engine>
#pragma semicolon 1


#define PLUGIN "Helloween"
#define VERSION "0.0"
#define AUTHOR "[America][TheVaskov]"


new const sz_mdl_hats[] = "models/ck/!pump_head.mdl";
new const sz_sound_witch[] = "ck/ck_witch.wav";


new my_hat[33];

public plugin_precache()
{
    precache_model(sz_mdl_hats);
    precache_sound(sz_sound_witch);
}

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR);

    register_clcmd("say nazi", "Hat_Set");

}


public client_putinserver(id) 
{
    Hat_Set(id);
}

public Hat_Set(idx_Player)
{
    static s_ptrClassname = 0;
    if (!s_ptrClassname) {
        s_ptrClassname = engfunc(EngFunc_AllocString, "info_target");
    }

    new pEntity = engfunc(EngFunc_CreateNamedEntity, s_ptrClassname);
    dllfunc(DLLFunc_Spawn, pEntity);

    set_pev(pEntity, pev_classname, "nazi_sleeve");
    engfunc(EngFunc_SetModel, pEntity, sz_mdl_hats);
    set_pev(pEntity, pev_owner, idx_Player);
    set_pev(pEntity, pev_aiment, idx_Player);
    set_pev(pEntity, pev_movetype, MOVETYPE_FOLLOW);

    my_hat[idx_Player] = pEntity;
    // set_pev(pEntity, pev_skin, get_member(pPlayer, m_iTeam));

    // return pEntity;
}

public client_death(idx_killer, idx_victim, id_weapon, hitplace, TK)
{
    if( id_weapon ==  DODW_AMERKNIFE ||
    id_weapon ==  DODW_GERKNIFE ||
    id_weapon ==  DODW_SPADE ||
    id_weapon ==  DODW_BRITKNIFE
    )
    {

        emit_sound(idx_killer, CHAN_AUTO, sz_sound_witch , 0.5, ATTN_NORM, 0, PITCH_NORM);
    }

}
/*



        g_bwEnt[player] = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
        if(g_bwEnt[player] > 0)
        {
                UserHaveHatWith[player] = 'n'
                new mdlName[256]
                new CsTeams:team = cs_get_user_team(player)       
                formatex(UserHatModel[player], 255, "%s", HATMDL[imodelnum])
                set_pev(g_bwEnt[player], pev_movetype, MOVETYPE_FOLLOW)
                set_pev(g_bwEnt[player], pev_aiment, player)
                set_pev(g_bwEnt[player], pev_rendermode, kRenderNormal)
                set_pev(g_bwEnt[player], pev_renderamt, 0.0)
                engfunc(EngFunc_SetModel, g_bwEnt[player], mdlName)
        }


*/