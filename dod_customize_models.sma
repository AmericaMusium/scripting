#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>
#include <dodx>
#include <dodfun>
#include <fun>
#include <engine>
#include <fakemeta>


#define MAX_BODY_GROUPS_NUMS 16 // imho 16
#define MAX_BODY_GROUPS_SIZE 32 // imho 32
#define MAX_MODELS_IN_TEAM 4
#define MAX_TEAMS 3
#define MAX_MODELNAME 64

#define MAXSTUDIOTRIANGLES 20000 // TODO: tune this
#define MAXSTUDIOVERTS 2048 // TODO: tune this
#define MAXSTUDIOSEQUENCES 2048 // total animation sequences -- KSH incremented
#define MAXSTUDIOSKINS 100 // total textures
#define MAXSTUDIOSRCBONES 512 // bones allowed at source movement
#define MAXSTUDIOBONES 128 // total bones actually used
#define MAXSTUDIOMODELS 32 // sub-models per model
#define MAXSTUDIOBODYPARTS 32
#define MAXSTUDIOGROUPS 16
#define MAXSTUDIOANIMATIONS 2048
#define MAXSTUDIOMESHES 256
#define MAXSTUDIOEVENTS 1024
#define MAXSTUDIOPIVOTS 256
#define MAXSTUDIOCONTROLLERS 8

//menu const buttons
#define BTN_MENU_BACK -10
#define BTN_MENU_SAVE -11
#define BTN_MENU_RESET -12


enum _:m_data
{
        id,
        owner,
        available_models,
        current_model_list_id, // starts from Zero (first is 0)
        body_groups,
        body_size[MAX_BODY_GROUPS_NUMS],
        body_selected[MAX_BODY_GROUPS_NUMS],
        current_body_index
}

new g_costume_ent[MAX_TEAMS][m_data]
new g_Precached_Player_Models_List[MAX_TEAMS][MAX_MODELS_IN_TEAM][MAX_MODELNAME]
new g_team_mdl_file[MAX_MODELS_IN_TEAM*MAX_TEAMS][MAX_MODELNAME] // array for saving precached mdl file

new g_models_precached = 0
new g_player_pev_body[33] = 0 
new g_player_to_g_costume_ent[33]


public plugin_precache()
{
    register_forward(FM_PrecacheModel, "FM_PrecacheModel_P", 1)
}

public plugin_init()
{
	register_plugin("DOD Customize Models", "0.0", "America")
	RegisterHam(Ham_Spawn, "player", "Ham_player_spawn_post", 1) // post
	register_clcmd("say 12", "customize_players_model") 

	set_task(3.0 , "g_costume_ent_create" )

	g_player_to_g_costume_ent[0] = 0
}

public FM_PrecacheModel_P(const szFile[])
{   
	if(containi(szFile, "models/player/") != -1)
	{
	g_models_precached++
	format(g_team_mdl_file[g_models_precached], charsmax(g_team_mdl_file[]), "%s", szFile)
	if ( containi(szFile, "/us-") != -1 || containi(szFile, "/brit-") != -1 ||  containi(szFile, "/ussr") != -1)
	{
		format( g_Precached_Player_Models_List[ALLIES][g_costume_ent[ALLIES][available_models]] , MAX_MODELNAME-1, "%s" ,  szFile)
		g_costume_ent[ALLIES][available_models]++
	}
	if (containi(szFile, "/axis-") != -1 )
	{
		format( g_Precached_Player_Models_List[AXIS][g_costume_ent[AXIS][available_models]] , MAX_MODELNAME-1, "%s" ,  szFile)
		g_costume_ent[AXIS][available_models]++
	}
	server_print(szFile)
	// server_print("ALLIES: %d ; AXIS %d  - player models", g_costume_ent[ALLIES][available_models] , g_costume_ent[AXIS][available_models])
}   

	
}

public Ham_player_spawn_post(idx_player)
{
    if(is_user_alive(idx_player))
    {	
        set_pev(idx_player, pev_body, g_player_pev_body[idx_player])
        return HAM_IGNORED
    }
    return HAM_IGNORED
}


