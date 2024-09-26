#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>
#include <fakemeta_util>
#include <fun>
#include <dodx>
#include <dodfun>
#include <dodconst>
#include <dodstats>
#include <dod_stocks>
#include <hamsandwich>


#define eDirection          4

#define eTurnAngle          0
#define eEngineForce        1
#define eGear               2
#define eVelocity_x         3
#define eVelocity_y         4
#define eVelocity_z         5
#define eJumpForce          6
#define eLastTime           7
#define eNextSoundTime      9
#define eNextPitchTime      10
//#define fm_drop_to_floor(%1) engfunc(EngFunc_DropToFloor,%1) 
// #define client_printcolor(%1 , %2) client_print( %1 , print_chat, %2)

// set_pev(idowner, pev_viewmodel2, WEAPON_MODEL_VIEW);
// mydata
new const WEAPON_MODEL_VIEW[] = "models/red/tiger/v_tiger_shit.mdl";
new const WEAPON_MODEL_PLAYER[] = "models/red/tiger/rc_tiger.mdl";
new const WEAPON_MODEL_WORLD[] = "models/red/tiger/rc_tiger.mdl";
new const RC_SOUND_ENGINE[] = "ambience/waterfall3.wav"
new const RC_SOUND_SHOOT[] = "ambience/aa3.wav"
new safeOrigin[3] = { -1500.0, -1500.0, -1500.0 }
new saveOrigin[33][3];
new CamMode[33];
new Float:TankAngleH[33];

//////
const OFFSET_CSMENUCODE = 205
 
new boom
new Pev_Value[33]
new dSavages[33][5], Float:fSavages[33][11],
    Float:Accel, Float:MaxForce,
    Float:MaxGrip, Float:Drag, Gravity,
    g_iItem, g_countTanks[33],
    g_idTank[33], g_idCamera[33],
    bool:g_bIsSvgMenuOpened[33], bool:g_isSpawningTank[33],
    bool:g_bHasSpawned[33]
 
new g_pCvarAccel,
    g_pCvarMaxForce,
    g_pCvarMaxGrip,
    g_pCvarDrag,
    g_pCvarChaseCam,
    g_pCvarMinDistance,
    g_pCvarMaxDistance,
    g_pCvarSavageCarHP,
    g_pCvarSavageDamage,
    g_pCvarSavageRadius,
    g_pCvarSavageKnockback

new g_pBeam[33]
new g_AlreadyBought[33];
new iTeamLimit;
public plugin_precache()
{
    precache_model(WEAPON_MODEL_WORLD)  // For the camera
    precache_model(WEAPON_MODEL_VIEW)
    precache_sound(RC_SOUND_ENGINE)
    precache_sound(RC_SOUND_SHOOT)
    boom = precache_model("sprites/explosion1.spr")
}
 
public plugin_init()
{
    register_plugin("RC Monster Trcuk", "3.00", "K-OS")
    register_event("HLTV", "event_round_start", "a", "1=0", "2=0")
    RegisterHam(Ham_Killed,"player", "fw_Killed_Post", 1)
   
    register_think("savage", "savage_think")
    register_think("camera", "camera_think")
 
    register_clcmd("say /rc", "OpenSavageMenu")
    // register_clcmd("say /rc", "SpawnSavage")
    
 //   register_clcmd("say /scount", "Count")
 
    g_pCvarAccel = register_cvar("zp_savage_accel", "7500")
    g_pCvarMaxForce = register_cvar("zp_savage_maxforce", "500.0")
    g_pCvarMaxGrip = register_cvar("zp_savage_maxgrip", "2.0")
    g_pCvarDrag = register_cvar("zp_savage_drag", "2.0")
    g_pCvarChaseCam = register_cvar("zp_savage_chasecam", "1")
    g_pCvarMinDistance = register_cvar("zp_savage_min_distance", "20.0")
    g_pCvarMaxDistance = register_cvar("zp_savage_max_distance", "500.0")
    g_pCvarSavageCarHP = register_cvar("zp_savage_health", "1200.0")
    g_pCvarSavageDamage = register_cvar("zp_savage_damage", "1300")
    g_pCvarSavageRadius = register_cvar("zp_savage_radius", "1000.0")
    g_pCvarSavageKnockback = register_cvar("zp_savage_knockback", "1000.0")
   
    
}
 
public fw_Killed_Post(victim_id, attacker_id)
{
    if (g_bHasSpawned[victim_id])
        RemoveSavages(victim_id)
}
 
public Ham_SavageTakeDamage_Pre(victim_id, inflictor_id, attacker_id, Float:fDamage, iDamageBits)
{
    static szNameCheck[32]
    pev(victim_id, pev_classname, szNameCheck, charsmax(szNameCheck))
    if (!equal("savage", szNameCheck))
        return HAM_IGNORED
	
    if(!is_user_connected(victim_id))
    return HAM_IGNORED;
    if(!is_user_connected(attacker_id))
    return HAM_IGNORED;
    
    if (pev(victim_id, pev_iuser1) == attacker_id)
        return HAM_SUPERCEDE
 
    return HAM_IGNORED
}
 
public Ham_SavageTakeDamage_Post( victim_id, inflictor_id, attacker_id, Float:fDamage, iDamageBits)
{
    static szNameCheck[32]
    pev(victim_id, pev_classname, szNameCheck, charsmax(szNameCheck))
    if (!equal("savage", szNameCheck))
        return HAM_IGNORED
 
    if (pev(victim_id, pev_health) <= 0.0)
    {
        new ownerid = pev(victim_id, pev_owner)
        DamageNearby(ownerid)
        // client_printcolor(ownerid, "!y[!gZP!y] Your RC Car Got !tDestroyed")
        client_print(ownerid, print_chat,"Your RC Car Got Destroyed")
        return HAM_IGNORED
    }
 
    return HAM_IGNORED
}


public zp_extra_item_selected(id, itemid)
{
    if (itemid != g_iItem)
        return
    g_AlreadyBought[id]++
    iTeamLimit++
    g_countTanks[id] += 1
    OpenSavageMenu(id)
}
 
public Count(id)
{
    client_print(id, print_chat, "%d %d %d %d", g_countTanks[id], g_isSpawningTank[id], g_bHasSpawned[id], g_bIsSvgMenuOpened[id])
}
 
