#include <amxmodx>
#include <fakemeta>
#include <engine>


new const MATERIAL_TYPES[][] = 
{
    "METAL_WALL04",  // M
    "GRATE1",        // G
    "OUT_DIRT1",     // D
    "FIFTIES_F01",   // T
    "TRRM_WOOD",     // W
    "OUT_GRSS1",     // P
    "GLASSBLUE1",    // Y
    "!WATERBLUE",    // S
    "OUT_RK5",       // R
    "OUT_SND2B",     // A
    "OUT_SND2C",     // L
    "C3A2B_REAC",    // E
    "WHITE",         // N
    "C3A2SIGN00",    // F
    "WET_WALL05",    // B
    "FIFTIES_WALL03" // Z
};

new const MATERIAL_CODES[] = "MGDTPWYSRALENFBZ";

public plugin_init()
{
    register_plugin("Material Detector", "1.0", "Your Name");
    register_clcmd("say /detect", "cmd_detect_material");

    set_task(5.0, "cmd_detect_material", 1);
}

public cmd_detect_material(id)
{
    // Получаем позицию глаз игрока
    new Float:vecStart[3], Float:vecEnd[3];
    pev(id, pev_origin, vecStart);


    // Получаем направление взгляда игрока
    new Float:vecAngles[3];
    entity_get_vector(id, EV_VEC_v_angle, vecAngles);
    angle_vector(vecAngles, ANGLEVECTOR_FORWARD, vecEnd);

    // Увеличиваем конечную точку луча на 9999 единиц вперёд
    vecEnd[0] = vecStart[0] + vecEnd[0] * 9999.0;
    vecEnd[1] = vecStart[1] + vecEnd[1] * 9999.0;
    vecEnd[2] = vecStart[2] + vecEnd[2] * 9999.0;

    // Определяем материал
    new material = detect_material(vecStart, vecEnd);

    // Выводим результат в чат
    switch (material)
    {
        case 'M': client_print(id, print_center, "Вы смотрите на: Металл");
        case 'W': client_print(id, print_center, "Вы смотрите на: Дерево");
        case 'C': client_print(id, print_center, "Вы смотрите на: Бетон");
        case 'G': client_print(id, print_center, "Вы смотрите на: Решётку");
        case 'D': client_print(id, print_center, "Вы смотрите на: Грязь");
        case 'T': client_print(id, print_center, "Вы смотрите на: Плитку");
        case 'P': client_print(id, print_center, "Вы смотрите на: Траву");
        case 'Y': client_print(id, print_center, "Вы смотрите на: Стекло");
        case 'S': client_print(id, print_center, "Вы смотрите на: Воду");
        case 'R': client_print(id, print_center, "Вы смотрите на: Камень");
        case 'A': client_print(id, print_center, "Вы смотрите на: Песок");
        case 'L': client_print(id, print_center, "Вы смотрите на: Гравий");
        case 'E': client_print(id, print_center, "Вы смотрите на: Листву");
        case 'N': client_print(id, print_center, "Вы смотрите на: Снег");
        case 'F': client_print(id, print_center, "Вы смотрите на: Мясо");
        case 'B': client_print(id, print_center, "Вы смотрите на: Кирпич");
        case 'Z': client_print(id, print_center, "Вы смотрите на: Штукатурку");
        default: client_print(id, print_center, "Вы смотрите на: Неизвестный материал");
    }

    set_task(1.0, "cmd_detect_material", 1);
}

public detect_material(Float:vecStart[3], Float:vecEnd[3])
{
    new tr = create_tr2();
    engfunc(EngFunc_TraceLine, vecStart, vecEnd, IGNORE_MONSTERS, 0, tr);

    // Получаем имя текстуры
    new szTextureName[32];
    engfunc(EngFunc_TraceTexture, 0, vecStart, vecEnd, szTextureName, charsmax(szTextureName));

    // old pointer memory new texture_type = dllfunc(DLLFunc_PM_FindTextureType, szTextureName);

    new texture_type[32];
    dllfunc(DLLFunc_PM_FindTextureType, szTextureName, texture_type, charsmax(texture_type));
    client_print(0, print_chat, "Вы смотрите на: %s || %s", szTextureName, texture_type);
    // Освобождаем память, выделенную для трассировки
    free_tr2(tr);   

    // Определяем материал по имени текстуры
    for (new i = 0; i < sizeof(MATERIAL_TYPES); i++)
    {
        if (equal(szTextureName, MATERIAL_TYPES[i]))
        {
            return MATERIAL_CODES[i]; // Возвращаем код материала
        }
    }

    return 'C'; // По умолчанию возвращаем бетон (Concrete)
}