#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>
#include <engine>
#include <dodx>
#include <dodfun>
#include <dhudmessage>


// US Allies
#define cl_garand 1
#define cl_m1carb 2
#define cl_thomp 3
#define cl_greesg 4
#define cl_springf 5
#define cl_bar 6
#define cl_30cal 7
#define cl_bazooka 8
// Axis 
#define cl_k98 10
#define cl_k43 11
#define cl_mp40 12
#define cl_stg44 13
#define cl_k98s 14
#define cl_fg42 15
#define cl_fg42s 16
#define cl_mg34 17
#define cl_mg42 18
#define cl_panzerschreck 19
// brit 
#define cl_enfield 21
#define cl_sten 22
#define cl_scenfield 23
#define cl_bren 24
#define cl_piat 25

///////////////////////////////////////////////////////////////////////////////////
#define MAX_LINES 8 // Масимальное количество строк в отдельном окне чата HUD MAX==8
#define ARRAY_LENGHT 512
#define UPDTIME_CHAT 2.0 // Время автосролла чата
#define print_time 2.0 // Не знаю 
// положение чата 
#define HUD_X 0.02 // 0.0 ; 1.0 ; -1=center
#define HUD_Y 0.40 // 0.0  верх; 1.0 низ
#define HUD_S 0.03 // расстояние между строками

#define HUD_FT 9.0 // Длительность медленного затухания сообщения в чате
#define HUD_HOLDTIME 20.0 // Длительность сообщения
new g_colorfade = 1; // редуцирование цвета
new g_fadeinfx = 0; // Файд ин в сообщениях чата попоярдку

enum _:LINE_DATA
{
     msg_string[ARRAY_LENGHT],
     r,
     g,
     b,
     effects,
     Float:fxtime,
     Float:holdtime,
     Float:fadeintime,
     Float:fadeouttime,
     counts,
     idx_player[32]
}
enum _:INFO_DATA
{
    troopers,
    snipers,
    machine_gunners,
    artillerists,
    medics,
    builders,
    empty,
    emtpy2
}
new DATA[3][INFO_DATA][LINE_DATA];

new pl_class;
new maxplayers;
new bool:cvar_one_color = true
////////////////////////
// message default: colors
public colors_default()
{   
for (new all_classes = 0; all_classes < INFO_DATA; all_classes++)
{   
    for( new all_teams = 1; all_teams < 3; all_teams++)
    {   
    DATA[all_teams][all_classes][r] = random_num(60, 254);
    DATA[all_teams][all_classes][g] = random_num(60, 254);
    DATA[all_teams][all_classes][b] = random_num(60, 254);
    DATA[all_teams][all_classes][effects] = random_num(0, 2);
    DATA[all_teams][all_classes][fxtime] = 1.0;
    DATA[all_teams][all_classes][holdtime] = UPDTIME_CHAT;
    DATA[all_teams][all_classes][fadeintime] = random_float(0.0,1.0);
    DATA[all_teams][all_classes][fadeouttime] = random_float(0.0,1.0);
    if(cvar_one_color==true)
        {
            colors_teams_and_classes(all_teams, all_classes)
        }

    }
}
}



