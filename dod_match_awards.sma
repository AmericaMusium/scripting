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


new const g_clsname_ent[] = "awards_obj" 
new const g_awards_mdl[] = "models/null.mdl" //
/*

Сбор статистика в конце раунда


ЗДЕСЬ НУЖНО БУДЕТ СОЗДАТЬ ОБРАБОТЧИК ДАННЫХ.
Max kills
Max captures
Max longlifes
Max Spadekills
Max rocketkllls
Max greandeskills
ПОСЛЕ ОБРАБОТКИ ВЫВОД 
ЗВАНИЕ\ НИКНЕЙМ \ РЕЗУЛЬТАТ.

ВИЗУАЛЬНАЯ ЧАСТЬ


Техническая часть с блоками.

*/

new maxpls

public plugin_init()
{
	register_plugin("DOD Match Awards","0.0","America")
	server_print("DOD Match Awards") 
    
    register_clcmd("awa", "awards_spawn")
    /// round
    register_event("RoundState", "event_RoundStart", "a", "1=1")
    register_event("RoundState","event_End","a","1=3","1=4","1=5")


    maxpls = get_maxplayers();
}

public plugin_precache()
{
	precache_model( g_awards_mdl ) //

} 


public event_RoundStart() 
{
    /// When PLAYES UNLOCKED AND CAN MOOVE
    server_print("[DODNACTHAWARD]Sevent_RoundStart")
    client_print(0, print_chat, "[DODNACTHAWARDS]event_RoundStart")

}

public event_End() 
{   
    /// When all flags captured first moments
    server_print("[DODNACTHAWARDS]func_RoundState")
    client_print(0, print_chat, "[DODNACTHAWARDS]func_RoundState")
}








/*
camera entity
ground entity
*/

public event_Awards(id)
{

    new iOrigin[3] //    
    new iOrigin_aimhit[3] //  
    get_user_origin(id, iOrigin, 0) //    looks
    get_user_origin(id, iOrigin_aimhit, 3) // aim hit position

    iOrigin_aimhit[2]+=100 // поднять повыше
    
    
    new Float:fOrigin_aimhit[3] //   float 
    IVecFVec(iOrigin_aimhit, fOrigin_aimhit) //     

    //// CREATE ENITY 
    new id_satchel = create_entity("info_target")	
    set_pev(id_satchel, pev_classname, g_clsname_ent) 
    set_pev(id_satchel, pev_solid, SOLID_TRIGGER)   
    set_pev(id_satchel, pev_movetype, MOVETYPE_TOSS) 
    // Если нужно что бы разбивалось от пули , надо менять на 
    // SOLID_BBOX и менять точку старта, а то задевае игрока
    // set_pev(id_satchel, pev_health, 1.0);
    // set_pev(id_satchel, pev_takedamage, DAMAGE_YES);
    
    entity_set_edict(id_satchel, EV_ENT_owner, id)
    static Float:vVelocity[3]
    velocity_by_aim(id, 300, vVelocity)
    set_pev(id_satchel, pev_velocity, vVelocity)
    set_pev(id_satchel, pev_origin, fOrigin_aimhit)

    if(!pev_valid(id_satchel)) 
    {
        return PLUGIN_HANDLED  
    }


    // new message = pev(id_satchel, pev_owner)
    // client_print(0, print_chat,"SATHEL %d OWNER: %d", id_satchel, message)
    // set_pev(id_satchel, pev_nextthink, get_gametime() + 1.0) //  think
    // drop_to_floor(id_satchel)
    emit_sound(id,CHAN_VOICE,"weapons/bazookareloadgetrocket.wav",1.0,ATTN_NORM,0,PITCH_NORM) //  
    engfunc(EngFunc_SetModel, id_satchel, g_awards_mdl) // 
    engfunc(EngFunc_SetSize, id_satchel, Float:{-6.0, -6.0, 0.0}, Float:{6.0, 6.0, 72.0}) //   entity(      )



    // установить параметры одной модели игрока
    new seqnum = random_num(1,20)
    set_pev(id_satchel, pev_sequence, seqnum)

    client_print(0, print_chat, "%d" , seqnum)
    /*
    set_pev(iEntity, pev_controller_0, 125)
    set_pev(iEntity, pev_controller_1, 125)
    set_pev(iEntity, pev_controller_2, 125)


    engfunc(EngFunc_SetView, id, rocket)


    */

 
}

