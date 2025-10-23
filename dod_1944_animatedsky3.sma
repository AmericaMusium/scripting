#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>
/*
на доннере лучше добавить смену скина облачного неба, с диффузией и сменой оттенков, всё это засинхронить со лайтспесами оставив там дождь навсегда
вариант 2: делать в одном плагине модель с прозрачной текстурой, но анимаецией, можно попробовать прямо сейчас
02-10-2025 Создано прозрачное облако работаеще под обычный скайбокс. 
Задача: построить внешний скайбокс по тому же типу, как базовая подложка, надеемся на отсуствие интерполяции
И ТАК, КОГДА  внешняя модель в норме и без флагов текстурирования,
Внутреняя модель прекраснно работает с флагом Transparent что бы задать двухслойной небо, НО!
При включениии флага Additive на внутренней модели, не работает, и текстуру становится полностью не видно в игре. 
Проблема последовательности рендера движка, внешнюю модель делать Additive нельзя, так как будет просмтариваться скайбокс обычный. 
А нам это не надо. 
Плагин прекрасно работает только с одним дополнительным слоем неба, но я хочу сделать 2 слоя. 
1 - который полностью перекрывает скайбокс,
2 - внутренняя модель, которая накладывается в режиме Transparent + Additive  на тектсуры внешний модели. 
В игровом пространсве мы находимся внутри этих сферических моделей неба. 
## s
Считаю что подложку Base делать надо SkinChange + поворот вокруг Z 
А Clouds надо делать со сменой SkinChange + поворот вокруг Y + AplhaChannel Changing =)
04-10
 

+ сделать Angle clamp fuse 
+ Сделать динамический траспарент облаков (вопрос синхронизировать ли его со скином)
ответ: не синхронизировать, т.к при полной облачности иногда нужна прозрачность, а при частичной нужно бывает и то и другое
вопрос с Transparent так и не решён. 
надо проверить дневное небо, и как его затемняет или засветляет цвет. поставить серый и смотреть как работает на ясной погоде. 
можно ли сделатть сменяемый тип погоды ? на пример ясный\пасмурный это самая сложная комбинация.
Фактически сейчас разговор идёт вот о каких свойствах:
Сфера облаков не может использовать и TransParent и Additive . она использует только  !! transparent?? ??
срочно проверить как работает Транспарент без аддитива

ответ: CLOUDSmdl=> texture.flag=Transparent + pev.kRenderTransTexture = (128-255) от 50до100% наложения. не менее

base.flag.flatshade = true, регулируется при смене освещения, всё меня устраивает. прозрачность облаков поверх работает
set_pev(g_Sky_Clouds, pev_rendermode, kRenderTransTexture); // отключает флаг additive  на модели )) 
kRenderTransAlpha\kRenderTransTexture = наложение 128-255  полноценное 
kRenderTransAdd = additive работает от 128 до 255


и так облачность надо делать как монотонный переход + градиентное небо без флага прозрачности, это будет рабоать в обычном режиме наложения 
и снимает наобходимость работы с палитрой. при этом мы можем отрегулировать смену скинов с облачностью 
на пример сделать:
clodmdl1 = полный диифузионный слой облачности
cloud2 = диффузия в одиночное облако = универсальная модель облков , довольно хорошая. +++ надо делать .flatshade kRenderTransAlpha 75


настройку облачности надо делать через конфиг в котором выставляется clamp ! 
а там уж пусть гуляеть рандомом от и до . рандом внтри плагина разворавичвается назад
тогда при универсалной модели сохраняется разнообразие и в нужный моммент его можно ограничиить сфокусировав настройками


как бы не пришлось делать СУКА ! придётся делать. Солнце и Луну с циклами
режим kRenderAdditive 128  с довольно нёмными параметрами. 
скин = цикл луны
Frames = цикл суток

подумать к чему привязать течение времени.
на до думать свечки освещения. 
time-goes = 1
time-min = начало суток 0
time-max = конец 24 // это параметр положения солнца и луны
light-min = это практически сильно привязанный параметр к time
light-max =

base-skin_min/max = привязать на базу погоды или на базу цвета?

// облако в полном порядке
cloud-skin-min
cloud-skin-max = в своём ритме 
cloud-skin-speed = скорость смены кадров.
cloud-trans-min/max = облачная интенсивность clamp

sun additive 170 задаёт яркость в дневное время.. 
поработать со скоростью вращения CLOUD , если прозрачность маленькая, то скрость 30.0 
и начиная с прозрачности замедлить срочно


Самая первая версия плагина подразумевал прекеш одной модели и выбор у неё скина неба, модель была оснащена анимацией вращения, и к сожалению минимальная скорость вращения была не совсем приемлима для меня.
Переделка анимации означала увеличение размерма файла (на 10-100 килобайт я думаю), тем не менее работать с анимацией через код было ограниченным в том. что завалаось только скорость или номер секвенции либо её кадр (я думаю эти очевидные вещи известны всем). 
Главная проблема использования готовой анимации, что у неё было одно направление вращения. Я решил отказаться и просто задал угловую скорость врещния модели. 
Важно: данная модель с картой текстурировано создано не мной, позже я переделал и переместил точку origin в геометрический центр модели. Такая модель стала пригодной для дальнейшей работы.
Но вернёмся на шаг назад: когда менялись скины и была готовая анимация, я решил сделать около 36 файлов, это был 36 фильм небесного цикла.
Проблемы с которыми я столкнулся это дискретные значения, который были слишком заметны на медленной скорости, из-за ограничения размера файла текстуры, звёзды были размытыми. 
Всё это привело меня к попытке создания двухслойного неба, в коротом облака были бы в режиме "additive". 
На этот раз проблема былоа в том, что если файл модели сохранён с параметром "additive" и "transparent",то модель не отображается вообще.
поверх другой. Нейросеть сказал что проблема в неком Z-буфере. В прочем мне не захотелось тратить на это время и к глубокой ночи методом подбора и экспериментов у меня получилось следующее:
я отключил все флаги при комплиции 3д файлов, и решил использовать варианты через amxxmodx set_pev(iEntity, pev_rendermode, kRenderTransAdd); 
.
Если на модели включён флаг "transparent", то через amxx вы можете регулировать прозрачность от 128 до 255, ествесвенно что от 0 до 128 совершается слишком сильный скачёк наложения.
В конечном итоге: повторюсь я отключил все флаги , кроме "flatshade=true" , "fullbright=true", но fullbright кажется не работает в Day Of Defeat. 
С помощью кода я выбираю тип рендера и регулирую силу наложения. Не поленюсь, расскажу почему всё так стало и на этом закончу свои коментарии:
Я попробовал создать третью сферу с режимом "Additive" и это сработало, на него я расположил белый шар на чёрном фоне, это позволило симулировать небесные тела, но без цветных оттенков, выглядело ненатурально.
Тогда я закрасил всю текстуру градиентом, который содержит такие цвета, который мы видели на небе. к моему удивлению последовательность этих цветов была такой же как у радуги. хотя это должно было быть прогнозируемо.
Затем я добавил на этот градиент светило, но ночной цикл без луны, это меня натолкнуло на то, что бы убрать и выделить в отельный файл, но пока этьо не исполнено.
Градент вместо кольцевидных переходов, я переделал в ещё более плавный градиень , который представлен на данный момент в релизе.
Базовый слой я сделал размым но с присутсвием облаков, что бы видно было наложение слоистость при комбинации со вторым слоем. 
Экспозиция и тональность базового и облачных слоёв многократно подобраны, не за 1 раз, так что на вопрос почему они именно такие , ответ: потому что так они смотрятся пока лучше всего из всех моих проб.
 
12-10-2025 Желаю переструктурировать плагин: 
Базовы слой было бы не плохо переделать потом ! 
Облачный слой в норме.
Слой Цвета прекрасен. 
Слой Солнца и Луны - надо переделывать
Слой молний будет субмоделью в небесной модели, и код запуска молнии будет (включение второй субмодели и её выключение.)
Возможно 
Молния : добавить эхо молнию, добавть гром предварительный . 
*/
#define PLUGIN		"Animated Sky"
#define VERSION		"3.0"
#define AUTHOR		"Sneaky.amxx | GlobalModders.net | MayroN | America//ClassicFresh"


