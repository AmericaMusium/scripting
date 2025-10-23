#include <amxmodx>

#pragma semicolon 1

public plugin_precache() 
{
    precache_generic("sound/1944/1944intro.mp3");
}

public client_connect(id) 
{
    client_cmd(id, "mp3 play ^"1944/1944intro.mp3^"");
}

public client_putinserver(id)
{
    set_task(10.0, "task_StopMusic", id);
}

public task_StopMusic(id) {
    client_cmd(id, "mp3 stop");
}