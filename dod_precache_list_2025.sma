#include <amxmodx>
#include <amxmisc>
#include <precache_list>

#define PLUGIN "[Resources Manager] Precacher / UnPrecacher"
#define AUTHOR "Shadows Adi"

// file amxmodx\configs\unprecache_list
new Array:g_aResources
new g_iPrecachedNum[rt_max]

new Array:g_aUnprecached
new g_szConfigsDir[128]

public plugin_init()
{
	register_cvar("precache_list_reapi", VERSION + " " + AUTHOR, FCVAR_SERVER|FCVAR_EXTDLL|FCVAR_UNLOGGED|FCVAR_SPONLY)
	register_plugin(PLUGIN, VERSION, AUTHOR)
}

public plugin_precache()
{	
	g_aResources = ArrayCreate(Data)
	g_aUnprecached = ArrayCreate(FileData)

	ReadFile()

	RegisterHookChain(RH_SV_AddResource, "RH_SV_AddResource_Pre")
	RegisterHookChain(RH_SV_AddResource, "RH_SV_AddResource_Post", 1)
}

public plugin_natives()
{
	register_library("precache_list")

	register_native("precache_get_item", "native_get_item")
	register_native("precache_get_size", "native_get_size")
	register_native("is_resource_precached", "native_resource_precached")
	register_native("is_resource_unprecached", "native_resource_unprecached")
	register_native("unprecache_resource", "native_unprecache_resource")
}

public plugin_end()
{
	ArrayDestroy(g_aResources)
	ArrayDestroy(g_aUnprecached)
}

ReadFile()
{
	get_configsdir(g_szConfigsDir, charsmax(g_szConfigsDir))
	format(g_szConfigsDir, charsmax(g_szConfigsDir), "%s/unprecache_list.ini", g_szConfigsDir)
	server_print("test: %s", g_szConfigsDir)

	if (!file_exists(g_szConfigsDir))
		set_fail_state("^"%s^" File not found: ...%s", PLUGIN, g_szConfigsDir)

	new iFile = fopen(g_szConfigsDir, "rt")
	new iLine = 0
	new szBuffer[MAX_RESOURCE_SIZE]
	new szTemp[FileData], szTempInfo[4]

	if (!iFile)
		set_fail_state("^"%s^" Could not open file %s.", PLUGIN, g_szConfigsDir)

	while (!feof(iFile))
	{
		fgets(iFile, szBuffer, charsmax(szBuffer))

		trim(szBuffer)
		iLine += 1

		if(szBuffer[0] == EOS || szBuffer[0] == ';' || szBuffer[0] == '#' || !szBuffer[0])
			continue

		if(parse(szBuffer, szTemp[ResourceName], charsmax(szTemp[ResourceName]), szTempInfo, charsmax(szTempInfo), szTemp[NewResource], charsmax(szTemp[NewResource])) < 2)
		{
			log_to_file("unprecache_list.log", "A problem has been detected inside %s. Line: %d", g_szConfigsDir, iLine)
			continue
		}

		szTemp[TypeResource] = str_to_num(szTempInfo)

		ArrayPushArray(g_aUnprecached, szTemp)
	}

	fclose(iFile)
}

public RH_SV_AddResource_Pre(ResourceType_t:rtType, szResource[], iSize, iFlags, id)
{
	if(szResource[0] == EOS || !szResource[0])
		return HC_CONTINUE

	switch(CheckResource(szResource))
	{
		case REPLACE:
		{
			SetHookChainArg(2, ATYPE_STRING, szResource)

			return HC_CONTINUE
		}
		case REMOVE:
		{
			return HC_SUPERCEDE
		}
	}

	return HC_CONTINUE
}

public RH_SV_AddResource_Post(ResourceType_t:rtType, const szResource[], iSize, iFlags, id)
{
	IndexResource(szResource, rtType, iSize, iFlags, id)
}

IndexResource(const szResource[], ResourceType_t:rtType, iSize, iFlags, id)
{
	new eTemp[Data]

	copy(eTemp[Resource], MAX_RESOURCE_SIZE, szResource)
	eTemp[Type] = rtType
	eTemp[Size] = iSize
	eTemp[Flags] = iFlags
	eTemp[Index] = id

	g_iPrecachedNum[rtType]++

	ArrayPushArray(g_aResources, eTemp)
}

