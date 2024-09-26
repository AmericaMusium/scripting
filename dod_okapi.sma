#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <fakemeta_util>
#include <dodx>
#include <dodfun>
#include <fun>
#include <engine>
#include <okapi>

new okapi_func:func_RocketTouch
new okapi_func:func_RocketExplodeTouch
new okapi_func:func_ThinkZoomOutIn_CBasePlayerWeapon
new okapi_func:func_ThinkZoomOutIn_CScopedKar

new okapi_func:func_Test_any

public plugin_init()
{
    register_plugin("DOD OKAPI TEST", "2023", "America")

    /*
    okapi_mod_replace_string("sprites/obj_icons/icon_obj_axis.spr","sprites/obj_icons/icon_obj_axiz.spr",1)
    okapi_engine_replace_string("sprites/obj_icons/icon_obj_axis.spr","sprites/obj_icons/icon_obj_axiz.spr",1)

    okapi_mod_replace_string("sprites/obj_icons/icon_obj_axis.spr","sprites/obj_icons/icon_obj_axiz.spr",1)
    okapi_engine_replace_string("sprites/obj_icons/icon_obj_axis.spr","sprites/obj_icons/icon_obj_axiz.spr",1)

    */

    // okapi_mod_replace_string("Axis", "Ussr",1)
    // okapi_engine_replace_string("Axis", "Ussr",1)
    register_event("SetFOV","Set_fov_post","be","1>0") // проверить перезапись угла

    server_print("OKAPI RUNS")
    // okapi_mod_replace_int(1,2)
}


public On_func_RocketTouch(idx_shell, idx_ent)
{
    //new obj = okapi_get_orig_return()

    server_print("On_func_RocketTouch %d %d", idx_shell, idx_ent)

    new sz_classname[32]
    pev( idx_shell, pev_classname, sz_classname, 31)
    server_print(sz_classname)
    pev( idx_ent, pev_classname, sz_classname, 31)
    server_print(sz_classname)
    return okapi_ret_ignore
    // return okapi_ret_supercede // blocking run RocketExplodeTouch
}

public On_func_RocketExplodeTouch(idx_shell, idx_ent)
{
    server_print("On_func_RocketExplodeTouch %d %d", idx_shell, idx_ent)
    return okapi_ret_ignore
}

public On_func_ThinkZoomOutIn(idx_weapon)
{   
    server_print("On_")
    return okapi_ret_supercede
}


public On_func_Test(idx_weapon)
{   
    server_print("On_TEST")
    return okapi_ret_supercede
}

/////////////////









