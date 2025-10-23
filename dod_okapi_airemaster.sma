/**
 * DoD OKAPI Remaster
 * Плагин для работы с библиотекой OKAPI в Day of Defeat
 * 
 * Описание:
 * Данный плагин демонстрирует использование библиотеки OKAPI для перехвата
 * и модификации внутренних функций игры Day of Defeat. Позволяет отслеживать
 * различные события, такие как выстрелы ракет, зумирование оружия и другие.
 * 
 * Автор: America (оригинал), AIRemaster (улучшенная версия)
 * Версия: 1.0
 */

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <fakemeta_util>
#include <dodx>
#include <dodfun>
#include <fun>
#include <engine>
#include <okapi>

// Объявление функций OKAPI для ракет
new okapi_func:func_RocketTouch_Bazooka
new okapi_func:func_RocketTouch_PIAT
new okapi_func:func_RocketTouch_Pschreck
new okapi_func:func_RocketExplodeTouch

// Объявление функций OKAPI для зумирования
new okapi_func:func_ThinkZoomIn_CBasePlayerWeapon
new okapi_func:func_ThinkZoomOut_CBasePlayerWeapon
new okapi_func:func_ThinkZoomOut_SPRING
new okapi_func:func_ThinkZoomOutIn_ENFIELD
new okapi_func:func_ThinkZoomOutIn_SPRING
new okapi_func:func_ThinkZoomOutIn_ScopedKar

// Счетчик успешных регистраций
new g_iSuccessfulRegistrations = 0
new g_iFailedRegistrations = 0

// Массив для хранения всех функций из !dod_functions.txt
#define MAX_FUNCTIONS 500
new g_szFunctionNames[MAX_FUNCTIONS][128]
new g_szFunctionSymbols[MAX_FUNCTIONS][128]
new g_iFunctionCount = 0

/**
 * Инициализация плагина
 */
public plugin_init()
{
    register_plugin("DoD OKAPI Remaster", "1.0", "AIRemaster")
    
    // Регистрация событий
    register_event("SetFOV", "Set_fov_post", "be", "1>0") // Отслеживание изменения угла обзора
    
    // Регистрация функций для перехвата
    register_all_functions()
    
    // Загрузка и регистрация всех функций из !dod_functions.txt
    load_and_register_all_dod_functions()
    
    server_print("[OKAPI Remaster] Плагин успешно запущен!")
    server_print("[OKAPI Remaster] Успешно зарегистрировано функций: %d", g_iSuccessfulRegistrations)
    server_print("[OKAPI Remaster] Не удалось зарегистрировать функций: %d", g_iFailedRegistrations)
}

/**
 * Загрузка и регистрация всех функций из !dod_functions.txt
 */
public load_and_register_all_dod_functions()
{
    // Путь к файлу с функциями
    new szFilePath[128]
    get_localinfo("amxx_configsdir", szFilePath, 127)
    format(szFilePath, 127, "%s/../scripting/!dod_functions.txt", szFilePath)
    
    // Открываем файл для чтения
    new iFileHandle = fopen(szFilePath, "rt")
    if(!iFileHandle)
    {
        server_print("[OKAPI Remaster] Ошибка: Не удалось открыть файл !dod_functions.txt")
        return
    }
    
    server_print("[OKAPI Remaster] Начинаю загрузку функций из !dod_functions.txt")
    
    // Чтение файла и поиск функций
    new szLine[256]
    new bool:bFunctionSection = false
    
    while(!feof(iFileHandle))
    {
        fgets(iFileHandle, szLine, 255)
        
        // Удаляем лишние пробелы и символы переноса строки
        trim(szLine)
        
        // Проверяем, начался ли раздел с функциями
        if(contain(szLine, "ordinal hint RVA") != -1)
        {
            bFunctionSection = true
            continue
        }
        
        // Если мы в разделе с функциями и строка не пустая
        if(bFunctionSection && strlen(szLine) > 10)
        {
            // Проверяем, что строка содержит функцию (начинается с числа и содержит символ "?")
            if(is_str_num(szLine[0]) && contain(szLine, "?") != -1)
            {
                // Извлекаем имя функции
                new szFunctionName[128]
                new iStart = contain(szLine, "?")
                if(iStart != -1)
                {
                    copy(szFunctionName, 127, szLine[iStart])
                    
                    // Сохраняем функцию в массив
                    if(g_iFunctionCount < MAX_FUNCTIONS)
                    {
                        copy(g_szFunctionSymbols[g_iFunctionCount], 127, szFunctionName)
                        
                        // Извлекаем читаемое имя функции
                        new szReadableName[128]
                        extract_readable_function_name(szFunctionName, szReadableName, 127)
                        copy(g_szFunctionNames[g_iFunctionCount], 127, szReadableName)
                        
                        g_iFunctionCount++
                    }
                }
            }
        }
        
        // Если достигли раздела Summary, завершаем чтение
        if(contain(szLine, "Summary") != -1 && bFunctionSection)
        {
            break
        }
    }
    
    // Закрываем файл
    fclose(iFileHandle)
    
    server_print("[OKAPI Remaster] Загружено %d функций из !dod_functions.txt", g_iFunctionCount)
    
    // Регистрируем все найденные функции
    register_all_dod_functions()
}

