

new const VERSION[] = "1.0";

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


new const g_szFileName[] = "Animator.ini";              //Путь до файла с моделями/спрайтами: addons/amxmodx/configs/...
new const g_szSaveDirName[] = "AnimatorSave";           //Путь до папки с сохранениями: addons/amxmodx/configs/...

new const g_szClassname[] = "AnimatorClassName";

enum {
	_MODEL = 3,
	_COORDS,
	_ANGLES
};

//Dla ebanogo kostila
enum {
	KL_MODEL,
	KL_MENU,
	KL_MODEL_ADD
};

enum _:XYZ {
	Float:X,Float:Y,Float:Z
};

new const g_iStep[] = {
	1,
	5,
	10,
	50,
	100
};

new
	Array:g_szArray__ModelsWay,
	Array:g_szArray__MenuName;

new
	Array:g_iArray__ModelID;

new
	g_pCvarString__ClCmd[256],
	g_pCvarString__FlagAccess[64];

new
	p_iSettingsStep[33],
	p_iItem[33][3];//Kostil` ebaniy

public plugin_precache() {
	Func__CreateFile();
	Func__CreateCvars();

	new szData[256];
	for(new iModel;iModel<ArraySize(g_szArray__ModelsWay);iModel++) {
		ArrayGetString(g_szArray__ModelsWay,iModel,szData,charsmax(szData));

		if(file_exists(szData))
			precache_model(szData);
		else {
			server_print("[Animator] Error load file: %s",szData);
			ArrayDeleteItem(g_szArray__ModelsWay,iModel);
		}
	}

	Func__LoadSaveFile();
}

public plugin_init() {
	register_plugin("Animator Of Sprites And Models",VERSION,"b0t.");

	Func__RegisterClCmd(g_pCvarString__ClCmd,"Show__GetModelMenu");

	register_clcmd("set_sequence","Func__SetSequence");
	register_clcmd("set_framerate","Func__SetFramerate");
}

public Show__GetModelMenu(const id) {
	if(!(get_user_flags(id) & read_flags(g_pCvarString__FlagAccess)))
		return client_print(id,print_center,"You have not flag access");

	if(ArraySize(g_iArray__ModelID))
		p_iItem[id][KL_MODEL_ADD] = ArraySize(g_iArray__ModelID)-1;

	new iMenu = menu_create("\wВыбор модели","GetModelMenu__Handler");

	new szMenu[256];
	for(new iItem;iItem<ArraySize(g_szArray__MenuName);iItem++) {
		ArrayGetString(g_szArray__MenuName,iItem,szMenu,charsmax(szMenu));

		menu_additem(iMenu,szMenu);
	}

	Func__DisplayMenu(id,iMenu,"Выход");

	return PLUGIN_HANDLED;
}

public GetModelMenu__Handler(const id,const iMenu,const iItem) {
	if(iItem == MENU_EXIT)
		return menu_destroy(iMenu);
	
	menu_destroy(iMenu);

	p_iItem[id][KL_MODEL] = iItem;
	Show__SpawnMenu(id);

	return PLUGIN_HANDLED;
}

public Show__SpawnMenu(const id) {
	new iMenu = menu_create(
		fmt(
			"\wНастройки спавна^n\
			\dНа карте: \r%i^n\
			\dВзаимодействуем с \r%i \dмоделью",
			
			ArraySize(g_iArray__ModelID),
			p_iItem[id][KL_MODEL_ADD] == 0 && ArraySize(g_iArray__ModelID) ? 1 : !ArraySize(g_iArray__ModelID) ? 0 : p_iItem[id][KL_MODEL_ADD]+1
		),
		"SpawnMenu__Handler"
	);

	menu_additem(iMenu,"Создать");
	menu_additem(iMenu,"\rУдалить^n^n^t^t\dНастройки:");

	menu_additem(iMenu,"модели^n");

	menu_additem(iMenu,"Координат");
	menu_additem(iMenu,"Углов^n");

	menu_additem(iMenu,"Переключить на следующую");
	menu_additem(iMenu,"Переключить на предыдущую^n");

	menu_additem(iMenu,"Сохранить");

	menu_setprop(iMenu,MPROP_PERPAGE,0);
	menu_setprop(iMenu,MPROP_EXIT,MEXIT_FORCE);

	menu_addblank2(iMenu);

	Func__DisplayMenu(id,iMenu,"Назад");

	return PLUGIN_HANDLED;
}

