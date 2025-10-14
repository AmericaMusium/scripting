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
#define SHTGN_SPRD 100.0

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
#define AMMO_SMG 1 		     // thompson, greasegun, sten, mp40
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
Есть вероятность что имеет смысл спрятать атаку огнестрелов на префрейм. что бы не обрабатывать случившееся событие. 
Тогда пропадёт оригинальный звук, и будет полная иммитация новых оружий, со спреем и всем постлежащим. 
Однако мортира тогда не сможет быть вызывана (возможно)
Не читает нормально фаеррейт . в чём-то ошибка. всегла 0,1 .после перезаписи фаеррайта вручную рабоает прекрасно
если регистрировать хамфорварл, то он регистрирует новый форвард каждый раз . не желаетльно регистрировать одинаковые фоврады в одном плагине.

*/

#define w_config "addons/amxmodx/configs/w_weapons.ini"

// создаём массив для данных иммитирум создание класса 
#define MAX_CWEAPONS 32
enum _:W_DATA
{
    code, // 104 , 25677, 84 any unic numberfor custom weapon
    ref[32], // weapon_spade
    slot, // 1 == knife 3== rifle
    wname[32], // weapon_katana
    Float:f_dmgmlt,  	// FLOAT DAMAGE MULTIPLIER
    Float:f_firerate1,
    Float:f_firerate2,   	// shooting speed per
    Float:f_rldtime, // reloadtime
    m_clip,   
    m_ammo,
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
    w_type
}



new g_weapons[MAX_CWEAPONS][W_DATA];
new g_uploaded_weapons;
new g_i_weapon[1366];
new bool: g_canshoot[33];
new g_user_ptr[33];

/// переопределяем смещения 

// Linux extra offsets
#define linux_diff_weapon 4
#define linux_diff_player 5
#define linux_diff_animation 4

// Dod CbaseWeapon offsets 
#define m_flNextPrimaryAttack 103 	// float
#define m_flNextSecondaryAttack 104 // float
#define m_flTimeWeaponIdle 105 	// float	
#define m_flNextAttack 211 // float

#define m_iClip 108  			// int
/// WANTED! SETTER FOR AMMO
#define m_pPlayer 89 			// int returns owner's of weapon
#define m_knifeItem 272			// prt ножа 
#define m_pistolItem 273        //  ptr пистолета в инвентаре
#define m_rifleItem 274        //  ptr основы в инвентаре
#define m_nadeItem 276 

#define m_pActiveItem 278 		// возвращает Entity idx оружия в руках (не константу) + linux_diff_player
#define m_rgpPlayerItems 81		// Weaponbox ячейки
#define m_fInReload	111         //  Integer 
#define m_iWeaponState 115		// IS BAZOOKA/PIAT/PSCHREK Shouldered

new g_msgCurWeapon;
new g_msgAmmoX; 
new g_maxpl;
new g_FriendlyFire;


new g_sprsmk;

public plugin_init()
{   
    upload_ini();
    // set_task(1.0, "upload_ini");
    register_plugin("DOD Wmod ini","0.0","America");
    server_print("DOD Wmod ini") ;   
    //pause("a");


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
    register_event("CurWeapon", "CurWeapon_Post_Check", "be", "1=1");
    register_event("ReloadDone", "CurWeapon_Reload_Done", "be", "1=1");
    RegisterHam(Ham_Spawn, "weaponbox", "Weaponbox_Spawn_Post", true);
    register_forward(FM_SetModel, "FakeMeta_SetModel", false);
    state WeaponBox_Disabled;

    // register_forward(FM_EmitSound, "fw_EmitSound")
    // register_think("shell_pschreck", "shell_pschreck_think")

    /// Automatic gunmenu
}



// Precache required files
public plugin_precache()
{
    // upload_ini();
    g_sprsmk = precache_model("sprites/smoke_ia.spr");
}

public upload_ini()
    {
    server_print("[WMOD] upload ini start");
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
    server_print("[WMOD] upload ini end");
    return PLUGIN_HANDLED;
}