public OpenSavageMenu(id)
{
    new iMenu = menu_create("Savage Menu: ", "SavageMenu_Handler")
    menu_additem(iMenu, "Spawn RC From Extra Items", "")
 
    if (g_bHasSpawned[id])
    menu_additem(iMenu, "Return RC", "")
    else
    menu_additem(iMenu, "2Return RC", "")
    //menu_additem(iMenu, "Switch Pov", "")
    // client_printcolor(id, "Press 1 to start and AWSD to control")
    client_print(id, print_chat,"Press 1 to start and AWSD to control")
    if (is_user_alive(id))
    {
        if(g_countTanks[id])
    {
        g_bIsSvgMenuOpened[id] = true
        g_isSpawningTank[id] = true
        SpawnFakeSavage(id)
        set_pdata_int(id, OFFSET_CSMENUCODE, 0)
        menu_setprop(iMenu, MPROP_EXIT, MEXIT_ALL)
        menu_display(id, iMenu, 0)
    }
    }
    if(!g_countTanks[id])
    {
   	if(g_AlreadyBought[id] < 1)
	{   
        /*
        new dummy, weapon = get_user_weapon( id, dummy, dummy );
        new points = dod_get_user_ammo( id, weapon )
        points = 500
		if(points > 20)
		{
		    g_countTanks[id]++
		    g_AlreadyBought[id]++
		}
        */
        g_countTanks[id]++
		g_AlreadyBought[id]++
	}
   }
		
}
 
public SavageMenu_Handler(id, iMenu, iItem)
{
    if (!is_user_alive(id))
        return	
 
    if (!g_countTanks[id])
    {
        // client_printcolor(id, "!y[!gZP!y] You don't any remote cars.")
        client_print(id, print_chat," You don't any remote cars")
        return
    }
 
    if (iItem == MENU_EXIT)
    {
        g_bIsSvgMenuOpened[id] = false
        g_isSpawningTank[id] = false
        g_bHasSpawned[id] = false
        RemoveSavages(id)
        menu_destroy(iMenu)
        return
    }
   
    switch (iItem)
    {
        case 0:
        {
	   SpawnSavage(id)
        }
        case 1:
        {
            if (g_bHasSpawned[id])
                TakeSavageBack(id)
            else
                client_print(id, print_chat," You haven't spawned any remote cars")
        }
    }
 
    g_bIsSvgMenuOpened[id] = false
    menu_destroy(iMenu)
}
 
public event_round_start()
{
    new iEntity = FM_NULLENT
    iTeamLimit = 0
    while ((iEntity = engfunc(EngFunc_FindEntityByString, iEntity, "classname", "savage")) != 0)
    engfunc(EngFunc_RemoveEntity, iEntity)
    for (new id = 1; id <= get_maxplayers(); id++)
    {
    if (!is_user_connected(id))
    continue
 
    g_idTank[id] = g_idCamera[id] = FM_NULLENT
    g_countTanks[id] = 0
    g_AlreadyBought[id] = 0
    g_isSpawningTank[id] = g_bHasSpawned[id] = false
    }
}

/* remove Round_Restart
public zp_fw_core_infect_post(id, attacker_id)
{
    if (is_user_connected(id))
        RemoveSavages(id)
}
*/

TakeSavageBack(id)
{
    if (!is_user_alive(id) )
        return PLUGIN_CONTINUE
 
    if (!g_bHasSpawned[id])
    {
      
        client_print(id, print_chat," You haven't spawned any remote cars")
        RemoveSavages(id)
        return PLUGIN_HANDLED
    }
 
    RemoveSavages(id)
    g_countTanks[id] += 1
    g_isSpawningTank[id] = false
    client_print(id, print_chat," You took your Remote car bacs")
    return PLUGIN_CONTINUE
}
 
public SpawnFakeSavage(id)
{
    if (!is_user_alive(id))
        return PLUGIN_HANDLED
 
    if (pev_valid(g_idTank[id]) || !g_bIsSvgMenuOpened[id] || g_bHasSpawned[id])
    {
        g_bHasSpawned[id] = false
        DestroySavage(id)
        remove_preview(id)
    }
 
    new iEntity = CreateSavage(id)
 
    if (!pev_valid(iEntity))
        return PLUGIN_HANDLED

    
    /*
    new pBeam = Beam_Create("sprites/laserbeam.spr", 6.0);
    if (pBeam != FM_NULLENT)
    {	
    Beam_EntsInit(pBeam, iEntity, id);
    Beam_SetColor(pBeam, Float:{0.0, 150.0, 0.0});
    Beam_SetScrollRate(pBeam, 255.0);
    Beam_SetBrightness(pBeam, 200.0);
    }
    else
    {
    pBeam = 0;
    }

    g_pBeam[id] = pBeam;
    */

    if (CheckEntityDistance(iEntity, id) > get_pcvar_num(g_pCvarMinDistance))
    {
    //    set_pev(iEntity, pev_rendercolor, Float:{ 255.0, 0.0, 0.0 })
    set_pev(iEntity, pev_rendermode, kRenderTransAdd)
    set_pev(iEntity, pev_renderamt, 200.0);
    }
    else
    {
        set_pev(iEntity, pev_rendermode, kRenderTransAdd); set_pev(iEntity, pev_renderamt, 200.0);
    }
    return PLUGIN_HANDLED
}
 
CreateSavage(id)
{
    static func_breakable_id
 
    if (!func_breakable_id)
        func_breakable_id = engfunc(EngFunc_AllocString, "func_breakable")
 
    new iEntity = engfunc(EngFunc_CreateNamedEntity, func_breakable_id)
 
    if (!pev_valid(iEntity))
        return FM_NULLENT
 
//    dllfunc(DLLFunc_Spawn, iEntity)
 
    if (!id)
        return iEntity
    new Float:StartAngle[3]
    pev(id, pev_angles, StartAngle)

    set_pev(iEntity, pev_classname, "savage")
    set_pev(iEntity, pev_owner, id)
    engfunc(EngFunc_SetModel, iEntity, WEAPON_MODEL_WORLD)
    engfunc(EngFunc_SetSize, iEntity, {-4.0, -4.0, 0.0}, {4.0, 4.0, 4.0})
    set_pev(iEntity, pev_solid, SOLID_NOT)
    set_pev(iEntity, pev_movetype, MOVETYPE_PUSHSTEP)
    set_pev(iEntity, pev_frame, 1)
    set_pev(iEntity, pev_sequence, 0)
    set_pev(iEntity, pev_framerate, 1)
    set_pev(iEntity, pev_takedamage, 0.0)
    set_pev(iEntity, pev_controller_0, 125)
    set_pev(iEntity, pev_controller_1, 125)
    set_pev(iEntity, pev_controller_2, 125)

    set_pev(iEntity, pev_renderfx, kRenderFxGlowShell)
    set_pev(iEntity, pev_renderamt, 5.0)
    set_pev(iEntity, pev_v_angle, StartAngle)
    set_pev(iEntity, pev_angles, StartAngle)
    
    CheckEntityPosition(iEntity, id)
    g_idTank[id] = iEntity
    return iEntity
}
 