public g_costume_ent_create()
{	
	// start creating g_custume_ent for every team
	for (new i_team = 1; i_team < 3; i_team++ )
	{	
		if( g_costume_ent[i_team][available_models] > 0 )
		{
			// searching spawn ent for get origin to assign for g_custume_ent
			new search_classname[32] 
			new Float:f_Origin[3]
			switch (i_team)
			{
				case ALLIES:{
					format(search_classname, 31, "info_player_allies" )
				}
				case AXIS:{
					format(search_classname, 31, "info_player_axis" )
				}
			}
			new ent = -1
			ent = find_ent_by_class(ent, search_classname)
			if(ent != -1)
			{	
				pev(ent, pev_origin, f_Origin)	
				server_print( "[g_costume_ent_create] search_classname %s id %d " , search_classname , ent )
				//remove_entity(ent)
				new next_ent = -1
				next_ent = find_ent_by_class(ent, search_classname)
				if(next_ent != -1)
					{
						server_print( "[g_costume_ent_create] 2222222222222 search_classname %s id %d " , search_classname , next_ent )
						remove_entity(ent)
					}
			
			}

			//f_Origin[2] += 50.0

			// create g_costume_ent 
			new idx_g_costume_ent = create_entity("info_target")
			set_pev(idx_g_costume_ent, pev_solid, SOLID_TRIGGER)   
			set_pev(idx_g_costume_ent, pev_movetype, MOVETYPE_FLY)
			// set_pev(idx_g_costume_ent, pev_gravity, 1.0)
			// entity_set_size(idx_g_costume_ent, Float:{-16.0, -16.0, -36.0}, Float:{16.0, 16.0, 16.0}) 
			set_pev(idx_g_costume_ent, pev_avelocity, Float:{0.0, 10.0, 0.0})	

			set_pev(idx_g_costume_ent, pev_effects, EF_DIMLIGHT) 

			//

			set_pev(idx_g_costume_ent, pev_origin, f_Origin)
			
			if(!pev_valid(idx_g_costume_ent)) 
			{
				server_print("!!!!!!!!!!!!!! [g_costume_ent_create] g_costume_ent not valid")
				return PLUGIN_CONTINUE  
			}
			
			g_costume_ent[i_team][id] = idx_g_costume_ent 
			g_costume_ent[i_team][owner] = 0
			g_costume_ent[i_team][current_model_list_id] = 0 //random_num( 0, g_costume_ent[i_team][available_models] ) // start from zero
			g_costume_ent[i_team][current_body_index] = 0
				
			server_print( "++++++++++[g_costume_ent_create] idx_g_costume_ent %d success for %d , %d", idx_g_costume_ent, i_team, g_costume_ent[i_team][id])

			engfunc(EngFunc_SetModel, g_costume_ent[i_team][id],  g_Precached_Player_Models_List[i_team][g_costume_ent[i_team][current_model_list_id]]) 
			entity_set_int(idx_g_costume_ent, EV_INT_sequence, 132) //  
			entity_set_float(idx_g_costume_ent, EV_FL_animtime, get_gametime()) //  
			entity_set_float(idx_g_costume_ent, EV_FL_framerate, 1.0) //  
			entity_set_float(idx_g_costume_ent, EV_FL_frame, 0.0) //  
			//
			server_print("model for fake ent: %s", g_Precached_Player_Models_List[i_team][g_costume_ent[i_team][current_model_list_id]])
			}
		else
		{
			server_print( "!!! [g_costume_ent_create] ! Models for team #%d NOT available (ALLIES == 1 ; AXIS == 2)" , i_team)
		}
	}
	return PLUGIN_CONTINUE
}




public customize_players_model(idx_player)
{	

	// проверить наличие pev_bodyIndex у игрока, если оно есть, то назначить для текушей g_costume_ent
	menu_allmodels_browser(idx_player)
	// set_task( 0.2 , "hud_updater" , idx_player, "",0, "b")	
}