public read_ini()
{
    new line_text[256], line_len, line_num;
    new file_lines = file_size(w_config, 1);

    server_print("[WMOD] file_lines = %d", file_lines);
    g_uploaded_weapons = (file_lines - 1);
    for (line_num = 1; line_num < file_lines ; line_num++) 
    {	
    new i = line_num;
    read_file(w_config, line_num, line_text, 255, line_len);
    // server_print(line_text);
    new cd[16],refn[32], slt[4], wnn[32], dmm[8], fr1[8], fr2[8], rlt[4], mclp[4], mamm[4], hclp[4], hamm[4], sf1[64],sf2[64], vm[64],pm[64], wm[64], vs[4], ps[4], ws[4], wt[4];

    new num = parse(line_text, cd, 15, refn, 31, slt, 3, wnn, 31, dmm, 7, fr1, 7 , fr2,7, rlt, 3,  mclp, 3, mamm, 3, hclp, 3, hamm, 3, sf1, 63, sf2, 63, vm, 63, pm, 63, wm, 63, vs,3, ps,3, ws,3,wt,3);
    server_print("%s", fr1);
    g_weapons[i][code] = str_to_num(cd);
    g_weapons[i][ref] = refn;
    g_weapons[i][slot] = str_to_num(slt);
    g_weapons[i][wname] = wnn;
    g_weapons[i][f_dmgmlt] = str_to_float(dmm);
    g_weapons[i][f_firerate1] = str_to_float(fr1);
    g_weapons[i][f_firerate2] = str_to_float(fr2);
    g_weapons[i][f_rldtime] = str_to_float(rlt);
    g_weapons[i][m_clip] = str_to_num(mclp);
    g_weapons[i][m_ammo] = str_to_num(mamm);
    g_weapons[i][hud_clip_icon] = str_to_num(hclp);
    g_weapons[i][hud_ammo_icon] = str_to_num(hamm);
    g_weapons[i][s_fire1] = sf1;
    g_weapons[i][s_fire2] = sf2;
    g_weapons[i][v_model] = vm;
    g_weapons[i][p_model] = pm;
    g_weapons[i][w_model] = wm;
    g_weapons[i][v_submdl] = str_to_num(vs);
    g_weapons[i][p_submdl] = str_to_num(ps);
    g_weapons[i][w_submdl] = str_to_num(ws);
    g_weapons[i][w_type] = str_to_num(wt);
    

    server_print("%f", g_weapons[i][f_firerate1]);
    new x[4];
    x = "";
    if(sf1[0]!=x[0])
    {
        engfunc(EngFunc_PrecacheSound, sf1);
    }
        
    if(sf2[0]!=x[0])
        engfunc(EngFunc_PrecacheSound, sf2);
    if(vm[0]!=x[0])
        engfunc(EngFunc_PrecacheModel, vm);
    if(pm[0]!=x[0])
        engfunc(EngFunc_PrecacheModel, pm);
    if(wm[0]!=x[0])
        engfunc(EngFunc_PrecacheModel, wm);

        // server_print("[WMOD] loading complete for %s  ", g_weapons[i][wname]);
    }
    Ham_g_PrAttack();
    server_print("[WMOD] TOTAL WEAPONS: %d", g_uploaded_weapons);
}

public Ham_g_PrAttack()
{
    new i;
    for( i = 1; i <= g_uploaded_weapons; i++)
    {
        server_print("[WMOD] Ham_g_PrAttack %s", g_weapons[i][ref]);
        RegisterHam(Ham_Weapon_PrimaryAttack,	g_weapons[i][ref],	"CurWeapon_PrimaryAttack_Pre", true);  
        RegisterHam(Ham_Weapon_SecondaryAttack,	g_weapons[i][ref],	"CurWeapon_SecondaryAttack_Pre", false);  
        RegisterHam(Ham_Item_Deploy,		g_weapons[i][ref], 	"HamHook_Item_Deploy_Post",	true);
        RegisterHam(Ham_DOD_Item_CanDrop, g_weapons[i][ref], "WeaponBox_Drop_P");
    }
        
}
public WeaponBox_Drop_P(id)
{

    /// запстить проверку на разрешение выброса ножа методом броска

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
            if(equal(temp,g_weapons[ii][wname]))
            {
                /// выдать оружие 
                if (!is_user_connected(id_owner) || !is_user_alive(id_owner)) return;
                // Get weapon entity ID of client's primary weapon - returns -1 on none

                new temp_cur_weapon_ent_id = get_pdata_cbase(id_owner, g_weapons[ii][slot]); // to frop pistol use m_pistolItem
                if (temp_cur_weapon_ent_id != -1)
                {
                    new temp_class_name[17];
                    entity_get_string(temp_cur_weapon_ent_id ,EV_SZ_classname,temp_class_name, 16);
                    engclient_cmd(id_owner,"drop",temp_class_name);
                    
                    // pev(temp_cur_weapon_ent_id,pev_classname,temp_class_name,16)
                    // //debug client_print(0, print_chat, "GIVE: temp cur = %d classname is %s .", temp_cur_weapon_ent_id, temp_class_name );
                }

                temp_cur_weapon_ent_id = give_item(id_owner, g_weapons[ii][ref]);
                if(!is_valid_ent(temp_cur_weapon_ent_id)) return;
                // //debug client_print(0, print_chat, "Player: %d , id=gived: %d", id_owner, temp_cur_weapon_ent_id)
                // to switch in arm:
                engclient_cmd(id_owner, g_weapons[ii][ref]);
                CustomWeapon_Retune(temp_cur_weapon_ent_id, ii, id_owner);

            }
        }
    }
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
set_pdata_int(idx_wpn, m_iClip,  g_weapons[i][m_clip], linux_diff_weapon);
/// --WANTED! SETTER FOR AMMO 
// set_pdata_int(idx_wpn, ??? , g_weapons[i][m_ammo], linux_diff_weapon);
// set_pdata_int(idx_wpn, m_iDefaultAmmo, 0); SETTER FOR AMMO 


