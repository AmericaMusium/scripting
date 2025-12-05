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
23-10 наверно ... потом об\еденить модели 

28-10 переделать логику запуск молнии , если ретёрн был, то просто след таск запуска каждый раз именно там. 

02-11 Всё пока что с этим плагином отдыхаю.. желательно сдесь сделать 3д модель в одну 
*/

#define PLUGIN		"Animated Sky"
#define VERSION		"4.0"
#define AUTHOR		"Sneaky.amxx | GlobalModders.net | MayroN | America//ClassicFresh"


#define CLASSNAME_SKY	"animated_sky"
#define THUNDER		"sprites/laserbeam.spr"

#define TASK_LIGHT	789697
#define TASK_THUNDER_RUN 789698
#define TASK_THUNDER_THINK 789699
#define TASK_THUNDER_DECAY 789700

new idx_Base;
new idx_Stars;
new idx_CloudsAir;
new idx_CloudsRain;
new idx_ThunderSphere;
new idx_SunMoon;
new is_need_sound = 0;

new 
	mapname[64],
	sky_type,
	szSKY_LIGHT_CURRENT[2],
	szSKY_LIGHT_START[2],
	szSKY_LIGHT_MAX[2],
	szSKY_DARK_MIN[2],
	Float:BASE_COLOR_MIN,
	Float:BASE_COLOR_MAX,
	Float:base_avelocty[3],
	Float:STARLESS,
	Float:CLOUDNESS,
	Float:BRIGHTNESS,
	Float:SUNLESS_MOONLESS,
	Float:THUNDERLIGHT,
	Float:sunmoon_avelocty[3],
	Float:cloud_avelocty[3],
	Float:cloud_trans_min,
	Float:cloud_trans_max,
	cloud_skin_direction
	;


new	SKY_DARK_MIN = 'b'; // По умолчанию
new	SKY_LIGHT_MAX = 'z'; // По умолчанию

new Float:SunMoon_avel_vecmul;
new Float:g_SkyDayTime;

new const g_arg[ ][ ] = { "bk", "dn", "ft", "lf", "rt", "up" }  
new const g_sky_name[] = {"hav"}

enum 
{
    BaseColor,
    Stars,
    SunMoon,	// Просто Вставить ) 
    CloudsAir, // Уменьшить и добавить рейн
    CloudsRain, // Уменьшить и добавить Тандер
    Thunder
}
new const sz_Sky_Model[][] = 
{	
	"models/animated_sky/0.mdl",
	"models/animated_sky/1.mdl",
	"models/animated_sky/2.mdl",
	"models/animated_sky/3.mdl",
	"models/animated_sky/4.mdl",
	"models/animated_sky/1944_sunmoon.mdl"
}



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
	Stars_Create();
	SunMoon_Create();		
	CloudsAir_Create();
	CloudsRain_Create();
	ThunderSphere_Create();

	// set_task(random_float(10.0, 10.0), "Sky_Thunder", _, _, _, "b");
	// set_task(random_float(1.0, 5.0), "ThunderSphere_Mini");
	set_task(5.0, "Sky_Thunder", TASK_THUNDER_RUN, "", 0, "b");
	
	
	Set_Sphere_aVel();

	set_cvar_num("sv_zmax", 30000);	
	set_cvar_num("sv_skycolor_r", 0);
	set_cvar_num("sv_skycolor_g", 0);
	set_cvar_num("sv_skycolor_b", 0);

	register_forward(FM_RemoveEntity, "onFM_RemoveEntity");

}

public plugin_precache()
{
	LOAD_CONFIG();

	new precache[ 64 ]; 
	for( new i; i < sizeof g_arg; i++ ) 
	{  
		formatex( precache, 63, "gfx/env/%s%s.tga",g_sky_name, g_arg[ i ] )  
		precache_generic( precache ) 
	}  
	set_cvar_string("sv_skyname", g_sky_name);
}

