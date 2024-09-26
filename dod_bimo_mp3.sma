#include <amxmodx>
#include <amxmisc>

#define IsMp3Format(%1)    bool:(equali(%1[strlen(%1) - 4], ".mp3"))


new const mp3song[] = "sound/BOOF/inst.mp3"
new const mp3black[] = "media/gamestartup.mp3"
public plugin_init()
{
     register_plugin("DOD MP3 CONNECT","0.0","America")
}


public plugin_precache( )
{
    precache_generic(mp3song)
    precache_generic(mp3black)
}

public client_connect(id)
{
    client_cmd(id, "stopsound; mp3 play %s", mp3black);
}

public client_putinserver(id)
{
    // client_cmd(id, "stopsound; mp3 play %s", mp3song);
    set_task(0.2, "startsong" , id)
   
}
public startsong(id)
{

    client_cmd(id, "stopsound; mp3 play %s", mp3song);
}