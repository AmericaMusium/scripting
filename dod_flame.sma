/***************************************************************************
 *			    	ORIGINAL AUTOR
 *  amx_ejl_flamethrower.sma     version 5.3.1                  Date: 5/4/2003
 *  Author: Eric Lidman      ejlmozart@hotmail.com
 *  Alias: Ludwig van        Upgrade: http://lidmanmusic.com/cs/plugins.html           
 *
 *				DOD TWEAKS by SidLuke
 *  !!! Don't send e-mails to Ludwig van if there is a problem with this plugin !!!	
 *
 *   Add a flamethrower weapon to any Half-Life mod. Clients need to bind a
 *   key to amx_fire_flamethrower and then use that key to use their flame-
 *   thrower. The flamethower is a deadly weapon and give frag credit to the
 *   player who burned another player with a flamethrower burst. Lots of
 *   cool FX fire etc. It is sensitive to the mp_friendlyfire cvar and will
 *   thus kill teamates if friendlyfire is on and not if its off.
 *
 * 
 *  CLIENT COMMANDS:
 * 
 *   amx_fire_flamethrower            --should be bound to a key, fires
 *                                      flamethrower if enabled and if there
 *                                      are sufficient funds from the client
 *                                      in either armor or money depending
 *                                      on the buytype cvar
 *   say /flamethrower                --gives cleints info on setup of the
 *                                      flamethrower in an motd window
 *   say vote_flamethrower            --starts a vote to have flamethrowers
 *                                      enabled or disabled
 *       
 *  ADMIN COMMANDS:
 *
 *   amx_flamethrowers                --toggles flamethrowers enabled or not
 *
 *   amx_flamethrowers_vote           --toggles on/off ability for players
 *                                      to start votes, default setting is on
 *   amx_flamethrowers_vote_default   --sets current flamethrowersvote status
 *                                      as server default auto-refreshed at
 *                                      every map change. ADMIN_RCON level
 *                                      admin required to set server default
 *   stopvote                         --stops vote in progress  
 *
 *  CVARS: can be set in admin.cfg, see corresponding commands for info
 *
 *   amx_luds_flamethrower 1          -- 0= disable  1= enable        
 *   amx_flvote_delay 180.0           -- Default 180.0 seconds. Delay between
 *                                       flamethrower votes allowed started 
 *                                       by a non admin
 *   amx_flamethrower_ammo 0          -- Set the number of flamethrower 
 *                                       blasts given to each player at spawn.
 *
 *  Additional info:
 *
 *   Flamethrower kills and damage are sent to the sever logs in the same
 *   format as normal kills and damage. A log parser (like pysychostats) 
 *   should be able to take the log output of this plugin and include them
 *   in the stats output. Flamethrower kills count on the DoD scoreboard, 
 *
 *
 ***************************************************************************/


/************************************************************************************
 *                                                                                  *
 *  *end* customizable section of code. other changes can be done with the cvars    *
 *                                                                                  *
 ************************************************************************************/


#include <amxmodx>
#include <amxmisc>
#include <fun>
#include <dodx>
#include <dodfun>
#include <engine>

new gmsgScoreShort
new gmsgDeathMsg
new gFlameThrowerId

new smoke 
new fire
new burning
new isburning[33]

new szFileDir[64]

new vault_value[128]
new votenumber = 0
new votecontroller[33][2]
new option[4]
new Float:vote_ratio
new st_vote = 0
new totalvoters = 0
new bool:bVoteToStop = false
new bool:flvote_deny = false
new bool:bFLvote = true
new restrict_override
new flame_count[33]

