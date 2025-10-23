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

#define MAX_RESOURCE_PATH_LENGTH 64    // Стандартный размер для путей к файлам
#define MAX_NAME_LENGTH 32             // Стандартный размер для имен
// #define MAX_STRING_LENGTH 16384          // Часто используемый размер для строк amxx const
#define LARGEST_BUFFER 1024           // Максимальный размер буфера
#define SHTGN_SPRD 30.0

/*
Создаётся многомерный массив, в который выгружаются настройки оружия иммитируя объекты класса
Через хамсэндвич активируется действия и перезаписываются параметры.

Precache: 
Надо сразу определиться что будет спрятано в p_model а что в v_ 
w_model =  вероятно что будет субмодельная или weaponbox 


Технолгия распознания будет через impulse specialcode
Для загрузки нужно определить файл конфигураии и количество переменных, записать и просомтреь процесс чтения. 

2. Создать отдельную фукнцию по регистрации ham_primary attack. что бы отключать форварды

// Ammo Channels
#define AMMO_SMG 1 		     // thomtemp_p_submodelon, greasegun, sten, mp40
#define AMMO_ALTRIFLE 2 	// carbine, k43, mg34
#define AMMO_RIFLE 3 		// garand, enfield, scoped enfield, k98, scoped k98
#define AMMO_PISTOL 4 		// colt, webley, luger
#define AMMO_SPRING 5 		// springfield
#define AMMO_HEAVY 6 		// bar, bren, stg44, fg42, scoped fg42
#define AMMO_MG42 7    		// mg42
#define AMMO_30CAL 8 		// 30cal
#define AMMO_GREN 9 		// grenades (should be all 3 types)
#define AMMO_ROCKET 13 		// bazooka, piat, panzerschreck

// DoD Weapon Constants
#define DODW_AMERKNIFE		1
#define DODW_GERKNIFE		2
#define DODW_COLT			3
#define DODW_LUGER			4
#define DODW_GARAND			5
#define DODW_SCOPED_KAR		6
#define DODW_THOMPSON		7
#define DODW_STG44			8
#define DODW_SPRINGFIELD	9
#define DODW_KAR			10
#define DODW_BAR			11
#define DODW_MP40			12
#define DODW_HANDGRENADE	13
#define DODW_STICKGRENADE	14
#define DODW_MG42			17
#define DODW_30_CAL			18
#define DODW_SPADE			19
#define DODW_M1_CARBINE		20
#define DODW_MG34			21
#define DODW_GREASEGUN		22
#define DODW_FG42			23
#define DODW_K43			24
#define DODW_ENFIELD		25
#define DODW_STEN			26
#define DODW_BREN			27
#define DODW_WEBLEY			28
#define DODW_BAZOOKA		29
#define DODW_PANZERSCHRECK	30
#define DODW_PIAT			31

hud_ammo_icon должно совпадать по категории с hud_clip_icon
если не будет совпдаать, то аммо не будет показывать,только покажет клип. 

отсталось :
разрешение на выброс 
HUD AMMO pb
субмодельный свитч - обязаетельно пора. 
mdl файл должен базироваться на референсном оружии для совпадения анимаций.

// Состояние плагина:
Мортира работает.
Маузер с подствольником работает. 

Есть вероятность что имеет смысл спрятать атаку огнестрелов на префрейм. что бы не обрабатывать случившееся событие. 
Тогда пропадёт оригинальный звук, и будет полная иммитация новых оружий, со спреем и всем постлежащим. 
Однако мортира тогда не сможет быть вызывана (возможно)
Не читает нормально фаеррейт . в чём-то ошибка. всегла 0,1 .после перезаписи фаеррайта вручную рабоает прекрасно
Исправлено: Регистрация повторных форвардов по Хамсэндвич
Что надо: 
Пересмотреть и обдумать перехват Аттаки, т.к. есть предварительные форварды, а есть пост-фоварды, возможно имеет смысл разделить.
На пример в МаузереСподствольником основная аттака совершенно не нужна.
В итоге: надо пересматривать файл конфигурации ini. и регистрировать хуки либо так, либо так
__________
Прорегестрированны хуки в правильно последовательности
Задача: Добавить Советское оружие. Проверить тщательно существующие, отбалансировать и составить список на новые. 
___ ___ 
Наконец-то поправлена перезапись количества АММО ссобой. технология получена. 
Задача: Добавить Советское оружие. Проверить тщательно существующие, отбалансировать и составить список на новые. (х2)
Добавить ПТРС или ПТРД , поправить звуки. Отрегулирвоать анимации. 
+++ Долать отлов мортиры. её ракеты с интекдсом владельца +++
Доделать КЛИП с обновленим от аммо
___
Сделать ПТРД , на основе mg34\30cal или выбрать по иконке, снабдить 1 патроном, и через сэт таск выствить условия. 
Сюда же воткнуть противометхотные мины и сюда фоткнуть дымовые гранаты. 
_-----
передалать smoke, добавить звук и взрыв смока. выполнгить проверку на присутсвие оружия 

03.03.2025 Ахуеть летит время. 
Короче есть вариант заблокировать **.qc оружия, что бы точно не вызывать звуки выстрелов ни на сервере, ни на клиенте , и на базе этого оружия уже делать своё кастомное
предлагаю сделать на базе ножа и его перемещать в слоты, однако не красиво будет по HUD switch.  Зато полная эмуляция. 
За исключением p_models_anim  , к сожалению в этим проблемы всегда. Можно пробовать писать стокки для решения проблемы анимации.

29-09-2025 =))) заглянул утащить технологии на куриную базуку
*/

#define w_config "addons/amxmodx/configs/w_weapons.ini"

// создаём массив для данных иммитирум создание класса 
#define MAX_CWEAPONS 32

enum _:W_DATA
{
    weapon_CustomCode, // 104 , 25677, 84 any unic numberfor custom weapon
    weapon_ReferenceName[32], // weapon_spade
    KickSlot, // 1 == knife 3== rifle
    weapon_customname[32], // weapon_katana
    Float:f_dmgmlt,  	// FLOAT DAMAGE MULTIPLIER
    Float:f_PrimaryFireRate,
    Float:f_SecondaryFireRate,   	// shooting speed per
    Float:f_ReloadTime, // reloadtime
    max_clip,   
    max_ammo,
    hud_clip_icon,
    hud_ammo_icon,
    s_fire1[64],
    s_fire2[64],
    v_model[64],
    p_model[64],
    w_model[64],
    v_submdl,
    p_submdl,
    w_submdl,
    weapon_customtype,
    is_reference_primaryattack_registered,
    is_reference_primaryattack_allowed,
    is_reference_secondaryattack_registered,
    is_reference_secondaryattack_allowed
};

new g_weapons[MAX_CWEAPONS][W_DATA];
new g_uploaded_weapons;
new g_i_weapon[1366];
new bool: is_player_can_shoot[33];
new bool: is_player_throw_smoke[33];
new g_player_has_item[33];


/// переопределяем смещения 
// Linux extra offsets
#define linux_diff_weapon 4
#define linux_diff_player 5
#define linux_diff_animation 4
// DOD CBASE offsets 
#define m_flNextPrimaryAttack 103 	// float
#define m_flNextSecondaryAttack 104 // float
#define m_flTimeWeaponIdle 105 	// float	
#define m_flNextAttack 211 // float

#define m_iClip 108  			// Item return m_iClip from ptr idx_weapon
#define m_rgAmmo 281            // Используется оффсет + к нему оффстер +AMMO_TYPE // new byammp = get_pdata_int(id_owner, m_rgAmmo + AMMO_TYPE, linux_diff_player);
#define m_iDefaultAmmo 112  	// int- не работает
#define m_iPrimaryAmmoType 106  // Item return AMMO_TYPE from ptr idx_weapon
#define m_pPlayer 89 			// int returns owner's of weapon

#define m_knifeItem 272			// ptr ножа 
#define m_pistolItem 273        //  ptr secondary pistol в инвентаре
#define m_rifleItem 274         // ptr primary в инвентаре
#define m_nadeItem 276          // ptr гранаты

#define m_flStartThrow 117      // if == 1.0   attack pressed сила замаха, от 0.0до 1.0 
#define m_flReleaseThrow 118 
#define m_flTimeToExplode 119 // explossion in gametime format of weapon_nade_ex (when acitive nade picket up after throw)

#define m_pActiveItem 278 		// возвращает Entity idx оружия в руках (не константу) + linux_diff_player
#define m_rgpPlayerItems 81		// Weaponbox ячейки
#define m_fInReload	111         //  Integer 
#define m_iWeaponState 115		// IS BAZOOKA/PIAT/temp_p_submodelCHREK Shouldered

#define BLOCKED_ATTACK_TIME 9999.0

