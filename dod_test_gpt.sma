#include < amxmodx >
#include < amxmisc >
#include < amxconst >

public plugin_init()
{
    register_plugin("ColorChat", "1.0", "Author");
}

public ColorChat_Timer()
{

    client_print(0, print_chat, " ^1");
    set_task(1.0, "ColorChat_Timer2");
}

public ColorChat_Timer2()
{

    client_print(0, print_chat, " ^2");
    set_task(1.0, "ColorChat_Timer3");
}
public ColorChat_Timer3()
{

    client_print(0, print_chat, " ^3");
    set_task(1.0, "ColorChat_Timer4");
}
public ColorChat_Timer5()
{

    client_print(0, print_chat, " ^4");
    set_task(1.0, "ColorChat_Timer");
}

public client_putinserver(id)
{
    set_task(5.0, "ColorChat_Timer");
}
