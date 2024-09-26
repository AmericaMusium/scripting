#include <amxmodx>
#include <hamsandwich>

#define PLUGIN "DOD Damage hud"
#define VERSION "1.0"
#define AUTHOR "America" //+79101483016 WhatsApp

new max_players;

public plugin_init()
{
register_plugin(PLUGIN, VERSION, AUTHOR)
RegisterHam ( Ham_TakeDamage, "player", "UserTakeDamage");
max_players = get_maxplayers();
}

public UserTakeDamage ( victim, weapon, attacker, Float:damage, damagebits )
{
if(is_user_bot(attacker)) return 0
else if((attacker>0)&&(attacker<max_players))
    {
        set_hudmessage(130, 40, 10, -1.0, 0.55, 0, 2.0, 1.0, 0.1, 0.1, 3)
        show_hudmessage(attacker, "%.0f", damage)
    }
return 0
}
