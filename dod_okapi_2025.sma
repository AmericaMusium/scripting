#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <dodx>
#include <dodfun>
#include <fun>
#include <engine>
#include <okapi>
#include <reapi>



// okapi desc 0x550x8B0xEC0x83
// new const sig[] = {0x55, 0x8B, 0xEC, 0x83} // , 0xEC, 0x10}; находит

new const sig[] = {0x55, 0x8B, "𐌻", "𐌻", 0xEC, 0x10};


new const sig_colt_wav[] = {0x68, 0xd8, 0x05 };

new const sig_sccooped_kar[] = {0x55, 0x8B, 0xEC, 0x83, 0xEC}

new okapi_func:func_Test_any

new ptr
// plugin_precache
// plugin_init




public OnPlayerKilled(victim, attacker, damage) 
{
    client_print(0, print_chat, "Игрок %d убит игроком %d с уроном %f!", victim, attacker, damage);
}
public plugin_precache()
{   

    ptr = okapi_mod_find_sig(sig, sizeof(sig));
    server_print("OKAPI :::::: %d", ptr)
    RegisterHookChain( RH_PF_precache_sound_I, "OnPlayerKilled", 1);

    
}


public plugin_init()
{
    //  ?ThinkZoomIn@CBasePlayerWeapon@@QAEXXZ
    new func_Test_any = okapi_build_method(ptr, arg_void, arg_void)
    // cоздаём хук для вызова On_func_RocketTouch при обнаружениии  ?RocketTouch@CBazookaShell@@QAEXPAVCBaseEntity@@@Z
    okapi_add_hook(func_Test_any,"On_func_Test", 1) // 1 = post
    server_print(" getted OKA{I TEST %d", func_Test_any)

    // my_func = okapi_build_function(ptr, arg_cbase, arg_cbase, arg_cbase);
    // new result = okapi_call(my_func, 10, 20);
    // log_amx("Результат вызова функции: %d", result);
    // server_print("OKAPI :::::: %d", result)

    //new okapi_hook:my_hook_handle = okapi_add_hook(my_func, "my_hook");
}

public On_func_Test(idx_weapon)
{   
    server_print("On_TEST %d", idx_weapon)
    if( pev_valid(idx_weapon))
    {
       new classname[32];
        entity_get_string(idx_weapon,EV_SZ_classname,classname,31);
        server_print("On_TEST %s", classname)

    }
    return okapi_ret_supercede
}


/*

Пример чтения и записи значения по указателю:
new ptr = okapi_mod_get_base_ptr() + 0x1234; // Пример адреса
new value = okapi_get_ptr_int(ptr);
log_amx("Значение по адресу %d: %d", ptr, value);

okapi_set_ptr_int(ptr, 999);
log_amx("Новое значение: %d", okapi_get_ptr_int(ptr));
############

kapi позволяет заменять строки и данные в памяти игры.
Пример замены строки:
new count = okapi_mod_replace_string("old_string", "new_string");
log_amx("Количество замен: %d", count);
##############

###########
To check if the signature is being searched correctly do:
new offset = okapi_mod_get_ptr_offset(okapi_mod_find_sig(SignA,8))
server_print("offset %x^n",offset) 


#########
okapi_build_function следует использовать для функций без класса.
okapi_build_method следует использовать для функций, которые являются членами класса.



Когда вы используете сигнатуры для использования функций, после того, как вы присоединяете модуль к функции, он изменяет байты функций.
Это означает, что если вы используете одну и ту же сигнатуру дважды, вторая не будет работать. Это означает, что если вы используете одну и ту же сигнатуру в двух
плагинах, она не будет работать в одном. Чтобы избежать этого, вы можете, например, просто выполнить поиск сигнатуры в plugin_precache и подключиться в plugin_init.


###########
использование символа "𐌻" или любого значения выше 0xFF означает, что конкретный бит должен быть пропущен из сравнений.
Сигнатуры должны выглядеть так:

Код:
{0x51,0x56,"𐌻","𐌻",0x8B,0x86}
{0x51,0x56,0xDEF,0xDEF,0x8B,0x86}
*/