/* Plugin generated by AMXX-Studio */

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


#define PLUGIN "DOD_ARTILLERY"
#define VERSION "11.feb.2022"
#define AUTHOR "America"




#define TRIPMINE_MAXALL 64
#define TRIPMINE_MAXHAVE 2
#define TRIPMINE_SETDIST 2048.0
#define TRIPMINE_RADDAM 200.0
#define TRIPMINE_DAMAGE 1.0
new const gentClassname[] = "artillery" //Classname ������ entity

new const gentModel[] = "models/tnt_tripmine.mdl" // ������
new const gentSpriteExplode[] = "sprites/explosion1.spr" //������ ������
new const gentSpriteSmoke[] = "sprites/puff.spr" //������ ����
new gent_Sprite[3] //���� ������� ������� ��������

new g_maxplayers[33]
new g_mine_limit[33]
new g_mine_owner[2048]
new g_maxmines 
new g_MessageFade, gMsgDeathMsg, gMsgFrags
static hudicon

// new p_friendlyfire
new bool:log_block_state = false

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_touch(gentClassname, "player", "EntityTouch") //������� ������� ������������� � entity
	// register_forward(FM_Touch, "EntityTouch", 1)
	// register_think(gentClassname, "EntityThink") //������� ������� �������� entity
	register_clcmd("say /entity", "StartCreate") //������� ��� ��������
	register_clcmd("say /delete", "DeleteAllArtillery") //������� ��� ��������	
	
	g_MessageFade = get_user_msgid("ScreenFade") //  ������������ ���� �������
	gMsgDeathMsg = get_user_msgid("DeathMsg")
	gMsgFrags = get_user_msgid("Frags")
	
	
	register_forward(FM_CmdStart,"anttroop_button") // ������������ ������� ��� �������� ���� �� ������ �
	
	
	
	// p_friendlyfire = get_cvar_pointer("mp_friendlyfire")
}
public anttroop_button(id, uc_handle)// �������, ������� ��������� �������� ���� �� ������ �
{
static Button, OldButtons;
Button = get_uc(uc_handle, UC_Buttons);
OldButtons = pev(id, pev_oldbuttons);

if((Button & IN_USE) && !(OldButtons & IN_USE))
	StartCreate(id)
	
}


public plugin_precache()
{
	precache_model( gentModel ) //�������� � ������ ������
	gent_Sprite[1] = precache_model( gentSpriteExplode ) //�������� � ������ ������ ������
	gent_Sprite[2] = precache_model( gentSpriteSmoke ) //�������� � ������ ������ ����
} 

public DeleteAllArtillery(){
	
	new i4Entity  = engfunc(EngFunc_FindEntityByString, 0, "model", gentModel) // c����� ���������� �������� ����� ����� �������
	while(i4Entity != 0){
		/// ���� ������ �� ����� ���� � ���� ��� ������ �� �������
		if(i4Entity > 0){
			remove_entity(i4Entity)
			client_print(0,print_chat,"Removed %d", i4Entity)
			g_maxmines = 0
		}
		
		i4Entity = engfunc(EngFunc_FindEntityByString, 0, "model", gentModel)
		if(i4Entity == 0) {
			client_print(0,print_chat,"Removed alll")
			break
			g_maxmines = 0
			i4Entity = 0
			/// � ��� ��� ������ ����� ����
		}
	}	
	
	for(new id = 0 ; id < get_maxplayers() ; id++){
		g_mine_limit[id] = 0
	}
}		

