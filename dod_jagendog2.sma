#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <dodx>
#include <dodfun>
#include <fun>
#include <xs>


#define PLUGIN "DOD JAGENDOG"
#define VERSION "1.0"
#define AUTHOR "[America][TheVaskov]"

#define RADENEMYS 2200.0
#define RADWEAPBS 1200.0

new g_Cvar[5] //�����
new const gModel[] = "models/red/tnt_pes.mdl" //������ NPC
new const gClassname[] = "jagendog" //��������� NPC

new const g_jblong[] = "weapons/red/jagenbarklong.wav"
new const g_jbshort[] = "weapons/red/jagenbarkshort.wav"
new const g_jbbree[] = "weapons/red/jagenbreethe.wav"

new g_msgHudText


//// new dodjagendebug  get pcvar   if(

static flastDogOrigin[3]

new debugmessage

//��������� ������(������ npc �� ����� ��)
enum _:GIBS
{
HEAD,
LEG,
BONE,
LUNG,
GIB
}

new gModelGibs[GIBS] //������� ������
new gSpriteBlood //������ �������

new iDog_id //������������� ���������� NPC
static iTar_fDog //������������� ������, ������� ������ NPC

new Float:fNPCOrigin[3] //���������� ����� ��������� NPC

public plugin_init()
{
register_plugin(PLUGIN, VERSION, AUTHOR) //�� ����� ��� ����

register_think(gClassname, "NPCThink") //������� �������� NPC

g_Cvar[1] = register_cvar("testnpc_health", "100") //����� npc
g_Cvar[2] = register_cvar("testnpc_speed", "280") //�������� noc
g_Cvar[3] = register_cvar("testnpc_distance", "98") //����������� ��������� ��� ������� �� ������� �� ����
debugmessage = register_cvar("debug_mesasge", "1")

g_msgHudText = get_user_msgid("HudText")


register_clcmd("say /npco", "NPCOrigin") //������� �������� ��������� ���������
register_clcmd("say /npcc", "NPCCreate") //������� ����������������� ��������


}

public plugin_precache()
{
precache_model( gModel ) //������ ������ NPC
precache_sound(g_jblong)
precache_sound(g_jbshort)
precache_sound(g_jbbree)



//������
gModelGibs[HEAD] = precache_model("models/w_bar.mdl")
gModelGibs[LEG] = precache_model("models/w_fg42.mdl")
gModelGibs[BONE] = precache_model("models/w_colt.mdl")
gModelGibs[LUNG] = precache_model("models/w_garand.mdl")
gModelGibs[GIB] = precache_model("models/w_k43.mdl")

//�����
gSpriteBlood = precache_model("sprites/blood-narrow.spr")

} 




public NPCOrigin(id)
{
entity_get_vector(id, EV_VEC_origin, fNPCOrigin) //���������� ����������
client_print(id, print_chat, "[NPC]Origin create") //������� ���������
} 

