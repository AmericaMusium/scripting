#include <amxmodx>
#include <amxmisc>
#include <fun>
#include <hamsandwich>
#include <engine>
#include <fakemeta>
#include <fakemeta_util>
#include <colorchat>
#include <dodx>
#include <dodfun>
 
 
#define PLUGIN "DOD_MENU_CLASS"
#define VERSION "1.0"
#define AUTHOR "author"
 
 
public plugin_init() {
 
 
register_plugin(PLUGIN, VERSION, AUTHOR)
register_clcmd( "say /class", "ClassMenu" );
}
public ClassMenu(id)
{
new menu = 
menu_create("\rClass Menu :", "menu_handler");
 
 
menu_additem(menu, "\wLeone", "1", 0);
menu_additem(menu, "\wCommando", "2", 0);
menu_additem(menu, "\wMachine Gun", "3", 0);
menu_additem(menu, "\wRambo", "4", 0);
menu_additem(menu, "\wSchmidt", "5", 0);
menu_additem(menu, "\wKrieg", "6", 0);
menu_additem(menu, "\wIDF Defender", "7", 0);
menu_additem(menu, "\wRifle", "8", 0);
menu_additem(menu, "\wMaverick", "9", 0);
menu_additem(menu, "\wClarion", "10", 0);
menu_additem(menu, "\wBullpup", "11", 0);
 
 
menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
menu_display(id, menu, 0);
 
 
}
public menu_handler(id, menu, item)
{
if( item == MENU_EXIT 
)
{
menu_destroy(menu);
return PLUGIN_HANDLED;
 
 
}
new data[6], iName[64];
new access, callback;
 
 
menu_item_getinfo(menu, item, access, data,5, iName, 63, callback);
new 
key = str_to_num(data);
switch(key)
 
 
{
case 1:
{
ColorChat(id, RED,"^x04[ Class ]^x01 You Have Chosen The Class ^x03Leone^x03 ^x04[Shotgun][Deagle][HE Grenade]^x04");

}
case 
2:
{
ColorChat(id, RED,"^x04[ Class ]^x01 You Have Chosen The Class^x03 Commando^x03 ^x04[Dak Dak][Usp][HE Grenade]^x04");

}
case 3: 
 
{
ColorChat(id, RED,"^x04[ Class ]^x01 You Have Chosen The Class ^x03Machine Gun^x03 ^x04[Mp5][Glock][Smoke Grenade]^x04");

}
case 
4:
{
ColorChat(id, RED,"^x04[ Class ]^x01 You Have Chosen The Class ^x03Rambo^x03 ^x04[Ak47][Five-Seven][HE Grenade]^x04");

}
case 5:
{ 
 
ColorChat(id, RED,"^x04[ Class ]^x01 You Have Chosen The Class ^x03Schmidt^x03 ^x04[Scout][Deagle][Flash Bang]^x04");

}
case 
6:
{
ColorChat(id, RED,"^x04[ Class ]^x01 You Have Chosen The Class ^x03Krieg^x03 ^x04[Krieg 552][Usp][Smoke Grenade]^x04");

}
case 
7:
{
ColorChat(id, RED,"^x04[ Class ]^x01 You Have Chosen The Class ^x03IDF Defender^x03 ^x04[Galil][Glock][He Grenade]^x04");

}
case 
8:
{
ColorChat(id, RED,"^x04[ Class ]^x01 You Have Chosen The Class ^x03Rifle^x03 ^x04[Sniper][Five-Seven][Flash Bang]^x04");

}
case 
9:
{
ColorChat(id, RED,"^x04[ Class ]^x01 You Have Chosen The Class ^x03Maverick^x03 ^x04[M4a1][Deagle][Smoke Grenade]^x04");

}
case 
10:
{
ColorChat(id, RED,"^x04[ Class ]^x01 You Have Chosen The Class^x03 Clarion^x03 ^x04[Famas][Usp][He Grenade]^x04");

}
case 
11:
{
ColorChat(id, RED,"^x04[ Class ]^x01 You Have Chosen The Class^x03 Bullpup^x03 ^x04[Aug][Glock][Flash Bang]^x04");

}
}
} 
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1049\\ f0\\ fs16 \n\\ par }
*/
