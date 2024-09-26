#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>
#include <fakemeta_util>
#include <fun>
#include <dodx>
#include <dodfun>
#include <dodconst>
#include <dodstats>
#include <hamsandwich>
#include <xs> 


new bool:is_battle_royale_active = false

new g_players_lifes[33] // max 3-5  to respawn

/* 
Королевская битва. 
Все флаги установить на 1. или стереть как существование   // singlecaps
Установить таймер раунда.   /// timeleft()
Создать переключать Death-Match или нет. (лучше да)  но дать 3-5 жизней . к стати есть бонус респаун ) 
player spawn и player wepoant stirp . give spade или лопату. 
переодически рандомно отправлять ящики с оружием.  добавить визуальную анимацию gta 
на доннере должно хорошо сработать.   
в начале сделать рендер тип прозрачный полностью 
а потом на волне объявить уже рендер и запустиь подарки. 
Новый игрок на дисконнекте может получить бан 
можно задать счётчик
*//// 


// Done in init to remove entities that were already created
public plugin_init()
{
	register_plugin("DOD Battle Royale", "0.0", "America")
}



////////////////////
@Task_DisplayMessage(id)
{
	client_print(id, print_chat, "%l", "TYPE_HELP", HelpCommand, SearchCommand);

	if (CvarTimeLimit > 0.0)
	{
		new timeleft = get_timeleft();

		if (timeleft > 0)
		{
			client_print(id, print_chat, "%l", "TIME_INFO_1", timeleft / 60, timeleft % 60, CvarNextmap);
		}
		else if (CvarNextmap[0] != EOS)
		{
			client_print(id, print_chat, "%l", "TIME_INFO_2", CvarNextmap);
		}
	}
}
