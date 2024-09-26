/* AMX Mod X
*   Anti Silent Run
*
* (c) Copyright 2007 by VEN
*
* This file is provided as is (no warranties)
*
*	DESCRIPTION
*		Plugin resets player speed on double duck to prevent silent run exploit.
*
*	VERSIONS
*		0.1.2
*			- fixed: speed was reset on fall duck
*		0.1.1
*			- fixed: speed was reset on jump duck
*		0.1
*			- initial version
*/

// plugin's main information
#define PLUGIN_NAME "Anti Silent Run"
#define PLUGIN_VERSION "0.1.2"
#define PLUGIN_AUTHOR "VEN"

#include <amxmodx>
#include <fakemeta>

#define MAX_CLIENTS 32
new Float:g_view_ofs[MAX_CLIENTS + 1][3]

#define VEC_VIEW 17.0
#define VEC_DUCK_VIEW 12.0

new const g_player_hull[] = {
	HULL_HUMAN,
	HULL_HEAD
}

public plugin_init() {
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)
	register_forward(FM_PlayerPreThink, "fwPlayerPreThink")
	register_forward(FM_PlayerPostThink, "fwPlayerPostThink")
}

public fwPlayerPreThink(id) {
	if (!is_user_alive(id) || !(pev(id, pev_button) & IN_DUCK))
		return FMRES_IGNORED

	pev(id, pev_view_ofs, g_view_ofs[id])

	return FMRES_HANDLED
}

public fwPlayerPostThink(id) {
	if (g_view_ofs[id][2] != VEC_VIEW || !is_user_alive(id) || !(pev(id, pev_button) & IN_DUCK) || pev(id, pev_fuser2))
		return FMRES_IGNORED

	pev(id, pev_view_ofs, g_view_ofs[id])
	if (g_view_ofs[id][2] != VEC_DUCK_VIEW)
		return FMRES_IGNORED

	static Float:vec1[3], Float:vec2[3], Float:size_z
	pev(id, pev_size, vec1)
	size_z = vec1[2]
	pev(id, pev_origin, vec1)
	vec2[0] = vec1[0]
	vec2[1] = vec1[1]
	vec2[2] = -9999.0

	engfunc(EngFunc_TraceHull, vec1, vec2, IGNORE_MONSTERS, g_player_hull[!!(pev(id, pev_flags) & FL_DUCKING)], id, 0)
	get_tr2(0, TR_vecEndPos, vec2)
	if (vec1[2] - vec2[2] > size_z)
		return FMRES_IGNORED

	pev(id, pev_velocity, vec1)
	vec1[0] = 0.0
	vec1[1] = 0.0
	set_pev(id, pev_velocity, vec1)

	return FMRES_HANDLED
}
