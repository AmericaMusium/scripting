#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <xs>

#if AMXX_VERSION_NUM < 180

	#define HAM_IGNORED 1
	#define HAM_HANDLED 2
	#define Ham_Spawn Ham:0
	#define Ham_TraceAttack Ham:8
	#define Ham_TakeDamage Ham:9
	#define Ham_Touch Ham:42
	
	native HamHook:RegisterHam(Ham:function, const EntityClass[], const Callback[], Post=0)
	native SetHamParamFloat(which, Float:value)
	native DisableHamForward(HamHook:fwd)
	native EnableHamForward(HamHook:fwd)

#else

	#include <hamsandwich>

#endif

#define PLUGIN "Weapon Physics"
#define VERSION "2.1"
#define AUTHOR "Nomexous"

/*

Version 1.0
 - Initial release.

Version 2.0
 - Added. Ability to compile on amxmodx.org's online compiler.
 - Added. Menu for enabling/disabling the plugin.
 - Added. Ability for weapons to be moved when shot.
 - Added. Sparks when weapon hits a wall while moving above a certain speed.
 - Added. Hooking of custom classes.
 - Fixed. Looping bounce sound when touching dead bodies in DoD.
 
Version 2.1
 - Fixed. Custom item spawn debug message removed.
 - Fixed. Non-visible entities no longer react to explosions (e.g. armoury_entities that have been picked up).
 - Changed. Shooting of weapons now off by default.
 - Added. Menu option for weapon clatter.

*/

#define BOUNCE "items/weapondrop1.wav"
#define RIC "debris/metal6.wav"

// Persistant items that don't disappear when picked up.
new const persistant[][] = { "armoury_entity" }

// Dropped items.
new const classes[][] = { "weaponbox", "item_thighpack", "weapon_shield" }

// The base is what the entity is created as, e.g. ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target")).
// Put all of them here. Make sure that this custom entity can take damage, otherwise it won't work!
new const custom_base[][] = { "info_target" }
// What the entity's classname is changed to after it's created, e.g. set_pev(ent, pev_classname, "fakeweapon")
new const custom_classname[][] = { "fakeweapon" }

#define HOOK_COUNT 4 * (sizeof persistant + sizeof classes + sizeof custom_base)

new HamHook:hamhooks[HOOK_COUNT]
new traceline_fid = 0

new custom_count, shootweapons_pcvar, physics_pcvar, clatter_sound_pcvar

new Float:multiplier = 15.0

public plugin_precache()
{
	custom_count = sizeof custom_classname
	precache_sound(BOUNCE)
	precache_sound(RIC)
	
	physics_pcvar = register_cvar("weapon_physics_enabled", "1")
	shootweapons_pcvar = register_cvar("weapon_physics_shoot_weapons", "0")
	clatter_sound_pcvar = register_cvar("weapon_physics_weapons_clatter", "1")
	
	do_ham_hooks()
}

public do_ham_hooks()
{
	new count = 0
	
	for (new i; i < sizeof persistant; i++)
	{
		hamhooks[count++] = RegisterHam(Ham_Spawn, persistant[i], "spawn_persistant_item", 1)
		hamhooks[count++] = RegisterHam(Ham_Touch, persistant[i], "touch_item")
		hamhooks[count++] = RegisterHam(Ham_TakeDamage, persistant[i], "damage_item")
		hamhooks[count++] = RegisterHam(Ham_TraceAttack, persistant[i], "shoot_item")
	}
	
	for (new x; x < sizeof classes; x++)
	{
		hamhooks[count++] = RegisterHam(Ham_Spawn, classes[x], "spawn_item", 1)
		hamhooks[count++] = RegisterHam(Ham_Touch, classes[x], "touch_item")
		hamhooks[count++] = RegisterHam(Ham_TakeDamage, classes[x], "damage_item")
		hamhooks[count++] = RegisterHam(Ham_TraceAttack, classes[x], "shoot_item")
	}
	
	for (new n; n < sizeof custom_base; n++)
	{
		hamhooks[count++] = RegisterHam(Ham_Spawn, custom_base[n], "spawn_custom_item", 1)
		hamhooks[count++] = RegisterHam(Ham_Touch, custom_base[n], "touch_custom_item")
		hamhooks[count++] = RegisterHam(Ham_TakeDamage, custom_base[n], "damage_custom_item")
		hamhooks[count++] = RegisterHam(Ham_TraceAttack, custom_base[n], "shoot_item")
	}
}

