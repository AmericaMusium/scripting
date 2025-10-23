#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <fakemeta_util>
#include <dodx>
#include <dodfun>
#include <fun>
#include <engine>


// Linux extra offsets
#define linux_diff_weapon 4
#define linux_diff_player 5
#define linux_diff_animation 4


#define m_pActiveItem 278 // notused here but can.
#define m_pClientActiveItem 279
#define m_iWeaponState 115		// IS BAZOOKA/PIAT/PSCHREK Shouldered
#define m_iWeapons2 527


#define m_iFOV 365

public plugin_init() {
    register_plugin("FOV Fix", "1.0", "YourName");
    register_event("CurWeapon", "event_curweapon", "be", "1=1");
    // register_forward(FM_AddToFullPack, "fw_AddToFullPack", 1);
    
    register_message(get_user_msgid("HideWeapon"), "message_HideWeapon");

    register_impulse( 101, "BlockCommand" )
    register_impulse( 102, "BlockCommand" )
    register_impulse( 202, "BlockCommand" )

}

public event_curweapon(id) {
    if (!is_user_alive(id)) return;

    // Устанавливаем FOV (например, 90)
    set_pev(id, pev_fov, 90);

    // Проверяем, видна ли модель оружия
    check_vmodel_visibility(id);

        // Отображаем кастомный HUD-элемент

    set_pev(id, pev_effects, pev(id, pev_effects) & ~EF_NODRAW);
    new activeitem = get_pdata_cbase(id, 278, 5);
    set_pev(activeitem, pev_effects, pev(activeitem, pev_effects) & ~EF_NODRAW);
        new idx_wpn = get_pdata_cbase(id, m_pActiveItem, linux_diff_player);
    //ExecuteHam(Ham_DOD_Weapon_ZoomOut,idx_wpn); // правильно 
    ExecuteHam(Ham_DOD_Weapon_ZoomOut,idx_wpn); // правильно 

    new m_iObserverWeapon = get_pdata_int(id, 372, 5);
    server_print(" m_iObserverWeapon %d", m_iObserverWeapon);
    new m_iClientHideHUD = get_pdata_int(id, 1072/4, 5);
    server_print(" m_iClientHideHUD %d", m_iClientHideHUD);
    new m_iClientFOV = get_pdata_int(id, 1076/4, 5);
    server_print(" m_iClientFOV %d", m_iClientFOV);

    set_pdata_int( id , 1460/4, 60, 5);
    set_pdata_int( id , 1076/4, 60, 5);

    message_begin(MSG_ONE, get_user_msgid("SetFOV"), _, id);
	write_byte(60);
	message_end();


    new ptr_w = get_weapon_ptr_from_slot(id, 2);
    set_pdata_int( id , m_iWeapons2, ptr_w);



    /*
    message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("StatusIcon"), _, id);
    write_byte(1); // Включить иконку
    write_string("clip_colt_full"); // Название иконки
    write_byte(255); // Красный
    write_byte(255); // Зелёный
    write_byte(255); // Синий
    message_end();
    */
}

public override_hide_W(id)
{
    message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("HideWeapon"), _, id);
    write_byte(0); // Показываем HUD
    message_end();
}

public check_vmodel_visibility(id) {
    static Float:origin[3], Float:angles[3], Float:end[3];
    pev(id, pev_origin, origin);
    pev(id, pev_v_angle, angles);

    // Вычисляем конечную точку для трассировки
    angle_vector(angles, ANGLEVECTOR_FORWARD, end);
    xs_vec_mul_scalar(end, 100.0, end);
    xs_vec_add(origin, end, end);

    // Трассировка луча
    engfunc(EngFunc_TraceLine, origin, end, IGNORE_MONSTERS, id, 0);

    // Если луч не попал в препятствие, модель оружия должна быть видна
    if (get_tr2(0, TR_pHit) == 0) {
        // Делаем модель оружия видимой
        set_pev(id, pev_viewmodel2, "models/v_garand.mdl");
    } else {
        // Если луч попал в препятствие, скрываем модель
        set_pev(id, pev_viewmodel2, "models/v_garand.mdl");
    }
    client_cmd(id, "cl_minmodels 0");

}


public fw_AddToFullPack(es, e, ent, host, hostflags, player, pSet) {
    if (!player || host != ent) return FMRES_IGNORED;

    // Устанавливаем параметры камеры для отображения v_model
    set_es(es, ES_Origin, {0.0, 0.0, 0.0}); // Примерные координаты
    set_es(es, ES_Angles, {0.0, 0.0, 0.0}); // Примерные углы


    return FMRES_IGNORED;
}




public message_HideWeapon(msg_id, msg_dest, msg_entity) {
    // Получаем значение параметра (1 - скрыть, 0 - показать)
    new hide = get_msg_arg_int(1);

    server_print("OVERRRRRRRIDE HIDE");
    // Если оружие скрывается, принудительно показываем его
    if (hide == 1) {
        set_msg_arg_int(1, ARG_BYTE, 1); // Меняем значение на 0 (показать)
    }

    return PLUGIN_CONTINUE;
}


    

public BlockCommand(id){

    server_print("impulse cathc")
	return PLUGIN_HANDLED
}



public get_weapon_ptr_from_slot(idx_player, slot)
{
    if (slot < 0 || slot > 6) return -1; // Слоты от 0 до 6
    return get_pdata_cbase(idx_player, 272 + slot, linux_diff_player);
}
