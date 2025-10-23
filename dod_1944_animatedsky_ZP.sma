#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>

#define PLUGIN		"Animated Sky"
#define VERSION		"ZP"
#define AUTHOR		"Sneaky.amxx | GlobalModders.net | MayroN | America//ClassicFresh"


#define CLASSNAME_SKY	"animated_sky"
#define THUNDER		"sprites/laserbeam.spr"

#define TASK_LIGHT	789697

new idx_Base;
new idx_ThunderLayer;
new idx_ColorLayer;
new idx_Moon;
new is_enable_time;
new is_need_sound = 0;

new	SKY_DARK_MIN = 'b'; // По умолчанию
new	SKY_LIGHT_MAX = 'z'; // По умолчанию

new Float:g_SunRotationSpeed;
new Float:sun_rotation_speed;
new Float:g_SkyDayTime;

new g_stepslight; // Количество шагов освещения
new Float:light_step_time; //  = g_timestep / float(g_stepslight * 2); // Время для одного шага освещения
new g_current_light_step; // Текущий шаг освещения
new direction_light = 1; // Направление смены освещения (1 — вперёд, -1 — назад)


new const sz_Base_Model[][] = 
{	
	"models/animated_sky/1944_transbase.mdl"
}

new const sz_SunMoon_Model[][] = 
{
	"models/animated_sky/1944_transsun.mdl",
	"models/animated_sky/1944_moon.mdl"
}

new const sz_Cloud_Model[][] = 
{
	"models/animated_sky/ligthing_sphere.mdl"
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
    Float:ThunderLayer_light,
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
	/*
    Moon_Create();
    */
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
	format(filepath, charsmax(filepath), "%s/animated_sky_settingsZP.ini", cfgdir);
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
				idx_ThunderLayer = str_to_num(value);
				if(idx_ThunderLayer >= 0)
				{
					engfunc(EngFunc_PrecacheModel, sz_Cloud_Model[idx_ThunderLayer]);
					// server_print("[***CLOUDS] model precached: %s", sz_Cloud_Model[idx_ThunderLayer]);
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
			else if (equal(key, "SUN_ROTATION_SPEED"))
			{
    			g_SunRotationSpeed = str_to_float(value);
			}

			else if(equal(key, "SKY_ENABLE_SOUND"))
			{	
				is_need_sound = str_to_num(value);
			}
			else if (equal(key, "SKY_THUNDER_TIME"))
			{
			g_thunder = precache_model(THUNDER);
            sky_thunder_time = str_to_float(value);
        

            }
            set_task(7.0, "Sky_Thunder", _, _, _, "b");
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
	}
}

public Thunder_Echo()
{
    BRIGHTNESS = random_float(5.0, 30.0);
    remove_task(4546);
}