public LOAD_CONFIG()
{
	engfunc(EngFunc_PrecacheModel, sz_Sky_Model[0]);
	engfunc(EngFunc_PrecacheModel, sz_Sky_Model[1]);
	engfunc(EngFunc_PrecacheModel, sz_Sky_Model[2]);
	engfunc(EngFunc_PrecacheModel, sz_Sky_Model[3]);
	engfunc(EngFunc_PrecacheModel, sz_Sky_Model[4]);
	engfunc(EngFunc_PrecacheModel, sz_Sky_Model[5]);
	g_thunder = precache_model(THUNDER);

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
		//
		is_right_map++;
		not_find++;
				//
		if(is_right_map)
		{
			strtok(linedata, key, charsmax(key), value, charsmax(value), '=');
			trim(key);
			trim(value);
		
			if (equal(key, "SKY_TYPE"))
			{
				sky_type = str_to_num(value);


				if(sky_type == -1)
				{	
					// pause("ad");
					return;
				}
			}
			else if (equal(key, "BASE_COLOR_MIN"))
			{
				BASE_COLOR_MIN = str_to_float(value);
			}
			else if (equal(key, "BASE_COLOR_MAX"))
			{
				BASE_COLOR_MAX = str_to_float(value);
			}
			else if (equal(key, "CLOUD_TRANS_MIN"))
			{
				cloud_trans_min = str_to_float(value);
			}
			else if (equal(key, "CLOUD_TRANS_MAX"))
			{
				cloud_trans_max = str_to_float(value);
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
				// Автоматический расчет скорости вращения солнца
				SunMoon_avel_vecmul = 360.0 / g_SkyDayTime;
				// server_print("[SKY] Day time set to: %.1f seconds", g_SkyDayTime);
			}



			

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
	set_pev(iEntity, pev_movetype, MOVETYPE_NOCLIP);
	set_pev(iEntity, pev_solid, SOLID_NOT);
	set_pev(iEntity, pev_sequence, 0);
	set_pev(iEntity, pev_angles, {0.0, 0.0, 0.0});

	set_pev(iEntity, pev_rendermode, kRenderTransAdd); // Render alpha
	set_pev(iEntity, pev_renderamt, 0.0); // 100 наверно крайнее значение
	set_pev(iEntity, pev_renderfx, kRenderFxNone); // kRenderFxFadeFast 2 
	set_pev(iEntity, pev_rendercolor, {0.0, 0.0, 0.0} );


	// set_pev(iEntity, pev_avelocity, base_avelocty); // задаёт вращение 
	engfunc(EngFunc_SetModel, iEntity, sz_Sky_Model[0]);
	dod_set_size(iEntity);

	idx_Base = iEntity;
	set_task(g_SkyDayTime / 600.0, "Base_Think", _, _, _, "b");
	
}

public Base_Think()
{
	new Float:Sun_Angles[3];
	pev(idx_Base, pev_angles, Sun_Angles);

	if (Sun_Angles[0] < -360.0 || Sun_Angles[0] > 360.0)	Sun_Angles[0] = 0.0;
	if (Sun_Angles[1] < -360.0 || Sun_Angles[1] > 360.0)	Sun_Angles[1] = 0.0;
	if (Sun_Angles[2] < -360.0 || Sun_Angles[2] > 360.0)	Sun_Angles[2] = 0.0;
	set_pev(idx_Base, pev_angles, Sun_Angles);

	BRIGHTNESS = 127.5 * (floatcos(Sun_Angles[1] + 0.0, degrees) + 1.0);
	BRIGHTNESS -= CLOUDNESS * 0.5;
	BRIGHTNESS = floatclamp(BRIGHTNESS, BASE_COLOR_MIN, BASE_COLOR_MAX);
	set_pev(idx_Base, pev_renderamt, BRIGHTNESS);

	STARLESS = (255.0 - BRIGHTNESS * 2.0) - CLOUDNESS;
	STARLESS = floatclamp(STARLESS, 0.0, 255.0);
	set_pev(idx_Stars, pev_renderamt, STARLESS);
	
	pev(idx_Base, pev_angles, Sun_Angles);

	// server_print("BRIGHTNESS %f", BRIGHTNESS);

	Update_Lighting_By_Angle();

}


public Stars_Create()
{	
	new iEntity = create_entity("info_target");
	
	if(!pev_valid(iEntity))
		return;
	
	set_pev(iEntity, pev_classname, CLASSNAME_SKY);
	set_pev(iEntity, pev_movetype, MOVETYPE_NOCLIP);
	set_pev(iEntity, pev_solid, SOLID_NOT);
	set_pev(iEntity, pev_sequence, 0);
	set_pev(iEntity, pev_angles, {0.0, 0.0, 0.0});

	/*
	base_avelocty[0] = 0.1 * 1.0;  // X на меня
	base_avelocty[1] = 0.2 * 1.0;  // Z
	base_avelocty[2] = 0.1 * 1.0;  // Y   <====
	*/
	set_pev(iEntity, pev_rendermode, kRenderTransAdd); // Render alpha
	set_pev(iEntity, pev_renderamt, 0.0); // 100 наверно крайнее значение
	set_pev(iEntity, pev_renderfx, kRenderFxNone); // kRenderFxFadeFast 2 
	set_pev(iEntity, pev_rendercolor, {0.0, 0.0, 0.0} );



	engfunc(EngFunc_SetModel, iEntity, sz_Sky_Model[1]);
	dod_set_size(iEntity);
	idx_Stars = iEntity;
	// set_task(g_SkyDayTime / 600.0, "Base_Think", _, _, _, "b");
}

public CloudsAir_Create()
{
	new iEntity = create_entity("info_target");

	if(!pev_valid(iEntity))
		return;

	set_pev(iEntity, pev_classname, CLASSNAME_SKY);
	set_pev(iEntity, pev_movetype, MOVETYPE_NOCLIP);
	set_pev(iEntity, pev_solid, SOLID_NOT);
	set_pev(iEntity, pev_sequence, 0);
	set_pev(iEntity, pev_framerate, 0.0);
	set_pev(iEntity, pev_angles, {0.0, 0.0, 0.0}); 
	engfunc(EngFunc_SetModel, iEntity, sz_Sky_Model[2]);

	set_pev(iEntity, pev_skin, random_num(0,4));

	// engfunc(EngFunc_SetSize, iEntity, Float:{-50000.0, -50000.0, -50000.0}, Float:{50000.0, 50000.0, 50000.0});

	// cloud_avelocty[1] = 2.3 * base_avelocty[1] + generate_random_velocity_compact();
	// cloud_avelocty[2] = -1.3 * base_avelocty[2] + generate_random_velocity_compact();
	// set_pev(iEntity, pev_avelocity, cloud_avelocty); // задаёт вращение 
	

	set_pev(iEntity, pev_rendermode, kRenderTransAdd); // Render alpha
	
	// set_pev(iEntity, pev_rendermode, kRenderTransTexture); // kRenderTransTexture 
	set_pev(iEntity, pev_renderamt, 0.0); // 100 наверно крайнее значение
	set_pev(iEntity, pev_renderfx, kRenderFxNone); // kRenderFxFadeFast 2 
	dod_set_size(iEntity);
	cloud_skin_direction = 1;

	idx_CloudsAir = iEntity;
	
	set_task( (g_SkyDayTime * 2.3) / 600.0 , "CloudsAir_Think", _, _, _, "b");

}


public CloudsAir_Think()
{
	new ChanceBet = random_num(1, 100);
	CLOUDNESS += 1.0 * float(cloud_skin_direction);
	if(CLOUDNESS >= cloud_trans_max || CLOUDNESS <= cloud_trans_min)
	{
		if(ChanceBet < 30) // 30% chance развернуться раньше/позже границы
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
			{	
				CLOUDNESS = cloud_trans_min;
				set_pev(idx_CloudsAir, pev_skin, random_num(0,4));
			}
			cloud_skin_direction = -cloud_skin_direction;
		}
	}
	/*
	// Дополнительный случайный разворот в середине диапазона (5% chance)
	if(ChanceBet < 1 && CLOUDNESS > cloud_trans_min + 10.0 && CLOUDNESS < cloud_trans_max - 10.0)
	{
		cloud_skin_direction = -cloud_skin_direction;
	}
	*/
	set_pev(idx_CloudsAir, pev_renderamt, floatclamp((CLOUDNESS-30.0), cloud_trans_min, cloud_trans_max)); // 120 охуенный предел для CloudsAir Легкая облачность 120
	set_pev(idx_CloudsRain, pev_renderamt, floatclamp(CLOUDNESS, cloud_trans_min, cloud_trans_max)); // 120 охуенный предел для CloudsAir Легкая облачность 120


	// server_print(" Br %.0f ^t ,Cld %.0f ^t MOON %.0f", BRIGHTNESS, CLOUDNESS, SUNLESS_MOONLESS);
}


