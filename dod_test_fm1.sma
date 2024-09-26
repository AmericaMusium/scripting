#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <dodx>
#include <dodfun>

#define PLUGIN "Dod MapSettings"
#define VERSION "1.0"
#define AUTHOR "29th ID"
new g_ent

new bool:g_get_info = false

new i_ES_EntityType
new i_ES_Number
new float:f_ES_MsgTime
new i_ES_MessageNum
new float:f_ES_Origin[3]
new float:f_ES_Angles[3]
new i_ES_ModelIndex
new i_ES_Sequence
new float:f_ES_Frame


///  gpt helper 
new i_ES_ColorMap, i_ES_Skin, i_ES_Solid, i_ES_Effects, i_ES_eFlags, i_ES_RenderMode, i_ES_RenderAmt, i_ES_RenderColor[3], i_ES_Body, i_ES_Controller[4], i_ES_Blending[4];
new i_ES_RenderFx, i_ES_MoveType;
new Float:f_ES_Scale, f_ES_AnimTime, f_ES_FrameRate, f_ES_Velocity[3], f_ES_Mins[3], f_ES_Maxs[3];

new i_ES_Spectator , i_ES_WeaponAnim
new i_ES_AimEnt, i_ES_Owner, i_ES_Team, i_ES_PlayerClass, i_ES_Health, i_ES_WeaponModel, i_ES_GaitSequence, i_ES_UseHull, i_ES_OldButtons, i_ES_OnGround, i_ES_iStepLeft, i_ES_iUser1, i_ES_iUser2, i_ES_iUser3, i_ES_iUser4;
new Float:f_ES_Friction, f_ES_Gravity, f_ES_BaseVelocity[3], f_ES_flFallVelocity, f_ES_FOV, f_ES_WeaponAnim, f_ES_StartPos[3], f_ES_EndPos[3], f_ES_ImpactTime, f_ES_StartTime, f_ES_fUser1, f_ES_fUser2, f_ES_fUser3, f_ES_fUser4;
new Float:f_ES_vUser1[3], f_ES_vUser2[3], f_ES_vUser3[3], f_ES_vUser4[3];



// Done in precache so it is caught before the entities are spawned
public plugin_precache() {
	
	
}

// Done in init to remove entities that were already created
public plugin_init() {
	register_plugin("DOD FM TEST", "0.0", "00")
 
    // register_forward(FM_ServerPrint, "forward_FM_ServerPrint") // works
    register_forward(FM_AddToFullPack, "forward_FM_AddToFullPack")
    

}


public forward_FM_ServerPrint(const string[])
{
    server_print("FM_ServerPrint :: %s" , string)
}


