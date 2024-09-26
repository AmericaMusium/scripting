#include <amxmodx>

public Action:ClientCmd(id, const cmd[])
{
    if (equal(cmd, "fire"))
    {
        new Float:origin[3], Float:forward[3], Float:end[3];
        new trace_entity;

        get_user_origin(id, origin);
        get_user_vectors(id, forward, _, _);

        // Устанавливаем конечную точку луча
        for (new i = 0; i < 3; i++)
        {
            end[i] = origin[i] + forward[i] * 4096.0; // 4096.0 - длина луча
        }

        // Выполняем трассировку луча
        trace_entity = engfunc(EngFunc_TraceLine, origin, end, ignore_monsters, id);

        // Получаем индекс декали
        new decalIndex = pev( trace_entity, pev_rendermode );

        // Выводим информацию в консоль
        server_print("Декаль: %d", decalIndex);
    }
}

public plugin_init()
{
    register_clcmd("say /fire", "ClientCmd");
}


#include <amxmodx>

public Action:ClientCmd(id, const cmd[])
{
    if (equal(cmd, "fire"))
    {
        new Float:origin[3], Float:forward[3], Float:end[3];
        new trace_entity;

        get_user_origin(id, origin);
        get_user_vectors(id, forward, _, _);

        // Устанавливаем конечную точку луча
        for (new i = 0; i < 3; i++)
        {
            end[i] = origin[i] + forward[i] * 4096.0; // 4096.0 - длина луча
        }

        // Выполняем трассировку луча
        trace_entity = engfunc(EngFunc_TraceLine, origin, end, ignore_monsters, id);

        // Получаем индекс декали
        new decalIndex = pev( trace_entity, pev_rendermode );

        // Наносим декаль в другом месте (например, в текущей позиции игрока)
        new Float:newPos[3];
        get_user_origin(id, newPos);

        // Отправляем сообщение для создания декали на клиенте
        MessageBegin(MSG_BROADCAST, SVC_TEMPENTITY);
            WriteByte(TE_DECAL); // Тип временной сущности - декаль
            WriteCoord(newPos[0]);
            WriteCoord(newPos[1]);
            WriteCoord(newPos[2]);
            WriteCoord(0.0); // Нормальные декали
            WriteCoord(0.0);
            WriteCoord(1.0); // Размер декали (ширина)
            WriteShort(decalIndex); // Индекс декали
        MessageEnd();
    }
}

public plugin_init()
{
    register_clcmd("say /fire", "ClientCmd");
}