public CloudsRain_Create()
{
	new iEntity = create_entity("info_target");

	if(!pev_valid(iEntity))
		return;

	set_pev(iEntity, pev_classname, CLASSNAME_SKY);
	set_pev(iEntity, pev_movetype, MOVETYPE_NOCLIP);
	set_pev(iEntity, pev_solid, SOLID_NOT);
	set_pev(iEntity, pev_sequence, 0);
	set_pev(iEntity, pev_framerate, 0.0);
	// set_pev(iEntity, pev_angles, {0.0, 0.0, 0.0}); 
	engfunc(EngFunc_SetModel, iEntity, sz_Sky_Model[3]);
	dod_set_size(iEntity);

	// cloud_avelocty[1] = -2.3 * base_avelocty[1] + generate_random_velocity_compact();
	// cloud_avelocty[2] = 2.4 * base_avelocty[2] + generate_random_velocity_compact();
	// set_pev(iEntity, pev_avelocity, cloud_avelocty); // задаёт вращение 
	

	set_pev(iEntity, pev_rendermode, kRenderTransTexture); // Render alpha
	set_pev(iEntity, pev_renderamt, 0.0); // 100 наверно крайнее значение
	set_pev(iEntity, pev_renderfx, kRenderFxNone); // kRenderFxFadeFast 2 

	cloud_skin_direction = 1;

	idx_CloudsRain = iEntity;
	
	// set_task( g_SkyDayTime / 600.0 , "CloudsAir_Think", _, _, _, "b");

}