CheckResource(szResource[])
{
	new szTemp[FileData]

	for(new i; i < ArraySize(g_aUnprecached); i++)
	{
		ArrayGetArray(g_aUnprecached, i, szTemp)

		switch(szTemp[TypeResource])
		{
			case REPLACE:
			{
				if(equali(szResource, szTemp[ResourceName]))
				{
					copy(szResource, MAX_RESOURCE_SIZE, szTemp[NewResource])

					return REPLACE
				}
			}
			case REMOVE:
			{
				if(equali(szResource, szTemp[ResourceName]))
					return REMOVE
			}
		}
	}

	return -1
}

// native precache_get_item(iID, szResource[], iLen, ResourceType_t:rtType)
public native_get_item(iPluginID, iParamNum)
{
	if(iParamNum != 4)
	{
		log_error(AMX_ERR_NATIVE, "^"%s^" Incorrect param num. Valid: iID, szResource[], iLen, rtType", PLUGIN)
		return -1
	}

	new eTemp[Data]
	new iID = get_param(1)
	new iLen = get_param(3)

	ArrayGetArray(g_aResources, iID, eTemp)

	set_string(2, eTemp[Resource], iLen)
	return 1
}

// native precache_get_size(iType)
public native_get_size(iPluginID, iParamNum)
{
	new ResourceType_t:iType = ResourceType_t:get_param(1)
	if(iType < t_sound || iType > rt_max)
	{
		log_error(AMX_ERR_NATIVE, "^"%s^" Incorrect param value. Min(%d) | Max(%d)", PLUGIN, t_sound, rt_max)
		return -1
	}

	return g_iPrecachedNum[iType]
}

// native is_resource_precached(szItem[], ResourceType_t:rType)
public native_resource_precached(iPluginID, iParamNum)
{
	if(iParamNum != 2)
	{
		log_error(AMX_ERR_NATIVE, "^"%s^" Incorrect param num. Valid: szItem[], rType", PLUGIN)
		return false
	}

	new szResource[MAX_RESOURCE_SIZE]
	new ResourceType_t:iType = ResourceType_t:get_param(2)

	get_string(1, szResource, charsmax(szResource))

	if(iType < t_sound || iType > rt_max)
	{
		log_error(AMX_ERR_NATIVE, "^"%s^" Incorrect param value. Min(%d) | Max(%d)", PLUGIN, t_sound, rt_max)
		return -1
	}

	new szTemp[Data]

	for(new i; i < ArraySize(g_aResources); i++)
	{
		ArrayGetArray(g_aResources, i, szTemp)

		if(equali(szTemp[Resource], szResource) && szTemp[Type] == iType)
		{
			return true
		}
	}

	return false
}

// native is_resource_unprecached(szItem[])
public native_resource_unprecached(iPluginID, iParamNum)
{
	if(iParamNum != 1)
	{
		log_error(AMX_ERR_NATIVE, "^"%s^" Incorrect param num. Valid: szItem[] rType", PLUGIN)
		return false
	}

	new szResource[MAX_RESOURCE_SIZE]
	get_string(1, szResource, charsmax(szResource))

	new eTemp[FileData]

	for(new i; i < ArraySize(g_aUnprecached); i++)
	{
		ArrayGetArray(g_aUnprecached, i, eTemp)

		if(equali(eTemp[ResourceName], szResource, strlen(szResource)))
		{
			return true
		}
	}

	return false
}

// native bool:unprecache_resource(szResource[], iType, bool:ForceChange, szNewResource[] = "")
public native_unprecache_resource(iPluginID, iParamNum)
{
	if(iParamNum < 3 || iParamNum > 4)
	{
		log_error(AMX_ERR_NATIVE, "^"%s^" Incorrect param value. szResource[], iType, bForceChange, szNewResource[] ( optional )")
		return false
	}

	new szResource[MAX_RESOURCE_SIZE]
	new iType
	new szNewResource[MAX_RESOURCE_SIZE]
	new iForceChange
	new bool:bSuccess = false

	get_string(1, szResource, charsmax(szResource))
	iType = get_param(2)
	iForceChange = get_param(3)
	get_string(4, szNewResource, charsmax(szNewResource))

	new iFile = fopen(g_szConfigsDir, "at")

	if(iFile)
	{
		new szTemp[MAX_RESOURCE_SIZE * 2 + 28]
		formatex(szTemp, charsmax(szTemp), "^n^"%s^" ^"%d^" ^"%s^"", szResource, iType, (szNewResource[0] != EOS ? szNewResource : ""))
		bSuccess = (fputs(iFile, szTemp)) == 0 ? true : false
	}

	fclose(iFile)

	if(iForceChange && bSuccess)
	{
		new szMapName[32]
		get_mapname(szMapName, charsmax(szMapName))
		server_cmd("changelevel ^"%s^"", szMapName)
	}

	return bSuccess
}