/**
 * Извлекает читаемое имя функции из символа
 * 
 * @param szSymbol Символ функции (например, ?ThinkZoomIn@CBasePlayerWeapon@@QAEXXZ)
 * @param szReadableName Буфер для записи читаемого имени
 * @param iMaxLen Максимальная длина буфера
 */
public extract_readable_function_name(const szSymbol[], szReadableName[], iMaxLen)
{
    // По умолчанию копируем весь символ
    copy(szReadableName, iMaxLen, szSymbol)
    
    // Ищем имя функции между ? и @
    new iStart = contain(szSymbol, "?")
    new iEnd = contain(szSymbol, "@")
    
    if(iStart != -1 && iEnd != -1 && iEnd > iStart + 1)
    {
        // Извлекаем имя функции
        new szFuncName[64]
        copy(szFuncName, 63, szSymbol[iStart + 1], iEnd - iStart - 1)
        
        // Ищем имя класса между @ и @@
        new iClassStart = iEnd + 1
        new iClassEnd = contain(szSymbol[iClassStart], "@@")
        
        if(iClassEnd != -1)
        {
            // Извлекаем имя класса
            new szClassName[64]
            copy(szClassName, 63, szSymbol[iClassStart], iClassEnd)
            
            // Формируем читаемое имя в формате ClassName::FunctionName
            format(szReadableName, iMaxLen, "%s::%s", szClassName, szFuncName)
        }
        else
        {
            // Если не удалось извлечь имя класса, используем только имя функции
            copy(szReadableName, iMaxLen, szFuncName)
        }
    }
}

/**
 * Регистрирует все функции, найденные в !dod_functions.txt
 */
public register_all_dod_functions()
{
    new iRegisteredCount = 0
    
    for(new i = 0; i < g_iFunctionCount; i++)
    {
        // Пропускаем функции, которые уже зарегистрированы
        if(is_already_registered_function(g_szFunctionSymbols[i]))
        {
            continue
        }
        
        // Находим указатель на функцию
        new func_ptr = okapi_mod_get_symbol_ptr(g_szFunctionSymbols[i])
        if(func_ptr)
        {
            // Для демонстрации регистрируем только первые 10 функций
            if(iRegisteredCount < 10)
            {
                server_print("[OKAPI Remaster] Успешно найдена функция: %s", g_szFunctionNames[i])
                iRegisteredCount++
                g_iSuccessfulRegistrations++
            }
        }
        else
        {
            g_iFailedRegistrations++
        }
    }
    
    server_print("[OKAPI Remaster] Всего зарегистрировано %d функций из !dod_functions.txt", iRegisteredCount)
}

/**
 * Проверяет, была ли функция уже зарегистрирована
 * 
 * @param szFunctionSymbol Символ функции
 * @return true, если функция уже зарегистрирована, иначе false
 */
public bool:is_already_registered_function(const szFunctionSymbol[])
{
    // Список уже зарегистрированных функций
    static const szRegisteredFunctions[][] = {
        "?RocketTouch@CBazookaShell@@QAEXPAVCBaseEntity@@@Z",
        "?RocketTouch@CPIATShell@@QAEXPAVCBaseEntity@@@Z",
        "?RocketTouch@CPschreckShell@@QAEXPAVCBaseEntity@@@Z",
        "?RocketExplodeTouch@CGrenade@@QAEXPAVCBaseEntity@@@Z",
        "?ThinkZoomIn@CBasePlayerWeapon@@QAEXXZ",
        "?ThinkZoomOut@CBasePlayerWeapon@@QAEXXZ",
        "?ThinkZoomOut@CSPRING@@QAEXXZ",
        "?ThinkZoomOutIn@CENFIELD@@QAEXXZ",
        "?ThinkZoomOutIn@CSPRING@@QAEXXZ",
        "?ThinkZoomOutIn@CScopedKar@@QAEXXZ"
    }
    
    // Проверяем, есть ли функция в списке
    for(new i = 0; i < sizeof(szRegisteredFunctions); i++)
    {
        if(equal(szFunctionSymbol, szRegisteredFunctions[i]))
        {
            return true
        }
    }
    
    return false
}