public SunMoon_Create()
{	
	new iEntity = create_entity("info_target");
	
	if(!pev_valid(iEntity))
		return;

	set_pev(iEntity, pev_classname, CLASSNAME_SKY);
	set_pev(iEntity, pev_movetype, MOVETYPE_NOCLIP);
	set_pev(iEntity, pev_solid, SOLID_NOT);
	set_pev(iEntity, pev_sequence, 0);

	// 20630313 mm 
	// 24062255 mm
	
	set_pev(idx_SunMoon, pev_angles, {0.0, 0.0, 0.0}); 
	engfunc(EngFunc_SetModel, iEntity, sz_Sky_Model[5]);
	dod_set_size(iEntity);
	//sunmoon_avelocty[1] = 30.3 // * base_avelocty[1] + generate_random_velocity_compact();
	//sunmoon_avelocty[2] = -40.3 // * base_avelocty[2] + generate_random_velocity_compact();
	// set_pev(iEntity, pev_avelocity, sunmoon_avelocty); // задаёт вращение 
	
	// engfunc(EngFunc_SetSize, iEntity, Float:{-50000.0, -50000.0, -50000.0}, Float:{50000.0, 50000.0, 50000.0});

	idx_SunMoon = iEntity;
	set_pev(idx_SunMoon, pev_rendermode, kRenderTransAdd);
	set_pev(idx_SunMoon, pev_renderamt, 255.0);

	// set_task( g_SkyDayTime / 600.0 , "SunMoon_Think", _, _, _, "b");
}