public amx_fl(id,level,cid){
	if (!cmd_access(id,level,cid,1))
		return PLUGIN_HANDLED

	new command[60]
	new variable[6]
	new name[32]
	get_user_name(id,name,31)
	read_argv(0,command,59)
	read_argv(1,variable,5)

	if(get_cvar_num("amx_luds_flamethrower") == 1){
		set_cvar_string("amx_luds_flamethrower","0")
		console_print(id,"[AMX] %s has been turned OFF",command)
		switch(get_cvar_num("amx_show_activity"))	{
			case 2:	client_print(0,print_chat,"ADMIN %s: Executed %s OFF",name,command)
			case 1:	client_print(0,print_chat,"ADMIN: Executed %s OFF",command)
		}
	}else{
		set_cvar_string("amx_luds_flamethrower","1")
		console_print(id,"[AMX] %s has been turned ON.",command)
		switch(get_cvar_num("amx_show_activity"))	{
			case 2:	client_print(0,print_chat,"ADMIN %s: Executed %s ON",name,command)
			case 1:	client_print(0,print_chat,"ADMIN: Executed %s ON",command)
		}
	}
	new authid[16]
	get_user_authid(id,authid,16)
	get_user_name(id,name,32)
	log_amx("^"%s<%d><%s><>^" flamethrowers", name,get_user_userid(id),authid)
	return PLUGIN_HANDLED
}

public amx_flvote(id,level,cid){
	if (!cmd_access(id,level,cid,1))
		return PLUGIN_HANDLED

	if(bFLvote == false) {
		bFLvote = true
		client_print(0,print_chat,"[AMX]  Admin has allowed players to initiate vote_flamethrower") 
		console_print(id,"[AMX]  You have allowed players to initiate vote_flamethrower")
	}else {
		bFLvote = false
		client_print(0,print_chat,"[AMX]  Admin has forbidden players to initiate vote_flamethrower") 
		console_print(id,"[AMX]  You have forbidden players to initiate vote_flamethrower")
	}	
	new authid[16],name[32]
	get_user_authid(id,authid,16)
	get_user_name(id,name,32)
	log_amx("^"%s<%d><%s><>^" flamethrower vote_mode",name,get_user_userid(id),authid)
	return PLUGIN_HANDLED
}

public amx_flvote_d(id,level,cid){
	if (!cmd_access(id,level,cid,1))
		return PLUGIN_HANDLED

	if(bFLvote == false){
		ejl_vault("WRITE","FLAMETHROWER_VOTE","OFF")
		console_print(id,"[AMX] Player initiated flamethrower voting  OFF   is now the default.")
	}else{
		ejl_vault("WRITE","FLAMETHROWER_VOTE","ON")
		console_print(id,"[AMX] Player initiated flamethrower voting  ON    is now the default.")
	}
	new authid[16],name[32]
	get_user_authid(id,authid,16)
	get_user_name(id,name,32)
	log_amx("^"%s<%d><%s><>^" flamethrower vote_mode_d",name,get_user_userid(id),authid)
	return PLUGIN_HANDLED
}

public amx_fflame(id){
	if(get_cvar_num("amx_luds_flamethrower") == 0){
		client_print(id,print_chat,"[AMX]  Flamethrower is disabled")	
		return PLUGIN_HANDLED
	}
	if(is_user_alive(id) == 0) 
		return PLUGIN_HANDLED

	if(flame_count[id] < 1){
		client_print(id,print_chat,"[AMX]  Insufficient fuel. You have used all your flamethrower blasts")		
		return PLUGIN_HANDLED
	}
	flame_count[id] -= 1
	if ( gFlameThrowerId )
		custom_weapon_shot(gFlameThrowerId,id)
	set_hudmessage(255,0,0, -1.0, 0.25, 0, 0.02, 3.0, 1.01, 1.1, 4)
	new msg[64]
	format(msg,63,"FLAMETHROWER BURSTS REMAINING: %d",flame_count[id])
	show_hudmessage(id,msg)

	fire_flamethrower(id)
	return PLUGIN_HANDLED
}