// Register messages 
new Float:TumbleVector[3];
new g_msgCurWeapon;
new g_msgAmmoX; 
new g_maxpl;
new g_FriendlyFire;
new is_oldweapon_drop1_or_delete0;
new g_SpriteKarGrenSmoke, g_SpriteSmokeGrenSmoke, g_SpriteExplode;

public plugin_init()
{   
    upload_ini();
    // set_task(1.0, "upload_ini");
    register_plugin("DOD Wmod ini","0.1b","America");
    // server_print("DOD Wmod ini") ;   

    g_maxpl = get_maxplayers();
    g_FriendlyFire = get_cvar_num ( "mp_friendlyfire");
    register_clcmd("say", "CustomWeapon_Give");
    register_srvcmd("say","CustomWeapon_Give");
    register_clcmd("say upd", "read_ini");
    register_clcmd("mm","gun_menu_open");


    // User Messages for Hud_Update_Ammo
    g_msgCurWeapon = get_user_msgid("CurWeapon");
    g_msgAmmoX = get_user_msgid("AmmoX");

    // Register Event / Signals
    register_event("CurWeapon", "CurWeapon_Post", "be", "1=1");
    register_event("ReloadDone", "CurWeapon_Reload_Done", "be", "1=1");
    RegisterHam(Ham_Spawn, "weaponbox", "Weaponbox_Spawn_Post", true);
    register_forward(FM_SetModel, "FakeMeta_SetModel", false);
    state WeaponBox_Disabled;

    // register_forward(FM_EmitSound, "fw_EmitSound")
    // register_think("shell_temp_p_submodelchreck", "shell_temp_p_submodelchreck_think")

    /// Automatic gunmenu
    // server_print("Friednly fire is %d", g_FriendlyFire );
    is_oldweapon_drop1_or_delete0 = 1;
}

// Precache required files
public plugin_precache()
{
    // upload_ini();
    g_SpriteKarGrenSmoke = precache_model("sprites/shot_smoke2.spr");
    g_SpriteSmokeGrenSmoke = precache_model("sprites/smoke_ia.spr");
    precache_generic("decals.wad");
    g_SpriteExplode = precache_model("sprites/f_explo.spr");
}

public upload_ini()
    {
    // server_print("[WMOD] upload ini start");
    if (!file_exists(w_config))
    {
        server_print("[WMOD] ERROR FILE NOT EXIST: %s", w_config);
        
        return PLUGIN_HANDLED;
    }
    if (file_exists(w_config)) 
    {
        server_print("[WMOD] file exists = %s", w_config);
        read_ini();
        return PLUGIN_CONTINUE;
    }
    // server_print("[WMOD] upload ini end");
    return PLUGIN_HANDLED;
}

public read_ini()
{
    new line_text[256], line_len, line_num;
    new file_lines = file_size(w_config, 1);

    // server_print("[WMOD] file_lines = %d", file_lines);
    g_uploaded_weapons = (file_lines - 1);
    for (line_num = 1; line_num < file_lines ; line_num++) 
    {	
        new i = line_num;
        read_file(w_config, line_num, line_text, 255, line_len);
        // server_print(line_text);
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

        // Parsing Arguments from line to char-arrays
        new num = parse(line_text, temp_weapon_CustomCode, 3, 
        temp_ReferenceName, 31, temp_KickSlot, 3, temp_CustomWeaponClsName, 31,
        temp_DamageMultiplyer, 7, temp_PrimaryFireRate, 7, temp_SecondaryFireRate, 7,
        temp_ReloadTime, 3,  temp_MaxClip, 3, temp_MaxAmmo, 3,
        temp_HUDClip, 3, temp_HUDAmmo, 3, temp_SoundPrimaryAtt, 63, temp_SoundSecondaryAtt, 63,
        temp_v_model, 63, temp_p_model, 63, temp_w_model, 63,
        temp_v_submodel, 3, temp_p_submodel,3, temp_w_submodel,3, 
        temp_weapon_customtype, 3, temp_is_reference_primaryattack_registered, 3, temp_is_reference_primaryattack_allowed, 3,
        temp_is_reference_secondaryattack_registered, 3, temp_is_reference_secondaryattack_allowed, 3);

        // Кеширование моделей и звуков
        new x[4];
        x = "";
        if(temp_SoundPrimaryAtt[0]!=x[0])
            engfunc(EngFunc_PrecacheSound, temp_SoundPrimaryAtt);
        if(temp_SoundSecondaryAtt[0]!=x[0])
            engfunc(EngFunc_PrecacheSound, temp_SoundSecondaryAtt);
        if(temp_v_model[0]!=x[0])
            engfunc(EngFunc_PrecacheModel, temp_v_model);
        if(temp_p_model[0]!=x[0])
            engfunc(EngFunc_PrecacheModel, temp_p_model);
        if(temp_w_model[0]!=x[0])
            engfunc(EngFunc_PrecacheModel, temp_w_model);


        // Копирование преобразованных данных в массив оперативной памяти сервера
        g_weapons[i][weapon_CustomCode] = str_to_num(temp_weapon_CustomCode);
        g_weapons[i][weapon_ReferenceName] = temp_ReferenceName;
        g_weapons[i][KickSlot] = str_to_num(temp_KickSlot);
        g_weapons[i][weapon_customname] = temp_CustomWeaponClsName;
        g_weapons[i][f_dmgmlt] = str_to_float(temp_DamageMultiplyer);
        g_weapons[i][f_PrimaryFireRate] = str_to_float(temp_PrimaryFireRate);
        g_weapons[i][f_SecondaryFireRate] = str_to_float(temp_SecondaryFireRate);
        g_weapons[i][f_ReloadTime] = str_to_float(temp_ReloadTime);
        g_weapons[i][max_clip] = str_to_num(temp_MaxClip);
        g_weapons[i][max_ammo] = str_to_num(temp_MaxAmmo);
        g_weapons[i][hud_clip_icon] = str_to_num(temp_HUDClip);
        g_weapons[i][hud_ammo_icon] = str_to_num(temp_HUDAmmo);
        g_weapons[i][s_fire1] = temp_SoundPrimaryAtt;
        g_weapons[i][s_fire2] = temp_SoundSecondaryAtt;
        g_weapons[i][v_model] = temp_v_model;
        g_weapons[i][p_model] = temp_p_model;
        g_weapons[i][w_model] = temp_w_model;
        g_weapons[i][v_submdl] = str_to_num(temp_v_submodel);
        g_weapons[i][p_submdl] = str_to_num(temp_p_submodel);
        g_weapons[i][w_submdl] = str_to_num(temp_w_submodel);
        g_weapons[i][weapon_customtype] = str_to_num(temp_weapon_customtype);
        g_weapons[i][is_reference_primaryattack_registered] = str_to_num(temp_is_reference_primaryattack_registered);
        g_weapons[i][is_reference_primaryattack_allowed] = str_to_num(temp_is_reference_primaryattack_allowed);
        g_weapons[i][is_reference_secondaryattack_registered] = str_to_num(temp_is_reference_secondaryattack_registered);
        g_weapons[i][is_reference_secondaryattack_allowed] = str_to_num(temp_is_reference_secondaryattack_allowed);
        
        // server_print("[WMOD] loading complete for %s  ", g_weapons[i][weapon_customname]);
        num++; //WARNING [237]: symbol is assigned a value that is never used: "num" == nums of parsed arguments
    }
    Ham_RegisterWeaponForwards();
    // server_print("[WMOD] TOTAL WEAPONS: %d", g_uploaded_weapons);
}
/*
public Ham_RegisterWeaponForwards()
{
    new i;
    for( i = 1; i <= g_uploaded_weapons; i++)
    {
        server_print("[WMOD] Ham_RegisterWeaponForwards %s", g_weapons[i][weapon_ReferenceName]);
        RegisterHam(Ham_Weapon_PrimaryAttack,	g_weapons[i][weapon_ReferenceName],	"CurWeapon_PrimaryAttack_P", true);  
        RegisterHam(Ham_Weapon_SecondaryAttack,	g_weapons[i][weapon_ReferenceName],	"CurWeapon_SecondaryAttack_P", false);  
        RegisterHam(Ham_Item_Deploy,		g_weapons[i][weapon_ReferenceName], 	"HamHook_Item_Deploy_Post",	true);
        RegisterHam(Ham_DOD_Item_CanDrop, g_weapons[i][weapon_ReferenceName], "WeaponBox_Drop_P");
    }
}
*/
public Ham_RegisterWeaponForwards()
{
    new i;
    new registeredWeapons[33][32]; // Массив для отслеживания зарегистрированных оружий
    new registeredWeaponsCount = 0;


    // Регистрация Предварительной Аттаки
    for (i = 1; i <= g_uploaded_weapons; i++)
    {
        // Проверяем, было ли уже зарегистрировано это оружие
        new bool:isRegistered = false;
        for (new j = 0; j < registeredWeaponsCount; j++)
        {
            if (strcmp(g_weapons[i][weapon_ReferenceName], registeredWeapons[j]) == 0)
            {
                isRegistered = true;
                break;
            }
        }

        // Если оружие не зарегистрировано, регистрируем его и добавляем в список зарегистрированных
        if (!isRegistered)
        {
            // server_print("[WMOD] Ham_RegisterWeaponForwards %s", g_weapons[i][weapon_ReferenceName]);
            if(g_weapons[i][is_reference_primaryattack_registered])
            {
                RegisterHam(Ham_Weapon_PrimaryAttack,       g_weapons[i][weapon_ReferenceName],      "CurWeapon_PrimaryAttack_P", g_weapons[i][is_reference_primaryattack_allowed]); //PostAllowed=1 разрешает атаку стандартную, если ноль, то просто вызывается на клиенте звуки и прочее
                //server_print("[WMOD] Ham_Weapon_PrimaryAttack %s is_allowed== %d ", g_weapons[i][weapon_ReferenceName], g_weapons[i][is_reference_primaryattack_allowed]);
            }
            if(g_weapons[i][is_reference_secondaryattack_registered])
            {
                RegisterHam(Ham_Weapon_SecondaryAttack,     g_weapons[i][weapon_ReferenceName],      "CurWeapon_SecondaryAttack_P", g_weapons[i][is_reference_secondaryattack_allowed]);  
                //server_print("[WMOD] Ham_Weapon_SecondaryAttack %s is_allowed== %d ", g_weapons[i][weapon_ReferenceName], g_weapons[i][is_reference_secondaryattack_allowed]);
            }
            RegisterHam(Ham_Item_Deploy,        g_weapons[i][weapon_ReferenceName], "HamHook_Item_Deploy_Post", true);
            // RegisterHam(Ham_DOD_Item_CanDrop,   g_weapons[i][weapon_ReferenceName], "WeaponBox_Drop_P");
            // RegisterHam(Ham_Item_Holster, g_weapons[i][weapon_ReferenceName], "Item_Holster_Post", true);

            // Добавляем оружие в список зарегистрированных
            copy(registeredWeapons[registeredWeaponsCount], 32, g_weapons[i][weapon_ReferenceName]);
            registeredWeaponsCount++;
        }
    }
}