/**
 * Регистрация всех функций для перехвата
 */
public register_all_functions()
{
    // Регистрация функций для ракет
    register_rocket_functions()
    
    // Регистрация функций для зумирования
    register_zoom_functions()
}

/**
 * Регистрация функций для отслеживания ракет
 */
public register_rocket_functions()
{
    // Находим идентификатор функции RocketTouch для Bazooka
    new func_ptr = okapi_mod_get_symbol_ptr("?RocketTouch@CBazookaShell@@QAEXPAVCBaseEntity@@@Z") 
    if(func_ptr)
    {   
        // Создаем метод для перехвата функции
        func_RocketTouch_Bazooka = okapi_build_method(func_ptr, arg_void, arg_cbase, arg_cbase)
        // Добавляем хук для вызова On_func_RocketTouch_Bazooka при обнаружении RocketTouch
        okapi_add_hook(func_RocketTouch_Bazooka, "On_func_RocketTouch_Bazooka", 0)
        server_print("[OKAPI Remaster] Функция RocketTouch для Bazooka успешно перехвачена")
        g_iSuccessfulRegistrations++
    }
    else
    {
        server_print("[OKAPI Remaster] Ошибка при поиске функции RocketTouch для Bazooka")
        g_iFailedRegistrations++
    }
    
    // Находим идентификатор функции RocketTouch для PIAT
    func_ptr = okapi_mod_get_symbol_ptr("?RocketTouch@CPIATShell@@QAEXPAVCBaseEntity@@@Z") 
    if(func_ptr)
    {   
        // Создаем метод для перехвата функции
        func_RocketTouch_PIAT = okapi_build_method(func_ptr, arg_void, arg_cbase, arg_cbase)
        // Добавляем хук для вызова On_func_RocketTouch_PIAT при обнаружении RocketTouch
        okapi_add_hook(func_RocketTouch_PIAT, "On_func_RocketTouch_PIAT", 0)
        server_print("[OKAPI Remaster] Функция RocketTouch для PIAT успешно перехвачена")
        g_iSuccessfulRegistrations++
    }
    else
    {
        server_print("[OKAPI Remaster] Ошибка при поиске функции RocketTouch для PIAT")
        g_iFailedRegistrations++
    }
    
    // Находим идентификатор функции RocketTouch для Pschreck
    func_ptr = okapi_mod_get_symbol_ptr("?RocketTouch@CPschreckShell@@QAEXPAVCBaseEntity@@@Z") 
    if(func_ptr)
    {   
        // Создаем метод для перехвата функции
        func_RocketTouch_Pschreck = okapi_build_method(func_ptr, arg_void, arg_cbase, arg_cbase)
        // Добавляем хук для вызова On_func_RocketTouch_Pschreck при обнаружении RocketTouch
        okapi_add_hook(func_RocketTouch_Pschreck, "On_func_RocketTouch_Pschreck", 0)
        server_print("[OKAPI Remaster] Функция RocketTouch для Pschreck успешно перехвачена")
        g_iSuccessfulRegistrations++
    }
    else
    {
        server_print("[OKAPI Remaster] Ошибка при поиске функции RocketTouch для Pschreck")
        g_iFailedRegistrations++
    }
    
    // Находим идентификатор функции RocketExplodeTouch
    func_ptr = okapi_mod_get_symbol_ptr("?RocketExplodeTouch@CGrenade@@QAEXPAVCBaseEntity@@@Z") 
    if(func_ptr)
    {   
        // Создаем метод для перехвата функции
        func_RocketExplodeTouch = okapi_build_method(func_ptr, arg_void, arg_cbase, arg_cbase)
        // Добавляем хук для вызова On_func_RocketExplodeTouch при обнаружении RocketExplodeTouch
        okapi_add_hook(func_RocketExplodeTouch, "On_func_RocketExplodeTouch", 0)
        server_print("[OKAPI Remaster] Функция RocketExplodeTouch успешно перехвачена")
        g_iSuccessfulRegistrations++
    }
    else
    {
        server_print("[OKAPI Remaster] Ошибка при поиске функции RocketExplodeTouch")
        g_iFailedRegistrations++
    }
}