public NPCCreate(id)
{   

iTar_fDog = id /// ����� ����� 

/*   ������������ �������� ����� 2�
if(iDog_id) //���� npc ��� ��� ������
{
	remove_entity(iDog_id) //������� ���
	iDog_id = 0 //���������� �������������
}
*/
iDog_id = create_entity("info_target") //������� ������

if(pev_valid( iDog_id )) //���������, ������ �� ������
{
	if(debugmessage) client_print(id, print_chat, "[NPC]Create") //���� ��, �����, ��� ������
	
	message_begin(MSG_ONE,g_msgHudText,{0,0,0},id);
	write_string("DOD Jagendog ! WBARK ! ") // sprite name
	write_byte(1); // red
	message_end();
	
	
	}else{
	if(debugmessage) client_print(id, print_chat, "[NPC]Error create") //����� �������
	return PLUGIN_HANDLED //���������� ���������� ���������� �������
}

entity_set_origin(iDog_id, fNPCOrigin) //������ �� ����������, ��������� ���� �����


entity_set_float(iDog_id, EV_FL_takedamage,1.0) //������ ��������

new Float:fHealth = float( get_pcvar_num( g_Cvar[1] )) //�������� �������� ����� � ������������ � ������� �����
entity_set_float(iDog_id, EV_FL_health, fHealth) //����������� ���������� ������

entity_set_model(iDog_id, gModel) //�������� ������
entity_set_string(iDog_id, EV_SZ_classname, gClassname) //����������� �����


entity_set_edict(iDog_id, EV_ENT_owner, id) // ����� �������

entity_set_int(iDog_id, EV_INT_solid, SOLID_BBOX) //������ ��� ������������
entity_set_int(iDog_id, EV_INT_movetype, MOVETYPE_PUSHSTEP) //NPC ����� ������������� �� �����
entity_set_float(iDog_id, EV_FL_gravity, 1.2)
entity_set_size(iDog_id, Float:{-16.0, -16.0, -36.0}, Float:{16.0, 16.0, 16.0}) //������ �������( �� ������ � �������� ������ )

entity_set_float(iDog_id, EV_FL_nextthink, halflife_time() + 0.3) //������� think

//������ ��������
set_pev(iDog_id, pev_enemy, 0)
entity_set_int(iDog_id, EV_INT_gamestate,1)

entity_set_int(iDog_id, EV_INT_sequence, 1) //������ ��������� ��������
entity_set_float(iDog_id, EV_FL_animtime, get_gametime()) //������ ����� ��������
entity_set_float(iDog_id, EV_FL_framerate,  1.0) //������ �������� ��������
entity_set_float(iDog_id, EV_FL_frame, 0.0) //������ ��������� ����

emit_sound(iDog_id, CHAN_ITEM,g_jbbree,0.2,ATTN_NORM,0,PITCH_NORM)
task_repeater( iDog_id )
RegisterHamFromEntity(Ham_Killed, iDog_id, "NPCKilled") //������ ������� ������

//////////////////////////////////////������� � ����� ������
// new iWeapon = create_entity("info_target")

//entity_set_int(iWeapon, EV_INT_solid, SOLID_NOT) //�� ������ ������� ���������� �������
//entity_set_int(iWeapon, EV_INT_movetype, MOVETYPE_FOLLOW) //������ �������� ���������� ������� �� �������
//entity_set_edict(iWeapon, EV_ENT_aiment, iDog_id) //��������������� ������������ ������� � NPC
//entity_set_model(iWeapon, "models/p_garand.mdl") //������ ������( ������ ���� ���������� ��� ������ )



return PLUGIN_HANDLED //�����
} 

