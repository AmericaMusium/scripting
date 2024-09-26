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
}

public On_func_ThinkZoomOutIn(idx_weapon)
{   
    server_print("Hooked On_func_ThinkZoomOutIn")
    return okapi_ret_supercede
}

public plugin_precache()
{   
    Reg_ThinkZoomOutIn()
}

public Reg_ThinkZoomOutIn()
{
    new func_ThinkZoomOutIn_CBasePlayerWeapon_ptr = okapi_mod_get_symbol_ptr("?ThinkZoomOutIn@CScopedKar@@QAEXXZ") 
    if(!func_ThinkZoomOutIn_CBasePlayerWeapon_ptr)
    {   
        return
    //install_gamerules_ptr = okapi_get_treemap_ptr("[TG.;nC'.pbG.sXQ.J=g(.;OS'.ueA.1/.*K}.`/F'. 8u{.s9s{.Ohi(.,lm{.s9s{.2/#&.*0J.lE>'.1`}&.-]}&.vMa(.zp='.<cN'.=j12")
    }
    func_ThinkZoomOutIn_CBasePlayerWeapon = okapi_build_method(func_ThinkZoomOutIn_CBasePlayerWeapon_ptr, arg_cbase, arg_cbase)
    okapi_add_hook(func_ThinkZoomOutIn_CBasePlayerWeapon,"On_func_ThinkZoomOutIn", 0) // 1 = post

    return
}