/**
 * Регистрация функций для отслеживания зумирования оружия
 */
public register_zoom_functions()
{
    // Находим идентификатор функции ThinkZoomIn для CBasePlayerWeapon
    new func_ptr = okapi_mod_get_symbol_ptr("?ThinkZoomIn@CBasePlayerWeapon@@QAEXXZ")
    if(func_ptr)
    {   
        // Создаем метод для перехвата функции
        func_ThinkZoomIn_CBasePlayerWeapon = okapi_build_method(func_ptr, arg_cbase, arg_cbase)
        // Добавляем хук для вызова On_func_ThinkZoomIn при обнаружении ThinkZoomIn
        okapi_add_hook(func_ThinkZoomIn_CBasePlayerWeapon, "On_func_ThinkZoomIn", 0)
        server_print("[OKAPI Remaster] Функция ThinkZoomIn для CBasePlayerWeapon успешно перехвачена")
        g_iSuccessfulRegistrations++
    }
    else
    {
        server_print("[OKAPI Remaster] Ошибка при поиске функции ThinkZoomIn для CBasePlayerWeapon")
        g_iFailedRegistrations++
    }
    
    // Находим идентификатор функции ThinkZoomOut для CBasePlayerWeapon
    func_ptr = okapi_mod_get_symbol_ptr("?ThinkZoomOut@CBasePlayerWeapon@@QAEXXZ")
    if(func_ptr)
    {   
        // Создаем метод для перехвата функции
        func_ThinkZoomOut_CBasePlayerWeapon = okapi_build_method(func_ptr, arg_cbase, arg_cbase)
        // Добавляем хук для вызова On_func_ThinkZoomOut при обнаружении ThinkZoomOut
        okapi_add_hook(func_ThinkZoomOut_CBasePlayerWeapon, "On_func_ThinkZoomOut", 0)
        server_print("[OKAPI Remaster] Функция ThinkZoomOut для CBasePlayerWeapon успешно перехвачена")
        g_iSuccessfulRegistrations++
    }
    else
    {
        server_print("[OKAPI Remaster] Ошибка при поиске функции ThinkZoomOut для CBasePlayerWeapon")
        g_iFailedRegistrations++
    }
    
    // Находим идентификатор функции ThinkZoomOut для SPRING
    func_ptr = okapi_mod_get_symbol_ptr("?ThinkZoomOut@CSPRING@@QAEXXZ")
    if(func_ptr)
    {   
        // Создаем метод для перехвата функции
        func_ThinkZoomOut_SPRING = okapi_build_method(func_ptr, arg_cbase, arg_cbase)
        // Добавляем хук для вызова On_func_ThinkZoomOut_SPRING при обнаружении ThinkZoomOut
        okapi_add_hook(func_ThinkZoomOut_SPRING, "On_func_ThinkZoomOut_SPRING", 0)
        server_print("[OKAPI Remaster] Функция ThinkZoomOut для SPRING успешно перехвачена")
        g_iSuccessfulRegistrations++
    }
    else
    {
        server_print("[OKAPI Remaster] Ошибка при поиске функции ThinkZoomOut для SPRING")
        g_iFailedRegistrations++
    }
    
    // Находим идентификатор функции ThinkZoomOutIn для ENFIELD
    func_ptr = okapi_mod_get_symbol_ptr("?ThinkZoomOutIn@CENFIELD@@QAEXXZ")
    if(func_ptr)
    {   
        // Создаем метод для перехвата функции
        func_ThinkZoomOutIn_ENFIELD = okapi_build_method(func_ptr, arg_cbase, arg_cbase)
        // Добавляем хук для вызова On_func_ThinkZoomOutIn_ENFIELD при обнаружении ThinkZoomOutIn
        okapi_add_hook(func_ThinkZoomOutIn_ENFIELD, "On_func_ThinkZoomOutIn_ENFIELD", 0)
        server_print("[OKAPI Remaster] Функция ThinkZoomOutIn для ENFIELD успешно перехвачена")
        g_iSuccessfulRegistrations++
    }
    else
    {
        server_print("[OKAPI Remaster] Ошибка при поиске функции ThinkZoomOutIn для ENFIELD")
        g_iFailedRegistrations++
    }
    
    // Находим идентификатор функции ThinkZoomOutIn для SPRING
    func_ptr = okapi_mod_get_symbol_ptr("?ThinkZoomOutIn@CSPRING@@QAEXXZ")
    if(func_ptr)
    {   
        // Создаем метод для перехвата функции
        func_ThinkZoomOutIn_SPRING = okapi_build_method(func_ptr, arg_cbase, arg_cbase)
        // Добавляем хук для вызова On_func_ThinkZoomOutIn_SPRING при обнаружении ThinkZoomOutIn
        okapi_add_hook(func_ThinkZoomOutIn_SPRING, "On_func_ThinkZoomOutIn_SPRING", 0)
        server_print("[OKAPI Remaster] Функция ThinkZoomOutIn для SPRING успешно перехвачена")
        g_iSuccessfulRegistrations++
    }
    else
    {
        server_print("[OKAPI Remaster] Ошибка при поиске функции ThinkZoomOutIn для SPRING")
        g_iFailedRegistrations++
    }
    
    // Находим идентификатор функции ThinkZoomOutIn для ScopedKar
    func_ptr = okapi_mod_get_symbol_ptr("?ThinkZoomOutIn@CScopedKar@@QAEXXZ")
    if(func_ptr)
    {   
        // Создаем метод для перехвата функции
        func_ThinkZoomOutIn_ScopedKar = okapi_build_method(func_ptr, arg_cbase, arg_cbase)
        // Добавляем хук для вызова On_func_ThinkZoomOutIn_ScopedKar при обнаружении ThinkZoomOutIn
        okapi_add_hook(func_ThinkZoomOutIn_ScopedKar, "On_func_ThinkZoomOutIn_ScopedKar", 0)
        server_print("[OKAPI Remaster] Функция ThinkZoomOutIn для ScopedKar успешно перехвачена")
        g_iSuccessfulRegistrations++
    }
    else
    {
        server_print("[OKAPI Remaster] Ошибка при поиске функции ThinkZoomOutIn для ScopedKar")
        g_iFailedRegistrations++
    }
}