// обновить HUD
new clip, ammo, myWeapon = dod_get_user_weapon(id_owner, clip, ammo);
Hud_Update_ammo(id_owner, ammo, i);
entity_set_string(id_owner, EV_SZ_viewmodel, g_weapons[i][v_model]);
entity_set_string(id_owner, EV_SZ_weaponmodel,g_weapons[i][p_model]);

//// meesage
// //debug client_print(id_owner, print_chat, "Player: %d , WeaponID: %d , retuned to CUSTOM", id_owner, idx_wpn);

}


public CurWeapon_Post_Check(id_owner)
{	
    if (!is_user_alive(id_owner)) return;

    // It runs in every Event(CurWeapon)
    
    new idx_wpn = get_pdata_cbase(id_owner, m_pActiveItem, linux_diff_player);
    if (g_i_weapon[idx_wpn]!=0) 
    {
        new ammo, clip;
        dod_get_user_weapon(id_owner, clip, ammo);
        if(clip<1) g_canshoot[id_owner] = false;
        else if(clip>0)   g_canshoot[id_owner] = true;
        Hud_Update_ammo(id_owner, ammo, g_i_weapon[idx_wpn]);

        //debug client_print(0, print_chat, "CurWeapon_Check + %d", idx_wpn)
    }
    
}

public HamHook_Item_Deploy_Post(idx_wpn)
{

    new i = entity_get_int(idx_wpn, EV_INT_iuser4);
    if(i<1)
    {
        //debug client_print(0, print_chat, "EMPTY CODE")
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




public Hud_Update_ammo(id, ammo, i)
{	
    // CLIP HUD ICON	
    
    message_begin(MSG_ONE, g_msgCurWeapon, {0, 0, 0}, id);
    write_byte(1);
    write_byte(g_weapons[i][hud_clip_icon]);
    write_byte(0);
    message_end();
    
    message_begin(MSG_ONE, g_msgAmmoX,{0,0,0},id);
    write_byte(g_weapons[i][hud_ammo_icon]);
    write_byte(ammo);
    message_end();
    
    // return;
}


public CurWeapon_PrimaryAttack_Pre(idx_wpn) 
{   
    // Эта функция вызывается по событию выстрела из оружия. Его можно "отменить" , одна на клиенте запускается вся модуляция выстрела
    // Запускается Выстрел, звуук. анимация, трассировка, трата патрона, однако по следующему отклику от сервера, возвращает исходное состояние 
    // оружия 
    if(g_i_weapon[idx_wpn]!=0)
    {
        new Float:time = get_pdata_float(idx_wpn, m_flNextPrimaryAttack, linux_diff_weapon);
        new i = g_i_weapon[idx_wpn];

        if(time < 0.0) 
        {   
            client_print(0, print_chat, "CurWeapon_PrimaryAttack_Pre BLOCK time: %f", time);
            return HAM_SUPERCEDE;
        }
        else 
        {   
            //set_pdata_float(idx_wpn, m_flNextPrimaryAttack, 4.0);
            set_pdata_float(idx_wpn, m_flNextPrimaryAttack, g_weapons[i][f_firerate1]);
            new id_owner = get_pdata_cbase(idx_wpn, m_pPlayer, linux_diff_weapon);
            // ++Возможно имеет смысл здесь работать с разрешением не плеера , а оружия. иначем зачем каждый раз брать владельца?
            if(g_canshoot[id_owner]==false) return HAM_SUPERCEDE;
            client_print(0, print_chat, "m_flNextPrimaryAttack %f ", g_weapons[i][f_firerate1] );
            if(g_weapons[i][w_type]>0)
                {
                    switch(g_weapons[i][w_type])
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
                            UnderBarrelKar_Fire(id_owner, idx_wpn);
                        }  
                    }
                }
            
            
            if(g_weapons[i][s_fire1])
            {
                client_print(0, print_chat, "EMIT SUND PRE SHOOT ");
                emit_sound(id_owner, CHAN_WEAPON, g_weapons[i][s_fire1], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);  
            }    
            return HAM_IGNORED;
            }   
        }
    return HAM_IGNORED;
}