public forward_FM_AddToFullPack(es, e, ent, host, hostflags, player, pSet)
{

    // (struct entity_state_s *state, int e, edict_t *ent, edict_t *host, int hostflags, int player, unsigned char *pSet);
	// You can pass in 0 for global usercmd handle or another usercmd handle here
    /*

        Return 1 if the entity state has been filled in for the ent and the entity will be propagated to the client, 0 otherwise

        state is the server maintained copy of the state info that is transmitted to the client 
        es == 210060352

        a MOD could alter values copied into state to send the "host" a different look for a particular entity update, etc.
        e and ent are the entity that is being added to the update, if 1 is returned
        host is the player's edict of the player whom we are sending the update to
        player is 1 if the ent/e is a player and 0 otherwise
        pSet is either the PAS or PVS that we previous set up.  We can use it to ask the engine to filter the entity against the PAS or PVS.
        we could also use the pas/ pvs that we set in SetupVisibility, if we wanted to.  Caching the value is valid in that case, but still only for the current frame

    

*/      
    new weaponame[64]


    if (pev_valid(ent))
    {   
        
        pev(ent,pev_classname,weaponame,31)
		// if (equal(weaponame, "weapon_scopedkar"))
        if (equal(weaponame, "weapon_scopedkar"))
        {	

			
            new search_object = es
			get_es( search_object, ES_EntityType , i_ES_EntityType );
            get_es( search_object, ES_Number , i_ES_Number );
            get_es( search_object, ES_MsgTime , f_ES_MsgTime );
            get_es( search_object, ES_MessageNum , i_ES_MessageNum );
            get_es( search_object, ES_Origin , f_ES_Origin );
            get_es( search_object, ES_Angles , f_ES_Angles );
            get_es( search_object, ES_ModelIndex , i_ES_ModelIndex );
            get_es( search_object, ES_Sequence , i_ES_Sequence );
            get_es( search_object, ES_Frame , f_ES_Frame );


			get_es( search_object, ES_ColorMap , i_ES_ColorMap );
			get_es( search_object, ES_Skin , i_ES_Skin );
			get_es( search_object, ES_Solid , i_ES_Solid );
			get_es( search_object, ES_Effects , i_ES_Effects );
			get_es( search_object, ES_Scale , f_ES_Scale );
			get_es( search_object, ES_eFlags , i_ES_eFlags );

			get_es( search_object, ES_RenderMode , i_ES_RenderMode );
			get_es( search_object, ES_RenderAmt , i_ES_RenderAmt );
			get_es( search_object, ES_RenderColor , i_ES_RenderColor ); // int[3] 
			get_es( search_object, ES_RenderFx , i_ES_RenderFx );


			get_es( search_object, ES_MoveType , i_ES_MoveType ); 
			get_es( search_object, ES_AnimTime , f_ES_AnimTime ); 
			get_es( search_object, ES_FrameRate , f_ES_FrameRate ); 
			get_es( search_object, ES_Body , i_ES_Body ); 
			get_es( search_object, ES_Controller , i_ES_Controller ); // int[4]
			get_es( search_object, ES_Blending , i_ES_Blending ); // int[4]
			get_es( search_object, ES_Velocity , f_ES_Velocity ); // float[3]


			get_es( search_object, ES_Mins , f_ES_Mins ); // float array[3]
			get_es( search_object, ES_Maxs , f_ES_Maxs ); // float array[3]


			get_es( search_object, ES_AimEnt, i_ES_AimEnt);
			get_es( search_object, ES_Owner, i_ES_Owner);
			get_es( search_object, ES_Friction, f_ES_Friction);
			get_es( search_object, ES_Gravity, f_ES_Gravity);
			get_es( search_object, ES_Team, i_ES_Team);
			get_es( search_object, ES_PlayerClass, i_ES_PlayerClass);
			get_es( search_object, ES_Health, i_ES_Health);
			get_es( search_object, ES_Spectator, i_ES_Spectator); // Assuming bool is represented as b_ES_Spectator
			get_es( search_object, ES_WeaponModel, i_ES_WeaponModel);
			get_es( search_object, ES_GaitSequence, i_ES_GaitSequence);
			get_es( search_object, ES_BaseVelocity, f_ES_BaseVelocity); // float array[3]
			get_es( search_object, ES_UseHull, i_ES_UseHull);
			get_es( search_object, ES_OldButtons, i_ES_OldButtons);
			get_es( search_object, ES_OnGround, i_ES_OnGround);
			get_es( search_object, ES_iStepLeft, i_ES_iStepLeft);
			get_es( search_object, ES_flFallVelocity, f_ES_flFallVelocity);
			get_es( search_object, ES_FOV, f_ES_FOV);
			get_es( search_object, ES_WeaponAnim, i_ES_WeaponAnim);
			get_es( search_object, ES_StartPos, f_ES_StartPos); // float array[3]
			get_es( search_object, ES_EndPos, f_ES_EndPos); // float array[3]
			get_es( search_object, ES_ImpactTime, f_ES_ImpactTime);
			get_es( search_object, ES_StartTime, f_ES_StartTime);
			get_es( search_object, ES_iUser1, i_ES_iUser1);
			get_es( search_object, ES_iUser2, i_ES_iUser2);
			get_es( search_object, ES_iUser3, i_ES_iUser3);
			get_es( search_object, ES_iUser4, i_ES_iUser4);
			get_es( search_object, ES_fUser1, f_ES_fUser1);
			get_es( search_object, ES_fUser2, f_ES_fUser2);
			get_es( search_object, ES_fUser3, f_ES_fUser3);
			get_es( search_object, ES_fUser4, f_ES_fUser4);
			get_es( search_object, ES_vUser1, f_ES_vUser1); // float array[3]
			get_es( search_object, ES_vUser2, f_ES_vUser2); // float array[3]
			get_es( search_object, ES_vUser3, f_ES_vUser3); // float array[3]
			get_es( search_object, ES_vUser4, f_ES_vUser4); // float array[3]


			set_es(es, ES_FOV, 100.0)

			return FMRES_OVERRIDE   ; // ВЛИЯЕТ 

			// return FMRES_SUPERCEDE;

			/*

			server_print("_____es: %d e %d ent %d host %d  hostflags %d  player %d pSet %d ", es, e, ent, host, hostflags, player, pSet)
            server_print("type: %d numb %d MsgTime: %f , MsgNum: %d  ", i_ES_EntityType , i_ES_Number , f_ES_MsgTime , i_ES_MessageNum )
            server_print("ES_Origin: %f %f %f  ES_Angles %f %f %f ", f_ES_Origin[0] , f_ES_Origin[1] , f_ES_Origin[2] , f_ES_Angles[0] , f_ES_Angles[1] , f_ES_Angles[2])
            
			
			server_print("ColorMap: %d Skin: %d Solid: %d Effects: %d Scale: %f eFlags: %d", i_ES_ColorMap, i_ES_Skin, i_ES_Solid, i_ES_Effects, f_ES_Scale, i_ES_eFlags);
			server_print("RenderMode: %d RenderAmt: %d RenderColor: %d %d %d RenderFx: %d", i_ES_RenderMode, i_ES_RenderAmt, i_ES_RenderColor[0], i_ES_RenderColor[1], i_ES_RenderColor[2], i_ES_RenderFx);
			server_print("MoveType: %d AnimTime: %f FrameRate: %f Body: %d", i_ES_MoveType, f_ES_AnimTime, f_ES_FrameRate, i_ES_Body);
			server_print("Controller: %d %d %d %d Blending: %d %d %d %d Velocity: %f %f %f", i_ES_Controller[0], i_ES_Controller[1], i_ES_Controller[2], i_ES_Controller[3], i_ES_Blending[0], i_ES_Blending[1], i_ES_Blending[2], i_ES_Blending[3], f_ES_Velocity[0], f_ES_Velocity[1], f_ES_Velocity[2]);
			server_print("Mins: %f %f %f Maxs: %f %f %f", f_ES_Mins[0], f_ES_Mins[1], f_ES_Mins[2], f_ES_Maxs[0], f_ES_Maxs[1], f_ES_Maxs[2]);
			
			
			server_print("AimEnt: %d Owner: %d Friction: %f Gravity: %f Team: %d PlayerClass: %d Health: %d Spectator: %d WeaponModel: %d GaitSequence: %d", i_ES_AimEnt, i_ES_Owner, f_ES_Friction, f_ES_Gravity, i_ES_Team, i_ES_PlayerClass, i_ES_Health, i_ES_Spectator, i_ES_WeaponModel, i_ES_GaitSequence);
			server_print("BaseVelocity: %f %f %f UseHull: %d OldButtons: %d OnGround: %d iStepLeft: %d flFallVelocity: %f FOV: %f WeaponAnim: %d", f_ES_BaseVelocity[0], f_ES_BaseVelocity[1], f_ES_BaseVelocity[2], i_ES_UseHull, i_ES_OldButtons, i_ES_OnGround, i_ES_iStepLeft, f_ES_flFallVelocity, f_ES_FOV, i_ES_WeaponAnim);
			server_print("StartPos: %f %f %f EndPos: %f %f %f ImpactTime: %f StartTime: %f", f_ES_StartPos[0], f_ES_StartPos[1], f_ES_StartPos[2], f_ES_EndPos[0], f_ES_EndPos[1], f_ES_EndPos[2], f_ES_ImpactTime, f_ES_StartTime);
			server_print("iUser1: %d iUser2: %d iUser3: %d iUser4: %d fUser1: %f fUser2: %f fUser3: %f fUser4: %f", i_ES_iUser1, i_ES_iUser2, i_ES_iUser3, i_ES_iUser4, f_ES_fUser1, f_ES_fUser2, f_ES_fUser3, f_ES_fUser4);
			server_print("vUser1: %f %f %f vUser2: %f %f %f vUser3: %f %f %f vUser4: %f %f %f", f_ES_vUser1[0], f_ES_vUser1[1], f_ES_vUser1[2], f_ES_vUser2[0], f_ES_vUser2[1], f_ES_vUser2[2], f_ES_vUser3[0], f_ES_vUser3[1], f_ES_vUser3[2], f_ES_vUser4[0], f_ES_vUser4[1], f_ES_vUser4[2]);
			*/

	


        
    }
         

	if (player && ent == host && get_orig_retval())
    {
	
		set_es(es, ES_FOV, 40)
    }
    
}
}