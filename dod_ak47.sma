#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <engine>
#include <xs>
#include <dodx>
#include <dodfun>
 
#define CustomItem(%0) (entity_get_int(%0, EV_INT_impulse) == WEAPON_KEY)
#define get_bit(%1,%2)   ((%1 & (1 << (%2 & 31))) ? true : false)
#define set_bit(%1,%2)    %1 |= (1 << (%2 & 31))
#define reset_bit(%1,%2) %1 &= ~(1 << (%2 & 31))
#define IsConnected(%0) (1<=%0<=g_MaxPlayers && get_bit(g_connect, %0))
 
#define m_rgpPlayerItems_CWeaponBox  34
#define m_pPlayer                    41
#define m_pNext                      42
#define m_flNextSecondaryAttack      47
#define m_iShell                     57
#define m_flNextAttack               83
#define m_flEjectBrass               111
#define m_rpgPlayerItems             367
#define m_rpgPlayerItems0            368
#define m_pActiveItem                373
 
#define WEAPON_KEY 4354
#define WEAPON_OLD "weapon_m1carbine"
#define WEAPON_NEW "weapon_ak88"
#define WEAPON_EVENT "events/fg42.sc"


#define OFFSET_WPN_ID			91
#define OFFSET_WPN_CLIP 		108
#define OFFSET_PISTOL_BPAMMO_LINUX	52
#define OFFSET_PISTOL_BPAMMO_WIN32	53
#define OFFSET_LINUX 			4
 
new const WEAPON_SOUNDS[][] = {
   "weapons/akm_clipin.wav",
   "weapons/akm_clipout.wav",
   "weapons/akm_draw.wav"
}
new const WEAPON_SPITES[][] = {
   "sprites/akm/640hud7.spr",
   "sprites/akm/640hud31.spr"
}
 
// - - - - - - - - - - ÌÎÄÅËÈ / - - - - - - - - - - 
#define WEAPON_MODEL_V "models/red/v_aug2.mdl"
#define WEAPON_MODEL_P "models/red/p_aug2.mdl"
#define WEAPON_MODEL_W "models/red/w_aug2.mdl"
#define WEAPON_MODEL_S "models/axis_gibs.mdl"
#define WEAPON_SOUND_S "weapons/garand_clipeject.wav"
 
// - - - - - - - - - - ÍÀÑÒÐÎÉÊÈ / - - - - - - - - - - 
#define WEAPON_RATE   0.09
#define WEAPON_DAMAGE 1.3
#define WEAPON_RECOIL 0.8
#define WEAPON_CLIP   30
#define WEAPON_AMMO   120
 
#define WEAPON_AKGOLD_COST 6000
#define WEAPON_AMMO_COST 200
// - - - - - - - - - - ÍÀÑÒÐÎÉÊÈ / - - - - - - - - - - 
 
new g_connect, g_MaxPlayers, g_shell, g_event, g_fw_index
 
