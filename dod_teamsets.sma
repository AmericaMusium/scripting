#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <fakemeta_util>
#include <dodx>
#include <dodfun>
#include <fun>
#include <engine>

#define PLUGIN "DOD_TEAMSETS"
#define VERSION "1.0"
#define AUTHOR "[America][TheVaskov]"

#define pev_army pev_groupinfo

// new const BRITISH = 0
// new const ALLIES = 1
// new const AXIS = 2
new const USSR = 4

/*
// Check if its Allies, If so is it a brit map?
new team = get_user_team(id)
if(team == 1 && dod_get_map_info(MI_ALLIES_TEAM))
		is_brit = true

get_user_team: allies and brit = 1 / axis = 2 
get_user_class:
	ALLIES:
garand = 1
m1 = 2 
thomp = 3
greese = 4
spring = 5
bar = 6
30cal = 7
bazooka = 8
	AXIS:
k98 = 10
k43 = 11
mp30 = 12
stg44 = 13
kar98s = 14
FG42 = 15
FG42s = 16
MG34-Schütze = 17
MG42-Schütze = 18
PanzerJager = 19
	BRIT:
enfield = 21
sten = 22
enfieldS = 23
bren = 24
PIAT = 25
*/
// new army[45]

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
		
	RegisterHam(Ham_Spawn,"player","Player_Respawn")

	register_clcmd("say ssov", "Player_Call_USSR") 
	register_clcmd("say amer", "Player_Call_USA")
	register_clcmd("say /ussr", "Player_Call_USSR") 
	register_clcmd("say /usa", "Player_Call_USA")

	register_clcmd("usa", "Player_Call_USA")
	register_clcmd("ussr", "Player_Call_USSR")
	register_clcmd("say /axis", "Player_Call_AXIS")
	
}

public plugin_precache() 
{
	precache_model("models/player/ussr-inf/ussr-inf.mdl")  
	precache_model("models/player/ussr-inf/ussr-infT.mdl") 
}
public Player_Call_USSR(id)
{
	// dod_set_user_team(id, ALLIES ,1);
	client_cmd(id,"jointeam 1")
	Player_Set_team(id, USSR)
	
}
public Player_Call_USA(id)
{
	// dod_set_user_team(id, ALLIES ,1);
	client_cmd(id,"jointeam 1")
	Player_Set_team(id, ALLIES)
}

public Player_Call_AXIS(id)
{
	// dod_set_user_team(id, AXIS ,1);
	client_cmd(id,"jointeam 2")
	Player_Set_team(id, AXIS)
}

public Player_Set_team(id, army)
{
	new myteam = get_user_team(id)

	if (myteam == ALLIES)
	{	
		if (army == ALLIES) 
		{
			set_pev(id, pev_army, ALLIES)
			client_print(id,print_chat,"[TEAMS] You'll spawn as Allies soldier")
		}
		if (army == USSR)
		{
		set_pev(id, pev_army, USSR)
		// dod_clear_model(id)
		// dod_set_model(id,"ussr-inf")
		// set_entvar(id, var_body, random_num(0, 4));
		// pev(id,pev_body, 675)
		client_print(id,print_chat,"[TEAMS] You'll spawn as USSR soldier")
		}
		else return;
	}

	
	if (myteam == AXIS)
	{
		if (army == AXIS)
		{	
			set_pev(id, pev_army, AXIS)
		}
		if (army == USSR)
		{
			// dod_clear_model(id)
			client_print(id,print_chat,"[TEAMS] AXIS CANT BE USSR ")
		}
		
	}
}

public Player_Respawn(id)
{	
	if(!is_user_alive( id )) return
	new myteam = get_user_team(id)
	new myarmy = pev(id, pev_army)
	new myclass = dod_get_user_class(id)
	// client_print(0, print_chat ,"[TEAMS] get_user_team = %d , class: %d , army %d" , myteam, myclass, myarmy)

	if (myteam == ALLIES)
	{	
		if (myarmy == ALLIES) 
		{
			dod_clear_model(id)
			client_print(id,print_chat,"[TEAMS] You spawned as Allies soldier")	
		}
		else if (myarmy == USSR)
		{
			dod_clear_model(id)
			dod_set_model(id,"ussr-inf")
		
			
			if (myclass == 3) 
			{
				/*
				strip_user_weapons(id)
				give_item(id, "weapon_spade")
				give_item(id, "weapon_colt")
				*/
				//client_cmd(id,"usa")
				console_cmd(id,"say weapon_tt33;")
				console_cmd(id,"say weapon_pps43;")
			}
			client_print(id,print_chat,"[TEAMS] You spawned as USSR soldier")	
		}
	}
	
	else if (myteam == AXIS)
	{
		dod_clear_model(id)
	} 
	else dod_clear_model(id)

}
		