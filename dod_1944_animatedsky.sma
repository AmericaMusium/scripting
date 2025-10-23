#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>
/*
на доннере лучше добавить смену скина облачного неба, с диффузией и сменой оттенков, всё это засинхронить со лайтспесами оставив там дождь навсегда


вариант 2: делать в одном плагине модель с прозрачной текстурой, но анимаецией, можно попробовать прямо сейчас

*/
#define PLUGIN		"Animated Sky"
#define VERSION		"2.1"
#define AUTHOR		"Sneaky.amxx | GlobalModders.net | MayroN | America//ClassicFresh"

#define ANIMATED_SKY	"models/animated_sky/1944w_clear.mdl"
#define CLASSNAME_SKY	"animated_sky"
#define THUNDER		"sprites/laserbeam.spr"

#define TASK_LIGHT	789697
#define TASK_SKIN	789698

new g_SkyEnt;
new g_iModel;
new g_iSkin;
new is_skin_need_change;
new is_enable_time;
new is_need_sound = 0;

new	SKY_DARK_MIN = 'b'; // По умолчанию
new	SKY_LIGHT_MAX = 'z'; // По умолчанию


new g_stepsskin; // Количество скинов (0, если скинов нет)
new g_stepslight; // Количество шагов освещения
new Float:g_timestep; // Общее время цикла (10 минут)
new Float:skin_step_time; // Время для одного шага скина
new Float:light_step_time; //  = g_timestep / float(g_stepslight * 2); // Время для одного шага освещения
new g_current_skin_step; // Текущий шаг скина
new g_current_light_step; // Текущий шаг освещения
new direction_skin = 1; // Направление смены скина (1 — вперёд, -1 — назад)
new direction_light = 1; // Направление смены освещения (1 — вперёд, -1 — назад)

enum
{	
	enum_sky_type_blue = 0,
	enum_sky_type_rain,
	enum_sky_type_storm,
	enum_sky_type_snow
}

enum
{
	_default = 0,
	_clearsky,
	_rainy
}

new const g_Model[][] = 
{
	"models/animated_sky/def_animated_sky_new.mdl",
	"models/animated_sky/1944w_clear.mdl",
	"models/animated_sky/1944w_rain.mdl",
	"models/animated_sky/1944_transclouds.mdl"
}

new 
	mapname[64],
	sky_type,
	szSKY_LIGHT_CURRENT[2],
	szSKY_LIGHT_START[2],
	szSKY_LIGHT_MAX[2],
	szSKY_DARK_MIN[2],
	Float:sky_thunder_time,
	Float:sky_speed_animated;

new const weather_sound[][] = 
{
	"weather_sound/rain_sound.wav",
	"weather_sound/snow_sound.wav"
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
	
	Load_Cfg();
	Sky_Create();
}

public Load_Cfg()
{
	set_cvar_num("sv_zmax", 50000);	
	set_cvar_num("sv_skycolor_r", 0);
	set_cvar_num("sv_skycolor_g", 0);
	set_cvar_num("sv_skycolor_b", 0);
}

public plugin_precache()
{
	get_mapname(mapname, charsmax(mapname));
	new cfgdir[128],filepath[256];
	get_configsdir(cfgdir, charsmax(cfgdir));
	format(filepath, charsmax(filepath), "%s/animated_sky_settings.ini", cfgdir);
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
				if(sky_type == -1)
				{
					pause("ad");
					return;
				}
			}
			else if(equal(key, "SKY_MODEL"))
			{	
				g_iModel = str_to_num(value);
			}
			else if(equal(key, "SKY_ENABLE_TIME"))
			{	
				is_enable_time = str_to_num(value);
			}
			else if (equal(key, "SKY_LIGHT_START"))
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
			else if(equal(key, "SKY_SKIN_START"))
			{	
				g_iSkin = str_to_num(value);
			}
			else if(equal(key, "SKY_ENABLE_SKIN_CHANGING"))
			{	
				is_skin_need_change = str_to_num(value);
			}
			else if (equal(key, "SKY_DAYTIME"))
			{	
				g_timestep = str_to_float(value);
			}
			else if (equal(key, "SKY_SKIN_MAX"))
			{
				g_stepsskin = str_to_num(value);
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
				
			else if (equal(key, "SKY_SPEED_ANIMATED"))
			{
				sky_speed_animated = str_to_float(value);
				is_right_map = 0;
			}



			
		}
	}
	if(file) fclose(file);
	if(!not_find)
	{
		pause("ad");
		return;
	}

	/*
	if(sky_type == enum_sky_type_rain)
	{
		create_entity("env_rain");
		set_lights(szSKY_LIGHT_START);
		g_thunder = precache_model(THUNDER);
		if(sky_thunder_time>0.0)
			set_task(sky_thunder_time, "Sky_Thunder", _, _, _, "b");
	}

	if(sky_type == enum_sky_type_storm)
	{
		create_entity("env_rain");
		set_lights(szSKY_LIGHT_START);
		g_thunder = precache_model(THUNDER);
		if(sky_thunder_time>0.0)
			set_task(sky_thunder_time, "Sky_Thunder", _, _, _, "b");
	}

	if(sky_type == enum_sky_type_snow)
	{
		create_entity("env_snow");
		set_lights(szSKY_LIGHT_START);
	}
	*/
	if(is_need_sound)
	{
		for(new i = 0; i < sizeof S_Thunder; i++)
			precache_sound(S_Thunder[i])
	}

	new what = engfunc(EngFunc_PrecacheModel, g_Model[g_iModel]);
	server_print(" PRECHACHEDDDDDDDDDDDDDDDD = %d %s", what,  g_Model[g_iModel]);

}