SpawnSavage(id)
{
    if (!is_user_alive(id) )
        return PLUGIN_CONTINUE
   
    new TankEnt = g_idTank[id]
 
    if (!pev_valid(TankEnt))
        return PLUGIN_HANDLED
 
    if (!pev(TankEnt, pev_iuser2))
    {
        engfunc(EngFunc_RemoveEntity, TankEnt)
        // client_printcolor(id, "!y[!gZP!y] You can't place Remote car here.")
        client_print(id, print_chat,"You can't place Remote car her")
        
    //  SpawnFakeSavage(id)	
        remove_preview(id)
        set_task(0.1,"OpenSavageMenu", id)
        return PLUGIN_HANDLED
    }
 
    set_pev(TankEnt, pev_framerate, 0.0)
    set_pev(TankEnt, pev_solid, SOLID_NOT)
    set_pev(TankEnt, pev_movetype, MOVETYPE_PUSHSTEP )
    set_pev(TankEnt, pev_friction, 0.5)
    set_pev(TankEnt, pev_gravity, 1.0)
    set_pev(TankEnt, pev_takedamage, 1.0)
    engfunc(EngFunc_SetSize, TankEnt, Float:{-200.0, -200.0, -80.0},{200.0, 200.0, 1.0})
    set_pev(TankEnt, pev_health, get_pcvar_float(g_pCvarSavageCarHP))
    set_pev(TankEnt, pev_sequence, 0)
    set_pev(TankEnt, pev_framerate, 0)
    set_pev(TankEnt, pev_framerate, 20.0)
    set_pev(TankEnt, pev_frame, 0)
    // set_pev(TankEnt, pev_body, random_num(2, 12));
    g_countTanks[id] -= 1
    g_bHasSpawned[id] = true
    g_isSpawningTank[id] = false
    remove_preview(id)
 
    RegisterHamFromEntity(Ham_TakeDamage, TankEnt, "Ham_SavageTakeDamage_Pre", false)
    RegisterHamFromEntity(Ham_TakeDamage, TankEnt, "Ham_SavageTakeDamage_Post", true)
   
    new Float:StartAngle[3]
    pev(id, pev_angles, StartAngle)
    //StartAngle[1] = 270.0
    //StartAngle[0] = 90.0 //get_pcvar_float(g_pcvarSavageAngel)
    StartAngle[0] = 0.0
    set_pev(TankEnt, pev_angles, StartAngle)
    set_pev(TankEnt, pev_v_angle, StartAngle)
    set_pev(TankEnt, pev_nextthink, halflife_time() + 0.01)
   
    if (get_pcvar_num(g_pCvarChaseCam))
    {
        new CamEnt = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
 
        if (!pev_valid(CamEnt))
            return PLUGIN_HANDLED
 
        g_idCamera[id] = CamEnt
       
        set_pev(CamEnt, pev_classname, "camera")
        set_pev(CamEnt, pev_owner, id)
        set_pev(CamEnt, pev_rendermode, kRenderTransColor)
        engfunc(EngFunc_SetModel, CamEnt, WEAPON_MODEL_WORLD)
        set_pev(CamEnt, pev_solid, SOLID_NOT)
        set_pev(CamEnt, pev_movetype, MOVETYPE_NOCLIP)
        set_pev(CamEnt, pev_angles, StartAngle)
   
        new Float:StartOrigin[3], Float:Angle = StartAngle[1] / 180 * M_PI
        pev(id, pev_origin, StartOrigin)
        StartOrigin[0] -= floatcos(Angle) * 110
        StartOrigin[1] -= floatsin(Angle) * 110
        StartOrigin[2] += 140
        set_pev(CamEnt, pev_origin, StartOrigin)
        set_pev(CamEnt, pev_nextthink, halflife_time() + 0.05)

        /// go to camera
        attach_view(id, TankEnt)

    }
   
    new Float:time = halflife_time()
    fSavages[id][eLastTime] = time
    fSavages[id][eNextSoundTime] = time
    fSavages[id][eNextPitchTime] = time
 
    Accel = get_pcvar_float(g_pCvarAccel)
    MaxForce = get_pcvar_float(g_pCvarMaxForce)
    MaxGrip = get_pcvar_float(g_pCvarMaxGrip)
    MaxGrip *= MaxGrip
    Drag = get_pcvar_float(g_pCvarDrag)
    if (MaxGrip > 1.0)  MaxGrip = 1.0
    if (Drag > 1.0) Drag = 1.0
   
    Gravity = get_cvar_num("sv_gravity")
    // set_user_maxspeed(id, 250.0)

    set_rendering(TankEnt)
    //fm_drop_to_floor(TankEnt)
    //g_bHasSpawned[id] = true
    // new szName[32]
   //  get_user_name(id, szName, charsmax(szName))
    // ColorChat(0,GREEN,"^03 %s ^01 Spawned a ^04 Race Car", szName)
    // client_printcolor(0, "!y[!gZP!y] !g%s !ySpawned Race Car", szName)
    client_print(0, print_chat,"Spawned Tank")
    
    
    new tempOri[3];
    pev(id, pev_origin, tempOri)
    saveOrigin[id][0] = tempOri[0]
    saveOrigin[id][1] = tempOri[1]
    saveOrigin[id][2] = tempOri[2]

    set_pev(id, pev_origin, safeOrigin)
    

    return PLUGIN_HANDLED
}
 
