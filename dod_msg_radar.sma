#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>
#include <engine>
#include <dodx>
#include <dodfun>

/*

[Ent 3] Set CD_PunchAngle Vector to {0.000000, 0.000000, 0.000000} крутит камеру игрока

[Ent 3] Set CD_flNextAttack Float to 2.000000  делает выстрел, без звука и вспышки, тратит патроны, наносит урон

ES_Team  показывает на радаре других игроков 1 .. 0 никого 

	"pev_view_ofs", высота камеры игрока йода

    pev_nextthink на плеере респауник игрока быстро

    pev_viewmodel2
*/



//* PvData Offsets.                            *


// Linux extra offsets
#define extra_offset_weapon		4
#define linux_diff_player		5


#define m_iHideHUD 265
#define m_iClientHideHUD 268
#define m_iClientFOV 269
#define m_pActiveItem 278 

public plugin_init()
{
	register_plugin("RADAR MESS", "0.1", "America")

    register_clcmd("say 00", "test_func")    
    register_forward(FM_AddToFullPack, "Fw__AddToFullPack", 1)


}

public test_func(id_owner)
{

    new activeitem = get_pdata_cbase(id_owner, m_pActiveItem, linux_diff_player);
    new item_classname[32]
    pev(activeitem, pev_classname, item_classname, 31) 

    client_print(id_owner, print_chat, "item: %d :: %s :: owner %d", activeitem, item_classname , id_owner)
 
    new mdlar[72]
    pev(id_owner, pev_model, mdlar, sizeof mdlar - 1)
    new mdlar2[72]
    pev(id_owner, pev_viewmodel, sizeof mdlar2 - 1)
    

    // engfunc(EngFunc_SetView, id_owner, activeitem)


    engfunc(EngFunc_CrosshairAngle, id_owner, random_float(-1.0,1.0), random_float(-100.0,100.0))


}

/////////////////////////////
public Fw__AddToFullPack(es, e, iEntity, iHost, iHostFlags, iPlayer, pSet)
{   
    if(!is_valid_ent(iEntity))
    {
        return 0;
    }

    new item_classname[32]
    pev(iEntity, pev_classname, item_classname, 31) 
       if(!(equali(item_classname, "weapon_scopedkar")))
	{
          return 0;
    }

   
    set_es(es, ES_RenderMode, kRenderTransAlpha)
    set_es(es, ES_RenderAmt, 150.0)

			

    
}