public WeaponBox_Drop_P(id)
{
    // Запутить проверку на разрешение выброса  оружия
    if(is_valid_ent(id))
    {
        SetHamReturnInteger(1);
        return HAM_SUPERCEDE;
    }
    return HAM_IGNORED;
}



public CustomWeapon_Give(id_owner,msg[])
{   
    new temp[64];
    read_args(temp, charsmax(temp));
    
    if (containi(msg, "weapon_") != -1)
    {
        new i ;
        for(i=0; i<33; i++)
        {
            temp[i]=msg[i];
        }
    }
    
    if (containi(temp, "weapon_") != -1)
    {   
        remove_quotes(temp);
        new i;
        for(i=1; i <= g_uploaded_weapons; i++)
        {
            new ii = i;
            if(equal(temp,g_weapons[ii][weapon_customname]))
            {
                /// выдать оружие 
                if (!is_user_connected(id_owner) || !is_user_alive(id_owner)) return;
                // Get weapon entity ID of client's primary weapon - returns -1 on none

                new temp_cur_weapon_ent_id = get_pdata_cbase(id_owner, g_weapons[ii][KickSlot]); // to frop pistol use m_pistolItem
                if (temp_cur_weapon_ent_id != -1)
                {
                    new temp_class_name[17];
                    entity_get_string(temp_cur_weapon_ent_id ,EV_SZ_classname,temp_class_name, 16);
                    // 
                    /////
                    switch (is_oldweapon_drop1_or_delete0)
                    {
                        case 0:
                        {
                            if(!ExecuteHamB(Ham_RemovePlayerItem,id_owner, any:temp_cur_weapon_ent_id)) return;
                            ExecuteHamB(Ham_Item_Kill,temp_cur_weapon_ent_id);
                        }
                        case 1: engclient_cmd(id_owner,"drop",temp_class_name); // это старый метод просто выбросить на землю
                    }
                }
                temp_cur_weapon_ent_id = give_item(id_owner, g_weapons[ii][weapon_ReferenceName]);
                if(!is_valid_ent(temp_cur_weapon_ent_id)) return;
                // //debug client_print(0, print_chat, "Player: %d , id=gived: %d", id_owner, temp_cur_weapon_ent_id)
                // to switch in arm:
                engclient_cmd(id_owner, g_weapons[ii][weapon_ReferenceName]);
                CustomWeapon_Retune(temp_cur_weapon_ent_id, ii, id_owner);
                return;
            }
        }
    }
    // Разрешил выдвать стандртное оружие по запросу.
    give_item(id_owner, temp);
    return;
}
////////////////// Retune Weapon Set Custom Code to Impulse
public CustomWeapon_Retune(idx_wpn, i, id_owner)
{
    // получить entity id текущего оружия
    // idx_wpn = get_pdata_cbase(id_owner, m_pActiveItem, linux_diff_player);
    /// назначит оружие специальный код
    entity_set_int(idx_wpn, EV_INT_iuser4, i);
    g_i_weapon[idx_wpn] = i;

    // устнаовить количество патронов
    set_pdata_int(idx_wpn, m_iClip,  g_weapons[i][max_clip], linux_diff_weapon);
    // ammo icon == get_weapon_ammotype_by_ptr(idx_wpn)
    // есть возможность взять AMMO_TYPE у ptr 
    // set_pdata_int(id_owner, m_rgAmmo + g_weapons[i][hud_ammo_icon],  g_weapons[i][max_ammo], linux_diff_player);
    set_pdata_int(id_owner, m_rgAmmo + get_weapon_ammotype_by_ptr(idx_wpn),  g_weapons[i][max_ammo], linux_diff_player);

    // обновить HUD
    new clip, ammo, myWeapon = dod_get_user_weapon(id_owner, clip, ammo);
    Hud_Update_ammo(id_owner, ammo, i);
    if(g_weapons[i][v_model])
        entity_set_string(id_owner, EV_SZ_viewmodel, g_weapons[i][v_model]);
    if(g_weapons[i][p_model])
        entity_set_string(id_owner, EV_SZ_weaponmodel,g_weapons[i][p_model]);
    CurWeapon_Refix_Properties(id_owner, idx_wpn);
    myWeapon++; // symbol is assigned a value that is never used: "myWeapon"
    //debug client_print(id_owner, print_chat, "Player: %d , WeaponID: %d , retuned to CUSTOM", id_owner, idx_wpn);
}
public CurWeapon_Refix_Properties(id_owner, idx_wpn)
{
    // Перезаписывает доп свойства, для контроля над оружием, на пример блокировка другой атаки без лишней регистрации форвардов
    switch(g_weapons[entity_get_int(idx_wpn, EV_INT_iuser4)][weapon_customtype])
    {
        case 15: 
        {   
            // Смещаем дымовую гранату в другой слот
            message_begin( MSG_ONE, get_user_msgid( "WeaponList" ), {0,0,0}, id_owner );
            write_byte( AMMO_GREN ); // Ammo 3 Type 
            write_byte( 2 ); // Ammo 1 Max
            write_byte( -1 ); // Ammo 2 Type
            write_byte( -1 ); // Ammo 2 Max
            write_byte( 3); // Slot (Starts at 0) НОМЕР СЛОТА 6 свободен, но худ не видно / 4й видно слот !
            write_byte( 1 ); // Bucket (Starts at 0) ЭТО НОМЕР ОРУЖИЯ В СЛОТЕ ПО ПОРЯДКУ.
            write_short( DODW_STICKGRENADE ); // Weapon ID
            write_byte( 128); // Flags
            write_byte( 1 ); // Clip Ammo // кратность деления количества патронов в обойме. в результате покажет остаток патронов в запасе . если у Вас 60 патронов, то при 1 = 60, если 5 =12
            message_end();
            client_print(0, print_chat, "SMOKE NADE IN HANDS");
        }
        default: return;
    }
}

public CurWeapon_Post(id_owner)
{	
    // It runs in every Event(CurWeapon)
    if (!is_user_alive(id_owner))
        return;
    new idx_wpn = get_pdata_cbase(id_owner, m_pActiveItem, linux_diff_player);
    if (g_i_weapon[idx_wpn]!=0) 
    {
        new ammo, clip;
        dod_get_user_weapon(id_owner, clip, ammo);
        if(clip<1) is_player_can_shoot[id_owner] = false;
        else    is_player_can_shoot[id_owner] = true;
        Hud_Update_ammo(id_owner, ammo, g_i_weapon[idx_wpn]);

        //debug client_print(0, print_chat, "CurWeapon_Check + %d", idx_wpn)
        switch (g_weapons[g_i_weapon[idx_wpn]][weapon_customtype])
        {
            case 15: 
            {   
                new GrenDODW_ID = read_data(2);
                if(GrenDODW_ID == DODW_STICKGRENADE)
                    is_player_throw_smoke[id_owner] = true;
            }
            case 16:
            {
                
            }
            default: 
            {
                is_player_throw_smoke[id_owner] = false;
                return;
            }
        }
    }
    
}

