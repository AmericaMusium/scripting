#include <amxmodx> 
#include <fakemeta>
#include <hamsandwich>

#define VERSION "0.6" 

const HUD_HIDE_CAL = 1<<0
const HUD_HIDE_FLASH = 1<<1
const HUD_HIDE_ALL = 1<<2	
const HUD_HIDE_RHA = 1<<3
const HUD_HIDE_TIMER = 1<<4
const HUD_HIDE_MONEY = 1<<5
const HUD_HIDE_CROSS = 1<<6
const HUD_DRAW_CROSS = 1<<7

const HIDE_GENERATE_CROSSHAIR = HUD_HIDE_FLASH|HUD_HIDE_RHA|HUD_HIDE_TIMER|HUD_HIDE_MONEY|HUD_DRAW_CROSS

#define	m_iHideHUD			361
#define	m_iClientHideHUD		362
#define	m_pClientActiveItem		374

enum _:Hide_Hud {
	Hide_Cal,
	Hide_Flash,
	Hide_All,
	Hide_Rha,
	Hide_Timer,
	Hide_Money,
	Hide_Cross,
	Draw_Cross
}

new g_bitHudFlags

new g_pCvars[Hide_Hud]

public plugin_init() 
{ 
	register_plugin("HUD Customizer", VERSION, "Igoreso/ConnorMcLeod") 
	
	g_pCvars[Hide_Cal] = register_cvar("amx_hud_hide_cross_ammo_weaponlist", "0")
	g_pCvars[Hide_Flash] = register_cvar("amx_hud_hide_flashlight", "1")
	g_pCvars[Hide_All] = register_cvar("amx_hud_hide_all", "1")
	g_pCvars[Hide_Rha] = register_cvar("amx_hud_hide_radar_health_armor", "1")
	g_pCvars[Hide_Timer] = register_cvar("amx_hud_hide_timer", "1")
	g_pCvars[Hide_Money] = register_cvar("amx_hud_hide_money", "0")
	g_pCvars[Hide_Cross] = register_cvar("amx_hud_hide_crosshair", "0")
	g_pCvars[Draw_Cross] = register_cvar("amx_hud_draw_crosshair", "0")

	register_event("HLTV", "Event_HLTV_New_Round", "a", "1=0", "2=0")

	register_event("ResetHUD", "Event_ResetHUD", "b")
	register_event("HideWeapon", "Event_HideWeapon", "b")

	Event_HLTV_New_Round()
}

public Event_HLTV_New_Round()
{
	for(new i; i<Hide_Hud; i++)
	{
		if( get_pcvar_num( g_pCvars[i] ) )
		{
			g_bitHudFlags |= 1<<i
		}
	}
}

public Event_ResetHUD(id)
{
	if( g_bitHudFlags )
	{
		set_pdata_int(id, m_iClientHideHUD, 0)
		set_pdata_int(id, m_iHideHUD, g_bitHudFlags)
	}	
}

public Event_HideWeapon( id )
{
	new iFlags = read_data(1)
	if( g_bitHudFlags && (iFlags & g_bitHudFlags != g_bitHudFlags) )
	{
		set_pdata_int(id, m_iClientHideHUD, 0)
		set_pdata_int(id, m_iHideHUD, iFlags|g_bitHudFlags)
	}

	if( iFlags & HIDE_GENERATE_CROSSHAIR && !(g_bitHudFlags & HUD_DRAW_CROSS) && is_user_alive(id) )
	{
		set_pdata_cbase(id, m_pClientActiveItem, FM_NULLENT)
	}
}