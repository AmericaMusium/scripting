

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

new g_Cvar[5] //квары
new const gModel[] = "models/red/tnt_pes.mdl" //Модель NPC
new const gClassname[] = "jagendog" //Класснейм NPC

new const g_jblong[] = "weapons/red/jagenbarklong.wav"
new const g_jbshort[] = "weapons/red/jagenbarkshort.wav"
new const g_jbbree[] = "weapons/red/jagenbreethe.wav"


static flastDogOrigin[3]



//Флагменты костей(разрыв npc на части хД)
enum _:GIBS
{
HEAD,
LEG,
BONE,
LUNG,
GIB
}

new gModelGibs[GIBS] //Прекаши костей
new gSpriteBlood //прекаш спрайта

new iDog_id //Идентификатор созданного NPC
static iTar_fDog //Идентификатор игрока, который создал NPC

new Float:fNPCOrigin[3] //Координаты точки появление NPC

public plugin_init()
{
register_plugin(PLUGIN, VERSION, AUTHOR) //Ну думаю тут ясно

register_think(gClassname, "NPCThink") //Событие действий NPC

g_Cvar[1] = register_cvar("testnpc_health", "100") //жизни npc
g_Cvar[2] = register_cvar("testnpc_speed", "280") //Скорость noc
g_Cvar[3] = register_cvar("testnpc_distance", "98") //Минимальная дистанция при которой он побежит за вами





register_clcmd("say /npco", "NPCOrigin") //Команда создание координат появление
register_clcmd("say /npcc", "NPCCreate") //Команда непосредственного создания


}

public plugin_precache()
{
precache_model( gModel ) //Прекаш модели NPC
precache_sound(g_jblong)
precache_sound(g_jbshort)
precache_sound(g_jbbree)



//Костей
gModelGibs[HEAD] = precache_model("models/w_bar.mdl")
gModelGibs[LEG] = precache_model("models/w_fg42.mdl")
gModelGibs[BONE] = precache_model("models/w_colt.mdl")
gModelGibs[LUNG] = precache_model("models/w_garand.mdl")
gModelGibs[GIB] = precache_model("models/w_k43.mdl")

//Крови
gSpriteBlood = precache_model("sprites/blood-narrow.spr")

} 




public NPCOrigin(id)
{
entity_get_vector(id, EV_VEC_origin, fNPCOrigin) //Записываем координаты
client_print(id, print_chat, "[NPC]Origin create") //выводим сообщение
} 