public update_hooks_and_forwards()
{
	if (get_pcvar_num(physics_pcvar))
	{
		for (new i; i < sizeof hamhooks; i++)
		{
			EnableHamForward(hamhooks[i])
		}
	}
	else
	{
		for (new i; i < sizeof hamhooks; i++)
		{
			DisableHamForward(hamhooks[i])
		}
	}
	
	if (get_pcvar_num(shootweapons_pcvar) && get_pcvar_num(physics_pcvar) && !traceline_fid)
	{
		traceline_fid = register_forward(FM_TraceLine, "fw_traceline")
	}
	
	if ((!get_pcvar_num(shootweapons_pcvar) || !get_pcvar_num(physics_pcvar)) && traceline_fid)
	{
		unregister_forward(FM_TraceLine, traceline_fid)
		traceline_fid = 0
	}
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_event("HLTV", "restart", "a", "1=0", "2=0")
	
	update_hooks_and_forwards()
	
	register_clcmd("amx_weapon_physics_menu", "conjure_menu", ADMIN_SLAY, "Shows weapon physics menu.")
	
	// This multiplier controls how fast the grenade will propel items. Originally, I wanted it to just be proportional to
	// the damage, but CZ and CS has different grenade strengths. Add your own here.
	new mods[][] = { "cstrike", "czero" }
	new Float:mult[] = { 22.0,  17.0 }
	
	new modname[10]
	get_modname(modname, 9)
	
	for (new i; i < sizeof mods; i++)
	{
		if (equal(modname, mods[i]))
		{
			multiplier = mult[i]
		}
	}
}

public conjure_menu(id, level, cid)
{
	if (cmd_access(id, level, cid, 1))
	{
		wpm(id)
	}
	return PLUGIN_HANDLED
}

public wpm(id)
{
	static wpmenu
	
	wpmenu = menu_create("Weapon Physics", "menu_h")
	
	get_pcvar_num(physics_pcvar) ? menu_additem(wpmenu, "Weapon physics: \yEnabled", "1") : menu_additem(wpmenu, "Weapon phyics: \rDisabled", "1")
	get_pcvar_num(shootweapons_pcvar) ? menu_additem(wpmenu, "Shoot weapons: \yEnabled", "2") : menu_additem(wpmenu, "Shoot weapons: \rDisabled", "2")
	get_pcvar_num(clatter_sound_pcvar) ? menu_additem(wpmenu, "Weapons clatter: \yEnabled", "3") : menu_additem(wpmenu, "Weapons clatter: \rDisabled", "3")
	
	menu_display(id, wpmenu, 0)
	return PLUGIN_HANDLED
}

public menu_h(id, menu, item)
{
	switch (item)
	{
		case 0:
		{
			set_pcvar_num(physics_pcvar, !get_pcvar_num(physics_pcvar))
		}
		
		case 1:
		{
			set_pcvar_num(shootweapons_pcvar, !get_pcvar_num(shootweapons_pcvar))
		}
		
		case 2:
		{
			set_pcvar_num(clatter_sound_pcvar, !get_pcvar_num(clatter_sound_pcvar))
		}
		
		default:
		{
			update_hooks_and_forwards()
			menu_destroy(menu)
			return PLUGIN_HANDLED
		}
	}
	
	menu_destroy(menu)
	wpm(id)
	return PLUGIN_HANDLED
}

