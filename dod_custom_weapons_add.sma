#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fun>
#include <hamsandwich>
#include <fakemeta>
#include <dodx>
#include <dodfun>

new idx_cweapon
new DODCW_ID
#define CWEAPON_NAME "weapon_mortar"

public plugin_init()
{
    register_plugin("DOD ADD CW" , "0.0" , "America")
    register_clcmd("say /cw", "cw_run") 
}

public cw_run(idx_player)
{
    strip_user_weapons(idx_player)

    //Add Custom Weapon Support
	DODCW_ID = custom_weapon_add("Custom LogNameW",0 , CWEAPON_NAME)
    if (DODCW_ID < 0)
    {
        server_print("*** Ошибка создания кастомного оружия")
        return PLUGIN_HANDLED
    }
    server_print("*** new custom weapond created: %d", DODCW_ID)

    // give_item(idx_player, CWEAPON_NAME)  хуйня пока не сработала 


    // Create new primary weapon entity
    idx_cweapon = engfunc(EngFunc_CreateNamedEntity,engfunc(EngFunc_AllocString, CWEAPON_NAME))
    if (idx_cweapon < 0)
    {
        server_print("*** 2 Ошибка создания кастомного оружия")
        return PLUGIN_HANDLED
    }
    server_print("*** 2 new custom weapond created: %d", idx_cweapon)

    if(pev_valid(idx_cweapon))
        {
            server_print("*** 3 new custom weapond created: %d", idx_cweapon)

            // Set entity position
            new Float: origin[3]
            pev(idx_player, pev_origin, origin)
            engfunc(EngFunc_SetOrigin, idx_cweapon , origin)

            set_pev(idx_cweapon, pev_spawnflags, SF_NORESPAWN)
            // Spawn the entity
            dllfunc(DLLFunc_Spawn,idx_cweapon)

            entity_set_int(idx_cweapon, EV_INT_spawnflags, SF_NORESPAWN);
            ExecuteHam(Ham_Spawn, idx_cweapon);
            ExecuteHamB(Ham_Item_AttachToPlayer, idx_player, idx_cweapon);


            set_pev(idx_player, pev_viewmodel2 , "models/v_bar.mdl")
            // Установка количества патронов
            set_pdata_int(idx_cweapon, 51, 10); // 51 - m_iClip, 10 - количество патронов

            // Выдача оружия игроку
            engclient_cmd(idx_player, "use", CWEAPON_NAME);



            RegisterHam(Ham_Weapon_PrimaryAttack,	CWEAPON_NAME,	"CWEAPON_NAME_attack_P", true);
            RegisterHam(Ham_Item_PostFrame, CWEAPON_NAME, "CWEAPON_NAME_attack_P");

        }
}

public CWEAPON_NAME_attack_P()
{
    server_print("*** 4 attack registered")

}
/*
    // Make sure entity was created
    if(pev_valid(temp_weapon_entity))
    {
    // Check to see if weapon chosen is scoped enfield or scoped fg42 and make scoped if it is
    if(weapon_class_id == 32 || weapon_class_id == 35)
    set_pdata_int(temp_weapon_entity,115,1,4) // Set entity scope flag true

    // Set entity position
    new Float:origin[3]
    pev(id,pev_origin,origin)
    engfunc(EngFunc_SetOrigin,temp_weapon_entity,origin)

    // Required as stated in HLSDK - Prevents two guns from showing (weaponbox)
    set_pev(temp_weapon_entity,pev_spawnflags,SF_NORESPAWN)

    // Spawn the entity
    dllfunc(DLLFunc_Spawn,temp_weapon_entity)

    // Store weapon entity ID for use with blocking other weapon entities
    client_chosen_weapon_id[id] = temp_weapon_entity

    // Decrement a weapon change from the client's counter
    client_gun_changes[id]--
        
    // Set client chose a weapon for use with blocking other guns on the ground
    client_block_state[id] = 1

    // Grab HL timestamp for determining the next time this client can get another gun
    client_give_timer[id] = get_gametime() + get_pcvar_float(p_weapon_delay)

    // Set that this client has chosen a weapon from the weapons mod. Used for calculating active classes.
    client_give_switch[id] = 1

    // Store client's last given class as the class chosen from the weapons mod. Used for calculating active classes.
    client_last_given_class[id] = client_chosen_class[id]

    // Set the client's last spawn class to the chosen weapon from the weapons mod. We
    // do this so the correct class counts are made when a player respawns after using
    // the weapons mod. Essentially we are just injecting the weapons mod given class
    // into the spawn class count handler to save un-needed coding.
    client_last_spawn_class[id] = client_chosen_class[id]




  public give_weapon(id)
  {
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

*/