public HamHook_Item_Deploy_Post(idx_wpn)
{   
    // функция вызывает в момент снаряжентя игрока оружием.
    //++ Именно в этой функции возможно поимеет смысл регистарция и её отключение
    new i = entity_get_int(idx_wpn, EV_INT_iuser4);
    if(i<1)
    {
        g_i_weapon[idx_wpn] = 0;
        return HAM_IGNORED;
    }

    new id_owner = get_pdata_cbase(idx_wpn, m_pPlayer, linux_diff_weapon);
    g_i_weapon[idx_wpn] = i;
    //debug client_print(0, print_chat, "CurWeapon: %d Weapon Founded", i)
    entity_set_string(id_owner, EV_SZ_viewmodel, g_weapons[i][v_model]);
    entity_set_string(id_owner, EV_SZ_weaponmodel,g_weapons[i][p_model]);
    pev(idx_wpn, pev_body, g_weapons[i][v_submdl]);

    return HAM_IGNORED;
}

public Item_Holster_Post(const item)
{
    // Скоррее всего вызывает когда игрок разоружается данным оружием.
    // server_print("ITEM HOLSTER RUNES");
}



public Hud_Update_ammo(id, ammo, i)
{	
    // CLIP HUD ICON	
    
    message_begin(MSG_ONE, g_msgCurWeapon, {0, 0, 0}, id);
    write_byte(1);
    write_byte(g_weapons[i][hud_clip_icon]);
    write_byte(0);
    message_end();
    
    message_begin(MSG_ONE, g_msgAmmoX,{0,0,0},id);
    write_byte(g_weapons[i][hud_clip_icon]);
    write_byte(ammo);
    message_end();
    
    // return;
}


public CurWeapon_PrimaryAttack_P(idx_wpn) 
{   
    // ++ пересмотреть функцию на тему оптимизации

    // Эта функция вызывается по событию выстрела из оружия. Его можно "отменить" , одна на клиенте запускается вся модуляция выстрела
    // Запускается Выстрел, звуук. анимация, трассировка, трата патрона, однако по следующему отклику от сервера, возвращает исходное состояние 
    // оружия 
    if(g_i_weapon[idx_wpn]!=0)
    {   
        if(g_weapons[g_i_weapon[idx_wpn]][is_reference_primaryattack_allowed] == 0)
        {   // В этой проверке блокируется первичная аттака смещением времени, малоли какая наступит раньше.
            set_pdata_float(idx_wpn, m_flNextPrimaryAttack, 999.0);
        }
        //++ хотя прощ воткнусь в сравние выношу из области видимости что бы быстрее были данные
        // new Float:time = get_pdata_float(idx_wpn, m_flNextPrimaryAttack, linux_diff_weapon);
        new i = g_i_weapon[idx_wpn];

        if(get_pdata_float(idx_wpn, m_flNextPrimaryAttack, linux_diff_weapon) < 0.0) 
        {   
            //  client_print(0, print_chat, "CurWeapon_PrimaryAttack_P BLOCK ti2e: %f", ti2e);
            return HAM_SUPERCEDE;
        }
        else 
        {   
            //set_pdata_float(idx_wpn, m_flNextPrimaryAttack, 4.0);
            set_pdata_float(idx_wpn, m_flNextPrimaryAttack, g_weapons[i][f_PrimaryFireRate]);
            new id_owner = get_pdata_cbase(idx_wpn, m_pPlayer, linux_diff_weapon);
            //++  Возможно имеет смысл здесь работать с разрешением не плеера , 
            //++ а оружия. иначем зачем каждый раз брать владельца? ЗАЧЕМ ?
            if(!is_player_can_shoot[id_owner]) 
                return HAM_SUPERCEDE;
            //  client_print(0, print_chat, "m_flNextPrimaryAttack %f ", g_weapons[i][f_PrimaryFireRate] );
            if(g_weapons[i][weapon_customtype]>0)
            {
                switch(g_weapons[i][weapon_customtype])
                {
                    case 1:
                    {
                        // melee knife
                    }
                    case 2:
                    {
                        // pistol
                    } 
                    case 3:
                    {
                        // rifle KAR
                    } 
                    case 4:
                    {
                        // semiautorifle m1carbine
                    } 
                    case 5:
                    {
                        // auogun mp40
                        /*
                        new  Float: vecPunchangle[3];
                        vecPunchangle[0] += random_float(15.0, 20.0); // минус вверх
                        vecPunchangle[1] += random_float(-10.3, -20.3); // минус влево.
                        set_pev(id_owner, pev_punchangle, vecPunchangle);
                        */
                    } 
                    case 6:
                    {
                        // sniper
                    } 
                    case 7:
                    {
                        // machinegun
                    } 
                    case 8:
                    {
                        //shotgun
                        Shotgun_PrimaryAttack(id_owner, idx_wpn);
                    }
                    case 9:
                    {
                        // bazooka
                    } 
                    case 10:
                    {
                        // mortar
                        Mortar_PrimaryAttack(id_owner, idx_wpn);
                    } 
                    case 11:
                    {
                        // nade
                    } 
                    case 12:
                    {
                        // machinegun
                    }
                    case 13:
                    {
                        // satchel
                    }
                    case 14:
                    {
                        // under-barrel_kar
                        // потратить патрон
                        // set_pdata_float(idx_wpn, m_flNextSecondaryAttack, 999.0);
                        set_pdata_int(idx_wpn, m_iClip,  get_pdata_int(idx_wpn, m_iClip, linux_diff_weapon)-1, linux_diff_weapon);
                        UnderBarrelKar_Fire(id_owner, idx_wpn);
                    }
                    case 16:
                    {
                        // iron sighn garand rifle
                        // set_pdata_float(idx_wpn, m_flNextSecondaryAttack, 999.0);
                    }
                    default: return HAM_IGNORED;
                }
            }
            if(g_weapons[i][s_fire1])
                emit_sound(id_owner, CHAN_AUTO, g_weapons[i][s_fire1], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);  
            return HAM_SUPERCEDE;
            }   
        }
    return HAM_IGNORED;
}

public CurWeapon_SecondaryAttack_P(idx_wpn)
{   
    if(g_i_weapon[idx_wpn]!=0)
    {
        new Float:time = get_pdata_float(idx_wpn, m_flNextSecondaryAttack, linux_diff_weapon);
        new i = g_i_weapon[idx_wpn];
        
        if(time > 0.0) 
        {   
            //  client_print(0, print_chat, "CurWeapon_PrimaryAttack_P BLOCK time: %f", time);
            return HAM_SUPERCEDE;
        }
        else 
        {
            new id_owner = get_pdata_cbase(idx_wpn, m_pPlayer, linux_diff_weapon);
            if(is_player_can_shoot[id_owner]==false) return HAM_IGNORED;

            if(g_weapons[i][weapon_customtype])
                {
                    switch(g_weapons[i][weapon_customtype])
                    {
                        case 1:
                        {
                            // melee knife
                        } 
                        case 2:
                        {
                            // pistol
                        } 
                        case 3:
                        {
                            // rifle KAR
                        } 
                        case 4:
                        {
                            // semiautorifle m1carbine
                            
                        } 
                        case 5:
                        {
                            // auogun mp40
                        } 
                        case 6:
                        {
                            // sniper
                        } 
                        case 7:
                        {
                            // machinegun
                        } 
                        case 8:
                        {
                            //shotgun
                            return HAM_SUPERCEDE;
                            /*
                            set_pdata_float(idx_wpn, m_flNextSecondaryAttack, g_weapons[i][f_SecondaryFireRate])
                            return HAM_OVERRIDE
                            */
                        }
                        case 9:
                        {
                            // bazooka
                        } 
                        case 10:
                        {   
                            // MORTAR
                            
                            // new activeitem =  get_pdata_cbase(id_owner, m_pActiveItem, linux_diff_player);
                            // idx_wpn = activeitem by player
                            // set_pdata_float(idx_wpn, m_flTimeWeaponIdle, get_gametime() + 20.0, linux_diff_weapon);

                            //ExecuteHam(Ham_Weapon_SendWeaponAnim, idx_wpn, 0, 1, 1);
                            // set_user_weaponanim(id_owner,0)

                        
                            return HAM_IGNORED;
                        } 
                        case 11:
                        {
                            // nade
                        } 
                        case 12:
                        {
                            // machinegun
                        } 
                        case 13:
                        {
                            //free and more.
                        }
                        case 14:
                        {   
                            // set_pdata_float(idx_wpn, m_flNextSecondaryAttack, g_weapons[i][f_SecondaryFireRate]);
                            return HAM_IGNORED;
                            // UnderBarrelKar_Fire(id_owner, idx_wpn);
                        }
                
                    }
                }
            
            
            
            if(g_weapons[i][s_fire2])
                emit_sound(id_owner, CHAN_AUTO, g_weapons[i][s_fire2], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);        
            //debug client_print(0, print_chat, "custom attack , time: %f", time)
            return HAM_HANDLED;
        }   
    }
    return HAM_IGNORED;
}