public plugin_init() {
        register_plugin("[Z]Weapon: AKM Gold (Scar)", "0.1", "batcon");
   RegisterHam(Ham_Item_Deploy, WEAPON_OLD, "fw_Item_Deploy_Post", 1);
   RegisterHam(Ham_Weapon_Reload, WEAPON_OLD, "fw_Weapon_Reload_Post", 1);
   RegisterHam(Ham_Weapon_PrimaryAttack, WEAPON_OLD, "fw_Weapon_PrimaryAttack");
   RegisterHam(Ham_Item_AddToPlayer, WEAPON_OLD, "fw_Item_AddToPlayer_Post", 1);
    
   RegisterHam(Ham_TraceAttack, "func_breakable", "fw_TraceAttack");
   RegisterHam(Ham_TraceAttack, "hostage_entity", "fw_TraceAttack");
   RegisterHam(Ham_TraceAttack, "player", "fw_TraceAttack");
    
   RegisterHam(Ham_TraceAttack, "func_breakable", "fw_TraceAttack_Post", 1);
   RegisterHam(Ham_TraceAttack, "func_wall", "fw_TraceAttack_Post", 1);
   RegisterHam(Ham_TraceAttack, "func_door", "fw_TraceAttack_Post", 1);
   RegisterHam(Ham_TraceAttack, "func_plat", "fw_TraceAttack_Post", 1);
   RegisterHam(Ham_TraceAttack, "func_rotating", "fw_TraceAttack_Post", 1);
   RegisterHam(Ham_TraceAttack, "worldspawn", "fw_TraceAttack_Post", 1);
    
   RegisterHam(Ham_Spawn, "weaponbox", "fw_Spawn_Weaponbox_Post", 1);
    
   unregister_forward(FM_PrecacheEvent, g_fw_index, 1);
    
   register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1);
   register_forward(FM_SetModel, "fw_SetModel");
   register_forward(FM_PlaybackEvent, "fw_PlaybackEvent");
    
   g_MaxPlayers = get_maxplayers();
    
   state WeaponBox_Disabled;
    
   register_clcmd(WEAPON_NEW, "hook_weapon");
   register_clcmd("buyammo1", "clcmd_buyammo");
   
   
   
   register_clcmd("say ak1", "give_scar1");
   register_clcmd("say ak2", "give_weapon");
 
   //register_clcmd("give_ak_test", "give_test");
 
}
public plugin_precache() {
   static buffer[64], i;
   engfunc(EngFunc_PrecacheModel, WEAPON_MODEL_V);
   engfunc(EngFunc_PrecacheModel, WEAPON_MODEL_P);
   engfunc(EngFunc_PrecacheModel, WEAPON_MODEL_W);
   g_shell = engfunc(EngFunc_PrecacheModel, WEAPON_MODEL_S);
   engfunc(EngFunc_PrecacheSound, WEAPON_SOUND_S);
   for(i = 0; i < sizeof WEAPON_SOUNDS;i++) engfunc(EngFunc_PrecacheSound, WEAPON_SOUNDS[i]);
   for(i = 0; i < sizeof WEAPON_SPITES;i++) engfunc(EngFunc_PrecacheGeneric, WEAPON_SPITES[i]);
   format(buffer, charsmax(buffer), "sprites/%s.txt", WEAPON_NEW);
   engfunc(EngFunc_PrecacheGeneric, buffer);
   g_fw_index = register_forward(FM_PrecacheEvent, "fw_PrecacheEvent_Post", 1);
}
public client_putinserver(id) set_bit(g_connect, id);
public client_disconnect(id) reset_bit(g_connect, id);
public hook_weapon(id) engclient_cmd(id, WEAPON_OLD);
 
