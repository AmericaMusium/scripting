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

#define PLUGIN "DOD IRON SIGHT"
#define VERSION "1.2"
#define AUTHOR "[America][TheVaskov]"


new const g_szMdlPArtifact[] = "models/red/jacket_2.mdl";



new bool:acceptzoom[33] // Accept to zoom rifle

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_clcmd("say jack", "Jacket_Create")

	
	// Add your code here...
}

public plugin_precache()
{
	precache_model("models/red/jacket_2.mdl")

}

static bool:g_i_status[33]
public client_connect(i_player)
	g_i_status[i_player]=false

public client_PostThink(i_player){
	
	if(pev(i_player,pev_button)&IN_ATTACK2)
	{
		if(g_i_status[i_player]==false)
		{
			g_i_status[i_player]=true // �����  i_player ������ +attack2
			
			
			acceptzoom[i_player]=false
			new knifetype = get_user_weapon(i_player,_,_)
			if(knifetype == 10 ){
				
				
				client_cmd(i_player,"say iron sight")
				// dod_weapon_type(i_player, 3)
				
				acceptzoom[i_player]=true
				
				// PLUGIN_HANDLED
			}
		}
	}      
	else {
		if(g_i_status[i_player]==true)
		{
			g_i_status[i_player]=false // ����� i_player ������ -attack2
			
		}
	}
}



public Jacket_Create(pPlayer) {
    static s_ptrClassname = 0;
    if (!s_ptrClassname) {
        s_ptrClassname = engfunc(EngFunc_AllocString, "info_target");
    }

    new pEntity = engfunc(EngFunc_CreateNamedEntity, s_ptrClassname);
    dllfunc(DLLFunc_Spawn, pEntity);

    set_pev(pEntity, pev_classname, "player_downjacket");
    engfunc(EngFunc_SetModel, pEntity, g_szMdlPArtifact);
    set_pev(pEntity, pev_owner, pPlayer);
    set_pev(pEntity, pev_aiment, pPlayer);
    set_pev(pEntity, pev_movetype, MOVETYPE_FOLLOW);
    // set_pev(pEntity, pev_skin, get_member(pPlayer, m_iTeam));

   // return pEntity;
}