public SpawnMenu__Handler(const id,const iMenu,const iItem) {
	if(iItem == MENU_EXIT) {
		menu_destroy(iMenu);
		Show__GetModelMenu(id);
		
		return PLUGIN_HANDLED;
	}

	menu_destroy(iMenu);

	switch(iItem+1) {
		case 1: {
			new iOrigin[XYZ],Float:fOrigin[XYZ];
			get_user_origin(id,iOrigin,Origin_AimEndEyes);
			IVecFVec(iOrigin,fOrigin);

			new Float:fAngles[XYZ];
			get_entvar(id,var_v_angle,fAngles);
			fAngles[X] = fAngles[Y] = fAngles[Z] = 0.0;

			new szModelWay[256];
			ArrayGetString(g_szArray__ModelsWay,p_iItem[id][KL_MODEL],szModelWay,charsmax(szModelWay));
			Func__CreateModel(id,szModelWay,fOrigin,fAngles,0,-1.0);
		}
		case 2: {
			if(!ArraySize(g_iArray__ModelID))
				return Show__SpawnMenu(id);

			new iEnt = UTIL_GetModelID(id);
			ArrayDeleteItem(g_iArray__ModelID,p_iItem[id][KL_MODEL_ADD]);
			set_entvar(iEnt,var_flags,FL_KILLME);

			p_iItem[id][KL_MODEL_ADD] = ArraySize(g_iArray__ModelID)-1;
		}
		case 3..5: {
			p_iItem[id][KL_MENU] = iItem + 1;
			return Show__SettingsMenu(id);
		}
		case 6: p_iItem[id][KL_MODEL_ADD] = ArraySize(g_iArray__ModelID) ? ((++p_iItem[id][KL_MODEL_ADD]) % ArraySize(g_iArray__ModelID)) : 0;
		case 7: p_iItem[id][KL_MODEL_ADD] = ArraySize(g_iArray__ModelID) ? ((--p_iItem[id][KL_MODEL_ADD]) % ArraySize(g_iArray__ModelID)) : 0;
		case 8: {
			Func__SaveAllModels();
		}
	}

	Show__SpawnMenu(id);

	return PLUGIN_HANDLED;
}

public Show__SettingsMenu(const id) {
	if(!ArraySize(g_iArray__ModelID)) {
		client_print(id,print_center,"Not model!");
		return Show__SpawnMenu(id);
	}

	static iEnt;
	iEnt = UTIL_GetModelID(id);

	static Float:fOrigin[XYZ],Float:fAngles[XYZ],iSequence,Float:fFrame;
	
	get_entvar(iEnt,var_origin,fOrigin);
	get_entvar(iEnt,var_angles,fAngles);
	
	iSequence = get_entvar(iEnt,var_sequence);
	fFrame = Float:get_entvar(iEnt,var_framerate);

	static iType;
	iType = p_iItem[id][KL_MENU];

	new iMenu = menu_create(
		fmt("\wнастройки модели^n\
			Координаты \y%.1f \r| \y%.1f \r| \y%.1f^n\
			\wУглы \y%.1f \r| \y%.1f \r| \y%.1f^n\
			\wАнимация \y%i^n\
			\wСкорость анимации \y%.1f",
			fOrigin[X],fOrigin[Y],fOrigin[Z],
			fAngles[X],fAngles[Y],fAngles[Z],
			iSequence,
			fFrame
		),
		"SettingsMenu__Handler"
	);

	if(iType != _MODEL)
		menu_additem(iMenu,fmt("Шаг: \y%i^n",g_iStep[p_iSettingsStep[id]]),"set_step");

	switch(iType) {
		case _MODEL: {
			menu_additem(iMenu,"Анимация","set_sequence");
			menu_additem(iMenu,"Скорость анимации","set_framerate");
		}
		case _COORDS,_ANGLES: {
			menu_additem(iMenu,"X\r++","1");
			menu_additem(iMenu,"X\y--^n","2");

			menu_additem(iMenu,"Y\r++","3");
			menu_additem(iMenu,"Y\y--^n","4");

			menu_additem(iMenu,"Z\r++","5");
			menu_additem(iMenu,"Z\y--^n","6");
		}
	}

	Func__DisplayMenu(id,iMenu,"Назад");

	return PLUGIN_HANDLED;
}