/*public give_test(id) {
   UTIL_DropWeapon(id, 1);
   if(!give_weapon(id)) return;
   emit_sound(id, CHAN_ITEM, "items/gunpickup2.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
   static amount; amount = GetAmmoDifference(id, CSW_AK47, WEAPON_AMMO)
   if(amount) {
      AmmoPickup_Icon(id, 4, WEAPON_CLIP, amount);
           cs_set_user_bpammo(id, CSW_AK47, WEAPON_AMMO);
   }
}*/
 
  
public give_scar1(id) {
   if(!is_user_alive(id)) return PLUGIN_HANDLED;

 
   UTIL_DropWeapon(id, 1);
   if(!give_weapon(id)) return PLUGIN_HANDLED;
   
   
   emit_sound(id, CHAN_ITEM, "items/gunpickup2.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
   static amount; amount = GetAmmoDifference(id, CSW_AK47, WEAPON_AMMO)
  

   return PLUGIN_HANDLED;
}

public give_weapon(id) {
   new ent = create_entity(WEAPON_OLD);
   if(!is_valid_ent(ent)) return false;
   entity_set_int(ent, EV_INT_spawnflags, SF_NORESPAWN);
   entity_set_int(ent, EV_INT_impulse, WEAPON_KEY);
   ExecuteHam(Ham_Spawn, ent);
   if(!ExecuteHamB(Ham_AddPlayerItem, id, ent)) {
      entity_set_int(ent, EV_INT_flags, FL_KILLME);
      return true;
   }
   ExecuteHamB(Ham_Item_AttachToPlayer, ent, id);
   return true;
}
public fw_Item_Deploy_Post(ent) {
   if(!CustomItem(ent)) return HAM_IGNORED;
   static id; id = get_pdata_cbase(ent, m_pPlayer, 4);
   entity_set_string(id, EV_SZ_viewmodel, WEAPON_MODEL_V);
   entity_set_string(id, EV_SZ_weaponmodel, WEAPON_MODEL_P);
   UTIL_PlayWeaponAnimation(id, 2); //Fix draw anim
   set_pdata_float(id, m_flNextAttack, 1.1, 5);
   return HAM_IGNORED;
}
public fw_Weapon_Reload_Post(ent) {
   if(!CustomItem(ent)) return HAM_IGNORED;
   set_pdata_float(get_pdata_cbase(ent, m_pPlayer, 4), m_flNextAttack, 2.9, 5);
   return HAM_IGNORED;
}
public fw_Weapon_PrimaryAttack(ent) {
   if(!CustomItem(ent)) return HAM_IGNORED;
   ExecuteHam(Ham_Weapon_PrimaryAttack, ent);
   static id; id = get_pdata_cbase(ent, m_pPlayer, 4);
   emit_sound(id, CHAN_WEAPON, WEAPON_SOUND_S, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
   UTIL_PlayWeaponAnimation(id, 3);
   set_pdata_float(ent, m_flNextSecondaryAttack, WEAPON_RATE, 4);
   static Float:Punchangle[3]; entity_get_vector(id, EV_VEC_punchangle, Punchangle);
   xs_vec_mul_scalar(Punchangle, WEAPON_RECOIL, Punchangle);
   entity_set_vector(id, EV_VEC_punchangle, Punchangle);
   set_pdata_int(ent, m_iShell, g_shell, 4);
   set_pdata_float(id, m_flEjectBrass, get_gametime(), 5);
   return HAM_SUPERCEDE;
}
public fw_Item_AddToPlayer_Post(ent, id) {
   switch(entity_get_int(ent, EV_INT_impulse)) {
      case 0: UTIL_Weaponlist(id, WEAPON_OLD, 2, 90, 0, 1, CSW_AK47, 0);
      case WEAPON_KEY: UTIL_Weaponlist(id, WEAPON_NEW, 2, WEAPON_AMMO, 0, 1, CSW_AK47, 0);
   }
}
public fw_TraceAttack(entity, attacker, Float:damage) {
         if(!IsConnected(attacker) || !CustomItem(get_pdata_cbase(attacker, m_pActiveItem, 5))) return HAM_IGNORED;
         SetHamParamFloat(3, damage * WEAPON_DAMAGE);
         return HAM_IGNORED;
}
public fw_TraceAttack_Post(entity, attacker, Float:damage, Float:fDir[3], ptr, damagetype) {
         if(!CustomItem(get_pdata_cbase(attacker, m_pActiveItem, 5))) return HAM_IGNORED;
         static Float:vecEnd[3]; get_tr2(ptr, TR_vecEndPos, vecEnd);
    engfunc(EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, vecEnd, 0);
         write_byte(TE_GUNSHOTDECAL);
    engfunc(EngFunc_WriteCoord, vecEnd[0]);
         engfunc(EngFunc_WriteCoord, vecEnd[1]);
         engfunc(EngFunc_WriteCoord, vecEnd[2]);
         write_short(entity);
         write_byte(random_num(41, 45));
         message_end();
         return HAM_IGNORED;
}
public fw_Spawn_Weaponbox_Post(ent) {
   if(is_valid_ent(ent))
      state (is_valid_ent(entity_get_edict(ent, EV_ENT_owner))) WeaponBox_Enabled;
}
public fw_UpdateClientData_Post(id, SendWeapons, CD_Handle) {
        if(!is_user_alive(id) || !CustomItem(get_pdata_cbase(id, m_pActiveItem, 5))) return FMRES_IGNORED;
        set_cd(CD_Handle, CD_flNextAttack, 999999.0);
        return FMRES_HANDLED;
}
public fw_SetModel(entity) <WeaponBox_Enabled>
{
   state WeaponBox_Disabled;
   if(!is_valid_ent(entity)) return FMRES_IGNORED;
    
   static i;
   for(i = 0; i < 6; i++) {
      static item; item = get_pdata_cbase(entity, m_rgpPlayerItems_CWeaponBox + i, 4);
      if(is_valid_ent(item) && CustomItem(item)) {
         entity_set_model(entity, WEAPON_MODEL_W);
         return FMRES_SUPERCEDE;
      }
   }
   return FMRES_IGNORED;
}
public fw_SetModel() <WeaponBox_Disabled>
{
   return FMRES_IGNORED;
}
public clcmd_buyammo(id) {
   if(!is_user_alive(id)) return PLUGIN_CONTINUE;
   static weapon; weapon = get_pdata_cbase(id, m_rpgPlayerItems0, 5);
        if(!is_valid_ent(weapon) || !CustomItem(weapon)) return PLUGIN_CONTINUE;
   static ammo;
   new clip2
   new wpnids =  dod_get_user_weapon(id, clip2, ammo);
   
   static amount; amount = min(WEAPON_CLIP, WEAPON_AMMO-ammo);
   UTIL_AmmoPickup(id, 4, amount);
   
   emit_sound(id, CHAN_ITEM, "items/9mmclip1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
   return PLUGIN_HANDLED;
}
public fw_PrecacheEvent_Post(type, name[]) {
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
stock UTIL_PlayWeaponAnimation(id, Sequence) {
   entity_set_int(id, EV_INT_weaponanim, Sequence);
   message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, _, id);
        write_byte(Sequence);
        write_byte(0);
        message_end();
}
stock UTIL_DropWeapon(id, slot) {
        if(!(1 <= slot <= 2)) return 0;
        static iCount; iCount = 0;
        static iEntity; iEntity = get_pdata_cbase(id, (m_rpgPlayerItems + slot), 5);
        if(iEntity > 0) {
               static iNext;
               static szWeaponName[32];
        
               do{
	       	
		new clipg, ammog
		new wpnid = dod_get_user_weapon(id, clipg, ammog)
		new wpnent = dod_get_weapon_ent(id, wpnid)
	
                       iNext = get_pdata_cbase(iEntity, m_pNext, 4);
                       if(get_weaponname(wpnent, szWeaponName, charsmax(szWeaponName))) {  
                               engclient_cmd(id, "drop", szWeaponName);
                               iCount++;
             }
               } while(( iEntity = iNext) > 0);
   }
        return iCount;
}
stock UTIL_Weaponlist(id, weaponlist[], int, int2, int3, int4, int5, int6) {
   static msg_WeaponList; if(!msg_WeaponList) msg_WeaponList = get_user_msgid("WeaponList");
   message_begin(MSG_ONE, msg_WeaponList, _, id);
   write_string(weaponlist);
   write_byte(int);
   write_byte(int2);
   write_byte(-1);
   write_byte(-1);
   write_byte(int3);
   write_byte(int4);
   write_byte(int5);
   write_byte(int6);
   message_end();
}
stock UTIL_AmmoPickup(id, AmmoID, Amount) {
   static msg_AmmoPickup; if(!msg_AmmoPickup) msg_AmmoPickup = get_user_msgid("AmmoPickup");
   message_begin(MSG_ONE_UNRELIABLE, msg_AmmoPickup, _, id);
   write_byte(AmmoID);
   write_byte(Amount);
   message_end();
}
stock UTIL_BlinkAcct(id, BlinkAmt) { 
   static msg_BlinkAcct; if(!msg_BlinkAcct) msg_BlinkAcct = get_user_msgid("BlinkAcct");
   message_begin(MSG_ONE_UNRELIABLE, msg_BlinkAcct, _, id);
   write_byte(BlinkAmt);
   message_end();
}
stock AmmoPickup_Icon(id, AmmoID, Clip, Amount) {
   static i, count; count = floatround(Amount*1.0/Clip, floatround_floor);
   static AmountAmmo; AmountAmmo = 0;
   for(i=0;i<count;i++) {
      UTIL_AmmoPickup(id, AmmoID, Clip);
      AmountAmmo+=Clip;
   }
   static RestAmmo; RestAmmo = Amount-AmountAmmo;
   if(RestAmmo) UTIL_AmmoPickup(id, AmmoID, RestAmmo);
}
stock GetAmmoDifference(id, csw, amount) {
   new ammo = 1
   amount = 8
   return amount-ammo;
}

stock dod_get_weapon_ent(id,wpnid)
{
	new ent = -1,entid

	new Float:origin[3]
	entity_get_vector(id,EV_VEC_origin,origin)
	
	while((ent = find_ent_in_sphere(ent,origin,0.4)) != 0)
			
		{
		if(is_valid_ent(ent))
			{
			entid = get_pdata_int(ent,OFFSET_WPN_ID,OFFSET_LINUX)
			
			if(wpnid == entid)
				return ent
			}
		}
		
	return 0
}
