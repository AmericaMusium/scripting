#include <amxmodx>

public plugin_init()
{
    register_plugin("DOD MENU TEAM", "1.0", "America")
    register_clcmd("say /team","f_menu_open", 0 )
}

 //lets make the function that will make the menu
 public f_menu_open( id )
 {
    //first we need to make a variable that will hold the menu
    new menu = menu_create( "\rTEAM MENU:", "menu_handler" );
    //Note - menu_create
    //The first parameter  is what the menu will be titled ( what is at the very top )
    //The second parameter is the function that will deal/handle with the menu ( which key was pressed, and what to do )

    //Now lets add some things to select from the menu
    menu_additem( menu, "\wALLIES: USA ", "", 0 );
    menu_additem( menu, "\wALLIES: USSR", "", 0 );
    menu_additem( menu, "\wAXIS: WERMACHT", "", 0 );
    //Note - menu_additem
    //The first parameter is which menu we will be adding this item/selection to
    //The second parameter is what text will appear on the menu ( Note that it is preceeded with a number of which item it is )
    //The third parameter is data that we want to send with this item
    //The fourth parameter is which admin flag we want to be able to access this item ( Refer to the admin flags from the amxconst.inc )
    //The fifth parameter is the callback for enabling/disabling items, by default we will omit this and use no callback ( default value of -1 ) Refer to the Menu Items with Callbacks section for more information.

    //Set a property on the menu
    menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );
    //Note - menu_setprop
    //The first parameter is the menu to modify
    //The second parameter is what to modify ( found in amxconst.inc )
    //The third parameter is what to modify it to ( in this case, we are adding a option to the menu that will exit the menu. setting it to MEXIT_NEVER will disable this option )
    //Additional note - MEXIT_ALL is the default property for MPROP_EXIT, so this is redundant

    //Lets display the menu
    menu_display( id, menu, 0 );
    //Note - menu_display
    //The first parameter is which index to show it to ( you cannot show this to everyone at once )
    //The second parameter is which menu to show them ( in this case, the one we just made )
    //The third parameter is which page to start them on
 }
 //okay, we showed them the menu, now lets handle it ( looking back at menu_create, we are going to use that function )
 public menu_handler( id, menu, item )
 {
    //Because of the simplicity of this menu, we can switch for which item was pressed
    //Note - this is zero-based, so the first item is 0
    switch( item )
    {
        case 0:
        {   
            client_cmd(id,"usa")
        }
        case 1:
        {   
            client_cmd(id,"ussr")
        }
        case 2:
        {   
            client_cmd(id,"axis")
        }
        case MENU_EXIT:
        {
            client_print( id, print_chat, "You exited the menu... what a bummer!" );
        }
    }

    //lets finish up this function by destroying the menu with menu_destroy, and a return
    menu_destroy( menu );
    return PLUGIN_HANDLED;
 }