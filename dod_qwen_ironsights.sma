#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <engine>
#include <dodx>

// Настройки
#define FOV_ZOOM 60        // Угол обзора при прицеливании
#define FOV_NORMAL 90      // Обычный угол обзора
#define MODEL_ZOOMED "models/v_m1carbine_scoped.mdl"  // Модель с "прицельной" позицией (можно создать в Моделедите)

new bool:g_IsZoomed[33];          // Статус прицеливания
new g_LastFOV[33];                // Сохранённый FOV
new const g_Weapons[][] = { "weapon_m1carbine", "weapon_garand", "weapon_g43" };

public plugin_init() {
    register_plugin("Iron Sights", "1.0", "YourName");
    
    register_event("Button2", "OnButton2", "be", "1=1"); // ПКМ
    register_event("ResetMaxSpeed", "OnWeaponSwitch", "be"); // Смена оружия
    register_event("CurWeapon", "OnCurWeapon", "be");
}

// При нажатии ПКМ
public OnButton2(id) {
    client_print(0, print_chat, "MUSE PRESSED");

}
/*
    if (!is_user_alive(id)) return PLUGIN_CONTINUE;
    
    new weapon = get_user_weapon(id);
    if (!is_valid_weapon(weapon)) return PLUGIN_CONTINUE;
    
    if (g_IsZoomed[id]) {
        // Выход из прицеливания
        set_user_fov(id, FOV_NORMAL);
        g_IsZoomed[id] = false;
        set_pev(id, pev.viewmodel, get_default_v_model(weapon)); // Восстановить обычную модель
    } else {
        // Вход в прицеливание
        g_LastFOV[id] = get_user_fov(id);
        set_user_fov(id, FOV_ZOOM);
        g_IsZoomed[id] = true;
        new model = fm_model_index(MODEL_ZOOMED);
        set_pev(id, pev.viewmodel2, model); // Меняем v_model на "прицельную"
    }
    
    return PLUGIN_HANDLED;
}

// При смене оружия — сброс прицеливания
public OnWeaponSwitch(id) {
    if (g_IsZoomed[id]) {
        set_user_fov(id, FOV_NORMAL);
        g_IsZoomed[id] = false;
    }
}

// При смене оружия (CurWeapon) — тоже сброс
public OnCurWeapon(id) {
    new weapon = read_data(2);
    if (!is_valid_weapon(weapon)) {
        if (g_IsZoomed[id]) {
            set_user_fov(id, FOV_NORMAL);
            g_IsZoomed[id] = false;
        }
    }
}

// Проверка, поддерживает ли оружие прицеливание
is_valid_weapon(weapon) {
    for (new i = 0; i < sizeof(g_Weapons); i++) {
        if (get_pdata_cbase(id, 373, 5) == fm_find_ent_by_class(0, g_Weapons[i])) {
            return true;
        }
    }
    return false;
}

// Возвращает ID модели по оружию (упрощённо)
get_default_v_model(weapon) {
    switch (weapon) {
        case CSW_M1CARBINE: return fm_model_index("models/v_m1carbine.mdl");
        case CSW_GARAND:    return fm_model_index("models/v_garand.mdl");
        case CSW_G43:       return fm_model_index("models/v_g43.mdl");
        default:            return 0;
    }
}

public plugin_precache() {
    precache_model(MODEL_ZOOMED); // Твоя модифицированная модель
}
*/