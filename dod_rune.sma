#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <hamsandwich>

#if AMXX_VERSION_NUM < 183
	#include <colorchat>
#else
	#define DontChange print_team_default
#endif

#pragma semicolon							1

#define PLUGIN_NAME							"[CS] Runes of Quake"
#define PLUGIN_VERS							"0.5"
#define PLUGIN_AUTH							"81x08"

#define IsPlayer(%0)						(%0 && %0 <= g_iMaxPlayers)

#define MAX_PLAYERS							32

#define XO_PLAYER							5
#define PDATA_SAFE							2

#define OFFSET_TEAM							114

#define MsgId_ScreenFade					98

#define TASK_PLAYER_RUNE_EFFECT				100

#if !defined Ham_CS_Player_ResetMaxSpeed
	#define Ham_CS_Player_ResetMaxSpeed		Ham_Item_PreFrame
#endif

// #define RUNE_DEBUG_MODE

#define RUNE_PICK_UP_INFO
#define RUNE_PICK_UP_SCREEN_FADE

#define RUNE_SPAWN_TIME						Float: 300.0

#define RUNE_SET_POS_ACCESS					ADMIN_RCON

#define RUNE_DMG__FACTOR					Float: 2.0
#define RUNE_DMG__TIME_EFFECT				30

#define RUNE_PROTECT__ABSORPTION			30
#define RUNE_PROTECT__TIME_EFFECT			30

#define RUNE_REGEN__HP						20
#define RUNE_REGEN__MAX_HP					50000.0
#define RUNE_REGEN__TIME_EFFECT				11

#define RUNE_INVISE__TIME_EFFECT			20

#define RUNE_SPEED__FACTOR					Float: 2.0
#define RUNE_SPEED__TIME_EFFECT				30

#define RUNE_HUD_INFO_POS					0.65, 0.865
#define RUNE_HUD_INFO_COLOR					38, 97, 156

enum _: ENUM_DATA_POS	{
	POS_X,
	POS_Y,
	POS_Z
};

enum _: ENUM_DATA_RUNE	{
	RUNE_NULL,

	RUNE_DMG,
	RUNE_PROTECT,
	RUNE_REGEN,
	RUNE_INVISE,
	RUNE_SPEED,
	
	RUNE_MAX
};

enum _: ENUM_DATA_RUNE_SETTINGS	{
	bool: RUNE_MODE,
	RUNE_SOUND[64],
	RUNE_COLOR[3],
	RUNE_ALPHA
};

new g_RuneSettings[ENUM_DATA_RUNE][ENUM_DATA_RUNE_SETTINGS] = {
	'^0',
	
	/* [Вкл | Выкл]		[Звук]				     [Цвет ScreenFade] 		[Яркость ScreenFade] */
	{true,			"player/britcover.wav", 			{66,	170,	255},		140},
	{true,			"player/britcover.wav", 		{255,	210,	128},		140},
	{true,			"player/britcover.wav", 	{255,	0,		0},			140},
	{true,			"player/britcover.wav", 		{255,	255,	255},		140},
	{true,			"player/britcover.wav", 			{255,	215,	0},			140},
	
	'^0'
};

new const g_szRuneMdl[] = "models/helmet_allie_para.mdl";
new const g_szEyesMdl[] = "models/helmet_allie_para_med.mdl";

new g_iCountRune,
	g_iMaxPlayers,
	g_iSyncHudRuneInfo,
	g_iArraySizeRunePosition;

new g_bRuneEdit;

new g_szFileDir[128];

new gp_iRune[MAX_PLAYERS + 1 char],
	gp_iRuneTimeEffect[MAX_PLAYERS + 1 char][ENUM_DATA_RUNE];

new gp_iEyesId[MAX_PLAYERS + 1 char];

new Array: g_aRunePosition;