#define CLASSNAME_SKY	"animated_sky"
#define THUNDER		"sprites/laserbeam.spr"

#define TASK_LIGHT	789697

new idx_Base;
new idx_Cloud;
new idx_ColorLayer;
new idx_SunMoon;
new is_enable_time;
new is_need_sound = 0;

new	SKY_DARK_MIN = 'b'; // По умолчанию
new	SKY_LIGHT_MAX = 'z'; // По умолчанию

new Float:SunMoon_avel_vecmul;
new Float:g_SkyDayTime;

new g_stepslight; // Количество шагов освещения
new Float:light_step_time; //  = g_timestep / float(g_stepslight * 2); // Время для одного шага освещения
new g_current_light_step; // Текущий шаг освещения
new direction_light = 1; // Направление смены освещения (1 — вперёд, -1 — назад)


new const sz_Base_Model[][] = 
{	
	"models/animated_sky/1944_transbase.mdl"
}

new const sz_Cloud_Model[][] = 
{
	"models/animated_sky/1944_transclouds.mdl"
}

new const sz_SunMoon_Model[][] = 
{
	"models/animated_sky/1944_transsun.mdl",
	"models/animated_sky/1944_sunmoon.mdl"
}


new 
	mapname[64],
	sky_type,
	szSKY_LIGHT_CURRENT[2],
	szSKY_LIGHT_START[2],
	szSKY_LIGHT_MAX[2],
	szSKY_DARK_MIN[2],
	Float:sky_thunder_time,
	Float:base_avelocty[3],
	Float:CLOUDNESS,
	Float:BRIGHTNESS,
	Float:cloud_avelocty[3],
	Float:cloud_trans_min,
	Float:cloud_trans_max,
	cloud_skin_direction
	;


