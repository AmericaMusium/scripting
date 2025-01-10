#include <amxmodx>
#include <fakemeta>
#include <dhudmessage>

#define m_iNumTKs 478
new g_total_TK[32]

new const TK_SOUND_1[] = "server/tk1.wav"
new const TK_SOUND_2[] = "server/tk2.wav"
new const TK_SOUND_3[] = "server/tk3.wav"
new const TK_SOUND_4[] = "server/tk4.wav"
new const TK_SOUND_5[] = "server/tk5.wav"

#define WARNMESSAGE "Вы убили товарища по команде!"
#define BANMESSAGE "Вы забанены за многочисленные убийства товарищей по команде!"

public plugin_init()
{
	register_plugin("DOD TK Manager SovSer","0.0","America")
    // WhatsApp +79101483016
}   

public plugin_precache()
{
    precache_sound(TK_SOUND_1)
    precache_sound(TK_SOUND_2)
    precache_sound(TK_SOUND_3)
    precache_sound(TK_SOUND_4)
    precache_sound(TK_SOUND_5)
}

public client_authorized(idx_player)
{
    g_total_TK[idx_player] = 0
}

public client_death(killer,victim,wpnindex,hitplace,TK)
{
    if(TK)
    {
        set_pdata_int(killer, m_iNumTKs, 0, 5) // RESET TEAMKILL
        g_total_TK[killer]++
        tk_notification(killer, g_total_TK[killer])
    }
    else
    {
        return;
    }
}

public tk_notification(idx_player, TK)
{
    switch (TK)
    {
    case 1:
    {
        emit_sound(idx_player, CHAN_AUTO, TK_SOUND_1 , 1.0, ATTN_NORM, 0, PITCH_NORM)
        set_dhudmessage(255, 0, 0, -1.0, -1.0 , 0, 6.0, 6.0) // r g b 
        show_dhudmessage(idx_player, WARNMESSAGE)
    }
    case 2:
    {
        emit_sound(idx_player, CHAN_AUTO, TK_SOUND_2, 1.0, ATTN_NORM, 0, PITCH_NORM)
        set_dhudmessage(255, 0, 0, -1.0, -1.0 , 0, 6.0, 6.0) // r g b 
        show_dhudmessage(idx_player, WARNMESSAGE)
    }
    case 3:
    {
        emit_sound(idx_player, CHAN_AUTO, TK_SOUND_3 , 1.0, ATTN_NORM, 0, PITCH_NORM)
        set_dhudmessage(255, 0, 0, -1.0, -1.0 , 0, 6.0, 6.0) // r g b 
        show_dhudmessage(idx_player, WARNMESSAGE)
    }
    case 4:
    {
        new rand_i = random_num(0,1)
        switch (rand_i)
        {
            case 0:emit_sound(idx_player, CHAN_AUTO, TK_SOUND_4 , 1.0, ATTN_NORM, 0, PITCH_NORM)
            case 1:emit_sound(idx_player, CHAN_AUTO, TK_SOUND_5 , 1.0, ATTN_NORM, 0, PITCH_NORM)
            default: emit_sound(idx_player, CHAN_AUTO, TK_SOUND_4 , 1.0, ATTN_NORM, 0, PITCH_NORM)
        } 
        set_dhudmessage(255, 0, 0, -1.0, -1.0 , 0, 6.0, 6.0) // r g b 
        show_dhudmessage(idx_player, BANMESSAGE)
        // set_task(3.0, "tk_ban_player")

        // tk_ban_player(idx_player)
        new userid = get_user_userid(idx_player)
        set_task(3.0,"tk_ban_player", userid)
    }
    default:
    {
        return
    }
    }
}

public tk_ban_player(userid)
{
	server_cmd("banid %d.0 #%d", 1440 , userid)
	server_cmd("writeid")
	server_cmd("kick #%d",userid)
}

public client_disconnected(idx_player)
{
    g_total_TK[idx_player] = 0
}