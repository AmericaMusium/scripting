/**
 * DoD Weapon Modifier - AI Remastered Edition
 * ===========================================
 * 
 * Описание:
 * Продвинутая система модификации оружия для Day of Defeat, позволяющая
 * создавать кастомное оружие с уникальными характеристиками, звуками,
 * моделями и поведением. Система поддерживает различные типы оружия:
 * - Огнестрельное оружие (винтовки, пистолеты, пулеметы)
 * - Подствольные гранатометы
 * - Мортиры и ракетные установки
 * - Дымовые гранаты
 * - Снайперские винтовки с прицелом
 * 
 * Возможности:
 * - Динамическая загрузка конфигурации из INI файла
 * - Система хуков Ham_Sandwich для перехвата событий оружия
 * - Кастомные звуки и модели для каждого оружия
 * - Система HUD с отображением патронов и иконок
 * - Поддержка различных типов боеприпасов
 * - Система эффектов (взрывы, дым, искры)
 * - Меню выбора оружия
 * 
 * Автор: America (оригинал), AI Remaster (улучшенная версия)
 * Версия: 2.0 AI Remastered
 * Дата: 2025
 */

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <fakemeta_util>
#include <fakemeta_stocks>
#include <dodx>
#include <dodfun>
#include <fun>
#include <engine>

#pragma semicolon 1

// ============================================================================
// КОНСТАНТЫ И ОПРЕДЕЛЕНИЯ
// ============================================================================

// Размеры буферов
#define MAX_RESOURCE_PATH_LENGTH 64
#define MAX_NAME_LENGTH 32
#define LARGEST_BUFFER 1024
#define MAX_WEAPONS 64
#define MAX_PLAYERS 33

// Константы для спрея дробовика
#define SHTGN_SPRD 30.0

// Путь к конфигурационному файлу
#define CONFIG_FILE "addons/amxmodx/configs/w_weapons_ai.ini"

// Типы боеприпасов DoD
#define AMMO_SMG 1          // thompson, greasegun, sten, mp40
#define AMMO_ALTRIFLE 2     // carbine, k43, mg34
#define AMMO_RIFLE 3        // garand, enfield, scoped enfield, k98, scoped k98
#define AMMO_PISTOL 4       // colt, webley, luger
#define AMMO_SPRING 5       // springfield
#define AMMO_HEAVY 6        // bar, bren, stg44, fg42, scoped fg42
#define AMMO_MG42 7         // mg42
#define AMMO_30CAL 8        // 30cal
#define AMMO_GREN 9         // grenades (все 3 типа)
#define AMMO_ROCKET 13      // bazooka, piat, panzerschreck

// Константы оружия DoD
#define DODW_AMERKNIFE      1
#define DODW_GERKNIFE       2
#define DODW_COLT           3
#define DODW_LUGER          4
#define DODW_GARAND         5
#define DODW_SCOPED_KAR     6
#define DODW_THOMPSON       7
#define DODW_STG44          8
#define DODW_SPRINGFIELD    9
#define DODW_KAR            10
#define DODW_BAR            11
#define DODW_MP40           12
#define DODW_HANDGRENADE    13
#define DODW_STICKGRENADE   14
#define DODW_MG42           17
#define DODW_30_CAL         18
#define DODW_SPADE          19
#define DODW_M1_CARBINE     20
#define DODW_MG34           21
#define DODW_GREASEGUN      22
#define DODW_FG42           23
#define DODW_K43            24
#define DODW_ENFIELD        25
#define DODW_STEN           26
#define DODW_BREN           27
#define DODW_WEBLEY         28
#define DODW_BAZOOKA        29
#define DODW_PANZERSCHRECK  30
#define DODW_PIAT           31

// Типы кастомного оружия
#define WEAPON_TYPE_MELEE       1   // Холодное оружие
#define WEAPON_TYPE_PISTOL      2   // Пистолет
#define WEAPON_TYPE_RIFLE       3   // Винтовка
#define WEAPON_TYPE_SEMIAUTO    4   // Полуавтоматическая винтовка
#define WEAPON_TYPE_AUTOGUN     5   // Автомат
#define WEAPON_TYPE_SNIPER      6   // Снайперская винтовка
#define WEAPON_TYPE_MACHINEGUN  7   // Пулемет
#define WEAPON_TYPE_SHOTGUN     8   // Дробовик
#define WEAPON_TYPE_BAZOOKA     9   // Ракетная установка
#define WEAPON_TYPE_MORTAR      10  // Мортира
#define WEAPON_TYPE_GRENADE     11  // Граната
#define WEAPON_TYPE_MG          12  // Пулемет (альтернативный)
#define WEAPON_TYPE_SATCHEL     13  // Саперная сумка
#define WEAPON_TYPE_UNDERBARREL 14  // Подствольный гранатомет
#define WEAPON_TYPE_SMOKE       15  // Дымовая граната
#define WEAPON_TYPE_IRONSIGHT   16  // Винтовка с прицелом