public SunMoon_Think()
{	
	//  <>>> CloudsAir_Think()
	SUNLESS_MOONLESS = floatclamp(255.0 - CLOUDNESS * 1.0, 0.0, 255.0);
	set_pev(idx_SunMoon, pev_renderamt, SUNLESS_MOONLESS);
}




public ThunderSphere_Create()
{	
	new iEntity = create_entity("info_target");
	
	if(!pev_valid(iEntity))
		return;
	
	set_pev(iEntity, pev_classname, CLASSNAME_SKY);
	set_pev(iEntity, pev_movetype, MOVETYPE_NOCLIP);
	set_pev(iEntity, pev_solid, SOLID_NOT);
	set_pev(iEntity, pev_sequence, 0);
	set_pev(iEntity, pev_angles, {0.0, 0.0, 0.0});

	// base_avelocty[0] = 0.5; // * 100.0;  // X на меня
	// base_avelocty[1] = 1.0; // * 100.0;  // Z
	// base_avelocty[2] = 0.5; // * 100.0;  // Y   <====

	set_pev(iEntity, pev_rendermode, kRenderTransAdd); // Render alpha
	set_pev(iEntity, pev_renderamt, 0.0); // 100 наверно крайнее значение
	set_pev(iEntity, pev_renderfx, kRenderFxNone); // kRenderFxFadeFast 2 
	set_pev(iEntity, pev_rendercolor, {0.0, 0.0, 0.0} );

	

	set_pev(iEntity, pev_avelocity, base_avelocty); // задаёт вращение 
	engfunc(EngFunc_SetModel, iEntity, sz_Sky_Model[4]);
	dod_set_size(iEntity);
	// engfunc(EngFunc_SetSize, iEntity, Float:{-50000.0, -50000.0, -50000.0}, Float:{50000.0, 50000.0, 50000.0});
	idx_ThunderSphere = iEntity;
	// set_task(g_SkyDayTime / 600.0, "Base_Think", _, _, _, "b");
}

public ThunderSphere_Think()
{   
	

	THUNDERLIGHT -= 5.0;
	THUNDERLIGHT = floatclamp(THUNDERLIGHT, 0.0, 255.0);
	set_pev(idx_ThunderSphere, pev_renderamt, THUNDERLIGHT);


	if (THUNDERLIGHT <1.0)
	{
		remove_task(TASK_THUNDER_THINK);
		set_task(random_float(4.0, 5.0), "Sky_Thunder");
	}
	
	static Float:Th_Angles[3];
	pev(idx_ThunderSphere, pev_angles, Th_Angles);

	Th_Angles[0] += random_float(-90.0, 90.0);
	Th_Angles[1] += random_float(-90.0, 90.0); 
	Th_Angles[2] += random_float(-90.0, 90.0); 
	set_pev(idx_ThunderSphere, pev_angles, Th_Angles); 
	
	
}

public ThunderSphere_Mini()
{
	if(CLOUDNESS > 150.0)
	{
		set_pev(idx_ThunderSphere, pev_skin, 1);
		THUNDERLIGHT = random_float(10.0, 10.0);
		set_pev(idx_ThunderSphere, pev_renderamt, THUNDERLIGHT);
		set_task(0.1 , "ThunderSphere_Think", TASK_THUNDER_THINK, _, _, "b");
	}
	// random_float(2.0, 3.0)
	// set_task(random_float(4.0, 5.0), "ThunderSphere_Mini");
}