new const S_Thunder[][] = 
{
	"1944/1944w_thunder0.wav",
	"1944/1944w_thunder1.wav",
	"1944/1944w_thunder2.wav",
	"1944/1944w_thunder3.wav",
	"1944/1944w_thunder4.wav"
}

new g_thunder;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);



	Base_Create();
	Cloud_Create();
	ColorLayer_Create();
	SunMoon_Create();

	Sky_Update();
	

	set_cvar_num("sv_zmax", 50000);	
	set_cvar_num("sv_skycolor_r", 0);
	set_cvar_num("sv_skycolor_g", 0);
	set_cvar_num("sv_skycolor_b", 0);

	register_forward(FM_RemoveEntity, "onFM_RemoveEntity");

}

public plugin_precache()
{
	LOAD_CONFIG();
}

public LOAD_CONFIG()
{
	get_mapname(mapname, charsmax(mapname));
	new cfgdir[128],filepath[256];
	get_configsdir(cfgdir, charsmax(cfgdir));
	format(filepath, charsmax(filepath), "%s/animated_sky_settings3.ini", cfgdir);
	new linedata[1024], key[32], value[64];
	new is_right_map = 0, not_find = 0;
	new file = fopen(filepath, "rt");
	while (file && !feof(file))
	{
		fgets(file, linedata, charsmax(linedata));
		replace(linedata, charsmax(linedata), "^n", "");
		if (!linedata[0] || linedata[0] == ';' || linedata[0] == '/') continue;
		if (linedata[0] == '[')
		{
			if (containi(linedata, mapname) != -1)
			{
				is_right_map++;
				not_find++;
			}
			continue;
		}
		if(is_right_map)
		{
			strtok(linedata, key, charsmax(key), value, charsmax(value), '=');
			trim(key);
			trim(value);
		
			if (equal(key, "SKY_TYPE"))
			{
				sky_type = str_to_num(value);
				// server_print("[***CLOUD] pause %d %s", sky_type , key);

				if(sky_type == -1)
				{	
					// server_print("[***CLOUD] pause");
					// pause("ad");
					return;
				}
			}

			// BASE 
			else if(equal(key, "BASE_MDL"))
			{	
				idx_Base = str_to_num(value);
				if(idx_Base >= 0)
				{
					engfunc(EngFunc_PrecacheModel, sz_Base_Model[idx_Base]);
					// server_print("[***CLOUDS] BASE model precached: %s", sz_Base_Model[idx_Base]);
				}
			}
			////// Облака
			//
			else if(equal(key, "CLOUD_MDL"))
			{	
				idx_Cloud = str_to_num(value);
				if(idx_Cloud >= 0)
				{
					engfunc(EngFunc_PrecacheModel, sz_Cloud_Model[idx_Cloud]);
					// server_print("[***CLOUDS] model precached: %s", sz_Cloud_Model[idx_Cloud]);
				}

			}
			else if (equal(key, "CLOUD_TRANS_MIN"))
			{
				cloud_trans_min = str_to_float(value);
				// server_print("[***CLOUDS] CLOUD cloud_trans_min: %f", cloud_trans_min);
			}

			else if (equal(key, "CLOUD_TRANS_MAX"))
			{
				cloud_trans_max = str_to_float(value);
				// server_print("[***CLOUDS] CLOUD cloud_trans_max: %f", cloud_trans_max);
			}
		
			else if(equal(key, "SKY_ENABLE_TIME"))
			{	
				is_enable_time = str_to_num(value);
			}
			else if(equal(key, "SKY_LIGHT_START"))
			{
				formatex(szSKY_LIGHT_START, charsmax(szSKY_LIGHT_START), "%s", value);
			}
			else if (equal(key, "SKY_LIGHT_MAX"))
			{
				formatex(szSKY_LIGHT_MAX, charsmax(szSKY_LIGHT_MAX), "%s", value);
				SKY_LIGHT_MAX = szSKY_LIGHT_MAX[0];
			}
			else if (equal(key, "SKY_DARK_MIN"))
			{
				formatex(szSKY_DARK_MIN, charsmax(szSKY_DARK_MIN), "%s", value);
				SKY_DARK_MIN = szSKY_DARK_MIN[0];
			}
			else if (equal(key, "SKY_DAYTIME"))
			{
		    	g_SkyDayTime = str_to_float(value);
    			// server_print("[SKY] Day time set to: %.1f seconds", g_SkyDayTime);
			}

			else if(equal(key, "SKY_ENABLE_SOUND"))
			{	
				is_need_sound = str_to_num(value);
			}
			else if (equal(key, "SKY_THUNDER_TIME"))
			{
			g_thunder = precache_model(THUNDER);
			sky_thunder_time = str_to_float(value);

			if(sky_thunder_time>0.0)
				set_task(sky_thunder_time, "Sky_Thunder", _, _, _, "b");
			}

			engfunc(EngFunc_PrecacheModel, sz_SunMoon_Model[0]);
			engfunc(EngFunc_PrecacheModel, sz_SunMoon_Model[1]);
		}
	}

	if(file) fclose(file);

	if(!not_find)
	{
		pause("ad");
		return;
	}

	if(is_need_sound)
	{
		for(new i = 0; i < sizeof S_Thunder; i++)
			precache_sound(S_Thunder[i])
	}

}