public client_connect(id)
{
	client_cmd(id, "cl_weather 1");
}

public client_putinserver(id)
{	
	if(!is_need_sound) return PLUGIN_CONTINUE;

	/*
	if(sky_type == enum_sky_type_rain)
	{
		set_task(0.1, "rain_sound", id + 3175);
	}

	if(sky_type == enum_sky_type_storm)
	{
		set_task(0.1, "rain_sound", id + 3175);
	}	

	if(sky_type == enum_sky_type_snow)
	{
		set_task(0.1, "snow_sound", id + 6317);
	}
	*/
	return PLUGIN_CONTINUE;
}

public Sky_Create()
{
	new iEntity = create_entity("info_target");
	
	if(!pev_valid(iEntity))
		return;

	set_pev(iEntity, pev_classname, CLASSNAME_SKY);
	set_pev(iEntity, pev_solid, SOLID_NOT);
	set_pev(iEntity, pev_sequence, 0);
	set_pev(iEntity, pev_framerate, sky_speed_animated); 

	/* ++ при выборе типа неба , будем прекештить новую модель.
	if(sky_type == enum_sky_type_blue)
		set_pev(iEntity, pev_skin, random_num(0, 6));

	if(sky_type == enum_sky_type_rain)
		set_pev(iEntity, pev_skin, random_num(7, 8));

	if(sky_type == enum_sky_type_storm)
		set_pev(iEntity, pev_skin, random_num(9, 10));

	if(sky_type == enum_sky_type_snow)
		set_pev(iEntity, pev_skin, random_num(11, 12));
	*/

	engfunc(EngFunc_SetModel, iEntity, g_Model[g_iModel]);
	engfunc(EngFunc_SetSize, iEntity, Float:{-50000.0, -50000.0, -50000.0}, Float:{50000.0, 50000.0, 50000.0});
	g_SkyEnt = iEntity;


	// 
	Sky_Update();
}


public Sky_Update()
{	
	format(szSKY_LIGHT_CURRENT,1, szSKY_LIGHT_START);
	if (!is_enable_time)
	{
		// Если время не активно, просто устанавливаем скин и освещение
		set_pev(g_SkyEnt, pev_skin, g_iSkin);
		set_lights(szSKY_LIGHT_CURRENT);
		return;
	}
	else
	{	
		// needfix : надо провести рассчёты что бы было синхноризирована буква старта и скин старта, а потом
		// в этом месте тоже исправить код и в конфиге и в этой функции тоже 
		set_pev(g_SkyEnt, pev_skin, g_iSkin);
		set_lights(szSKY_LIGHT_CURRENT);
		
		Start_Cycles();
	}
}

public Start_Cycles()
{
	// Запускаем смену освещения
	if (is_enable_time)
	{
		g_stepslight = SKY_LIGHT_MAX - SKY_DARK_MIN + 1;
		light_step_time = g_timestep / float(g_stepslight * 2); // Время для одного шага освещения
		set_task(light_step_time, "Update_Lighting", TASK_LIGHT,_, _, "b");

		if(is_skin_need_change && g_stepsskin > 0)
		{	
			skin_step_time = g_timestep / float(g_stepsskin * 2);
			set_task(skin_step_time, "Update_Skin", TASK_SKIN, _, _, "b");
		}
		else 
		{
			set_pev(g_SkyEnt, pev_skin, g_iSkin);
		}
		set_task(g_timestep, "On_New_Day");
	}
	
	server_print("Количество шагов освещения: %d", g_stepslight);
	server_print("Время для одного шага скина: %f", skin_step_time);
	server_print("Время для одного шага освещения: %f", light_step_time);

}

public On_New_Day()
{	
	remove_task(TASK_LIGHT);
	remove_task(TASK_SKIN);
	// Сбрасываем текущие шаги скинов и освещения
	g_current_skin_step = 0;
	g_current_light_step = 0;

	// Запускаем новый цикл
	Start_Cycles();
	// server_print("Начался новый день! Скины и освещение синхронизированы.");
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
	set_lights(szSKY_LIGHT_CURRENT);
}

public Update_Skin()
{
    // Увеличиваем или уменьшаем текущий шаг в зависимости от направления
    g_current_skin_step += direction_skin;

    // Если достигли максимума, меняем направление на уменьшение
    if (g_current_skin_step >= g_stepsskin)
    {
        g_current_skin_step = g_stepsskin - 1;
        direction_skin = -1;
    }
    // Если достигли минимума, меняем направление на увеличение
    else if (g_current_skin_step < 0)
	{	

		g_current_skin_step = 0;
		direction_skin = 1;
	}

    // Устанавливаем скин // fix 
    set_pev(g_SkyEnt, pev_skin,  g_stepsskin-g_current_skin_step);
}


public Sky_Thunder() 
{

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


public rain_sound(iTaskID)
{
	new id = iTaskID - 3175

	client_cmd(id, "speak %s", weather_sound[0]);
	set_task(44.9, "rain_sound", id + 3175)
}

public snow_sound(iTaskID)
{
	new id = iTaskID - 6317

	client_cmd(id, "speak %s", weather_sound[1]);
	set_task(44.9, "snow_sound", id + 6317)
}

public client_disconnected(id)
{
	if(task_exists(id + 3175))
		remove_task(id + 3175);
	if(task_exists(id + 6317))
		remove_task(id + 6317);
}