public NPCCreate(id)
{   

iTar_fDog = id /// скоро удалю 

/*   ограничитель создания более 2х
if(iDog_id) //Если npc уже был создан
{
	remove_entity(iDog_id) //Убираем его
	iDog_id = 0 //Сбрасываем идентификатор
}
*/
iDog_id = create_entity("info_target") //Создаем объект

if(pev_valid( iDog_id )) //Проверяем, создан ли объект
{
	client_print(id, print_chat, "[NPC]Create") //Если да, пишем, что создан
	
	}else{
	client_print(id, print_chat, "[NPC]Error create") //Иначе выводим
	return PLUGIN_HANDLED //Прекращаем дальшейнее выполнение функции
}

entity_set_origin(iDog_id, fNPCOrigin) //Ставим на координаты, созданные нами ранее


entity_set_float(iDog_id, EV_FL_takedamage,1.0) //Делаем смертным

new Float:fHealth = float( get_pcvar_num( g_Cvar[1] )) //Получаем значение квара и конвертируем в дробное число
entity_set_float(iDog_id, EV_FL_health, fHealth) //Присваиваем количество жизней

entity_set_model(iDog_id, gModel) //Присваем модель
entity_set_string(iDog_id, EV_SZ_classname, gClassname) //Присваиваем класс


entity_set_edict(iDog_id, EV_ENT_owner, id) // задаём хозяина

entity_set_int(iDog_id, EV_INT_solid, SOLID_BBOX) //Делаем его материальным
entity_set_int(iDog_id, EV_INT_movetype, MOVETYPE_PUSHSTEP) //NPC может передвигаться по карте
entity_set_float(iDog_id, EV_FL_gravity, 1.2)
entity_set_size(iDog_id, Float:{-16.0, -16.0, -36.0}, Float:{16.0, 16.0, 16.0}) //Задаем размеры( не путать с размером модели )

entity_set_float(iDog_id, EV_FL_nextthink, halflife_time() + 0.3) //Заводим think

//Задаем свойства
set_pev(iDog_id, pev_enemy, 0)
entity_set_int(iDog_id, EV_INT_gamestate,1)

entity_set_int(iDog_id, EV_INT_sequence, 1) //Задаем начальную анимацию
entity_set_float(iDog_id, EV_FL_animtime, get_gametime()) //Задаем время анимации
entity_set_float(iDog_id, EV_FL_framerate,  1.0) //Задаем скорость анимации
entity_set_float(iDog_id, EV_FL_frame, 0.0) //Задаем начальный кадр

emit_sound(iDog_id, CHAN_ITEM,g_jbbree,0.2,ATTN_NORM,0,PITCH_NORM)
task_repeater( iDog_id )
RegisterHamFromEntity(Ham_Killed, iDog_id, "NPCKilled") //Задаем событие смерти

//////////////////////////////////////Создаем в руках оружие
// new iWeapon = create_entity("info_target")

//entity_set_int(iWeapon, EV_INT_solid, SOLID_NOT) //Не задаем никаких физичиских свойств
//entity_set_int(iWeapon, EV_INT_movetype, MOVETYPE_FOLLOW) //Задаем свойство следования объекта за игроком
//entity_set_edict(iWeapon, EV_ENT_aiment, iDog_id) //Непосредственно прикрепление объекта к NPC
//entity_set_model(iWeapon, "models/p_garand.mdl") //Задаем модель( можете хоть гранатомет ему давать )



return PLUGIN_HANDLED //конец
} 