fire_flamethrower(id){
	emit_sound(id, CHAN_WEAPON, "ambience/flameburst1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
	new vec[3] 
	new aimvec[3] 
	new velocityvec[3] 
	new length 	 
	new speed = 10 
	get_user_origin(id,vec) 
	get_user_origin(id,aimvec,2)
	new dist = get_distance(vec,aimvec)

	new speed1 = 160
	new speed2 = 350
	new radius = 105

	if(dist < 50){
		radius = 0
		speed = 5
	}
	else if(dist < 150){
		speed1 = speed2 = 1
		speed = 5
		radius = 50
	}
	else if(dist < 200){
		speed1 = speed2 = 1
		speed = 5
		radius = 90
	}
	else if(dist < 250){
		speed1 = speed2 = 90
		speed = 6
		radius = 90
	}
	else if(dist < 300){
		speed1 = speed2 = 140
		speed = 7
	}
	else if(dist < 350){
		speed1 = speed2 = 190
		speed = 7
	}
	else if(dist < 400){
		speed1 = 150
		speed2 = 240
		speed = 8
	}
	else if(dist < 450){
		speed1 = 150
		speed2 = 290
		speed = 8
	}
	else if(dist < 500){
		speed1 = 180
		speed2 = 340
		speed = 9
	}

	velocityvec[0]=aimvec[0]-vec[0] 
	velocityvec[1]=aimvec[1]-vec[1] 
	velocityvec[2]=aimvec[2]-vec[2] 
	length=sqrt(velocityvec[0]*velocityvec[0]+velocityvec[1]*velocityvec[1]+velocityvec[2]*velocityvec[2]) 
	velocityvec[0]=velocityvec[0]*speed/length 
	velocityvec[1]=velocityvec[1]*speed/length 
	velocityvec[2]=velocityvec[2]*speed/length 

	new args[8]
	args[0] = vec[0]
	args[1] = vec[1]
	args[2] = vec[2]
	args[3] = velocityvec[0]
	args[4] = velocityvec[1]
	args[5] = velocityvec[2]
	set_task(0.1,"te_spray",0,args,8,"a",2)
	check_burnzone(id,vec,aimvec,speed1,speed2,radius)
}

public te_spray(args[]){

	//TE_SPRAY	
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte (120) // Throws a shower of sprites or models
	write_coord(args[0]) // start pos
	write_coord(args[1]) 
	write_coord(args[2])
	write_coord(args[3]) // velocity
	write_coord(args[4])  
	write_coord(args[5])
	write_short (fire) // spr
	write_byte (8) // count
	write_byte (70) // speed
	write_byte (100) //(noise)
	write_byte (5) // (rendermode)
	message_end()

	return PLUGIN_CONTINUE
}


public sqrt(num) { 
	new div = num 
	new result = 1 
	while (div > result) { // end when div == result, or just below 
		div = (div + result) / 2 // take mean value as new divisor 
		result = num / div 
	} 
	return div 
} 

check_burnzone(id,vec[],aimvec[],speed1,speed2,radius){
	new maxplayers = get_maxplayers()+1
	new tbody,tid
	get_user_aiming(id,tid,tbody,550)
	new ffcvar = get_cvar_num("mp_friendlyfire")
	if((tid > 0) && (tid < maxplayers)){
		if( get_user_team(tid) == get_user_team(id) ){
			if ( ffcvar )
				burn_victim(tid,id,1) // tk
		}
		else{
			burn_victim(tid,id,0)
		}
	}
	
	new burnvec1[3],burnvec2[3],length1

	burnvec1[0]=aimvec[0]-vec[0] 
	burnvec1[1]=aimvec[1]-vec[1] 
	burnvec1[2]=aimvec[2]-vec[2]
 
	length1=sqrt(burnvec1[0]*burnvec1[0]+burnvec1[1]*burnvec1[1]+burnvec1[2]*burnvec1[2]) 
	burnvec2[0]=burnvec1[0]*speed2/length1 
	burnvec2[1]=burnvec1[1]*speed2/length1 
	burnvec2[2]=burnvec1[2]*speed2/length1
	burnvec1[0]=burnvec1[0]*speed1/length1 
	burnvec1[1]=burnvec1[1]*speed1/length1 
	burnvec1[2]=burnvec1[2]*speed1/length1 
	burnvec1[0] += vec[0] 
	burnvec1[1] += vec[1]
	burnvec1[2] += vec[2] 
	burnvec2[0] += vec[0]
	burnvec2[1] += vec[1]
	burnvec2[2] += vec[2]

	new origin[3]
	for (new i=1; i<=maxplayers; i++) {
		if( is_user_alive(i) && (i != id) ){
			if( get_user_team(i) == get_user_team(id) ){
				if ( ffcvar){ // ta & ff on
					get_user_origin(i,origin)
					if(get_distance(origin,burnvec1) < radius)
						burn_victim(i,id,1)
					else if(get_distance(origin,burnvec2) < radius)
						burn_victim(i,id,1)
				}
			}
			else{
				get_user_origin(i,origin)
				if(get_distance(origin,burnvec1) < radius)
					burn_victim(i,id,0)
				else if(get_distance(origin,burnvec2) < radius)
					burn_victim(i,id,0)
			}
		}
	}
	return PLUGIN_CONTINUE		
}

burn_victim(id,killer,tk){
	if(isburning[id] == 1)
		return PLUGIN_CONTINUE
	isburning[id] = 1

	emit_sound(id, CHAN_ITEM, "ambience/burning1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)

	new hp,args[4]
	hp = get_user_health(id)
	if(hp > 250)
		hp = 250
	args[0] = id
	args[1] = killer
	args[2] = tk	
	set_task(0.3,"on_fire",451,args,4,"a",hp / 10)
	set_task(0.7,"fire_scream",0,args,4)
	set_task(5.5,"stop_firesound",0,args,4)

	return PLUGIN_CONTINUE
}

public on_fire(args[]){
	new hp,rx,ry,rz,forigin[3]
	new id = args[0]
	new killer = args[1]
	new tk = args[2]
	if(isburning[id] == 0)
		return PLUGIN_CONTINUE
	rx = random_num(-30,30)
	ry = random_num(-30,30)
	rz = random_num(-30,30)
	get_user_origin(id,forigin)

	//TE_SPRITE - additive sprite, plays 1 cycle 
	message_begin( MSG_BROADCAST,SVC_TEMPENTITY) 
	write_byte( 17 ) 
	write_coord(forigin[0]+rx) // coord, coord, coord (position) 
	write_coord(forigin[1]+ry)
	write_coord(forigin[2]+10+rz)
	write_short( burning ) // short (sprite index) 
	write_byte( 30 ) // byte (scale in 0.1's) 
	write_byte( 200 ) // byte (brightness) 
	message_end() 

	//Smoke 
	message_begin( MSG_BROADCAST,SVC_TEMPENTITY) 
	write_byte( 5 ) 
	write_coord(forigin[0]+(rx*2)) // coord, coord, coord (position) 
	write_coord(forigin[1]+(ry*2))
	write_coord(forigin[2]+100+(rz*2))
	write_short( smoke )// short (sprite index) 
	write_byte( 60 ) // byte (scale in 0.1's) 
	write_byte( 15 ) // byte (framerate) 
	message_end() 

	if( !is_user_alive(id) )
		return PLUGIN_CONTINUE

	hp = get_user_health(id)
	if(hp - 11 < 1){
		set_msg_block(gmsgDeathMsg, BLOCK_ONCE)
		set_user_health(id,hp - 11)
		if ( gFlameThrowerId )
			custom_weapon_dmg(gFlameThrowerId,killer,id,11,0) // *************
		message_begin(MSG_ALL,gmsgDeathMsg,{0,0,0},0)
		write_byte( killer )
		write_byte( id )
		write_byte( 0 )
		message_end()

		new namek[32],namev[32],authida[40],authidv[40],teama[16],teamv[16],wlogname [32]
		get_user_name(id,namev,31)
		get_user_name(killer,namek,31)
		get_user_authid(id,authidv,39)
		get_user_authid(killer,authida,39)

		get_user_team(id,teamv,15)
		get_user_team(killer,teama,15)

		xmod_get_wpnlogname(gFlameThrowerId,wlogname,31)

		log_message("^"%s<%d><%s><%s>^" killed ^"%s<%d><%s><%s>^" with ^"%s^"",
			namek,get_user_userid(killer),authida,teama,namev,get_user_userid(id),authidv,teamv,wlogname )	

		client_print(id,print_chat,"[AMX] You were killed by %s's flamethrower^n",namek)
		client_print(killer,print_chat,"[AMX] You killed %s with your flamethrower^n",namev)

		new fr = get_user_frags(killer)
		if( !tk ){
			set_user_frags(killer,fr + 1)
			// refresh scoreboard
			if ( gmsgScoreShort ){
				message_begin( MSG_ALL,gmsgScoreShort )
				write_byte(killer)
				write_short(dod_get_user_score(killer))
				write_short(fr+1)
				write_short(dod_get_pl_deaths(killer))
				write_byte(1) // always 1 , don't know what is this . anyone ?
				message_end( )
			}
		}
	
	}
	else {
		set_user_health(id,hp - 11)
		if ( gFlameThrowerId )
			custom_weapon_dmg(gFlameThrowerId,killer,id,11,0) // *************
	}
	return PLUGIN_CONTINUE
}

public fire_scream(args[]){
	emit_sound(args[0], CHAN_AUTO, "scientist/c1a0_sci_catscream.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
	return PLUGIN_CONTINUE 
}

public stop_firesound(args[]){
	isburning[args[0]] = 0
	emit_sound(args[0], CHAN_ITEM, "vox/_period.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
	return PLUGIN_CONTINUE 
}

public HandleSay(id) {
	new Speech[192]
	read_args(Speech,192)
	remove_quotes(Speech)
	if (equal(Speech, "vote_flamethrower")) {
		if (restrict_override == 1) { 
			client_print(id,print_chat,"[AMX] Flamethrower restrictions cannot be changed. Override is on.") 
			return PLUGIN_HANDLED
		}
		FLVote(id)
	}
	else if( (restrict_override == 0) && (bFLvote == true) ){
		if( (containi(Speech, "fire") != -1) || (containi(Speech, "flam") != -1) ){
			if(get_cvar_num("amx_luds_flamethrower") == 1){
				client_print(id,print_chat, "[AMX]  Flamethrowers enabled. To change say vote_flamethrower   For help say /flamethrower")
			}else{
				client_print(id,print_chat, "[AMX]  Flamethrowers disabled. To change say vote_flamethrower   For help say /flamethrower")
			}
		}
	}
	return PLUGIN_CONTINUE
}

public flamet_motd(id){
	display_motd(id)
	return PLUGIN_CONTINUE
}

public FLVote(id) {
	if( (flvote_deny == true) && (!(get_user_flags(id)&ADMIN_MAP)) ){
		client_print(id,print_chat,"[AMX] We just had a flamethrower vote. Wait a little longer.")
		return PLUGIN_HANDLED
	}
	if( (bFLvote == false) && (!(get_user_flags(id)&ADMIN_MAP)) ){
		client_print(id,print_chat,"[AMX] Server is set so that only admins can start this vote.")
		return PLUGIN_HANDLED
	}
	new Float:voting = get_cvar_float("amx_last_voting")
	if (voting > get_gametime()){ 
		client_print(id,print_chat,"There is already one voting...") 
		return PLUGIN_HANDLED 
	} 
	if (voting && voting + get_cvar_float("amx_vote_delay") > get_gametime()) { 
		client_print(id,print_chat,"Voting not allowed at this time") 
		return PLUGIN_HANDLED 
	}
	new inprogress[32]
	get_cvar_string("amx_vote_inprogress",inprogress,32)
	if(equal(inprogress, "0",1)){
	new menu_msg[256]
	new keys
	format(menu_msg,256,"\yAllow Flamethrowers? \w^n^n1.  Yes, I am a pyromaniac!^n2.  No, fire scares me")

	keys = (1<<0)|(1<<1)
	new authid[16],name[32]
	get_user_authid(id,authid,16)
	get_user_name(id,name,32)
	log_amx("^"%s<%d><%s><>^" flamethrower",
		name,get_user_userid(id),authid)
	new Float:vote_time = get_cvar_float("amx_vote_time") + 2.0 
	set_cvar_float("amx_last_voting",  get_gametime() + vote_time )
	vote_ratio = get_cvar_float("amx_fl_vote_ratio")
	for(new a = 0; a < 33; a++){
		votecontroller[a][1] = 0
	}
	votenumber++
	set_cvar_string("amx_vote_inprogress","1")
	ejl_vault("WRITE","CURRENT_VOTE","FT_VOTE")
	bVoteToStop = true

	totalvoters = 0
	new maxpl = get_maxplayers()+1
	for(new k = 1; k < maxpl; k++){
		if(!is_user_bot(k)){
			if( !( get_user_team(k)==3 || (get_user_time(k)== 0) ) ){
				show_menu(k,keys,menu_msg,floatround(vote_time))
				totalvoters++
			}
		}
	}

	set_task(vote_time,"HandleFTVote")
	client_print(id,print_console,"[AMX] Voting has started...")
	for(new j = 0; j < 4;++j) option[j] = 0
	}else{
	client_print(id,print_chat,"[AMX] Voting not allowed yet.")	
	}
	return PLUGIN_HANDLED
}

public HandleFTVote() {

	set_hudmessage(63,187,239, -1.0, 0.70, 2, 0.02, 10.0, 0.01, 0.1, 2)

	flvote_deny = true
	set_task(get_cvar_float("amx_flvote_delay"),"fl_vote_deny")
	set_cvar_string("amx_vote_inprogress","0")
	ejl_vault("WRITE","CURRENT_VOTE","NULL")
	bVoteToStop = false

	for(new a = 0; a < 33; a++){
		votecontroller[a][1] = 0
	}

	if(st_vote == 1){
		st_vote = 0
		client_print(0,print_chat,"[AMX]  Voting sucessfully stopped.")
		return PLUGIN_HANDLED
	}


	new best = 0
	new best_count = 0
	for(new a = 0; a < 4; ++a) {
		if (option[a] > best_count){
			best_count = option[a]
			best = a
		}
	}
	new inum = totalvoters
	new Float:result_v = inum ? (float(option[best]) / float(inum)) : 0.0
	if (result_v >= vote_ratio) {
		if(best == 0){
			client_print(0,print_chat,"[AMX] Voting over .... Flamethrower wins.")
			if(get_cvar_num("amx_luds_flamethrower") == 1){
				show_hudmessage(0,"Vote over.^nFlamethrowers will stay enabled.^n^n%d votes for Flamethrowers ON^n%d votes for Flamethrowers OFF^n^n%d Total eligible voters",
				option[0],option[1],totalvoters)
			} else {
				set_hudmessage(63,187,239, -1.0, 0.70, 2, 0.02, 10.0, 0.01, 0.1, 2)
				show_hudmessage(0,"Vote over.^nUse Flamethrower wins. Burn baby!!!^n^n%d votes for Flamethrowers ON^n%d votes for Flamethrowers OFF^n^n%d Total eligible voters",
				option[0],option[1],totalvoters)
				set_cvar_string("amx_luds_flamethrower","1")
			}
			log_amx("World triggered ^"voting_success^" (needed ^"%.2f^") (ratio ^"%.2f^") (result ^"flamethrower^")",
				vote_ratio,result_v)
		}else {
			client_print(0,print_chat,"[AMX] Voting over .... No Flamethrowers.")
			if(get_cvar_num("amx_luds_flamethrower") == 0){
				show_hudmessage(0,"Vote over.^nFlamethrowers will stay disabled.^n^n%d votes for Flamethrowers ON^n%d votes for Flamethrowers OFF^n^n%d Total eligible voters",
				option[0],option[1],totalvoters)
			} else {
				show_hudmessage(0,"Vote over.^nFlamethrower loses, put the fire out.^n^n%d votes for Flamethrowers ON^n%d votes for Flamethrowers OFF^n^n%d Total eligible voters",
				option[0],option[1],totalvoters)
				set_cvar_string("amx_luds_flamethrower","0")
			}
			log_amx("World triggered ^"voting_failure^" (needed ^"%.2f^") (ratio ^"%.2f^")",
				vote_ratio,result_v)
		}
	}else{
		client_print(0,print_chat,"[AMX] Voting for flamethrowers failed... No clear majority.")
	}
	return PLUGIN_HANDLED
}

public vote_count(id,key)
{
	ejl_vault("READ","CURRENT_VOTE","")
	if(equal(vault_value,"FT_VOTE")){
	new name[32]
	get_user_name(id,name,32)
	if(votenumber != votecontroller[id][0]){
		votecontroller[id][0] = votenumber
		if (get_cvar_float("amx_vote_answers")) {
			client_print(0,print_chat,"[AMX] %s voted for option # %d",name,key+1)
		}
		option[key] += 1
	}else{
		votecontroller[id][1] +=1
	}
	}else{
		return PLUGIN_CONTINUE
	}
	return PLUGIN_HANDLED
}

public stopvote(id,level,cid){
	if (!cmd_access(id,level,cid,1))
		return PLUGIN_HANDLED
	if(bVoteToStop == true){
		new name[32]
		get_user_name(id,name,32)
		st_vote = 1
		client_print(id,print_console,"[AMX]  ADMIN !!! Ignore the unknown command message -- its ok")
		client_print(0,print_chat,"[AMX]  %s has disabled the vote in progress.",name)
	}
	return PLUGIN_CONTINUE
}

public fl_vote_deny(){
	flvote_deny = false
	return PLUGIN_CONTINUE
}

public client_connect(id){
	isburning[id] = 0
	votecontroller[id][1] = 0
	flame_count[id] = get_cvar_num("amx_flamethrower_ammo")
	return PLUGIN_CONTINUE
}

public client_disconnect(id){
	isburning[id] = 0
	votecontroller[id][1] = 0
	return PLUGIN_CONTINUE
}

public new_spawn(id){
	isburning[id] = 0
	flame_count[id] = get_cvar_num("amx_flamethrower_ammo") 
	return PLUGIN_CONTINUE
}		

public plugin_precache(){ 
	fire = precache_model("sprites/explode1.spr")

	smoke = precache_model("sprites/smoke.spr") 
	burning = precache_model("sprites/fire.spr")

	precache_sound("ambience/burning1.wav")
	precache_sound("ambience/flameburst1.wav")
	precache_sound("scientist/c1a0_sci_catscream.wav")
	precache_sound("vox/_period.wav")

	return PLUGIN_CONTINUE 
}

public plugin_init(){
	register_plugin("FlameThrower [DoD]","1.0.1","SidLuke")
	register_concmd("amx_flamethrowers","amx_fl",ADMIN_LEVEL_H,": toggles flamethrowers on and off")
	register_concmd("amx_flamethrowers_vote","amx_flvote",ADMIN_LEVEL_H,": toggles ability for players to start flamethrower votes on and off")
	register_concmd("amx_flamethrowers_vote_default","amx_flvote_d",ADMIN_RCON,": sets the current flamethrowervote mode to server default")
	register_clcmd("amx_fire_flamethrower","amx_fflame")
	register_clcmd("say /flamethrower","flamet_motd")
	register_clcmd("say","HandleSay")
	register_cvar("amx_luds_flamethrower","1",FCVAR_SERVER)
	register_cvar("amx_flamethrower_ammo","50")

	register_concmd("stopvote","stopvote",ADMIN_MAP,"stops vote in progress")
	register_menucmd(register_menuid("Allow Flamethrowers? ") ,(1<<0)|(1<<1)|(1<<2)|(1<<3),"vote_count")
	register_cvar("amx_fl_vote_ratio","0.51")
	register_cvar("amx_vote_time","15")
	register_cvar("amx_vote_answers","1")
	register_cvar("amx_vote_delay","1")
	register_cvar("amx_last_voting","0")
	register_cvar("amx_vote_inprogress","0")
	register_cvar("amx_flvote_delay","180.0")

	register_event("ResetHUD", "new_spawn", "b")

	get_datadir(szFileDir,63)
	add(szFileDir,63,"/ejl_vault.ini")

	ejl_vault("READ","FLAMETHROWER_VOTE","")
	if(equal(vault_value,"OFF"))
		bFLvote = false
	else
		bFLvote = true

	gmsgScoreShort = get_user_msgid("ScoreShort")
	gmsgDeathMsg = get_user_msgid("DeathMsg")

	gFlameThrowerId = custom_weapon_add("Flame Thrower",0,"flame_thrower") // name , melee ? , logname
	if ( !gFlameThrowerId )
		pause("a")
	
	return PLUGIN_CONTINUE
}

public ejl_vault(rw[],key[],value[]){
	new data[192]
	new stxtsize = 0
	new line = 0 
	new skip = 0
	new vkey[64]
	new vvalue[128]
	new vaultwrite[192]
	if(equal(rw,"READ")){
		if(file_exists(szFileDir) == 1){
			copy(vault_value,128,"")
			while((line=read_file(szFileDir,line,data,192,stxtsize))!=0){
				parse(data,vkey,64,vvalue,128)
				if(equal(vkey,key)){
					copy(vault_value,128,vvalue)
				}
			}
		}else{
			write_file(szFileDir, "**** Plugins use to store values -- immune to crashes and map changes ****", 0)
		}
	}
	else if(equal(rw,"WRITE")){
		if(file_exists(szFileDir) == 1){		
			format(vaultwrite,192,"%s %s",key,value)
			while((line=read_file(szFileDir,line,data,192,stxtsize))!=0){
				parse(data,vkey,64,vvalue,128)
				if(skip == 0){
					if( (equal(data,"")) || (equal(vkey,key)) ){
						skip = 1
						write_file(szFileDir,vaultwrite,line-1)
					}
				}
				else if(equal(vkey,key)){
					write_file(szFileDir,"",line-1)
				}
			}
			if(skip == 0){
				write_file(szFileDir,vaultwrite,-1)
			}
		}
	}
	return PLUGIN_CONTINUE
}

display_motd(id){
	new hk_motd[1300]

	new pos = copy( hk_motd,1299,"<html><head><style type=^"text/css^">pre{color:lightblue;}body{background:#000000;margin-left:8px;margin-top:0px;}</style></head><pre><body>")

	pos += format( hk_motd[pos],1299-pos,
			"Bind a key to amx_fire_flamethrower. Go to your console,^n\
	            choose a key for firing your flamethrower. Lets say^n\
			we want to use CAPSLOCK. Do this in console:^n^n\
			^tbind capslock amx_fire_flamethrower^n^n"
			)

	pos += format( hk_motd[pos],1299-pos,
			"Enter that and now whenever you press the CAPSLOCK key,^n\
                  it fires your flamethrower. By default each flamethrower^n\
		 	Flamethrower may need to be enabled by admin for you to use it.^n^n"
			)

	pos += format( hk_motd[pos],1299-pos,
			"The flamethrower, while not having a long range, does not by^n\
			nature require a high degree of accuracy and is thus very^n\
			effective and highly lethal at short range against members^n\
			of the opposite team.^n^n"
			)

	format(hk_motd[pos],1299-pos,"</pre></body></html>") 

	show_motd(id,hk_motd,"Flamethrower Help")
}
