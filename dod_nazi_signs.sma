/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <fakemeta_util>
#include <dodx>
#include <dodfun>
#include <fun>
#include <engine>

#define PLUGIN "NAZI_SIGNS"
#define VERSION "1.0"
#define AUTHOR "[America][TheVaskov]"


new const g_szMdlNazi[] = "models/red/nazi_body.mdl"

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_clcmd("say nazi", "SetNazi")
	
	// Add your code here...
}

public plugin_precache()
{
	precache_model("models/red/nazi_body.mdl")

}

public SetNazi(pPlayer){
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

   // return pEntity;
  }
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1049\\ f0\\ fs16 \n\\ par }
*/
