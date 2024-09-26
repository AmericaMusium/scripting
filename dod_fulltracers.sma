//////////////////////////////////////////////////////////////////////////////////
//
//	DoD Tracers
//		- Version 0.2
//		- 09.08.2007
//		- diamond-optic
//  ВНУТРИ ИГРЫ УЖЕ ЗАШИТЫ МНОЖЕТЕЛИ НА НЕКОТОРЫЕ ТРАСЕРА. НАПРИМЕР У АВТОМАТОВ ПРИ СКОРОСТИ 3000 БУДУТ ВИДНЫ ТРАСЕРЫ
//////////////////////////////////////////////////////////////////////////////////
//
// Information:
//
// 	- Selected guns will produce 'MG' tracers
//	- Works well with dod_forcetracers plugin
//
// CVARs: 
//
//	dod_tracers	//(1)ON or (0)OFF
//
//	//the following turn on/off tracers for each weapon
//	dod_tracers_colt "1"
//	dod_tracers_luger "1"
//	dod_tracers_webley "1"
//	dod_tracers_garand "1"
//	dod_tracers_enfield "1"
//	dod_tracers_kar "1"
//	dod_tracers_k43 "1"
//	dod_tracers_scopedkar "1"
//	dod_tracers_springfield "1"
//	dod_tracers_scopedenfield "1"
//	dod_tracers_scopedfg42 "1"
//	dod_tracers_fg42 "1"
//	dod_tracers_thompson "1"
//	dod_tracers_m1carbine "1"
//	dod_tracers_bar "1"
//	dod_tracers_greasegun "1"
//	dod_tracers_mp40 "1"
//	dod_tracers_stg44 "1"
//	dod_tracers_sten "1"
//	dod_tracers_bren "1"
//
// Credits:
//
//	- Jon for the original tracer plugin
//	- Firestorm for the dod port
//	- Modified to MG Tracer & cvars added by diamond-optic
//
// Changelog:
//
//	 - 08.28.2006 Version 0.1
//		Modified dod_pistoltracers to allow all guns
//
//	 - 09.08.2007 Version 0.2
//		Spectators and dead players now see the tracers
//
//////////////////////////////////////////////////////////////////////////////////

#include <amxmodx>
#include <dodx>

new lastammo[33], lastweap[33]

new p_dod_tracers
new p_colt, p_luger, p_webley, p_garand, p_enfield, p_kar, p_k43, p_scopedkar, p_springfield, p_scopedenfield, p_scopedfg42, p_fg42, p_thompson, p_m1carbine, p_bar, p_greasegun, p_mp40, p_stg44, p_sten, p_bren


public plugin_init()
{
	register_plugin("DoD Tracers","0.2","AMXX DoD Team")
	
	register_cvar("dod_tracers_stats", "0.2", FCVAR_SERVER|FCVAR_SPONLY)

    register_concmd("dod_reloadtracers","force_manual");
	register_event("CurWeapon","make_tracer","be","1=1")//,"3>0")
	
	p_dod_tracers = register_cvar("dod_tracers","1")
	
	p_colt = register_cvar("dod_tracers_colt", "1")
	p_luger = register_cvar("dod_tracers_luger", "1")
	p_webley = register_cvar("dod_tracers_webley", "1")
	p_garand = register_cvar("dod_tracers_garand", "1")
	p_enfield = register_cvar("dod_tracers_enfield", "1")
	p_kar = register_cvar("dod_tracers_kar", "1")
	p_k43 = register_cvar("dod_tracers_k43", "1")
	p_scopedkar = register_cvar("dod_tracers_scopedkar", "1")
	p_springfield = register_cvar("dod_tracers_springfield", "1")
	p_scopedenfield = register_cvar("dod_tracers_scopedenfield", "1")
	p_scopedfg42 = register_cvar("dod_tracers_scopedfg42", "1")
	p_fg42 = register_cvar("dod_tracers_fg42", "1")
	p_thompson = register_cvar("dod_tracers_thompson", "1")
	p_m1carbine = register_cvar("dod_tracers_m1carbine", "1")
	p_bar = register_cvar("dod_tracers_bar", "1")
	p_greasegun = register_cvar("dod_tracers_greasegun", "1")
	p_mp40 = register_cvar("dod_tracers_mp40", "1")
	p_stg44 = register_cvar("dod_tracers_stg44", "1")
	p_sten = register_cvar("dod_tracers_sten", "1")
	p_bren = register_cvar("dod_tracers_bren", "1")


}

