
#include <amxmodx>
#include <dodx>
#include <fakemeta>
#include <hamsandwich>
#include <engine>


new const weapon_sniperrifle[] = "weapon_scopedkar"


// Linux extra offsets
#define linux_diff_weapon 4
#define linux_diff_player 5
#define linux_diff_animation 4


#define m_pActiveItem 278 // notused here but can.
#define m_pClientActiveItem 279
#define m_iWeaponState 115		// IS BAZOOKA/PIAT/PSCHREK Shouldered

// spawn 
#define m_irdytospawn 354
#define m_imissedwave 355



#define m_iCurrentAnimationSequence 522
#define m_iObserverWeapon 372 // 

#define m_flFieldOfView 148 // 40.0 
#define m_iFOV 365
#define m_iClientFOV 269

#define m_fKnownItem 244


#define m_iMinimap 480 // -2 MO MAP ; -1 FULLMMAP + MINI MAP
#define m_iMapMarker 526 // -1 
#define m_iweapons 527 //
#define i_seenAxisSpawnScene 463
#define m_pPlayer 89 			// int returns owner's of weapon
#define CLP(%0) client_print(0 ,print_chat, %0)


new g_iMsg_HideWeapon, g_iMsg_Crosshair;
#define REMOVE_CROSSHAIR  0
#define HIDE_MONEY ( 1 << 5 )

public plugin_init() 
{
    register_plugin("DOD SNIPER LEARNING", "0.0", "America")

    // Ham Post
    RegisterHam(Ham_Item_UpdateItemInfo,  weapon_sniperrifle, "post_Ham_Item_UpdateItemInfo", 1) 
    RegisterHam(Ham_Weapon_SecondaryAttack, weapon_sniperrifle, "post_Ham_Weapon_SecondaryAttack", 1) 
    RegisterHam(Ham_DOD_Weapon_ZoomOut, weapon_sniperrifle, "post_DOD_Weapon_ZoomOut", 0 )
    RegisterHam(Ham_DOD_Weapon_ZoomIn, weapon_sniperrifle, "post_DOD_Weapon_ZoomIn", 0 )

    //register_event("HideWeapon","Event_HideWpn","b")	
    //register_event("SetFOV","Event_SetFOV","b")


    g_iMsg_HideWeapon = get_user_msgid( "HideWeapon" );
    g_iMsg_Crosshair  = get_user_msgid( "Crosshair"  ); 


    // 
    register_clcmd("say 1","idx_player_retune")
    register_clcmd("say 2","idx_player_retune2")
    register_clcmd("say 3","idx_player_retune3")
    register_clcmd("say 4","idx_player_retune4")
}


public plugin_precache()
{


precache_model("kurica.mdl")
}



public idx_player_retune(idx_player)
{   
    new idx_wpn = get_pdata_cbase(idx_player, m_pActiveItem, linux_diff_player);
    //ExecuteHam(Ham_DOD_Weapon_ZoomOut,idx_wpn); // правильно 
     ExecuteHamB(Ham_DOD_Weapon_ZoomIn,idx_wpn); // правильно 
    

}
public idx_player_retune2(idx_player)
{   
    new idx_wpn = get_pdata_cbase(idx_player, m_pActiveItem, linux_diff_player);

   // ExecuteHamB(Ham_DOD_Weapon_ChangeFOV, idx_player, 1); // не рабоатает


    
    // меняет FOV и меняет скорость.
    set_pdata_int(idx_player, m_iFOV, 89, 4)
    
     //set_pev(idx_player, pev_viewmodel,  "models/kurica.mdl")
    set_pev(idx_player, pev_viewmodel, "kurica.mdl")

    //set_pdata_int(idx_player, m_iClientFOV, -2, linux_diff_player) // что-то влияет


    //set_pev(idx_wpn, pev_model, "kurica.mdl");
    
    /*
    static g_scopetest;
    if (!g_scopetest)
		g_scopetest = get_user_msgid("Scope")

    message_begin(MSG_ONE,g_scopetest,{0,0,0},idx_player)
	write_byte(1)
	message_end()
    */

}

