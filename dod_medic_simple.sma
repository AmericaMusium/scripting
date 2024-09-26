#include <amxmodx>

#include <fun>
#include <dodx>

// amx_medic coded/developed by StrontiumDog
// Plugin in use at TheVille.Org II - DoD v1.3 Custom Map Server FF ON
// 63.210.145.199:27015
// http://www.theville.org 

public plugin_init()
{
	register_plugin("amx_medic by StrontiumDog", "1.3b", "StrontiumDog")
	register_clcmd("say /medic","medic",0,"- Calls for medic when your health is below 20hp")
	register_clcmd("say_team /medic","medic",0,"- Calls for medic when your health is below 20hp")
	register_cvar("amx_medic_maxhealth", "60") // max health a person can have when being healed(default 60)
	register_cvar("amx_medic_minhealth", "20") // max health a person can have when being healed(default 20)
}

public plugin_precache() 
{
	precache_sound("medic/us_medic.wav")
	precache_sound("medic/ger_medic.wav")
	precache_sound("medic/britmedic.wav")
	precache_sound("medic/bandage1.wav") 
}

public medic(id,level,cid)
{
	new med_health = get_user_health(id) // get player health
	new med_minhealth = 20
	new med_maxhealth = 60
	
	// Is the map British or American (Thanks Diamond-Optic!)
	new uk = dod_get_map_info(MI_ALLIES_TEAM)
	
	new med_myname[33]
	get_user_name(id, med_myname, 32)
	
	// If player is dead, send message and exit
    if(!is_user_alive(id))
	{
        client_print(id, print_chat, "[MEDIC] You are dead. You have ceased to be. You have kicked the bucket. You are pushing up the daisies.")
       	return PLUGIN_HANDLED
    }
	
	// If player's health is not below minhealth var, send message and exit
	if (med_minhealth < med_health)
	{
		client_print(id, print_chat, "[MEDIC] You have %d hp. It's only a flesh wound. Get up and fight soldier!", med_health)
		return PLUGIN_HANDLED;
	}
	
	// Play US medic sound
	if  ((get_user_team(id) == 1) && (uk == 0))
	{
		emit_sound(id, CHAN_AUTO, "medic/us_medic.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	}
	
	// Play German medic sound
	if (get_user_team(id) == 2) 
	{
		emit_sound(id, CHAN_AUTO, "medic/ger_medic.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	}
	
	// Play British medic sound
	if  ((get_user_team(id) == 1) && (uk == 1))
	{
		emit_sound(id, CHAN_AUTO, "medic/britmedic.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	}
	
	//While player is being healed, fade the screen to black
	ftb(id)
	
	// Heal them

	set_user_health(id, med_maxhealth)
	client_print(0, print_chat, "[MEDIC] %s has been healed", med_myname)
	emit_sound(id, CHAN_AUTO, "medic/bandage1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	return PLUGIN_HANDLED;
}

// Fades screen to black while player is being healed
public ftb(id)
{
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