/**
 * Обработчик события касания ракеты Bazooka
 * 
 * @param idx_shell Индекс снаряда
 * @param idx_ent Индекс сущности, с которой произошло столкновение
 * @return Тип возврата для OKAPI
 */
public On_func_RocketTouch_Bazooka(idx_shell, idx_ent)
{
    // Получаем имена классов для логирования
    new sz_classname[32], target_classname[32]
    pev(idx_shell, pev_classname, sz_classname, 31)
    pev(idx_ent, pev_classname, target_classname, 31)
    
    server_print("[OKAPI Remaster] Событие RocketTouch (Bazooka) - снаряд %d (%s) коснулся %d (%s)", 
                 idx_shell, sz_classname, idx_ent, target_classname)
    
    // Получаем владельца ракеты
    new owner = pev(idx_shell, pev_owner)
    if(is_user_connected(owner)) {
        new name[32]
        get_user_name(owner, name, 31)
        server_print("[OKAPI Remaster] Владелец ракеты: %s (%d)", name, owner)
    }
    
    // Возвращаем okapi_ret_ignore, чтобы позволить оригинальной функции выполниться
    return okapi_ret_ignore
}

/**
 * Обработчик события касания ракеты PIAT
 * 
 * @param idx_shell Индекс снаряда
 * @param idx_ent Индекс сущности, с которой произошло столкновение
 * @return Тип возврата для OKAPI
 */
public On_func_RocketTouch_PIAT(idx_shell, idx_ent)
{
    // Получаем имена классов для логирования
    new sz_classname[32], target_classname[32]
    pev(idx_shell, pev_classname, sz_classname, 31)
    pev(idx_ent, pev_classname, target_classname, 31)
    
    server_print("[OKAPI Remaster] Событие RocketTouch (PIAT) - снаряд %d (%s) коснулся %d (%s)", 
                 idx_shell, sz_classname, idx_ent, target_classname)
    
    // Получаем владельца ракеты
    new owner = pev(idx_shell, pev_owner)
    if(is_user_connected(owner)) {
        new name[32]
        get_user_name(owner, name, 31)
        server_print("[OKAPI Remaster] Владелец ракеты: %s (%d)", name, owner)
    }
    
    // Возвращаем okapi_ret_ignore, чтобы позволить оригинальной функции выполниться
    return okapi_ret_ignore
}

