#include <amxmodx>
#include <dodx>

#define PLUGIN        "GOOD GAME SPRITE"
#define VERSION        "1.2"
#define AUTHOR        "Yek'-ta + MayroN"

#define SHOWTIME        10.0      // Время отображения спрайта на экране

#define HUD_HIDE_FLASH (1<<1)
#define HUD_HIDE_CROSS (1<<6)
#define HUD_DRAW_CROSS (1<<7)

#define CSW_SHIELD  2

#define SPRITE_GAME        "good_game_sprite/good_game"

new bool:bShowSprite[MAX_PLAYERS +1]

enum _:MESSAGES
{
        g_iMsg_WeaponList,
        g_iMsg_CurWeapon,
        g_iMsg_SetFOV,
        g_iMsg_HideWeapon,
        g_iMsg_Crosshair
}

new g_Messages[MESSAGES];

new g_Messages_Name[MESSAGES][] =
{
        "WeaponList",
        "CurWeapon",
        "SetFOV",
        "HideWeapon",
        "Crosshair"
}

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR)

    for(new i; i < sizeof g_Messages; i++)    {
        g_Messages[i] = get_user_msgid(g_Messages_Name[i]);
    }

    register_event("CurWeapon","comboHudGoster","be", "1=1");
    register_event("TeamInfo", "JoinTeam", "a");
}

public plugin_precache()
{
    precache_model(fmt("sprites/%s.spr", SPRITE_GAME));
    precache_generic(fmt("sprites/%s.txt", SPRITE_GAME));
}

public client_putinserver(id) 
{
    set_task(0.1, "task_Show", id);
}

public task_Show(id)
{
    bShowSprite[id] = true;
    set_task(SHOWTIME, "RemoveHUD", id);
    comboHudGoster(id);
}

public client_disconnected(id) 
{
    bShowSprite[id] = false;
    remove_task(id); 
}

public JoinTeam()
{
    new szTeam[2]; read_data(2, szTeam, charsmax(szTeam));

    if(szTeam[0] != 'S')
        return;

    new id = read_data(1);
    
    if(bShowSprite[id])
        set_task(0.1, "task_Repeat", id);
}

public task_Repeat(id)
{
    comboHudGoster(id);
}

public RemoveHUD(id)
{
    remove_task(id);
    bShowSprite[id] = false;
    Hide_NormalCrosshair(id, 0);
    show_crosshair(id, 0);
}

public comboHudGoster(id)
{
    if(!bShowSprite[id])
        return PLUGIN_HANDLED

    static userwpn, prim
    userwpn = get_user_weapon(id, prim)
    
    /*
    switch (userwpn)
    {
        case CSW_NONE: Msg_WeaponList(id, -1,-1);
        case CSW_P228: Msg_WeaponList(id, 9,52);
        case CSW_HEGRENADE: Msg_WeaponList(id, 12,1);
        case CSW_XM1014: Msg_WeaponList(id, 5,32);
        case CSW_C4: Msg_WeaponList(id, 14,1);
        case CSW_MAC10: Msg_WeaponList(id, 6,100);
        case CSW_AUG: Msg_WeaponList(id, 4,90);
        case CSW_SMOKEGRENADE: Msg_WeaponList(id, 13,1);
        case CSW_ELITE: Msg_WeaponList(id, 10,120);
        case CSW_FIVESEVEN: Msg_WeaponList(id, 7,100);
        case CSW_UMP45: Msg_WeaponList(id, 6,100);
        case CSW_GALIL: Msg_WeaponList(id, 4,90);
        case CSW_FAMAS: Msg_WeaponList(id, 4,90);
        case CSW_USP: Msg_WeaponList(id, 6,100);
        case CSW_GLOCK18: Msg_WeaponList(id, 10,120);
        case CSW_MP5NAVY: Msg_WeaponList(id, 10,120);
        case CSW_M249: Msg_WeaponList(id, 3,200);
        case CSW_M3: Msg_WeaponList(id, 5,32);
        case CSW_M4A1: Msg_WeaponList(id, 4,90);
        case CSW_TMP: Msg_WeaponList(id, 10,120);
        case CSW_FLASHBANG: Msg_WeaponList(id, 11,2);
        case CSW_DEAGLE: Msg_WeaponList(id, 8,35);
        case CSW_SG552: Msg_WeaponList(id, 4,90);
        case CSW_AK47: Msg_WeaponList(id, 2,90);
        case CSW_KNIFE:Msg_WeaponList(id, -1,-1);
        case CSW_P90: Msg_WeaponList(id, 7,100);
        case CSW_SCOUT: Msg_WeaponList(id, 2,90);
        case CSW_AWP: Msg_WeaponList(id, 1,30);
        case CSW_SG550: Msg_WeaponList(id, 4,90);
        case CSW_G3SG1: Msg_WeaponList(id, 2,90);
    }
    */
    Msg_WeaponList(id, 1,30);
    Msg_SetFOV(id, 89);
    Msg_CurWeapon(id, 1,DODW_AMERKNIFE,prim);
    Msg_SetFOV(id, 90);

    return PLUGIN_CONTINUE
}

stock Hide_NormalCrosshair(id, flag)
{
    if(flag == 1)
    {
        message_begin(MSG_ONE, g_Messages[g_iMsg_HideWeapon], _, id);
        write_byte(HUD_HIDE_CROSS | HUD_HIDE_FLASH);
        message_end();
    }
    else
    {
        message_begin(MSG_ONE, g_Messages[g_iMsg_HideWeapon], _, id);
        write_byte(HUD_DRAW_CROSS | HUD_HIDE_FLASH);
        message_end();
    }
}

stock show_crosshair(id, flag)
{
    message_begin(MSG_ONE_UNRELIABLE, g_Messages[g_iMsg_Crosshair], _, id);
    write_byte(flag);
    message_end();
}

stock Msg_CurWeapon(id, IsActive,WeaponID,ClipAmmo)
{
    message_begin(MSG_ONE,g_Messages[g_iMsg_CurWeapon], {0,0,0}, id);
    write_byte(IsActive);
    write_byte(WeaponID);
    write_byte(ClipAmmo);
    message_end();
}

stock Msg_WeaponList(id, PrimaryAmmoID,PrimaryAmmoMaxAmount)
{
    message_begin(MSG_ONE,g_Messages[g_iMsg_WeaponList], {0,0,0}, id);
    write_string(SPRITE_GAME);
    write_byte(PrimaryAmmoID);
    write_byte(PrimaryAmmoMaxAmount);
    write_byte(-1);
    write_byte(-1);
    write_byte(0);
    write_byte(11);
    write_byte(CSW_SHIELD);
    write_byte(0);
    message_end();
}

stock Msg_SetFOV(id, Degrees)
{
    message_begin(MSG_ONE,g_Messages[g_iMsg_SetFOV], {0,0,0}, id);
    write_byte(Degrees);
    message_end();
}