public NPCThink( iDog_id )
{

if(!is_valid_ent( iDog_id )) //���� NPC �� ����������
	return FMRES_IGNORED //���������� ���������� ���������� �������
	
	new owner = entity_get_edict(iDog_id, EV_ENT_owner)
	
	if( !is_valid_ent( iTar_fDog )) {
		
		iTar_fDog = owner
		// return FMRES_IGNORED
	}
	
	
	if(!is_user_alive( owner ) || !is_user_connected( owner ) ) //���� ����� ����� ��� ������������
	{
		remove_entity( iDog_id ) //������� NPC
		iDog_id = 0 //���������� �������������
		
		return FMRES_IGNORED //���������� ���������� ���������� �������
	}
	new Float:fNOrigin[3], Float:fPOrigin[3] //���� ������� ���������� NPC � ������
	new Float:fDistance //���� ������� ��������� ����� ����
	pev(iDog_id, pev_origin, fNOrigin) //�������� ���������� NPC
	// //�������� ���������� NPC - ������ �� �����������
	
	pev(iTar_fDog, pev_origin, fPOrigin) //�������� ���������� ������
	fDistance = get_distance_f(fNOrigin, fPOrigin) //�������� ��������� ����� ����
	
	if(fDistance <= float( get_pcvar_num( g_Cvar[3] ) )) //���� �������� ����� ���������
	{	
		new classnametarget[32]
		new name[32]
		pev(iTar_fDog, pev_classname, classnametarget,31)
		// entity_get_edict(iDog_id, EV_ENT_owner)
		if(debugmessage) client_print(0, print_center, "[DOG] DOG COMES TO %d %s", iTar_fDog, classnametarget  ) //����� ��� ������� �������, ��� NPC ������ ���
		
		
		
		////////////////////// WEAPONBOX GET
		if(equal(classnametarget, "weaponbox")){
			
			// entity_set_int(iTar_fDog, EV_INT_solid, SOLID_NOT) //�� ������ ������� ���������� �������	
			/// HERE WHEN DOG CONTACT CLOSSE TO /////////////////
			entity_set_int(iTar_fDog, EV_INT_movetype, MOVETYPE_FOLLOW) //������ �������� ���������� ������� �� �������
			entity_set_edict(iTar_fDog, EV_ENT_aiment, iDog_id) //��������������� ������������ ������� � NPC
			entity_set_int(iDog_id, EV_INT_iuser4, iTar_fDog)
			if(debugmessage) client_print(0, print_center, "[DOG] DOG GETS WEAPONBOX %d %s", iTar_fDog)
			iTar_fDog = owner
		}
		
		///////////////////// COME TO PAPA ///  ������� ����� 
		if(iTar_fDog == owner){
			
			get_user_name(iTar_fDog, name, 31)
			new weaponid = get_user_weapon(owner, _,_)
			new teeth = entity_get_int(iDog_id,EV_INT_iuser4)
			
			/*
			if(!is_valid_ent( teeth )) entity_set_int(iDog_id, EV_INT_iuser4, 0)
			
			if(is_valid_ent( teeth )) {
				entity_set_int(teeth, EV_INT_movetype, MOVETYPE_TOSS)
				entity_set_edict(teeth, EV_ENT_aiment, 0)
				drop_to_floor(teeth)
				entity_set_int(iDog_id, EV_INT_iuser4, 0)
				
			}
			
			*/
			
			if(teeth){
				//////////
				if(!is_valid_ent( teeth )) {
					if(debugmessage) client_print(0, print_chat, "[DOG] COMES TO OWNER: TEETH %d NO VALID - DELETED", teeth)
					entity_set_int(iDog_id, EV_INT_iuser4, 0)
				}
				if(is_valid_ent( teeth )) {
					
					/////
					
				}
				
			}
			
			
			// client_print(0, print_chat, "[DOG] %s PAPA APORT Teeth: %d iDog_id %d dog %d ", name , teeth, iDog_id, iDog_id)
			if(weaponid == 19 && !teeth) {
				
				/// HERE WHEN DOG CONTACT CLOSSE TO
				
				if(debugmessage) client_print(0, print_chat, "[DOG] YOU MAKES A COOMAND TO SEARCH WEAPONBOX")
				find_numberOfweaponbox(iDog_id)
				
				
			}
			
		}
		
		/////////////////////////////////////////////////////////// ATTACK 
		
		if( iTar_fDog > 0 && iTar_fDog < 33 && iTar_fDog != owner) {
			
			// radius_damage(fNOrigin, 50, 50)
			
			get_user_name(iTar_fDog, name, 31)
			if(debugmessage) client_print(0, print_chat, "[DOG] %s under Attack", name)
			if(!is_user_alive(iTar_fDog) || !is_user_connected(iTar_fDog)) find_numberOfweaponbox(iDog_id)
		}
		
		
		
		if(pev(iDog_id, pev_sequence) != 1) //���� �������� npc ����������� �� �������
		{
			entity_set_int(iDog_id, EV_INT_sequence, 1) //������ �������� ����
			entity_set_float(iDog_id, EV_FL_animtime, get_gametime()) //������ ����� ��������
			entity_set_float(iDog_id, EV_FL_framerate, 1.0) //������ �������� ��������
			entity_set_float(iDog_id, EV_FL_frame, 0.0) //������ ��������� ����
			
			
			emit_sound(iDog_id, CHAN_ITEM,g_jbbree,0.3,ATTN_NORM,0,PITCH_NORM)
		}
		}else{
		if(pev(iDog_id, pev_sequence) != 4) //���� �������� npc ����������� �� ����
		{
			entity_set_int(iDog_id, EV_INT_sequence, 4) //������ �������� ����
			entity_set_float(iDog_id, EV_FL_animtime, get_gametime()) //������ ����� ��������
			entity_set_float(iDog_id, EV_FL_framerate, 1.0) //������ �������� ��������
			entity_set_float(iDog_id, EV_FL_frame, 0.0) //������ ��������� ����
			
			
			// emit_sound(iDog_id, CHAN_ITEM, g_jblong,1.0,ATTN_NORM,0,PITCH_NORM)
		}
		
		new Float:fAngles[3] //���� ������� ����������, ���� ������ ����� �������� NPC
		new Float:fVelocity[3] //���� ������� ����������, ���� ����� ������ NPC
		
		entity_get_vector(iDog_id, EV_VEC_angles, fAngles) //��������
		
		new Float:fX = fPOrigin[0] - fNOrigin[0] //����������� ���������� x
		new Float:fZ = fPOrigin[1] - fNOrigin[1] //����������� ���������� z
		
		new Float:fRadian
		fRadian = floatatan(fZ/fX, radian) //�������� ����
		
		fAngles[1] = fRadian * (180 / 3.14) //���������� ����������
		
		if(fPOrigin[0] < fNOrigin[0]) //���� ���������� ������ ������������ x ������ NPC`�������
		{
			fAngles[1] = fAngles[1] - 180.0 //������������� ���
			}else{
			fAngles[1] = fRadian * (180 / 3.14) //���������� ����������
		}
		
		new Float:fSpeed = fDistance / float( get_pcvar_num( g_Cvar[2] ) ) //������ ��������
		
		fVelocity[0] = (fPOrigin[0] - fNOrigin[0]) / fSpeed
		fVelocity[1] = (fPOrigin[1] - fNOrigin[1]) / fSpeed
		fVelocity[2] = (fPOrigin[2] - fNOrigin[2]) / fSpeed
		
		// HiGH LEVEL off boost
		if( fVelocity[2] > 150.0) fVelocity[2] = 100.0
		
		// Close boost
		if( fVelocity[2] > 1.0 && fVelocity[2] < 100 && (fPOrigin[2] - fNOrigin[2]) < 200.0 && fDistance < 290.0) fVelocity[2] += 200.0
		
		// Small boxes boost
		if( fVelocity[2] > 1.0 && fVelocity[2] < 100 && (fPOrigin[2] - fNOrigin[2]) > 200.0 && fDistance > 290.0) fVelocity[2] += 100.0
		
		// default felocity Upboost
		if( fVelocity[2] < 40.0 && fDistance > 290.0) fVelocity[2] += 70.0
		
		new Float:fDistanceBlock
		fDistanceBlock = get_distance_f(fNOrigin, flastDogOrigin)
		
		// client_print(0, print_chat, "fVel Z  =%f", fVelocity[2])
		// client_print(0, print_chat, "fVel x = %f  fVel y = %f", fVelocity[0], fVelocity[1])
		
		/// Antiblock system
		if( fSpeed > 0.3 && fDistanceBlock < 30.0){ 
			
			fVelocity[0] += random_float(-200.0, 200.0)
			fVelocity[1] += random_float(-200.0, 200.0)
			fVelocity[2] += random_float(50.0, 110.0)
			
			
			client_print(0, print_chat, "ANTIBLOCK: s %f , d %f ", fSpeed, fDistanceBlock)
		}
		
		
		// client_print(0, print_chat, "Speed: %f blDist %f ", fSpeed , fDistanceBlock )
		
		entity_set_vector(iDog_id, EV_VEC_angles, fAngles) //����������� ����� ���������� ���� ��������
		entity_set_vector(iDog_id, EV_VEC_velocity, fVelocity) //����������� ����� ���������� ���� ������
	}
	pev(iDog_id, pev_origin, flastDogOrigin)
	entity_set_float(iDog_id, EV_FL_nextthink, halflife_time() + 0.3) //���������
	
	return FMRES_HANDLED
} 

