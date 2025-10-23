/*
Дано: 

х = 7 
y = 8 
Чему равна площадь прямоугольника. 
S = x * y 
S = N

new x

*/
#include <amxmodx>
#pragma semicolon 1

new x, y, s;

public plugin_init()
{   

    server_print(" ------------------- ПРОГРАММКА ДЛЯ МИШАНИ ");
    x = 321;
    y = 684;
    s = x * y;  
    server_print(" Результат: %d", s);
}