public client_connect(id)
{
	client_cmd(id, "cl_weather 1");
}


public sync_light_for_client(id)
{
    if(is_user_connected(id))
    {
        // Триггер синхронизации
        engfunc(EngFunc_LightStyle, 0, szSKY_LIGHT_CURRENT);
	}
}

public client_putinserver(id)
{	
	set_task(0.1, "sync_light_for_client", id);
	return PLUGIN_CONTINUE;
}


public Sky_Update()
{	
	format(szSKY_LIGHT_CURRENT,1, szSKY_LIGHT_START);
	set_lights(szSKY_LIGHT_CURRENT);
	if (!is_enable_time)
	{
		// Если время не активно, просто устанавливаем освещение

		return;
	}
	else
	{	
		Start_Cycles();
		Set_Sphere_aVel();
	}
}


// Добавь в начале файла с другими переменными
new g_SkyHours;
new g_SkyMinutes;
new Float:g_TimeAccumulator;

// В функции Start_Cycles() добавь инициализацию времени:
public Start_Cycles()
{
    if (!is_enable_time)
        return;
        
    // Автоматический расчет шагов освещения
    g_stepslight = SKY_LIGHT_MAX - SKY_DARK_MIN;
    light_step_time = g_SkyDayTime / float(g_stepslight * 2);
    
    // Автоматический расчет скорости вращения солнца
    SunMoon_avel_vecmul = 360.0 / g_SkyDayTime;
    
    // Сбрасываем состояние цикла и время
    g_current_light_step = 0;
    direction_light = 1;
    g_SkyHours = 0; // Начинаем с 00:00
    g_SkyMinutes = 0;
    g_TimeAccumulator = 0.0;
    
    // Устанавливаем начальное освещение
    new current_light = SKY_DARK_MIN + g_current_light_step;
    formatex(szSKY_LIGHT_CURRENT, charsmax(szSKY_LIGHT_CURRENT), "%c", current_light);
    set_lights(szSKY_LIGHT_CURRENT);
    
    // Запускаем задачи
    remove_task(TASK_LIGHT);
    set_task(light_step_time, "Update_Lighting", TASK_LIGHT, _, _, "b");
    
    remove_task(98765);
    set_task(g_SkyDayTime, "On_New_Day", 98765);
    
    // Обновляем вращение небесных тел

    
    // Выводим начальное время
    PrintSkyTime();
}

// Модифицируй функцию Update_Lighting():
public Update_Lighting()
{
    // Обновляем текущий шаг
    g_current_light_step += direction_light;

    // Проверяем границы и меняем направление если нужно
    if (g_current_light_step >= g_stepslight)
    {
        g_current_light_step = g_stepslight - 1;
        direction_light = -1;
    }
    else if (g_current_light_step < 0)
    {    
        g_current_light_step = 0;
        direction_light = 1;
    }

    // Рассчитываем текущую букву освещённости
    new current_light = SKY_DARK_MIN + g_current_light_step;
    
    // Устанавливаем освещение
    formatex(szSKY_LIGHT_CURRENT, charsmax(szSKY_LIGHT_CURRENT), "%c", current_light);
    set_lights(szSKY_LIGHT_CURRENT);
    
    // Обновляем время
    UpdateSkyTime();
    
    // Синхронизируем с клиентами
    for (new id = 1; id <= get_maxplayers(); id++)
    {
        if (is_user_connected(id))
        {
            engfunc(EngFunc_LightStyle, 0, szSKY_LIGHT_CURRENT);
        }
    }
}