/*================================================================================
 [PLUGIN]
=================================================================================*/
public plugin_precache()	{
	new iRuneCount;
	for(new iCount = RUNE_NULL + 1; iCount < RUNE_MAX; iCount++)	{
		if(g_RuneSettings[iCount][RUNE_MODE])	{
			iRuneCount++;
			precache_sound(g_RuneSettings[iCount][RUNE_SOUND]);
		}
	}
	
	if(iRuneCount)	{
		precache_model(g_szRuneMdl);
		precache_model(g_szEyesMdl);
	} else UTIL_LogToFile("[Warning] All runes have been disabled. The plugin moved into pause mode.");
}

public plugin_init()	{
	/* [PLUGIN] */
	register_plugin(PLUGIN_NAME, PLUGIN_VERS, PLUGIN_AUTH);

	/* [LOGEVENT] */
	// register_logevent("LogEventHook_RoundEnd",		2,	"1=Round_End");
	
	/*
	#if !defined RUNE_SPAWN_TIME
		register_logevent("LogEventHook_RoundStart",	2,	"1=Round_Start");
	#endif
	*/
	// register_logevent("LogEventHook_RestartGame",	2,	"1=Game_Commencing", "1&Restart_Round_");

	/* [ENGINE] */
	// register_touch("rune", "player", "TouchHook_Rune_Player");

	/* [HAMSANDWICH] */
	// RegisterHam(Ham_Killed, "player", "HamHook_Player_Killed_Post", true);
	// RegisterHam(Ham_TraceAttack, "player", "HamHook_Player_TraceAttack_Pre", false);
	// RegisterHam(Ham_CS_Player_ResetMaxSpeed, "player", "HamHook_CS_Player_ResetMaxSpeed", true);

	/* [CLCMD] */
	register_clcmd("say /setrune", "ClCmd_SetPositionRune");
	
	/* [MENUCMD] */
	register_menucmd(register_menuid("Show_SetPositionRune"), MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_0, "Handler_SetPositionRune");
	
	/* [OTHER] */
	g_iMaxPlayers = get_maxplayers();
	// g_iSyncHudRuneInfo = CreateHudSyncObj();
	
	
	/*
	#if defined RUNE_SPAWN_TIME
		set_task(RUNE_SPAWN_TIME, "funcRandomSpawnRune", .flags = "b");
	#endif
	*/
	
	
	// register_dictionary("rune.txt");
}

public plugin_cfg()	{
	g_aRunePosition = ArrayCreate(ENUM_DATA_POS);

	formatex(g_szFileDir, charsmax(g_szFileDir), "addons/amxmodx/configs/rune");

	if(!(dir_exists(g_szFileDir)))
		mkdir(g_szFileDir);
	
	new szMapName[32];
	get_mapname(szMapName, charsmax(szMapName));
	
	formatex(g_szFileDir, charsmax(g_szFileDir), "%s/%s.ini", g_szFileDir, szMapName);
	
	new iFile = fopen(g_szFileDir, "rt");
	if(iFile)	{
		new szBuffer[128], szPosition[ENUM_DATA_POS][6];
		new Float: fPosition[ENUM_DATA_POS];
		
		while(!(feof(iFile)))	{
			fgets(iFile, szBuffer, charsmax(szBuffer));
			trim(szBuffer);
			
			if(!(szBuffer[0]) || szBuffer[0] == ';')
				continue;
			
			parse(szBuffer, szPosition[POS_X], charsmax(szPosition[]), szPosition[POS_Y], charsmax(szPosition[]), szPosition[POS_Z], charsmax(szPosition[]));
			
			fPosition[POS_X] = str_to_float(szPosition[POS_X]);
			fPosition[POS_Y] = str_to_float(szPosition[POS_Y]);
			fPosition[POS_Z] = str_to_float(szPosition[POS_Z]);
			
			ArrayPushArray(g_aRunePosition, fPosition);
		}
		
		fclose(iFile);
		
		g_iArraySizeRunePosition = ArraySize(g_aRunePosition);
	}
}

