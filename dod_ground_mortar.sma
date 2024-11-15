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


#define PLUGIN "DOD GROUND MORTAR"
#define VERSION "27jul2022"
#define AUTHOR "[America][TheVaskov]"




#define GMORTAR_MAXALL 64
#define GMORTAR_MAXHAVE 1
#define GMORTAR_SETDIST 150.0
#define GMORTAR_RADDAM 200.0
#define GMORTAR_DAMAGE 44.0


new const g_gmcname[] = "groundmortar" //Classname ������ entity

new const g_gmmdl[] = "models/mapmodels/hk_mortar.mdl" // ������
new const gentSpriteExplode[] = "sprites/explosion1.spr" //������ ������
new const gentSpriteSmoke[] = "sprites/puff.spr" //������ ����
new gent_Sprite[3] //���� ������� ������� ��������


new g_gm_limit[33]
new g_gm_owner[2048]
new g_maxgm
new g_MessageFade, gMsgDeathMsg, gMsgFrags


// new p_friendlyfire


public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_touch(g_gmcname, "player", "EntityTouch") //������� ������� ������������� � entity
	// register_forward(FM_Touch, "EntityTouch", 1)
	// register_think(g_gmcname, "EntityThink") //������� ������� �������� entity
	
	
	register_clcmd("say /gmor", "create_gmortar") //������� ��� ��������
	// register_clcmd("say /delete", "DeleteAllMines") //������� ��� ��������	
	
	
	
	register_event("HLTV", "Del_all_gmortars", "a", "1=0", "2=0")
	
	g_MessageFade = get_user_msgid("ScreenFade") //  ������������ ���� �������
	gMsgDeathMsg = get_user_msgid("DeathMsg")
	gMsgFrags = get_user_msgid("Frags")
	
	
	// RegisterHam(Ham_TakeDamage, "info_target", "fw_takedamage");
	register_forward(FM_CmdStart,"anttroop_button") // ������������ ������� ��� �������� ���� �� ������ �
	
	
	// p_friendlyfire = get_cvar_pointer("mp_friendlyfire")
}
public gmortar_button(id, uc_handle)// �������, ������� ��������� �������� ���� �� ������ �
{
static Button, OldButtons;
Button = get_uc(uc_handle, UC_Buttons);
OldButtons = pev(id, pev_oldbuttons);

if((Button & IN_USE) && !(OldButtons & IN_USE))
	create_gmortar(id)
	
}


public plugin_precache()
{
	precache_model( g_gmmdl ) //�������� � ������ ������
	gent_Sprite[1] = precache_model( gentSpriteExplode ) //�������� � ������ ������ ������
	gent_Sprite[2] = precache_model( gentSpriteSmoke ) //�������� � ������ ������ ����
} 

public Del_all_gmortars(){
	
	new gment  = engfunc(EngFunc_FindEntityByString, 0, "model", g_gmmdl) // c����� ���������� �������� ����� ����� �������
	while(gment != 0){
		/// ���� ������ �� ����� ���� � ���� ��� ������ �� �������
		if(gment > 0){
			remove_entity(gment)
			// client_print(0,print_chat,"Removed %d", gment)
			g_maxgm= 0
		}
		
		gment = engfunc(EngFunc_FindEntityByString, 0, "model", g_gmmdl)
		if(gment == 0) {
			// client_print(0,print_chat,"Removed alll")
			
			g_maxgm= 0
			gment = 0
			break
			/// � ��� ��� ������ ����� ����
		}
	}	
	
	for(new id = 0 ; id < get_maxplayers() ; id++){
		g_gm_limit[id] = 0
	}
}		

public create_gmortar(id)
{
	if(is_user_connected(id) && is_user_alive(id)){
		new iOrigin[3] //������� ������ ��� �������� ���������
		new iOrigin1[3] // ������ ��������
		get_user_origin(id, iOrigin, 3) //�������� ���������� ���� ������� �����
		get_user_origin(id, iOrigin1, 0) // ���������� ������
		
		new Float:fOrigin[3] //������� ������ ��� float ��������
		IVecFVec(iOrigin, fOrigin) //������������ ���������� � ������� \ ���� ����� ����������� ������
		
		// new gment = engfunc(EngFunc_CreateNamedEntity,engfunc(EngFunc_AllocString,"info_target"))
		new gment = create_entity("info_target")	// ������ ������
		set_pev(gment, pev_origin, fOrigin) //����������� ���������� ����� ������	
		
		
		if(!pev_valid(gment)) 
			{//��������� ���������� ��, ���� ���
		return PLUGIN_HANDLED //�����������. ������ ��� ������ ������
	}
	
	//set_pev(gment, pev_health, 1.0);
	//set_pev(gment, pev_takedamage, DAMAGE_YES);
	set_pev(gment, pev_classname, g_gmcname) //����������� Classname
	set_pev(gment, pev_solid, SOLID_BBOX) //������ ��� ������������
	set_pev(gment, pev_movetype, MOVETYPE_NONE) //�� ������ ��� ��������, �� ������ ������ ����
	// set_pev(gment, pev_sequence, 0) //���������� � �������� ��� ��������
	// set_pev(gment, pev_framerate, 1.0) //���������� �������� ��������
	
	new units = get_entity_distance(id,gment) // ���� ��������� ����� �������� � �����
	// client_print(id,print_chat,"Distance to mine %d units", units) // ����� ����������
	
	if(units > GMORTAR_SETDIST || g_maxgm>= GMORTAR_MAXALL || g_gm_limit[id] >= GMORTAR_MAXHAVE)  // ���� ����������� ����� 150 , ��� ����� ���� ��� ������ �� �������
	{ 
		remove_entity(gment)
		// client_print(id,print_chat,"You can not set mine: Distance: %d / %f | Actived mines on ground %d / %d ",units, GMORTAR_SETDIST, g_gm_limit[id], GMORTAR_MAXHAVE )
		
	}
	else{
		/// �� � ���� �� ������ 150 �� ��������� ���� ���
		
		// g_maxgmortars++
		g_gm_limit[id]++
		g_gm_owner[gment] = id
		
		// set_pev(gment, pev_nextthink, get_gametime() + 1.0) //������� ������ think
		
		emit_sound(id,CHAN_VOICE,"weapons/bazookareloadshovehome.wav",0.8,ATTN_NORM,0,PITCH_NORM + random_num(-30, -20)) // ���� ���������
		engfunc(EngFunc_SetModel, gment, g_gmmdl) //����������� ������
		engfunc(EngFunc_SetSize, gment, Float:{-6.0, -6.0, -3.0}, Float:{6.0, 6.0, 45.0}) //������� ���� ������ entity( ��� ������������� � �� ������ )
		
		
		set_task(2.0, "gm_attack", gment )
		// set_task(2.0, gm_attack, gment)
		
	}
}
return PLUGIN_HANDLED
} 

