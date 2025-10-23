#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <dodx>
#include <dodfun>
#include <fun>
#include <engine>

#pragma semicolon 1

#define USSR_SOLD 1
#define AXIS_GIRL 2
#define num_of_new_models 3
// US Allies
#define DODCL_garand 1
#define DODCL_m1carb 2
#define DODCL_thomp 3
#define DODCL_greesg 4
#define DODCL_springf 5
#define DODCL_bar 6
#define DODCL_30cal 7
#define DODCL_bazooka 8
// Axis 
#define DODCL_k98 10
#define DODCL_k43 11
#define DODCL_mp40 12
#define DODCL_stg44 13
#define DODCL_k98s 14
#define DODCL_fg42 15
#define DODCL_fg42s 16
#define DODCL_mg34 17
#define DODCL_mg42 18
#define DODCL_panzerschreck 19
// brit 
#define DODCL_enfield 21
#define DODCL_sten 22
#define DODCL_scenfield 23
#define DODCL_bren 24
#define DODCL_piat 25

new body_size[4];
new player_models[num_of_new_models][] =
{   
    "",
	"models/player/ussr-inf/ussr-inf.mdl",
	"models/player/axis-nimf/axis-nimf.mdl"
};

public plugin_init()
{   
    register_plugin("DOD player models", "0.0", "America");
    body_size = {6, 8, 7, 7};
}

public plugin_precache()
{   
    for (new i=1; i < num_of_new_models; i++)
    {
        precache_model(player_models[i]);
    }
}

public dod_client_spawn(idx_player)
{
    if(!is_user_alive( idx_player )) return;
    new player_team = pev(idx_player, pev_team);
    // Assign MODEL
    if(random_num(0,1))
    {
        switch (player_team)
        {
            case 1:
            {   
                // dod_clear_model(idx_player);
                // Назначить модель игроку моментально можно только при использовании сразу двух функций
                dod_set_model(idx_player,"ussr-inf"); // работает строго после респауна
                set_user_info(idx_player, "model", "ussr-inf"); // работает жёстко
            }
            case 2:
            {   
                // dod_clear_model(idx_player);
                dod_set_model(idx_player,"axis-nimf"); // работает строго после респауна
                set_user_info(idx_player, "model", "axis-nimf");
            }
            default: 
            {   
                dod_clear_model(idx_player);
            }
        }
        set_task(0.1, "Player_Body_Assign", idx_player);
    }
    else
    {
        set_pev( idx_player, pev_body, 0);
        dod_clear_model(idx_player);
    } 
    
}
public Player_Body_Assign(idx_player)
{   
    return;
    //Assign Costume
    new model[64];
    get_user_info(idx_player, "model", model, 63);
    new select_body[4];
    select_body[0] = random_num(0,5);
    select_body[1] = random_num(0,6);
    select_body[2] = random_num(0,4);
    select_body[3] = random_num(0,4);
    new generated_index = dyn_pev_body_index(4, body_size ,select_body);
    set_pev( idx_player, pev_body, generated_index);
    set_user_info(idx_player, "model", model);    
}



stock dyn_pev_body_index(num_bodygroups, const size_bodygroups[], const chosen_submodels[])
{
    new index = 0;
    new group_multiplier = 1; // Множитель для каждой группы

    // Проверка на корректность количества групп
    if (num_bodygroups <= 0) 
    {
        server_print("Ошибка: количество групп должно быть больше 0");
        return -1; // Индикатор ошибки
    }

    for (new i = 0; i < num_bodygroups; i++) 
    {
        // Проверка корректности выбранной субмодели
        if (chosen_submodels[i]+1 < 1 || chosen_submodels[i]+1 > size_bodygroups[i])
        {   
            server_print(" Ошибка chosen_submodels[i] %d" , chosen_submodels[i]);
            server_print("Ошибка: некорректный выбор субмодели в группе %d", i + 1);
            return -1; // Индикатор ошибки
        }

        index += (chosen_submodels[i] - 1) * group_multiplier; // -1 для нумерации с 0
        group_multiplier *= size_bodygroups[i]; // Увеличение множителя для следующей группы
    }

    return index;
}