/*================================================================================
 [CLIENT]
=================================================================================*/
public client_disconnected(pId)	{
	if(gp_iRune[pId])	{
		gp_iRune[pId] = RUNE_NULL;
		
		if(gp_iEyesId[pId])	{
			funcRemoveEnt(gp_iEyesId[pId]);
			gp_iEyesId[pId] = 0;
		}
		
		for(new iCount = RUNE_NULL; iCount < RUNE_MAX; iCount++)
			gp_iRuneTimeEffect[pId][iCount] = 0;

		remove_task(pId + TASK_PLAYER_RUNE_EFFECT);
	}
}

/*================================================================================
 [LOGEVENT]
=================================================================================*/
public LogEventHook_RoundStart()
	funcRandomSpawnRune();

public LogEventHook_RestartGame()
	LogEventHook_RoundEnd();

public LogEventHook_RoundEnd()	{
	for(new iIndex = 1; iIndex <= g_iMaxPlayers; iIndex++)	{
		if(gp_iRune[iIndex])	{
			if(gp_iRune[iIndex] & (1 << RUNE_INVISE))	{
				if(gp_iEyesId[iIndex])	{
					funcRemoveEnt(gp_iEyesId[iIndex]);
					gp_iEyesId[iIndex] = 0;
				}
				
				UTIL_SetPlayerRendering(iIndex, kRenderFxNone, Float: {0.0, 0.0, 0.0}, kRenderNormal, 0.0);
			}
			
			gp_iRune[iIndex] = RUNE_NULL;

			for(new iCount = RUNE_NULL; iCount < RUNE_MAX; iCount++)
				gp_iRuneTimeEffect[iIndex][iCount] = 0;

			remove_task(iIndex + TASK_PLAYER_RUNE_EFFECT);
		}
	}
	
	#if !defined RUNE_SPAWN_TIME
		funcRemoveEnt();
	#endif
}