public idx_player_retune3(idx_player)
{   

    /// функция меня угол обзора , не меняет скорость передвижения

	static iMsgID_SetFOV;
   
	
	if (!iMsgID_SetFOV)
		iMsgID_SetFOV = get_user_msgid("SetFOV");

	message_begin(MSG_ONE, get_user_msgid("SetFOV"), _, idx_player);
	write_byte(60);
	message_end();



    //set_pev(idx_player, pev_viewmodel, "kurica.mdl")
    set_pev(idx_player, pev_viewmodel, "kurica.mdl")

    set_pdata_int(idx_player, m_iClientFOV, -2, linux_diff_player) // что-то влияет

    static g_scopetest;
    if (!g_scopetest)
		g_scopetest = get_user_msgid("Scope")

    message_begin(MSG_ONE,g_scopetest,{0,0,0},idx_player)
	write_byte(0)
	message_end()
}

public idx_player_retune4(idx_player)
{   
    new idx_wpn1 = get_pdata_cbase(idx_player, m_pActiveItem, linux_diff_player);

    // new idx_wpn = get_pdata_cbase(idx_player, m_iObserverWeapon, linux_diff_player); -1 

    new idx_wpn = get_pdata_cbase_safe(idx_player, m_iCurrentAnimationSequence, linux_diff_player);
    // set_pdata_cbase(idx_player, i_seenAxisSpawnScene, 1, linux_diff_player);


    server_print("idx player %d , idx weapon = %d , iobserver  = %d ", idx_player , idx_wpn1, idx_wpn  )
}


public post_Ham_Item_UpdateItemInfo()
{
    CLP("Ham_Item_UpdateItemInfo")
}

public post_Ham_Weapon_SecondaryAttack()
{
    CLP("Ham_Weapon_SecondaryAttack")
}


public post_DOD_Weapon_ZoomIn(idx_wpn)
{
     CLP("post_DOD_Weapon_ZoomIn")
}




public post_DOD_Weapon_ZoomOut(idx_wpn)
{
    
     CLP("post_DOD_Weapon_ZoomOut")


    new id_owner = get_pdata_cbase(idx_wpn, m_pPlayer, linux_diff_weapon);
    
    new idx_wpn = get_pdata_cbase(id_owner, m_iObserverWeapon, 5);
    CLP("obeserwer idx weapon = %d", idx_wpn)
}

/*
public client_PreThink(pPlayer)
{
    // чем медленне бежит , тем прозрачней 
    if(!is_user_alive(pPlayer))
        return;

    static Float: fVecVelocity[3];
    entity_get_vector(pPlayer, EV_VEC_velocity, fVecVelocity);

    new idx_wpn1 = get_pdata_cbase(pPlayer, m_pActiveItem, linux_diff_player);

    set_rendering(
        .index      = idx_wpn1,
        .fx         = kRenderFxNone,
        .render     = kRenderTransAlpha,
        .amount     = max( 20, floatround(vector_length(fVecVelocity)))
    );
}
*/

public Event_HideWpn(const id) 
{
         // set_pev(id,pev_iuser2, 89) 
    //set_pev(id, pev_viewmodel, "kurica.mdl")
   set_pev(id, pev_viewmodel, "kurica.mdl")
        /*
         message_begin(MSG_ONE_UNRELIABLE,get_user_msgid("Crosshair"),_,id)
        write_byte(1)
        message_end
        */
        /*
        message_begin( MSG_ONE, g_iMsg_HideWeapon, _, id );
        write_byte( HIDE_MONEY );
        message_end();
    */
        /*
        message_begin( MSG_ONE, g_iMsg_Crosshair, _, id );
        write_byte( REMOVE_CROSSHAIR );
        message_end();
    */

		return PLUGIN_HANDLED

}


public Event_SetFOV(const idx_player) {

   //   set_pev(id, pev_viewmodel, "kurica.mdl")
set_pev(idx_player, pev_viewmodel, "kurica.mdl")
     /*
    message_begin(MSG_ONE_UNRELIABLE,get_user_msgid("Crosshair"),_,id)
    write_byte(1)
    message_end
    */
    /*
        message_begin( MSG_ONE, g_iMsg_HideWeapon, _, id );
        write_byte( HIDE_MONEY );
        message_end();
*/
        /*
        message_begin( MSG_ONE, g_iMsg_Crosshair, _, id );
        write_byte( REMOVE_CROSSHAIR );
        message_end();
        */
        
		return PLUGIN_HANDLED
}

