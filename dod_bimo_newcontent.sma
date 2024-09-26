#include <amxmisc>
#include <dodx>
#include <dodfun>
#include <fakemeta>
#include <hamsandwich>

public plugin_init()
{
	register_plugin("DOD SOUNDRES","0.0","America")
	server_print("SOUNDRES")	
    register_forward(FM_EmitSound, "fw_emit_sound") // регестрируем форвард который будет работать как фильтр звуков
}

public plugin_precache() 
{	
	//axis menu 1
	precache_sound("misc/heatisone2.wav")		//1
	
}

public fw_emit_sound(id,channel,const sound[])
{
    if(equal(sound,"ambience/britwin.wav")) // проверяем,тот ли звук мы поймали
    {
        emit_sound(id,channel,"misc/heatisone2.wav",1.0,1.0,0,100) // проигрываем нужный нам
        return FMRES_SUPERCEDE;
    }
    if(equal(sound,"ambience/germanwin.wav")) // проверяем,тот ли звук мы поймали
    {
        emit_sound(id,channel,"misc/heatisone2.wav",1.0,1.0,0,100) // проигрываем нужный нам
        return FMRES_SUPERCEDE;
    }
    if(equal(sound,"ambience/uswin.wav")) // проверяем,тот ли звук мы поймали
    {
        emit_sound(id,channel,"misc/heatisone2.wav",1.0,1.0,0,100) // проигрываем нужный нам
        return FMRES_SUPERCEDE;
    }
}