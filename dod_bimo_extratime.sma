#include <amxmodx>
#include <amxmisc>
#include <dodx>
#include <dodfun>

new g_VotePlus
new g_TotalPlayers
new g_VoteFree = 1

public plugin_init()
{
	register_plugin("DOD Extratime","0.0","America")
	server_print("DOD Extratime")
    //register_concmd ("votetime", "Vote_start", ADMIN_BAN, "123")
    // register_clcmd("moqatime", "time_add")
    register_concmd ("addtime", "time_add_ask", ADMIN_LEVEL_B, "123")
    register_concmd ("rrr", "restart_ask", ADMIN_LEVEL_B, "123")
}

public Vote_start(id, level, cid)
{
if (!cmd_access(id, level, cid, 1))
	return PLUGIN_HANDLED
if(g_VoteFree)
{
    g_VoteFree = 0
    new Netname[33]
    get_user_name(id, Netname, 32)

    new Players[32]
	new count, i, player 
	get_players(Players, count, "ch")

    g_TotalPlayers = count

	for (i=0; i < count; i++) 
    {   
        // каждому игроку. 
        player = Players[i]
        client_print(0, print_center, "%s starts voting for extra time", Netname )
        vote_menu_open(player)
    }
}
}


//lets make the function that will make the menu
 public vote_menu_open( id )
 {
    //first we need to make a variable that will hold the menu
    new menu = menu_create( "\rDo you want to extend the round time?", "vote_menu_press" );
    //Note - menu_create
    //The first parameter  is what the menu will be titled ( what is at the very top )
    //The second parameter is the function that will deal/handle with the menu ( which key was pressed, and what to do )

    //Now lets add some things to select from the menu
    menu_additem( menu, "\wYES ", "", 0 );
    menu_additem( menu, "\wNO", "", 0 );
    // menu_additem( menu, "\wAXIS: WERMACHT", "", 0 );
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
 public vote_menu_press( id, menu, item )
 {
    //Because of the simplicity of this menu, we can switch for which item was pressed
    //Note - this is zero-based, so the first item is 0
    new Netname[33]
    get_user_name(id, Netname, 32)
   
    switch( item )
    {
        case 0:
        {   
            g_VotePlus++
            client_print(0, print_chat, " RESULTS FOR SET EXTRATIME: %d / %d", g_VotePlus, g_TotalPlayers)
            set_hudmessage(random_num(2,20), random_num(200,220), random_num(5,50), float(random_num(0,1000))/ 1000.0, float(random_num(0,1000))/ 1000.0, 0, 6.0, float(4), 0.8, 2.2, -1);	// format our hudmsg
            show_hudmessage(0," %s : YES ! ", Netname )
            vote_result_check()
        }
        case 1:
        {   
            client_print(0, print_chat, " RESULTS FOR SET EXTRATIME: %d / %d", g_VotePlus, g_TotalPlayers)
            set_hudmessage(random_num(200,220), random_num(5,20), random_num(5,20), float(random_num(0,1000))/ 1000.0, float(random_num(0,1000))/ 1000.0, 0, 6.0, float(4), 0.8, 2.2, -1);	// format our hudmsg
            show_hudmessage(0," %s : NO ! ", Netname )
            vote_result_check()
        }
        case MENU_EXIT:
        {   
            set_hudmessage(random_num(5,20), random_num(5,20), random_num(205,220), float(random_num(0,1000))/ 1000.0, float(random_num(0,1000))/ 1000.0, 0, 6.0, float(4), 0.8, 2.2, -1);	// format our hudmsg
            show_hudmessage(0," %s : Close menu ! ", Netname )
            client_print(0, print_chat, " RESULTS FOR SET EXTRATIME: %d / %d", g_VotePlus, g_TotalPlayers)
            vote_result_check()
        }
    }

    //lets finish up this function by destroying the menu with menu_destroy, and a return
    menu_destroy( menu );
    return PLUGIN_HANDLED;
 }

 public vote_result_check()
 {
    new changer = (g_TotalPlayers)/2    
    if (g_VotePlus >= (g_TotalPlayers / 2) && g_VoteFree)
    {   

        client_print(0, print_center, "EXTRATIME !!!!!!!")
        time_add()

        new Players[32]
	    new count, i, player 
	    get_players(Players, count, "ch")
	    for (i=0; i < count; i++) 
        {   
            player = Players[i]
            client_cmd(player,"spk player/gerprepare.wav")
            client_cmd(player,"spk weapons/mortar_hit1.wav")
        } 
        
    }
    

 }

public time_add_ask(id, level, cid)
{
if (!cmd_access(id, level, cid, 1))
	return PLUGIN_HANDLED

time_add()

}
public restart_ask(id, level, cid)
{
if (!cmd_access(id, level, cid, 1))
	return PLUGIN_HANDLED

server_cmd("restart")

}



public time_add()
{   
    if(g_VoteFree)
    {
    new Float:currentlimit = get_cvar_float("mp_timelimit")
    server_print(" current limit = %f", currentlimit)
    currentlimit += 10.0
    if(currentlimit > 55.0)
    {   
        currentlimit = 55.0
        
    }
    server_cmd("mp_timelimit %d", floatround(currentlimit))
    g_VoteFree = 0
    }

}