public menu_allmodels_browser(idx_player)
{	
	// start checking is ent exists, is it free for customize and is it have available models 
	// ( but thrid not need) look at public g_costume_ent_create()  it was checked 
	new i_team = pev( idx_player, pev_team )
	if( !pev_valid(g_costume_ent[i_team][id]) || g_costume_ent[i_team][available_models] < 1)
		{
			return PLUGIN_CONTINUE
		}

	if (  g_costume_ent[i_team][owner] != 0 && g_costume_ent[i_team][owner] != idx_player)
		{
			return PLUGIN_CONTINUE
		}
	
	// assign roots
	g_player_to_g_costume_ent[idx_player] = g_costume_ent[i_team][id]
	g_costume_ent[i_team][owner] = idx_player

	new menu_models = menu_create( "\rChoose model", "menu_allmodels_click" )

	for ( new i=0; i < g_costume_ent[i_team][available_models]; i++ )
	{
		menu_additem( menu_models, g_Precached_Player_Models_List[i_team][i] , "", 0)
	}
		// add special menu points
	// menu_additem( menu_models, "\r Back to change model", "-10", 0)
	menu_additem( menu_models, "\w Save current uniform and model", "-11", 0)
	menu_additem( menu_models, "\y Reset and delete unfiform and model", "-12", 0)

	// menu_setprop( menu_models, MPROP_EXIT, MEXIT_NEVER );
	menu_display( idx_player, menu_models, 0 );

	return PLUGIN_CONTINUE
 }


public menu_allmodels_click( idx_player, menu, item )
{
	if (item == MENU_EXIT)
	{
		server_print("exit pressed")
		menu_destroy(menu)
		return PLUGIN_CONTINUE
	}

	new i_team = pev( idx_player, pev_team )
	new ItemData[64], m_Name[64], i_Access, i_Callback
	menu_item_getinfo(menu, item, i_Access, ItemData, charsmax(ItemData), m_Name, charsmax(m_Name), i_Callback)

	server_print("[menu_allmodels_click] item: %d ModelName %s ItemD:%s ", item, m_Name, ItemData)
	
	g_costume_ent[i_team][current_model_list_id] = item
	
	// engfunc(EngFunc_SetModel,  g_player_to_g_costume_ent[idx_player] , m_Name) // из заголовка меню Прямая установка модели.
	engfunc(EngFunc_SetModel,  g_player_to_g_costume_ent[idx_player] , g_Precached_Player_Models_List[i_team][item]) 
	// g_player_to_g_costume_ent[idx_player] == g_costume_ent[i_team][id]    // назначение регулируемой enitty для игрока-кастомизатора

	switch (str_to_num(ItemData))
	{
		case BTN_MENU_SAVE: 
		{
			server_print("BBTN_MENU_SAVE")
			menu_display( idx_player, menu, 0 );
			return PLUGIN_CONTINUE
		}
		case BTN_MENU_RESET: 
		{
			g_costume_reset(idx_player);
			server_print("BTN_MENU_RESET ")
			menu_display( idx_player, menu, 0 );
			return PLUGIN_CONTINUE
		}
		default:
		{       
            menu_submodelgroups_browser(idx_player, menu, item, m_Name , ItemData )
			// menu_destroy( menu )
			//return PLUGIN_CONTINUE
		} 
	}

	return PLUGIN_CONTINUE
}