/*
public find_weaponboxdogpvs(id){ 
	
	static class[32];
	static ent, chain;
	ent = engfunc(EngFunc_EntitiesInPVS, id);
	while(ent)
	{
		chain = pev(ent, pev_chain);
		// pev(ent, pev_origin, point);
		pev(ent, pev_classname, class, charsmax(class));
		if(equal(class, "weaponbox"))
		{
			
			client_print(0,print_chat, "Found entity in PVS (ent:%i class:%s)", ent, class)
			iTar_fDog = ent
			
		}
		
		if(!chain)
			break;
		
		ent = chain;
	}
	return PLUGIN_HANDLED;
}
*/

/*
public find_weaponboxdogpvs2(dog) 
{ 
	static nextz, chainz
	static  classz [ 32 ]
	
	nextz = engfunc ( EngFunc_EntitiesInPVS, dog ) 
	while ( nextz ) 
	{ 
		// pev ( nextz, pev_classname, classz , charsmax ( class ) ) 
		chainz = pev ( nextz, pev_chain ) 
		
		server_print ( "������ ������ � ������������� (%i) PVS: ent(%i) class(%s)" , dog, nextz, classz ) 
		
		if ( ! chainz ) 
			break
		
		nextz = chainz
	} 
}

*/
public task_repeater(iDog_id ){
	if(pev_valid( iDog_id )) //���������, ������ �� ������
	{
		find_numberOfplayers(iDog_id)
		if(debugmessage) client_print(0, print_chat, "[DOG] SEARCH ENEMY TASK START" )
		set_task(2.0, "task_repeater", iDog_id )
		
	}
}

