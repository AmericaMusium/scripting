#include <amxmodx>
#include <fun>
#include <dodx>
#include <hamsandwich>


/// CLASSES
// US Allies
#define cl_garand 1
#define cl_m1carb 2
#define cl_thomp 3
#define cl_greesg 4
#define cl_springf 5
#define cl_bar 6
#define cl_30cal 7
#define cl_bazooka 8
// Axis 
#define cl_k98 10
#define cl_k43 11
#define cl_mp40 12
#define cl_stg44 13
#define cl_k98s 14
#define cl_fg42 15
#define cl_fg42s 16
#define cl_mg34 17
#define cl_mg42 18
#define cl_panzerschreck 19
// brit 
#define cl_enfield 21
#define cl_sten 22
#define cl_scenfield 23
#define cl_bren 24
#define cl_piat 25

public plugin_init(){
	register_plugin("DOD Nades Equip","0.0","America")

	RegisterHam(Ham_Spawn,"player","func_HamSpawn",1)
}

public Nade_Equip(id)
{
	if(is_user_bot( id )) return PLUGIN_CONTINUE;
	if(!is_user_alive( id)) return PLUGIN_CONTINUE;
	//client_print(0, print_chat, "NADE QUEQP")
	if(get_user_team(id) == 2)
		{
			give_item(id, "weapon_stickgrenade")
			return PLUGIN_CONTINUE;
		}
	if(get_user_team(id) == 1)
		{
			give_item(id, "weapon_handgrenade")
			return PLUGIN_CONTINUE;
		}
	return PLUGIN_CONTINUE;
}


public func_HamSpawn(id)
{
	if(is_user_alive(id) && !is_user_bot(id))
	{
		new myclass = dod_get_user_class(id)
		// 4 nades
		if (myclass == cl_k98 
		|| myclass == cl_k43)
		{
			set_task(1.1, "Nade_Equip", id)
			set_task(1.6, "Nade_Equip", id)
			// set_task(2.1, "Nade_Equip", id)
		}
		// 3 nades
		if (myclass == cl_garand || myclass == cl_m1carb)
		{
			set_task(0.5, "Nade_Equip", id)
			set_task(1.5, "Nade_Equip", id)
			set_task(2.5, "Nade_Equip", id)
		}
		/// 2 nades
		if (myclass == cl_thomp 
		|| myclass == cl_greesg 
		|| myclass == cl_bar
		|| myclass == cl_stg44
		|| myclass == cl_mp40)
		{
			set_task(1.2, "Nade_Equip", id)
		}
		if ( myclass == cl_bazooka
		|| myclass == cl_mg34
		|| myclass == cl_mg42
		|| myclass == cl_panzerschreck
		|| myclass == cl_piat )
		{
			set_task(1.2, "Nade_Equip", id)
			set_task(1.8, "Nade_Equip", id)
		}
		// 1 nade
		if (myclass == cl_springf
		|| myclass == cl_k98s
		|| myclass == cl_30cal )
		{
			set_task(1.0, "Nade_Equip", id)
		}
		
	}
}