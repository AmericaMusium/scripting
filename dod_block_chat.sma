#include <amxmodx>
#include <amxmisc>

#define PLUGIN "DOD Damage hud"
#define VERSION "1.0"
#define AUTHOR "America" //+79101483016 WhatsApp

new bool:is_chat_blocked

public plugin_init()
{
    register_plugin("DOD BLOCK CHAT", "0.0", "Anerica") 
    register_clcmd ("say blockchat", "menu_dir_browse", ADMIN_LEVEL_A)
    register_clcmd ("say chatblock", "menu_dir_browse", ADMIN_LEVEL_A)
    register_clcmd("say", "on_ChatMsg")
    register_clcmd("say_team", "on_ChatMsg")

}

public Switch_Chat(id, level, cid)
{
    if (!cmd_access(id, level, cid, 3))
        return PLUGIN_HANDLED

    if (is_chat_blocked)
    {
        is_chat_blocked = false
        client_print(0 ,print_chat,"CHAT UNBLOCKED")
    }
    else
    {
        is_chat_blocked = true
        client_print(0 ,print_chat,"CHAT BLOCKED")
    }
    return PLUGIN_CONTINUE
}


public on_ChatMsg()
{
	if (is_chat_blocked)
	{
		return PLUGIN_HANDLED;
	}
	return 0;
}

