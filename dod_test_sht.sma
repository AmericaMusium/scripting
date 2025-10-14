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

new g_idx_weapon;
new g_sprsmk;
new g_HamForwardPrAtt;
new g_HamForwardPrAtt2;

public plugin_init()
{   
    // Register Event / Signals
    register_event("CurWeapon", "CurWeapon_Post_Check", "be", "1=1");
    g_HamForwardPrAtt = RegisterHam(Ham_Weapon_PrimaryAttack,	"weapon_mp40",	"Ham_Weapon_PrimaryAttack_Post2", 1);
    g_HamForwardPrAtt2 = RegisterHam(Ham_Weapon_PrimaryAttack,	"weapon_mp40",	"Ham_Weapon_PrimaryAttack_Post", 1);

    server_print("FORWARDS %d, %d", g_HamForwardPrAtt, g_HamForwardPrAtt2);

    register_clcmd("say rr", "Run_Attack_Synth");
}

// Precache required files
public plugin_precache()
{
    //upload_ini()   
    g_sprsmk = precache_model("sprites/smoke_ia.spr");
}

public Ham_Weapon_PrimaryAttack_Post(idx_wpn) 
{   
    client_print(0, print_chat, "Ham_Weapon_PrimaryAttack_Post");
    return HAM_SUPERCEDE;
}


public CurWeapon_Post_Check(id_owner)
{	
    // Запускается каждый раз при Event(CurWeapon)
    
    new idx_weapon = get_pdata_cbase(id_owner, m_pActiveItem, linux_diff_player);
    //set_pdata_float(idx_weapon, m_flNextPrimaryAttack, 1.2, linux_diff_weapon);
    g_idx_weapon = idx_weapon;

}

public Run_Attack_Synth(idx_player)
{   
    // Вызывает только звук рикошета, тратит патрон
    ExecuteHam(Ham_Weapon_PrimaryAttack, g_idx_weapon);
    // Выполняет трассировку + Damage + Decals
    PrimaryAttack_Shotgun2(idx_player);

    set_pev(idx_player, pev_sequence, 74);
    emit_sound(idx_player, CHAN_WEAPON, "weapons/mp44_shoot.wav", 1.0, ATTN_NORM, 0, PITCH_NORM);
    muzzle_flash( idx_player ); //вылетает на мазлфлеше
    ExecuteHam(Ham_Weapon_SendWeaponAnim, idx_player, 1, 1, 1);
}

muzzle_flash( idx_player ) {
	set_pev( idx_player, pev_effects, pev(idx_player, pev_effects) | EF_MUZZLEFLASH );
}


public PrimaryAttack_Shotgun2(id_owner)
{   
    // Run_Attack_Synth(id_owner);
    new Float:SHTGN_SPRD = 10.0;
    new idx_weapon = g_idx_weapon;
    client_print(0, print_chat, "shotgun fired2");
    new  Float: vecPunchangle[3];
    new i = 0;

    new Float:f_origin[3], Float:endpoint[3];
    new Float:f_origin_traceto[3];
    new i_aim[3];
    new Float:f_aim[3];
    pev(id_owner, pev_origin, f_origin);
    f_origin[2]+=8.0;

    //f_origin[] - точка, откуда игрок смотрит
    //f_aim[] - точка через 35u от взгляда игрока вперёд
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
        
        draw_laser(f_origin, f_origin_traceto, 100);
        if(hit> 0 && fraction != 1.0)
        {
        
            ExecuteHamB(Ham_TraceAttack, hit, id_owner, 30.0, f_origin_traceto, ttres, DMG_BULLET);
            // ExecuteHam(Ham_TraceAttack, idx_weapon, id_owner, 400.0, f_origin_traceto, ttres, DMG_BULLET);
            
        }
        
        else
        {
            r_decal_index(ttres);
        }


        free_tr2(ttres);
        //client_print(0, print_chat, "HIT: %d FRACTION: %f", hit, fraction)
        
    }   
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
        if(iHit>32)
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


public  Ham_Weapon_PrimaryAttack_Post2(g_idx_weapon)
{
    client_print(0,print_chat,"Ham_Weapon_PrimaryAttack_Post2");
    DisableHamForward(g_HamForwardPrAtt2);
    DisableHamForward(g_HamForwardPrAtt);
}