public SettingsMenu__Handler(const id,const iMenu,const iItem) {
	if(iItem == MENU_EXIT) {
		menu_destroy(iMenu);
		
		Show__SpawnMenu(id);

		return PLUGIN_HANDLED;
	}

	new szData[64];
	menu_item_getinfo(iMenu,iItem, .info = szData, .infolen = charsmax(szData));
	menu_destroy(iMenu);

	if(equal(szData,"set_step")) {
		p_iSettingsStep[id] = (++p_iSettingsStep[id]) % sizeof(g_iStep);
		Show__SettingsMenu(id);
		
		return PLUGIN_HANDLED;
	}

	if(equal(szData,"set_sequence") || equal(szData,"set_framerate")) {
		client_print_color(id,print_team_red,"Введите значение^4!");
		client_print_color(id,print_team_red,"Пример для анимации^4:^3 1");
		client_print_color(id,print_team_red,"Пример для скорости анимации^4:^3 1.0");

		//Show__SettingsMenu(id);

		client_cmd(id,"messagemode %s",szData);

		return PLUGIN_HANDLED;
	}

	new Float:fNewVec[XYZ];
	switch(str_to_num(szData)) {
		case 1: fNewVec[X] += g_iStep[p_iSettingsStep[id]];
		case 2: fNewVec[X] -= g_iStep[p_iSettingsStep[id]];
		case 3: fNewVec[Y] += g_iStep[p_iSettingsStep[id]];
		case 4: fNewVec[Y] -= g_iStep[p_iSettingsStep[id]];
		case 5: fNewVec[Z] += g_iStep[p_iSettingsStep[id]];
		case 6: fNewVec[Z] -= g_iStep[p_iSettingsStep[id]];
	}

	new iEnt = UTIL_GetModelID(id);

	new iType = p_iItem[id][KL_MENU];
	switch(iType) {
		case _COORDS: {
			new Float:fOrigin[XYZ];
			get_entvar(iEnt,var_origin,fOrigin);

			xs_vec_add_ex(fOrigin,fNewVec);

			engfunc(EngFunc_SetOrigin,iEnt,fOrigin);
		}
		case _ANGLES: {
			new Float:fAngles[XYZ];
			get_entvar(iEnt,var_angles,fAngles);

			xs_vec_add_ex(fAngles,fNewVec);

			set_entvar(iEnt,var_angles,fAngles);
		}
	}

	Show__SettingsMenu(id);

	return PLUGIN_HANDLED;
}

public Func__CreateModel(const id,const szModelWay[],const Float:fOrigin[XYZ],const Float:fAngles[XYZ],const iSequence,const Float:fFrame) {
	new iEnt = rg_create_entity(szModelWay[0] == 'm' ? "info_target" : "env_sprite");

	if(is_nullent(iEnt))
		return;

	engfunc(EngFunc_SetModel,iEnt,szModelWay);
	engfunc(EngFunc_SetOrigin,iEnt,fOrigin);

	set_entvar(iEnt,var_angles,fAngles);

	set_entvar(iEnt,var_classname,g_szClassname);

	switch(szModelWay[0]) {
		case 's': {
			set_entvar(iEnt,var_renderfx,kRenderFxNone);
			set_entvar(iEnt,var_rendercolor,Float:{255.0,255.0,255.0});
			set_entvar(iEnt,var_rendermode,kRenderTransAdd);
			set_entvar(iEnt,var_renderamt,float(255));
			//set_entvar(iEnt,var_scale,0.20);

			set_entvar(iEnt,var_animtime,get_gametime());
			set_entvar(iEnt,var_framerate,fFrame == -1.0 ? 20.0 : fFrame);

			set_entvar(iEnt,var_spawnflags,SF_SPRITE_STARTON);
			dllfunc(DLLFunc_Spawn,iEnt);
		}
		case 'm': {
			set_entvar(iEnt,var_solid,SOLID_NOT);
			set_entvar(iEnt,var_movetype,MOVETYPE_NOCLIP);

			set_entvar(iEnt,var_sequence,iSequence);
			set_entvar(iEnt,var_framerate,fFrame == -1.0 ? 1.0 : fFrame);
		}
	}

	ArrayPushCell(g_iArray__ModelID,iEnt);
	if(id != -1)
		p_iItem[id][KL_MODEL_ADD] = ArraySize(g_iArray__ModelID)-1;
}