public menu_submodelgroups_browser(idx_player, menu, item, m_Name[] , ItemData[])
{ 


	new ItemData[64], m_Name[64], i_Access, i_Callback
	menu_item_getinfo(menu, item, i_Access, ItemData, charsmax(ItemData), m_Name, charsmax(m_Name), i_Callback)
	server_print("[menu_submodelgroups_browser] item::index_current_model_list %d m_name::mdl name %s data:: empty sz %s ",item, m_Name, ItemData)
	///////////////
	// получили из м_Дата имя файла, открываем и парсим. , здесь создадим меню боди групп , надо бередать размеры каждой боди группы
	new menu_groups = menu_create( "\rChoose groups", "menu_submodelgroups_click" );
	new filePointer = fopen(m_Name, "rb");
	if (!filePointer)
	{
		return 0;
	}

		
	const bodygroup_nums_position = 204; // aka numbodyparts
	new bodygroup_nums, bodypartindex_position, submodels_nums
	new bodygroup_name[64] 

	fseek(filePointer, bodygroup_nums_position, SEEK_SET); // set search cursor to position 
	fread(filePointer, bodygroup_nums, BLOCK_INT); // read data from position 
	fread(filePointer, bodypartindex_position, BLOCK_INT); // == 3791044 in this file
	server_print("Total number of bodygroups in models: %d", bodygroup_nums);
	// server_print("Body part index position: %d", bodypartindex_position); // == 3791044 in this file

	fseek(filePointer, bodypartindex_position, SEEK_SET)

	new i_team = pev(idx_player,pev_team)
	g_costume_ent[i_team][body_groups] = bodygroup_nums
	//
	for (new group = 0; group < bodygroup_nums; group++){
		for (new i = 0; i < sizeof(bodygroup_name); i++){
			// get every char in name[64]
			fread(filePointer, bodygroup_name[i], BLOCK_CHAR)
		}
		
		server_print("%d:%s", group+1, bodygroup_name)

		fseek(filePointer, bodypartindex_position += 64, SEEK_SET)  
		fread(filePointer, submodels_nums, BLOCK_CHAR)
		server_print("      submodels: %d",  submodels_nums)

		g_costume_ent[i_team][body_size][group] = submodels_nums

		fseek(filePointer, bodypartindex_position += 12, SEEK_SET)

		strtoupper(bodygroup_name)
		new menu_title[32]
		format(menu_title, 31, "%s parts: %d" ,bodygroup_name,  submodels_nums) // color \r
		//
		// g_bodygroups_nums = bodygroup_nums
		// g_bodygroups_size[group] = submodels_nums

		//
		menu_additem( menu_groups, menu_title, "", 0)
		server_print("TITLE :%s", menu_title)

		server_print("BODY SIZE G ENT ARRAY :%d :%d :%d :%d", g_costume_ent[i_team][body_size][0] , g_costume_ent[i_team][body_size][1], g_costume_ent[i_team][body_size][2], g_costume_ent[i_team][body_size][3])
		
	}
	fclose(filePointer);

	// add special menu points
	menu_additem( menu_groups, "\r Back to change model", "-10", 0)
	menu_additem( menu_groups, "\w Save current uniform and model", "-11", 0)
	menu_additem( menu_groups, "\y Reset and delete unfiform and model", "-12", 0)

	menu_setprop( menu_groups, MPROP_EXIT, MEXIT_ALL );
	menu_display( idx_player, menu_groups, 0 );
	return PLUGIN_CONTINUE
}

public menu_submodelgroups_click( idx_player, menu, item )
{	
	switch (item)
	{
		case MENU_EXIT: 
		{
			server_print("exit pressed")
			menu_destroy(menu)
			return PLUGIN_CONTINUE
		}
		default:
		{	
			
		}
	}
	new ItemData[64], m_Name[64], i_Access, i_Callback	
	menu_item_getinfo(menu, item, i_Access, ItemData, charsmax(ItemData), m_Name, charsmax(m_Name), i_Callback)

	server_print("[menu_submodelgroups_click] item::idx_bodygroup %d | name::bodygroup_name %s | data::empty_sz %s ", item, m_Name, ItemData)
	
	switch (str_to_num(ItemData))
	{
		case BTN_MENU_BACK: 
		{
			server_print("BTN_MENU_BACK")
			menu_allmodels_browser(idx_player)
			return PLUGIN_CONTINUE
		}
		case BTN_MENU_SAVE: 
		{
			server_print("BBTN_MENU_SAVE")
			menu_display( idx_player, menu, 0 );
			return PLUGIN_CONTINUE
		}
		case BTN_MENU_RESET: 
		{	
			g_costume_reset(idx_player);
			server_print("BTN_MENU_RESET ");
			menu_display( idx_player, menu, 0 );
			return PLUGIN_CONTINUE
		}
		default:
		{
			menu_submodel_browser(idx_player, menu, item, m_Name , ItemData )
			menu_destroy( menu )
		} 
	}
	return PLUGIN_CONTINUE
} 


