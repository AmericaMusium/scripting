#include <amxmodx>
#include <fakemeta>
#include <engine>
#include <fun>
#include <dodx>
#include <dodfun>
#include <hamsandwich>

/*
немножко проверить сколько аптечек на карте
добавить модель аптечки в w_model1944 общую
*/
#define MAX_MEDKITS 4
#define TASK_OFFSET_MEDKIT 4048

new Float:spawn_origin[MAX_MEDKITS][3];


new const Medkit_Model[] = "models/mapmodels/sandbag_gib.mdl";
new const Medkit_Sound[] = "1944/1944zoom_out.wav";
new current_spawn_number;
new g_medkit_limiter;
new bool:Is_ready_to_spawn;

// Precache required files
public plugin_precache()
{
    precache_model(Medkit_Model);
    precache_sound(Medkit_Sound);
}

public plugin_init()
{
    register_plugin("DOD Medkits Support","0.0","America");
    current_spawn_number = 0;
    Is_ready_to_spawn = false;
    register_touch("world_medkit", "player", "Medkit_Touch");
}

public client_death(killer,victim,wpnindex,hitplace,TK)
{  
    if (!is_user_connected(killer) || !is_user_connected(victim))
    return PLUGIN_CONTINUE


    pev(victim, pev_origin, spawn_origin[current_spawn_number]);
    spawn_origin[current_spawn_number][2] += 15.0;
    current_spawn_number++;
    if(current_spawn_number > MAX_MEDKITS-1)
    {
        current_spawn_number = 0;
        Is_ready_to_spawn = true;
    }
    return Medkit_Spawn();
}


public Medkit_Spawn()
{	
    if(Is_ready_to_spawn==false) return 0;

    new idx_Medkit = create_entity("info_target");
    set_pev(idx_Medkit, pev_solid, SOLID_TRIGGER);
    set_pev(idx_Medkit, pev_movetype, MOVETYPE_TOSS);
    set_pev(idx_Medkit, pev_classname, "world_medkit")
    // Если нужно что бы разбивалось от пули , надо менять на 
    // SOLID_BBOX и менять точку старта, а то задевае игрока
    // set_pev(idx_Medkit, pev_health, 1.0);
    // set_pev(idx_Medkit, pev_takedamage, DAMAGE_YES);
    
    set_pev(idx_Medkit, pev_origin, spawn_origin[random_num(0, MAX_MEDKITS-1)]);

    if(!pev_valid(idx_Medkit)) 
    {
        return PLUGIN_HANDLED;
    }

    g_medkit_limiter++;
    if(g_medkit_limiter > MAX_MEDKITS-1)
    {
        Medkit_Delete(idx_Medkit);
        return 0;
    }
    // set_pev(idx_Medkit, pev_nextthink, get_gametime() + 1.0) //  think
    // drop_to_floor(idx_Medkit);
    // emit_sound(idx_Medkit, CHAN_AUTO, "weapons/bazookareloadgetrocket.wav", 1.0, ATTN_NORM, 0, PITCH_NORM); //  
    engfunc(EngFunc_SetModel, idx_Medkit, Medkit_Model); // 
    engfunc(EngFunc_SetSize, idx_Medkit, Float:{-6.0, -6.0, 0.0}, Float:{6.0, 6.0, 3.0}); 

    pev(idx_Medkit, pev_scale, 4.0);
    client_print(0, print_chat, "medkit spawned %d", g_medkit_limiter);
    fx_rendering(idx_Medkit);
    set_task(10.0, "Medkit_Delete", idx_Medkit);
    return 1;
}





public Medkit_Touch(idx_Medkit, idx_player)
{
	if(is_user_alive(idx_player) && !is_user_bot(idx_player))
	{
//		user_silentkill(idx_player);
        //client_print(0, print_chat, "medkit touched");
        // emit_sound(idx_Medkit, CHAN_AUTO, Medkit_Sound, 1.0, 1.5 , 0, (PITCH_NORM + (random_num(-50, 5))));
        // client_cmd(idx_player,"spk 1944/1944medkit2.wav");

        set_user_health(idx_player, clamp((get_user_health(idx_player) + 30),0,100));
        Medkit_Delete(idx_Medkit);
        fx_screenfade(idx_player);
        
        
	}
}

public Medkit_Delete(idx_Medkit)
{   
    if(pev_valid(idx_Medkit))
    {   
        g_medkit_limiter--;
        remove_entity(idx_Medkit);
    }   
}



public fx_screenfade(idx_player)
{
    if (!is_user_connected(idx_player))
        return;
    
    // Второй, более мягкий эффект
    message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("ScreenFade"), _, idx_player);
    write_short(1<<10);
    write_short(1<<10);
    write_short(0x0000);
    write_byte(100);
    write_byte(220);
    write_byte(100);
    write_byte(50);
    message_end();

    emit_sound(idx_player, CHAN_AUTO, Medkit_Sound, 1.0, 1.5 , 0, (PITCH_NORM + (random_num(-50, 5))));
}

public fx_rendering(idx_Medkit)
{
	set_rendering(idx_Medkit, kRenderFxGlowShell, random(5), random(40), random(5), kRenderNormal, 16);
}

// Fades screen to black while player is being healed
public ftb(id)
{   
    /// пиздатое затемнение как удар в затылок-)
	new Fade 
	Fade = get_user_msgid("ScreenFade")
	message_begin(MSG_ONE, Fade, {0,0,0}, id);  
	write_short(floatround(2.0*4096.0)); // fade lasts this long duration 
	write_short(floatround(4.0*4096.0)); // fade lasts this long hold time 
	write_short(2); // fade type in/out
	write_byte(0); // fade red 
	write_byte(0); // fade green 
	write_byte(0); // fade blue  
	write_byte(240); // fade alpha: Change to 255 for complete blackness and recompile
	message_end(); 
    
	return PLUGIN_CONTINUE
}