// Смещения для Linux
#define LINUX_DIFF_WEAPON 4
#define LINUX_DIFF_PLAYER 5
#define LINUX_DIFF_ANIMATION 4

// Смещения DOD CBASE
#define m_flNextPrimaryAttack 103
#define m_flNextSecondaryAttack 104
#define m_flTimeWeaponIdle 105
#define m_flNextAttack 211
#define m_iClip 108
#define m_rgAmmo 281
#define m_iDefaultAmmo 112
#define m_iPrimaryAmmoType 106
#define m_pPlayer 89
#define m_knifeItem 272
#define m_pistolItem 273
#define m_rifleItem 274
#define m_nadeItem 276
#define m_flStartThrow 117
#define m_flReleaseThrow 118
#define m_flTimeToExplode 119
#define m_pActiveItem 278
#define m_rgpPlayerItems 81
#define m_fInReload 111
#define m_iWeaponState 115

#define BLOCKED_ATTACK_TIME 9999.0

// ============================================================================
// СТРУКТУРЫ ДАННЫХ
// ============================================================================

// Структура данных оружия
enum _:WEAPON_DATA
{
    // Основные параметры
    weapon_CustomCode,                    // Уникальный код оружия
    weapon_ReferenceName[MAX_NAME_LENGTH], // Имя базового оружия
    KickSlot,                            // Слот оружия
    weapon_customname[MAX_NAME_LENGTH],   // Кастомное имя оружия
    
    // Характеристики
    Float:f_dmgmlt,                      // Множитель урона
    Float:f_PrimaryFireRate,             // Скорострельность основной атаки
    Float:f_SecondaryFireRate,           // Скорострельность вторичной атаки
    Float:f_ReloadTime,                  // Время перезарядки
    
    // Боеприпасы
    max_clip,                            // Размер магазина
    max_ammo,                            // Максимальное количество патронов
    hud_clip_icon,                       // Иконка магазина в HUD
    hud_ammo_icon,                       // Иконка патронов в HUD
    
    // Звуки и модели
    s_fire1[MAX_RESOURCE_PATH_LENGTH],   // Звук основной атаки
    s_fire2[MAX_RESOURCE_PATH_LENGTH],   // Звук вторичной атаки
    v_model[MAX_RESOURCE_PATH_LENGTH],   // View модель
    p_model[MAX_RESOURCE_PATH_LENGTH],   // Player модель
    w_model[MAX_RESOURCE_PATH_LENGTH],   // World модель
    v_submdl,                            // Submodel view модели
    p_submdl,                            // Submodel player модели
    w_submdl,                            // Submodel world модели
    
    // Настройки поведения
    weapon_customtype,                   // Тип кастомного оружия
    is_reference_primaryattack_registered,   // Зарегистрирована ли основная атака
    is_reference_primaryattack_allowed,      // Разрешена ли основная атака
    is_reference_secondaryattack_registered, // Зарегистрирована ли вторичная атака
    is_reference_secondaryattack_allowed     // Разрешена ли вторичная атака
};

// ============================================================================
// ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ
// ============================================================================

// Массивы данных
new g_weapons[MAX_WEAPONS][WEAPON_DATA];
new g_uploaded_weapons;
new g_i_weapon[2048];
new bool:is_player_can_shoot[MAX_PLAYERS];
new bool:is_player_throw_smoke[MAX_PLAYERS];
new g_player_has_item[MAX_PLAYERS];

// Сообщения
new g_msgCurWeapon;
new g_msgAmmoX;
new g_maxpl;
new g_FriendlyFire;

// Настройки
new is_oldweapon_drop1_or_delete0;

// Спрайты
new g_SpriteKarGrenSmoke, g_SpriteSmokeGrenSmoke, g_SpriteExplode;

// Векторы
new Float:TumbleVector[3];

// ============================================================================
// ОСНОВНЫЕ ФУНКЦИИ ПЛАГИНА
// ============================================================================

/**
 * Инициализация плагина
 */