public colors_teams_and_classes(target_team, target_class)
{   
    switch (target_team)
    {
        case ALLIES:
        {
            switch (target_class)
            {
                case troopers:
                {
                DATA[target_team][target_class][r] = 0 // random_num(60, 254)
                DATA[target_team][target_class][g] = 255 //random_num(60, 254)
                DATA[target_team][target_class][b] = 0 // random_num(60, 254)
                DATA[target_team][target_class][effects] = 1 // random_num(0, 2)
                DATA[target_team][target_class][fxtime] = 0.0;
                DATA[target_team][target_class][holdtime] = UPDTIME_CHAT;
                DATA[target_team][target_class][fadeintime] = 0.0 //random_float(0.0,1.0)
                DATA[target_team][target_class][fadeouttime] = 0.0 //random_float(0.0,1.0)
                }
                case machine_gunners:
                {
                DATA[target_team][target_class][r] = 0 // random_num(60, 254)
                DATA[target_team][target_class][g] = 255 //random_num(60, 254)
                DATA[target_team][target_class][b] = 0 // random_num(60, 254)
                DATA[target_team][target_class][effects] = 1 // random_num(0, 2)
                DATA[target_team][target_class][fxtime] = 0.0;
                DATA[target_team][target_class][holdtime] = UPDTIME_CHAT;
                DATA[target_team][target_class][fadeintime] = 0.0 //random_float(0.0,1.0)
                DATA[target_team][target_class][fadeouttime] = 0.0 //random_float(0.0,1.0)
                }
            }
        }
    }   
}









/////////////////////////////
public plugin_init()
{
	register_plugin("Build and Caps", "0.1", "America");
    maxplayers = get_maxplayers(); 

    // OKAPI 
    // okapi_mod_replace_string("Axis","Allies" , 1)
    // okapi_engine_replace_string("scope"," ", 1)

    // register_event("CurWeapon","bar_update_text_full","be","1=1")
    colors_default()
    set_task(UPDTIME_CHAT, "bar_update_text_full", 0, "", 0, "b");


}

public bar_update_text_counts()
{   
    // Refresh DATA 
    for (new all_classes = 0; all_classes < INFO_DATA; all_classes++)
    {
            DATA[ALLIES][all_classes][counts] = 0;
            DATA[AXIS][all_classes][counts] = 0;
    }

    // Собрать данные счётсчика игроков и классов
    for (new id_owner = 1; id_owner <= maxplayers; id_owner++)
    {
        if (is_user_connected(id_owner))
        {
            pl_class = dod_get_user_class(id_owner);

           	switch (pl_class)
                {
                // UPDATE ALLIES COUNTS
                case cl_garand: DATA[ALLIES][troopers][counts]++
                case cl_m1carb: DATA[ALLIES][medics][counts]++      
                case cl_greesg: DATA[ALLIES][troopers][counts]++    
                case cl_thomp:  DATA[ALLIES][troopers][counts]++   
                case cl_bar:    DATA[ALLIES][troopers][counts]++    
                case cl_springf:DATA[ALLIES][snipers][counts]++     
                case cl_30cal:  DATA[ALLIES][machine_gunners][counts]++
                case cl_bazooka:DATA[ALLIES][artillerists][counts]++
                // Axis 
                case cl_k98:     DATA[AXIS][troopers][counts]++
                case cl_k43:     DATA[AXIS][medics][counts]++
                case cl_mp40:    DATA[AXIS][troopers][counts]++
                case cl_stg44:   DATA[AXIS][troopers][counts]++
                case cl_k98s:    DATA[AXIS][snipers][counts]++
                case cl_fg42:    DATA[AXIS][troopers][counts]++
                case cl_fg42s:   DATA[AXIS][snipers][counts]++
                case cl_mg34:    DATA[AXIS][machine_gunners][counts]++
                case cl_mg42:    DATA[AXIS][machine_gunners][counts]++
                case cl_panzerschreck: DATA[AXIS][artillerists][counts]++
                // brit 
                case cl_enfield:    DATA[ALLIES][troopers][counts]++
                case cl_sten:       DATA[ALLIES][troopers][counts]++
                case cl_scenfield:  DATA[ALLIES][snipers][counts]++
                case cl_bren:       DATA[ALLIES][machine_gunners][counts]++
                case cl_piat:       DATA[ALLIES][artillerists][counts]++
                default: 
                {
                    
                }
                }
            
        }
   
    formatex(DATA[ALLIES][troopers][msg_string], ARRAY_LENGHT-1, "Allies troopers: %d", DATA[ALLIES][troopers][counts] )
    formatex(DATA[ALLIES][snipers][msg_string], ARRAY_LENGHT-1, "Allies snipers: %d", DATA[ALLIES][snipers][counts] )
    formatex(DATA[ALLIES][machine_gunners][msg_string], ARRAY_LENGHT-1, "Machine gunners: %d", DATA[ALLIES][machine_gunners][counts] )
    formatex(DATA[ALLIES][medics][msg_string], ARRAY_LENGHT-1, "Field medics : %d", DATA[ALLIES][medics][counts] )
    formatex(DATA[ALLIES][artillerists][msg_string], ARRAY_LENGHT-1, "Artillerists : %d", DATA[ALLIES][artillerists][counts] )

    formatex(DATA[AXIS][troopers][msg_string], ARRAY_LENGHT-1, "Axis troopers: %d", DATA[ALLIES][troopers][counts] )
    formatex(DATA[AXIS][snipers][msg_string], ARRAY_LENGHT-1, "Axis snipers: %d", DATA[ALLIES][snipers][counts] )
    formatex(DATA[AXIS][machine_gunners][msg_string], ARRAY_LENGHT-1, "Machine gunners: %d", DATA[ALLIES][machine_gunners][counts] )
    formatex(DATA[AXIS][medics][msg_string], ARRAY_LENGHT-1, "Field medics : %d", DATA[ALLIES][medics][counts] )
    formatex(DATA[AXIS][artillerists][msg_string], ARRAY_LENGHT-1, "Artillerists : %d", DATA[ALLIES][artillerists][counts] )
    

    }

    
}