public StartCreate(id)
{
	if(is_user_connected(id) && is_user_alive(id)){
		new iOrigin[3] //������� ������ ��� �������� ���������
		new iOrigin1[3] // ������ ��������
		get_user_origin(id, iOrigin, 3) //�������� ���������� ���� ������� �����
		get_user_origin(id, iOrigin1, 0)
		
		new Float:fOrigin[3] //������� ������ ��� float ��������
		IVecFVec(iOrigin, fOrigin) //������������ ���������� � ������� \ ���� ����� ����������� ������
		
		// new i4Entity = engfunc(EngFunc_CreateNamedEntity,engfunc(EngFunc_AllocString,"info_target"))
		new i4Entity = create_entity("func_breakable")	// ������ ������
		
		entity_set_int(i4Entity, EV_INT_solid, SOLID_BBOX)
		entity_set_int(i4Entity, EV_INT_effects, 0)
		entity_set_int(i4Entity, EV_INT_deadflag, DEAD_NO)
		entity_set_float(i4Entity, EV_FL_health, 100.0)
		entity_set_float(i4Entity, EV_FL_takedamage, 90.0) 
		
		
		fOrigin[2] += 200.0
		set_pev(i4Entity, pev_origin, fOrigin) //����������� ���������� ����� ������	
		
		// engfunc(EngFunc_SetView, id, i4Entity)  // ����������� ������.
		// new Float:fVel[3]
		// velocity_by_aim(id, 10, fVel)	
		// set_pev(i4Entity, pev_velocity, fVel)
		
		
		
		
		/*
		if(!pev_valid(i4Entity)) 
			{//��������� ���������� ��, ���� ���
		return PLUGIN_HANDLED //�����������. ������ ��� ������ ������
	}
	*/
	
	set_pev(i4Entity, pev_classname, gentClassname) //����������� Classname
	set_pev(i4Entity, pev_movetype, MOVETYPE_TOSS) //�� ������ ��� ��������, �� ������ ������ ����
	set_pev(i4Entity, pev_sequence, 0) //���������� � �������� ��� ��������
	set_pev(i4Entity, pev_framerate, 1.0) //���������� �������� ��������
	
	new units = get_entity_distance(id,i4Entity) // ���� ��������� ����� �������� � �����
	client_print(id,print_chat,"Distance to mine %d units", units) // ����� ����������
	
	if(units > TRIPMINE_SETDIST || g_maxmines >= TRIPMINE_MAXALL || g_mine_limit[id] >= TRIPMINE_MAXHAVE)  // ���� ����������� ����� 150 , ��� ����� ���� ��� ������ �� �������
	{ 
		remove_entity(i4Entity)
		client_print(id,print_chat,"You can not set mine")
		
	}
	else{
		/// �� � ���� �� ������ 150 �� ��������� ���� ���
		
		g_maxmines++
		g_mine_limit[id]++
		g_mine_owner[i4Entity] += id
		
		// set_pev(i4Entity, pev_nextthink, get_gametime() + 1.0) //������� ������ think
		
		emit_sound(id,CHAN_VOICE,"weapons/bazookareloadshovehome.wav",0.8,ATTN_NORM,0,PITCH_NORM + random_num(-30, -20)) // ���� ���������
		engfunc(EngFunc_SetModel, i4Entity, gentModel) //����������� ������
		engfunc(EngFunc_SetSize, i4Entity, Float:{-6.0, -6.0, -3.0}, Float:{6.0, 6.0, 3.0}) //������� ���� ������ entity( ��� ������������� � �� ������ )
		
	}
}
return PLUGIN_HANDLED
} 

