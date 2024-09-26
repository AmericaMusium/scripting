
#include <amxmodx>
#include <amxmisc>
#include <orpheu>
#include <engine>
#include <fakemeta>
#include <xs>
#include <orpheu_memory>
#include <hamsandwich>
#include <fakemeta>
#include <dodx>
#include <dodfun>


// Linux extra offsets
#define linux_diff_weapon 4
#define linux_diff_player 5
#define m_pPlayer 89 	// int returns weapon's owner
#define m_pActiveItem 278 // notused here but can.
#define m_iFOV 365

new OrpheuFunction:ThinkZoomIn;
new OrpheuFunction:ThinkZoomOut;
new OrpheuFunction:BounceTouch;

new OrpheuFunction:CreateEntity

new idx_w = 0

new idx_cdata = 0

public plugin_precache()
{
    // ThinkZoomIn = OrpheuGetFunction( "ThinkZoomIn", "CBasePlayerWeapon" );
    ThinkZoomIn = OrpheuGetFunction( "ThinkZoomIn", "CBasePlayerWeapon" );
    OrpheuRegisterHook( ThinkZoomIn , "Or_Hook_ThinkZoomIn_P", OrpheuHookPre );
    server_print("OrpheuFunction:ThinkZoomIn::CBasePlayerWeapon id:%d", ThinkZoomIn)
    register_clcmd("say ThinkZoomIn","Or_Call_ThinkZoomIn")

    ThinkZoomOut = OrpheuGetFunction( "ThinkZoomOut", "CBasePlayerWeapon" );
    OrpheuRegisterHook( ThinkZoomOut , "Or_Hook_ThinkZoomOut_P", OrpheuHookPre );
    server_print("OrpheuFunction:ThinkZoomOut::CBasePlayerWeapon id:%d", ThinkZoomOut)
    register_clcmd("say ThinkZoomOut","OR_Call_ThinkZoomOut")

    /*
    register_forward( FM_UpdateClientData, "fw_UpdateClientData_Post", 1 );
    register_forward(FM_AddToFullPack, "addToFullPack", 1)
    */
    
    /*
    BounceTouch = OrpheuGetFunction( "BounceTouch", "CGrenade" );
    OrpheuRegisterHook( BounceTouch , "Or_Hook_BounceTouch_P", OrpheuHookPre );
    */
    server_print("OrpheuFunction:BounceTouch::CGrenade id:%d", BounceTouch)


    CreateEntity = OrpheuGetEngineFunctionsStruct()
    server_print("CreateEntity:CreateEntity::CreateEntity id:%d", CreateEntity)



}


public plugin_init ()
{
    register_plugin( "Set Team Score", "1.0.0", "Arkshine" );

}

public Or_Hook_ThinkZoomIn_P(idx_weapon)
{   

    // returns idx_weapon
    server_print("OrpheuFunction:ThinkZoomIn::CBasePlayerWeapon | idx_weapon = %d", idx_weapon)
    idx_w = idx_weapon
    //OrpheuSetReturn( false );
    return OrpheuSupercede; // BLOCKIN THIS EVENT
}

public Or_Call_ThinkZoomIn(id)
{   
    OrpheuCall( ThinkZoomIn , idx_w)
}


public Or_Hook_ThinkZoomOut_P(idx_weapon)
{      
    server_print("OrpheuFunction:ThinkZoomOut_Post::CBasePlayerWeapon | idx_weapon = %d", idx_weapon)
}

public OR_Call_ThinkZoomOut(idx_player)
{
    OrpheuCall( ThinkZoomOut , idx_w)
}

public Or_Hook_BounceTouch_P(idx)
{   
}


// To adjust View Offset

public fw_UpdateClientData_Post(id, sendweapons, cd_handle)
{
    if (id == 1)
    {


	//set_cd( cd_handle, CD_ViewOfs, fNewView );
    // set_cd( cd_handle, CD_FOV, 35.0 );

	///ADD 
	// set map as v_model O_o  WORKS !!
	// set_cd( cd_handle, CD_ViewModel, 1 ); 
    if(idx_cdata < 128)
    {
        set_cd( cd_handle, CD_ViewModel, idx_cdata ); 
        idx_cdata++ 
        client_print(0, print_chat, "i_model  %d", idx_cdata)
    }
    else 
    {
        idx_cdata = 0
    }


	// change only Z-point of view //
	/*
    new Float:fNewView[3];
    fNewView[1] = 296.0
	fNewView[2] = 96.0
	set_cd( cd_handle, CD_ViewOfs, fNewView );
   
    new cls_name[32]
    pev(id, pev_classname, cls_name, 31)
    client_print(0, print_chat, "%s", cls_name)
     */
    }
}



/////////////////////////////
public addToFullPack(es, e, iEntity, iHost, iHostFlags, iPlayer, pSet)
{   
    if(!is_valid_ent(iEntity))
    {
        return 0;
    }

    new item_classname[32]
    pev(iEntity, pev_classname, item_classname, 31) 
    if(!(equali(item_classname, "player")))
    {
        return 0;
    }

    set_es(es, ES_FOV, 35.0)

}