public plugin_init()
{
    // Регистрация плагина
    register_plugin("DoD Weapon Modifier AI Remastered", "2.0", "AI Remaster");
    
    // Инициализация переменных
    g_maxpl = get_maxplayers();
    g_FriendlyFire = get_cvar_num("mp_friendlyfire");
    is_oldweapon_drop1_or_delete0 = 1;
    
    // Регистрация команд
    register_clcmd("say", "CustomWeapon_Give");
    register_srvcmd("say", "CustomWeapon_Give");
    register_clcmd("say upd", "read_ini");
    register_clcmd("mm", "gun_menu_open");
    register_clcmd("weapons", "gun_menu_open");
    
    // Регистрация сообщений
    g_msgCurWeapon = get_user_msgid("CurWeapon");
    g_msgAmmoX = get_user_msgid("AmmoX");
    
    // Регистрация событий
    register_event("CurWeapon", "CurWeapon_Post", "be", "1=1");
    register_event("ReloadDone", "CurWeapon_Reload_Done", "be", "1=1");
    
    // Регистрация хуков
    RegisterHam(Ham_Spawn, "weaponbox", "Weaponbox_Spawn_Post", true);
    register_forward(FM_SetModel, "FakeMeta_SetModel", false);
    
    // Загрузка конфигурации
    upload_ini();
    
    // Установка состояния
    state WeaponBox_Disabled;
    
    // Логирование
    server_print("[WeaponMod AI] Плагин успешно инициализирован!");
    server_print("[WeaponMod AI] Загружено оружий: %d", g_uploaded_weapons);
}

/**
 * Предзагрузка ресурсов
 */
public plugin_precache()
{
    // Загрузка спрайтов
    g_SpriteKarGrenSmoke = precache_model("sprites/shot_smoke2.spr");
    g_SpriteSmokeGrenSmoke = precache_model("sprites/smoke_ia.spr");
    g_SpriteExplode = precache_model("sprites/f_explo.spr");
    
    // Загрузка дополнительных ресурсов
    precache_generic("decals.wad");
    
    server_print("[WeaponMod AI] Ресурсы предзагружены");
}

// ============================================================================
// СИСТЕМА КОНФИГУРАЦИИ
// ============================================================================

/**
 * Загрузка конфигурационного файла
 */
public upload_ini()
{
    if (!file_exists(CONFIG_FILE))
    {
        server_print("[WeaponMod AI] ОШИБКА: Файл конфигурации не найден: %s", CONFIG_FILE);
        return PLUGIN_HANDLED;
    }
    
    server_print("[WeaponMod AI] Загружаю конфигурацию из: %s", CONFIG_FILE);
    read_ini();
    return PLUGIN_CONTINUE;
}

/**
 * Чтение и парсинг INI файла
 */
public read_ini()
{
    new line_text[256], line_len, line_num;
    new file_lines = file_size(CONFIG_FILE, 1);
    
    g_uploaded_weapons = (file_lines - 1);
    
    for (line_num = 1; line_num < file_lines; line_num++)
    {
        new i = line_num;
        read_file(CONFIG_FILE, line_num, line_text, 255, line_len);
        
        // Парсинг параметров
        new temp_weapon_CustomCode[4],
            temp_ReferenceName[32],
            temp_KickSlot[4],
            temp_CustomWeaponClsName[32],
            temp_DamageMultiplyer[4],
            temp_PrimaryFireRate[8],
            temp_SecondaryFireRate[8],
            temp_ReloadTime[4],
            temp_MaxClip[4],
            temp_MaxAmmo[4],
            temp_HUDClip[4],
            temp_HUDAmmo[4],
            temp_SoundPrimaryAtt[64],
            temp_SoundSecondaryAtt[64],
            temp_v_model[64],
            temp_p_model[64],
            temp_w_model[64],
            temp_v_submodel[4],
            temp_p_submodel[4],
            temp_w_submodel[4],
            temp_weapon_customtype[4],
            temp_is_reference_primaryattack_registered[4],
            temp_is_reference_primaryattack_allowed[4],
            temp_is_reference_secondaryattack_registered[4],
            temp_is_reference_secondaryattack_allowed[3];
        
        // Парсинг строки
        new num = parse(line_text, temp_weapon_CustomCode, 3,
            temp_ReferenceName, 31, temp_KickSlot, 3, temp_CustomWeaponClsName, 31,
            temp_DamageMultiplyer, 7, temp_PrimaryFireRate, 7, temp_SecondaryFireRate, 7,
            temp_ReloadTime, 3, temp_MaxClip, 3, temp_MaxAmmo, 3,
            temp_HUDClip, 3, temp_HUDAmmo, 3, temp_SoundPrimaryAtt, 63, temp_SoundSecondaryAtt, 63,
            temp_v_model, 63, temp_p_model, 63, temp_w_model, 63,
            temp_v_submodel, 3, temp_p_submodel, 3, temp_w_submodel, 3,
            temp_weapon_customtype, 3, temp_is_reference_primaryattack_registered, 3, temp_is_reference_primaryattack_allowed, 3,
            temp_is_reference_secondaryattack_registered, 3, temp_is_reference_secondaryattack_allowed, 3);
        
        // Предзагрузка ресурсов
        precache_weapon_resources(temp_SoundPrimaryAtt, temp_SoundSecondaryAtt, temp_v_model, temp_p_model, temp_w_model);
        
        // Сохранение данных в массив
        save_weapon_data(i, temp_weapon_CustomCode, temp_ReferenceName, temp_KickSlot, temp_CustomWeaponClsName,
            temp_DamageMultiplyer, temp_PrimaryFireRate, temp_SecondaryFireRate, temp_ReloadTime,
            temp_MaxClip, temp_MaxAmmo, temp_HUDClip, temp_HUDAmmo, temp_SoundPrimaryAtt, temp_SoundSecondaryAtt,
            temp_v_model, temp_p_model, temp_w_model, temp_v_submodel, temp_p_submodel, temp_w_submodel,
            temp_weapon_customtype, temp_is_reference_primaryattack_registered, temp_is_reference_primaryattack_allowed,
            temp_is_reference_secondaryattack_registered, temp_is_reference_secondaryattack_allowed);
    }
    
    // Регистрация хуков для оружия
    Ham_RegisterWeaponForwards();
    
    server_print("[WeaponMod AI] Загружено оружий: %d", g_uploaded_weapons);
}