///////////////////////////////////////////////
public gm_attack(gment) {

new gmentOrigin[3]
pev(gment,pev_origin,gmentOrigin)


message_begin(MSG_BROADCAST,SVC_TEMPENTITY) //������� ���������
write_byte(TE_EXPLOSION) //������ ���������(������)
engfunc(EngFunc_WriteCoord, gmentOrigin[0]) //���������� x
engfunc(EngFunc_WriteCoord, gmentOrigin[1]) //���������� y
engfunc(EngFunc_WriteCoord, gmentOrigin[2] + 30.0) //���������� z
write_short(gent_Sprite[1]) //������ ������� ������
write_byte(6) //������ �������
write_byte(15) //�������� ��������
write_byte(0) //�����
message_end() //����� ���������

message_begin(MSG_BROADCAST,SVC_TEMPENTITY)//������� ���������
write_byte(TE_SMOKE) //������ ���������(���)
engfunc(EngFunc_WriteCoord, gmentOrigin[0]) //���������� x
engfunc(EngFunc_WriteCoord, gmentOrigin[1]) //���������� y
engfunc(EngFunc_WriteCoord, gmentOrigin[2] + 50.0) //���������� x
write_short(gent_Sprite[2]) //������ ������� ����
write_byte(15) //������ �������
write_byte(10) //�������� ��������
message_end() //����� ���������



message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
write_byte(TE_DLIGHT)
write_coord(gmentOrigin[0])
write_coord(gmentOrigin[1])
write_coord(gmentOrigin[2])
write_byte(5)
write_byte(12)
write_byte(252)
write_byte(199)
write_byte(2)
write_byte(25)
message_end()

/*
message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
write_byte(TE_WORLDDECAL);
engfunc(EngFunc_WriteCoord, fOriginE[0]);
engfunc(EngFunc_WriteCoord, fOriginE[1]);
engfunc(EngFunc_WriteCoord, fOriginE[2]);
write_byte(60);
message_end();
*/

set_task(2.0, "gm_attack", gment )
set_task(3.0, "gm_damage", gment )


}
public scr_shake(id)
{


new gmsgShake = get_user_msgid("ScreenShake")
message_begin(MSG_ONE, gmsgShake, {0,0,0}, id)
write_short(255<<14) //ammount
write_short(10<<14) //lasts this long
write_short(255<<14) //frequency
message_end()


}

public gm_damage(gment) {



new iPlayers[32] //������� ������ ��� �������� �������� �������
new iPlayer, iNum //��� ������ ���-�� ������� � ��������� ������ ������
new VictimId

get_players(iPlayers, iNum, "ach") //�������� �������, �������� �������, ����� � hltv

VictimId = random_num(1, iNum)


// scr_shake(VictimId)

new Float:fOrigPl[3] //������� ������ ��� float ��������� ������
pev(VictimId, pev_origin, fOrigPl) //�������� ���������� ������

fOrigPl[0] += random_float(- 400.0 , 400.0)
fOrigPl[1] += random_float(- 400.0 , 400.0)
fOrigPl[2] += random_float(1.0 , 2.0)



message_begin(MSG_ALL,SVC_TEMPENTITY)
write_byte(TE_DLIGHT)
write_coord(fOrigPl[0])
write_coord(fOrigPl[1])
write_coord(fOrigPl[2])
write_byte(5)
write_byte(12)
write_byte(252)
write_byte(199)
write_byte(2)
write_byte(25)
message_end()


message_begin(MSG_ALL,SVC_TEMPENTITY) //������� ���������
write_byte(TE_EXPLOSION) //������ ���������(������)
engfunc(EngFunc_WriteCoord, fOrigPl[0]) //���������� x
engfunc(EngFunc_WriteCoord, fOrigPl[1]) //���������� y
engfunc(EngFunc_WriteCoord, fOrigPl[2] - 20.0) //���������� z
write_short(gent_Sprite[1]) //������ ������� ������
write_byte(4) //������ �������
write_byte(15) //�������� ��������
write_byte(random_num(0,6)) //�����
message_end() //����� ���������



}





/*

for(new i; i < iNum; i++) //������� ���� �� ���� �������
{
iPlayer = iPlayers[i] //��� �������� ���������� ��������

new Float:fOrigPl[3] //������� ������ ��� float ��������� ������
pev(iPlayer, pev_origin, fOrigPl) //�������� ���������� ������

*/



