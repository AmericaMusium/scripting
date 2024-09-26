/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>
#include <fakemeta_util>
#include <fun>
#include <dodx>
#include <dodfun>
#include <dodconst>
#include <dodstats>
#include <hamsandwich>

#define PLUGIN "DATA SAVER"
#define VERSION "0.0"
#define AUTHOR "[America][TheVaskov]"

new const g_szSaveDirName[] = "ds_mapsarray" // имя папки для сохранения
// new const g_szFileName[] = "Animator.ini" NOT USED

new cv_debug
new g_szBuffer[1000]; //Объявим массив для записи информации из файла

new szData[256]; 	// строка полного пути нахождения файла.
new szBuffer[256]; // временный буффер



public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	cv_debug = register_cvar("debug","1")
	
	register_clcmd("say ds_create", "ds_CreateFile")
	register_clcmd("say ds_load", "ds_LoadFile")
	register_clcmd("say ds_menu", "ds_openmenu")

	register_clcmd("say build", "object_build")
	
	
	// menu open

}


public ds_CreateFile()
{

	//     sizeof(array) = 32  
	//   charsmax(array) = 31
	// записывает в массив szData строку " где %с  = g_szSaveDirName )
	
	// создать папку
	formatex(szData,charsmax(szData),"addons/amxmodx/configs/%s",g_szSaveDirName);
	if(!dir_exists(szData))
		mkdir(szData);
	
	// создать файл
	get_mapname(szBuffer,255)
	formatex(szData,charsmax(szData),"addons/amxmodx/configs/%s/%s.ini",g_szSaveDirName, szBuffer);

	new message[128] 
	if(!file_exists(szData))
	{	
		// если файл НЕ существует записать иинфу 
		message = "File create this is start" 
		write_file(szData, message );
	}
	else
	{
		// если файл существует записать иинфу добавит строку.
		message = "File Exist . add string" 
		write_file(szData, message );
	}
		
	
	if(debug)  client_print(0,print_chat,"ds_CreateFile: %s message %s ", szData , message)
	
	
	/*
	/// открываем файл с флагом РЕАД !ЧИТАТЬ
	new f = fopen(szData,"r");
	g_szArray__MenuName = ArrayCreate(256);
	g_szArray__ModelsWay = ArrayCreate(256);

	new szMenuName[256],szFileWay[256];
	while(!feof(f)) {
		fgets(f,szData,charsmax(szData));
		trim(szData);

		if(szData[0] == ';' || szData[0] == EOS)
			continue;
		
		if(szData[0] == '"') {
			parse(szData,
				szMenuName,charsmax(szMenuName),
				szFileWay,charsmax(szFileWay)
			);

			remove_quotes(szMenuName);
			remove_quotes(szFileWay);

			ArrayPushString(g_szArray__MenuName,szMenuName);
			ArrayPushString(g_szArray__ModelsWay,szFileWay);

			continue;
		}

		continue;
	}
	fclose(f);

	g_iArray__ModelID = ArrayCreate(64);
	*/

}

public ds_LoadFile(id)
{	
	
	// Проверяем существование файла
    if(!file_exists(szData))
        return;

	// открываем файл с флагом R - read !ЧИТАТЬ
	new file = fopen(szData,"r");
	/*
	g_szArray_MenuName = ArrayCreate(256);
	g_szArray_ModelsWay = ArrayCreate(256);
	*/
	new szMenuName[256], szFileWay[256];

	while(!feof(file))
	{
		/// пока не достигнут конец файла.
		//Записываем содержимое файла в массив
        fgets(file, g_szBuffer, charsmax(g_szBuffer));

		
        console_print(id, g_szBuffer);
        //Пропускаем пустые строки
        if(!g_szBuffer[0])
            continue;
	}
	//Закрываем файл
    fclose(file);
	ds_print_console(id);
	if(debug)  client_print(0,print_chat,"FILE LOADED: %s ", szData)

	
}

public ds_print_console(id)
{

    for(new i = 0; i < strlen(g_szBuffer); i++)
        console_print(0, g_szBuffer[i]);
}











///////////////////
/*

public ds_openmenu(){
	
	/// create and open menu
	
	new ds_menu = menu_create("DS Menu","ds_menu_case")
	menu_additem(ds_menu,"Garand","1",0)
	menu_additem(ds_menu, "M1 Carbine", "2", 0)
	menu_additem(ds_menu,"Thompson","3",0)
	menu_additem(ds_menu,"Grease Gun","4",0)
	menu_additem(ds_menu,"Springfield","5",0)
	menu_additem(ds_menu,"BAR","6",0)
	
}
/*
public ds_menu_case(key){
	
	if (key == MENU_EXIT)
	{
		menu_destroy(ds_menu_case)
		return PLUGIN_HANDLED
	}
	new data[6],iName[64]
	new access,callback
	menu_item_getinfo(ds_menu,item,access,data,5,iName,63,callback)
	new key = str_to_num(data)
	
	switch(key)
	{
		case 1:{
			//
		}
		case 2:{
			//
		}
		case 3:{
			//
		}
		case 4:{
			//
		}
		case 5:{ 
			//
			}
	}
}
*/