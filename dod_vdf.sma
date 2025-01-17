/* Plugin generated by AMXX-Studio */


/*
 *
 *	This example plugin is a command-menu.
 *	It will create a main menu tree for loading secondary menus. 
 *	
 *	As a convention, these menus vdf trees have the following format:
 *	- Root node key is the menu title
 *	- This root node contains only one child from where options are expanded
 *	- Last node's value contains the command to be executed.
 *	For a better comprehension, open the vdf files provided with this example.
 *
 */

#include <amxmodx>
#include <amxmisc>
#include <vdf>

#define PLUGIN "vdf menu"
#define VERSION "1.04"
#define AUTHOR "commonbullet"

// in this simple plugin I won't handle nodes that
// can't be displayed in one page
#define MAX_NODES_PER_PAGE 8


// search in this directoty - Make sure you have this folder in mod's directory
new g_MenuComDefaultDir[] = {"menucom"}

// main menu file name
new g_MenuFile[] = {"main_menu.vdf"}

// stores the current main node from where menu options are taken
new VdfNode:g_CurrentNode

// stores the main menu vdf tree
new VdfTree:g_MainMenu

// stores the current tree (the one that's being displayed)
new VdfTree:g_CurrentMenu

// stores all loaded nodes in current menu's page
new VdfNode:g_NodeList[MAX_NODES_PER_PAGE]


public plugin_init()
{

	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_menucmd(register_menuid("CommandMenu"), 1023, "commands_handler")
	register_concmd("vdfmenu", "menu_commands")	
	register_concmd("amx_vdfmenu", "menu_switch")
	
	create_mainmenu()
}


public create_mainmenu()
{
	// this function creates the main menu
	
	new menufile[64]	// menu file names
	new cmd[44]		// used to format the command string	
	new VdfNode:rootnode	// node pointer
	new VdfNode:node	// child nodes
	new dir			// directory pointer
	new sp			// stores the .vdf position of a filename string	
	new counter		// for counting root nodes childs
	
	// add menu's directoty into path
	format(menufile, 63, "%s/%s", g_MenuComDefaultDir, g_MenuFile)

	// this creates a brand new vdf tree
	// when the tree is created, a root node is added
	g_MainMenu = vdf_create_tree(menufile)
	
	// if it hasn't been created for some reason, quit
	if(!g_MainMenu)
		return
	
	// root node key's is the menu title
	rootnode = vdf_get_root_node(g_MainMenu)
	vdf_set_node_key(rootnode, "Main Menu")
	
	// read menus' directory  set (in g_MenuComDefaultDir)
	dir = open_dir(g_MenuComDefaultDir, menufile, 31)
	
	while(next_file(dir, menufile, 63) && counter < MAX_NODES_PER_PAGE) {
		
		// simple filtering .vdf files
		if((sp = strfind(menufile, ".vdf")) > -1) {
			 
			// if it's the main menu file, skip
			if(equal(menufile, g_MenuFile))
				continue
			
			// appends new a child node into the rootnode of the menu tree
			node = vdf_append_child_node(g_MainMenu, rootnode)
			
			// node value stores the command
			// menu_cmd is the name of a commad registered by this plugin
			format(cmd, 44, "amx_vdfmenu %s", menufile)
			vdf_set_node_value(node, cmd)
			
			// node key stores the menu name,
			// this removes extension first, by placing a null character
			// on ".vdf" position
			menufile[sp] = 0			
			vdf_set_node_key(node, menufile)
			counter++			
		}
	}
			
	// no nodes were written, this is not a valid main menu
	if(!counter) {
		
		// free tree memory
		vdf_remove_tree(g_MainMenu)
		
		// then, it's important to set the global pointer to NULL
		// so we won't be trying to read from it later
		// - otherwise crash is coming
		g_MainMenu = VDF_NULL_TREE 
	}
	
	// else we've got a tree, let's save it.
	else {
		vdf_save(g_MainMenu)
		client_print(0, print_chat, "Vdf menu has been created type amx_vdfmenu in console to open it.")
	}
}

