#include <amxmodx>


// Размер карты
#define CELL_SIZE 20
#define LINE_SIZE 6

// Вводное задания
#define CELL_TASK 20
#define INPUT_OFFLINE_PASSENGES 51
#define WHILE_MAX_CYCLES 80

// максимальный размер место в самолёте
new Map_Online[CELL_SIZE][LINE_SIZE][4];


public plugin_init()
{   
    server_print("========================================================================");
    InputMap_Zero();
    InputMap_Print();
    InputMap_Generate(CELL_TASK, INPUT_OFFLINE_PASSENGES); 
}

public InputMap_Zero()
{
    for (new i = 0; i < CELL_SIZE; i++)
    {   
    // заполняем произвольно массив при онлайн регистрации
        for (new j = 0; j < LINE_SIZE; j++)
        {
            Map_Online[i][j] = ".";
            
        }
    }
}

public InputMap_Print()
{
    for (new i = 0; i < CELL_SIZE; i++)
    {   
        // прочитать массив
        server_print("%s %s %s %s %s %s",
        Map_Online[i][0], 
        Map_Online[i][1], 
        Map_Online[i][2], 
        Map_Online[i][3], 
        Map_Online[i][4],
        Map_Online[i][5]);

    }
}

public InputMap_Generate(n, m)
{   
    // N == количество рядов , M == количество пассажиров пришедних на стойку регистрации
    if (n == 0 || n > 1000)
        return; // error
    if (m == 0 || m > 6000 || m == 1)
        return; // error
    
    new OnlinePassengersCount;
    OnlinePassengersCount = Register_Online_Passengers(n, 0);
    if(OnlinePassengersCount)
    {
        // Если всё прекрасно, продолжаем работу
        InputMap_OffLine_Register(n, m);
    }

}   


public Register_Online_Passengers(n, m)
{   
    // N == количество рядов , M == количество пассажиров пришедних на стойку регистрации
    new OnlinePassengersCount_Recheck = 0;
    new OnlinePassengersCount;
    if(m == 0)
        OnlinePassengersCount = random_num(1, ((n*6)/2));
    else OnlinePassengersCount = m
    server_print("Запрос на регистацию Online: %d Пассажиров на %d рядов", OnlinePassengersCount, n);
    if( OnlinePassengersCount == 1)
        return 0; // error
    
    while (OnlinePassengersCount_Recheck < OnlinePassengersCount)
    {   
        if(InputMap_ReFill(n, m))
            OnlinePassengersCount_Recheck++;
        continue;
    }


    if (OnlinePassengersCount_Recheck == OnlinePassengersCount)
        {   
            InputMap_Print();
            return OnlinePassengersCount;
        }
    else return 0;
    
}

public InputMap_ReFill(n , m)
{   
    // заполняем произвольно массив при онлайн регистрации
    new target_line = random_num(0, n-1);
    new target_place = random_num(0, LINE_SIZE-1);
    if( equal(Map_Online[target_line][target_place], "."))
    {   
        // если слот свободен
        Map_Online[target_line][target_place] = "X";
        return 1;
    }
    return 0;
}

public InputMap_OffLine_Register(n, m)
{   
    // N == количество рядов , M == количество пассажиров пришедних на стойку регистрации
    // будем регистрировать зеркально руководствуясь обратным счётсчиком
    new Offline_Passengers_Post;
    Offline_Passengers_Post = m
    new Cycles = WHILE_MAX_CYCLES;
    server_print("Запрос на регистацию OFFLINE: %d Пассажиров ", m);
    while ( Offline_Passengers_Post > 0)
    {
        for (new i = 0; i < CELL_SIZE; i++)
        {   
            for (new j = 0; j < LINE_SIZE; j++)
            {
                if(!equal(Map_Online[i][j], Map_Online[i][(LINE_SIZE-1)-j]))
                    {
                        if( equal(Map_Online[i][j] ,"X") && equal(Map_Online[i][(LINE_SIZE-1)-j], "."))
                        {
                            if(Offline_Passengers_Post)
                            {   
                                Map_Online[i][(LINE_SIZE-1)-j] = "Z"; // Усажен зеркально
                                Offline_Passengers_Post--
                            }
                        }
                        if(equal(Map_Online[i][(LINE_SIZE-1)-j] ,"X") && equal(Map_Online[i][j] ,"."))
                            {   
                                if(Offline_Passengers_Post)
                                {   
                                    Map_Online[i][j] = "Z"; // Усажен зеркально
                                    Offline_Passengers_Post--
                                }
                            }
                    }
            }
            Cycles--
        }
        if (Cycles < 1) break;
        continue;
    }
    new errors = InputMap_Mirror_Recheck();
    if(Offline_Passengers_Post == 0 && errors == 0)
    {   
        server_print("++++++++++++ Задача исполнена");
        
    }
    else 
    {
        server_print("Задача не исполнена :: Не зарегестрировано %d/%d ", Offline_Passengers_Post, m);
        if (Offline_Passengers_Post > 0)
            Register_Online_Passengers(n, m);
    }
    InputMap_Print();
}

public InputMap_Mirror_Recheck()
{   
    for (new i = 0; i < CELL_SIZE; i++)
    {   
        new dots = 0;
        for (new j = 0; j < LINE_SIZE; j++)
        {
            if(equal(Map_Online[i][j] ,"."))
            {
               dots++;    
            }
        }
        if(dots == 1 || dots == 3 || dots == 5)
        {
            server_print("Задача не решена, плохоя ряд: %d", i)
            return 1;
        }
    }
    return 0;
}