public Start_Cycles()
{
    if (is_enable_time)
    {
        // Автоматический расчет шагов освещения
        g_stepslight = SKY_LIGHT_MAX - SKY_DARK_MIN + 1;
        light_step_time = g_SkyDayTime / float(g_stepslight * 2);
        
        // Автоматический расчет скорости вращения солнца
        sun_rotation_speed = 360.0 / g_SkyDayTime;
        
        // Применяем множитель если указан
        if(g_SunRotationSpeed > 0.0) {
            sun_rotation_speed *= g_SunRotationSpeed;
        }
        
        // Устанавливаем скорость вращения солнца
        Sun_Speed(sun_rotation_speed);
        
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


public Sky_Thunder() 
{
	// if(CLOUDNESS < 40.0 || BRIGHTNESS > 60.0) return;
    /*
    if(random_num(0,10) > 9)
    {
        set_task(random_float(0.2, 0.4), "Sky_Thunder");
    }
    */
    set_task(random_float(0.2, 10.0), "Thunder_Echo", 4546);

	set_lights("z");
    /*
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
    */

    set_task(0.1, "Sky_Thunder_Decay", 4545);

    set_pev(idx_ThunderLayer, pev_rendermode, kRenderTransAdd); // Render alpha
    set_pev(idx_ThunderLayer, pev_renderamt, 255.0); // 100 наверно крайнее значение
    set_pev(idx_ThunderLayer, pev_renderfx, kRenderFxNone); // kRenderFxFadeFast 2 

    ThunderLayer_light = 255.0;
    BRIGHTNESS = 60.0;
    set_task(0.1 , "ThunderLayer_Think", 7545, _, _, "b");
}

public Sky_Thunder_Decay()
{
 
	set_lights(szSKY_LIGHT_CURRENT);

    remove_task(4545);

	// emit_sound(0, CHAN_AUTO, S_Thunder[random_num(0, sizeof(S_Thunder)-1)], 1.0, ATTN_NORM, 0, PITCH_NORM);
	for(new id = 1 ; id < get_maxplayers() + 1 ; id++)
	{ 	
		// if(is_user_connected(id) && is_user_alive(id ) && !is_user_bot(id))
        if(is_user_connected(id) && !is_user_bot(id))
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
	base_avelocty[1] = 4.5 * generate_random_velocity_compact();
	base_avelocty[2] = 3.4 * generate_random_velocity_compact();
	set_pev(iEntity, pev_avelocity, base_avelocty); // задаёт вращение 
	engfunc(EngFunc_SetModel, iEntity, sz_Base_Model[idx_Base]);

	
	engfunc(EngFunc_SetSize, iEntity, Float:{-50000.0, -50000.0, -50000.0}, Float:{50000.0, 50000.0, 50000.0});
	idx_Base = iEntity;
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
	
	engfunc(EngFunc_SetSize, iEntity, Float:{-50000.0, -50000.0, -50000.0}, Float:{50000.0, 50000.0, 50000.0});

	/* 
	генерация скорости вращения переехала
	new Float:sun_avel[3];
	// sun_avel[0] = 20.0 // random_float(-50.0, 50.0);
	sun_avel[1] = generate_random_velocity_compact() // градусов в секунду
	sun_avel[2] = generate_random_velocity_compact()	// градусов в секунду
	// set_pev(iEntity, pev_avelocity, sun_avel); // задаёт вращение 
	*/

    set_pev(iEntity, pev_rendermode, kRenderTransAdd); // Render alpha
    set_pev(idx_ColorLayer, pev_renderamt, 0.0);

    idx_ColorLayer = iEntity;

	// new Float: TaskFl = g_SkyDayTime / 600.0
	set_task(0.1, "ColorLayer_Think", _, _, _, "b");
}



public Moon_Create()
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
	engfunc(EngFunc_SetModel, iEntity, sz_SunMoon_Model[1]);
	
	engfunc(EngFunc_SetSize, iEntity, Float:{-50000.0, -50000.0, -50000.0}, Float:{50000.0, 50000.0, 50000.0});


	new Float:sun_obj_avel[3];
	// sun_avel[0] = 20.0 // random_float(-50.0, 50.0);
	// sun_obj_avel[1] = 21.4 * generate_random_velocity_compact() // градусов в секунду
	sun_obj_avel[1] = 21.2 * generate_random_velocity_compact()	// градусов в секунду
	sun_obj_avel[0] = 2.0 * sun_obj_avel[1];
	set_pev(iEntity, pev_avelocity, sun_obj_avel); // задаёт вращение 
	set_pev(iEntity, pev_rendermode, kRenderTransAdd); // Render alpha

	idx_Moon = iEntity;
	set_task( g_SkyDayTime / 600.0 , "Moon_Think", _, _, _, "b");
}

public Moon_Think()
{
	static Float: MoonBrightness;
	MoonBrightness = BRIGHTNESS + 50.0;
	MoonBrightness = floatclamp(MoonBrightness, 30.0, 255.0);
	set_pev(idx_Moon, pev_renderamt, MoonBrightness);
}


public Sun_Speed(Float:speed)
{
	if(!pev_valid(idx_ColorLayer)) return;

	new Float:sun_avel[3];
	sun_avel[0] = 2.0 * speed;
	sun_avel[1] = 1.0 * speed; //  
	sun_avel[2] = 2.0 * speed; //

	set_pev(idx_ColorLayer, pev_avelocity, sun_avel);

}


public ColorLayer_Think()
{	
    BRIGHTNESS -= 10.0;

    BRIGHTNESS = floatclamp(BRIGHTNESS, 0.0, 255.0);
    set_pev(idx_ColorLayer, pev_renderamt, BRIGHTNESS);

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
	engfunc(EngFunc_SetModel, iEntity, sz_Cloud_Model[idx_ThunderLayer]);
	engfunc(EngFunc_SetSize, iEntity, Float:{-50000.0, -50000.0, -50000.0}, Float:{50000.0, 50000.0, 50000.0});

	cloud_avelocty[1] = 0.0 * base_avelocty[1] + generate_random_velocity_compact();
	cloud_avelocty[2] = 0.0 * base_avelocty[2] + generate_random_velocity_compact();
	set_pev(iEntity, pev_avelocity, cloud_avelocty); // задаёт вращение 

	set_pev(iEntity, pev_rendermode, kRenderTransAdd); // Render alpha
	set_pev(iEntity, pev_renderamt, 0.0); // 100 наверно крайнее значение
	set_pev(iEntity, pev_renderfx, kRenderFxNone); // kRenderFxFadeFast 2 

	cloud_skin_direction = 1;

	idx_ThunderLayer = iEntity;
	


	// // server_print("[***CLOUDS] CLOUDS sky created %d : VELOCITY %f %f", idx_Base , cloud_avelocty[1], cloud_avelocty[2]);
}


public ThunderLayer_Think()
{   

    ThunderLayer_light -= 90.0;

    server_print(" POWER %f", ThunderLayer_light);
    ThunderLayer_light = floatclamp(ThunderLayer_light, 0.0, 255.0);
    
    if (ThunderLayer_light <1.0)
    {
        remove_task(7545);
    }
    static Float:Th_Angles[3];

    Th_Angles[0] = random_float(-360.0, 360.0);
    Th_Angles[1] = random_float(-360.0, 360.0); 
    Th_Angles[2] = random_float(-360.0, 360.0); 
    set_pev(idx_ThunderLayer, pev_angles, Th_Angles); 
    set_pev(idx_ThunderLayer, pev_renderamt, ThunderLayer_light);

}


// Компактный вариант одной строкой
stock Float:generate_random_velocity_compact()
{
    return (random_num(0, 1) ? random_float(0.3, 0.5) : random_float(-0.5, -0.3));
}

public onFM_RemoveEntity(entity)
{
    if(pev_valid(entity) && (entity == idx_Base || entity == idx_ThunderLayer))
    {
        // server_print("Attempt to remove sky entity! Blocked.");
        return FMRES_SUPERCEDE;
    }
    return FMRES_IGNORED;
}
