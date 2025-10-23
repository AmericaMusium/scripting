#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>
#include <dodx>
#include <dodfun>
#include <fun>
#include <engine>
#include <fakemeta>

/// переопределяем смещения 
// Linux extra offsets
#define linux_diff_weapon 4
#define linux_diff_player 5
#define linux_diff_animation 4
#define m_pActiveItem 278 		// возвращает Entity idx оружия в руках (не константу) + linux_diff_player

new g_entvmdl;
public plugin_init()
{
	register_clcmd("say 13", "customize_players_v_model");
}

public plugin_precache()
{
   g_entvmdl= precache_model("models/wmod/v_ksg12.mdl")
}
public customize_players_v_model(idx_player)
{   

    new activeitem =  get_pdata_cbase(idx_player, m_pActiveItem, linux_diff_player);
    entity_set_string(idx_player, EV_SZ_viewmodel, "models/wmod/v_ksg12.mdl");
    set_pev( g_entvmdl , pev_skin, 1);

}