// Добавь новые функции для работы со временем:
UpdateSkyTime()
{
    // Накапливаем время и обновляем минуты/часы
    g_TimeAccumulator += light_step_time;
    
    // Каждые 60 "игровых минут" обновляем время
    new minutes_to_add = floatround(g_TimeAccumulator / (g_SkyDayTime / (24.0 * 60.0)));
    
    if (minutes_to_add > 0)
    {
        g_SkyMinutes += minutes_to_add;
        g_TimeAccumulator = 0.0;
        
        // Обрабатываем перенос часов
        while (g_SkyMinutes >= 60)
        {
            g_SkyMinutes -= 60;
            g_SkyHours++;
            
            if (g_SkyHours >= 24)
            {
                g_SkyHours = 0;
            }
            
            // Каждый час выводим время (опционально)
            if (g_SkyMinutes == 0)
            {
                PrintSkyTime();
            }
        }
        
        // Выводим время каждые 30 минут (можно изменить)
        if (g_SkyMinutes == 0 || g_SkyMinutes == 30)
        {
            PrintSkyTime();
        }
    }
}

PrintSkyTime()
{
    new timeString[32];
    
    // Форматируем время в виде ЧЧ:ММ
    format(timeString, charsmax(timeString), "%02d:%02d", g_SkyHours, g_SkyMinutes);
    
    // Определяем время суток для красивого вывода
    new timeOfDay[32];
    if (g_SkyHours >= 5 && g_SkyHours < 12)
        format(timeOfDay, charsmax(timeOfDay), "Утро");
    else if (g_SkyHours >= 12 && g_SkyHours < 17)
        format(timeOfDay, charsmax(timeOfDay), "День");
    else if (g_SkyHours >= 17 && g_SkyHours < 22)
        format(timeOfDay, charsmax(timeOfDay), "Вечер");
    else
        format(timeOfDay, charsmax(timeOfDay), "Ночь");
    
    server_print("[SKY] Время суток: %s (%s)", timeString, timeOfDay);
    
    // Можно также выводить в чат всем игрокам (раскомментируй если нужно)
    
    for (new id = 1; id <= get_maxplayers(); id++)
    {
        if (is_user_connected(id))
        {
            client_print(id, print_chat, "[Небо] Сейчас %s (%s)", timeString, timeOfDay);
        }
    }
    
}

// Обнови функцию On_New_Day():
public On_New_Day()
{    
    // Выводим время перед сбросом
    server_print("[SKY] Завершились сутки. Последнее время: %02d:%02d", g_SkyHours, g_SkyMinutes);
    
    // Перезапускаем цикл
    Start_Cycles();
}

