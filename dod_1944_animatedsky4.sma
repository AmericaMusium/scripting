#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>


#define PLUGIN		"Animated Sky"
#define VERSION		"4.0"
#define AUTHOR		"Sneaky.amxx | GlobalModders.net | MayroN | America//ClassicFresh"


#define CLASSNAME_SKY	"animated_sky"
#define THUNDER		"sprites/laserbeam.spr"

#define TASK_LIGHT	789697

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
	CloudsAir_Create();
	CloudsRain_Create();
	SunMoon_Create();
	ThunderSphere_Create();

	// set_task(random_float(10.0, 10.0), "Sky_Thunder", _, _, _, "b");
	// set_task(random_float(1.0, 5.0), "ThunderSphere_Mini");
	set_task(5.0, "Sky_Thunder");
	
	
	Set_Sphere_aVel();

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
	BRIGHTNESS -= CLOUDNESS * 1.0;
	BRIGHTNESS = floatclamp(BRIGHTNESS, BASE_COLOR_MIN, BASE_COLOR_MAX);

	set_pev(idx_Base, pev_renderamt, BRIGHTNESS);

	STARLESS = (255.0 - BRIGHTNESS * 2.0) - CLOUDNESS;
	STARLESS = floatclamp(STARLESS, 0.0, 254.0);
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
	
	set_task( g_SkyDayTime / 600.0 , "CloudsAir_Think", _, _, _, "b");

}


public CloudsAir_Think()
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
	if(ChanceBet < 1 && CLOUDNESS > cloud_trans_min + 10.0 && CLOUDNESS < cloud_trans_max - 10.0)
	{
		cloud_skin_direction = -cloud_skin_direction;
	}
	// set_pev(idx_CloudsAir, pev_renderamt, CLOUDNESS); // 120 охуенный предел для CloudsAir Легкая облачность 120 
	// 50-200 хорошо очень


	set_pev(idx_CloudsAir, pev_renderamt, floatclamp(CLOUDNESS, cloud_trans_min, cloud_trans_max)); // 120 охуенный предел для CloudsAir Легкая облачность 120
	set_pev(idx_CloudsRain, pev_renderamt, floatclamp(CLOUDNESS, cloud_trans_min, cloud_trans_max)); // 120 охуенный предел для CloudsAir Легкая облачность 120
	
	SUNLESS_MOONLESS = 255.0 - CLOUDNESS;
	SUNLESS_MOONLESS = floatclamp(SUNLESS_MOONLESS, 0.0, 255.0);

	set_pev(idx_SunMoon, pev_renderamt, SUNLESS_MOONLESS);

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

	
	set_pev(iEntity, pev_rendermode, kRenderTransAdd); // Render alpha
	set_pev(iEntity, pev_renderamt, 255.0);
	idx_SunMoon = iEntity;
	// set_task( g_SkyDayTime / 600.0 , "SunMoon_Think", _, _, _, "b");
}

public SunMoon_Think()
{	
	//  <>>> CloudsAir_Think()
	/*
	SUNLESS_MOONLESS = 255.0 - CLOUDNESS;

	MoonBrightness = BRIGHTNESS - (CLOUDNESS*0.5);
	MoonBrightness = floatclamp(MoonBrightness, 0.0, 255.0);
	set_pev(idx_SunMoon, pev_renderamt, STARLESS);

	SUNLESS_MOONLESS = floatclamp(SUNLESS_MOONLESS, 0.0, 255.0);
	set_pev(idx_SunMoon, pev_renderamt, SUNLESS_MOONLESS);
	//server_print("MOONRIGHT %f", MoonBrightness);
	*/
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
		remove_task(7545);
		set_task(random_float(15.0, 50.0), "Sky_Thunder");
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
		set_task(0.1 , "ThunderSphere_Think", 7545, _, _, "b");
	}
	// random_float(2.0, 3.0)
	// set_task(random_float(4.0, 5.0), "ThunderSphere_Mini");
}


public Sky_Thunder() 
{
	if(CLOUDNESS < 180.0) return;
	
	set_pev(idx_ThunderSphere, pev_skin, 0);
	set_lights("z");
	
	set_task(0.1 , "ThunderSphere_Think", 7545, _, _, "b");
	THUNDERLIGHT = random_float(50.0, 255.0);
	set_pev(idx_ThunderSphere, pev_renderamt, THUNDERLIGHT);

	
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
	
	set_task(0.1, "Sky_Thunder_Decay");

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
	base_avelocty[0] = -0.5 * SunMoon_avel_vecmul;  // X на меня
	base_avelocty[1] = 1.0 * SunMoon_avel_vecmul;  // Z
	base_avelocty[2] = -1.0 * SunMoon_avel_vecmul;  // Y   <====
	set_pev(idx_Base, pev_angles, {0.0, -90.0, 0.0} );
	set_pev(idx_Base, pev_avelocity, base_avelocty);

	// Stars 
	set_pev(idx_Stars, pev_avelocity, {-0.075, -0.075, -0.075});

	// Clouds AIR
	//cloud_avelocty[1] = 1.2 * base_avelocty[1] + generate_random_velocity_compact(); 
	// cloud_avelocty[2] = 1.2 * base_avelocty[2] + generate_random_velocity_compact();
	cloud_avelocty[1] = floatclamp( 1.2 * base_avelocty[1] + generate_random_velocity_compact() , -1.5 , 1.5);
	cloud_avelocty[2] = floatclamp( 0.6 * base_avelocty[1] + generate_random_velocity_compact() , -1.5 , 1.5);
	set_pev(idx_CloudsAir, pev_avelocity, cloud_avelocty); // задаёт вращение 
	server_print(" x %f ^t y %f", cloud_avelocty[1], cloud_avelocty[2]);

	// CLouds Rain
	cloud_avelocty[1] = 1.1 * cloud_avelocty[1] + generate_random_velocity_compact();
	cloud_avelocty[2] = 1.1 * cloud_avelocty[2] + generate_random_velocity_compact();
	set_pev(idx_CloudsRain, pev_avelocity, cloud_avelocty); // задаёт вращение 
	

	// Sun Moon
	sunmoon_avelocty[0] = 1.0 * SunMoon_avel_vecmul;
	sunmoon_avelocty[1] = 0.25 * SunMoon_avel_vecmul;
	// sun_obj_avel[2] = 0.5 * SunMoon_avel_vecmul; // тарелка крутится как руль
	set_pev(idx_SunMoon, pev_angles, {90.0, 0.0, 0.0}); 
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
        server_print("[SKY] Освещение: %c (угол: %.1f°)", current_light_char, angle);
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
    if (old_light != current_light_char) {
        server_print("[SKY] Освещение: %c (угол: %.1f° | Облачность: %.0f| Влияние: %.1f%%)", 
            current_light_char, angle, CLOUDNESS, cloud_influence * 100.0);
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
        server_print("[SKY] Освещение: %c (угол: %.1f° | Облачность: %.0f)", current_light_char, angle, CLOUDNESS);
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