public Sky_Thunder() 
{	
	/*
	попробовать реализовать смену pev_skin на clouds Air и Clouds Rain:D ) ) тоже классно 
	А ещё  и на Base Color )  И на MOOON! ))) 
	*/
	if(CLOUDNESS < 200.0) 
	{	
		remove_task(TASK_THUNDER_RUN);
		set_task(5.0, "Sky_Thunder", TASK_THUNDER_RUN, "", 0, "b");
		// set_task(random_float(15.0, 50.0), "Sky_Thunder", TASK_THUNDER_RUN, "", 0, "b");
		return;
	}
	static thunder_mode;
	thunder_mode = random_num(0,1)
	switch (thunder_mode)
	{	
		case 0:
		{	
			THUNDERLIGHT = random_float(50.0, 255.0);
			set_lights("z");
			set_task(0.1, "Sky_Thunder_Decay", TASK_THUNDER_DECAY, "", 0);
			
			new Float:origin[3], Float:end[3]
			origin[0] += random_num(-2048, 2048)
			origin[1] += random_num(-2048, 2048)
			origin[2] += 2048.0

			end[0] = origin[0] 
			end[1] = origin[1]
			end[2] = -2048.0

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
			
		}
		default:
		{
			THUNDERLIGHT = random_float(0.0, 50.0);
		}
	}
	// Thunder skin
	remove_task(TASK_THUNDER_RUN);
	set_pev(idx_ThunderSphere, pev_skin, thunder_mode);
	
	set_task(0.1 , "ThunderSphere_Think", TASK_THUNDER_THINK, _, _, "b");
	set_pev(idx_ThunderSphere, pev_renderamt, THUNDERLIGHT);
}

public Sky_Thunder_Decay()
{
	
	set_lights(szSKY_LIGHT_CURRENT);
	THUNDERLIGHT = 20.0;
	set_pev(idx_ThunderSphere, pev_skin, 1);
	// emit_sound(0, CHAN_AUTO, S_Thunder[random_num(0, sizeof(S_Thunder)-1)], 1.0, ATTN_NORM, 0, PITCH_NORM);
	for(new id = 1 ; id < get_maxplayers() + 1 ; id++)
	{ 	
		if(is_user_connected(id))
		{
			client_cmd( id,"spk %s", S_Thunder[random_num(0, sizeof(S_Thunder)-1)]);
		}	
	}	
}


public Set_Sphere_aVel()
{	
	// // Base Color
	base_avelocty[0] = 2.0 * SunMoon_avel_vecmul;  // X на меня
	base_avelocty[1] = 1.0 * SunMoon_avel_vecmul;  // Z
	// base_avelocty[2] = 2.0 * SunMoon_avel_vecmul;  // Y   <====
	set_pev(idx_Base, pev_angles, {0.0, 0.0, 0.0} );
	set_pev(idx_Base, pev_avelocity, base_avelocty);

	// Stars 
	set_pev(idx_Stars, pev_avelocity, {-0.075, -0.075, -0.075});

	// Clouds AIR
	//cloud_avelocty[1] = 1.2 * base_avelocty[1] + generate_random_velocity_compact(); 
	// cloud_avelocty[2] = 1.2 * base_avelocty[2] + generate_random_velocity_compact();
	cloud_avelocty[0] = generate_random_velocity_compact();
	cloud_avelocty[1] = floatclamp( 1.2 * base_avelocty[1] * generate_random_velocity_compact() , -1.5 , 1.5);
	cloud_avelocty[2] = floatclamp( 0.6 * base_avelocty[1] * generate_random_velocity_compact() , -1.5 , 1.5);
	set_pev(idx_CloudsAir, pev_avelocity, cloud_avelocty); // задаёт вращение 

	// CLouds Rain
	cloud_avelocty[0] = generate_random_velocity_compact();
	cloud_avelocty[1] = 1.1 * cloud_avelocty[1] * generate_random_velocity_compact();
	cloud_avelocty[2] = 1.1 * cloud_avelocty[2] * generate_random_velocity_compact();
	set_pev(idx_CloudsRain, pev_avelocity, cloud_avelocty); // задаёт вращение 
	

	// Sun Moon
	sunmoon_avelocty[0] = -1.0 * SunMoon_avel_vecmul;
	// sunmoon_avelocty[1] = -1.0 * SunMoon_avel_vecmul;
	// sun_obj_avel[2] = 0.5 * SunMoon_avel_vecmul; // тарелка крутится как руль
	set_pev(idx_SunMoon, pev_angles, {180.0, 0.0, 0.0}); 
	set_pev(idx_SunMoon, pev_avelocity, sunmoon_avelocty);

	// Thunder 
	// set_pev(idx_Base, pev_angles, {0.0, -90.0, 0.0} );
	set_pev(idx_ThunderSphere, pev_avelocity, base_avelocty);
}	