/*  
блок 2 .улуччшенный 
public Start_Cycles()
{
    if (!is_enable_time)
        return;
        
    // Автоматический расчет шагов освещения
    g_stepslight = SKY_LIGHT_MAX - SKY_DARK_MIN;
    light_step_time = g_SkyDayTime / float(g_stepslight * 2);
    
    // Автоматический расчет скорости вращения солнца
    SunMoon_avel_vecmul = 360.0 / g_SkyDayTime;
    
    // Сбрасываем состояние цикла
    g_current_light_step = 0;
    direction_light = 1;
    
    // Устанавливаем начальное освещение
    new current_light = SKY_DARK_MIN + g_current_light_step;
    formatex(szSKY_LIGHT_CURRENT, charsmax(szSKY_LIGHT_CURRENT), "%c", current_light);
    set_lights(szSKY_LIGHT_CURRENT);
    
    // Запускаем задачи
    remove_task(TASK_LIGHT);
    set_task(light_step_time, "Update_Lighting", TASK_LIGHT, _, _, "b");
    
    remove_task(98765); // Уникальный ID для задачи нового дня
    set_task(g_SkyDayTime, "On_New_Day", 98765);
    
    // Обновляем вращение небесных тел
    Set_Sphere_aVel();
}

public Update_Lighting()
{
    // Обновляем текущий шаг
    g_current_light_step += direction_light;

    // Проверяем границы и меняем направление если нужно
    if (g_current_light_step >= g_stepslight)
    {
        g_current_light_step = g_stepslight - 1;
        direction_light = -1;
    }
    else if (g_current_light_step < 0)
    {    
        g_current_light_step = 0;
        direction_light = 1;
    }

    // Рассчитываем текущую букву освещённости
    new current_light = SKY_DARK_MIN + g_current_light_step;
    
    // Устанавливаем освещение
    formatex(szSKY_LIGHT_CURRENT, charsmax(szSKY_LIGHT_CURRENT), "%c", current_light);
    set_lights(szSKY_LIGHT_CURRENT);
    
    // Синхронизируем с клиентами
    for (new id = 1; id <= get_maxplayers(); id++)
    {
        if (is_user_connected(id))
        {
            engfunc(EngFunc_LightStyle, 0, szSKY_LIGHT_CURRENT);
        }
    }
}

public On_New_Day()
{    
    // Просто перезапускаем цикл
    Start_Cycles();
    
    // Логируем начало новых суток (для отладки)
    server_print("[SKY] New day started - %s", szSKY_LIGHT_CURRENT);
}

*/
/*
старый блок 
public Start_Cycles()
{
    if (is_enable_time)
    {
		// Автоматический расчет шагов освещения
		g_stepslight = SKY_LIGHT_MAX - SKY_DARK_MIN + 1;
		light_step_time = g_SkyDayTime / float(g_stepslight * 2);
		
		// Автоматический расчет скорости вращения солнца
		SunMoon_avel_vecmul = 360.0 / g_SkyDayTime;
		
		// Устанавливаем скорость вращения солнца

		set_task(light_step_time, "Update_Lighting", TASK_LIGHT, _, _, "b");
		set_task(g_SkyDayTime, "On_New_Day");
	}
}


public On_New_Day()
{	
	remove_task(TASK_LIGHT);

	g_current_light_step = 0;

	// Запускаем новый цикл
	Start_Cycles();
	Set_Sphere_aVel();

}

public Update_Lighting()
{
	// Увеличиваем или уменьшаем текущий шаг в зависимости от направления
	g_current_light_step += direction_light;

	// Если достигли максимума, меняем направление на уменьшение
	if (g_current_light_step >= g_stepslight)
	{
		g_current_light_step = g_stepslight - 1;
		direction_light = -1;
	}
	// Если достигли минимума, меняем направление на увеличение
	else if (g_current_light_step < 0)
	{	
		g_current_light_step = 0;
		direction_light = 1;
	}

	// Рассчитываем текущую букву освещённости
	new current_light = SKY_DARK_MIN + g_current_light_step;

	
	// Устанавливаем освещение
	formatex(szSKY_LIGHT_CURRENT, charsmax(szSKY_LIGHT_CURRENT), "%c", current_light);
	// // server_print("CLOD LIGHT LEVEL %s", szSKY_LIGHT_CURRENT);
	set_lights(szSKY_LIGHT_CURRENT);
	
}

*/
public Sky_Thunder() 
{
	if(CLOUDNESS < 40.0 || BRIGHTNESS > 60.0) return;

	set_lights("z");
	new Float:origin[3], Float:end[3]

	origin[0] += random_num(-2000, 2200)
	origin[1] += random_num(-2000, 2200)
	origin[2] += 99999.9

	end[0] = origin[0]
	end[1] = origin[1]
	end[2] = -99999.9

	engfunc(EngFunc_TraceLine, origin, end, IGNORE_MONSTERS, 0, 0)
	get_tr2(0, TR_vecEndPos, end)
	
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY) 
	write_byte(TE_BEAMPOINTS) 
	write_coord_f(origin[0]) 
	write_coord_f(origin[1]) 
	write_coord_f(origin[2]) 
	write_coord_f(end[0]) 
	write_coord_f(end[1]) 
	write_coord_f(end[2]) 	
	write_short(g_thunder) 
	write_byte(1) 
	write_byte(5) 
	write_byte(2) 
	write_byte(60) 
	write_byte(35)
	write_byte(255) 
	write_byte(255) 
	write_byte(255) 
	write_byte(255) 
	write_byte(200) 
	message_end() 
	
	set_task(0.1, "Sky_Thunder_Decay");

}

public Sky_Thunder_Decay()
{
	
	set_lights(szSKY_LIGHT_CURRENT);

	// emit_sound(0, CHAN_AUTO, S_Thunder[random_num(0, sizeof(S_Thunder)-1)], 1.0, ATTN_NORM, 0, PITCH_NORM);
	for(new id = 1 ; id < get_maxplayers() + 1 ; id++)
	{ 	
		if(is_user_connected(id))
		{
			client_cmd( id,"spk %s", S_Thunder[random_num(0, sizeof(S_Thunder)-1)]);
		}
		
	}
	
}


public client_disconnected(id)
{
	if(task_exists(id + 3175))
		remove_task(id + 3175);
	if(task_exists(id + 6317))
		remove_task(id + 6317);
}