public plugin_precache()
{   



    // ZOOM FUNC
    
    // ?ThinkZoomOut@CBasePlayerWeapon@@QAEXXZ
    // ?ThinkZoomOutIn@CScopedKar@@QAEXXZ

    new func_ThinkZoomOutIn_CBasePlayerWeapon_ptr = okapi_mod_get_symbol_ptr("?ThinkZoomOutIn@CScopedKar@@QAEXXZ") 
    if(!func_ThinkZoomOutIn_CBasePlayerWeapon_ptr)
    {   
        return 1
    //install_gamerules_ptr = okapi_get_treemap_ptr("[TG.;nC'.pbG.sXQ.J=g(.;OS'.ueA.1/.*K}.`/F'. 8u{.s9s{.Ohi(.,lm{.s9s{.2/#&.*0J.lE>'.1`}&.-]}&.vMa(.zp='.<cN'.=j12")
    }

    
    func_ThinkZoomOutIn_CBasePlayerWeapon = okapi_build_method(func_ThinkZoomOutIn_CBasePlayerWeapon_ptr, arg_cbase, arg_cbase)
    okapi_add_hook(func_ThinkZoomOutIn_CBasePlayerWeapon,"On_func_ThinkZoomOutIn", 0) // 1 = post
                                                                                
    //// *
    new func_ThinkZoomOutIn_CScopedKar_ptr = okapi_mod_get_symbol_ptr("?ThinkZoomIn@CBasePlayerWeapon@@QAEXXZ")
    if(!func_ThinkZoomOutIn_CScopedKar_ptr)
    {   

    //install_gamerules_ptr = okapi_get_treemap_ptr("[TG.;nC'.pbG.sXQ.J=g(.;OS'.ueA.1/.*K}.`/F'. 8u{.s9s{.Ohi(.,lm{.s9s{.2/#&.*0J.lE>'.1`}&.-]}&.vMa(.zp='.<cN'.=j12")
    }
    func_ThinkZoomOutIn_CScopedKar = okapi_build_method(func_ThinkZoomOutIn_CScopedKar_ptr, arg_cbase, arg_cbase)
    okapi_add_hook(func_ThinkZoomOutIn_CScopedKar,"On_func_ThinkZoomOutIn", 0) // 1 = post

    /// test func 

    
    // ***************************************************
    // Находим идентификатор функции
    new func_Test_any_ptr = okapi_mod_get_symbol_ptr("?Think@CEnvModel@@EAEXXZ") 
    if(!func_Test_any_ptr)
    {   
        // Если на найдено , тогда ищем по сигнатуре
        // func_Test_any_ptr = okapi_get_treemap_ptr("55 8b ec 83 ec 44 53 56 57 89 4d fc 8b 45 fc 8b 10 8b 4d fc ff 92 84 01 00 00 8b 4d fc 8b 91 64 01 00 00 89 82 b4 05 00 00 8b 45 fc 8b 10 8b 4d fc ff 92 94 01 00 00 5f 5e 5b 8b e5 5d c3")
        server_print("OKAPI func_RocketTouch_ptr error")
        return PLUGIN_CONTINUE
        
    }
    server_print(" getted OKA{I TEST %d", func_Test_any_ptr)
    // Раз уж найдено, создаём метод, т.к. функция принадлежит какому-то классу, если бы это была безклассовая функция, то использовали бы okapi_build_function
    // описываем функцию, является ли возвратом , какие аргументы даёт.   
    func_Test_any = okapi_build_method(func_Test_any_ptr, arg_void, arg_void)
    // cоздаём хук для вызова On_func_RocketTouch при обнаружениии  ?RocketTouch@CBazookaShell@@QAEXPAVCBaseEntity@@@Z
    okapi_add_hook(func_Test_any,"On_func_Test", 0) // 1 = post
    server_print(" getted OKA{I TEST %d", func_Test_any)
 
    return PLUGIN_CONTINUE

}

public Set_fov_post(id)
{
    client_print(0, print_chat, "FOV POST")

    new fov = read_data(1)
    return fov
}


public secondsfimc()
{
        // REGISTERING ROCKETLAUCNH FUNCTION
    // Находим идентификатор функции
    new func_RocketTouch_ptr = okapi_mod_get_symbol_ptr("?RocketTouch@CBazookaShell@@QAEXPAVCBaseEntity@@@Z") 
    if(!func_RocketTouch_ptr)
    {   
        // Если на найдено , тогда ищем по сигнатуре
        // install_gamerules_ptr = okapi_get_treemap_ptr("[TG.;nC'.pbG.sXQ.J=g(.;OS'.ueA.1/.*K}.`/F'. 8u{.s9s{.Ohi(.,lm{.s9s{.2/#&.*0J.lE>'.1`}&.-]}&.vMa(.zp='.<cN'.=j12")
        server_print("OKAPI func_RocketTouch_ptr error")
    }
    // Раз уж найдено, создаём метод, т.к. функция принадлежит какому-то классу, если бы это была безклассовая функция, то использовали бы okapi_build_function
    // описываем функцию, является ли возвратом , какие аргументы даёт.   
    func_RocketTouch = okapi_build_method(func_RocketTouch_ptr, arg_void, arg_cbase, arg_cbase)
    // cоздаём хук для вызова On_func_RocketTouch при обнаружениии  ?RocketTouch@CBazookaShell@@QAEXPAVCBaseEntity@@@Z
    okapi_add_hook(func_RocketTouch,"On_func_RocketTouch", 0) // 1 = post
  

    new func_RocketExplodeTouch_ptr = okapi_mod_get_symbol_ptr("?RocketExplodeTouch@CGrenade@@QAEXPAVCBaseEntity@@@Z") 
    if(!func_RocketExplodeTouch_ptr)
    {   

    //install_gamerules_ptr = okapi_get_treemap_ptr("[TG.;nC'.pbG.sXQ.J=g(.;OS'.ueA.1/.*K}.`/F'. 8u{.s9s{.Ohi(.,lm{.s9s{.2/#&.*0J.lE>'.1`}&.-]}&.vMa(.zp='.<cN'.=j12")
    }
    func_RocketExplodeTouch = okapi_build_method(func_RocketTouch_ptr, arg_void, arg_cbase, arg_cbase)
    okapi_add_hook(func_RocketExplodeTouch,"On_func_RocketExplodeTouch", 0) // 1 = post
    
}