public restart()
{
	for (new i; i < sizeof persistant; i++)
	{
		new o
		while ((o = engfunc(EngFunc_FindEntityByString, o, "classname", persistant[i])))
		{
			static Float:origin[3], Float:angles[3]
			pev(o, pev_vuser1, origin)
			pev(o, pev_vuser2, angles)
			set_pev(o, pev_angles, angles)
			set_pev(o, pev_avelocity, Float:{0.0, 0.0, 0.0})
			engfunc(EngFunc_SetOrigin, o, origin)
			engfunc(EngFunc_DropToFloor, o)
		}
	}
}

public spawn_item(ent)
{
	set_pev(ent, pev_movetype, MOVETYPE_BOUNCE)
	set_pev(ent, pev_takedamage, DAMAGE_YES)
	set_pev(ent, pev_health, 100.0)
	
	return HAM_IGNORED
}

public spawn_persistant_item(ent)
{
	set_pev(ent, pev_movetype, MOVETYPE_BOUNCE)
	set_pev(ent, pev_takedamage, DAMAGE_YES)
	set_pev(ent, pev_health, 100.0)
	
	new Float:origin[3], Float:angles[3]
	pev(ent, pev_origin, origin)
	pev(ent, pev_angles, angles)
	set_pev(ent, pev_vuser1, origin)
	set_pev(ent, pev_vuser2, angles)
	
	return HAM_IGNORED
}

public spawn_custom_item(ent)
{
	if (is_custom_ent(ent))
	{
		return spawn_item(ent)
	}
	return HAM_IGNORED
}

public damage_item(ent, inflictor, attacker, Float:damage, damagebits)
{
	if (pev(ent, pev_effects) & EF_NODRAW) return HAM_IGNORED
	
	static Float:ent_v[3], Float:ent_o[3], Float:inflictor_o[3], Float:temp[3]
	pev(ent, pev_velocity, ent_v)
	pev(ent, pev_origin, ent_o)
	pev(inflictor, pev_origin, inflictor_o)
	xs_vec_sub(ent_o, inflictor_o, temp)
	xs_vec_normalize(temp, temp)
	xs_vec_mul_scalar(temp, damage, temp)
	xs_vec_mul_scalar(temp, multiplier, temp)
	xs_vec_add(ent_v, temp, ent_v)
	set_pev(ent, pev_velocity, ent_v)
	
	// Set a random yaw. I would've set random pitch and roll, but then the weapons don't land flat, even with my Lie Flat plugin.
	static Float:av[3]
	//av[0] = random_float(-1000.0, 1000.0)
	av[1] = random_float(-1000.0, 1000.0)
	//av[2] = random_float(-1000.0, 1000.0)
	set_pev(ent, pev_avelocity, av)
	
	SetHamParamFloat(4, 0.0)
	return HAM_HANDLED
}

public damage_custom_item(ent, inflictor, attacker, Float:damage, damagebits)
{
	if (is_custom_ent(ent))
	{
		static Float:ent_v[3], Float:ent_o[3], Float:inflictor_o[3], Float:temp[3]
		pev(ent, pev_velocity, ent_v)
		pev(ent, pev_origin, ent_o)
		pev(inflictor, pev_origin, inflictor_o)
		xs_vec_sub(ent_o, inflictor_o, temp)
		xs_vec_normalize(temp, temp)
		xs_vec_mul_scalar(temp, damage, temp)
		xs_vec_mul_scalar(temp, multiplier, temp)
		xs_vec_add(ent_v, temp, ent_v)
		set_pev(ent, pev_velocity, ent_v)
		
		// Set a random yaw. I would've set random pitch and roll, but then the weapons don't land flat, even with my Lie Flat plugin.
		static Float:av[3]
		av[1] = random_float(-1000.0, 1000.0)
		set_pev(ent, pev_avelocity, av)
		
		SetHamParamFloat(4, 0.0)
		return HAM_HANDLED
	}
	return HAM_IGNORED
}