public award_scene()
{



}

public awards_spawn(id)
{

    /// создать камеру, которая летит от игрока к игроку или вокруг спауна, смотрит в лица 

    new Float:fNOrigin[3], Float:fPOrigin[3] 
    new iOrigin[3] //    
    new iOrigin_aimhit[3] //  
    get_user_origin(id, iOrigin, 0) //    looks
    get_user_origin(id, iOrigin_aimhit, 3) // aim hit position

    iOrigin_aimhit[2]+=100 // поднять повыше
    
    
    new Float:fOrigin_aimhit[3] //   float 
    IVecFVec(iOrigin_aimhit, fOrigin_aimhit) //     

    //// CREATE ENITY 
    new id_satchel = create_entity("info_target")	
    set_pev(id_satchel, pev_classname, g_clsname_ent) 
    set_pev(id_satchel, pev_solid, SOLID_TRIGGER)   

    set_pev(id_satchel, pev_movetype, MOVETYPE_PUSHSTEP) 
 
    // Если нужно что бы разбивалось от пули , надо менять на 
    // SOLID_BBOX и менять точку старта, а то задевае игрока
    // set_pev(id_satchel, pev_health, 1.0);
    // set_pev(id_satchel, pev_takedamage, DAMAGE_YES);
    
    entity_set_edict(id_satchel, EV_ENT_owner, id)
    static Float:vVelocity[3]
    velocity_by_aim(id, 300, vVelocity)
    set_pev(id_satchel, pev_velocity, vVelocity)
    set_pev(id_satchel, pev_origin, fOrigin_aimhit)

    if(!pev_valid(id_satchel)) 
    {
        return PLUGIN_HANDLED  
    }


    // new message = pev(id_satchel, pev_owner)
    // client_print(0, print_chat,"SATHEL %d OWNER: %d", id_satchel, message)
    // set_pev(id_satchel, pev_nextthink, get_gametime() + 1.0) //  think
    // drop_to_floor(id_satchel)
    emit_sound(id,CHAN_VOICE,"weapons/bazookareloadgetrocket.wav",1.0,ATTN_NORM,0,PITCH_NORM) //  
    engfunc(EngFunc_SetModel, id_satchel, g_awards_mdl) // 
    engfunc(EngFunc_SetSize, id_satchel, Float:{-6.0, -6.0, 0.0}, Float:{6.0, 6.0, 72.0}) //   entity(      )



    client_print(0, print_chat, "award spawn creted" )


    engfunc(EngFunc_SetView, id, id_satchel)
    
    /*
    
    message_begin(MSG_ONE, get_user_msgid("SetFOV"), {0,0,0}, id)
  	write_byte(110) //Zooming AUG/SIG style
 	message_end()
    */

    ///////// ориентация камеры

	pev(id_satchel, pev_origin, fNOrigin) //�������� ���������� NPC
	// //�������� ���������� NPC - ������ �� �����������
	
	pev(id, pev_origin, fPOrigin) 
    new Float:fAngles[3] //���� ������� ����������, ���� ������ ����� �������� NPC
	new Float:fVelocity[3] //���� ������� ����������, ���� ����� ������ NPC
		
    entity_get_vector(id_satchel, EV_VEC_angles, fAngles) //��������
    
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
    
    entity_set_vector(id_satchel, EV_VEC_angles, fAngles) //����������� ����� ���������� ���� ��������

}
















public awards_cams()
{

    
}