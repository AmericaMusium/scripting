
#include <amxmodx>
#include <amxmisc>
 
#define PLUGIN "[amxmodx.inc] get_systime"
#define VERSION "1.0"
#define AUTHOR "Admin"

//Глобальная переменная
new g_sys_time

#define g_sys_time_max 1673370060
 
public plugin_init() {
 
    register_plugin(PLUGIN, VERSION, AUTHOR)
    


    //2 Команды для тестов
    register_srvcmd("systime","systime")
    register_srvcmd("systime2","systime2")
}

 
public systime(){
 
    //Записываем системное время в переменную
    g_sys_time = get_systime()
    //вывод в консоль
    server_print("Sys time: %d", g_sys_time)
     
}
public systime2(){
 
    //новая переменная и получение разницы между моментом ( прямо сейчас)
    // и записанным в предыдущей функции
    new sec_time = get_systime() - g_sys_time
    //Вывод результата в консоль
    server_print("Sys time2: %d", sec_time)
     
}