public client_PreThink(id)
{
    if (!is_user_alive(id) )
        return
    if(!pev_valid(g_idTank[id]))
        return
 
    if (pev(id, pev_button) & IN_ATTACK && g_bHasSpawned[id] && !g_bIsSvgMenuOpened[id] && g_idTank[id])
        client_print( id, print_chat, "Fire from Tank! ") 

    if (pev(id, pev_button) & IN_ATTACK2 && g_bHasSpawned[id] && !g_bIsSvgMenuOpened[id] && g_idTank[id])
        client_print( id, print_chat, "2 Fire from Tank! ") 
        
    if (g_isSpawningTank[id] && g_bIsSvgMenuOpened[id])
        UpdateEntityPosition(id)
    
    if (pev(id, pev_button) & IN_DUCK && g_bHasSpawned[id] && !g_bIsSvgMenuOpened[id] && g_idTank[id])
        DamageNearby(g_idTank[id])

    if (pev(id, pev_button) & IN_USE && g_bHasSpawned[id] && !g_bIsSvgMenuOpened[id] && g_idTank[id])
        CameraSwitchView(id)
    
   
   

    if(pev_valid(g_idTank[id]) && pev_valid(id) && (CamMode[id] == 1))
    
    {   
        /////////// SHOW PLAYER ANGLE /// RECIVE RETUNE 
    // new Float:fAngA[3]
    // pev(id, pev_angles, fAngA)
    new Float:fAngB[3]
    pev(id, pev_v_angle, fAngB)
    //fAngB[0] *= -1.0
    client_print(id, print_center, "HORIZONT ANGLE: %i ", (-1*floatround(fAngB[0]))  )
    // client_print(id, print_center, "A0:%i  A1: %i | B0:%i  B1: %i", floatround(fAngA[0]) , floatround(fAngA[1]) , floatround(fAngB[0]) , floatround(fAngB[1])  )
    
    new Float: hudy
    hudy = (fAngB[0] + 90.0 ) / 180.0
	// ВЕРХ == 0.0 , центр == 0,5 . 1.0 == полный низ. 
    set_hudmessage(130, 40, 10, 0.2, hudy , 0, 0.8, 0.4, 0.1, 0.1, -1)
	show_hudmessage(id, " xxx %f", fAngB[0] )

    }
    

   
    // set_pdata_int(id,365, 44, OFFSET_LINUX) // SET FOV 
    ////////////

}
 
DamageNearby(iEntity)
{
    static Float:origin[3], Float:originVictim[3]
    pev(iEntity, pev_origin, origin)
    new ownerid = pev(iEntity, pev_owner)
    
    if (!pev_valid(g_idTank[ownerid]))
	return;	

    new Text[34]
    new Float:distance_diff, victim = -1
    while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, origin, get_pcvar_float(g_pCvarSavageRadius))) != 0)
    {
        if (!is_user_connected(victim))
            continue
 
        if (!is_user_alive(victim))
            continue
 
        pev(victim, pev_origin, originVictim)
        distance_diff = get_distance_f(origin, originVictim)
 
        if (get_user_health(victim) > 0)
        {
            new current_damage = get_pcvar_num(g_pCvarSavageDamage) - floatround(distance_diff)
            format(Text, charsmax(Text) - 1, "%s", current_damage)
            // ExecuteHam(Ham_TakeDamage, victim, iEntity, ownerid, (get_pcvar_float(g_pCvarSavageDamage) - distance_diff), DMG_GRENADE)
            Set_Knockback(victim, origin, (get_pcvar_float(g_pCvarSavageKnockback) - distance_diff))
            // bd_show_text(ownerid, ownerid, Text, 12)
        }
        else
            ExecuteHam(Ham_Killed, victim, ownerid)
    }
    DestroySavage(ownerid, true)
}
 
Set_Knockback(ent, Float:VicOrigin[3], Float:speed)
{
    static Float:fl_Velocity[3]
    static Float:EntOrigin[3]
   
    pev(ent, pev_origin, EntOrigin)
    static Float:distance_f
    distance_f = get_distance_f(EntOrigin, VicOrigin)
   
    new Float:fl_Time = distance_f / speed
   
    fl_Velocity[0] = ((EntOrigin[0] - VicOrigin[0]) / fl_Time) * 1.5
    fl_Velocity[1] = ((EntOrigin[1] - VicOrigin[1]) / fl_Time) * 1.5
    fl_Velocity[2] = (EntOrigin[2] - VicOrigin[2]) / fl_Time
   
    set_pev(ent, pev_velocity, fl_Velocity)
}
 
public client_disconnect(id)
{
    DestroySavage(id)
}
 
