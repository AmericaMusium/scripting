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

public plugin_init()
{
	register_plugin("DOD HORSE ","0.0","America")
	server_print("DOD HORSE")  
    register_clcmd("say hor","horse_check")
}

public horse_check(id)
{
	new Float:fOrigin[3]
	new i2Origin[3]

	pev(id, pev_origin, fOrigin);
	// set_pev(id, pev_origin, fOrigin);
	server_print("%f , %f , %f", fOrigin[0], fOrigin[1], fOrigin[2] )

	FVecIVec(fOrigin, i2Origin)

	new g_horsemdl[] = "models/mapmodels/horse_statue.mdl"
	new Rent = engfunc(EngFunc_FindEntityByString, 0, "model", g_horsemdl)
	new classname[32];
	pev(Rent,pev_classname,classname,31);
	set_pev(Rent, pev_model, " ")
	server_print(" %s , %d ", classname, Rent )
	/*
    new currentent = -1
	while((currentent = find_ent_in_sphere(currentent,i2Origin,Float:150.0)) != 0) 
    {
		new classname[32];
		entity_get_string(currentent,EV_SZ_classname,classname,31);

		if(equal(classname,"env_model"))
		{   
			pev(currentent, pev_origin, fOrigin);
			fOrigin[2] -= 1024.0;
	   		set_pev(currentent, pev_origin, fOrigin);
			
		}
		
	}
	*/
}

