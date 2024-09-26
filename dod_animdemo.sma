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

#define PLUGIN "animdemo"
#define VERSION "1.0"
#define AUTHOR "[America][TheVaskov]"


#define ACT_RANGE_ATTACK1   28

// Linux extra offsets
#define extra_offset_animating   4
#define extra_offset_player 5

// CBaseAnimating
#define m_flFrameRate      36
#define m_flGroundSpeed      37
#define m_flLastEventCheck   38
#define m_fSequenceFinished   39
#define m_fSequenceLoops   40

// CBaseMonster
#define m_Activity      73
#define m_IdealActivity      74

// CBasePlayer
#define m_flLastAttackTime   220


public plugin_init() {
register_plugin(PLUGIN, VERSION, AUTHOR)

register_clcmd("say anna", "SetAnna")

// Add your code here...
}

public plugin_precache()
{
precache_model("models/red/nazi_body.mdl")

}

public SetAnna(pPlayer){

	Player_SetAnimation(pPlayer, 26);
}


stock Player_SetAnimation(iPlayer, anim)
{


new Float:flFrameRate, Float:flGroundSpeed, bool:bLoops

// Fucking Hard code value xD

lookup_sequence(iPlayer, "death1", flFrameRate, bLoops, flGroundSpeed)

static Float:flGametime; flGametime = get_gametime()

set_pev(iPlayer, pev_frame, 0.0)

set_pev(iPlayer, pev_framerate, 0.20)

set_pev(iPlayer, pev_animtime, flGametime)
set_pev(iPlayer, pev_sequence, anim)
set_pev(iPlayer, pev_gaitsequence, anim)

set_pdata_int(iPlayer, m_fSequenceLoops, bLoops, extra_offset_animating)
set_pdata_int(iPlayer, m_fSequenceFinished, 0, extra_offset_animating)

set_pdata_float(iPlayer, m_flFrameRate, flFrameRate, extra_offset_animating)
set_pdata_float(iPlayer, m_flGroundSpeed, flGroundSpeed, extra_offset_animating)
set_pdata_float(iPlayer, m_flLastEventCheck, flGametime , extra_offset_animating)

set_pdata_int(iPlayer, m_Activity, ACT_RANGE_ATTACK1, extra_offset_player)
set_pdata_int(iPlayer, m_IdealActivity, ACT_RANGE_ATTACK1, extra_offset_player)  
set_pdata_float(iPlayer, m_flLastAttackTime, flGametime , extra_offset_player)
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1049\\ f0\\ fs16 \n\\ par }
*/
