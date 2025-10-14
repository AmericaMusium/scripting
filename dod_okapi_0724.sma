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

new okapi_func:func_ThinkZoomOutIn_CBasePlayerWeapon


public plugin_init()
{
    register_plugin("DOD OKAPI TEST", "2024", "America")

    server_print("OKAPI RUNS 2")
    // okapi_mod_replace_int(1,2)
    Reg_ThinkZoomOutIn()
}

public On_func_ThinkZoomOutIn(idx_weapon)
{   
    server_print("Hooked On_func_ThinkZoomOutIn")
    return okapi_ret_supercede
}

public plugin_precache()
{   
    
}

public Reg_ThinkZoomOutIn()
{   


    /// _ZN10CScopedKar14ThinkZoomOutInEv
    // ?ThinkZoomIn@CBasePlayerWeapon@@QAEXXZ
    new func_ThinkZoomOutIn_CBasePlayerWeapon_ptr = okapi_engine_get_symbol_ptr("?ThinkZoomIn@CBasePlayerWeapon@@QAEXXZ") 
    server_print("OKAPI func_ThinkZoomOutIn_CBasePlayerWeapon_ptr finded %d",func_ThinkZoomOutIn_CBasePlayerWeapon_ptr )
    if(!func_ThinkZoomOutIn_CBasePlayerWeapon_ptr)
    {   
        server_print("OKAPI not finded 000000: %d" , func_ThinkZoomOutIn_CBasePlayerWeapon_ptr)
        return
    }
    func_ThinkZoomOutIn_CBasePlayerWeapon = okapi_build_method(func_ThinkZoomOutIn_CBasePlayerWeapon_ptr, arg_cbase, arg_cbase)
    okapi_add_hook(func_ThinkZoomOutIn_CBasePlayerWeapon,"On_func_ThinkZoomOutIn", 0) // 1 = post
    return
}