public NPCThink( iDog_id )
{

if(!is_valid_ent( iDog_id )) //Если NPC не существует
	return FMRES_IGNORED //Прекращаем дальшейнее выполнение функции
	
	new owner = entity_get_edict(iDog_id, EV_ENT_owner)
	
	if( !is_valid_ent( iTar_fDog )) {
		
		iTar_fDog = owner
		// return FMRES_IGNORED
	}
	
	
	if(!is_user_alive( owner ) || !is_user_connected( owner ) ) //Если игрок мертв или отсоеденился
	{
		remove_entity( iDog_id ) //Убираем NPC
		iDog_id = 0 //Сбрасываем идентификатор
		
		return FMRES_IGNORED //Прекращаем дальшейнее выполнение функции
	}
	new Float:fNOrigin[3], Float:fPOrigin[3] //Сюда запишем координаты NPC и игрока
	new Float:fDistance //Сюда запишем расстяние между ними
	pev(iDog_id, pev_origin, fNOrigin) //Получаем координаты NPC
	// //Получаем координаты NPC - Защита от застревания
	
	pev(iTar_fDog, pev_origin, fPOrigin) //Получаем координаты игрока
	fDistance = get_distance_f(fNOrigin, fPOrigin) //Получаем дистанцию между ними
	
	if(fDistance <= float( get_pcvar_num( g_Cvar[3] ) )) //Если дистация межде указанной
	{	
		new classnametarget[32]
		new name[32]
		pev(iTar_fDog, pev_classname, classnametarget,31)
		// entity_get_edict(iDog_id, EV_ENT_owner)
		client_print(0, print_center, "[NPC] I CLOSE TO ENITTY %d %s", iTar_fDog, classnametarget  ) //Чисто для прикола выводим, что NPC догнал нас
		
		
		
		////////////////////// WEAPONBOX GET
		if(equal(classnametarget, "weaponbox")){
			
			// entity_set_int(iTar_fDog, EV_INT_solid, SOLID_NOT) //Не задаем никаких физичиских свойств	
			/// HERE WHEN DOG CONTACT CLOSSE TO /////////////////
			entity_set_int(iTar_fDog, EV_INT_movetype, MOVETYPE_FOLLOW) //Задаем свойство следования объекта за игроком
			entity_set_edict(iTar_fDog, EV_ENT_aiment, iDog_id) //Непосредственно прикрепление объекта к NPC
			entity_set_int(iDog_id, EV_INT_iuser4, iTar_fDog)
			
			iTar_fDog = owner
		}
		
		///////////////////// COME TO PAPA ///  УСЛОВИЕ АПОРТ 
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
					client_print(0, print_chat, "[DOG] PAPA TEETH: %d NO VALID", teeth)
					entity_set_int(iDog_id, EV_INT_iuser4, 0)
				}
				if(is_valid_ent( teeth )) {
					
					/////
					
				}
				
			}
			
			
			// client_print(0, print_chat, "[DOG] %s PAPA APORT Teeth: %d iDog_id %d dog %d ", name , teeth, iDog_id, iDog_id)
			if(weaponid == 19 && !teeth) {
				
				/// HERE WHEN DOG CONTACT CLOSSE TO
				
				client_print(0, print_chat, "[DOG] APORT TEETH: %d", teeth)
				find_numberOfweaponbox(iDog_id)
				
				
			}
			
		}
		
		/////////////////////////////////////////////////////////// ATTACK 
		
		if( iTar_fDog > 0 && iTar_fDog < 33 && iTar_fDog != owner) {
			
			// radius_damage(fNOrigin, 50, 50)
			
			get_user_name(iTar_fDog, name, 31)
			client_print(0, print_chat, "[DOG] %s under Attack", name)
			if(!is_user_alive(iTar_fDog) || !is_user_connected(iTar_fDog)) find_numberOfweaponbox(iDog_id)
		}
		
		
		
		if(pev(iDog_id, pev_sequence) != 1) //Если анимация npc установлена не стоячая
		{
			entity_set_int(iDog_id, EV_INT_sequence, 1) //Задаем анимацию бега
			entity_set_float(iDog_id, EV_FL_animtime, get_gametime()) //Задаем время анимации
			entity_set_float(iDog_id, EV_FL_framerate, 1.0) //Задаем скорость анимации
			entity_set_float(iDog_id, EV_FL_frame, 0.0) //Задаем начальный кадр
			
			
			emit_sound(iDog_id, CHAN_ITEM,g_jbbree,0.3,ATTN_NORM,0,PITCH_NORM)
		}
		}else{
		if(pev(iDog_id, pev_sequence) != 4) //Если анимация npc установлена не бега
		{
			entity_set_int(iDog_id, EV_INT_sequence, 4) //Задаем анимацию бега
			entity_set_float(iDog_id, EV_FL_animtime, get_gametime()) //Задаем время анимации
			entity_set_float(iDog_id, EV_FL_framerate, 1.0) //Задаем скорость анимации
			entity_set_float(iDog_id, EV_FL_frame, 0.0) //Задаем начальный кадр
			
			
			// emit_sound(iDog_id, CHAN_ITEM, g_jblong,1.0,ATTN_NORM,0,PITCH_NORM)
		}
		
		new Float:fAngles[3] //Сюда запишем координаты, куда должен будет смотреть NPC
		new Float:fVelocity[3] //Сюда запишем координаты, куда будет бежать NPC
		
		entity_get_vector(iDog_id, EV_VEC_angles, fAngles) //Получаем
		
		new Float:fX = fPOrigin[0] - fNOrigin[0] //Расчитываем координаты x
		new Float:fZ = fPOrigin[1] - fNOrigin[1] //Расчитываем координаты z
		
		new Float:fRadian
		fRadian = floatatan(fZ/fX, radian) //Получаем угол
		
		fAngles[1] = fRadian * (180 / 3.14) //Приваиваем координаты
		
		if(fPOrigin[0] < fNOrigin[0]) //Если координаты игрока относительно x меньше NPC`овскивх
		{
			fAngles[1] = fAngles[1] - 180.0 //Разворачиваем его
			}else{
			fAngles[1] = fRadian * (180 / 3.14) //Записываем координаты
		}
		
		new Float:fSpeed = fDistance / float( get_pcvar_num( g_Cvar[2] ) ) //Задаем скорость
		
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
		
		entity_set_vector(iDog_id, EV_VEC_angles, fAngles) //Присваиваем новые координаты куда смотреть
		entity_set_vector(iDog_id, EV_VEC_velocity, fVelocity) //Присваиваем новые координаты куда бежать
	}
	pev(iDog_id, pev_origin, flastDogOrigin)
	entity_set_float(iDog_id, EV_FL_nextthink, halflife_time() + 0.3) //Повторяем
	
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
		
		server_print ( "Найден объект в проигрывателе (%i) PVS: ent(%i) class(%s)" , dog, nextz, classz ) 
		
		if ( ! chainz ) 
			break
		
		nextz = chainz
	} 
}