/*================================================================================
 [ENGINE]
=================================================================================*/
/*
public TouchHook_Rune_Player(const eId, const pId)	{
	new iRune = entity_get_int(eId, EV_INT_iuser1);
	
	if(gp_iRune[pId] == RUNE_NULL)
		set_task(1.0, "taskPlayerRuneEffect", pId + TASK_PLAYER_RUNE_EFFECT, .flags = "b");

	gp_iRune[pId] |= (1 << iRune);
	
	switch(iRune)	{
		case RUNE_DMG:	{
			gp_iRuneTimeEffect[pId][RUNE_DMG] += RUNE_DMG__TIME_EFFECT;
			
			#if defined RUNE_PICK_UP_INFO
				client_print_color(pId, DontChange, "%L", pId, "ROQ_TAKE_RUNE_DMG", RUNE_DMG__FACTOR, RUNE_DMG__TIME_EFFECT);
			#endif
		}
		case RUNE_PROTECT:	{
			gp_iRuneTimeEffect[pId][RUNE_PROTECT] += RUNE_PROTECT__TIME_EFFECT;
			
			#if defined RUNE_PICK_UP_INFO
				client_print_color(pId, DontChange, "%L", pId, "ROQ_TAKE_RUNE_PROTECT", RUNE_PROTECT__ABSORPTION, RUNE_PROTECT__TIME_EFFECT);
			#endif
		}
		case RUNE_REGEN:	{
			gp_iRuneTimeEffect[pId][RUNE_REGEN] += RUNE_REGEN__TIME_EFFECT;
			
			#if defined RUNE_PICK_UP_INFO
				client_print_color(pId, DontChange, "%L", pId, "ROQ_TAKE_RUNE_REGEN", RUNE_REGEN__HP, RUNE_REGEN__TIME_EFFECT);
			#endif
		}
		case RUNE_INVISE: {
			gp_iRuneTimeEffect[pId][RUNE_INVISE] += RUNE_INVISE__TIME_EFFECT;
			
			UTIL_SetPlayerRendering(pId, kRenderFxGlowShell, Float: {0.0, 0.0, 0.0}, kRenderTransAlpha, 0.0);
			
			#if defined RUNE_PICK_UP_INFO
				client_print_color(pId, DontChange, "%L", pId, "ROQ_TAKE_RUNE_INVISE", RUNE_INVISE__TIME_EFFECT);
			#endif
			
			if(!(gp_iEyesId[pId]))	{
				gp_iEyesId[pId] = create_entity("func_wall");
				if(is_valid_ent(gp_iEyesId[pId]))	{
					entity_set_model(gp_iEyesId[pId], g_szEyesMdl);
					
					entity_set_edict(gp_iEyesId[pId], EV_ENT_aiment, pId);
					
					if(pev_valid(pId) == PDATA_SAFE)
						entity_set_int(gp_iEyesId[pId], EV_INT_body, get_pdata_int(pId, OFFSET_TEAM, XO_PLAYER) + 1);

					entity_set_int(gp_iEyesId[pId], EV_INT_sequence, 0);
					entity_set_int(gp_iEyesId[pId], EV_INT_movetype, MOVETYPE_FOLLOW);
				}
			}
		}
		case RUNE_SPEED: {
			gp_iRuneTimeEffect[pId][RUNE_SPEED] += RUNE_SPEED__TIME_EFFECT;

			ExecuteHamB(Ham_CS_Player_ResetMaxSpeed, pId);
			
			#if defined RUNE_PICK_UP_INFO
				client_print_color(pId, DontChange, "%L", pId, "ROQ_TAKE_RUNE_SPEED", RUNE_SPEED__FACTOR, RUNE_SPEED__TIME_EFFECT);
			#endif
		}
	}

	#if defined RUNE_PICK_UP_SCREEN_FADE
		UTIL_ScreenFade(pId, (1<<12), (1<<12), 0, g_RuneSettings[iRune][RUNE_COLOR][0], g_RuneSettings[iRune][RUNE_COLOR][1], g_RuneSettings[iRune][RUNE_COLOR][2], g_RuneSettings[iRune][RUNE_ALPHA]);
	#endif
	
	client_cmd(pId, "stopsound");
	client_cmd(pId, "spk %s", g_RuneSettings[iRune][RUNE_SOUND]);
	
	remove_entity(eId);
}
*/


/*================================================================================
 [HAMSANDWICH]
=================================================================================*/
/*
public HamHook_Player_Killed_Post(const vId, const aId)	{
	if(gp_iRune[vId])	{
		if(gp_iRune[vId] & (1 << RUNE_INVISE))	{
			if(gp_iEyesId[vId])	{
				funcRemoveEnt(gp_iEyesId[vId]);
				gp_iEyesId[vId] = 0;
			}
			
			UTIL_SetPlayerRendering(vId, kRenderFxNone, Float: {0.0, 0.0, 0.0}, kRenderNormal, 0.0);
		}

		gp_iRune[vId] = RUNE_NULL;

		for(new iCount = RUNE_NULL; iCount < RUNE_MAX; iCount++)
			gp_iRuneTimeEffect[vId][iCount] = 0;

		remove_task(vId + TASK_PLAYER_RUNE_EFFECT);
	}
}

public HamHook_Player_TraceAttack_Pre(const vId, const aId, Float: fDamage, const Float: fDeriction[3], const iTraceHandle, const iBitDamage)	{
	if(IsPlayer(aId) && vId != aId)	{
		if(gp_iRune[aId] & (1 << RUNE_DMG))
			SetHamParamFloat(3, fDamage * RUNE_DMG__FACTOR);
		
		if(gp_iRune[vId] & (1 << RUNE_PROTECT) && iBitDamage & DMG_ACID|DMG_SONIC|DMG_SHOCK|DMG_DROWN|DMG_NERVEGAS|DMG_RADIATION|DMG_SLOWBURN|DMG_SLOWFREEZE|DMG_ENERGYBEAM)
			SetHamParamFloat(3, (fDamage * RUNE_PROTECT__ABSORPTION) / 100);
	}
	
	return HAM_IGNORED;
}

public HamHook_CS_Player_ResetMaxSpeed(const pId)	{
	if(gp_iRune[pId] & (1 << RUNE_SPEED))
		entity_set_float(pId, EV_FL_maxspeed, entity_get_float(pId, EV_FL_maxspeed) * RUNE_SPEED__FACTOR);
	
	return HAM_IGNORED;
}
*/


