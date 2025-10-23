#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>

#define PLUGIN		"Animated Sky"
#define VERSION		"2.0"
#define AUTHOR		"Sneaky.amxx | GlobalModders.net | MayroN"

#define ANIMATED_SKY	"models/animated_sky/animated_sky_new.mdl"

#define CLASSNAME_SKY	"animated_sky"

#define THUNDER		"sprites/laserbeam.spr"

enum
{
	enum_sky_type_blue = 0,
	enum_sky_type_rain,
	enum_sky_type_storm,
	enum_sky_type_snow
}

new 
	mapname[64],
	sky_type,
	sky_light[2],
	Float:sky_thunder_time,
	Float:sky_speed_animated;

new const weather_sound[][] = 
{
	"weather_sound/rain_sound.wav",
	"weather_sound/snow_sound.wav",
	"weather_sound/thunder.wav"
}

new g_thunder;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	Load_Cfg();
	Create_Sky();
}

Load_Cfg()
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
				sky_type = str_to_num(value);
			else if (equal(key, "SKY_LIGHT"))
				formatex(sky_light, charsmax(sky_light), "%s", value);
			else if (equal(key, "SKY_THUNDER_TIME"))
				sky_thunder_time = str_to_float(value);
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

	if(sky_type == enum_sky_type_rain)
	{
		create_entity("env_rain");
		set_lights(sky_light);
		g_thunder = precache_model(THUNDER);

		set_task(sky_thunder_time, "Thunder", _, _, _, "b");
	}

	if(sky_type == enum_sky_type_storm)
	{
		create_entity("env_rain");
		set_lights(sky_light);
		g_thunder = precache_model(THUNDER);

		set_task(sky_thunder_time, "Thunder", _, _, _, "b");
	}

	if(sky_type == enum_sky_type_snow)
	{
		create_entity("env_snow");
		set_lights(sky_light);
	} 

	for(new i = 0; i < sizeof weather_sound; i++)
		precache_sound(weather_sound[i])

	engfunc(EngFunc_PrecacheModel, ANIMATED_SKY);
}

public client_connect(id)
{
	client_cmd(id, "cl_weather 1");
}

public client_putinserver(id)
{
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
}

Create_Sky()
{
	new iEntity = create_entity("info_target");
	
	if(!pev_valid(iEntity))
		return;

	set_pev(iEntity, pev_classname, CLASSNAME_SKY);
	set_pev(iEntity, pev_solid, SOLID_NOT);
	set_pev(iEntity, pev_sequence, 0);
	set_pev(iEntity, pev_framerate, sky_speed_animated);

	if(sky_type == enum_sky_type_blue)
		set_pev(iEntity, pev_skin, random_num(0, 6));

	if(sky_type == enum_sky_type_rain)
		set_pev(iEntity, pev_skin, random_num(7, 8));

	if(sky_type == enum_sky_type_storm)
		set_pev(iEntity, pev_skin, random_num(9, 10));

	if(sky_type == enum_sky_type_snow)
		set_pev(iEntity, pev_skin, random_num(11, 12));

	engfunc(EngFunc_SetModel, iEntity, ANIMATED_SKY);
	engfunc(EngFunc_SetSize, iEntity, Float:{-50000.0, -50000.0, -50000.0}, Float:{50000.0, 50000.0, 50000.0});

	Light_Sky(iEntity);
}

public Light_Sky(iEntity)
{       
	if(!pev_valid(iEntity)) 
		return;
		
	new Float:fOrigin[3];	
	pev(iEntity, pev_origin, fOrigin)
        
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_DLIGHT);
	engfunc(EngFunc_WriteCoord, fOrigin[0]);
	engfunc(EngFunc_WriteCoord, fOrigin[1]);
	engfunc(EngFunc_WriteCoord, fOrigin[2] += 2000.0);
	write_byte(1000) 
	write_byte(0) 
	write_byte(0) 
	write_byte(0) 
	write_byte(2) 
	write_byte(0) 
	message_end()	   
  
	set_task(0.1, "Light_Sky", iEntity)  
}

public Thunder() 
{
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
	write_byte(15) 
	write_byte(60) 
	write_byte(35)
	write_byte(255) 
	write_byte(255) 
	write_byte(255) 
	write_byte(255) 
	write_byte(200) 
	message_end() 

	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_DLIGHT)
	write_coord_f(end[0]) 
	write_coord_f(end[1]) 
	write_coord_f(end[2] += 3.0) 	
	write_byte(25)
	write_byte(255)
	write_byte(255)
	write_byte(255)
	write_byte(8)
	write_byte(60)
	message_end()

	emit_sound(0, CHAN_STATIC, weather_sound[2], 1.0, ATTN_NORM, 0, PITCH_NORM);
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