*/
public task_repeater(iDog_id ){
	if(pev_valid( iDog_id )) //Проверяем, создан ли объект
	{
		find_numberOfplayers(iDog_id)
		client_print(0, print_chat, "SEARCH ENEMY TASK" )
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

// Если weaponbox существует, то назначить цель
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
		
		// server_print ( "Найден объект в проигрывателе (%i) PVS: ent(%i) class(%s)" , dog, nextz, classz ) 
		
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
new iDog_id2 = create_entity("info_target") //Создаем нового, тот пропал

if(pev_valid( iDog_id2 )) //Проверяем, создан ли объект
{
	client_print(iTar_fDog, print_chat, "[NPC]Create Dead create") //Если да, пишем, что создан
	}else{
	client_print(iTar_fDog, print_chat, "[NPC]Error create") //Иначе выводим
	return PLUGIN_HANDLED //Прекращаем дальшейнее выполнение функции
}

new Float:fOrigin[3], Float:fAngles[3] //Запишем, как стоял старый NPC

pev(iDog_id, pev_origin, fOrigin) //Получаем координаты
pev(iDog_id, pev_angles, fAngles) //Получаем куда смотрит

entity_set_origin(iDog_id2, fOrigin) //Присваиваем
entity_set_vector(iDog_id2, EV_VEC_angles, fAngles) //Присваиваем

entity_set_model(iDog_id2, gModel) //Задаем модель

entity_set_size(iDog_id, Float:{-16.0, -16.0, -36.0}, Float:{16.0, 16.0, 36.0}) //Задаем размеры( не путать с размером модели )

entity_set_int(iDog_id2, EV_INT_sequence, 108) //Задаем анимацию смерти
entity_set_float(iDog_id2, EV_FL_animtime, get_gametime()) //Задаем время анимации
entity_set_float(iDog_id2, EV_FL_framerate, 1.0) //Задаем скорость анимации
entity_set_float(iDog_id2, EV_FL_frame, 0.0) //Задаем начальный кадр

set_task(2.0, "GibsNPC", iDog_id2) //Разорвем на куски npc через 10 сек и уничтожим его. 
return PLUGIN_HANDLED //конец
}

public GibsNPC( iDog_id )
{
new Float:fOrigin[3] //Куда запишем
pev(iDog_id, pev_origin, fOrigin) //Получаем координаты

for(new i; i < sizeof gModelGibs; i++) //Разбрасываем кости
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

//Создаем кровь
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

remove_entity( iDog_id ) //Уничтожаем его нахер
client_print(0, print_chat, "[NPC]Terminated") //Выводим сообщение что ли
} 

//////////////////////////////////////// SEARCHING WALLS SYSTEM

public throw_something(id)
{
	new Float: Origin[3]
	
	pev(id, pev_origin , Origin)
	Origin[2] += 28

	new Float:fVelocity[3]
	
	new iEnt = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	
	if(!iEnt)
		return PLUGIN_HANDLED
	
	velocity_by_aim(id, 1000, fVelocity)
	set_pev(iEnt, pev_velocity, fVelocity)
	set_pev(iEnt, pev_classname, "iClassname")

	
	engfunc(EngFunc_SetSize, iEnt, Float:{-1.0, -7.0, -1.0}, Float:{1.0, 7.0, 1.0})
	engfunc(EngFunc_SetModel,iEnt, "iMdl.mdl")

	
	set_pev(iEnt, pev_origin, Origin)
	set_pev(iEnt, pev_solid, SOLID_TRIGGER)
	set_pev(iEnt, pev_movetype, MOVETYPE_TOSS)
	set_pev(iEnt, pev_owner, id)
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1049\\ f0\\ fs16 \n\\ par }
*/