public Base_Create()
{	
	new iEntity = create_entity("info_target");
	
	if(!pev_valid(iEntity))
		return;
	
	set_pev(iEntity, pev_classname, CLASSNAME_SKY);
	set_pev(iEntity, pev_movetype, MOVETYPE_TOSS);
	set_pev(iEntity, pev_solid, SOLID_NOT);
	set_pev(iEntity, pev_sequence, 0);
	set_pev(iEntity, pev_angles, {0.0, 0.0, 0.0});
	base_avelocty[1] = 4.5 * generate_random_velocity_compact();
	base_avelocty[2] = 3.4 * generate_random_velocity_compact();
	set_pev(iEntity, pev_avelocity, base_avelocty); // задаёт вращение 
	engfunc(EngFunc_SetModel, iEntity, sz_Base_Model[idx_Base]);

	engfunc(EngFunc_SetSize, iEntity, Float:{-50000.0, -50000.0, -50000.0}, Float:{50000.0, 50000.0, 50000.0});
	idx_Base = iEntity;
}


public Cloud_Create()
{
	new iEntity = create_entity("info_target");

	if(!pev_valid(iEntity))
		return;

	set_pev(iEntity, pev_classname, CLASSNAME_SKY);
	set_pev(iEntity, pev_movetype, MOVETYPE_TOSS);
	set_pev(iEntity, pev_solid, SOLID_NOT);
	set_pev(iEntity, pev_sequence, 0);
	set_pev(iEntity, pev_framerate, 0.0);
	set_pev(iEntity, pev_angles, {0.0, 0.0, 0.0}); 
	engfunc(EngFunc_SetModel, iEntity, sz_Cloud_Model[idx_Cloud]);
	engfunc(EngFunc_SetSize, iEntity, Float:{-50000.0, -50000.0, -50000.0}, Float:{50000.0, 50000.0, 50000.0});

	cloud_avelocty[1] = 6.3 * base_avelocty[1] + generate_random_velocity_compact();
	cloud_avelocty[2] = 6.3 * base_avelocty[2] + generate_random_velocity_compact();
	set_pev(iEntity, pev_avelocity, cloud_avelocty); // задаёт вращение 
	

	set_pev(iEntity, pev_rendermode, kRenderTransTexture); // Render alpha
	set_pev(iEntity, pev_renderamt, 1.0); // 100 наверно крайнее значение
	set_pev(iEntity, pev_renderfx, kRenderFxNone); // kRenderFxFadeFast 2 

	cloud_skin_direction = 1;

	idx_Cloud = iEntity;
	
	set_task( g_SkyDayTime / 600.0 , "Cloud_Think", _, _, _, "b");

}


public Cloud_Think()
{
	new ChanceBet = random_num(1, 100);
	CLOUDNESS += 1.0 * float(cloud_skin_direction);
	if(CLOUDNESS >= cloud_trans_max || CLOUDNESS <= cloud_trans_min)
	{
		if(ChanceBet < 5) // 30% chance развернуться раньше/позже границы
		{
			cloud_skin_direction = -cloud_skin_direction; // Разворот
			CLOUDNESS = floatclamp(CLOUDNESS, cloud_trans_min, cloud_trans_max);
		}
		else
		{
			// Отскок от границы
			if(CLOUDNESS >= cloud_trans_max)
				CLOUDNESS = cloud_trans_max;
			else
				CLOUDNESS = cloud_trans_min;
			cloud_skin_direction = -cloud_skin_direction;
		}
	}
	// Дополнительный случайный разворот в середине диапазона (5% chance)
	if(ChanceBet < 5 && CLOUDNESS > cloud_trans_min + 10.0 && CLOUDNESS < cloud_trans_max - 10.0)
	{
		cloud_skin_direction = -cloud_skin_direction;
	}
	set_pev(idx_Cloud, pev_renderamt, CLOUDNESS);
	// server_print("CLOUDNESS %f | ^n BRIGHTNESS %f", CLOUDNESS , BRIGHTNESS);
}




public ColorLayer_Create()
{	
	new iEntity = create_entity("info_target");
	
	if(!pev_valid(iEntity))
		return;

	set_pev(iEntity, pev_classname, CLASSNAME_SKY);
	set_pev(iEntity, pev_movetype, MOVETYPE_TOSS);
	set_pev(iEntity, pev_solid, SOLID_NOT);
	set_pev(iEntity, pev_sequence, 0);


	engfunc(EngFunc_SetModel, iEntity, sz_SunMoon_Model[0]);
	set_pev(iEntity, pev_angles, {0.0, 0.0, 0.0}); 
	engfunc(EngFunc_SetSize, iEntity, Float:{-50000.0, -50000.0, -50000.0}, Float:{50000.0, 50000.0, 50000.0});


	set_pev(iEntity, pev_rendermode, kRenderTransAdd); // Render alpha

	idx_ColorLayer = iEntity;

	set_task(g_SkyDayTime / 600.0, "ColorLayer_Think", _, _, _, "b");
}


