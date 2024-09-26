
#include <amxmodx>
#include <dodx>
#include <fakemeta>
#include <hamsandwich>
#include <engine>

// m_pszSavedWeaponModel проверить
BXINT_modelindex = entity_get_int(ent,EV_INT_modelindex)

new g_msgCurWeapon, g_msgScreenFade, g_msgScreenShake, g_msgAmmoX

new const sz_v_mdl[] = "models/v_mp40.mdl"
new idx_v_mdl = 0
new g_rifle_ptr = 0

#define WEAPON_NAME "weapon_scopedkar"
#define WEAPON_EVENT "events/weapons/scopedkar.sc"
#define m_pPlayer 89 			// int returns owner's of weapon
#define HIDEHUD_WEAPONS (1<<0)


#define IsConnected(%0) (1<=%0<=g_MaxPlayers && get_bit(g_connect, %0))
#define get_bit(%1,%2)   ((%1 & (1 << (%2 & 31))) ? true : false)
#define set_bit(%1,%2)    %1 |= (1 << (%2 & 31))
#define reset_bit(%1,%2) %1 &= ~(1 << (%2 & 31))

new g_event
new g_fw_index
new g_connect, g_MaxPlayers

public plugin_init() 
{
    register_plugin("DOD SNIPER LEARNING", "0.0", "America")

    register_clcmd("say 1","idx_player_retune")
    register_clcmd("say 2","change_FOV1") // change FOV method
    register_clcmd("say 3","change_FOV2")  // change FOV method 2
    register_clcmd("say 4","show_weapon_model")  // change FOV method 2


    g_msgCurWeapon 	= get_user_msgid( "CurWeapon" );
	g_msgScreenFade	= get_user_msgid( "ScreenFade" );
	g_msgScreenShake= get_user_msgid( "ScreenShake" );
	g_msgAmmoX	= get_user_msgid( "AmmoX" );


    ////
    RegisterHam(Ham_Item_Deploy, "weapon_scopedkar", "fw_Item_Deploy_Post", 1);
    

    unregister_forward(FM_PrecacheEvent, g_fw_index, 1);
    register_forward(FM_PlaybackEvent, "fw_PlaybackEvent");




    // Регистрация функций Ham Sandwich
    RegisterHam(Ham_Item_Deploy, "weapon_scopedkar", "Weapon_Deploy_Post", 1);
    RegisterHam(Ham_Item_CanHolster, "weapon_scopedkar", "Weapon_CanHolster_Post", 1);
    RegisterHam(Ham_Item_Holster, "weapon_scopedkar", "Weapon_Holster_Post", 1);
    RegisterHam(Ham_Item_UpdateItemInfo, "weapon_scopedkar", "Weapon_UpdateItemInfo_Post", 1);

}


public plugin_precache()
{
    idx_v_mdl = precache_model(sz_v_mdl)
    server_print("idx v_mdl %d", idx_v_mdl)
    // precache_model("models/garand.mdl")
    g_fw_index = register_forward(FM_PrecacheEvent, "fw_PrecacheEvent_Post", 1);
}

public idx_player_retune(idx_player)
{     
    set_pev(idx_player, pev_viewmodel2, sz_v_mdl)
    entity_set_string(idx_player, EV_SZ_viewmodel ,sz_v_mdl)


    //set_pev( idx_player, pev_viewmodel, 1 );
    message_begin(MSG_ONE, g_msgCurWeapon, {0, 0, 0}, idx_player)
    write_byte(1)
    write_byte(10)                                       // ID SPRITE GUN + CROSSHAIR   20 = m1carbine
    write_byte(5)                                      // this must change spprites but it now works in DOD , that's why I use next 
    message_end()
    UTIL_PlayWeaponAnimation(idx_player, 3)
}
 
public change_FOV1(idx_player)
{    
    new m_iFOV = 365 // offset cbaseplayer  
    set_pdata_int(idx_player, m_iFOV, 89, 4)


    UTIL_PlayWeaponAnimation(idx_player, 3)
}

public change_FOV2(idx_player)
{   
	static iMsgID_SetFOV;
	if (!iMsgID_SetFOV)
		iMsgID_SetFOV = get_user_msgid("SetFOV");

	message_begin(MSG_ONE, get_user_msgid("SetFOV"), _, idx_player);
	write_byte(89);
	message_end();

    UTIL_PlayWeaponAnimation(idx_player, 3)
}




public fw_PrecacheEvent_Post(type, name[]) 
{
   if(equal(WEAPON_EVENT, name)) {
      g_event = get_orig_retval();
      return FMRES_HANDLED;
   }
   return FMRES_IGNORED;
}

public fw_PlaybackEvent(flags, invoker, eventid, Float:delay, Float:origin[3], Float:iangles[3], Float:fparam1, Float:fparam2, iParam1, iParam2, bParam1, bParam2) {
   if(eventid != g_event || !IsConnected(invoker)) return FMRES_IGNORED;
   playback_event(flags | FEV_HOSTONLY, invoker, eventid, delay, origin, iangles, fparam1, fparam2, iParam1, iParam2, bParam1, bParam2);
   return FMRES_SUPERCEDE;
}


