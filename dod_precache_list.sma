#include <amxmodx>
#include <fakemeta>

#define MAX_PRECACHE    512
#define MAX_FILE_LENGHT    128

new g_iCounter

new g_szPrecachedFiles[MAX_PRECACHE+1][MAX_FILE_LENGHT+1]
new g_szCustomFiles[MAX_PRECACHE+1][MAX_FILE_LENGHT+1]

new g_iForwardsIds[3]

public plugin_precache()
{
    register_plugin("Precache Management", "1.0.0", "ConnorMcLeod")

    g_iForwardsIds[0] = register_forward(FM_PrecacheModel, "Precache_Post", 1)
    g_iForwardsIds[1] = register_forward(FM_PrecacheSound, "Precache_Post", 1)
    g_iForwardsIds[2] = register_forward(FM_PrecacheGeneric, "Precache_Post", 1)
}

public plugin_natives()
{
    register_library("precache")
    register_native("can_precache","native_can_precache")
    register_native("PrecacheModel","native_PrecacheModel")
    register_native("PrecacheSound","native_PrecacheSound")
    register_native("PrecacheGeneric","native_PrecacheGeneric")
}

public plugin_init()
{
    unregister_forward(FM_PrecacheModel, g_iForwardsIds[0], 1)
    unregister_forward(FM_PrecacheSound, g_iForwardsIds[1], 1)
    unregister_forward(FM_PrecacheGeneric, g_iForwardsIds[2], 1)

    new const szLogFile[] = "PrecacheList.log"
    new const szLogFile2[] = "PrecacheListCust.log"
    for(new i=1; i<=MAX_PRECACHE; i++)
    {
        if(g_szPrecachedFiles[i][0])
        {
            log_to_file(szLogFile, "<%d><%s>", i, g_szPrecachedFiles[i])
        }
        if(g_szCustomFiles[i][0])
        {
            log_to_file(szLogFile2, "<%d><%s>", i, g_szCustomFiles[i])
        }
    }
    log_to_file(szLogFile, "%i files precached", g_iCounter)
    pause("ad")
}

public Precache_Post(const szFile[])
{
    static iVal
    iVal = get_orig_retval()
    update_counter(iVal)

    if( !g_szPrecachedFiles[iVal][0] )
    {
        formatex(g_szPrecachedFiles[iVal], MAX_FILE_LENGHT, szFile)
    }
}

update_counter(iVal)
{
    if( iVal > g_iCounter )
    {
        g_iCounter = iVal
        return 1
    }
    return 0
}

public native_can_precache(iPlugin, iParams)
{
    return (g_iCounter < MAX_PRECACHE)
}

public native_PrecacheModel(iPlugin, iParams)
{
    if(iParams != 1)
        return -1

    static szFile[MAX_FILE_LENGHT], iVal
    get_string(1, szFile, MAX_FILE_LENGHT-1)

    iVal = engfunc(EngFunc_PrecacheModel, szFile)

    update_counter( iVal )
    if( !g_szCustomFiles[iVal][0] )
    {
        formatex(g_szCustomFiles[iVal], MAX_FILE_LENGHT, szFile)
    }

    return iVal
}

public native_PrecacheSound(iPlugin, iParams)
{
    if(iParams != 1)
        return -1

    static szFile[MAX_FILE_LENGHT], iVal
    get_string(1, szFile, MAX_FILE_LENGHT-1)

    iVal = engfunc(EngFunc_PrecacheSound, szFile)

    update_counter( iVal )
    if( !g_szCustomFiles[iVal][0] )
    {
        formatex(g_szCustomFiles[iVal], MAX_FILE_LENGHT, szFile)
    }

    return iVal
}

public native_PrecacheGeneric(iPlugin, iParams)
{
    if(iParams != 1)
        return -1

    static szFile[MAX_FILE_LENGHT], iVal
    get_string(1, szFile, MAX_FILE_LENGHT-1)

    iVal = engfunc(EngFunc_PrecacheGeneric, szFile)

    update_counter( iVal )
    if( !g_szCustomFiles[iVal][0] )
    {
        formatex(g_szCustomFiles[iVal], MAX_FILE_LENGHT, szFile)
    }

    return iVal
} 