// Компактный вариант одной строкой
stock Float:generate_random_velocity_compact()
{
    return (random_num(0, 1) ? random_float(0.3, 0.5) : random_float(-0.5, -0.3));
}

public onFM_RemoveEntity(entity)
{
    if(pev_valid(entity) && (entity == idx_Base || entity == idx_CloudsAir))
    {
        return FMRES_SUPERCEDE;
    }
    return FMRES_IGNORED;
}

public Update_Lighting_By_Angle_clean()
{
	// Чистая форма ! 
    new Float:Sun_Angles[3];
    pev(idx_Base, pev_angles, Sun_Angles);

    // Берём угол по оси Y
    new Float:angle = Sun_Angles[1];

    // Нормализуем угол в 0..360
    while (angle < 0.0) angle += 360.0;
    while (angle >= 360.0) angle -= 360.0;

    // Создаем синусоидальную кривую освещения с одним пиком за сутки
    new Float:rad_angle = angle * (3.14159 / 180.0); // в радианы
    new Float:light_factor = (floatsin(rad_angle + 1.5708) + 1.0) / 2.0; // смещаем на +90° вместо -90°

    // Преобразуем в диапазон освещения
    new light_steps = SKY_LIGHT_MAX - SKY_DARK_MIN;
    new step_index = floatround(light_factor * light_steps);
    step_index = clamp(step_index, 0, light_steps);

    new current_light_char = SKY_DARK_MIN + step_index;

    // Устанавливаем освещение
    formatex(szSKY_LIGHT_CURRENT, charsmax(szSKY_LIGHT_CURRENT), "%c", current_light_char);
    set_lights(szSKY_LIGHT_CURRENT);

    // Синхронизация с клиентами
    for (new id = 1; id <= get_maxplayers(); id++) {
        if (is_user_connected(id)) {
            engfunc(EngFunc_LightStyle, 0, szSKY_LIGHT_CURRENT);
        }
    }
    
    // Отладочный вывод
    static old_light = -1;
    if (old_light != current_light_char) {
        // server_print("[SKY] Освещение: %c (угол: %.1f°)", current_light_char, angle);
        old_light = current_light_char;
    }
}