DestroySavage(id, bool:effect = false)
{
    if (pev_valid(g_idCamera[id]))
    {
        if (is_user_alive(id))
        set_pev(id, pev_origin, saveOrigin[id])
        attach_view(id, id)
        engfunc(EngFunc_RemoveEntity, g_idCamera[id])
        g_idCamera[id] = -1
        remove_preview(id)
    }
    if (effect)
    {
        if (!pev_valid(g_idTank[id]))
            return
 
        new Float:vOrigin[3]
        pev(g_idTank[id], pev_origin, vOrigin)
        message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
        write_byte(3)
        write_coord(floatround(vOrigin[0]))
        write_coord(floatround(vOrigin[1]))
        write_coord(floatround(vOrigin[2] + 10))
        write_short(boom)
        write_byte(40)
        write_byte(15)
        write_byte(0)
        message_end()
    }
 
    if (pev_valid(g_idTank[id]))
    {
        emit_sound(g_idTank[id], CHAN_VOICE, RC_SOUND_SHOOT , VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
        engfunc(EngFunc_RemoveEntity, g_idTank[id])
        g_idTank[id] = -1
    }

    g_bHasSpawned[id] = false
}
 
RemoveSavages(id)
{
    if (!is_user_connected(id))
        return
 
    DestroySavage(id)
}
 
public savage_think(TankEnt)
{
    new idowner = pev(TankEnt, pev_owner)
 
    if (!is_user_alive(idowner))
    {
        RemoveSavages(idowner)
        return
    }
       
    new Float:FrameTime = (halflife_time() - fSavages[idowner][eLastTime])
    fSavages[idowner][eLastTime] = halflife_time()
       
    new Float:vOrigin[3]
    pev(TankEnt, pev_origin, vOrigin)
 
    // Health handling
    if (pev(TankEnt, pev_health) < 0.0)
    {
        DestroySavage(idowner, true)
        client_print(idowner, print_center, "Your Car got destroyed")
        return
    }
   
    new Float:vVelocity[3]
    pev(TankEnt, pev_velocity, vVelocity)
   
    // That stupid collision box gets stuck behind every little bump , so force it to keep moving
    vVelocity[0] = fSavages[idowner][eVelocity_x] * 0.8 + vVelocity[0] * 0.2
    vVelocity[1] = fSavages[idowner][eVelocity_y] * 0.8 + vVelocity[1] * 0.2
   
    // Input handling
    new buttonpress = 0
    if (g_idCamera[idowner] && g_idTank[idowner])
        buttonpress = pev(idowner, pev_button)
   
    new Float:EngineForce = fSavages[idowner][eEngineForce]
    new Float:TurnAngle = fSavages[idowner][eTurnAngle]
    new Float:BrakeForce = 0.0
    new Float:JumpForce = fSavages[idowner][eJumpForce]

    // set_pev(idowner, pev_viewmodel2, WEAPON_MODEL_VIEW);
   
    if (buttonpress & IN_ATTACK2 && JumpForce > -1.0)   // Jump
    {
        JumpForce += 5.0 * FrameTime  
        if (JumpForce > 3.0)    JumpForce = 3.0
    }
 
    else if (buttonpress & IN_FORWARD)  // Forward
    {
        EngineForce += Accel * FrameTime
        if (EngineForce > MaxForce)
            EngineForce = MaxForce

        //client_print(0 , print_chat, "Forward Vel = %f ", EngineForce)
    }
    else if (buttonpress & IN_BACK) // Back
    {
        EngineForce -= Accel * FrameTime
        if (EngineForce < MaxForce * -0.7)
            EngineForce = MaxForce * -0.7
    }
    else
        EngineForce = 0.0
 
    if (buttonpress & IN_MOVELEFT)  // Left
    {
        TurnAngle += 1.5 * FrameTime
        if (TurnAngle > 0.5)
            TurnAngle = 0.5
        // client_print(0 , print_chat, "Left Vel = %f ", TurnAngle)
    }
    else if (buttonpress & IN_MOVERIGHT)    // Right
    {
        TurnAngle -= 1.5 * FrameTime
        if (TurnAngle < -0.5)
        TurnAngle = -0.5
    }
    else
    {
        if (floatabs(TurnAngle) < 0.2)
            TurnAngle = 0.0
        else if (TurnAngle > 0.0)
            TurnAngle -= 1.5 * FrameTime
        else if (TurnAngle < 0.0)
            TurnAngle += 1.5 * FrameTime
    }
   
    // dynamics handling  
    new Float:vAngles[3]
    pev(TankEnt, pev_angles, vAngles)
    new Float:Angle = vAngles[1] / 180 * M_PI
 
    new Float:Speed = floatsqroot( vVelocity[0]*vVelocity[0] +vVelocity[1]*vVelocity[1] )
    new Float:VelocityAngle = floatatan2( vVelocity[1], vVelocity[0], radian )
   
    new Float:Grip = 0.0
   
    new Float:Accel_x = -1 * Drag * vVelocity[0]
    new Float:Accel_y = -1 * Drag * vVelocity[1]
   
    new Float:vAVelocity[3]
    pev(TankEnt, pev_avelocity, vAVelocity)
 
    if (!pev(TankEnt, pev_flags))
    {
        // Set angle startpoint for stunts calculations
        if (JumpForce > -1.0 && !(buttonpress & IN_ATTACK2))
        {
            set_pev(TankEnt, pev_startpos, vAngles)
            JumpForce = -1.0
        }
       
        set_pev(TankEnt, pev_endpos, vAngles)
       
        if (buttonpress & IN_FORWARD)
        {
            vAVelocity[0] += 800.0 * FrameTime
            if (vAVelocity[0] > 500.0)
                vAVelocity[0] = 500.0
            // client_print(0 , print_chat, "Forward 2Vel = %s ", vAVelocity)
        }
        else if (buttonpress & IN_BACK)
        {
            vAVelocity[0] -= 800.0 * FrameTime
            if (vAVelocity[0] < -500.0)
            vAVelocity[0] = -500.0
        }
        else
        {
            if (floatabs(vAVelocity[0]) < 80.0)
                vAVelocity[0] = 0.0
            else if (vAVelocity[0] > 0.0)
                vAVelocity[0] -= 800.0 * FrameTime
            else if (vAVelocity[0] < 0.0)
                vAVelocity[0] += 800.0 * FrameTime
        }
 
        if (buttonpress & IN_MOVELEFT)
        {
            vAVelocity[1] += 800.0 * FrameTime * dSavages[idowner][eDirection]
            if (vAVelocity[1] > 500.0)
                vAVelocity[1] = 500.0
        }
        else if (buttonpress & IN_MOVERIGHT)
        {
            vAVelocity[1] -= 800.0 * FrameTime * dSavages[idowner][eDirection]
            if (vAVelocity[1] < -500.0)
                vAVelocity[1] = -500.0
        }
        else
        {
            if (floatabs(vAVelocity[1]) < 80.0)
                vAVelocity[1] = 0.0
            else if (vAVelocity[1] > 0.0)
                vAVelocity[1] -= 800.0 * FrameTime
            else if (vAVelocity[1] < 0.0)
                vAVelocity[1] += 800.0 * FrameTime
        }
    }
    else if ((pev(TankEnt, pev_flags) & FL_INWATER) && (engfunc(EngFunc_PointContents, vOrigin) == CONTENTS_SKY))
    {
        new Float:vBump[3]
        vBump[0] = vOrigin[0] - vVelocity[0] * FrameTime
        vBump[1] = vOrigin[1] - vVelocity[1] * FrameTime
        vBump[2] = vOrigin[2] - vVelocity[2] * FrameTime
        set_pev(TankEnt, pev_origin, vBump)
       
        vVelocity[0] *= -0.5
        vVelocity[1] *= -0.5
        vVelocity[2] *= -0.5
        set_pev(TankEnt, pev_velocity, vVelocity)
    }
    else
    {
        if (floatcos(vAngles[0], degrees) < -0.1)   // Upside down in the ground, so crashed
        {
            TakeSavageBack(idowner)
            client_print(idowner, print_center, "Your car was almost crashed, write /rc to spawn it again")
            return
        }
       
        // Just landed, check stunts
        if (JumpForce < 0.0)
            JumpForce = 0.0
       
        if (Speed > 0.1)
            Grip = floatsin(Angle - VelocityAngle)
   
        new Float:TireGrip = Grip
        if (TireGrip < MaxGrip*-1.0) TireGrip = MaxGrip*-1.0
        else if (TireGrip > MaxGrip) TireGrip = MaxGrip
 
        // 3-speed gearbox
        if (Speed > MaxForce * 1.1)
        {
            if(fSavages[idowner][eGear] < 1.5)
                EngineForce *= 0.5
            fSavages[idowner][eGear] = 1.6
            TireGrip *= 0.6
        }
        else if (Speed > MaxForce * 0.7 && Speed < MaxForce * 0.9)
        {          
            if (fSavages[idowner][eGear] < 1.2 || fSavages[idowner][eGear] > 1.4 )
                EngineForce *= 0.5
            fSavages[idowner][eGear] = 1.3  
            TireGrip *= 0.8
        }
        else if (Speed < MaxForce * 0.5)
            fSavages[idowner][eGear] = 1.0
   
        // Check direction the car is going
        if (floatcos(Angle - VelocityAngle) > 0.0)
            dSavages[idowner][eDirection] = 1
        else
            dSavages[idowner][eDirection] = -1
       
        //Acceleration
        Accel_x += floatcos(Angle) * EngineForce * fSavages[idowner][eGear]
        Accel_y += floatsin(Angle) * EngineForce * fSavages[idowner][eGear]
       
        //Braking
        Accel_x -= floatcos(Angle) * BrakeForce * Speed * dSavages[idowner][eDirection]
        Accel_y -= floatsin(Angle) * BrakeForce * Speed * dSavages[idowner][eDirection]
       
        //Sideways friction ( drifting)
        Accel_x -= floatcos( Angle - M_PI/2 ) * TireGrip * Speed * 10   // Cheap but working tracktion
        Accel_y -= floatsin( Angle - M_PI/2 ) * TireGrip * Speed * 10
       
        new Float:vNewAngle[3]
        vector_to_angle(vVelocity, vNewAngle)  
        vAngles[0] = vNewAngle[0] * dSavages[idowner][eDirection]
       
        vVelocity[0] += Accel_x * FrameTime// * floatcos(CurAng[1], degrees)
        vVelocity[1] += Accel_y * FrameTime// * floatcos(CurAng[1], degrees)
       
        // Rotational force doesn't excists, but i got it right here :)
        vAVelocity[0] = 0.0
        vAVelocity[1] = Speed * floatsin(TurnAngle) * (1-floatabs(Grip)) * dSavages[idowner][eDirection]
        vAVelocity[2] = 0.0
       
        if (!(buttonpress & IN_ATTACK2) && JumpForce > 0.0)
        {
            vVelocity[2] += JumpForce * 100
            JumpForce = 0.0
            entity_set_byte(TankEnt, EV_BYTE_controller1, 127)
            entity_set_byte(TankEnt, EV_BYTE_controller2, 127)
        }
        else
            vVelocity[2] -= Gravity * FrameTime // To stop him from riding up the wall, almost
           
        set_pev(TankEnt, pev_velocity, vVelocity)
        entity_set_byte(TankEnt, EV_BYTE_controller1, floatround((EngineForce-Speed*0.1)/MaxForce *-32)+127)
        entity_set_byte(TankEnt, EV_BYTE_controller2, floatround(TireGrip*(Speed/MaxForce)*32)+127)
    }
 
    entity_set_byte(TankEnt, EV_BYTE_controller3, floatround(TurnAngle*192)+127)
    set_pev(TankEnt, pev_framerate, dSavages[idowner][eDirection]*Speed/100)
 
    vAngles[0] += vAVelocity[0] * FrameTime
    vAngles[1] += vAVelocity[1] * FrameTime
    vAngles[2] += vAVelocity[2] * FrameTime
    set_pev(TankEnt, pev_angles, vAngles)

    // SEND RETUNE AMGLES
    new Float:fAngA[3]
    pev(idowner, pev_angles, fAngA)
    vAngles[1] = fAngA[1]
    set_pev(TankEnt, pev_angles, vAngles)

    /*
    new Float:fAngA[3]
    pev(idowner, pev_angles, fAngA)
    fAngA[1] = vAngles[1]
    set_pev(idowner, pev_angles, fAngA) 
    */ 
    //TankAngleH[idowner] = vAngles[1] 
    //set_pev(TankEnt, pev_avelocity, vAVelocity)

    fSavages[idowner][eEngineForce] = EngineForce
    fSavages[idowner][eTurnAngle] = TurnAngle
    fSavages[idowner][eVelocity_x] = vVelocity[0]
    fSavages[idowner][eVelocity_y] = vVelocity[1]
    fSavages[idowner][eVelocity_z] = vVelocity[2]
    fSavages[idowner][eJumpForce] = JumpForce
   
    // sound velocity
    new Float:pitch = floatabs(EngineForce/MaxForce) + Speed/1000
    if(EngineForce > 0.2)
    {
    if (fSavages[idowner][eNextSoundTime] < halflife_time())
    {
        emit_sound(TankEnt, CHAN_VOICE, RC_SOUND_ENGINE, VOL_NORM, ATTN_NORM, 0, PITCH_NORM )
        fSavages[idowner][eNextSoundTime] = halflife_time() + 0.5
    }
    else if(fSavages[idowner][eNextPitchTime] < halflife_time())
    {
        emit_sound(TankEnt, CHAN_VOICE, RC_SOUND_ENGINE , VOL_NORM, ATTN_NORM, SND_CHANGE_PITCH, PITCH_NORM )
        fSavages[idowner][eNextPitchTime] = halflife_time() + 0.1
    }
}
    if(Pev_Value[idowner] == 0)
    {
    static Float:StartAngle
    pev(idowner, pev_angles, StartAngle)
    set_pev(TankEnt, pev_angles, StartAngle)
  //  set_pev(TankEnt, pev_v_angle, StartAngle)
    Pev_Value[idowner] = 1
    }
    set_pev(TankEnt, pev_nextthink, halflife_time() + 0.02)
}
 
public camera_think(CamEnt)
{
    new idowner = pev(CamEnt, pev_owner)
   
    if (!is_valid_ent(idowner)) return
   
    new Float:TargetOrigin[3], Float:CameraOrigin[3], Float:CameraAngles[3]
    pev(g_idTank[idowner], pev_origin, TargetOrigin)
    pev(CamEnt, pev_origin, CameraOrigin)
    pev(CamEnt, pev_angles, CameraAngles)
   
    new Float:Direction[3], Float:Angles[3]
    Direction[0] = (TargetOrigin[0] - CameraOrigin[0])
    Direction[1] = (TargetOrigin[1] - CameraOrigin[1])
    Direction[2] = (CameraOrigin[2] - TargetOrigin[2])
   
    vector_to_angle(Direction, Angles)
    Angles[0] -= CameraAngles[0]
    Angles[1] -= CameraAngles[1]
   
    Angles[0] = floatsin(Angles[0], degrees) * 500
    Angles[1] = floatsin(Angles[1], degrees) * 500
 
    set_pev(CamEnt, pev_avelocity, Angles)
   
    new Float:Distance = (vector_distance(TargetOrigin, CameraOrigin) - 100) / 50
    Direction[0] *= Distance
    Direction[1] *= Distance
    Direction[2] = (TargetOrigin[2] - CameraOrigin[2] + 50) * Distance
    set_pev(CamEnt, pev_velocity, Direction)
 
    if (g_idCamera[idowner] && g_idTank[idowner])
        set_pev(CamEnt, pev_nextthink, halflife_time() + 0.1)
}
 
CheckEntityPosition(iEntity, id)
{
    if (!pev_valid(iEntity))
        return false
 
    // Trace direction
    new Float:fOrigin[3]
    GetAimOrigin(id, fOrigin)
 
    // Check fraction
    new Float:fFraction
    get_tr2(0, TR_flFraction, fFraction)
 
    // Normal vector
    new Float:fNormal[3]
 
    // We hit something
    if (fFraction < 1.0)
    {
        get_tr2(0, TR_vecEndPos, fOrigin)
        get_tr2(0, TR_vecPlaneNormal, fNormal)
    }
 
    // Update normal vector and new origin
    xs_vec_mul_scalar(fNormal, 8.0, fNormal)
//    if (CheckEntityDistance(iEntity, id) < get_pcvar_num(g_pCvarMaxDistance))
    xs_vec_add(fOrigin, fNormal, fOrigin)
/*    else
    {
    new origin[3], Float:xorigin[3];
    get_user_origin(id, origin);
    IVecFVec(origin, xorigin);
 
        // Direction
    new Float:direction[3];
    velocity_by_aim(id, get_pcvar_num(g_pCvarMaxDistance) - 50, direction);
    xs_vec_add(fOrigin, fNormal, fOrigin);
    }
*/    
    fOrigin[2] += 0.0
 
    engfunc(EngFunc_SetOrigin, iEntity, fOrigin)
 
    if (CheckEntityCollides(fOrigin, 17.0))
        return false
 
    // Follow terrain
    EntityFollowTerrain(iEntity, fOrigin, 0)
 
    // Check placement points
    new iPointContents = engfunc(EngFunc_PointContents, fOrigin)
 
    if (iPointContents != CONTENTS_EMPTY)
        return false
 
    // Check if it is hitting an entity we don't want glitch
    new iHit = get_tr2(0, TR_pHit)
 
    if (pev_valid(iHit) && !CheckEntityHitAllowed(iHit))
        return false
 
    // Entity is too close?
    if (CheckEntityDistance(iEntity, id) <= get_pcvar_num(g_pCvarMinDistance))
        return false
 
    // Entity is too far?
    if (CheckEntityDistance(iEntity, id) > get_pcvar_num(g_pCvarMaxDistance))
        return false
 
    return true
}
 
GetAimOrigin(id, Float:fOriginAim[3], Float:fMaximumAimDistance = 85.0)
{
    // Get player's origin and view ofs
    static Float:fOrigin[3], Float:fViewOfs[3]
    pev(id, pev_origin, fOrigin)
    pev(id, pev_view_ofs, fViewOfs)
 
    // Do some calculation stuff
    xs_vec_add(fOrigin, fViewOfs, fOrigin)
 
    // Get player's view angles
    pev(id, pev_v_angle, fViewOfs)
 
    // Make vectors
    engfunc(EngFunc_MakeVectors, fViewOfs)
 
    // Get forward vector
    global_get(glb_v_forward, fViewOfs)
 
    // Do some calculations
    xs_vec_mul_scalar(fViewOfs, fMaximumAimDistance, fViewOfs)
    xs_vec_add(fOrigin, fViewOfs, fViewOfs)
 
    // Trace line?
    engfunc(EngFunc_TraceLine, fOrigin, fViewOfs, DONT_IGNORE_MONSTERS, id, 0)
 
    // Get aim origin by trace line result
    get_tr2(0, TR_vecEndPos, fOriginAim)	
}

 
CheckEntityCollides( Float:fOrigin[ 3 ], Float:fBounds )
{
    new Float:fTraceEnd[8][3]
 
    // Calculate X, Y and Z
    fTraceEnd[0][0] = fOrigin[0] - fBounds
    fTraceEnd[0][1] = fOrigin[1] - fBounds
    fTraceEnd[0][2] = fOrigin[2] - fBounds
 
    fTraceEnd[1][0] = fOrigin[0] - fBounds
    fTraceEnd[1][1] = fOrigin[1] - fBounds
    fTraceEnd[1][2] = fOrigin[2] + fBounds
 
    fTraceEnd[2][0] = fOrigin[0] - fBounds
    fTraceEnd[2][1] = fOrigin[1] + fBounds
    fTraceEnd[2][2] = fOrigin[2] + fBounds
 
    fTraceEnd[3][0] = fOrigin[0] + fBounds
    fTraceEnd[3][1] = fOrigin[1] + fBounds
    fTraceEnd[3][2] = fOrigin[2] + fBounds
 
    fTraceEnd[4][0] = fOrigin[0] + fBounds
    fTraceEnd[4][1] = fOrigin[1] - fBounds
    fTraceEnd[4][2] = fOrigin[2] - fBounds
 
    fTraceEnd[5][0] = fOrigin[0] + fBounds
    fTraceEnd[5][1] = fOrigin[1] + fBounds
    fTraceEnd[5][2] = fOrigin[2] - fBounds
 
    fTraceEnd[6][0] = fOrigin[0] + fBounds
    fTraceEnd[6][1] = fOrigin[1] - fBounds
    fTraceEnd[6][2] = fOrigin[2] + fBounds
 
    fTraceEnd[7][0] = fOrigin[0] - fBounds
    fTraceEnd[7][1] = fOrigin[1] + fBounds
    fTraceEnd[7][2] = fOrigin[2] - fBounds
 
    // Get trace hits, and check point contents
    new Float:fTraceHit[3], iLoop, iPointContents, iHit, iInnerLoop
 
    for (iLoop = 0; iLoop < sizeof(fTraceEnd); iLoop ++)
    {
        // Get point contents
        iPointContents = engfunc(EngFunc_PointContents, fTraceEnd[iLoop])
 
        if (iPointContents != CONTENTS_EMPTY)
            return true
 
        // Is it hitting something?
        iHit = trace_line(0, fOrigin, fTraceEnd[iLoop], fTraceHit)
 
        if (iHit != 0)
            return true
 
        for (iInnerLoop = 0; iInnerLoop < sizeof(fTraceHit); iInnerLoop ++)
        {
            if (fTraceEnd[iLoop][iInnerLoop] != fTraceHit[iInnerLoop])
                return true
        }
    }
 
    return false
}
 
EntityFollowTerrain(iEntity, Float:fOrigin[ 3 ], iTraceResult)
{
    // Trace
    new Float:fTraceTo[3]
    xs_vec_sub(fOrigin, Float:{ 0.0, 0.0, 10.0 }, fTraceTo)
 
    // Get angles
    new Float:fAngles[2][3]
    pev(iEntity, pev_angles, fAngles[0])
 
    // Get forward vector
    new Float:fForward[3]
    angle_vector(fAngles[0], ANGLEVECTOR_FORWARD, fForward)
 
    // Get up vector
    new Float:fVectorUp[3]
    get_tr2(iTraceResult, TR_vecPlaneNormal, fVectorUp)
 
    // Calculate vectors
    new Float:fVectorRight[3], Float:fVectorForward[3]
 
    xs_vec_cross(fForward, fVectorUp, fVectorRight)
    xs_vec_cross(fVectorUp, fVectorRight, fVectorForward)
 
    vector_to_angle(fVectorForward, fAngles[0])
    vector_to_angle(fVectorRight, fAngles[1])
 
    // Update angles
    fAngles[0][2] = -1.0 * fAngles[1][0]
 
    // Set angles that we calculated
    set_pev(iEntity, pev_angles, fAngles[0])
}
 
CheckEntityHitAllowed(iEntity)
{
    new const szClassNameHitDenied[][] =
    {
        "func_door",
        "func_door_rotating",
        "func_plat",
        "func_rotating",
        "func_train",
        "func_conveyor",
        "hostage_entity",
        "player"
    }
 
    // Get class name of the entity that has been hit
    static szClassName[32]
    pev(iEntity, pev_classname, szClassName, charsmax(szClassName))
 
    // Check if it is hitting a denied class name
    for (new iLoop = 0; iLoop < sizeof(szClassNameHitDenied); iLoop ++)
    {
        if (equali(szClassName, szClassNameHitDenied[iLoop]))
            return false
    }
 
    return true
}
 
CheckEntityDistance(iEntity, id)
{
    new Float:fOrigin[2][3]
    pev(iEntity, pev_origin, fOrigin[0])
    pev(id, pev_origin, fOrigin[1])
    return floatround(get_distance_f(fOrigin[0], fOrigin[1]))
}
 
UpdateEntityPosition(id)
{
    if (!is_user_alive(id))
    return
 
    new iEntity = g_idTank[id]
 
    if (!pev_valid(iEntity))
    return
    if (g_isSpawningTank[id])
    {
    if (CheckEntityPosition(iEntity, id))
    {
    set_pev(iEntity, pev_iuser2, 1)
    new Float:StartAngle[3]
    pev(id, pev_angles, StartAngle)
    set_pev(iEntity, pev_angles, StartAngle)
    set_pev(iEntity, pev_v_angle, StartAngle)
    set_pev(iEntity, pev_rendermode, kRenderTransAdd); set_pev(iEntity, pev_renderamt, 200.0);
    set_pev(iEntity, pev_body, 0)
  //  client_print(id, print_chat, "Red")
    }
    else
    {
    set_pev(iEntity, pev_iuser2, 0)
    set_pev(iEntity, pev_rendermode, kRenderTransAdd); set_pev(iEntity, pev_renderamt, 200.0);
    set_pev(iEntity, pev_body, 1)
    new Float:StartAngle[3]
    pev(id, pev_angles, StartAngle)
    set_pev(iEntity, pev_angles, StartAngle)
    set_pev(iEntity, pev_v_angle, StartAngle)
  //  client_print(id, print_chat, "Green")
    }
   }
}
public remove_preview(id)
{
		if (g_pBeam[id] && pev_valid(g_pBeam[id]))
		engfunc(EngFunc_RemoveEntity, g_pBeam[id]);
}

public rocket_shoot(id, rocketindex, wId)
{ 
    if (!g_idTank[id]) return;
	if (!rocketindex) return;
    /*
    TANK ENT HAT THIS :
    set_pev(TankEnt, pev_angles, vAngles)
    set_pev(TankEnt, pev_avelocity, vAVelocity)
    set_pev(TankEnt, pev_velocity, vVelocity)
    */
    new Float:vOrigin[3]
    VelocityByAim(id, 150 , vOrigin) 
	new Float:pOrigin[3]
	pev(g_idTank[id], pev_origin, pOrigin)
    xs_vec_add( pOrigin, vOrigin, pOrigin ) // MOVE Start rocket point from tank's tube
	pOrigin[2] += 40.0                     // Tune HeightPoint startpoint rocket
	set_pev(rocketindex, pev_origin, pOrigin)

}

public rocket_retune(rocket)
{
    if (!pev_valid(rocket)) return; 
    new Float:fVelocity[3]
    new Float:fAngle[3]

    new idonwer = pev(rocket, pev_owner)
    pev(g_idTank[idonwer], pev_angles, fAngle)
    set_pev(rocket, pev_angles, fAngle)
    
    engfunc(EngFunc_MakeVectors, fAngle);
    global_get(glb_v_forward, fVelocity);
    new Float:length = vector_length(fVelocity);
    
    new Float:speed = 1400.0
    fVelocity[0] *= (speed / length);
    fVelocity[1] *= (speed / length);
    fVelocity[2] *= (speed / length);

    //set_pev(rocket, pev_movetype, MOVETYPE_NONE)
    set_pev(rocket, pev_movetype, MOVETYPE_TOSS)
    set_pev(rocket, pev_velocity, fVelocity)

}

public CameraSwitchView(id)
{
    if (!g_idTank[id]) return;
    if (!g_idCamera[id]) return;
    
    if(CamMode[id] == 0)
    {
        // player view
        // attach_view(id, id)
        CamMode[id]++
        return;
    }
    else if(CamMode[id] == 1)
    {
        // cam view
        attach_view(id, g_idCamera[id])
        CamMode[id]++
        return;
    }
     else if(CamMode[id] == 2)
    {
        // tank view
        attach_view(id, g_idTank[id])
        CamMode[id]++
        return;
    }

    
    if (CamMode[id] >2)  CamMode[id] = 0
    return;
}