public touch_item(ent, touched)
{
	if (pev(touched, pev_solid) < SOLID_BBOX) return HAM_IGNORED
	
	if (1 <= touched <= 32) return HAM_IGNORED // Prevents bugginess when someone drops a gun (or in DoD, when a gun gets stuck inside a dead body).
	
	static Float:v[3]
	pev(ent, pev_velocity, v)
	
	if (xs_vec_len(v) > 700.0)
	{
		static Float:origin[3]
		pev(ent, pev_origin, origin)
		origin[0] += random_float(-10.0, 10.0)
		origin[1] += random_float(-10.0, 10.0)
		origin[2] += random_float(-10.0, 10.0)
		draw_spark(origin)
	}
	
	xs_vec_mul_scalar(v, 0.4, v)
	set_pev(ent, pev_velocity, v)
	
	if (get_pcvar_num(clatter_sound_pcvar))
	{
		engfunc(EngFunc_EmitSound, ent, CHAN_WEAPON, BOUNCE, 0.25, ATTN_STATIC, 0, PITCH_NORM)
	}
	
	return HAM_IGNORED
}

public touch_custom_item(ent, touched)
{
	if (is_custom_ent(ent))
	{
		return touch_item(ent, touched)
	}
	return HAM_IGNORED
}

public shoot_item(ent, attacker, Float:damage, Float:direction[3], trace, damagebits)
{
	static Float:endpoint[3]
	get_tr2(trace, TR_vecEndPos, endpoint)
	draw_spark(endpoint)
	
	static Float:velocity[3]
	pev(ent, pev_velocity, velocity)
	
	xs_vec_mul_scalar(direction, damage, direction)
	xs_vec_mul_scalar(direction, multiplier, direction)
	xs_vec_add(direction, velocity, velocity)
	set_pev(ent, pev_velocity, velocity)
	
	engfunc(EngFunc_EmitSound, ent, CHAN_ITEM, RIC, 0.5, ATTN_STATIC, 0, PITCH_NORM)
	
	return HAM_IGNORED
}

public fw_traceline(Float:start[3], Float:end[3], conditions, id, trace)
{
	// Spectators don't need to run this.
	if (!is_user_alive(id)) return FMRES_IGNORED
	
	// If we hit a player, don't bother searching for an item nearby.
	if (is_user_alive(get_tr2(trace, TR_pHit))) return FMRES_IGNORED
	
	static Float:endpt[3], tr = 0, i
	
	get_tr2(trace, TR_vecEndPos, endpt)
	
	i = 0
	
	while ((i = engfunc(EngFunc_FindEntityInSphere, i, endpt, 20.0)))
	{
		if (is_shootable_ent(i))
		{
			engfunc(EngFunc_TraceModel, start, end, HULL_POINT, i, tr)
		
			if (pev_valid(get_tr2(tr, TR_pHit)))
			{
				get_tr2(tr, TR_vecEndPos, endpt)
				set_tr2(trace, TR_vecEndPos, endpt)
				
				set_tr2(trace, TR_pHit, i)
				
				return FMRES_IGNORED
			}
		}
	}
	
	return FMRES_IGNORED
}

public is_shootable_ent(ent)
{
	static classname[32]
	pev(ent, pev_classname, classname, 31)
	
	for (new i; i < sizeof classes; i++)
	{
		if (equal(classname, classes[i]))
		{
			return true
		}
	}
	
	for (new i; i < sizeof persistant; i++)
	{
		if (equal(classname, persistant[i]))
		{
			return true
		}
	}
	
	for (new i; i < sizeof custom_classname; i++)
	{
		if (equal(classname, custom_classname[i]))
		{
			return true
		}
	}
	
	return false
}

public is_custom_ent(ent)
{
	static classname[40]
	pev(ent, pev_classname, classname, 39)
	
	for (new i; i < custom_count; i++)
	{
		if (equal(classname, custom_classname[i]))
		{
			return true
		}
	}
	
	return false
}

stock draw_spark(Float:origin[3])
{
	message_begin(MSG_ALL, SVC_TEMPENTITY)
	write_byte(TE_SPARKS)
	engfunc(EngFunc_WriteCoord, origin[0])
	engfunc(EngFunc_WriteCoord, origin[1])
	engfunc(EngFunc_WriteCoord, origin[2])
	message_end()	
}