stock UTIL_PlayWeaponAnimation(id, Sequence)
{
    entity_set_int(id, EV_INT_weaponanim, Sequence);
    message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, _, id);
    write_byte(Sequence);
    write_byte(0);
    message_end();
}


public fw_Item_Deploy_Post(ent)
{
   static idx_player

   idx_player = get_pdata_cbase(ent, m_pPlayer, 4);
   entity_set_string(idx_player, EV_SZ_viewmodel ,sz_v_mdl)
   UTIL_PlayWeaponAnimation(idx_player, 2); //Fix draw anim
   return HAM_IGNORED;
}



// Функции обратного вызова для каждого события
public Weapon_Deploy_Post(id, retrun_bool) 
{
    server_print("Weapon_Deploy called for entity %d bool: %d", id , retrun_bool);
    return PLUGIN_CONTINUE;
}

public Weapon_CanHolster_Post(id) {
    server_print("Weapon_CanHolster called for entity %d", id);
    return PLUGIN_CONTINUE;
}

public Weapon_Holster_Post(id) {
    server_print("Weapon_Holster called for entity %d", id);
    return PLUGIN_CONTINUE;
}

public Weapon_UpdateItemInfo_Post(id) {
    server_print("Weapon_UpdateItemInfo called for entity %d", id);
    return PLUGIN_CONTINUE;
}


public show_weapon(idx_player)
{
    new g_msgHideWeapon
    new g_msgSetFOV

    // Изменяем FOV обратно на значение по умолчанию (90)
    g_msgSetFOV = get_user_msgid("SetFOV")
    message_begin(MSG_ONE, g_msgSetFOV, { 0, 0, 0 }, idx_player)
    write_byte(90)
    message_end()

    // Отправляем сообщение HideWeapon с параметром 0 для отображения модели оружия
    g_msgHideWeapon = get_user_msgid("HideWeapon")      
    message_begin(MSG_ONE, g_msgHideWeapon, { 0, 0, 0 }, idx_player)
    write_byte(0)                                   
    message_end()
}
/*
	 * Description:		Deploys the entity (usually a weapon).
	 *					This function has different version for the following mods:
	 *						Sven-Coop 5.0+, see Ham_SC_Item_Deploy instead.
	 * Forward params:	function(this);
	 * Return type:		Integer (boolean).
	 * Execute params:	ExecuteHam(Ham_Item_Deploy, this);
	 
	Ham_Item_Deploy,
	
	 * Description:		Whether or not the entity can be holstered.
	 *					This function has different version for the following mods:
	 *						Sven-Coop 5.0+, see Ham_SC_Item_CanHolster instead.
	 * Forward params:	function(this);
	 * Return type:		Integer (boolean).
	 * Execute params:	ExecuteHam(Ham_Item_CanHolster, this);

	Ham_Item_CanHolster,


	 * Description:		Whether or not the entity (usually weapon) can be holstered.
	 * Forward params:	function(this)
	 * Return type:		Integer (boolean).
	 * Execute params:	ExecuteHam(Ham_Item_Holster, this);
	
	Ham_Item_Holster,


	 * Description:		Updates the HUD info about this item.
	 * Forward params:	function(this);
	 * Return type:		None.

	Ham_Item_UpdateItemInfo
    */

public show_weapon_model(idx_player)
{
    new g_msgHideWeapon
    new g_msgSetFOV

    /*
    // Изменяем FOV обратно на значение по умолчанию (90)
    g_msgSetFOV = get_user_msgid("SetFOV")
    message_begin(MSG_ONE, g_msgSetFOV, { 0, 0, 0 }, idx_player)
    write_byte(90)
    message_end()
    */

    // Отправляем сообщение HideWeapon с параметром 0 для отображения модели оружия
    g_msgHideWeapon = get_user_msgid("HideWeapon")      
    message_begin(MSG_ONE, g_msgHideWeapon, { 0, 0, 0 }, idx_player)
    write_byte(0)                                   
    message_end()

    // Получаем текущее значение m_iHideHUD
    new hide_hud = get_pdata_int(idx_player, 265);

    // Снимаем флаг HIDEHUD_WEAPONS
    hide_hud &= ~HIDEHUD_WEAPONS;

    // Устанавливаем новое значение m_iHideHUD
    set_pdata_int(idx_player, 265, hide_hud);

    client_print(idx_player, print_chat , " %d flags hud ", hide_hud)
}


public client_PostThink(id) {


     if (!is_user_alive(id)) {
        return;
    }
    
    new iFOV = 35;
    if (iFOV != 90) {
        set_pev(id, pev_fov, float(iFOV));
    }
}


public hide_weapon_model(id)
{
    // Получаем текущее значение gHUD.m_iHideHUDDisplay
    new hud_flags = get_pdata_int(id, 125, 5)

    // Устанавливаем флаг HIDEHUD_WEAPONS
    hud_flags |= HIDEHUD_WEAPONS

    // Устанавливаем новое значение gHUD.m_iHideHUDDisplay
    set_pdata_int(id, 125, hud_flags, 5)
}