find_numberOfplayers(dog)
{
new entityList[20]
new owner = entity_get_edict(dog, EV_ENT_owner)
new teeth = entity_get_int(dog,EV_INT_iuser4)

new numberOfplayers = find_sphere_class(dog, "player", RADENEMYS, entityList, sizeof entityList)

if (numberOfplayers > 0)
{
	// Found that many weaponboxes near the dog
	
	// If you need to get the closest one, sort the array
	new data[1]
	data[0] = dog
	SortCustom1D(entityList, numberOfplayers, "SortByShortestDistance")
	
	if(!is_user_alive(entityList[0]) || !is_user_connected(entityList[0])) iTar_fDog = owner
	
	if(entityList[0] != owner && is_user_alive(entityList[0]) && is_user_connected(entityList[0])){
		
		// if(!is_user_alive(entityList[0]) || !is_user_connected(entityList[0])) iTar_fDog = owner
		
		new ot = get_user_team(owner)
		new vt2 = entityList[0]
		new vt = get_user_team(vt2)
		
		if(ot!= vt) {
			
			iTar_fDog = entityList[0]
			if(teeth){
				//////////
				if(!is_valid_ent( teeth )) {
					client_print(0, print_chat, "[DOG] Search %d enemy: teeth %d NO VALID", iTar_fDog, teeth)
					entity_set_int(iDog_id, EV_INT_iuser4, 0)
				}
				if(is_valid_ent( teeth )) {
					
					entity_set_int(teeth, EV_INT_movetype, MOVETYPE_TOSS)
					entity_set_edict(teeth, EV_ENT_aiment, 0)
					drop_to_floor(teeth)
					entity_set_int(iDog_id, EV_INT_iuser4, 0)
					
					
				}
				
				
				//iTar_fDog = entityList[0]      +++++++++
				/// SET TEETH TO ZERO , DROP WEAPONBOX .
				
				
			}
		}
		
		
	}
}
}
find_numberOfweaponbox(dog)
{
new entityList[20]
new owner = entity_get_edict(dog, EV_ENT_owner)
new teeth = entity_get_int(dog,EV_INT_iuser4)


new numberOfweaponbox = find_sphere_class(dog, "weaponbox", RADWEAPBS, entityList, sizeof entityList)


if (numberOfweaponbox > 0 )
{
// Found that many weaponboxes near the dog

// If you need to get the closest one, sort the array
new data[1]
data[0] = dog
SortCustom1D(entityList, numberOfweaponbox, "SortByShortestDistance")

// Finally, get a single weaponbox to work with

// ���� weaponbox ����������, �� ��������� ����
if(is_valid_ent(entityList[0])) 
{
	iTar_fDog = entityList[0]
	
	emit_sound(iDog_id, CHAN_AUTO, g_jblong,1.0,ATTN_NORM,0,PITCH_NORM)
	
	///////////start pvs check
	static nextz, chainz
	static  classz [ 32 ]
	
	nextz = engfunc ( EngFunc_EntitiesInPVS, owner ) 
	while ( nextz ) 
	{ 
		// pev ( nextz, pev_classname, classz , charsmax ( class ) ) 
		chainz = pev ( nextz, pev_chain ) 
		
		// server_print ( "������ ������ � ������������� (%i) PVS: ent(%i) class(%s)" , dog, nextz, classz ) 
		
		if ( ! chainz ) 
			break
			
			nextz = chainz
		} 
	
	if(nextz = iTar_fDog) iTar_fDog = entityList[0]
	if(nextz != iTar_fDog) iTar_fDog = owner
		
	///////////edn pvs
	
	
	}
	//if(entityList[0] == teeth)
	//iTar_fDog = owner
	
	
}
}
public SortByShortestDistance(elem1, elem2, const array[], const data[], data_size)
{
new dog = data[0]

new distanceToFirstOne = get_entity_distance(dog,elem1)
new distanceToSecondOne = get_entity_distance(dog,elem2)


if (distanceToFirstOne < distanceToSecondOne)
{
	return -1
}

if (distanceToFirstOne > distanceToSecondOne)
{
	return 1
}

return 0
}



