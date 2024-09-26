#include <amxmodx>

#define Maxsounds 1

new plugin_author[] = "AMXX DoD Team"
new plugin_version[] = "1.0"

new soundlist[Maxsounds][] = {"sound/thevaskovband"}

public plugin_init( )
{
    register_plugin("DoD Connect Sound MP3", plugin_version, plugin_author)
    register_cvar("dod_connectsound_mp3", plugin_version, FCVAR_SERVER)
}

public plugin_precache( )
{
    new temp[128]
    for ( new a = 0; a < Maxsounds; a++ )
    {
             format(temp, 127, "%s.mp3", soundlist[a])
             if ( file_exists(temp) )
                 precache_generic(temp)
    }
}

public client_putinserver( id )
{
    set_task(3.0, "consound", 100 + id)
}

public consound( timerid_id )
{
    new id = timerid_id - 100
    new Usertime
    Usertime = get_user_time(id, 0)
    if ( Usertime <= 0 )
    {
        set_task(3.0, "consound", timerid_id)
    }else
    {
        new i = random(Maxsounds)
        client_cmd(id, "mp3 play ^"%s^"", soundlist[i])
    }
    
    return PLUGIN_CONTINUE
}
