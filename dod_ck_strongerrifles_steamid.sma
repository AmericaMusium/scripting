#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <dodx>
#include <hamsandwich>
#include <engine>

new const STEAMID_BANK[][] = 
{
    "STEAM_0:1:168151611", // America STEAM_0:1:168151617
    "STEAM_0:1:168151611"
}

new bool:is_oneshot_killer[33];

public plugin_init()
{
    register_plugin("DoD Stronger Rifles", "[ck]", "America");	
    RegisterHam(Ham_TakeDamage, "player", "func_TakeDamage");	
}

public client_connect(client)
{   
    if(is_user_bot(client)) return;
    is_oneshot_killer[client] = false;
    
    // Проверяем по файлу ИЛИ по массиву
    if (check_steamid_in_file(client) || check_from_bank(client))
    {
        is_oneshot_killer[client] = true;
        server_print("++++++++++++++++++++++++THE VIP CONNECTED AS SHOOTER: %n", client);
    }
}

public client_disconnected(id)
{
    is_oneshot_killer[id] = false;
}

bool:check_from_bank(client)
{
    static authid[35];
    get_user_authid(client, authid, charsmax(authid));
    
    for (new i = 0; i < sizeof(STEAMID_BANK); i++)
    {
        if (equal(authid, STEAMID_BANK[i]))
        {
            return true;
        }
    }
    return false;
}

bool:check_steamid_in_file(client)
{   
    new filename[128];
    static authid[35];
    get_user_authid(client, authid, charsmax(authid));
    get_configsdir(filename, charsmax(filename));
    format(filename, charsmax(filename), "%s/oneshot.ini", filename);
    
    if (!file_exists(filename))
    {
        server_print("File %s not found!", filename);
        return false;
    }
    
    new file = fopen(filename, "rt");
    if (!file)
    {
        server_print("Cannot open file %s!", filename);
        return false;
    }
    
    new line[256];
    while (fgets(file, line, charsmax(line)) != 0)
    {
        // Обрезаем символы новой строки и возврата каретки для чистоты сравнения
        trim(line);
        
        // Пропускаем пустые строки и комментарии
        if (!line[0] || line[0] == ';')
            continue;

        if (equal(line, authid))
        {   
            fclose(file);
            return true;
        }
    }
    fclose(file);
    return false;
}

public func_TakeDamage(id, inflictor, attacker, Float:damage, damagebits)
{ 
    // Проверяем, что атакующий - валидный игрок
    if (!(1 <= attacker <= 32) || !is_user_connected(attacker))
        return HAM_IGNORED;
    
    // Если атакующий - наш "убийца одним выстрелом"
    if (is_oneshot_killer[attacker])
    {
        // Меняем параметр урона на 200.0
        SetHamParamFloat(4, 200.0);
        // Сообщаем, что мы изменили параметры damage
        return HAM_OVERRIDE;
    }
    
    // Для всех остальных ничего не меняем
    return HAM_IGNORED;
}