//////////////////////// JUST DEFAULT COPYPAST CODE FROM WEBSITE  ,,DOES NOT MATTER WHAT WROTE HERE>   NPCKilled //  GibsNPC 

public NPCKilled( iDog_id )
{
new iDog_id2 = create_entity("info_target") //������� ������, ��� ������

if(pev_valid( iDog_id2 )) //���������, ������ �� ������
{
	if(debugmessage) client_print(iTar_fDog, print_chat, "[DOG]Create Dead create") //���� ��, �����, ��� ������
	}else{
	client_print(iTar_fDog, print_chat, "[DOG]Error create") //����� �������
	return PLUGIN_HANDLED //���������� ���������� ���������� �������
}

new Float:fOrigin[3], Float:fAngles[3] //�������, ��� ����� ������ NPC

pev(iDog_id, pev_origin, fOrigin) //�������� ����������
pev(iDog_id, pev_angles, fAngles) //�������� ���� �������

entity_set_origin(iDog_id2, fOrigin) //�����������
entity_set_vector(iDog_id2, EV_VEC_angles, fAngles) //�����������

entity_set_model(iDog_id2, gModel) //������ ������

entity_set_size(iDog_id, Float:{-16.0, -16.0, -36.0}, Float:{16.0, 16.0, 36.0}) //������ �������( �� ������ � �������� ������ )

entity_set_int(iDog_id2, EV_INT_sequence, 108) //������ �������� ������
entity_set_float(iDog_id2, EV_FL_animtime, get_gametime()) //������ ����� ��������
entity_set_float(iDog_id2, EV_FL_framerate, 1.0) //������ �������� ��������
entity_set_float(iDog_id2, EV_FL_frame, 0.0) //������ ��������� ����

set_task(2.0, "GibsNPC", iDog_id2) //�������� �� ����� npc ����� 10 ��� � ��������� ���. 
return PLUGIN_HANDLED //�����
}

public GibsNPC( iDog_id )
{
new Float:fOrigin[3] //���� �������
pev(iDog_id, pev_origin, fOrigin) //�������� ����������

for(new i; i < sizeof gModelGibs; i++) //������������ �����
{
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_MODEL)
	engfunc(EngFunc_WriteCoord, fOrigin[0])
	engfunc(EngFunc_WriteCoord, fOrigin[1])
	engfunc(EngFunc_WriteCoord, fOrigin[2])
	write_coord(random_num(100, 400))
	write_coord(random_num(100, 400))
	write_coord(random_num(100, 400))
	write_angle(random( 361 ))
	write_short(gModelGibs[i])
	write_byte(1)
	write_byte(125)
	message_end()
}

//������� �����
message_begin(MSG_BROADCAST, SVC_TEMPENTITY) 
write_byte(TE_BLOODSPRITE)
engfunc(EngFunc_WriteCoord, fOrigin[0])
engfunc(EngFunc_WriteCoord, fOrigin[1])
engfunc(EngFunc_WriteCoord, fOrigin[2])
write_short(gSpriteBlood)
write_short(gSpriteBlood)
write_byte(250)
write_byte(20)
message_end()

remove_entity( iDog_id ) //���������� ��� �����
client_print(0, print_chat, "[NPC]Terminated") //������� ��������� ��� ��
} 
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1049\\ f0\\ fs16 \n\\ par }
*/