/*================================================================================
 [CLCMD]
=================================================================================*/
public ClCmd_SetPositionRune(const pId)
	return (get_user_flags(pId) & RUNE_SET_POS_ACCESS) ? Show_SetPositionRune(pId) : PLUGIN_HANDLED;

/*================================================================================
 [MENUCMD]
=================================================================================*/
Show_SetPositionRune(const pId)	{
	new szMenu[360], iBitKeys = MENU_KEY_1|MENU_KEY_5|MENU_KEY_0;
	new iLen = formatex(szMenu, charsmax(szMenu), "\y[Rune] \wНастройка позиций \d| Всего позиций \r[ %s%d \r]^n^n", g_iArraySizeRunePosition ? "\y" : "\d", g_iArraySizeRunePosition);

	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \wРежим \r[ \d%s \r]^n^n", g_bRuneEdit ? "Редактирование" : "Игровой");
	
	if(g_bRuneEdit)	{
		iBitKeys |= MENU_KEY_2;
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \wПоставить позицию^n");
		
		if(g_iArraySizeRunePosition)	{
			iBitKeys |= MENU_KEY_3|MENU_KEY_4;
			
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3] \wУдалить все позиции^n");
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[4] \wУдалить руну под прицелом^n^n");
		} else {
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3] \dУдалить все позиции^n");
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[4] \dУдалить руну под прицелом^n^n");
		}
	} else {
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \dПоставить позицию^n");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3] \dУдалить все позиции^n");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[4] \dУдалить руну под прицелом^n^n");
	}

	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[5] \wСохранить позиции^n^n^n");

	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[0] \wВыход");

	return show_menu(pId, iBitKeys, szMenu, -1, "Show_SetPositionRune");
}

public Handler_SetPositionRune(const pId, const iKey)	{
	switch(iKey)	{
		case 0: {
			g_bRuneEdit = !g_bRuneEdit;

			new eId = FM_NULLENT;
			while((eId = find_ent_by_class(eId, "rune")))	{
				entity_set_int(eId, EV_INT_solid, g_bRuneEdit ? SOLID_BBOX : SOLID_TRIGGER);
				entity_set_size(eId, Float:{-20.5, -20.5, 0.0}, Float:{20.5, 20.5, 60.5});
			}
		}
		case 1:	{
			new Float: fOrigin[3];
			UTIL_GetAimingPosition(pId, fOrigin);

			g_iArraySizeRunePosition++;
			ArrayPushArray(g_aRunePosition, fOrigin);

			funcCreateRune(fOrigin, false);
		}
		case 2:	{
			funcRemoveEnt();
			ArrayClear(g_aRunePosition);

			g_iArraySizeRunePosition = 0;
		}
		case 3:	{
			new eId, iBody;
			get_user_aiming(pId, eId, iBody);
			
			new szClassName[6];
			entity_get_string(eId, EV_SZ_classname, szClassName, charsmax(szClassName));
			
			if(is_valid_ent(eId) && equal(szClassName, "rune"))	{
				new eIdIndex = entity_get_int(eId, EV_INT_iuser2);

				new eIdObject = FM_NULLENT, eIdObjectIndex;
				while((eIdObject = find_ent_by_class(eIdObject, "rune")))	{
					eIdObjectIndex = entity_get_int(eIdObject, EV_INT_iuser2);
					if(eIdObjectIndex > eIdIndex)
						entity_set_int(eIdObject, EV_INT_iuser2, eIdObjectIndex - 1);
				}

				g_iCountRune--;
				g_iArraySizeRunePosition--;

				funcRemoveEnt(eId);
				ArrayDeleteItem(g_aRunePosition, eIdIndex);
			}
		}
		case 4:	{
			delete_file(g_szFileDir);

			new szBuffer[128];
			new Float: fOrigin[ENUM_DATA_POS];

			for(new iObject = 0; iObject < g_iArraySizeRunePosition; iObject++)	{
				ArrayGetArray(g_aRunePosition, iObject, fOrigin);

				formatex(szBuffer, charsmax(szBuffer), "^"%.f^" ^"%.f^" ^"%.f^"", fOrigin[0], fOrigin[1], fOrigin[2]);
				write_file(g_szFileDir, szBuffer, -1);
			}
		}
		case 9: return PLUGIN_HANDLED;
	}
	
	return Show_SetPositionRune(pId);
}

