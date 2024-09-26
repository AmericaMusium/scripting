#include <amxmodx>
#include <amxmisc>
#include <engine>

public plugin_init()
{
	register_plugin("DOD NightDays","0.0","America")
	server_print("DOD NightDays")
    register_clcmd("say /light","light")
    register_clcmd("say /light2","light2")

    register_clcmd("say /dd","update_light")
    
}
 
public light(id){
 
    set_lights("b")
     
}
 
public light2(id){
 
    set_lights("z")
     
}

public update_light()
{
    new a = get_timeleft()
    client_print(0, print_chat, "Timeleft %d:%02d", (a / 60), (a % 60))
    client_print(0, print_chat, "Timeleft %d", a)
    // a = 1773
    // 1773 / 60= количество оставш минут до конца в десятично значении. = 29,55   

    new Float:currentlimit = get_cvar_float("mp_timelimit")
    server_print("current limit = %f", currentlimit)
    currentlimit += 10.0

}