public bar_update_text_full()
{   
    // Refresh DATA 
    for (new refresh = 0; refresh < INFO_DATA; refresh++)
    {
            DATA[ALLIES][refresh][counts] = 0;
            DATA[AXIS][refresh][counts] = 0;
    }

    // Собрать данные счётсчика игроков и классов
    for (new id_owner = 1; id_owner <= maxplayers; id_owner++)
    {
        if (is_user_connected(id_owner))
        {
            pl_class = dod_get_user_class(id_owner);

           	switch (pl_class)
                {
                // UPDATE ALLIES COUNTS
                case cl_garand: {
                    DATA[ALLIES][troopers][counts]++
                    DATA[ALLIES][troopers][idx_player][DATA[ALLIES][troopers][counts]] = id_owner 
                    }
                case cl_m1carb: {
                    DATA[ALLIES][medics][counts]++
                    DATA[ALLIES][medics][idx_player][DATA[ALLIES][medics][counts]] = id_owner 
                    }
                case cl_greesg: {
                    DATA[ALLIES][troopers][counts]++
                    DATA[ALLIES][troopers][idx_player][DATA[ALLIES][troopers][counts]] = id_owner 
                    }
                case cl_thomp:  {
                    DATA[ALLIES][troopers][counts]++
                    DATA[ALLIES][troopers][idx_player][DATA[ALLIES][troopers][counts]] = id_owner 
                    }
                case cl_bar:    {
                    DATA[ALLIES][troopers][counts]++
                    DATA[ALLIES][troopers][idx_player][DATA[ALLIES][troopers][counts]] = id_owner 
                    }
                case cl_springf:{
                    DATA[ALLIES][snipers][counts]++
                    DATA[ALLIES][snipers][idx_player][DATA[ALLIES][snipers][counts]] = id_owner 
                    }
                case cl_30cal:  {
                    DATA[ALLIES][machine_gunners][counts]++
                    DATA[ALLIES][machine_gunners][idx_player][DATA[ALLIES][machine_gunners][counts]] = id_owner 
                    }
                case cl_bazooka:{
                    DATA[ALLIES][artillerists][counts]++
                    DATA[ALLIES][artillerists][idx_player][DATA[ALLIES][artillerists][counts]] = id_owner 
                    }

                // Axis 
                case cl_k98:     {
                    DATA[AXIS][troopers][counts]++
                    DATA[AXIS][troopers][idx_player][DATA[AXIS][troopers][counts]] = id_owner 
                    }
                case cl_k43:     {
                    DATA[AXIS][medics][counts]++
                    DATA[AXIS][medics][idx_player][DATA[AXIS][medics][counts]] = id_owner 
                    }
                case cl_mp40:   {
                    DATA[AXIS][troopers][counts]++
                    DATA[AXIS][troopers][idx_player][DATA[AXIS][troopers][counts]] = id_owner 
                    }
                case cl_stg44:   {
                    DATA[AXIS][troopers][counts]++
                    DATA[AXIS][troopers][idx_player][DATA[AXIS][troopers][counts]] = id_owner 
                    }
                case cl_k98s:   {
                    DATA[AXIS][snipers][counts]++
                    DATA[AXIS][snipers][idx_player][DATA[AXIS][snipers][counts]] = id_owner 
                    }
                case cl_fg42:   {
                    DATA[AXIS][troopers][counts]++
                    DATA[AXIS][troopers][idx_player][DATA[AXIS][troopers][counts]] = id_owner 
                    }
                case cl_fg42s:  {
                    DATA[AXIS][snipers][counts]++
                    DATA[AXIS][snipers][idx_player][DATA[AXIS][snipers][counts]] = id_owner 
                    }
                case cl_mg34:    {
                    DATA[AXIS][machine_gunners][counts]++
                    DATA[AXIS][machine_gunners][idx_player][DATA[AXIS][machine_gunners][counts]] = id_owner 
                    }
                case cl_mg42:    {
                    DATA[AXIS][machine_gunners][counts]++
                    DATA[AXIS][machine_gunners][idx_player][DATA[AXIS][machine_gunners][counts]] = id_owner 
                    }
                case cl_panzerschreck: {
                    DATA[AXIS][artillerists][counts]++
                    DATA[AXIS][artillerists][idx_player][DATA[AXIS][artillerists][counts]] = id_owner 
                    }

                // brit 
                case cl_enfield:    {
                    DATA[ALLIES][troopers][counts]++
                    DATA[ALLIES][troopers][idx_player][DATA[ALLIES][troopers][counts]] = id_owner 
                    }
                case cl_sten:       {
                    DATA[ALLIES][medics][counts]++
                    DATA[ALLIES][medics][idx_player][DATA[ALLIES][medics][counts]] = id_owner 
                    }
                case cl_scenfield:  {
                    DATA[ALLIES][snipers][counts]++
                    DATA[ALLIES][snipers][idx_player][DATA[ALLIES][snipers][counts]] = id_owner 
                    }
                case cl_bren:       {
                    DATA[ALLIES][machine_gunners][counts]++
                    DATA[ALLIES][machine_gunners][idx_player][DATA[ALLIES][machine_gunners][counts]] = id_owner 
                    }
                case cl_piat:       {
                    DATA[ALLIES][artillerists][counts]++
                    DATA[ALLIES][artillerists][idx_player][DATA[ALLIES][artillerists][counts]] = id_owner 
                    }
                default: 
                {
                    
                }
                }
            
        }
    
    
    formatex(DATA[ALLIES][troopers][msg_string], ARRAY_LENGHT-1, "Allies troopers: %d", DATA[ALLIES][troopers][counts] )
    formatex(DATA[ALLIES][snipers][msg_string], ARRAY_LENGHT-1, "Allies snipers: %d", DATA[ALLIES][snipers][counts] )
    formatex(DATA[ALLIES][machine_gunners][msg_string], ARRAY_LENGHT-1, "Machine gunners: %d", DATA[ALLIES][machine_gunners][counts] )
    formatex(DATA[ALLIES][medics][msg_string], ARRAY_LENGHT-1, "Field medics : %d", DATA[ALLIES][medics][counts] )
    formatex(DATA[ALLIES][artillerists][msg_string], ARRAY_LENGHT-1, "Artillerists : %d", DATA[ALLIES][artillerists][counts] )

    formatex(DATA[AXIS][troopers][msg_string], ARRAY_LENGHT-1, "Axis troopers: %d", DATA[AXIS][troopers][counts] )
    formatex(DATA[AXIS][snipers][msg_string], ARRAY_LENGHT-1, "Axis snipers: %d", DATA[AXIS][snipers][counts] )
    formatex(DATA[AXIS][machine_gunners][msg_string], ARRAY_LENGHT-1, "Machine gunners: %d", DATA[AXIS][machine_gunners][counts] )
    formatex(DATA[AXIS][medics][msg_string], ARRAY_LENGHT-1, "Field medics : %d", DATA[AXIS][medics][counts] )
    formatex(DATA[AXIS][artillerists][msg_string], ARRAY_LENGHT-1, "Artillerists : %d", DATA[AXIS][artillerists][counts] )
    

    /*
    new name[32]
    get_user_name(id_owner, name, 31)
    server_print(" CLASS %d NAME: %s",pl_class, name)
    */
    }


    bar_update_gunners()
    
    
}


