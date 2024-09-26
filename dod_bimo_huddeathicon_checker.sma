#include <amxmodx>
#include <amxmisc>
#include <dodx>
#include <dodfun>

new gMsgDeathMsg
new hudicon = 0

public plugin_init()
{
	register_plugin("DOD HUDDEATH","0.0","America")
	server_print("DOD HUDDdddddddddEATH")
    gMsgDeathMsg = get_user_msgid("DeathMsg")

    register_clcmd("say /dd","func_hudico")
}
public func_hudico(id)
{

    message_begin(MSG_ALL, gMsgDeathMsg,{0,0,0},0)
    write_byte(0) // killer
    write_byte(id) // victim
    write_byte(hudicon)  // 42 is smash
    message_end()

    client_print(0, print_chat, "icon is %d", hudicon)
    hudicon++
}