/**
 * Предзагрузка ресурсов оружия
 */
public precache_weapon_resources(const sound1[], const sound2[], const v_model[], const p_model[], const w_model[])
{
    new x[4];
    x = "";
    
    if (sound1[0] != x[0])
        engfunc(EngFunc_PrecacheSound, sound1);
    if (sound2[0] != x[0])
        engfunc(EngFunc_PrecacheSound, sound2);
    if (v_model[0] != x[0])
        engfunc(EngFunc_PrecacheModel, v_model);
    if (p_model[0] != x[0])
        engfunc(EngFunc_PrecacheModel, p_model);
    if (w_model[0] != x[0])
        engfunc(EngFunc_PrecacheModel, w_model);
}

/**
 * Сохранение данных оружия в массив
 */
public save_weapon_data(i, const custom_code[], const ref_name[], const kick_slot[], const custom_name[],
    const dmg_mult[], const fire1_rate[], const fire2_rate[], const reload_time[],
    const max_clip[], const max_ammo[], const hud_clip[], const hud_ammo[],
    const sound1[], const sound2[], const v_model[], const p_model[], const w_model[],
    const v_sub[], const p_sub[], const w_sub[], const weapon_type[],
    const prim_reg[], const prim_allow[], const sec_reg[], const sec_allow[])
{
    g_weapons[i][weapon_CustomCode] = str_to_num(custom_code);
    copy(g_weapons[i][weapon_ReferenceName], 31, ref_name);
    g_weapons[i][KickSlot] = str_to_num(kick_slot);
    copy(g_weapons[i][weapon_customname], 31, custom_name);
    g_weapons[i][f_dmgmlt] = str_to_float(dmg_mult);
    g_weapons[i][f_PrimaryFireRate] = str_to_float(fire1_rate);
    g_weapons[i][f_SecondaryFireRate] = str_to_float(fire2_rate);
    g_weapons[i][f_ReloadTime] = str_to_float(reload_time);
    g_weapons[i][max_clip] = str_to_num(max_clip);
    g_weapons[i][max_ammo] = str_to_num(max_ammo);
    g_weapons[i][hud_clip_icon] = str_to_num(hud_clip);
    g_weapons[i][hud_ammo_icon] = str_to_num(hud_ammo);
    copy(g_weapons[i][s_fire1], 63, sound1);
    copy(g_weapons[i][s_fire2], 63, sound2);
    copy(g_weapons[i][v_model], 63, v_model);
    copy(g_weapons[i][p_model], 63, p_model);
    copy(g_weapons[i][w_model], 63, w_model);
    g_weapons[i][v_submdl] = str_to_num(v_sub);
    g_weapons[i][p_submdl] = str_to_num(p_sub);
    g_weapons[i][w_submdl] = str_to_num(w_sub);
    g_weapons[i][weapon_customtype] = str_to_num(weapon_type);
    g_weapons[i][is_reference_primaryattack_registered] = str_to_num(prim_reg);
    g_weapons[i][is_reference_primaryattack_allowed] = str_to_num(prim_allow);
    g_weapons[i][is_reference_secondaryattack_registered] = str_to_num(sec_reg);
    g_weapons[i][is_reference_secondaryattack_allowed] = str_to_num(sec_allow);
}

// ============================================================================
// СИСТЕМА ХУКОВ HAM_SANDWICH
// ============================================================================

/**
 * Регистрация хуков для всех оружий
 */