public menu_submodel_browser(idx_player, menu, item, m_Name[] , ItemData[])
{
	new ItemData[64], m_Name[64], i_Access, i_Callback
	menu_item_getinfo(menu, item, i_Access, ItemData, charsmax(ItemData), m_Name, charsmax(m_Name), i_Callback)
	server_print("[menu_submodel_browser] item::idx_bodygroup %d name::bodygroup_name %s data::empty_sz %s ", item, m_Name, ItemData)
	new i_team = pev(idx_player, pev_team)

	new menu_submodels = menu_create( "\rChoose Submodel id", "menu_submodel_click" );

	new sz_selected_body[4]
	num_to_str(item, sz_selected_body, charsmax(sz_selected_body));
	new xxx = g_costume_ent[i_team][body_size][item] 
	for (new i = 1 ; i <= xxx ; i++)
	{
		new point_name[32]
		format(point_name, 31, "%s %d", m_Name , i)
		
		// здесь определяем распределение скинов, отключаем нерабочие суб-модели
		// menu_additem( menu_submodels, point_name, sz_selected_body, ADMIN_ADMIN) // для неактивного меню
		if(  containi(g_Precached_Player_Models_List[i_team][g_costume_ent[i_team][current_model_list_id]], "axis-inf") != -1 )
		{
			if( item == 0 && i == 2)
			{
				menu_additem( menu_submodels, point_name, sz_selected_body, ADMIN_ADMIN) // для неактивного меню
			}
			else 
			{
				menu_additem( menu_submodels, point_name, sz_selected_body, 0);
			}
		}
		if(containi(g_Precached_Player_Models_List[i_team][g_costume_ent[i_team][current_model_list_id]], "us-inf") != -1 )
		{
			if( item == 0 && i == 6)
			{
				menu_additem( menu_submodels, point_name, sz_selected_body, ADMIN_ADMIN) // для неактивного меню
			}
			else 
			{
				menu_additem( menu_submodels, point_name, sz_selected_body, 0);
			}
		}
		else
		{
			menu_additem( menu_submodels, point_name, sz_selected_body, 0);
		}			
	}

	menu_additem( menu_submodels, "\r Back to change bodypart", "-10", 0)
	menu_additem( menu_submodels, "\w Save current uniform and model", "-11", 0)
	menu_additem( menu_submodels, "\y Reset and delete unfiform and model", "-12", 0)


	menu_setprop( menu_submodels, MPROP_EXIT, MEXIT_ALL );
	menu_display( idx_player, menu_submodels, 0 );
}

public menu_submodel_click( idx_player, menu, item )
{	
	switch (item)
	{
		case MENU_EXIT: 
		{
			server_print("exit pressed")
			menu_destroy(menu)
			return PLUGIN_CONTINUE
		}
		default:
		{	
			
		}
	}

	new ItemData[64], m_Name[64], i_Access, i_Callback	
	menu_item_getinfo(menu, item, i_Access, ItemData, charsmax(ItemData), m_Name, charsmax(m_Name), i_Callback)
	server_print("[menu_submodel_click] item::idx_submodel %d name:%s data::idx_bodygroup %s ",item, m_Name, ItemData)

	new i_team = pev(idx_player, pev_team)
	new idx_bodygroup = str_to_num(ItemData) // порядковый элемент массива, строка бодигрупп, не нуждается в корректировке.
	new idx_submodel = item;

	// server_print("----------------|||| %d idx_bodygroup",idx_bodygroup)

	switch (str_to_num(ItemData))
	{
		case BTN_MENU_BACK: 
		{       
			menu_destroy(menu);
			server_print("BTN_MENU_BACK");
			menu_allmodels_browser(idx_player);
		}
		case BTN_MENU_SAVE: 
		{
			server_print("BBTN_MENU_SAVE");
			menu_display( idx_player, menu, 0 );
			g_costume_update(idx_player);
			// return PLUGIN_CONTINUE
		}
		case BTN_MENU_RESET: 
		{	
			g_costume_reset(idx_player);
			server_print("BTN_MENU_RESET ")
			menu_display( idx_player, menu, 0 );
			return PLUGIN_CONTINUE
		}
		default:
		{
			g_costume_ent[i_team][body_selected][idx_bodygroup] = idx_submodel
			menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );
			menu_display( idx_player, menu, 0 );
			g_costume_update(idx_player)
			// output_chat(idx_player)
		} 
	}

		/// здесь в ответном клике мы должны приянть  
	// 1 = idx_bodygroup что ьы понять номер строки массив строки массива 
	// 2 = выбраннные item idx_submodel  , что бы задать значение массива {} и передать в калькулятор pev_index.
	// если м_Дата последняя будет пусткой, то скорее всего там будет адрес на переход каталога меню выше. 
	// можно клик объеденить с последующим брауз, для оптимизации передачи

	// menu_submodel_browser(idx_player, menu, item, ItemData , m_Name)
	// отлови селектед

	return PLUGIN_CONTINUE
}