public CurWeapon_Reload_Done(id_owner)
{	
    if (!is_user_alive(id_owner)) return;
    // It runs in every Event(CurWeapon)
    new idx_wpn = get_pdata_cbase(id_owner, m_pActiveItem, linux_diff_player);
    if (g_i_weapon[idx_wpn]!=0) 
        {
            // устнаовить количество патронов 
            //++ здесь можно обработать переброс патронов в соотвествии с номинальным остатком АММО и разности на максКЛИП,
            //  иначес стандартная обойма выгребает всё  по референсу
            set_pdata_int(idx_wpn, m_iClip, g_weapons[g_i_weapon[idx_wpn]][max_clip], linux_diff_weapon);
        }
    return;
}


/// KORD_12.7 » 16 ноя 2013, 12:04
public Weaponbox_Spawn_Post(const iWeaponBox)
{
        if (is_valid_ent(iWeaponBox))
        {
                state (is_valid_ent(pev(iWeaponBox, pev_owner))) WeaponBox_Enabled;
        }
        
        return HAM_IGNORED;
}

public FakeMeta_SetModel(const weaponbox) <WeaponBox_Enabled>
{
    state WeaponBox_Disabled;

    if (!is_valid_ent(weaponbox))
    {
        return FMRES_IGNORED;
    }
    else
    {
        new cbase = 82;
        for ( cbase = 82; cbase < 86; cbase++ ) 
            {
                new idx_wpn = get_pdata_cbase(weaponbox, cbase, linux_diff_weapon); // oofset 4
                if (is_valid_ent(idx_wpn))
                {
                    if(g_i_weapon[idx_wpn]!=0)
                    {   
                        //debug client_print(0, print_chat, "custom weapob box")
                        engfunc(EngFunc_SetModel, weaponbox, g_weapons[g_i_weapon[idx_wpn]][w_model]);
                        return FMRES_SUPERCEDE;
                    }
                }
            }
    }
    return FMRES_IGNORED;
}

public FakeMeta_SetModel(const iEntity) <WeaponBox_Disabled>
{
        return FMRES_IGNORED;
} 

// MENU CREATOR 
public gun_menu_open( id )
{
    new menu = menu_create( "\rNew weapons menu", "gun_menu_press" );
    for(new iItem = 1; iItem<=g_uploaded_weapons;iItem++)
    {
        new i = iItem;
        menu_additem( menu, g_weapons[i][weapon_customname], "", 0);
        // server_print("menu::: %s g_weapons[i][weapon_customname]", g_weapons[i][weapon_customname]);
    }
    
    menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );
    menu_display( id, menu, 0 );
}

public gun_menu_press( id, menu, item )
{
    //Because of the simplicity of this menu, we can switch for which item was pressed
    //Note - this is zero-based, so the first item is 0    
    //  client_print(0, print_chat, " You did choose:: %d", item );
    if (item >= 0 && item < 10)
    {
        new i = item+1;
        CustomWeapon_Give(id, g_weapons[i][weapon_customname]);
        //lets finish up this function by destroying the menu with menu_destroy, and a return
        menu_destroy( menu );
        return;
    }
}

public Shotgun_PrimaryAttack(id_owner, idx_weapon)
{    
    new i = 0;
    new  Float: vecPunchangle[3];
    vecPunchangle[0] += random_float(-0.3, 0.3);
    vecPunchangle[1] += random_float(-0.3, 0.3);
    set_pev(id_owner, pev_punchangle, vecPunchangle);
    new Float:f_origin[3];
    new Float:f_origin_traceto[3];
    new i_aim[3];
    new Float:f_aim[3];
    pev(id_owner, pev_origin, f_origin);
    f_origin[2]+=8.0;

    //f_origin[] - точка, откуда игрок смотрит
    //f_aim[] - точка через 35u от взгляда игрока
    get_user_origin(id_owner, i_aim, 3);
    IVecFVec(i_aim,f_aim);
    
    // new Float:fDistance = get_distance_f(f_origin, f_aim) //���
    // client_print(0, print_chat, "fDistance %f", fDistance)
    for (i=0 ; i < 6 ; i++)
    {   

        // ExecuteHam(Ham_Weapon_PrimaryAttack, idx_weapon) // тратит патроны, наносит урон.
        // set_pdata_float(idx_weapon, m_flNextPrimaryAttack, g_weapons[i][f_PrimaryFireRate])

        
        f_origin_traceto[0] = float(i_aim[0]) + random_float(-SHTGN_SPRD,SHTGN_SPRD);
        f_origin_traceto[1] = float(i_aim[1]) + random_float(-SHTGN_SPRD,SHTGN_SPRD);
        f_origin_traceto[2] = float(i_aim[2]) + random_float(-SHTGN_SPRD,SHTGN_SPRD);

        new ttres = create_tr2();
        engfunc(EngFunc_TraceLine, f_origin, f_origin_traceto, DONT_IGNORE_MONSTERS, id_owner, ttres);
        get_tr2(ttres, TR_vecEndPos, f_origin_traceto);
        new  Float:fraction;
        get_tr2(ttres, TR_flFraction, fraction);
        new hit = get_tr2(ttres, TR_pHit);

        // draw_laser(f_origin, f_origin_traceto, 100); // посмотреть куда идёт спрей
        if(hit> 0 && fraction != 1.0)
        {
            ExecuteHamB(Ham_TraceAttack, hit, id_owner, 50.0, f_origin_traceto, ttres, DMG_BULLET);
            //ExecuteHam(Ham_TraceAttack, hit, id_owner, 400.0, f_origin_traceto, ttres, DMG_BULLET);
        }
        else
        {   r_decal_index(ttres);   }
        free_tr2(ttres);
        //client_print(0, print_chat, "HIT: %d FRACTION: %f", hit, fraction)
    }   
}

public Mortar_PrimaryAttack(id_owner, idx_weapon)
{
        //new shoulder = get_pdata_cbase(idx_weapon, m_iWeaponState, linux_diff_weapon);
        // set_pdata_cbase(idx_weapon, m_iWeaponState, 1, linux_diff_weapon);
        //client_print(0, print_chat, "MORTAR SHOOT is  ? %d ", shoulder )
        // ExecuteHam(Ham_Weapon_PrimaryAttack, idx_weapon)
    return HAM_IGNORED;

}


public rocket_shoot(id_owner, rocketindex, wId)
{ 
    // event on Rocket Laucnhed
    set_players_item(id_owner, rocketindex);
    // Получаем индекс оружия
    new i = entity_get_int(get_pdata_cbase(id_owner, m_pActiveItem, linux_diff_player), EV_INT_iuser4);
    if(i)
    {
        set_task(0.2, "rocket_tune", id_owner);
    }

    return;
}

public rocket_tune(id_owner)
{   
    // Получаем индекс оружия
    new i = entity_get_int(get_pdata_cbase(id_owner, m_pActiveItem, linux_diff_player), EV_INT_iuser4);
    switch (g_weapons[i][weapon_customtype])
    {
        case 10:
        {
            new idx_rocket = get_players_item(id_owner);
            if (!is_valid_ent(idx_rocket))
            {
                return;
            }
            else
            {
                fm_attach_view(id_owner, idx_rocket);
                new Float:fAngViev[3];

                // смена вида камера работает
                pev(id_owner, pev_angles, fAngViev);
                set_pev(idx_rocket, pev_angles, fAngViev);
                // вращение снаряда 

                new Float:Thumble[3];
                Thumble[0] = random_float(-70.0, 70.0);
                Thumble[1] = random_float(-70.0, 70.0);
                Thumble[2] = random_float(-70.0, 70.0);

                set_pev(idx_rocket, pev_movetype, MOVETYPE_TOSS);
                set_pev(idx_rocket, pev_gravity, 1.5);
                set_pev(idx_rocket, pev_avelocity, Thumble);

                new Float:fVel[3];
                pev(idx_rocket, pev_velocity, fVel);
                fVel[0] *= 0.70;
                fVel[1] *= 0.70;
                fVel[2] *= 0.70;
                set_pev(idx_rocket, pev_velocity, fVel);
            }
        }
        default: return;
    }// switch ends   
    return;
}