/*================================================================================
 [TASK]
=================================================================================*/

/*
public taskPlayerRuneEffect(pId)	{
	pId -= TASK_PLAYER_RUNE_EFFECT;

	new szRuneInfo[ENUM_DATA_RUNE][64];

	switch(gp_iRune[pId])	{
		case RUNE_NULL:	{
			remove_task(pId + TASK_PLAYER_RUNE_EFFECT);
			
			return PLUGIN_HANDLED;
		}
		default:	{
			if(gp_iRune[pId] & (1 << RUNE_DMG))	{
				formatex(szRuneInfo[RUNE_DMG], charsmax(szRuneInfo[]), "%L", pId, "ROQ_HUD_INFO_RUNE_DMG", gp_iRuneTimeEffect[pId][RUNE_DMG]);
				if(--gp_iRuneTimeEffect[pId][RUNE_DMG] <= 0)
					gp_iRune[pId] &= ~(1 << RUNE_DMG);
			}
			if(gp_iRune[pId] & (1 << RUNE_PROTECT))	{
				formatex(szRuneInfo[RUNE_PROTECT], charsmax(szRuneInfo[]), "%L", pId, "ROQ_HUD_INFO_RUNE_PROTECT", gp_iRuneTimeEffect[pId][RUNE_PROTECT]);
				if(--gp_iRuneTimeEffect[pId][RUNE_PROTECT] <= 0)
					gp_iRune[pId] &= ~(1 << RUNE_PROTECT);
			}
			
			if(gp_iRune[pId] & (1 << RUNE_REGEN))	{
				formatex(szRuneInfo[RUNE_REGEN], charsmax(szRuneInfo[]), "%L", pId, "ROQ_HUD_INFO_RUNE_REGEN", gp_iRuneTimeEffect[pId][RUNE_REGEN]);
				if(--gp_iRuneTimeEffect[pId][RUNE_REGEN] <= 0)
					gp_iRune[pId] &= ~(1 << RUNE_REGEN);
				else {
					static Float: fHealth; fHealth = entity_get_float(pId, EV_FL_health) + RUNE_REGEN__HP;
					fHealth > RUNE_REGEN__MAX_HP ? entity_set_float(pId, EV_FL_health, RUNE_REGEN__MAX_HP) : entity_set_float(pId, EV_FL_health, fHealth);
				}
			}

			if(gp_iRune[pId] & (1 << RUNE_INVISE))	{
				formatex(szRuneInfo[RUNE_INVISE], charsmax(szRuneInfo[]), "%L", pId, "ROQ_HUD_INFO_RUNE_INVISE", gp_iRuneTimeEffect[pId][RUNE_INVISE]);
				if(--gp_iRuneTimeEffect[pId][RUNE_INVISE] <= 0)	{
					gp_iRune[pId] &= ~(1 << RUNE_INVISE);
					
					if(gp_iEyesId[pId])	{
						funcRemoveEnt(gp_iEyesId[pId]);
						gp_iEyesId[pId] = 0;
					}
					
					UTIL_SetPlayerRendering(pId, kRenderFxNone, Float: {0.0, 0.0, 0.0}, kRenderNormal, 0.0);
				}
			}
			
			if(gp_iRune[pId] & (1 << RUNE_SPEED))	{
				formatex(szRuneInfo[RUNE_SPEED], charsmax(szRuneInfo[]), "%L", pId, "ROQ_HUD_INFO_RUNE_SPEED", gp_iRuneTimeEffect[pId][RUNE_SPEED]);
				if(--gp_iRuneTimeEffect[pId][RUNE_SPEED] <= 0)	{
					gp_iRune[pId] &= ~(1 << RUNE_SPEED);
					
					ExecuteHamB(Ham_CS_Player_ResetMaxSpeed, pId);
				}
			}
		}
	}

	set_hudmessage(RUNE_HUD_INFO_COLOR, RUNE_HUD_INFO_POS, 0, 0.0, 0.8, 0.2, 0.2, -1);
	ShowSyncHudMsg(pId, g_iSyncHudRuneInfo, "%L%s%s%s%s%s", pId, "ROQ_HUD_INFO_RUNE_TITLE", szRuneInfo[RUNE_DMG], szRuneInfo[RUNE_SPEED], szRuneInfo[RUNE_PROTECT], szRuneInfo[RUNE_REGEN], szRuneInfo[RUNE_INVISE]);

	return PLUGIN_HANDLED;
}
*/