public output_chat(idx_player)
{	
	new i_team = pev(idx_player, pev_team)
	server_print("%d | { %d, %d, %d, %d }| { %d, %d, %d, %d } ", 
	g_costume_ent[i_team][body_groups], 
	g_costume_ent[i_team][body_size][0],
	g_costume_ent[i_team][body_size][1],
	g_costume_ent[i_team][body_size][2],
	g_costume_ent[i_team][body_size][3],
	g_costume_ent[i_team][body_selected][0],
	g_costume_ent[i_team][body_selected][1],
	g_costume_ent[i_team][body_selected][2],
	g_costume_ent[i_team][body_selected][3])

	new pev_index_for = dyn_pev_body_index( g_costume_ent[i_team][body_groups], g_costume_ent[i_team][body_size] , g_costume_ent[i_team][body_selected]) 

	set_pev( g_costume_ent[i_team][id] , pev_body , pev_index_for)
	server_print( "New is pev_body %d," , pev_index_for )
}



// Функция расчета индекса pev_body
public dyn_pev_body_index(num_bodygroups, const size_bodygroups[], const chosen_submodels[])
{	
	// int = количество бодигрупп, размер каждой бодигруппы, выбранные порядковые номера моделей в каждой бодигруппе
    new index = 0;
    new group_multiplier = 1; // Множитель для каждой группы

    // Проверка на корректность количества групп
    if (num_bodygroups <= 0) 
    {
        log_amx("Ошибка: количество групп должно быть больше 0");
        return -1; // Индикатор ошибки
    }

    for (new i = 0; i < num_bodygroups; i++) 
    {
        // Проверка корректности выбранной субмодели
        if ((chosen_submodels[i]+1) < 1 || (chosen_submodels[i] +1 ) > size_bodygroups[i])
        {
            log_amx("Ошибка: некорректный выбор субмодели в группе %d", i + 1);
            return -1; // Индикатор ошибки
        }

        index += (chosen_submodels[i] ) * group_multiplier; // 
        group_multiplier *= size_bodygroups[i]; // Увеличение множителя для следующей группы
    }

    return index;
}


public g_costume_update(idx_player)
{	
	// определяем кто вызвал, на какую g_costume_ent обновить костюм
	new i_team = pev( idx_player, pev_team); // определяем респаун, на котором энтити.
	new idx_custume_ent = g_costume_ent[i_team][id]; // определяем idx_custume_ent
	new idx_body_updated = dyn_pev_body_index( g_costume_ent[i_team][body_groups], g_costume_ent[i_team][body_size], g_costume_ent[i_team][body_selected])
	server_print(" Внимание !!!!! Индекс расчитан == %d", idx_body_updated)
	set_pev( idx_custume_ent, pev_body, idx_body_updated);
	/*
	g_costume_ent[i_team][current_body_index] // это сохранённый индекс здесь надо определиться либо текущий, что бы невзыимать с энтити, либо временный, не соотвествующий ентити
	g_costume_ent[i_team][body_selected] // это массив выбранных субмоделей
	*/

	//Assign Costume вызвать одевание костюма на самого игрока.
	new model[64];
    // get_user_info(idx_custume_ent, "model", model, 63);
	server_print(" ДОЪУЯ СЭКОНОМИЛИ ВРЕМЯ %s", model);
	Player_Rewrite_From_Costume(idx_player);
}