public Ham_RegisterWeaponForwards()
{
    new registeredWeapons[33][32];
    new registeredWeaponsCount = 0;
    
    for (new i = 1; i <= g_uploaded_weapons; i++)
    {
        // Проверка на дублирование регистрации
        new bool:isRegistered = false;
        for (new j = 0; j < registeredWeaponsCount; j++)
        {
            if (strcmp(g_weapons[i][weapon_ReferenceName], registeredWeapons[j]) == 0)
            {
                isRegistered = true;
                break;
            }
        }
        
        if (!isRegistered)
        {
            // Регистрация хуков
            if (g_weapons[i][is_reference_primaryattack_registered])
            {
                RegisterHam(Ham_Weapon_PrimaryAttack, g_weapons[i][weapon_ReferenceName], "CurWeapon_PrimaryAttack_P", g_weapons[i][is_reference_primaryattack_allowed]);
            }
            
            if (g_weapons[i][is_reference_secondaryattack_registered])
            {
                RegisterHam(Ham_Weapon_SecondaryAttack, g_weapons[i][weapon_ReferenceName], "CurWeapon_SecondaryAttack_P", g_weapons[i][is_reference_secondaryattack_allowed]);
            }
            
            RegisterHam(Ham_Item_Deploy, g_weapons[i][weapon_ReferenceName], "HamHook_Item_Deploy_Post", true);
            
            // Добавление в список зарегистрированных
            copy(registeredWeapons[registeredWeaponsCount], 32, g_weapons[i][weapon_ReferenceName]);
            registeredWeaponsCount++;
        }
    }
    
    server_print("[WeaponMod AI] Зарегистрировано хуков для %d уникальных оружий", registeredWeaponsCount);
}

// ============================================================================
// СИСТЕМА ВЫДАЧИ ОРУЖИЯ
// ============================================================================

/**
 * Выдача кастомного оружия
 */
public CustomWeapon_Give(id_owner, msg[])
{
    new temp[64];
    read_args(temp, charsmax(temp));
    
    if (containi(msg, "weapon_") != -1)
    {
        for (new i = 0; i < 33; i++)
        {
            temp[i] = msg[i];
        }
    }
    
    if (containi(temp, "weapon_") != -1)
    {
        remove_quotes(temp);
        
        for (new i = 1; i <= g_uploaded_weapons; i++)
        {
            if (equal(temp, g_weapons[i][weapon_customname]))
            {
                give_custom_weapon(id_owner, i);
                return;
            }
        }
    }
    
    // Выдача стандартного оружия
    give_item(id_owner, temp);
}

/**
 * Выдача кастомного оружия игроку
 */
public give_custom_weapon(id_owner, weapon_index)
{
    if (!is_user_connected(id_owner) || !is_user_alive(id_owner))
        return;
    
    // Удаление текущего оружия
    new temp_cur_weapon_ent_id = get_pdata_cbase(id_owner, g_weapons[weapon_index][KickSlot]);
    if (temp_cur_weapon_ent_id != -1)
    {
        new temp_class_name[17];
        entity_get_string(temp_cur_weapon_ent_id, EV_SZ_classname, temp_class_name, 16);
        
        switch (is_oldweapon_drop1_or_delete0)
        {
            case 0:
            {
                if (!ExecuteHamB(Ham_RemovePlayerItem, id_owner, any:temp_cur_weapon_ent_id))
                    return;
                ExecuteHamB(Ham_Item_Kill, temp_cur_weapon_ent_id);
            }
            case 1:
            {
                engclient_cmd(id_owner, "drop", temp_class_name);
            }
        }
    }
    
    // Выдача нового оружия
    temp_cur_weapon_ent_id = give_item(id_owner, g_weapons[weapon_index][weapon_ReferenceName]);
    if (!is_valid_ent(temp_cur_weapon_ent_id))
        return;
    
    // Переключение на оружие
    engclient_cmd(id_owner, g_weapons[weapon_index][weapon_ReferenceName]);
    
    // Настройка оружия
    CustomWeapon_Retune(temp_cur_weapon_ent_id, weapon_index, id_owner);
}

/**
 * Настройка кастомного оружия
 */
public CustomWeapon_Retune(idx_wpn, i, id_owner)
{
    // Установка кастомного кода
    entity_set_int(idx_wpn, EV_INT_iuser4, i);
    g_i_weapon[idx_wpn] = i;
    
    // Установка патронов
    set_pdata_int(idx_wpn, m_iClip, g_weapons[i][max_clip], LINUX_DIFF_WEAPON);
    set_pdata_int(id_owner, m_rgAmmo + get_weapon_ammotype_by_ptr(idx_wpn), g_weapons[i][max_ammo], LINUX_DIFF_PLAYER);
    
    // Обновление HUD
    new clip, ammo, myWeapon = dod_get_user_weapon(id_owner, clip, ammo);
    Hud_Update_ammo(id_owner, ammo, i);
    
    // Установка моделей
    if (g_weapons[i][v_model][0])
        entity_set_string(id_owner, EV_SZ_viewmodel, g_weapons[i][v_model]);
    if (g_weapons[i][p_model][0])
        entity_set_string(id_owner, EV_SZ_weaponmodel, g_weapons[i][p_model]);
    
    // Дополнительная настройка
    CurWeapon_Refix_Properties(id_owner, idx_wpn);
}