public Func__SaveAllModels() {
	new szMapName[MAX_MAPNAME_LENGTH];
	get_mapname(szMapName,charsmax(szMapName));

	new szFile[256];
	formatex(szFile,charsmax(szFile),"addons/amxmodx/configs/%s/%s.ini",g_szSaveDirName,szMapName);

	if(file_exists(szFile))
		delete_file(szFile);


	new szData[256];
	new szModel[256],Float:fOrigin[XYZ],Float:fAngles[XYZ],iSequence,Float:fFrame;

	new iEnt;
	while((iEnt = rg_find_ent_by_class(iEnt,g_szClassname))) {
		get_entvar(iEnt,var_model,szModel,charsmax(szModel));
		
		get_entvar(iEnt,var_origin,fOrigin);
		get_entvar(iEnt,var_angles,fAngles);
		iSequence = get_entvar(iEnt,var_sequence);
		fFrame = Float:get_entvar(iEnt,var_framerate);

		formatex(szData,charsmax(szData),
			"^"%s^" ^"%.1f^" ^"%.1f^" ^"%.1f^" ^"%.1f^" ^"%.1f^" ^"%.1f^" ^"%i^" ^"%.1f^"",
			szModel,
			fOrigin[X],fOrigin[Y],fOrigin[Z],
			fAngles[X],fAngles[Y],fAngles[Z],
			iSequence,
			fFrame
		);

		write_file(szFile,szData);
	}
}

public Func__LoadSaveFile() {
	new szMapName[MAX_MAPNAME_LENGTH];
	get_mapname(szMapName,charsmax(szMapName));
	formatex(szMapName,charsmax(szMapName),"%s.ini",szMapName);

	new szDir[256],szFile[256],iData;
	formatex(szDir,charsmax(szDir),"addons/amxmodx/configs/%s",g_szSaveDirName);

	iData = open_dir(szDir,szFile,charsmax(szFile));

	if(!iData)
		return PLUGIN_HANDLED;
	
	new szOpenFile[256];
	while(next_file(iData,szFile,charsmax(szFile))) {
		if(equali(szMapName,szFile)) {
			formatex(szOpenFile,charsmax(szOpenFile),"%s/%s",szDir,szMapName);
			break;
		}
	}

	if(szOpenFile[0] == EOS)
		return PLUGIN_HANDLED;
	
	new szData[256];
	new f = fopen(szOpenFile,"r");

	new Float:fOrigin[XYZ],Float:fAngles[XYZ];
	new szModel[256],szOrigin[XYZ][32],szAngles[XYZ][32],szSequence[3],szFrame[4];
	while(!feof(f)) {
		fgets(f,szData,charsmax(szData))
		trim(szData);

		if(szData[0] != '"')
			continue;
		
		parse(szData,
			szModel,charsmax(szModel),
			szOrigin[X],31,
			szOrigin[Y],31,
			szOrigin[Z],31,
			szAngles[X],31,
			szAngles[Y],31,
			szAngles[Z],31,
			szSequence,charsmax(szSequence),
			szFrame,charsmax(szFrame)
		);

		if(!file_exists(szModel)) {
			server_print("[Animator] Error load file: %s",szModel);
			continue;
		}

		fOrigin[X] = str_to_float(szOrigin[X]);
		fOrigin[Y] = str_to_float(szOrigin[Y]);
		fOrigin[Z] = str_to_float(szOrigin[Z]);

		fAngles[X] = str_to_float(szAngles[X]);
		fAngles[Y] = str_to_float(szAngles[Y]);
		fAngles[Z] = str_to_float(szAngles[Z]);

		Func__CreateModel(
			-1,
			szModel,
			fOrigin,
			fAngles,
			str_to_num(szSequence),
			str_to_float(szFrame)
		);

		continue;
	}
	fclose(f);

	return PLUGIN_HANDLED;
}

