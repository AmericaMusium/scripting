#include <amxmodx>
#include <fakemeta>
#include <dodx>
#include <dodfun>
#include <hamsandwich>
#include <engine>

public plugin_init()
{
	register_plugin("DOD Admin Tools", "0.0","America")	
	RegisterHam(Ham_TakeDamage,"player","func_TakeDamage")	
    register_concmd ("r", "restart_ask")
    register_concmd ("rr", "restart_ask")
    register_concmd ("rrr", "restart_ask")

}

public func_TakeDamage(id,inflictor,attacker,Float:damage,damagebits)
{ 
	// bits 64 == nades //4226 SPADE // 32896 = K98KNIFE / 65664 = buttgarand
	
	if( is_user_bot(attacker) && !is_user_bot(id) )
    {
        SetHamParamFloat(4, 0.0)
        return HAM_OVERRIDE
        //return HAM_IGNORED
    }
	return HAM_IGNORED
}
/*

public client_PreThink(pPlayer)
{
    // чем медленне бежит , тем прозрачней 
    if(!is_user_alive(pPlayer))
        return;

    static Float: fVecVelocity[3];
    entity_get_vector(pPlayer, EV_VEC_velocity, fVecVelocity);

    set_rendering(
        .index      = pPlayer,
        .fx         = kRenderFxNone,
        .render     = kRenderTransAlpha,
        .amount     = max( 20, floatround(vector_length(fVecVelocity)))
    );
}
*/


public restart_ask()
{
server_cmd("restart")
}


