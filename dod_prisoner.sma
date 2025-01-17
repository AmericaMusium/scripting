/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <fun>

#define PLUGIN "DoD Prisoner Mod"
#define VERSION "1.0"
#define AUTHOR "29th ID"

new g_cvarEnabled;
new grabbed[33], grablength[33], bool:prisoner[33];
new velocity_multiplier;

public plugin_init() {
	register_plugin( PLUGIN, VERSION, AUTHOR );
	register_forward( FM_Touch, "hook_Touch" );
	register_forward( FM_AddToFullPack, "hook_AddToFullPack", 1 );
	
	g_cvarEnabled = register_cvar( "dod_prisoner", "1" );
}

public hook_Touch( ptr, ptd ) {
	if( !get_pcvar_num( g_cvarEnabled ) || !is_user_alive( ptr ) || !is_user_alive( ptd ) || prisoner[ptr] )
		return PLUGIN_CONTINUE;
	new ptr_team = get_user_team(ptr);
	new ptd_team = get_user_team(ptd);
	new weapons[32], num;
	get_user_weapons(ptr,weapons,num);
	if( !num || ptr_team == ptd_team )
		return PLUGIN_CONTINUE;
	
	// Get Grabber's button bitmask
	static button;
	button = pev( ptr, pev_button );
	
	// Get Grabbed's velocity to see if he's standing still
	new m_grabbed_vel[3];
	pev( ptd, pev_velocity, m_grabbed_vel );
	
	// (!m_grabbed_vel[0] && !m_grabbed_vel[1] && !m_grabbed_vel[2])
	if( button & IN_USE && (!m_grabbed_vel[0] && !m_grabbed_vel[1] && !m_grabbed_vel[2]) )
	{
		new parm[1]
		parm[0] = ptr
		velocity_multiplier = 8
		set_task(0.1, "grabtask", 100+ptr, parm, 1, "b")
		set_grabbed(ptr, ptd)
	}
	
	return PLUGIN_CONTINUE;
}

public grabtask(parm[])
{
	new id = parm[0]
	if (grabbed[id])
	{
		new origin[3], look[3], direction[3], moveto[3], grabbedorigin[3], velocity[3], length

		if (!is_user_alive(grabbed[id]))
		{
			//release(id)
			return
		}

		get_user_origin(id, origin, 1)
		get_user_origin(id, look, 1)
		get_user_origin(grabbed[id], grabbedorigin)

		direction[0]=look[0]-origin[0]
		direction[1]=look[1]-origin[1]
		direction[2]=look[2]-origin[2]
		length = get_distance(look,origin)
		if (!length) length=1				// avoid division by 0

		moveto[0]=origin[0]+direction[0]*grablength[id]/length
		moveto[1]=origin[1]+direction[1]*grablength[id]/length
		moveto[2]=origin[2]+direction[2]*grablength[id]/length
		
		velocity[0]=(moveto[0]-grabbedorigin[0])*velocity_multiplier
		velocity[1]=(moveto[1]-grabbedorigin[1])*velocity_multiplier
		velocity[2]=(moveto[2]-grabbedorigin[2])*velocity_multiplier

		new Float:vector[3]
		IVecFVec(velocity, vector)
		set_pev( grabbed[id], pev_velocity, vector );
	}
	// Check to see if grabber is still holding USE
	if( !(pev(id, pev_button) & IN_USE) )
	{
		prisoner[grabbed[id]]=false;
		grabbed[id]=0
		remove_task(100+id)
	}
}

public set_grabbed(id, targetid)
{
	new origin1[3], origin2[3]
	get_user_origin(id, origin1)
	get_user_origin(targetid, origin2)
	grabbed[id]=targetid
	prisoner[targetid]=true;
	grablength[id]=get_distance(origin1,origin2)
	strip_user_weapons( targetid );
	client_print( targetid, print_center, "You have been taken prisoner" );
}

public hook_AddToFullPack( es_handle, e, id, host, hostflags, player, pSet ) {
	if( !player || !is_user_alive( id ) || !prisoner[id] ) return FMRES_IGNORED;
	
	set_es( es_handle, ES_Sequence, 190 );
	set_es( es_handle, ES_Frame, float( -1 ) );
	set_es( es_handle, ES_FrameRate, float( 0 ) );
	
	return FMRES_IGNORED;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1049\\ f0\\ fs16 \n\\ par }
*/
