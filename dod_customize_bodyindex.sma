#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>
#include <dodx>
#include <dodfun>
#include <fun>
#include <engine>
#include <fakemeta>

#define MAX_BODY_GROUPS_NUMS 16 // Максимальное количество групп bodygroups
#define MAX_BODY_GROUPS_SIZE 32 // Максимальный размер группы bodygroups
#define MAX_MODELS_IN_TEAM 4    // Максимальное количество моделей в команде
#define MAX_TEAMS 3             // Количество команд
#define MAX_MODELNAME 64        // Максимальная длина имени модели

#define MAXSTUDIOTRIANGLES 20000 // Максимальное количество треугольников в модели
#define MAXSTUDIOVERTS 2048     // Максимальное количество вершин в модели
#define MAXSTUDIOSEQUENCES 2048 // Максимальное количество анимаций
#define MAXSTUDIOSKINS 100      // Максимальное количество текстур
#define MAXSTUDIOSRCBONES 512   // Максимальное количество костей в исходной модели
#define MAXSTUDIOBONES 128      // Максимальное количество костей в модели
#define MAXSTUDIOMODELS 32      // Максимальное количество подмоделей
#define MAXSTUDIOBODYPARTS 32   // Максимальное количество частей тела
#define MAXSTUDIOGROUPS 16      // Максимальное количество групп
#define MAXSTUDIOANIMATIONS 2048 // Максимальное количество анимаций
#define MAXSTUDIOMESHES 256     // Максимальное количество мешей
#define MAXSTUDIOEVENTS 1024    // Максимальное количество событий
#define MAXSTUDIOPIVOTS 256     // Максимальное количество опорных точек
#define MAXSTUDIOCONTROLLERS 8  // Максимальное количество контроллеров

// Константы для кнопок меню
#define BTN_MENU_BACK -10
#define BTN_MENU_SAVE -11
#define BTN_MENU_RESET -12

// Структура для хранения данных о моделях и bodygroups
enum _:m_data {
    id,                // ID сущности
    owner,             // Владелец сущности
    available_models,  // Количество доступных моделей
    current_model_list_id, // Текущая выбранная модель
    body_groups,       // Количество групп bodygroups
    body_size[MAX_BODY_GROUPS_NUMS], // Размер каждой группы bodygroups
    body_selected[MAX_BODY_GROUPS_NUMS], // Выбранные субмодели в каждой группе
    current_body_index // Текущий индекс bodygroup
}

// Глобальные переменные
new g_costume_ent[MAX_TEAMS][m_data]; // Данные о сущностях для каждой команды
new g_Precached_Player_Models_List[MAX_TEAMS][MAX_MODELS_IN_TEAM][MAX_MODELNAME]; // Список моделей для каждой команды
new g_team_mdl_file[MAX_MODELS_IN_TEAM * MAX_TEAMS][MAX_MODELNAME]; // Массив для хранения прекешированных моделей
new g_models_precached = 0; // Количество прекешированных моделей
new g_player_pev_body[33]; // Индекс pev_body для каждого игрока
new g_player_to_g_costume_ent[33]; // Связь между игроком и сущностью

// Прекеширование моделей
public plugin_precache() {
    register_forward(FM_PrecacheModel, "FM_PrecacheModel_P", 1);
}

// Инициализация плагина
public plugin_init() {
    register_plugin("DOD Customize Models", "0.0", "America");
    RegisterHam(Ham_Spawn, "player", "Ham_player_spawn_post", 1); // Хук на спавн игрока
    register_clcmd("say /customize", "customize_players_model"); // Команда для кастомизации модели

    set_task(3.0, "create_g_costume_ent"); // Создание сущностей через 3 секунды

    g_player_to_g_costume_ent[0] = 0; // Инициализация связи между игроком и сущностью
}

// Обработка прекеширования моделей
public FM_PrecacheModel_P(const szFile[]) {
    if (containi(szFile, "models/player/") != -1) {
        g_models_precached++;
        format(g_team_mdl_file[g_models_precached], charsmax(g_team_mdl_file[]), "%s", szFile);

        if (containi(szFile, "/us-") != -1 || containi(szFile, "/brit-") != -1) {
            format(g_Precached_Player_Models_List[ALLIES][g_costume_ent[ALLIES][available_models]], MAX_MODELNAME - 1, "%s", szFile);
            g_costume_ent[ALLIES][available_models]++;
        }
        if (containi(szFile, "/axis") != -1) {
            format(g_Precached_Player_Models_List[AXIS][g_costume_ent[AXIS][available_models]], MAX_MODELNAME - 1, "%s", szFile);
            g_costume_ent[AXIS][available_models]++;
        }
        server_print(szFile);
    }
}

// Хук на спавн игрока
public Ham_player_spawn_post(idx_player) {
    if (is_user_alive(idx_player)) {
        set_pev(idx_player, pev_body, g_player_pev_body[idx_player]);
        return HAM_IGNORED;
    }
    return HAM_IGNORED;
}

// Создание сущностей для кастомизации моделей
public create_g_costume_ent() {
    for (new i_team = 1; i_team < 3; i_team++) {
        if (g_costume_ent[i_team][available_models] > 0) {
            new search_classname[32];
            new Float:f_Origin[3];

            switch (i_team) {
                case ALLIES: format(search_classname, 31, "info_player_allies");
                case AXIS: format(search_classname, 31, "info_player_axis");
            }

            new ent = -1;
            ent = find_ent_by_class(ent, search_classname);

            if (ent != -1) {
                pev(ent, pev_origin, f_Origin);
                server_print("[create_g_costume_ent] search_classname %s id %d", search_classname, ent);

                new next_ent = -1;
                next_ent = find_ent_by_class(ent, search_classname);

                if (next_ent != -1) {
                    server_print("[create_g_costume_ent] 2222222222222 search_classname %s id %d", search_classname, next_ent);
                    remove_entity(ent);
                }
            }

            new idx_g_costume_ent = create_entity("info_target");
            set_pev(idx_g_costume_ent, pev_solid, SOLID_TRIGGER);
            set_pev(idx_g_costume_ent, pev_movetype, MOVETYPE_FLY);
            set_pev(idx_g_costume_ent, pev_avelocity, Float:{0.0, 10.0, 0.0});
            set_pev(idx_g_costume_ent, pev_effects, EF_DIMLIGHT);
            set_pev(idx_g_costume_ent, pev_origin, f_Origin);

            if (!pev_valid(idx_g_costume_ent)) {
                server_print("!!!!!!!!!!!!!! [create_g_costume_ent] g_costume_ent not valid");
                return PLUGIN_CONTINUE;
            }

            g_costume_ent[i_team][id] = idx_g_costume_ent;
            g_costume_ent[i_team][owner] = 0;
            g_costume_ent[i_team][current_model_list_id] = 0;
            g_costume_ent[i_team][current_body_index] = 0;

            server_print("++++++++++[create_g_costume_ent] idx_g_costume_ent %d success for %d , %d", idx_g_costume_ent, i_team, g_costume_ent[i_team][id]);

            engfunc(EngFunc_SetModel, g_costume_ent[i_team][id], g_Precached_Player_Models_List[i_team][g_costume_ent[i_team][current_model_list_id]]);
            entity_set_int(idx_g_costume_