public Update_Lighting_By_Angle()
{	
	// Good Float
    new Float:Sun_Angles[3];
    pev(idx_Base, pev_angles, Sun_Angles);

    // Берём угол по оси Y
    new Float:angle = Sun_Angles[1];

    // Нормализуем угол в 0..360
    while (angle < 0.0) angle += 360.0;
    while (angle >= 360.0) angle -= 360.0;

    // Создаем синусоидальную кривую освещения
    new Float:rad_angle = angle * (3.14159 / 180.0);
    new Float:light_factor = (floatsin(rad_angle + 1.5708) + 1.0) / 2.0;

    // 🔧 СМЕШИВАЕМ С ОБЛАЧНОСТЬЮ
    // Коэффициент влияния облачности (0.0 - 1.0)
    new Float:cloud_influence = CLOUDNESS / 255.0;
    
    // Смешиваем солнечное освещение с облачным затемнением
    new Float:final_light_factor = light_factor * (1.0 - cloud_influence * 0.7); // облачность уменьшает свет на 70% максимум

    // Преобразуем в диапазон освещения
    new light_steps = SKY_LIGHT_MAX - SKY_DARK_MIN;
    new step_index = floatround(final_light_factor * light_steps);
    step_index = clamp(step_index, 0, light_steps);

    new current_light_char = SKY_DARK_MIN + step_index;

    // Устанавливаем освещение
    formatex(szSKY_LIGHT_CURRENT, charsmax(szSKY_LIGHT_CURRENT), "%c", current_light_char);
    set_lights(szSKY_LIGHT_CURRENT);

    // Синхронизация с клиентами
    for (new id = 1; id <= get_maxplayers(); id++) {
        if (is_user_connected(id)) {
            engfunc(EngFunc_LightStyle, 0, szSKY_LIGHT_CURRENT);
        }
    }
    
    // Отладочный вывод
    static old_light = -1;
    if (old_light != current_light_char) 
	{
        // server_print("[SKY] Освещение: %c (угол: %.1f° | Облачность: %.0f| Влияние: %.1f%%)", 
			// current_light_char, angle, CLOUDNESS, cloud_influence * 100.0);
        old_light = current_light_char;
    }
}

public Update_Lighting_By_Angle_cloud1()
{
    new Float:Sun_Angles[3];
    pev(idx_Base, pev_angles, Sun_Angles);

    // Берём угол по оси Y
    new Float:angle = Sun_Angles[1];

    // Нормализуем угол в 0..360
    while (angle < 0.0) angle += 360.0;
    while (angle >= 360.0) angle -= 360.0;

    // Создаем синусоидальную кривую освещения
    new Float:rad_angle = angle * (3.14159 / 180.0);
    new Float:light_factor = (floatsin(rad_angle + 1.5708) + 1.0) / 2.0;

    // Преобразуем в диапазон освещения
    new light_steps = SKY_LIGHT_MAX - SKY_DARK_MIN;
    new step_index = floatround(light_factor * light_steps);
    step_index = clamp(step_index, 0, light_steps);

    new current_light_char = SKY_DARK_MIN + step_index;

    // 🔧 ДОБАВЛЯЕМ ВЛИЯНИЕ ОБЛАЧНОСТИ
    // Чем больше CLOUDNESS, тем ближе к минимальному освещению
    new cloud_effect = floatround((CLOUDNESS / 255.0) * light_steps);
    current_light_char -= cloud_effect;
    
    // Защита от выхода за границы
    current_light_char = clamp(current_light_char, SKY_DARK_MIN, SKY_LIGHT_MAX);

    // Устанавливаем освещение
    formatex(szSKY_LIGHT_CURRENT, charsmax(szSKY_LIGHT_CURRENT), "%c", current_light_char);
    set_lights(szSKY_LIGHT_CURRENT);

    // Синхронизация с клиентами
    for (new id = 1; id <= get_maxplayers(); id++) {
        if (is_user_connected(id)) {
            engfunc(EngFunc_LightStyle, 0, szSKY_LIGHT_CURRENT);
        }
    }
    
    // Отладочный вывод
    static old_light = -1;
    if (old_light != current_light_char) {
        // server_print("[SKY] Освещение: %c (угол: %.1f° | Облачность: %.0f)", current_light_char, angle, CLOUDNESS);
        old_light = current_light_char;
    }
}

stock dod_set_size(idx_ent)
{
	engfunc(EngFunc_SetOrigin, idx_ent,	{0.0, 0.0, 0.0});
	engfunc(EngFunc_SetSize, idx_ent, Float:{-4096.0, -4096.0, -4096.0}, Float:{4096.0, 4096.0, 4096.0});

	/*
	new Float: Mins[3], Float: Maxs[3];
	pev( idx_ent, pev_size, Mins);
	server_print(" THE SIZE: %f %f %f", Mins[0], Mins[1], Mins[2]);
	*/
}