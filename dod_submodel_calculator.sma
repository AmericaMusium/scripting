#include <amxmodx>
#include <amxmisc>


/// 782
public plugin_init()
{
    server_print("SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS");
    new INPUT_NUMB_GROUP = 4;
    new INPUT_SIZE_BODYGROUP[] = {6, 8, 7, 7};
    new INPUT_SELECT_BODYGROUP[] = {3, 3, 3, 3};
    new BodYY = dyn_pev_body_index(INPUT_NUMB_GROUP, INPUT_SIZE_BODYGROUP, INPUT_SELECT_BODYGROUP);
    server_print("SSSSSSSSSSSSSSSSSSS  INDEX = %d           SSSSSSSSSSSSSSSSSSSSSSSSSS", BodYY); 
    // напиши формула расчёта правильную, в данном случае должен быть равен 782
    

}
// Функция расчета индекса pev_body
// Функция расчета индекса pev_body

stock dyn_pev_body_index(num_bodygroups, const size_bodygroups[], const chosen_submodels[])
{
    new index = 0;
    new group_multiplier = 1; // Множитель для каждой группы

    // Проверка на корректность количества групп
    if (num_bodygroups <= 0) 
    {
        log_amx("Ошибка: количество групп должно быть больше 0");
        return -1; // Индикатор ошибки
    }

    for (new i = 0; i < num_bodygroups; i++) 
    {
        // Проверка корректности выбранной субмодели
        if (chosen_submodels[i] < 1 || chosen_submodels[i] > size_bodygroups[i])
        {
            log_amx("Ошибка: некорректный выбор субмодели в группе %d", i + 1);
            return -1; // Индикатор ошибки
        }

        index += (chosen_submodels[i] - 1) * group_multiplier; // -1 для нумерации с 0
        group_multiplier *= size_bodygroups[i]; // Увеличение множителя для следующей группы
    }

    return index;
}