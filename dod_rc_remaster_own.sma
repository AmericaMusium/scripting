#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>
#include <fakemeta_util>
#include <fun>
#include <dodx>
#include <dodfun>
#include <dodconst>
#include <dodstats>
#include <dod_stocks>
#include <hamsandwich>

new const gentClassname[] = "tripsatchel" //Classname  entity
new const gentModel[] = "models/mapmodels/hk_satchel.mdl" 
new const gentSpriteExplode[] = "sprites/explosion1.spr" 
new const gentSpriteSmoke[] = "sprites/puff.spr" // 
new gent_Sprite[3] 


public plugin_init()
{
    register_plugin("RC Entity", "0.00", "America")
    register_clcmd("say /my", "RCentity_create")
    //register_think("tripsatchel", "savage_think"
    RegisterHam( Ham_Think , "info_target" , "savage_think" )

{

} 
}


public plugin_precache()
{
    precache_model( gentModel ) 
	gent_Sprite[1] = precache_model( gentSpriteExplode ) 
	gent_Sprite[2] = precache_model( gentSpriteSmoke ) 
}

public RCentity_create(id)
{	
	if(is_user_connected(id) && is_user_alive(id))
	{ 	
        new iOrigin[3] //    
		new iOrigin1[3] //  
		get_user_origin(id, iOrigin, 0) //    looks
		get_user_origin(id, iOrigin1, 1) //  
		
		new Float:fOrigin[3] //   float 
		IVecFVec(iOrigin1, fOrigin) //     

		//// CREATE ENITY 
		new id_satchel = create_entity("info_target")	
		// set_pev(id_satchel, pev_classname, gentClassname) 
		set_pev(id_satchel, pev_solid, SOLID_BBOX)   
		set_pev(id_satchel, pev_movetype, MOVETYPE_TOSS)
        set_pev(id_satchel, pev_owner, id)
		// Если нужно что бы разбивалось от пули , надо менять на 
		// SOLID_BBOX и менять точку старта, а то задевае игрока
		// set_pev(id_satchel, pev_health, 1.0);
		// set_pev(id_satchel, pev_takedamage, DAMAGE_YES);
		
		entity_set_edict(id_satchel, EV_ENT_owner, id)
		static Float:vVelocity[3]
		velocity_by_aim(id, 300, vVelocity)
		set_pev(id_satchel, pev_velocity, vVelocity)
		set_pev(id_satchel, pev_origin, fOrigin)
        engfunc(EngFunc_SetModel, id_satchel, gentModel) // 
		engfunc(EngFunc_SetSize, id_satchel, Float:{-6.0, -6.0, 0.0}, Float:{6.0, 6.0, 3.0}) //
    }
}


public savage_think(id_tank)
{
    new id_owner = pev(id_tank, pev_owner)

    server_print("dddddddd")
    // Input handling
    new buttonpress = 0
    buttonpress = pev(id_owner, pev_button)

    if (buttonpress & IN_FORWARD)  // Forward
    {
        /// 
        static Float:vVelocity[3]
		velocity_by_aim(id_owner, 300, vVelocity)
        set_pev(id_tank, pev_velocity, vVelocity)
    }

}