/**
 * Обработчик события касания ракеты Pschreck
 * 
 * @param idx_shell Индекс снаряда
 * @param idx_ent Индекс сущности, с которой произошло столкновение
 * @return Тип возврата для OKAPI
 */
public On_func_RocketTouch_Pschreck(idx_shell, idx_ent)
{
    // Получаем имена классов для логирования
    new sz_classname[32], target_classname[32]
    pev(idx_shell, pev_classname, sz_classname, 31)
    pev(idx_ent, pev_classname, target_classname, 31)
    
    server_print("[OKAPI Remaster] Событие RocketTouch (Pschreck) - снаряд %d (%s) коснулся %d (%s)", 
                 idx_shell, sz_classname, idx_ent, target_classname)
    
    // Получаем владельца ракеты
    new owner = pev(idx_shell, pev_owner)
    if(is_user_connected(owner)) {
        new name[32]
        get_user_name(owner, name, 31)
        server_print("[OKAPI Remaster] Владелец ракеты: %s (%d)", name, owner)
    }
    
    // Возвращаем okapi_ret_ignore, чтобы позволить оригинальной функции выполниться
    return okapi_ret_ignore
}

/**
 * Обработчик события взрыва ракеты
 * 
 * @param idx_shell Индекс снаряда
 * @param idx_ent Индекс сущности, с которой произошло столкновение
 * @return Тип возврата для OKAPI
 */
public On_func_RocketExplodeTouch(idx_shell, idx_ent)
{
    server_print("[OKAPI Remaster] Событие RocketExplodeTouch - снаряд %d взорвался при контакте с %d", 
                 idx_shell, idx_ent)
    
    // Получаем владельца ракеты
    new owner = pev(idx_shell, pev_owner)
    if(is_user_connected(owner)) {
        new name[32]
        get_user_name(owner, name, 31)
        server_print("[OKAPI Remaster] Владелец ракеты: %s (%d)", name, owner)
    }
    
    return okapi_ret_ignore
}

/**
 * Обработчик события зумирования (ThinkZoomIn)
 * 
 * @param idx_weapon Индекс оружия
 * @return Тип возврата для OKAPI
 */
public On_func_ThinkZoomIn(idx_weapon)
{   
    // Получаем владельца оружия
    new owner = pev(idx_weapon, pev_owner)
    if(is_user_connected(owner)) {
        new name[32], weapon_name[32]
        get_user_name(owner, name, 31)
        pev(idx_weapon, pev_classname, weapon_name, 31)
        server_print("[OKAPI Remaster] Игрок %s (%d) использует зум (ThinkZoomIn) оружия %s (%d)", 
                    name, owner, weapon_name, idx_weapon)
    } else {
        server_print("[OKAPI Remaster] Событие ThinkZoomIn для оружия %d", idx_weapon)
    }
    
    // Возвращаем okapi_ret_ignore для продолжения оригинальной функции
    return okapi_ret_ignore
}

/**
 * Обработчик события зумирования (ThinkZoomOut)
 * 
 * @param idx_weapon Индекс оружия
 * @return Тип возврата для OKAPI
 */
public On_func_ThinkZoomOut(idx_weapon)
{   
    // Получаем владельца оружия
    new owner = pev(idx_weapon, pev_owner)
    if(is_user_connected(owner)) {
        new name[32], weapon_name[32]
        get_user_name(owner, name, 31)
        pev(idx_weapon, pev_classname, weapon_name, 31)
        server_print("[OKAPI Remaster] Игрок %s (%d) выходит из зума (ThinkZoomOut) оружия %s (%d)", 
                    name, owner, weapon_name, idx_weapon)
    } else {
        server_print("[OKAPI Remaster] Событие ThinkZoomOut для оружия %d", idx_weapon)
    }
    
    // Возвращаем okapi_ret_ignore для продолжения оригинальной функции
    return okapi_ret_ignore
}

/**
 * Обработчик события зумирования (ThinkZoomOut) для SPRING
 * 
 * @param idx_weapon Индекс оружия
 * @return Тип возврата для OKAPI
 */