public ColorLayer_Think()
{	
	new Float:Sun_Angles[3];
	pev(idx_ColorLayer, pev_angles, Sun_Angles);

	if (Sun_Angles[0] < -360.0 || Sun_Angles[0] > 360.0)	Sun_Angles[0] = 0.0;
	if (Sun_Angles[1] < -360.0 || Sun_Angles[1] > 360.0)	Sun_Angles[1] = 0.0;
	if (Sun_Angles[2] < -360.0 || Sun_Angles[2] > 360.0)	Sun_Angles[2] = 0.0;
	set_pev(idx_ColorLayer, pev_angles, Sun_Angles);

	BRIGHTNESS = 127.5 * (floatcos(Sun_Angles[1] + 0.0, degrees) + 1.0);
	BRIGHTNESS -= CLOUDNESS * 1.5;
	BRIGHTNESS = floatclamp(BRIGHTNESS, 0.0, 255.0);

	set_pev(idx_ColorLayer, pev_renderamt, BRIGHTNESS);
	pev(idx_ColorLayer, pev_angles, Sun_Angles);
}




public SunMoon_Create()
{	
	new iEntity = create_entity("info_target");
	
	if(!pev_valid(iEntity))
		return;

	set_pev(iEntity, pev_classname, CLASSNAME_SKY);
	set_pev(iEntity, pev_movetype, MOVETYPE_TOSS);
	set_pev(iEntity, pev_solid, SOLID_NOT);
	set_pev(iEntity, pev_sequence, 0);

	// 20630313 mm 
	// 24062255 mm
	set_pev(idx_SunMoon, pev_angles, {0.0, 0.0, 0.0}); 
	engfunc(EngFunc_SetModel, iEntity, sz_SunMoon_Model[1]);
	
	engfunc(EngFunc_SetSize, iEntity, Float:{-50000.0, -50000.0, -50000.0}, Float:{50000.0, 50000.0, 50000.0});

	
	set_pev(iEntity, pev_rendermode, kRenderTransAdd); // Render alpha
	set_pev(iEntity, pev_renderamt, 0.0);
	idx_SunMoon = iEntity;
	set_task( g_SkyDayTime / 600.0 , "SunMoon_Think", _, _, _, "b");
	server_print( " MOOON SUUN CREARED ");

}

public SunMoon_Think()
{
	static Float: MoonBrightness;
	MoonBrightness = BRIGHTNESS - (CLOUDNESS*0.5);
	MoonBrightness = floatclamp(MoonBrightness, 0.0, 255.0);
	//
	set_pev(idx_SunMoon, pev_renderamt, MoonBrightness);
	//server_print("MOONRIGHT %f", MoonBrightness);
}


public Set_Sphere_aVel()
{
	new Float:ColorLayer_avel[3];
	set_pev(idx_ColorLayer, pev_angles, {0.0, 0.0, 0.0}); 
	ColorLayer_avel[0] = 2.0 * SunMoon_avel_vecmul;
	ColorLayer_avel[1] = 1.0 * SunMoon_avel_vecmul; //  кручёный бильярд, танцы
	ColorLayer_avel[2] = 1.0 * SunMoon_avel_vecmul; //
	set_pev(idx_ColorLayer, pev_avelocity, ColorLayer_avel);

	new Float:sun_obj_avel[3];
	set_pev(idx_SunMoon, pev_angles, {0.0, 0.0, 0.0}); 
	sun_obj_avel[0] = 1.0 * SunMoon_avel_vecmul;
	sun_obj_avel[1] = 0.5 * SunMoon_avel_vecmul; //  
	sun_obj_avel[2] = 0.5 * SunMoon_avel_vecmul; // тарелка крутится как руль
	set_pev(idx_SunMoon, pev_avelocity, sun_obj_avel);
}	


// Компактный вариант одной строкой
stock Float:generate_random_velocity_compact()
{
    return (random_num(0, 1) ? random_float(0.3, 0.5) : random_float(-0.5, -0.3));
}

public onFM_RemoveEntity(entity)
{
    if(pev_valid(entity) && (entity == idx_Base || entity == idx_Cloud))
    {
        // server_print("Attempt to remove sky entity! Blocked.");
        return FMRES_SUPERCEDE;
    }
    return FMRES_IGNORED;
}