public CurWeapon_SecondaryAttack_Pre(idx_wpn)
{   
    if(g_i_weapon[idx_wpn]!=0)
    {
        new Float:time = get_pdata_float(idx_wpn, m_flNextSecondaryAttack, linux_diff_weapon);
        new i = g_i_weapon[idx_wpn];
        
        if(time > 0.0) 
        {   
            client_print(0, print_chat, "CurWeapon_PrimaryAttack_Pre BLOCK time: %f", time);
            return HAM_SUPERCEDE;
        }
        else 
        {
            new id_owner = get_pdata_cbase(idx_wpn, m_pPlayer, linux_diff_weapon);
            if(g_canshoot[id_owner]==false) return HAM_IGNORED;

            if(g_weapons[i][w_type])
                {
                    switch(g_weapons[i][w_type])
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
                            set_pdata_float(idx_wpn, m_flNextSecondaryAttack, g_weapons[i][f_firerate2])
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
                
                    }
                }
            
            
            
            if(g_weapons[i][s_fire2])
                emit_sound(id_owner, CHAN_WEAPON, g_weapons[i][s_fire2], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);        
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
            set_pdata_int(idx_wpn, m_iClip, g_weapons[g_i_weapon[idx_wpn]][m_clip], linux_diff_weapon);
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

//lets make the function that will make the menu
public gun_menu_open( id )
{
    new menu = menu_create( "\rNew weapons menu", "gun_menu_press" );
    for(new iItem = 1; iItem<=g_uploaded_weapons;iItem++)
    {
        new i = iItem;
        menu_additem( menu, g_weapons[i][wname], "",0);
        // g_weapons[i][wname];
    }
    menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );
    menu_display( id, menu, 0 );
}

public gun_menu_press( id, menu, item )
{
    //Because of the simplicity of this menu, we can switch for which item was pressed
    //Note - this is zero-based, so the first item is 0    

    new i = item+1;
    
    client_print(0, print_chat, " You did choose:: %s", g_weapons[i][wname] );

    CustomWeapon_Give(id, g_weapons[i][wname]);

    //lets finish up this function by destroying the menu with menu_destroy, and a return
    menu_destroy( menu );
    return PLUGIN_HANDLED;
}






///  в любом виде C_weapon придётся отправлять трассировку пули + декаль + дамаг
// если оружие особого типа, возможна блокировка выстрела.
// но скорее для дробовика нужна следующая вот какая схема:
// 
// при воспрозведёном выстреле взять направление, добавить спрэд.
// пуля пошла на трасс, в условиях разлёт на деколь или damage. 
// трассуха черех индекс ставится
// damage нанести через Ham
// наверно это всё в одной функции 
// bullet(id_attacker, idx_weapon, Float:trStart[3], Float:trEnd[3], Float:damage)




public Shotgun_PrimaryAttack(id_owner, idx_weapon)
{

    Shotgun_PrimaryAttack2(id_owner, idx_weapon);
    return;

    client_print(0, print_chat, "shotgun fired");
    new Float: vecPunchangle[3];
    new i = 0;
    
    // vecPunchangle[0] += random_float(-0.3, 0.3)
    // vecPunchangle[1] += random_float(-0.3, 0.3)
    // set_pev(id_owner, pev_punchangle, vecPunchangle);
    new Float:f_origin[3], Float:endpoint[3];
    new Float:f_origin_traceto[3];
    new i_aim[3];
    new Float:f_aim[3];
    pev(id_owner, pev_origin, f_origin);
    f_origin[2]+=18.0;

    //f_origin[] - точка, откуда игрок смотрит
    //f_aim[] - точка через 35u от взгляда игрока
    get_user_origin(id_owner, i_aim, 3);
    IVecFVec(i_aim,f_aim);
    
    // new Float:fDistance = get_distance_f(f_origin, f_aim) //���
    // client_print(0, print_chat, "fDistance %f", fDistance)
    for (i=0 ; i < 6 ; i++)
    {   

        // ExecuteHam(Ham_Weapon_PrimaryAttack, idx_weapon) // тратит патроны, наносит урон.
        // set_pdata_float(idx_weapon, m_flNextPrimaryAttack, g_weapons[i][f_firerate1])

        // #define SHTGN_SPRD 30.0
        f_origin_traceto[0] = float(i_aim[0]) + random_float(-SHTGN_SPRD,SHTGN_SPRD);
        f_origin_traceto[1] = float(i_aim[1]) + random_float(-SHTGN_SPRD,SHTGN_SPRD);
        f_origin_traceto[2] = float(i_aim[2]) + random_float(-SHTGN_SPRD,SHTGN_SPRD);

        new ttres = create_tr2();
        engfunc(EngFunc_TraceLine, f_origin, f_origin_traceto, DONT_IGNORE_MONSTERS, id_owner, ttres);
        get_tr2(ttres, TR_vecEndPos, f_origin_traceto);
        new  Float:fraction;
        get_tr2(ttres, TR_flFraction, fraction);
        new hit = get_tr2(ttres, TR_pHit);
        
        if(hit> 0 && fraction != 1.0)
        {

            ExecuteHamB(Ham_TraceAttack, hit, id_owner, 200.0, f_origin_traceto, ttres, DMG_SLASH);
            // ExecuteHam(Ham_TraceAttack, idx_weapon, id_owner, 400.0, f_origin_traceto, ttres, DMG_BULLET);
            //draw_laser(f_origin, f_origin_traceto, 100)
        }
        
        else
        {
            //r_decal_index(ttres);
        }


        free_tr2(ttres);
        //client_print(0, print_chat, "HIT: %d FRACTION: %f", hit, fraction)
        
    }   
}


public Shotgun_PrimaryAttack2(id_owner, idx_weapon)
{

    client_print(0, print_chat, "shotgun fired2");
    new  Float: vecPunchangle[3];
    new i = 0;
    
    // vecPunchangle[0] += random_float(-0.3, 0.3)
    // vecPunchangle[1] += random_float(-0.3, 0.3)
    // set_pev(id_owner, pev_punchangle, vecPunchangle);
    new Float:f_origin[3], Float:endpoint[3];
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
    for (i=0 ; i < 3 ; i++)
    {   

        // ExecuteHam(Ham_Weapon_PrimaryAttack, idx_weapon) // тратит патроны, наносит урон.
        // set_pdata_float(idx_weapon, m_flNextPrimaryAttack, g_weapons[i][f_firerate1])

        
        f_origin_traceto[0] = float(i_aim[0]) + random_float(-SHTGN_SPRD,SHTGN_SPRD);
        f_origin_traceto[1] = float(i_aim[1]) + random_float(-SHTGN_SPRD,SHTGN_SPRD);
        f_origin_traceto[2] = float(i_aim[2]) + random_float(-SHTGN_SPRD,SHTGN_SPRD);

        new ttres = create_tr2();
        engfunc(EngFunc_TraceLine, f_origin, f_origin_traceto, DONT_IGNORE_MONSTERS, id_owner, ttres);
        get_tr2(ttres, TR_vecEndPos, f_origin_traceto);
        new  Float:fraction;
        get_tr2(ttres, TR_flFraction, fraction);
        new hit = get_tr2(ttres, TR_pHit);
        
        if(hit> 0 && fraction != 1.0)
        {
        
            ExecuteHamB(Ham_TraceAttack, hit, id_owner, 30.0, f_origin_traceto, ttres, DMG_BULLET);
            // ExecuteHam(Ham_TraceAttack, idx_weapon, id_owner, 400.0, f_origin_traceto, ttres, DMG_BULLET);
            draw_laser(f_origin, f_origin_traceto, 100);
        }
        
        else
        {
            // r_decal_index(ttres);
        }


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
    set_user_prt(id_owner, rocketindex);
    set_task(0.2, "rocket_tune", id_owner);
    return 1;
}

public rocket_tune(id_owner)
{
    new idx_rocket = get_user_ptr(id_owner);
    if (!is_valid_ent(idx_rocket))
    {
        return 0;
    }
    else
    {
        fm_attach_view(id_owner, idx_rocket);
        new clsname[32];
        pev(idx_rocket, pev_classname, clsname, 31);
        client_print(0, print_chat, "%s", clsname);
        new Float:fAngViev[3];

        // смена вида камера работает
        pev(id_owner, pev_angles, fAngViev);
        set_pev(idx_rocket, pev_angles, fAngViev);
        // вращение снаряда 
        /*
        pev(id_owner, pev_v_angle, fAngViev)
        set_pev(idx_rocket, pev_v_angle, fAngViev)
        */
        // set_pev(idx_rocket, pev_movetype, MOVETYPE_TOSS)
        // set_pev(idx_rocket, pev_nextthink, get_gametime() + 1.1)

        new Float:Thumble[3];
        Thumble[0] = random_float(-20.0, 20.0);
        Thumble[1] = random_float(-20.0, 20.0);
        Thumble[2] = random_float(-20.0, 20.0);

        set_pev(idx_rocket, pev_movetype, MOVETYPE_TOSS);
        set_pev(idx_rocket, pev_gravity, 1.0);
        set_pev(idx_rocket, pev_avelocity, Thumble);

        new Float:fVel[3];
        // velocity_by_aim(id, ROCKET_SPEED, fVel)	
        
        pev(idx_rocket, pev_velocity, fVel);
        fVel[0] *= 0.80;
        fVel[1] *= 0.80;
        fVel[2] *= 0.80;
        set_pev(idx_rocket, pev_velocity, fVel);
        
    }
    return 0;
}

public dod_rocket_explosion(id_owner, Float:pos[3], idx_wpn)  
{   
    fm_attach_view(id_owner, id_owner);
}

public fw_EmitSound(ent, iChannel, const szSample[], Float:fVolume, Float:fAttenuation, iFlags, iPitch) 
{
    
        EF_EmitSound(ent, iChannel, "weapons/sbarrel1.wav", fVolume, fAttenuation, iFlags, iPitch);
        return FMRES_SUPERCEDE;
}

stock get_user_ptr(id_owner)
{
    return g_user_ptr[id_owner];
}

stock set_user_prt(id_owner, prt)
{
    g_user_ptr[id_owner] = prt;
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

new Array: g_hDecals;

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

    iMessage = TE_WORLDDECAL;
    //iMessage = TE_GUNSHOTDECAL;
    
    if(iMessage == TE_GUNSHOT)
    {
        if(iHit>g_maxpl)
        {
            iDecalIndex=0; // problems with func_breakable decals for bullets, thats why need set ZERO
        } 
        
        MESSAGE_BEGIN(MSG_PAS, SVC_TEMPENTITY, vecEndPos, 0);
        WRITE_BYTE(iMessage);
        WRITE_COORD(vecEndPos[0]);
        WRITE_COORD(vecEndPos[1]);
        WRITE_COORD(vecEndPos[2]);
        WRITE_SHORT(iHit);
        WRITE_BYTE(iDecalIndex);
        MESSAGE_END();
        // quake PARTICEL SIMPLE
        /*
        MESSAGE_BEGIN(MSG_PAS, SVC_TEMPENTITY, vecEndPos, 0);
        WRITE_BYTE(TE_GUNSHOT);
        WRITE_COORD(vecEndPos[0]);
        WRITE_COORD(vecEndPos[1]);
        WRITE_COORD(vecEndPos[2]);
        MESSAGE_END();
        */
        
    }
    
    else if(iMessage == TE_WORLDDECAL)
    {   
        message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
        write_byte(TE_WORLDDECAL);
        engfunc(EngFunc_WriteCoord, vecEndPos[0]);
        engfunc(EngFunc_WriteCoord, vecEndPos[1]);
        engfunc(EngFunc_WriteCoord, vecEndPos[2]);
        write_byte(iDecalIndex);
        message_end();
    }

    else if(iMessage == TE_DECALHIGH)
    {   

        if(iHit != 0 && iDecalIndex != 0 )
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
    }
    client_print(0,print_chat,"IDecalIndex = %d, Ihit %d", iDecalIndex, iHit ) ;
}




bool:is_team_attack(attacker, victim)
{
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
    write_short(g_sprsmk);
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
public shell_pschreck_think(idx_rocket)
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
    new Float:fOrigin[3];
    client_print(idx_player, print_chat, "UNDERBARREL");
}