// ============================================================================
// СИСТЕМА ОБРАБОТКИ СОБЫТИЙ
// ============================================================================

/**
 * Обработчик события CurWeapon
 */
public CurWeapon_Post(id_owner)
{
    if (!is_user_alive(id_owner))
        return;
    
    new idx_wpn = get_pdata_cbase(id_owner, m_pActiveItem, LINUX_DIFF_PLAYER);
    if (g_i_weapon[idx_wpn] != 0)
    {
        new ammo, clip;
        dod_get_user_weapon(id_owner, clip, ammo);
        
        if (clip < 1)
            is_player_can_shoot[id_owner] = false;
        else
            is_player_can_shoot[id_owner] = true;
        
        Hud_Update_ammo(id_owner, ammo, g_i_weapon[idx_wpn]);
        
        // Обработка специальных типов оружия
        switch (g_weapons[g_i_weapon[idx_wpn]][weapon_customtype])
        {
            case WEAPON_TYPE_SMOKE:
            {
                new GrenDODW_ID = read_data(2);
                if (GrenDODW_ID == DODW_STICKGRENADE)
                    is_player_throw_smoke[id_owner] = true;
            }
            default:
            {
                is_player_throw_smoke[id_owner] = false;
            }
        }
    }
}

/**
 * Обработчик деплоя оружия
 */
public HamHook_Item_Deploy_Post(idx_wpn)
{
    new i = entity_get_int(idx_wpn, EV_INT_iuser4);
    if (i < 1)
    {
        g_i_weapon[idx_wpn] = 0;
        return HAM_IGNORED;
    }
    
    new id_owner = get_pdata_cbase(idx_wpn, m_pPlayer, LINUX_DIFF_WEAPON);
    g_i_weapon[idx_wpn] = i;
    
    // Установка моделей
    if (g_weapons[i][v_model][0])
        entity_set_string(id_owner, EV_SZ_viewmodel, g_weapons[i][v_model]);
    if (g_weapons[i][p_model][0])
        entity_set_string(id_owner, EV_SZ_weaponmodel, g_weapons[i][p_model]);
    
    // Установка submodel
    if (g_weapons[i][v_submdl] > 0)
        pev(idx_wpn, pev_body, g_weapons[i][v_submdl]);
    
    return HAM_IGNORED;
}

// ============================================================================
// СИСТЕМА АТАК
// ============================================================================

/**
 * Обработчик основной атаки
 */