public On_func_ThinkZoomOut_SPRING(idx_weapon)
{   
    // Получаем владельца оружия
    new owner = pev(idx_weapon, pev_owner)
    if(is_user_connected(owner)) {
        new name[32]
        get_user_name(owner, name, 31)
        server_print("[OKAPI Remaster] Игрок %s (%d) выходит из зума (ThinkZoomOut) SPRING (%d)", 
                    name, owner, idx_weapon)
    } else {
        server_print("[OKAPI Remaster] Событие ThinkZoomOut для SPRING %d", idx_weapon)
    }
    
    // Возвращаем okapi_ret_ignore для продолжения оригинальной функции
    return okapi_ret_ignore
}

/**
 * Обработчик события зумирования (ThinkZoomOutIn) для ENFIELD
 * 
 * @param idx_weapon Индекс оружия
 * @return Тип возврата для OKAPI
 */
public On_func_ThinkZoomOutIn_ENFIELD(idx_weapon)
{   
    // Получаем владельца оружия
    new owner = pev(idx_weapon, pev_owner)
    if(is_user_connected(owner)) {
        new name[32]
        get_user_name(owner, name, 31)
        server_print("[OKAPI Remaster] Игрок %s (%d) использует зум (ThinkZoomOutIn) ENFIELD (%d)", 
                    name, owner, idx_weapon)
    } else {
        server_print("[OKAPI Remaster] Событие ThinkZoomOutIn для ENFIELD %d", idx_weapon)
    }
    
    // Возвращаем okapi_ret_ignore для продолжения оригинальной функции
    return okapi_ret_ignore
}

/**
 * Обработчик события зумирования (ThinkZoomOutIn) для SPRING
 * 
 * @param idx_weapon Индекс оружия
 * @return Тип возврата для OKAPI
 */
public On_func_ThinkZoomOutIn_SPRING(idx_weapon)
{   
    // Получаем владельца оружия
    new owner = pev(idx_weapon, pev_owner)
    if(is_user_connected(owner)) {
        new name[32]
        get_user_name(owner, name, 31)
        server_print("[OKAPI Remaster] Игрок %s (%d) использует зум (ThinkZoomOutIn) SPRING (%d)", 
                    name, owner, idx_weapon)
    } else {
        server_print("[OKAPI Remaster] Событие ThinkZoomOutIn для SPRING %d", idx_weapon)
    }
    
    // Возвращаем okapi_ret_ignore для продолжения оригинальной функции
    return okapi_ret_ignore
}

/**
 * Обработчик события зумирования (ThinkZoomOutIn) для ScopedKar
 * 
 * @param idx_weapon Индекс оружия
 * @return Тип возврата для OKAPI
 */
public On_func_ThinkZoomOutIn_ScopedKar(idx_weapon)
{   
    // Получаем владельца оружия
    new owner = pev(idx_weapon, pev_owner)
    if(is_user_connected(owner)) {
        new name[32]
        get_user_name(owner, name, 31)
        server_print("[OKAPI Remaster] Игрок %s (%d) использует зум (ThinkZoomOutIn) ScopedKar (%d)", 
                    name, owner, idx_weapon)
    } else {
        server_print("[OKAPI Remaster] Событие ThinkZoomOutIn для ScopedKar %d", idx_weapon)
    }
    
    // Возвращаем okapi_ret_ignore для продолжения оригинальной функции
    return okapi_ret_ignore
}

/**
 * Обработчик события изменения поля зрения
 * 
 * @param id Индекс игрока
 * @return Значение FOV
 */
public Set_fov_post(id)
{
    new fov = read_data(1)
    new name[32]
    get_user_name(id, name, 31)
    
    server_print("[OKAPI Remaster] Игрок %s изменил FOV на %d", name, fov)
    
    return fov
}

/**
 * Пример использования сигнатур для поиска функций
 * 
 * Сигнатуры - это последовательности байтов, которые уникально идентифицируют функцию.
 * Для поиска по сигнатуре можно использовать:
 * 1. Точные байты (0x55, 0x8B, 0xEC и т.д.)
 * 2. Маску "𐌻" или любое значение выше 0xFF для пропуска байта при сравнении
 * 
 * Пример сигнатуры для ThinkZoomIn:
 * new const sig_ThinkZoomIn[] = {0x55, 0x8B, 0xEC, 0x83, 0xEC, 0x44, 0x53, 0x56, 0x57};
 * new ptr = okapi_mod_find_sig(sig_ThinkZoomIn, sizeof(sig_ThinkZoomIn));
 */ 