public Func__SetSequence(const id) {
	new szValue[10];
	read_argv(read_argc()-1,szValue,charsmax(szValue));
	trim(szValue);

	if(!is_str_num(szValue))
		return client_print(id,print_center,"Invalid value");

	new iEnt = UTIL_GetModelID(id);
	set_entvar(iEnt,var_sequence,str_to_num(szValue));

	Show__SettingsMenu(id);

	return PLUGIN_HANDLED;
}

public Func__SetFramerate(const id) {
	new szValue[10];
	read_argv(read_argc()-1,szValue,charsmax(szValue));
	trim(szValue);

	if(!is_str_num(szValue) && contain(szValue,".") == -1)
		return client_print(id,print_center,"Invalid value");

	new iEnt = UTIL_GetModelID(id);
	set_entvar(iEnt,var_framerate,str_to_float(szValue));

	Show__SettingsMenu(id);

	return PLUGIN_HANDLED;
}

public Func__RegisterClCmd(const szCmd[],const szFunc[]) {
	register_clcmd(fmt("%s",szCmd),szFunc);
	register_clcmd(fmt("say /%s",szCmd),szFunc);
	register_clcmd(fmt("say_team /%s",szCmd),szFunc);
}

public Func__DisplayMenu(const id,const iMenu,const szExitName[]) {
	menu_setprop(iMenu,MPROP_NEXTNAME,"Далее");
	menu_setprop(iMenu,MPROP_BACKNAME,"Назад");
	menu_setprop(iMenu,MPROP_EXITNAME,szExitName);

	menu_setprop(iMenu,MPROP_NUMBER_COLOR,"\y");

	if(is_user_connected(id))
		menu_display(id,iMenu);
	else
		menu_destroy(iMenu);
}

public Func__CreateFile() {
	new szData[256];
	formatex(szData,charsmax(szData),"addons/amxmodx/configs/%s",g_szSaveDirName);

	if(!dir_exists(szData))
		mkdir(szData);

	formatex(szData,charsmax(szData),"addons/amxmodx/configs/%s",g_szFileName);

	if(!file_exists(szData))
		write_file(szData,"; ^"Имя в меню^" ^"Путь до файла^"");
	
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
}

public Func__CreateCvars() {
	bind_pcvar_string(
		create_cvar(
			"amx_animator_clcmd","anim",
			.description = "Команда для открытия меню(say/say_team/consol)"
		),
		g_pCvarString__ClCmd,charsmax(g_pCvarString__ClCmd)
	);

	bind_pcvar_string(
		create_cvar(
			"amx_animator_flag_access","a",
			.description = "Флаг доступа к команде 'amx_animator_clcmd'"
		),
		g_pCvarString__FlagAccess,charsmax(g_pCvarString__FlagAccess)
	);

	AutoExecConfig(true,"Animator");
}

stock xs_vec_add_ex(Float:fVec[XYZ],const Float:fVecAdd[XYZ]) {
	fVec[X] += fVecAdd[X];
	fVec[Y] += fVecAdd[Y];
	fVec[Z] += fVecAdd[Z];
}

stock UTIL_GetModelID(const id) {
	new iEnt;
	if(p_iItem[id][KL_MODEL_ADD] == ArraySize(g_iArray__ModelID) || ArraySize(g_iArray__ModelID) == 1)
		iEnt = ArrayGetCell(g_iArray__ModelID,ArraySize(g_iArray__ModelID) - 1);
	else
		iEnt = ArrayGetCell(g_iArray__ModelID,p_iItem[id][KL_MODEL_ADD]);
	
	return iEnt;
}
