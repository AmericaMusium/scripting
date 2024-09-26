
#include <amxmodx>
#include <amxmisc>
#include <orpheu>
#include <orpheu_memory>

new g_pGameRules;

#define set_mp_pdata(%1,%2)  ( OrpheuMemorySetAtAddress( g_pGameRules, %1, 1, %2 ) )
#define get_mp_pdata(%1)     ( OrpheuMemoryGetAtAddress( g_pGameRules, %1 ) )

public plugin_precache()
{
    OrpheuRegisterHook( OrpheuGetFunction( "InstallGameRules" ), "OnInstallGameRules", OrpheuHookPost );
}

public OnInstallGameRules()
{
    g_pGameRules = OrpheuGetReturn();
}

public plugin_init ()
{
    register_plugin( "Set Team Score", "1.0.0", "Arkshine" );
    register_concmd( "amx_tscore", "ClientCommand_SetTeamScore", ADMIN_RCON, "- <Team> <Score>" );
}

public ClientCommand_SetTeamScore ( const player, const level, const cid )
{
    if ( !cmd_access( player, level, cid, 3 ) )
    {
        return PLUGIN_HANDLED;
    }
    
    new team [ 2 ];
    new score[ 6 ];
    
    read_argv( 1, team , charsmax( team ) );
    read_argv( 2, score, charsmax( score ) );
    
    new signedShort = 32768;
    new scoreToGive = clamp( str_to_num( score ), -signedShort, signedShort );
    
    switch ( team[ 0 ] )
    {
        case 'C', 'c' : 
        {
            set_mp_pdata( "m_iNumCTWins", scoreToGive );
        }
        case 'T', 't' : 
        {
            set_mp_pdata( "m_iNumTerroristWins", scoreToGive );
        }
        case '@' :
        {
            set_mp_pdata( "m_iNumCTWins", scoreToGive );
            set_mp_pdata( "m_iNumTerroristWins", scoreToGive );
        }
        default :
        {
            return PLUGIN_HANDLED;
        }
    }
    
    UpdateTeamScores( .notifyAllPlugins = true );
    
    return PLUGIN_HANDLED;
}   

UpdateTeamScores ( const bool:notifyAllPlugins = false )
{
    static OrpheuFunction:handleFuncUpdateTeamScores;

    if ( !handleFuncUpdateTeamScores )
    {
        handleFuncUpdateTeamScores = OrpheuGetFunction( "UpdateTeamScores", "CHalfLifeMultiplay" )
    }

    ( notifyAllPlugins ) ?

        OrpheuCallSuper( handleFuncUpdateTeamScores, g_pGameRules ) :
        OrpheuCall( handleFuncUpdateTeamScores, g_pGameRules );
}