public bar_update_gunners()
{   
    for (new user_team = 1; user_team < 3 ; user_team++)
    {   
        // server_print("------------user_team %d", user_team)
        new clip, ammo, myWeapon
        new totalgunners = DATA[user_team][machine_gunners][counts]
        new gunner = totalgunners
        for (gunner ; gunner > 0 ; gunner--)
        {   
            new id_owner = DATA[user_team][machine_gunners][idx_player][gunner]
            if(is_user_connected(id_owner) && gunner!=0)
            {
            new name[32]
            get_user_name(id_owner, name, 31)
            myWeapon = dod_get_user_weapon(id_owner, clip, ammo)

            if(myWeapon == DODW_30_CAL || myWeapon == DODW_MG34 || myWeapon == DODW_MG42)
                {
                
                format(DATA[user_team][machine_gunners][msg_string], ARRAY_LENGHT-1, "%s | ammo: %d/%d", DATA[user_team][machine_gunners][msg_string] , clip, ammo)
                //server_print("------------------- Macnine gunner %d / %d is %s ammo: %d/%d" , gunner ,totalgunners, name , clip, ammo)

                new max_allbullets

                switch (myWeapon)
                    {
                        case DODW_30_CAL: max_allbullets = 300000 // 150 ПАТРОНО * 255 МАКС ЯРКОСТЬ ЦВЕТА
                        case DODW_MG34: max_allbullets = 45000 // 375
                        case DODW_MG42: max_allbullets = 50000 // 250 
                    }
                    //
                
                new allbullets = ((clip + ammo)*25500) / max_allbullets

                DATA[user_team][machine_gunners][g] = allbullets
                DATA[user_team][machine_gunners][r] = (255 - allbullets)
                }
            }
        }
    }
    bar_print_teams()
}


public bar_print_teams()
{

     new str // = MAX_LINES-1
     new user_team
    for (new all_teams = 1;all_teams < 3; all_teams++ )
    for (new id_owner = 1; id_owner <= maxplayers; id_owner++)
    {   
        if(is_user_connected(id_owner))
        {
        user_team = get_user_team(id_owner)
        if (user_team == all_teams)
        {
            for(new all_classes = 0; all_classes < MAX_LINES; all_classes++ )
            {                    
                set_dhudmessage(DATA[user_team][all_classes][r],DATA[user_team][all_classes][g],DATA[user_team][all_classes][b], HUD_X , (HUD_Y + (HUD_S * float(all_classes))) , DATA[user_team][all_classes][effects], DATA[user_team][all_classes][fxtime], DATA[user_team][all_classes][holdtime], DATA[user_team][all_classes][fadeintime], DATA[user_team][all_classes][fadeouttime], false)
                show_dhudmessage(id_owner, DATA[user_team][all_classes][msg_string])
            
            }
        }
    }
}
}

