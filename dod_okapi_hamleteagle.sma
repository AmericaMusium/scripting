#include <amxmodx>
#include <okapi>

public plugin_precache()
{   
    // https://forums.alliedmods.net/showthread.php?t=234986&page=10
    new const InstallGameRulesSignature[] = {0x68,0xDEF,0xDEF,0xDEF,0xDEF,0xFF,0xDEF,0xDEF,0xDEF,0xDEF,0xDEF,0x83,0xDEF,0xDEF,0xFF,0xDEF,0xDEF,0xDEF,0xDEF,0xDEF,0xA1,0xDEF,0xDEF,0xDEF,0xDEF,0xD9,0xDEF,0xDEF,0xD8,0xDEF,0xDEF,0xDEF,0xDEF,0xDEF,0xDF}
    new const InstallGameRulesSymbol[] = "_Z16InstallGameRulesv"

    new okapi_func:InstallGameRules = okapi_build_function(OkapiGetFunctionAddress(InstallGameRulesSignature, sizeof InstallGameRulesSignature, InstallGameRulesSymbol), arg_int)
    okapi_add_hook(InstallGameRules, "OnInstallGameRules", .post = 1)
}  

public OnInstallGameRules()
{
    new Object = okapi_get_orig_return()
    new CheckWinConditionsFuncOffset = 65
    new okapi_func:CheckWinConditions = okapi_build_vfunc_ptr(Object, CheckWinConditionsFuncOffset, arg_void)    
}  

OkapiGetFunctionAddress(const FunctionSignature[] = "", SignatureLen, const FunctionSymbol[])
{
    new OkapiAddress

    if
    (
        (OkapiAddress = okapi_mod_get_symbol_ptr(FunctionSymbol)) || 
        (OkapiAddress = okapi_mod_find_sig(FunctionSignature, SignatureLen))
    )
    {
        return OkapiAddress
    }
    
    return PLUGIN_CONTINUE
} 