/*================================================================================
 [STOCK]
=================================================================================*/
public funcRandomSpawnRune()	{
	if(!(g_iArraySizeRunePosition))
		return PLUGIN_HANDLED;
	
	funcRemoveEnt();

	new Array: aRuneRandomPos = ArrayCreate(ENUM_DATA_POS);
	for(new iCount = 0, Float: fOrigin[ENUM_DATA_POS]; iCount < g_iArraySizeRunePosition; iCount++)	{
		ArrayGetArray(g_aRunePosition, iCount, fOrigin);
		ArrayPushArray(aRuneRandomPos, fOrigin);
	}

	#if defined RUNE_DEBUG_MODE
		log_amx("============================");
	#endif

	for(new iCount = 0, iRandomPos = 0, Float: fOrigin[ENUM_DATA_POS]; iCount < g_iArraySizeRunePosition; iCount++)	{
		iRandomPos = random(ArraySize(aRuneRandomPos));
		ArrayGetArray(aRuneRandomPos, iRandomPos, fOrigin);
		ArrayDeleteItem(aRuneRandomPos, iRandomPos);
		
		#if defined RUNE_DEBUG_MODE
			log_amx("[Rune - %d] - [%f] [%f] [%f]", iCount, fOrigin[0], fOrigin[1], fOrigin[2]);
		#endif
		
		funcCreateRune(fOrigin);
	}
	
	ArrayDestroy(aRuneRandomPos);
	
	return PLUGIN_HANDLED;
}

