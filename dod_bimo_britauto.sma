#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>
#include <dodx>
#include <fakemeta>

/*
#include <engine>

#include <fakemeta_util>
#include <fun>

#include <dodfun>
#include <dodconst>
#include <dodstats>
#include <dod_stocks>

*/


public plugin_init() 
{
	register_plugin("AUTORESTART BRIT","0.0","America")
    RegisterHam(Ham_Spawn, "player", "brit_fix", 1);
}


public brit_fix(id)
{
    if(is_user_alive(id))
	{   

        new mdlar[72]
        pev(id, pev_model, mdlar, sizeof mdlar - 1)
        server_print(mdlar)

	    new myclass = dod_get_user_class(id)
	    if (myclass == 21 || myclass == 22 ||myclass == 23 ||myclass == 24 ||myclass == 25)
		    server_print("NEED TO RESTART")
        else server_print("CHECK OKEY")
	}
    server_print("CHECK WAS")
   
}

