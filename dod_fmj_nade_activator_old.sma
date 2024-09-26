
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

#define PLUGIN "DOD ENT SCANNER"
#define VERSION "07Jan2023"
#define AUTHOR "[America][TheVaskov]"

// LINUX 4
#define m_flTimeToExplode 119 // explossion in gametime format 
#define m_flNextPrimaryAttack 103 // 
#define m_flNextSecondaryAttack 104
#define m_fInAttack 113
#define m_bUnderhand 120 // bool
#define m_flStartThrow 117
#define m_flReleaseThrow 118 


public plugin_init()
{
	register_plugin("NADE ACTIVATOR", "0.0", "America")
	// register_event("CurWeapon","event_post","be")
	//register_event("ReloadDone", "event_post", "be", "1=1")
	register_clcmd("say nade1", "event_post")
	// register_forward 
}

public event_post(id)
{
	
	event_rename()
}

public event_rename()
{
scan_entity_list()

}

public scan_entity_list()
{
	new iEntCount = entity_count()
	new iEntMax = global_get(glb_maxEntities)
	

	new sClsname[32]
	new id_ent
	for (id_ent = 0 ; id_ent < iEntMax; id_ent++ )
	{
		if(pev_valid(id_ent))
		{	
			pev(id_ent, pev_classname, sClsname, 31)
			if(equal(sClsname, "weapon_stickgrenade"))
			{
				// set_pev(id_ent,pev_classname,"weapon_stickgrenade_ex")
				// set_pev(id_ent, pev_nextthink, get_gametime() + 10.0)
				// set_pev(id_ent, pev_dmgtime, get_gametime() + 10.0)
				// set_pev(id_ent, pev_flags, )
				new Float:crnt1;
				new Float:crnt2;
				new Float:crnt3;
				new Float:crnt4;

				new mode = get_pdata_int(id_ent, m_bUnderhand, 4);
				
				crnt1 = get_pdata_float(id_ent, m_flTimeToExplode, 4)
				crnt2 = get_pdata_float(id_ent, m_flStartThrow, 4)
				crnt3 = get_pdata_float(id_ent, m_flReleaseThrow, 4)

				// set_pdata_float(id_ent, m_flTimeToExplode,  get_gametime() + 10.0 , 4)
				server_print("RENAMED %s   == %d", sClsname, id_ent )
				client_print(0, print_center, "Timeex: %f, StarThrow %f, Release %f ",  crnt1, crnt2, crnt3)

				/*
				new Float:start_delay = get_gametime() + SETTING_DELAYSTART
				set_pev(grenid,pev_nextthink,start_delay)
				set_pev(grenid,pev_fuser1,start_delay + SETTING_DURATION)

				set_pev(grenid,pev_iuser1,true)
				*/
				
			}
		}

	}
	
}