public EntityTouch(i4Entity, id)
{

/// ������� ����� ���� � �����

if(!pev_valid(i4Entity)) //��������� ���������� ��, ���� ���
	return FMRES_IGNORED

new Float:fOrigin[3] //������� ������ ��� float ���������
pev(i4Entity, pev_origin, fOrigin) //�������� ���������� entity

new Float:fOriginE[3] //������� ������ ��� float ��������� entity
pev(i4Entity, pev_origin, fOriginE) //�������� ���������� entity

new iPlayers[32] //������� ������ ��� �������� �������� �������
new iPlayer, iNum //��� ������ ���-�� ������� � ��������� ������ ������

get_players(iPlayers, iNum, "ach") //�������� �������, �������� �������, ����� � hltv

for(new i; i < iNum; i++) //������� ���� �� ���� �������
{
	iPlayer = iPlayers[i] //��� �������� ���������� ��������
	
	new Float:fOriginP[3] //������� ������ ��� float ��������� ������
	pev(iPlayer, pev_origin, fOriginP) //�������� ���������� ������
	
	new Float:fDistance //������� ������ ��� �������� ���������
	fDistance = get_distance_f(fOriginP, fOriginE) //�������� ��������� ����� ������� � entity
	
	if(fDistance < TRIPMINE_RADDAM) //���� ��������� < 300.0
	{	
		new current_health = pev(iPlayer,pev_health)
		
		new Float:damagetripmine = TRIPMINE_RADDAM - fDistance
		
		current_health = current_health - damagetripmine - TRIPMINE_DAMAGE
		set_pev(iPlayer,pev_health,current_health)
		
		if(current_health <= 1.0){
			new deathcount =  dod_get_pl_deaths(iPlayer)
			deathcount++
			dod_set_pl_deaths(iPlayer, deathcount, 1)
			
			message_begin(MSG_ALL,gMsgDeathMsg,{0,0,0},0)
			write_byte(g_mine_owner[i4Entity]) // killer
			write_byte(iPlayer) // victim
			write_byte(42)  // 42 is smash
			message_end()
			
			
		}
		
		
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY) //������� ���������
		write_byte(TE_EXPLOSION) //������ ���������(������)
		engfunc(EngFunc_WriteCoord, fOrigin[0]) //���������� x
		engfunc(EngFunc_WriteCoord, fOrigin[1]) //���������� y
		engfunc(EngFunc_WriteCoord, fOrigin[2] + 30.0) //���������� z
		write_short(gent_Sprite[1]) //������ ������� ������
		write_byte(10) //������ �������
		write_byte(15) //�������� ��������
		write_byte(0) //�����
		message_end() //����� ���������
		
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)//������� ���������
		write_byte(TE_SMOKE) //������ ���������(���)
		engfunc(EngFunc_WriteCoord, fOrigin[0]) //���������� x
		engfunc(EngFunc_WriteCoord, fOrigin[1]) //���������� y
		engfunc(EngFunc_WriteCoord, fOrigin[2] + 50.0) //���������� x
		write_short(gent_Sprite[2]) //������ ������� ����
		write_byte(25) //������ �������
		write_byte(10) //�������� ��������
		message_end() //����� ���������
		
		
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
		write_byte(TE_WORLDDECAL);
		engfunc(EngFunc_WriteCoord, fOrigin[0]);
		engfunc(EngFunc_WriteCoord, fOrigin[1]);
		engfunc(EngFunc_WriteCoord, fOrigin[2]);
		write_byte(60);
		message_end();
		
		red_flash(iPlayer)
		
		
	}
}





g_mine_limit[(g_mine_owner[i4Entity])] --
g_maxmines--

new fragcount = dod_get_user_kills(g_mine_owner[i4Entity])
fragcount++
dod_set_user_kills(g_mine_owner[i4Entity], fragcount, 1)
if(g_maxmines<1) g_maxmines=0





remove_entity(i4Entity)

return FMRES_IGNORED
} 

///////////////////////////////////////////////
/*

public EntityThink(i4Entity)
{
if(!pev_valid(i4Entity)) {
	//��������� ���������� ��, ���� ���
	
	
	new Float:fOriginE[3] //������� ������ ��� float ��������� entity
	pev(i4Entity, pev_origin, fOriginE) //�������� ���������� entity
	
	return PLUGIN_CONTINUE
	
}
// set_pev(i4Entity, pev_nextthink, get_gametime() + 0.1) //���������
return PLUGIN_CONTINUE
} 
*/
///////////////////////////////////////////



stock red_flash(id)
{

message_begin(MSG_ONE_UNRELIABLE, g_MessageFade , {0,0,0}, id)
write_short(1<<10)
write_short(1<<10)
write_short(0x0001)
write_byte(240)
write_byte(10) 
write_byte(10) 
write_byte(50)
message_end() 	

}
/*
new wpnid_tripmine

wpnid_tripmine = custom_weapon_add("Tripmine Grenade",0,"tripmine_grenade")

custom_weapon_shot(wpnid_tripmine,id)

custom_weapon_dmg(wpnid_tripmine,grenade_owner,ent,tripmine_damage,HIT_CHEST)
*/