public CurWeapon_PrimaryAttack_P(idx_wpn)
{
    if (g_i_weapon[idx_wpn] != 0)
    {
        // Блокировка атаки если не разрешена
        if (g_weapons[g_i_weapon[idx_wpn]][is_reference_primaryattack_allowed] == 0)
        {
            set_pdata_float(idx_wpn, m_flNextPrimaryAttack, 999.0);
        }
        
        new i = g_i_weapon[idx_wpn];
        
        if (get_pdata_float(idx_wpn, m_flNextPrimaryAttack, LINUX_DIFF_WEAPON) < 0.0)
        {
            return HAM_SUPERCEDE;
        }
        else
        {
            set_pdata_float(idx_wpn, m_flNextPrimaryAttack, g_weapons[i][f_PrimaryFireRate]);
            new id_owner = get_pdata_cbase(idx_wpn, m_pPlayer, LINUX_DIFF_WEAPON);
            
            if (!is_player_can_shoot[id_owner])
                return HAM_SUPERCEDE;
            
            // Обработка специальных типов оружия
            if (g_weapons[i][weapon_customtype] > 0)
            {
                handle_special_weapon_attack(id_owner, idx_wpn, i, true);
            }
            
            // Воспроизведение звука
            if (g_weapons[i][s_fire1][0])
                emit_sound(id_owner, CHAN_AUTO, g_weapons[i][s_fire1], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
            
            return HAM_SUPERCEDE;
        }
    }
    return HAM_IGNORED;
}

/**
 * Обработчик вторичной атаки
 */
public CurWeapon_SecondaryAttack_P(idx_wpn)
{
    if (g_i_weapon[idx_wpn] != 0)
    {
        new Float:time = get_pdata_float(idx_wpn, m_flNextSecondaryAttack, LINUX_DIFF_WEAPON);
        new i = g_i_weapon[idx_wpn];
        
        if (time > 0.0)
        {
            return HAM_SUPERCEDE;
        }
        else
        {
            new id_owner = get_pdata_cbase(idx_wpn, m_pPlayer, LINUX_DIFF_WEAPON);
            if (is_player_can_shoot[id_owner] == false)
                return HAM_IGNORED;
            
            // Обработка специальных типов оружия
            if (g_weapons[i][weapon_customtype])
            {
                handle_special_weapon_attack(id_owner, idx_wpn, i, false);
            }
            
            // Воспроизведение звука
            if (g_weapons[i][s_fire2][0])
                emit_sound(id_owner, CHAN_AUTO, g_weapons[i][s_fire2], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
            
            return HAM_HANDLED;
        }
    }
    return HAM_IGNORED;
}

/**
 * Обработка специальных типов оружия
 */
public handle_special_weapon_attack(id_owner, idx_wpn, weapon_index, bool:is_primary)
{
    switch (g_weapons[weapon_index][weapon_customtype])
    {
        case WEAPON_TYPE_SHOTGUN:
        {
            if (is_primary)
                Shotgun_PrimaryAttack(id_owner, idx_wpn);
        }
        case WEAPON_TYPE_MORTAR:
        {
            if (is_primary)
                Mortar_PrimaryAttack(id_owner, idx_wpn);
        }
        case WEAPON_TYPE_UNDERBARREL:
        {
            if (is_primary)
            {
                set_pdata_int(idx_wpn, m_iClip, get_pdata_int(idx_wpn, m_iClip, LINUX_DIFF_WEAPON) - 1, LINUX_DIFF_WEAPON);
                UnderBarrelKar_Fire(id_owner, idx_wpn);
            }
        }
    }
}

// ============================================================================
// СИСТЕМА HUD
// ============================================================================

/**
 * Обновление HUD с патронами
 */
public Hud_Update_ammo(id, ammo, i)
{
    // Обновление иконки магазина
    message_begin(MSG_ONE, g_msgCurWeapon, {0, 0, 0}, id);
    write_byte(1);
    write_byte(g_weapons[i][hud_clip_icon]);
    write_byte(0);
    message_end();
    
    // Обновление количества патронов
    message_begin(MSG_ONE, g_msgAmmoX, {0, 0, 0}, id);
    write_byte(g_weapons[i][hud_clip_icon]);
    write_byte(ammo);
    message_end();
}

/**
 * Обработчик перезарядки
 */
public CurWeapon_Reload_Done(id_owner)
{
    if (!is_user_alive(id_owner))
        return;
    
    new idx_wpn = get_pdata_cbase(id_owner, m_pActiveItem, LINUX_DIFF_PLAYER);
    if (g_i_weapon[idx_wpn] != 0)
    {
        set_pdata_int(idx_wpn, m_iClip, g_weapons[g_i_weapon[idx_wpn]][max_clip], LINUX_DIFF_WEAPON);
    }
}

// ============================================================================
// СИСТЕМА МЕНЮ
// ============================================================================

/**
 * Открытие меню оружия
 */
public gun_menu_open(id)
{
    new menu = menu_create("\r[WeaponMod AI] Меню оружия", "gun_menu_press");
    
    for (new iItem = 1; iItem <= g_uploaded_weapons; iItem++)
    {
        new i = iItem;
        menu_additem(menu, g_weapons[i][weapon_customname], "", 0);
    }
    
    menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
    menu_display(id, menu, 0);
}

/**
 * Обработчик выбора в меню
 */
public gun_menu_press(id, menu, item)
{
    if (item >= 0 && item < g_uploaded_weapons)
    {
        new i = item + 1;
        CustomWeapon_Give(id, g_weapons[i][weapon_customname]);
        menu_destroy(menu);
        return;
    }
}

// ============================================================================
// СПЕЦИАЛЬНЫЕ ТИПЫ ОРУЖИЯ
// ============================================================================

/**
 * Атака дробовика
 */
public Shotgun_PrimaryAttack(id_owner, idx_weapon)
{
    new Float:vecPunchangle[3];
    vecPunchangle[0] += random_float(-0.3, 0.3);
    vecPunchangle[1] += random_float(-0.3, 0.3);
    set_pev(id_owner, pev_punchangle, vecPunchangle);
    
    new Float:f_origin[3];
    new Float:f_origin_traceto[3];
    new i_aim[3];
    new Float:f_aim[3];
    
    pev(id_owner, pev_origin, f_origin);
    f_origin[2] += 8.0;
    
    get_user_origin(id_owner, i_aim, 3);
    IVecFVec(i_aim, f_aim);
    
    // Выстрел несколькими пулями
    for (new i = 0; i < 6; i++)
    {
        f_origin_traceto[0] = float(i_aim[0]) + random_float(-SHTGN_SPRD, SHTGN_SPRD);
        f_origin_traceto[1] = float(i_aim[1]) + random_float(-SHTGN_SPRD, SHTGN_SPRD);
        f_origin_traceto[2] = float(i_aim[2]) + random_float(-SHTGN_SPRD, SHTGN_SPRD);
        
        new ttres = create_tr2();
        engfunc(EngFunc_TraceLine, f_origin, f_origin_traceto, DONT_IGNORE_MONSTERS, id_owner, ttres);
        get_tr2(ttres, TR_vecEndPos, f_origin_traceto);
        
        new Float:fraction;
        get_tr2(ttres, TR_flFraction, fraction);
        new hit = get_tr2(ttres, TR_pHit);
        
        if (hit > 0 && fraction != 1.0)
        {
            ExecuteHamB(Ham_TraceAttack, hit, id_owner, 50.0, f_origin_traceto, ttres, DMG_BULLET);
        }
        else
        {
            r_decal_index(ttres);
        }
        free_tr2(ttres);
    }
}

/**
 * Атака миномета
 */
public Mortar_PrimaryAttack(id_owner, idx_weapon)
{
    // Логика миномета
    return HAM_IGNORED;
}

/**
 * Подствольный гранатомет
 */
public UnderBarrelKar_Fire(idx_player, idx_weapon)
{
    Kargrenade_Create(idx_player, idx_weapon);
}

// ============================================================================
// СИСТЕМА ГРАНАТ
// ============================================================================

/**
 * Создание гранаты подствольника
 */
public Kargrenade_Create(idx_player, idx_weapon)
{
    if (!pev_valid(idx_player) && !pev_valid(idx_weapon))
        return HAM_SUPERCEDE;
    
    new iOrigin1[3];
    get_user_origin(idx_player, iOrigin1, 1);
    
    new Float:fOrigin[3];
    IVecFVec(iOrigin1, fOrigin);
    
    // Создание гранаты
    new idx_KarGrenade = create_entity("info_target");
    if (!pev_valid(idx_KarGrenade))
    {
        return PLUGIN_HANDLED;
    }
    
    set_pev(idx_KarGrenade, pev_classname, "grenade_kar");
    set_pev(idx_KarGrenade, pev_solid, SOLID_TRIGGER);
    set_pev(idx_KarGrenade, pev_movetype, MOVETYPE_TOSS);
    set_pev(idx_KarGrenade, pev_avelocity, TumbleVector);
    engfunc(EngFunc_SetModel, idx_KarGrenade, "models/w_grenade.mdl");
    engfunc(EngFunc_SetSize, idx_KarGrenade, Float:{-1.0, -1.0, 1.0}, Float:{1.0, 1.0, 1.0});
    entity_set_edict(idx_KarGrenade, EV_ENT_owner, idx_player);
    
    static Float:vVelocity[3];
    velocity_by_aim(idx_player, 1000, vVelocity);
    set_pev(idx_KarGrenade, pev_velocity, vVelocity);
    set_pev(idx_KarGrenade, pev_origin, fOrigin);
    
    TumbleVector[0] = random_float(-600.0, 600.0);
    TumbleVector[1] = random_float(-600.0, 600.0);
    TumbleVector[2] = random_float(-600.0, 600.0);
    
    // Эффект следа
    message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
    write_byte(TE_BEAMFOLLOW);
    write_short(idx_KarGrenade);
    write_short(g_SpriteKarGrenSmoke);
    write_byte(20);
    write_byte(2);
    write_byte(63);
    write_byte(63);
    write_byte(63);
    write_byte(100);
    message_end();
    
    set_task(random_float(0.9, 1.5), "Kargrenade_Explode", idx_KarGrenade);
    
    return HAM_SUPERCEDE;
}

/**
 * Взрыв гранаты подствольника
 */
public Kargrenade_Explode(idx_KarGrenade)
{
    if (!pev_valid(idx_KarGrenade))
        return PLUGIN_HANDLED;
    
    new idx_owner = entity_get_edict(idx_KarGrenade, EV_ENT_owner);
    new Float:fOrigin_KarGrenade[3];
    pev(idx_KarGrenade, pev_origin, fOrigin_KarGrenade);
    
    // Нанесение урона
    Kargrenade_DamageRadius(idx_KarGrenade, fOrigin_KarGrenade, idx_owner);
    
    // Эффекты взрыва
    create_explosion_effects(fOrigin_KarGrenade);
    
    remove_entity(idx_KarGrenade);
    return PLUGIN_C