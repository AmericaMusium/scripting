
#include <amxmodx>
#include <dodx>
#include <fakemeta>

#define brit_ammo_sound "player/britneedammo.wav"
#define axis_ammo_sound "player/gerneedammo.wav"
#define us_ammo_sound "player/usneedammo.wav"


public plugin_init() {
    register_plugin("DOD NEED AMMO SUPPOR", "0.0", "America")
    register_forward(FM_EmitSound , "EmitSound");
}


public EmitSound(entity, channel, const sound[])
{
    // britneedammo.wav
    // gerneedammo.wav
    // usneedammo.wav

    switch (sound)
    {
        case 0:
        {
            server_print(sound)
        }

        case 1:
        {
            server_print(sound)
        }
        
        case 2:
        {
            server_print(sound)
        }
    
    }
    /*
    if(equal(sound , "weapons/cbar_miss1.wav"))
    {
        emit_sound(entity,  channel, "hlzm/claw_miss.wav", 1.0, ATTN_NORM, 0, PITCH_NORM);
        client_print(entity, print_chat,"This sound ====> Done!")
        return FMRES_SUPERCEDE;
    }
    
    */
    return FMRES_IGNORED;
} 