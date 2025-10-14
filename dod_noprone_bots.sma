#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <dodx>

#define PLUGIN "dod_noprone_bots"
#define VERSION "0.0"
#define AUTHOR "America"
new now_maxplayers
public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	set_task(0.8,"Check_bots_for_Prone",0,_,_,"b") // b - Выполнение задачи бесконечно количество раз
	now_maxplayers = get_maxplayers()
}

public Check_bots_for_Prone() 
{
	// правильный цикл по maxpl
    for(new idx_player = 1 ; idx_player < now_maxplayers + 1 ; idx_player++)
	{   
		if(is_user_alive(idx_player) && is_user_bot(idx_player))
		{
			dod_set_pronestate( idx_player, 0 );
		}
	}
    return PLUGIN_CONTINUE;
}

stock dod_set_pronestate( id, flag ) 
{
	set_pev( id, pev_iuser3, flag );
}