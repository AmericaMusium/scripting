#include <amxmodx>
#include <engine>

// Константы для количества bodygroups и субмоделей в каждой группе
#define NUM_BODYGROUPS 4
new const SUBMODELS_PER_GROUP[NUM_BODYGROUPS] = {6, 8, 7, 7};



// Пример использования (тот же, что и раньше)
public plugin_init()
{
    // ... (регистрация плагина и т.д.)

    new chosen_submodels[NUM_BODYGROUPS] = {3, 3, 5, 1};
    new pev_body = pev_body_index(chosen_submodels);

    if (pev_body != -1)
    {
        server_print("PEV Body Index: %d", pev_body); // Вывод результата
    }
}


// Функция расчета индекса pev_body
stock pev_body_index(const chosen_submodels[])
{
    new index = 0;
    new group_multiplier = 1; // Множитель для каждой группы

    for (new i = 0; i < NUM_BODYGROUPS; i++) 
    {
        // Проверка корректности выбранной субмодели
        if (chosen_submodels[i] < 1 || chosen_submodels[i] > SUBMODELS_PER_GROUP[i])
        {
            log_amx("Ошибка: некорректный выбор субмодели в группе %d", i + 1);
            return -1; // Индикатор ошибки
        }

        index += (chosen_submodels[i] - 1) * group_multiplier; // -1 для нумерации с 0
        group_multiplier *= SUBMODELS_PER_GROUP[i]; // Увеличение множителя для следующей группы
    }

    return index;
}




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