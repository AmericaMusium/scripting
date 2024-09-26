#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>
#include <fakemeta_util>
#include <fun>
#include <dodx>
#include <dodfun>
#include <hamsandwich>

#define PLUGIN "DOD SOUNDS"
#define VERSION "23jan2023"
#define AUTHOR "[America][TheVaskov]"

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
    register_clcmd("say sound", "func_stop_sound")

    register_forward(FM_EmitSound, "fw_emit_sound")

  

}

public func_stop_sound(){

    new ent = -1
	while ((ent = fm_find_ent_by_class(ent, "ambient_generic"))) 
	{
		server_print(" ambinet sound foudned %d", ent)
        fm_remove_entity(ent)
	}
	return PLUGIN_CONTINUE

}


public fw_emit_sound(id,channel,const sound[])
{
    if(equal(sound,"burning1.wav")) // проверяем,тот ли звук мы поймали
    {
        // emit_sound(id,channel,"ussr/ustakingfireleft.wav",1.0,1.0,0,100) // проигрываем нужный нам

        server_print(" ++++++++++++++++++++ ambinet sound foudned %d ", channel)
        return FMRES_SUPERCEDE;
    }
}


public sounds_Stops(){



client_cmd(0, "stopsound");
}



public client_connect(id)
{

client_cmd(id, "stopsound");
}
