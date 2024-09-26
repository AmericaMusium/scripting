#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <fakemeta_util>
#include <dodx>
#include <dodfun>
#include <fun>
#include <engine>

#define PLUGIN "Head Guerilla"
#define VERSION "1.0"
#define AUTHOR "[America][TheVaskov]"

new g_prt_head[33]


new const g_szMdlNazi[] = "models/misc/hguerilla.mdl"

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_clcmd("say guer", "Set_Head")

	// Add your code here...
}

public plugin_precache()
{
	precache_model("models/misc/hguerilla.mdl")

}

public Set_Head(pPlayer){
    if(g_prt_head[pPlayer]!=0)
    {
        remove_entity(g_prt_head[pPlayer])
        g_prt_head[pPlayer] =0 
        client_print(pPlayer , print_chat, "guer off")
        return
    }
	static s_ptrClassname = 0;
    if (!s_ptrClassname) {
        s_ptrClassname = engfunc(EngFunc_AllocString, "info_target");
    }

    new pEntity = engfunc(EngFunc_CreateNamedEntity, s_ptrClassname);
    dllfunc(DLLFunc_Spawn, pEntity);

    set_pev(pEntity, pev_classname, "nazi_sleeve");
    engfunc(EngFunc_SetModel, pEntity, g_szMdlNazi);
    set_pev(pEntity, pev_owner, pPlayer);
    set_pev(pEntity, pev_aiment, pPlayer);
    set_pev(pEntity, pev_movetype, MOVETYPE_FOLLOW);
    // set_pev(pEntity, pev_skin, get_member(pPlayer, m_iTeam));

    g_prt_head[pPlayer] = pEntity
    client_print(pPlayer , print_chat, "guer on")
   // return pEntity;
  }