//////////////

/*
public block_log(type, msg[])
return(log_block_state?FMRES_SUPERCEDE:FMRES_IGNORED)

public tripminedamage(i4Entity)
{
new Float:GrenOrigin[3],ent = -1
pev(i4Entity,pev_origin,GrenOrigin)

while((ent = engfunc(EngFunc_FindEntityInSphere,ent,GrenOrigin,SETTING_TRIPMINEDAMAGERADIUS)) != 0)
{
	new classname[32]
	pev(ent,pev_classname,classname,31)
	
	if(equali(classname,"player") && is_user_alive(ent) && !get_user_godmode(ent))
	{
		if(random_num(1,1) == 1) 
		{
			
			new tribal
		}
		if(random_num(1,1) == 1)
		{				
			new tripmine_owner = pev(i4Entity,pev_owner)
			
			if(!is_user_connected(tripmine_owner))
				return PLUGIN_HANDLED
			
			new attacker_team = get_user_team(tripmine_owner)
			new victim_team = get_user_team(ent)
			
			if(attacker_team != victim_team || (attacker_team == victim_team && get_pcvar_num(p_friendlyfire)))
			{
				new current_health = pev(ent,pev_health)
				
				if(current_health > TRIPMINEDAMAGE)
				{							
					// emit_sound(ent,CHAN_VOICE,fileNames[random_num(cough1,cough2)],0.6,ATTN_NORM,0,PITCH_NORM + random_num(-30, -20))
					// emit_sound(ent,CHAN_BODY,fileNames[grunt],1.0,ATTN_NORM,0,PITCH_NORM + random_num(-30, -20))
					
					set_pev(ent,pev_health,float(current_health - TRIPMINEDAMAGE))
					
					//custom weapon damage	
					custom_weapon_dmg(wpnid_tripmine,tripmine_owner,ent,TRIPMINEDAMAGE,HIT_CHEST)
				}
				else
				{
					// emit_sound(ent,CHAN_VOICE,fileNames[random_num(cough1,cough2)],0.6,ATTN_NORM,0,PITCH_NORM + random_num(-30, -20))
					// emit_sound(ent,CHAN_BODY,fileNames[grunt],1.0,ATTN_NORM,0,PITCH_NORM + random_num(-30, -20))
					
					log_block_state = true
					user_silentkill(ent)
					log_block_state = false
					
					message_begin(MSG_ALL,gMsgDeathMsg,{0,0,0},0)
					write_byte(tripmine_owner)
					write_byte(ent)
					write_byte(0)
					message_end()
					
					new steam[32],teamname[32],name[32]
					new steam2[32],teamname2[32],name2[32]
					get_user_authid(tripmine_owner,steam,31)
					get_user_authid(ent,steam2,31)
					dod_get_pl_teamname(tripmine_owner,teamname,31)
					dod_get_pl_teamname(ent,teamname2,31)
					get_user_name(tripmine_owner,name,31)
					get_user_name(ent,name2,31)
					
					log_message("^"%s<%d><%s><%s>^" killed ^"%s<%d><%s><%s>^" with ^"tripmine_grenade^"", name, get_user_userid(tripmine_owner), steam, teamname, name2, get_user_userid(ent), steam2, teamname2)
					
					//custom weapon damage	
					custom_weapon_dmg(wpnid_tripmine,tripmine_owner,ent,TRIPMINEDAMAGE,HIT_CHEST)
					
					new kills = dod_get_user_kills(tripmine_owner) + 1
					dod_set_user_kills(tripmine_owner, kills,0)
					
					message_begin(MSG_BROADCAST,gMsgFrags,{0,0,0},0)
					write_byte(tripmine_owner)
					write_short(kills)
					message_end()
					
				}
			}
		}
	}
}
}
*/
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1049\\ f0\\ fs16 \n\\ par }
*/