public dod_rocket_explosion(id_owner, Float:pos[3], idx_wpn)  
{   
    // event on Rocket_Explission
    fm_attach_view(id_owner, id_owner);
}

public fw_EmitSound(ent, iChannel, const szSample[], Float:fVolume, Float:fAttenuation, iFlags, iPitch) 
{
    
        EF_EmitSound(ent, iChannel, "weapons/sbarrel1.wav", fVolume, fAttenuation, iFlags, iPitch);
        return FMRES_SUPERCEDE;
}

stock get_players_item(id_owner)
{   
    // читает индекс сущности принадлежащей игроку ( на пример рокеты )
    return g_player_has_item[id_owner];
}

stock set_players_item(id_owner, ptr)
{   
    // записывает  индекс сущности принадлежащей игроку ( на пример рокеты )
    g_player_has_item[id_owner] = ptr;
}

stock set_user_weaponanim(id_owner, anim)
{
    entity_set_int(id_owner, EV_INT_weaponanim, anim);
    message_begin(MSG_ONE, SVC_WEAPONANIM, {0, 0, 0}, id_owner);
    write_byte(anim);
    write_byte(entity_get_int(id_owner, EV_INT_body));
    message_end();
} 

//
//Decals.                                    
//

// new Array: g_hDecals;

#define INSTANCE(%0) ((%0 == -1) ? 0 : %0)
#define IsValidPev(%0) (pev_valid(%0) == 2)
#define STATEMENT_FALLBACK(%0,%1,%2)	public %0()<>{return %1;} public %0()<%2>{return %1;}

#define MESSAGE_BEGIN(%0,%1,%2,%3)	engfunc(EngFunc_MessageBegin, %0, %1, %2, %3)
#define MESSAGE_END()			message_end()
#define WRITE_ANGLE(%0)			engfunc(EngFunc_WriteAngle, %0)
#define WRITE_BYTE(%0)			write_byte(%0)
#define WRITE_COORD(%0)			engfunc(EngFunc_WriteCoord, %0)
#define WRITE_STRING(%0)		write_string(%0)
#define WRITE_SHORT(%0)			write_short(%0)

stock r_decal_index(iTrace)
{
    new iHit;
    new iMessage;
    new iDecalIndex;
    new Float: flFraction; 
    new Float: vecEndPos[3];
    
    iHit = INSTANCE(get_tr2(iTrace, TR_pHit));
    
    if(iHit  && !IsValidPev(iHit) || (pev(iHit, pev_flags) & FL_KILLME))
    {
        return;
    }
    
    if (pev(iHit, pev_solid) != SOLID_BSP && pev(iHit, pev_movetype) != MOVETYPE_PUSHSTEP)
    {
        return;
    }

    iDecalIndex = ExecuteHamB(Ham_DamageDecal, iHit,0);

    get_tr2(iTrace, TR_flFraction, flFraction);
    get_tr2(iTrace, TR_vecEndPos, vecEndPos);

    /*
    message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
    write_byte(TE_SPARKS);
    write_coord(floatround(vecEndPos[0]));
    write_coord(floatround(vecEndPos[1]));
    write_coord(floatround(vecEndPos[2]));
    message_end();
    */


    // iMessage = TE_GUNSHOT; // quake 1 gunshot sprite
    // iMessage = TE_WORLDDECAL;
    //iMessage = TE_GUNSHOTDECAL;
    iMessage = TE_WORLDDECALHIGH;
    
    if(iMessage == TE_GUNSHOT)
    {
        if(iHit>g_maxpl)
        {
            iDecalIndex=0; // problems with func_breakable decals for bullets, thats why need set ZERO
        } 
        /*
        MESSAGE_BEGIN(MSG_PAS, SVC_TEMPENTITY, vecEndPos, 0);
        WRITE_BYTE(iMessage);
        WRITE_COORD(vecEndPos[0]);
        WRITE_COORD(vecEndPos[1]);
        WRITE_COORD(vecEndPos[2]);
        WRITE_SHORT(iHit);
        WRITE_BYTE(iDecalIndex);
        MESSAGE_END();
        */
        // quake PARTICEL SIMPLE
        
        MESSAGE_BEGIN(MSG_PAS, SVC_TEMPENTITY, vecEndPos, 0);
        WRITE_BYTE(TE_GUNSHOT);
        WRITE_COORD(vecEndPos[0]);
        WRITE_COORD(vecEndPos[1]);
        WRITE_COORD(vecEndPos[2]);
        MESSAGE_END();
        
        return;
        
    }
    
    else if(iMessage == TE_WORLDDECAL)
    {   

        // пока работает только с decals.wad
        iDecalIndex = engfunc(EngFunc_DecalIndex, "{m_funkyladder");

        server_print("TE_WORLDDECAL %d" , iDecalIndex);
        if(iDecalIndex > 0)
        {

            message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
            write_byte(TE_WORLDDECAL);
            engfunc(EngFunc_WriteCoord, vecEndPos[0]);
            engfunc(EngFunc_WriteCoord, vecEndPos[1]);
            engfunc(EngFunc_WriteCoord, vecEndPos[2]);
            write_byte(iDecalIndex);
            message_end();
        }
    }
    else if(iMessage == TE_WORLDDECALHIGH)
    {   
        iDecalIndex = engfunc(EngFunc_DecalIndex, "{x_bush2");

        server_print("TE_WORLDDECALHIGH %d" , iDecalIndex);
        if(iDecalIndex > 0)
        {
            message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
            write_byte(TE_WORLDDECALHIGH);
            engfunc(EngFunc_WriteCoord, vecEndPos[0]);
            engfunc(EngFunc_WriteCoord, vecEndPos[1]);
            engfunc(EngFunc_WriteCoord, vecEndPos[2]);
            write_byte(iDecalIndex);
            message_end();
        }
    }
    else if(iMessage == TE_DECALHIGH)
    {   
        // ЕСЛИ НОМЕР ТЕКСТУРЫ ВЫШЕ 256
        // В СТАРОЙ ВЕРСИИ ПОЧЕМУ-ТО ПРОВЕРЯЛ ЭТО , НО ДА, ДКАОЛЬ НЕ ДОЛЖНА БЫТЬ НУЛЕВОЙ ВИДИМО iHit ТОЖЕ
        // ЛЕГКО ОБОСРАТЬСЯ В ЭТОЙ ФУНКЦИИ
        // if(iHit != 0 && iDecalIndex != 0 )
        // {   

            iDecalIndex = engfunc(EngFunc_DecalIndex, "{lime001");

            server_print("TE_DECALHIGH %d" , iDecalIndex);
            if(iDecalIndex > 0)
            {
                message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
                write_byte(TE_DECALHIGH);
                engfunc(EngFunc_WriteCoord, vecEndPos[0]);
                engfunc(EngFunc_WriteCoord, vecEndPos[1]);
                engfunc(EngFunc_WriteCoord, vecEndPos[2]);
                write_byte(iDecalIndex);
                write_short(iHit);
                message_end();
            }
        // }
    }
    

    // client_print(0,print_chat,"IDecalIndex = %d, Ihit %d", iDecalIndex, iHit ) ;
}



/*
bool:is_team_attack(attacker, victim)
{   
    // from weaponmod by devcones
    if(!(pev(victim, pev_flags) & (FL_CLIENT | FL_FAKECLIENT)))
    {
        // Victim is a monster, so definetely no team attack ;)
        return false;
    }
    if(get_pcvar_num(g_FriendlyFire) == 1)
    {
        if(get_user_team(victim) == get_user_team(attacker))
        {
            // Team attack
            return true;
        }
    }
    // No team attack or friendlyfire is disabled
    return false;
}
*/


public draw_laser(Float:start[3], Float:end[3], staytime)
{                    
    message_begin(MSG_ALL, SVC_TEMPENTITY);
    write_byte(TE_BEAMPOINTS);
    engfunc(EngFunc_WriteCoord, start[0]);
    engfunc(EngFunc_WriteCoord, start[1]);
    engfunc(EngFunc_WriteCoord, start[2]);
    engfunc(EngFunc_WriteCoord, end[0]);
    engfunc(EngFunc_WriteCoord, end[1]);
    engfunc(EngFunc_WriteCoord, end[2]);
    write_short(g_SpriteKarGrenSmoke);
    write_byte(0);
    write_byte(0);
    write_byte(600); // In tenths of a second.
    write_byte(10);
    write_byte(1);
    write_byte(255); // Red
    write_byte(0); // Green
    write_byte(0); // Blue
    write_byte(127);
    write_byte(1);
    message_end();
} 