public show_tracer(id,team,vec1[3],vec2[3],weap)
{
	if(!is_user_connected(id))
		return PLUGIN_CONTINUE

	message_begin(MSG_ONE_UNRELIABLE,SVC_TEMPENTITY,vec1,id)	
	write_byte(TE_TRACER)
	write_coord(vec1[0])
	write_coord(vec1[1])
	write_coord(vec1[2])
	write_coord(random_num(vec2[0] - 10,vec2[0] + 10))
	write_coord(vec2[1])
	write_coord(random_num(vec2[2] - 10,vec2[2] + 10))
	message_end()	

    
    
	/*
	/// TE_Line - линии с точками хуйня
    message_begin(MSG_ONE_UNRELIABLE,SVC_TEMPENTITY,vec1,id)	
    write_byte(TE_LINE)
    write_coord(vec1[0])
    write_coord(vec1[1])
    write_coord(vec1[2])
    write_coord(random_num(vec2[0] - 10,vec2[0] + 10))
    write_coord(vec2[1])
    write_coord(random_num(vec2[2] - 10,vec2[2] + 10))
    write_short(1) //LIFE
    write_byte(130) //r
    write_byte(70) //g
    write_byte(20) //b 
    message_end()
    */ 

     // Quick spark sprite, client ricochet sound.
     /*
    message_begin(MSG_ONE_UNRELIABLE,SVC_TEMPENTITY,vec1,id)	
    write_byte(TE_ARMOR_RICOCHET)
    write_coord(vec1[0])
    write_coord(vec1[0])
    write_coord(vec1[0])
    write_byte(100)
    message_end()
    */
	
	return PLUGIN_CONTINUE
}


// Client disconnected, reset his data
public client_connect(id)
{
    if (!is_user_bot(id))
    {
         force_manual(id)
    }
   
}


public make_tracer(id)
{
	if(get_pcvar_num(p_dod_tracers) == 0 || !is_user_connected(id) || !is_user_alive(id))
		return PLUGIN_CONTINUE

	new weap = read_data(2)
	new ammo = read_data(3)
	
	if (lastweap[id] == 0)
		lastweap[id] = weap

	if(lastammo[id] > ammo && lastweap[id] == weap)
		{
		new team = get_user_team(id)
		new ammo, clip, zGun = dod_get_user_weapon(id,clip,ammo)
		new vec1[3], vec2[3]
		get_user_origin(id,vec1,1)
		get_user_origin(id,vec2,3)
		
		new plist[32], pnum
		get_players(plist,pnum,"c")
		for(new i = 0; i < pnum; i++)
			{
			if (is_user_connected(plist[i]))
				{
				if((get_pcvar_num(p_colt) == 1 && zGun == DODW_COLT) || (get_pcvar_num(p_luger) == 1 && zGun == DODW_LUGER) || (get_pcvar_num(p_webley) == 1 && zGun == DODW_WEBLEY)
					|| (get_pcvar_num(p_garand) == 1 && zGun == DODW_GARAND) || (get_pcvar_num(p_enfield) == 1 && zGun == DODW_ENFIELD) || (get_pcvar_num(p_kar) == 1 && zGun == DODW_KAR) || (get_pcvar_num(p_k43) == 1 && zGun == DODW_K43)
					|| (get_pcvar_num(p_scopedkar) == 1 && zGun == DODW_SCOPED_KAR) || (get_pcvar_num(p_springfield) == 1 && zGun == DODW_SPRINGFIELD) || (get_pcvar_num(p_scopedenfield) == 1 && zGun == DODW_SCOPED_ENFIELD)
					|| (get_pcvar_num(p_scopedfg42) == 1 && zGun == DODW_SCOPED_FG42) || (get_pcvar_num(p_fg42) == 1 && zGun == DODW_FG42)
					|| (get_pcvar_num(p_thompson) == 1 && zGun == DODW_THOMPSON) || (get_pcvar_num(p_m1carbine) == 1 && (zGun == DODW_M1_CARBINE || zGun == DODW_FOLDING_CARBINE)) || (get_pcvar_num(p_bar) == 1 && zGun == DODW_BAR) || (get_pcvar_num(p_greasegun) == 1 && zGun == DODW_GREASEGUN)
					|| (get_pcvar_num(p_mp40) == 1 && zGun == DODW_MP40) || (get_pcvar_num(p_stg44) == 1 && zGun == DODW_STG44) || (get_pcvar_num(p_sten) == 1 && zGun == DODW_STEN) || (get_pcvar_num(p_bren) == 1 && zGun == DODW_BREN))
						show_tracer(plist[i],team,vec1,vec2,weap)		
				}
			}
		}
	
	lastammo[id] = ammo
	lastweap[id] = weap
	
	return PLUGIN_CONTINUE
}

public force_manual(id)
{   
    /*
    //DoD Beta 2.0 Bullet Tracer settings
    traceroffset 100
    tracerlength 0.45
    tracerred 1.3
    tracerblue 0.1
    tracergreen 0.7
    traceralpha 0.45
    tracerspeed 6250
    */

    client_cmd(id,"traceralpha 0.45") // 0.45
    client_cmd(id,"tracerblue 0.1")
    client_cmd(id,"tracergreen 0.7")
    client_cmd(id,"tracerred 1.3")
    client_cmd(id,"tracerlength 5.0")
    client_cmd(id,"traceroffset 100")
    client_cmd(id,"tracerspeed 4000") //6250 origina
   
    client_print(id,print_chat,"[DOD_TRACERS] Settings Updated")
    server_print("[DOD_TRACERS] Settings Updated")

}