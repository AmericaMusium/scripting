#include <amxmodx>

// Массив для хранения количества убийств каждого игрока
new Playerskills[32];

// Функция, вызываемая при смерти игрока
public client_death(client, killer, weapon)
{
    // Увеличиваем количество убийств у убийцы
    if (killer > 0 && killer <= 32)
    {
        Playerskills[killer]++;
    }
}

// Функция для поиска игрока с максимальным количеством убийств
public FindPlayerWithMaxKills()
{
    new maxKills = 0;
    new maxPlayer = 0;

    // Перебираем игроков
    for (new i = 1; i <= 32; i++)
    {
        // Если у игрока больше убийств, обновляем максимум
        if (Playerskills[i] > maxKills)
        {
            maxKills = Playerskills[i];
            maxPlayer = i;
        }
    }

    // Выводим информацию о игроке с максимальным количеством убийств
    if (maxPlayer > 0)
    {
        client_print(0, print_chat, "Игрок %d имеет максимальное количество убийств: %d", maxPlayer, maxKills);
    }
    else
    {
        client_print(0, print_chat, "Нет убийств на сервере.");
    }
}

// Функция, вызываемая при старте раунда (вызывайте ее по необходимости)
public RoundStart()
{
    // Обнуляем количество убийств перед началом раунда
    for (new i = 1; i <= 32; i++)
    {
        Playerskills[i] = 0;
    }
}

// Регистрация хуков и команд
public plugin_init()
{
    register_clcmd("say /maxkills", "FindPlayerWithMaxKills");
    register_clcmd("say /roundstart", "RoundStart");

    register_event("DeathMsg", "client_death", "b", "1=userid,2=attacker,3=weapon");
}