public g_costume_reset(idx_player)
{	
	// Можно создать рекурсивное меню, если вызван reset, то нужно каким-то образом передавать это условия в виде item. 
	// до тех пора, пока это не реализовано, будем просто очищать селектед и pev_body
	
	if(idx_player)
	{ // если функция вызвана от игрока, то массивы будут очищены

	// определяем кто вызвал, на какую g_costume_ent обновить костюм
	new i_team = pev( idx_player, pev_team); // определяем респаун, на котором энтити.
	new idx_custume_ent = g_costume_ent[i_team][id]; // определяем idx_custume_ent
	for (new i = 0; i < g_costume_ent[i_team][body_groups]; i++)
	{	
		// g_costume_ent[i_team][body_size][i] = 0 // Неактивно , пока нет достойного рекурсивного меню.
		g_costume_ent[i_team][body_selected][i] = 0 
	}
	// g_costume_ent[i_team][body_groups] = 0 // Неактивно , пока нет достойного рекурсивного меню.
	g_costume_ent[i_team][current_body_index] = 0;
	set_pev( idx_custume_ent, pev_body, g_costume_ent[i_team][current_body_index]);
	server_print(" !!! Очистка !!!!!");

	}
}

public Player_Rewrite_From_Costume(idx_player)
{	
	//-- надо доделать адекватное извлечение имени модели из этити, на игрока.
	// определяем кто вызвал, на какую g_costume_ent обновить костюм
	new i_team = pev( idx_player, pev_team); // определяем респаун, на котором энтити.
	// new idx_custume_ent = g_costume_ent[i_team][id]; // определяем idx_custume_ent

	new filename[32]; // краткое имя модели
	// Получаем имя файла после последнего слеша
	new last_slash = strfind(g_Precached_Player_Models_List[i_team][g_costume_ent[i_team][current_model_list_id]], "/", true, MAX_MODELNAME-1); // true для поиска с конца
	copy(filename, sizeof(filename), g_Precached_Player_Models_List[i_team][g_costume_ent[i_team][current_model_list_id]][last_slash + 1]);
	// Удаляем расширение
	replace(filename, sizeof(filename), ".mdl", "");

	server_print(" СОКРАЩЁННОЕ ИМЯ === %s", filename); 
}

public Player_Body_Assign(idx_player)
{
    //Assign Costume
    new model[64];
    get_user_info(idx_player, "model", model, 63);
	
	/*
	взять актуальное имя модели энтити и передать игроку 
	// g_Precached_Player_Models_List[i_team][g_costume_ent[i_team][current_model_list_id]] // == models/player/axis-inf/axis-inf.mdl
	*/
    set_pev( idx_player, pev_body, 1024);
    set_user_info(idx_player, "model", model);    
}


//-- надо доделать адекватное извлечение имени модели из этити, на игрока.
/*
затем убрать дебаги, потом вшить вариативность при респауне.
перепроверить все защиты, убрать дебагмесседжи, скорее всего придёться сохранять не только кастомизированный индекс, но и шорт-нэйм модели.
для привязки после респауна , игроку.

возможно имеетсмысл пропарсить имена субмоделей, для красоты.



язык программирования Pawn Amxx Goldsrc
у меня есть массив new modelfile[64] = "models/player/classical/axis-inf.mdl"
иногда он имеет и другие значения моделей,  мне нужно из этой строки получить только последний фрагмент: 
"axis-inf" , как мне отфильтровать бодобные строки так, что бы сначала найти самый последний слеш (или самый первый с конца), и после него взять имя файла, а потом удалить ".mdl"
*/