public menu_switch(id)
{
	// stores the argument	
	//new argv[32]
	new args[63]
	
	read_args(args, 62)
	
	// flag if it's main menu to be displayed
	new openmain
	
	
	// no arguments - open main menu
	if(!args[0])
		openmain = 1
	
	else {
		new filename[65]
		format(filename, 64, "%s/%s", g_MenuComDefaultDir, args)
		
		// opening main menu or a secondary menu
		// depending on arguments	
		if( !equali(filename, g_MenuComDefaultDir) && // no valid filename ?
		     file_exists(filename) && // file exists?
		     !equali(filename, g_MenuFile)) { //	is that the main menu?
			
			// last custom menu might have not been destroyed properly
			if(g_CurrentMenu && g_CurrentMenu != g_MainMenu) {
				vdf_remove_tree(g_CurrentMenu)
				g_CurrentMenu = VDF_NULL_TREE
			}
			
			// load the secondary menu
			g_CurrentMenu = vdf_open(filename)
			
			// if it failed on creating, switch back to main menu
			if(!g_CurrentMenu)
				openmain = 1
		}
		else
			openmain = 1		
	}
	if(openmain) {
		// remember when I said that you should set it to 0
		// when removing main menu?
		// now we can check its consistency;
		if(!g_MainMenu)
			return PLUGIN_HANDLED
		g_CurrentMenu = g_MainMenu
	}
	
	g_CurrentNode = VDF_NULL_NODE
	
	//open menu
	menu_commands(id)
	
	return PLUGIN_HANDLED
		
}

public menu_commands(id)
{
	if(!g_CurrentMenu)
		return
	
	new 	VdfNode:parent		// stores the parent node if current branch has one
	new 	VdfNode:node		// used as iterator
	new 	VdfNode:rootnode	// stores the rootnode
	new 	menukeys		// keys bitset
	static 	key[32]			// to store key values
	static  menubody[288]		// menu text body	
	new	nodecount		// to count nodes included
	
	// the parameter for vdf_get_root_node is a tree and not a node!
	rootnode = vdf_get_root_node(g_CurrentMenu)
	
	
	if(!g_CurrentNode) {
		// the topmost node in menu options is the first child of root node
		g_CurrentNode = vdf_get_child_node(rootnode)
		parent = VDF_NULL_NODE
	}
	else {
		// get the first child at a specific branch
		g_CurrentNode = vdf_get_first_node(g_CurrentNode)
		parent = vdf_get_parent_node(g_CurrentNode)
	}	
	
	// the root node key contains the menu title
	vdf_get_node_key(rootnode, key, 31)
	format(menubody, 22, "\r%s\y^n", key)
	
	// set up for menu building start
	node  = g_CurrentNode
	nodecount = 0
	
	// Exit option
	menukeys = 1 << 9
	
	while(nodecount < MAX_NODES_PER_PAGE && node) {		
		
		// gets the option and includes in the menu body
		vdf_get_node_key(node, key, 31)		
		format(menubody[strlen(menubody)], 288 - strlen(menubody),
		    "^n%d. %s", nodecount + 1, key)		
		
		// adds a (+) signal if this node can be expanded
		if(vdf_get_child_node(node))
			strcat(menubody, " (+)", 287)
		
		// update valid keys and node list
		menukeys |= 1 << nodecount
		g_NodeList[nodecount++] = node
		
		// moves to the next node
		node = vdf_get_next_node(node)
	}
	
	strcat(menubody, "^n\w", 287)
	
	// if it has a parent, adds 'back' option
	if(parent) {
		strcat(menubody, "^n9. Back", 287)
		menukeys |= 1 << 8
	}
	
	strcat(menubody, "^n0. Exit", 287)
	show_menu(id, menukeys, menubody, _, "CommandMenu")			
}

public commands_handler(id, key)
{
	static cmd[65]
	
	if(key < MAX_NODES_PER_PAGE) {
	
		// if the selected node has a child update g_CurrentNode
		// and display menu again
		if((g_CurrentNode = vdf_get_child_node(g_NodeList[key])))
			menu_commands(id)
		else {
			//gets key value and executes it
			vdf_get_node_value(g_NodeList[key], cmd, 64)
			
			// destroys tree if it's not the main menu tree 
			if(g_CurrentMenu != g_MainMenu) {
				vdf_remove_tree(g_CurrentMenu)
				g_CurrentMenu = VDF_NULL_TREE
			}			
			server_cmd(cmd)
		}
	}
	else if(key == 8) {
	
		// get back
		g_CurrentNode  = vdf_get_parent_node(g_CurrentNode);
		if(g_CurrentNode == vdf_get_root_node(g_CurrentMenu))
			g_CurrentNode = VDF_NULL_NODE
		menu_commands(id)
	}
	
	// on exit destroy if it's a secondary menu
	else if(g_CurrentMenu != g_MainMenu) {
		vdf_remove_tree(g_CurrentMenu)
		g_CurrentMenu = VDF_NULL_TREE
	}
}