/*
public shell_temp_p_submodelchreck_think(idx_rocket)
{   
    
    set_pev(idx_rocket, pev_nextthink, get_gametime() + 1.1)
    set_pev(idx_rocket, pev_movetype, MOVETYPE_TOSS)
    set_pev(idx_rocket, pev_gravity,2.45)	
    set_pev(idx_rocket, pev_avelocity, {0.0, 50.0, 0.0})

}
*/

/// Функции подствольного гранатомёта на Маузере

public UnderBarrelKar_Fire(idx_player, idx_weapon)
{
    Kargrenade_Create(idx_player, idx_weapon);
}


public Kargrenade_Create(idx_player, idx_weapon)
{	
    if(!pev_valid(idx_player) && !pev_valid(idx_weapon))
        return HAM_SUPERCEDE;
    new iOrigin1[3]; //  
    get_user_origin(idx_player, iOrigin1, 1); //  
    
    new Float:fOrigin[3]; //   float 
    IVecFVec(iOrigin1, fOrigin) ;//     

    //// CREATE ENITY ;
    new idx_KarGrenade = create_entity("info_target");
    if(!pev_valid(idx_KarGrenade)) 
    {
        return PLUGIN_HANDLED;
    }
    set_pev(idx_KarGrenade, pev_classname, "grenade_kar");
    set_pev(idx_KarGrenade, pev_solid, SOLID_TRIGGER);
    set_pev(idx_KarGrenade, pev_movetype, MOVETYPE_TOSS);
    set_pev(idx_KarGrenade,pev_avelocity, TumbleVector);
    engfunc(EngFunc_SetModel, idx_KarGrenade, "models/w_grenade.mdl"); // 
    engfunc(EngFunc_SetSize, idx_KarGrenade, Float:{-1.0, -1.0, 1.0}, Float:{1.0, 1.0, 1.0});
    entity_set_edict(idx_KarGrenade, EV_ENT_owner, idx_player);
    static Float:vVelocity[3];
    velocity_by_aim(idx_player, 1000, vVelocity);
    set_pev(idx_KarGrenade, pev_velocity, vVelocity);
    set_pev(idx_KarGrenade, pev_origin, fOrigin);

    TumbleVector[0] = random_float(-600.0,600.0); // = 1320.0  // Wheel 
    TumbleVector[1] = random_float(-600.0,600.0);  // TEA
    TumbleVector[2] = random_float(-600.0,600.0); //  HOURS
    // Если нужно что бы разбивалось от пули , надо менять на 
    // SOLID_BBOX и менять точку старта, а то задевае игрока
    // set_pev(idx_KarGrenade, pev_health, 1.0);
    // set_pev(idx_KarGrenade, pev_takedamage, DAMAGE_YES);
    
    message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
    write_byte(TE_BEAMFOLLOW);	// Temp entity type
    write_short(idx_KarGrenade);		// entity
    write_short(g_SpriteKarGrenSmoke);	// sprite index
    write_byte(20);	// life time in 0.1's
    write_byte(2);	// line width in 0.1's
    write_byte(63);	// red (RGB)
    write_byte(63);	// green (RGB)
    write_byte(63);	// blue (RGB)
    write_byte(100);// brightness 0 invisible, 255 visible
    message_end();

    set_task(random_float(0.9,1.5), "Kargrenade_Explode", idx_KarGrenade);

    new ammo, clip;
    dod_get_user_weapon(idx_player, clip, ammo);

    return HAM_SUPERCEDE;
}

public Kargrenade_DamageRadius(idx_KarGrenade, Float:fOrigin_KarGrenade[3], idx_owner)
{   
    new Float:fOrigin_Player[3];
    new Float:fDistance;
    new Float:fDamage;
    for(new id = 1 ; id < get_maxplayers() + 1 ; id++)
    {   
        if(is_user_alive(id))
        {
            pev(id, pev_origin, fOrigin_Player);
            fDistance = get_distance_f(fOrigin_Player, fOrigin_KarGrenade);
            if(fDistance < 200.0)
            {   
                // множитель урона при 140 140 дамага 60-100
                fDamage = 200.0 * (1.0 - (fDistance/200.0));
                // inflictor == owner берёт activeweapon  при смерте, не регистрирует убийство
                ExecuteHam(Ham_TakeDamage, id, idx_owner , idx_owner, fDamage, DMG_GENERIC); // DMG_BULLET
                // server_print("damage kargrenad %f", fDamage);
            }
        }
    }
}

public Kargrenade_Explode(idx_KarGrenade)
{
    if(!pev_valid(idx_KarGrenade)) 
        return PLUGIN_HANDLED;
    new idx_owner = entity_get_edict(idx_KarGrenade, EV_ENT_owner);
    new Float:fOrigin_KarGrenade[3];
    pev(idx_KarGrenade, pev_origin, fOrigin_KarGrenade);
    Kargrenade_DamageRadius(idx_KarGrenade, fOrigin_KarGrenade, idx_owner);


    new origin[3];
    origin[0] = floatround(fOrigin_KarGrenade[0]);
    origin[1] = floatround(fOrigin_KarGrenade[1]);
    origin[2] = floatround(fOrigin_KarGrenade[2]);
    // (origin[3], addrad= скорость движения, sprite, startfrate, framerate, life=радиус и продолжительность, width, amplitude, red, green, blue, brightness, speed)
    // create_cylinder(origin, 1200, g_torus, 0, 0, 30, 200, 10, 150, 150, 150, 40, 0)

    // fx_dod_explossion();
    
    message_begin(MSG_BROADCAST,SVC_TEMPENTITY) ;// 
    write_byte(TE_EXPLOSION); // ()
    engfunc(EngFunc_WriteCoord, fOrigin_KarGrenade[0]) ;// x
    engfunc(EngFunc_WriteCoord, fOrigin_KarGrenade[1]); // y
    engfunc(EngFunc_WriteCoord, fOrigin_KarGrenade[2] + 10.0); // z
    write_short(g_SpriteExplode); //  
    write_byte(9); // scale
    write_byte(40); // 
    write_byte(0); //
    message_end(); // 
    // 
    /* fx_dod_explossion типа спарклс
    message_begin(MSG_BROADCAST,SVC_TEMPENTITY) ;// 
    write_byte(TE_TAREXPLOSION); // ()
    engfunc(EngFunc_WriteCoord, fOrigin_KarGrenade[0]) ;// x
    engfunc(EngFunc_WriteCoord, fOrigin_KarGrenade[1]); // y
    engfunc(EngFunc_WriteCoord, fOrigin_KarGrenade[2] + 10.0); // z
    message_end(); //   
    */

    message_begin(MSG_BROADCAST,SVC_TEMPENTITY) ;// 
    write_byte(TE_STREAK_SPLASH); // ()
    engfunc(EngFunc_WriteCoord, fOrigin_KarGrenade[0]) ;// x
    engfunc(EngFunc_WriteCoord, fOrigin_KarGrenade[1]); // y
    engfunc(EngFunc_WriteCoord, fOrigin_KarGrenade[2] + 10.0); // z
    engfunc(EngFunc_WriteCoord, fOrigin_KarGrenade[0] + 200.0) ;// x
    engfunc(EngFunc_WriteCoord, fOrigin_KarGrenade[1] + 200.0); // y
    engfunc(EngFunc_WriteCoord, fOrigin_KarGrenade[2] + 210.0); // z
    write_byte(24); // scale
    write_short(10); //  
    write_short(50); //  
    write_short(10); //  
    message_end(); // 

    // fx_sprite_smoke
    message_begin(MSG_BROADCAST,SVC_TEMPENTITY);// 
    write_byte(TE_SMOKE); // ()
    engfunc(EngFunc_WriteCoord, fOrigin_KarGrenade[0]); // x
    engfunc(EngFunc_WriteCoord, fOrigin_KarGrenade[1]); // y
    engfunc(EngFunc_WriteCoord, fOrigin_KarGrenade[2] + 20.0); // x
    write_short(g_SpriteKarGrenSmoke); //  
    write_byte(25); // 
    write_byte(10); // 
    message_end();// 

    // fx_decal_explossion
    message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
    write_byte(TE_WORLDDECAL);
    engfunc(EngFunc_WriteCoord, fOrigin_KarGrenade[0]);
    engfunc(EngFunc_WriteCoord, fOrigin_KarGrenade[1]);
    engfunc(EngFunc_WriteCoord, fOrigin_KarGrenade[2]);
    write_byte(60); // 60 EXPLOD
    message_end();

    // fx_sparkles
    new sparkles;
    for (sparkles = 0; sparkles < 8 ; sparkles++)
    {
        message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
        write_byte(TE_SPARKS);
        write_coord((origin[0] + random_num(-150,150)));
        write_coord((origin[1] + random_num(-150,150)));
        write_coord((origin[2] + random_num(0,150)));
        message_end();
    }


    // fx_dlight
    message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
    write_byte(TE_DLIGHT);
    write_coord(origin[0]);
    write_coord(origin[1]);
    write_coord(origin[2]+20);
    write_byte(20); // radius in 10's)
    write_byte(200); // Red
    write_byte(random_num(30, 80)); // Green
    write_byte(0); // Blue
    write_byte(253); // brightness
    write_byte(40);  // Сила глушения, чем больше число, тем скорее затухает 
    message_end();

    remove_entity(idx_KarGrenade);
    return PLUGIN_CONTINUE;
}


