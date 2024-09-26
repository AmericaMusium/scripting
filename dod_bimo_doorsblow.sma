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
#include <hamsandwich>

new Float:fOrigin[3]

public plugin_init()
{
	register_plugin("DOD Doors Blows","0.0","America")
	server_print("DOD Doors Blows")

}


public dod_rocket_explosion(id, pos[3], wpnid)
{
    //  
    new currentent = -1
	while((currentent = find_ent_in_sphere(currentent,pos,Float:150.0)) != 0) 
    {
		new classname[32];
		entity_get_string(currentent,EV_SZ_classname,classname,31);

        if(equal(classname,"func_door_rotating"))
		{   
        	// FwdThinkBreak(currentent)
			Fwd_changeorigin(currentent)
        }
	}
}


public dod_grenade_explosion(id, pos[3], wpnid)
{
    //  
    new currentent = -1
	while((currentent = find_ent_in_sphere(currentent,pos,Float:150.0)) != 0) 
    {
		new classname[32];
		entity_get_string(currentent,EV_SZ_classname,classname,31);

        if(equal(classname,"func_door_rotating"))
		{   
        	// FwdThinkBreak(currentent)
			Fwd_changeorigin(currentent)
        }
	}
}
// func_breakable rendering fix by xPaw (convert to fakemeta by AlexALX)
public FwdThinkBreak( iEntity ) {
	if( pev( iEntity, pev_solid ) == SOLID_NOT ) {
		new iEffects = pev( iEntity, pev_effects );

		if( !( iEffects & EF_NODRAW ) )
			set_pev( iEntity, pev_effects, iEffects | EF_NODRAW );

		if( pev( iEntity, pev_deadflag ) != DEAD_DEAD )
			set_pev( iEntity, pev_deadflag, DEAD_DEAD );
	}
}


public Fwd_changeorigin(iEnt)
{
	if(is_valid_ent(iEnt))
	{
		pev(iEnt, pev_origin, fOrigin);
		fOrigin[2] -= 1024.0;
	    set_pev(iEnt, pev_origin, fOrigin);
	}
}








/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1049\\ f0\\ fs16 \n\\ par }
*/