static stock funcCreateRune(const Float: fOrigin[3], const bool: bRandom = true)	{
	new eId = create_entity("info_target");
	if(is_valid_ent(eId))	{
		entity_set_origin(eId, fOrigin);
		entity_set_model(eId, g_szRuneMdl);

		new iRuneRandom;
		do iRuneRandom = random_num(RUNE_NULL + 1, RUNE_MAX - 1);
		while (!(g_RuneSettings[iRuneRandom][RUNE_MODE]));

		entity_set_int(eId, EV_INT_body, iRuneRandom);
		entity_set_int(eId, EV_INT_iuser1, iRuneRandom);
		entity_set_int(eId, EV_INT_iuser2, g_iCountRune);
		entity_set_int(eId, EV_INT_solid, g_bRuneEdit ? SOLID_BBOX : SOLID_TRIGGER);
		
		entity_set_float(eId, EV_FL_framerate, 1.0);
		
		entity_set_string(eId, EV_SZ_classname, "rune");
		
		entity_set_size(eId, Float:{-20.5, -20.5, 0.0}, Float:{20.5, 20.5, 60.5});

		drop_to_floor(eId);
		
		if(bRandom) ArraySetArray(g_aRunePosition, g_iCountRune, fOrigin);
		
		g_iCountRune++;
	}
}

static stock funcRemoveEnt(eId = FM_NULLENT)	{
	if(eId != -1) entity_set_int(eId, EV_INT_flags, entity_get_int(eId, EV_INT_flags) | FL_KILLME);
	else {
 		g_iCountRune = 0;
		
		while((eId = find_ent_by_class(eId, "rune")))
			entity_set_int(eId, EV_INT_flags, entity_get_int(eId, EV_INT_flags) | FL_KILLME);
	}
}



/*================================================================================
 [UTIL]
=================================================================================*/
static stock UTIL_ScreenFade(const pId, const iDuration, const iHoldTime, const iFlags, const iRed, const iBlue, const iGreen, const iAlpha, const iReliable = 0)	{
	message_begin(iReliable ? MSG_ONE : MSG_ONE_UNRELIABLE, MsgId_ScreenFade, .player = pId);
	{
		write_short(iDuration);
		write_short(iHoldTime);
		write_short(iFlags);
		write_byte(iRed);
		write_byte(iBlue);
		write_byte(iGreen);
		write_byte(iAlpha);
	}

	message_end();
}

static stock UTIL_GetAimingPosition(const pId, const Float: fReturn[3])	{
	new Float: fVecStart[3], Float: fVecEnd[3];
	
	entity_get_vector(pId, EV_VEC_origin, fVecStart);
	entity_get_vector(pId, EV_VEC_view_ofs, fVecEnd);
	
	fVecStart[0] += fVecEnd[0];
	fVecStart[1] += fVecEnd[1];
	fVecStart[2] += fVecEnd[2];
	
	entity_get_vector(pId, EV_VEC_v_angle, fVecEnd);

	engfunc(EngFunc_MakeVectors, fVecEnd);
	global_get(glb_v_forward, fVecEnd);

	fVecEnd[0] = fVecStart[0] + fVecEnd[0] * 8192.0;
	fVecEnd[1] = fVecStart[1] + fVecEnd[1] * 8192.0;
	fVecEnd[2] = fVecStart[2] + fVecEnd[2] * 8192.0;

	engfunc(EngFunc_TraceLine, fVecStart, fVecEnd, DONT_IGNORE_MONSTERS, pId, 0);
	get_tr2(0, TR_vecEndPos, fReturn);
}

static stock UTIL_SetPlayerRendering(const pId, const iRenderFx, const Float: fColor[3], const iRenderMode, const Float: fRenderAmt)	{
	entity_set_int(pId, EV_INT_renderfx, iRenderFx);

	entity_set_vector(pId, EV_VEC_rendercolor, fColor);
	
	entity_set_int(pId, EV_INT_rendermode, iRenderMode);
	
	entity_set_float(pId, EV_FL_renderamt, fRenderAmt);
}

static stock UTIL_LogToFile(const szError[], any:...)	{
	new szLog[64], szData[24];
	get_time("roq_error_%Y%m%d.log", szData, charsmax(szData));
	formatex(szLog, charsmax(szLog), "addons/amxmodx/logs/%s", szData);
	log_to_file(szLog, szError);
	
	pause("ad");
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1049\\ f0\\ fs16 \n\\ par }
*/