public grenade_throw(idx_owner, idx_grenade, wid)
{	
    // сбросим счётсчик , установим время. 
    // здесь нужно повторять функцию установки параметров, т.к. по факту здесь они даже не сработали, потому что скрипт срабатывает быстрее чем игровые назначения.
    // по факту если не запустить grenade_throw_P() то движок перепишет параметры гранаты по стандарту .

    // sticknade_ex fix пока нет необходимости,
    // set_pdata_float(id_nade, m_flTimeToExplode, g_ntimer[id_owner] , 4) // 
    // это защита от хитрожопых, которые бросая гранату, и сразу нажимают на Е

    // set_pev(idx_grenade, pev_dmgtime, get_gametime() + 100.0);
    if(is_player_throw_smoke[idx_owner])
    {   
        /*
        remove_entity(idx_grenade); 
        engclient_cmd(idx_owner, "throw_smoke");
        */
        // Режим самостояльеного создания
        
        entity_set_string(idx_grenade, EV_SZ_classname, "smoke_grenade");
        set_pev(idx_grenade, pev_dmgtime, BLOCKED_ATTACK_TIME);
        RegisterHam(Ham_Think, "info_target", "SmokeGrenade_Smokes");
        set_task(1.5, "Smoke_TestRetune", idx_grenade);
        // server_print("is_player_throw_smoke == True idx_grenade: %d  idx_owner %d", idx_grenade , idx_owner);

    }
    else return;
}


public Smoke_TestRetune(idx_smokegrenade)
{ 
    emit_sound(idx_smokegrenade, CHAN_AUTO, "ambience/treejump.wav", VOL_NORM, ATTN_NORM, 0, 85);
    pev(idx_smokegrenade, pev_avelocity, TumbleVector);

    new idx_owner = entity_get_edict(idx_smokegrenade, EV_ENT_owner);
    SmokeGrenade_Create(idx_owner, idx_smokegrenade);
}


public SmokeGrenade_Create(idx_owner, idx_ref_grenade2)
{	
    
    new Float:fDmgTime;
    pev(idx_ref_grenade2, pev_dmgtime, fDmgTime);
    if(fDmgTime == BLOCKED_ATTACK_TIME)
    {
        
        new Float:fOrigin[3], Float:fVeloctiy[3], Float:fAngles[3]; //   float 
        pev(idx_ref_grenade2, pev_origin, fOrigin);
        pev(idx_ref_grenade2, pev_velocity, fVeloctiy);
        pev(idx_ref_grenade2, pev_angles, fAngles);
        pev(idx_ref_grenade2, pev_avelocity, TumbleVector);
        
        fVeloctiy[0] += random_float(20.0, 20.0);
        fVeloctiy[1] += random_float(20.0, 20.0);
        fVeloctiy[2] += random_float(20.0, 20.0);
        remove_entity(idx_ref_grenade2); 

        //// CREATE ENITY ;
        new idx_SmokeGrenade = create_entity("info_target");
        if(!pev_valid(idx_SmokeGrenade)) 
        {
            return PLUGIN_HANDLED;
        }
        set_pev(idx_SmokeGrenade, pev_classname, "grenade_smoke");
        set_pev(idx_SmokeGrenade, pev_solid, SOLID_TRIGGER);
        set_pev(idx_SmokeGrenade, pev_movetype, MOVETYPE_TOSS);
        engfunc(EngFunc_SetModel, idx_SmokeGrenade, "models/w_stick.mdl"); //  модель гранаты взять !!!
        engfunc(EngFunc_SetSize, idx_SmokeGrenade, Float:{-1.0, -1.0, 1.0}, Float:{1.0, 1.0, 1.0});
        entity_set_edict(idx_SmokeGrenade, EV_ENT_owner, idx_owner);
        set_pev(idx_SmokeGrenade, pev_origin, fOrigin);
        set_pev(idx_SmokeGrenade, pev_velocity, fVeloctiy);
        set_pev(idx_SmokeGrenade, pev_angles, fAngles);
        set_pev(idx_SmokeGrenade, pev_avelocity, TumbleVector);

        /*
        TumbleVector[0] = random_float(-600.0,600.0); // = 1320.0  // Wheel 
        TumbleVector[1] = random_float(-600.0,600.0);  // TEA
        TumbleVector[2] = random_float(-600.0,600.0); //  HOURS
        */
        // fx_dod_explossion();
        message_begin(MSG_BROADCAST,SVC_TEMPENTITY) ;// 
        write_byte(TE_EXPLOSION); // ()
        engfunc(EngFunc_WriteCoord, fOrigin[0]) ;// x
        engfunc(EngFunc_WriteCoord, fOrigin[1]); // y
        engfunc(EngFunc_WriteCoord, fOrigin[2] + 10.0); // z
        write_short(g_SpriteExplode); //  
        write_byte(3); // scale
        write_byte(40); // 
        write_byte(2); //
        message_end(); // 

        message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
        write_byte(TE_BEAMFOLLOW);	// Temp entity type
        write_short(idx_SmokeGrenade);		// entity
        write_short(g_SpriteKarGrenSmoke);	// sprite index
        write_byte(20);	// life time in 0.1's
        write_byte(2);	// line width in 0.1's
        write_byte(25);	// red (RGB)
        write_byte(25);	// green (RGB)
        write_byte(25);	// blue (RGB)
        write_byte(100);// brightness 0 invisible, 255 visible
        message_end();


        entity_set_int(idx_SmokeGrenade, EV_INT_iuser4, 1);
        
        // set_think 
        set_pev(idx_SmokeGrenade, pev_nextthink, get_gametime() + 1.0);
    }
    return PLUGIN_CONTINUE;
}

public SmokeGrenade_Smokes(idx_smokegrenade)
{   

    if(pev_valid(idx_smokegrenade))
    {
    new clsname[32];
    entity_get_string(idx_smokegrenade, EV_SZ_classname, clsname, 31);
    if(equal(clsname,"grenade_smoke"))
        {
        new sprite_size = entity_get_int(idx_smokegrenade, EV_INT_iuser4);
        new Float:GrenOrigin[3],iOrigin[3];
        pev(idx_smokegrenade, pev_origin, GrenOrigin);

        iOrigin[0] = floatround(GrenOrigin[0]);
        iOrigin[1] = floatround(GrenOrigin[1]);
        iOrigin[2] = floatround(GrenOrigin[2]);

        for(new i=0; i < 4; i++)
        {	
            // Start the message
            message_begin(MSG_BROADCAST, SVC_TEMPENTITY, iOrigin);
            write_byte(TE_SMOKE);
            if(sprite_size<10)
            {
                write_coord(iOrigin[0] + random_num(-10,10));
                write_coord(iOrigin[1] + random_num(-10,10));
                write_coord(iOrigin[2] + random_num(-10, 0));
            }
            else 
            {
                write_coord(iOrigin[0] + random_num(-60,60));
                write_coord(iOrigin[1] + random_num(-60,60));
                write_coord(iOrigin[2] + random_num( -30, 60));
            }
            write_short(g_SpriteSmokeGrenSmoke);
            if (sprite_size<20)
            {
                entity_set_int(idx_smokegrenade, EV_INT_iuser4, sprite_size);
                write_byte(sprite_size); // SPRITESIZE
                //write_byte(random_num(30,50)); // SPRITESIZE
            }
            else
            {
                write_byte(random_num(20,50)); // SPRITESIZE
            }
            write_byte(random_num(1,3)); // SPRITE FPS 3-6 zaebis!!
            message_end();
            
            // End the message
        }
        sprite_size++;
        entity_set_int(idx_smokegrenade, EV_INT_iuser4, sprite_size);
        if(sprite_size > 30)
        {
            remove_entity(idx_smokegrenade);
            return;
        }
        // server_print("sprite_size %d", sprite_size);
        if(sprite_size < 15)
            {

            set_pev(idx_smokegrenade, pev_nextthink, get_gametime() + 0.6);
            }
        else
            {
            set_pev(idx_smokegrenade, pev_nextthink, get_gametime() + 1.0);
            }
        }
    }
}


public get_weapon_ammotype_by_ptr(ptr_idx_weapon)
{
    return get_pdata_int(ptr_idx_weapon, m_iPrimaryAmmoType, linux_diff_weapon);
}