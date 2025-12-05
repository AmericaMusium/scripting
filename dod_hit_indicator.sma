#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>
/*
Плагин показывает попадание, брызгает кровью
*/ 

public plugin_init()
{
}

// Дополнительная функция для кровавых следов при ранении
public client_damage(attacker, victim, damage, wpnindex, hitplace, TA)
{
    if (!is_user_alive(victim) || damage < 5)
        return;
    
    // Создаем кровавый след при серьезном ранении
    if (damage > 15 && hitplace == HIT_CHEST)
    {
        new Float:origin[3];
        pev(victim, pev_origin, origin);
        
        // Создаем большое кровавое пятно на земле
        message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
        write_byte(TE_WORLDDECAL);
        write_coord_f(origin[0]);
        write_coord_f(origin[1]);
        write_coord_f(origin[2] - 36.0);
        write_byte(random_num(190, 195)); // Случайный декаль крови
        message_end();
    }
}