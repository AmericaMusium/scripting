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


new sprite_all

public plugin_precache()
{
    sprite_all = precache_model("sprites/ripple.spr")
}

public plugin_init()
{
register_plugin("DOD CSGO PICKPOINTS","0.1","[America][TheVaskov]")
register_clcmd("set_point", "point_set", 0, "set up point for teammste")
}




public point_set(id_owner)
{
if(!is_user_alive(id_owner))
    return PLUGIN_CONTINUE

//Получаем координаты для спрайта
new origin[3]
get_user_origin(id_owner,origin,3)
new team_owner = get_user_team(id_owner)

//Говорим что хотим создать временный объект и показать одному игроку
message_begin(MSG_ONE,SVC_TEMPENTITY,origin,id_owner)
write_byte(TE_SPRITE)//говорим что хотим создать, в данном случае спрайт
write_coord(origin[0])//х - координата
write_coord(origin[1])//у - координата
write_coord(origin[2])//z - координата
write_short(sprite_all)// id спрайта
write_byte(30) //масштаб
write_byte(50)//яркость
message_end()
client_cmd(id_owner, "spk sound/fvox/hiss")


new maxpl = get_maxplayers();
for (new pl = 1; pl <= maxpl; pl++)
{
if (is_user_connected(pl) && !is_user_bot(pl))
{
new team_mate = get_user_team(pl)
if (team_mate==team_owner)
{
message_begin(MSG_ONE,SVC_TEMPENTITY,origin,pl)
write_byte(TE_SPRITE)//говорим что хотим создать, в данном случае спрайт
write_coord(origin[0])//х - координата
write_coord(origin[1])//у - координата
write_coord(origin[2])//z - координата
write_short(sprite_all)// id спрайта
write_byte(20) //масштаб
write_byte(50)//яркость
message_end()

client_cmd(pl, "spk sound/player/geiger1")
} 
else return 0
}
}
return 0
}