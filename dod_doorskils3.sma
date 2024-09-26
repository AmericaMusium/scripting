
/* - AMX Mod X Script ------------------------------------------- *

 *  Breakable Doors
 *  (c) Copyright 2003-2004, written by Ryan
 *
 *  This plugin allows doors that use the func_door_rotating entity
 *  to be destroyed with a grenade in Counter-Strike. This is
 *  compatible with all official CS maps, and written to be
 *  compatible with custom maps as well.
 *
 *  Current Version: 1.1
 *
 *  Changelog:
 *  ---------
 *  - AMXX Support!
 *
 *  Future Plans:
 *  ------------
 *  - Breakable sliding doors
 *  - Door health           ( dependant on door 'material' )
 *  - Dynamic door gibs     ( dependant on door 'material' )
 *
 *
 *  CVARS:
 *  -----
 *  mp_breakabledoors <1|0> - enable/disable plugin
 *
 *  Enjoy!

 * -------------------------------------------------------------- */


#include <amxmodx>
#include <engine>


/* -------------------------------------------------------------- */


// Configuration

#define MAX_DOORS              32       // Maximum doors to store
#define EXPLOSION_MAXRANGE    2.5

// Reference

#define AXIS_X                  0
#define AXIS_Y                  1
#define AXIS_Z                  2

#define DOOR_ENT                0
#define DOOR_TYPE               1

#define FUNC_DOOR_ROTATING      0
#define FUNC_DOOR               1

// Globals

new DOOR_GIBS;                          // Model Index

new g_iTotalDoors;
new g_Doors[MAX_DOORS][2];

new Float:g_vDoorOrigins[MAX_DOORS][3];

new bool:g_bDoorBroken[MAX_DOORS];
new bool:g_bBreakHint[33];


/* - Events ----------------------------------------------------- */


// Buy Grenade

public on_BuyGrenade( id )
{
    if ( !get_cvar_num( "mp_breakabledoors" ) )
        return PLUGIN_CONTINUE;


    if ( g_iTotalDoors > 0 && !g_bBreakHint[id] )
    {
        client_print( id,print_chat,"* Grenades will destroy doors if they are close enough!" );
        g_bBreakHint[id] = true;
    }

    return PLUGIN_CONTINUE;
}


// Grenade Explosion

public on_Explosion() {

    if ( !get_cvar_num( "mp_breakabledoors" ) )
        return PLUGIN_CONTINUE;


    // GRENADE EXPLOSION
    // read_data(1) = 3     (TE_EXPLOSION)
    // read_data(6) = 25    (scale in 0.1's)

    new Float:vExplosion[3];
    vExplosion[0] = float( read_data( 2 ) );
    vExplosion[1] = float( read_data( 3 ) );
    vExplosion[2] = float( read_data( 4 ) );

    for ( new i = 0; i < g_iTotalDoors; i++ )
    {
        // Check if explosion in range of door(s)

        if ( vector_distance( g_vDoorOrigins[i], vExplosion ) / 40.0 <= EXPLOSION_MAXRANGE && !g_bDoorBroken[i] )
        {
            new DoorEnt = g_Doors[i][DOOR_ENT];

            // Rotating doors

            if ( g_Doors[i][DOOR_TYPE] == FUNC_DOOR_ROTATING )
            {
                new Float:vNewOrigin[3];
                vNewOrigin[0] = g_vDoorOrigins[i][0];
                vNewOrigin[1] = g_vDoorOrigins[i][1];
                vNewOrigin[2] = g_vDoorOrigins[i][2] + 2000;

                // Find point near map edge

                while ( PointContents( vNewOrigin ) == CONTENTS_SOLID && vNewOrigin[AXIS_Z] != g_vDoorOrigins[i][AXIS_Z] )
                    vNewOrigin[AXIS_Z] -= 25.0;

                // Move door just outside map edge

                vNewOrigin[AXIS_Z] += 300.0;
                entity_set_origin( DoorEnt, vNewOrigin );

                // Make door invisible

                set_entity_visibility( DoorEnt, 0 );

                // Draw effects

                door_effect( g_vDoorOrigins[i] );
                g_bDoorBroken[i] = true;
            }

            // Sliding doors

            else if ( g_Doors[i][DOOR_TYPE] == FUNC_DOOR )
            {
                /* CURRENTLY NO SUPPORT
                   NEED *WORKING* GET_KEYVALUE() FIRST */
            }
        }
    }

    return PLUGIN_CONTINUE;
}


// Round End Events

public on_Log_World() {

    if ( !get_cvar_num( "mp_breakabledoors" ) )
        return PLUGIN_CONTINUE;


    new szLogAction[64];
    read_logargv( 1, szLogAction, 63 );

    // Round End

    if ( equali( szLogAction, "Round_End" ) )
    {
        set_task( 5.0, "_door_restore" );
    }

    // Round Restart

    else if ( containi( szLogAction, "Restart_Round_" ) != -1 )
    {
        new szRestart[3];
        copy( szRestart, 2, szLogAction[15] );  // Duration starts at 15th char

        // Remove "_"

        if ( containi( szRestart, "_" ) != -1 )
            copy( szRestart, 1, szRestart );

        new iRestart = str_to_num( szRestart );
        new Float:fRestart = float( iRestart );

        set_task( fRestart, "_door_restore" ); 
    }

    // Game Commencing

    else if ( equali( szLogAction, "Game_Commencing" ) )
    {
        set_task( 3.0, "_door_restore" );
    }

    return PLUGIN_CONTINUE;
}



/* - Other Functions -------------------------------------------- */


// Restore Broken Doors

public _door_restore() {

    if ( !get_cvar_num( "mp_breakabledoors" ) )
        return PLUGIN_CONTINUE;


    for ( new i = 0; i < g_iTotalDoors; i++ )
    {
        new DoorEnt = g_Doors[i][DOOR_ENT];

        if ( g_bDoorBroken[i] && g_Doors[i][DOOR_TYPE] == FUNC_DOOR_ROTATING )
        {
            // Make visible

            set_entity_visibility( DoorEnt, 1 );

            // Reset position

            entity_set_origin( DoorEnt, g_vDoorOrigins[i] );

            g_bDoorBroken[i] = false;
        }

        else if ( g_bDoorBroken[i] && g_Doors[i][DOOR_TYPE] == FUNC_DOOR )
        {
            /* CURRENTLY NO SUPPORT
               NEED *WORKING* GET_KEYVALUE() FIRST */
        }
    }

    return PLUGIN_CONTINUE;
}


// Find all door entities ( at mapstart )

public _door_find() {

    if ( !get_cvar_num( "mp_breakabledoors" ) )
        return PLUGIN_CONTINUE;


    // Rotating Doors

    new DoorEnt = find_ent( -1, "func_door_rotating" );

    while ( DoorEnt > 0 )
    {
        new iDoorNum = g_iTotalDoors;

        entity_get_vector( DoorEnt, EV_VEC_origin, g_vDoorOrigins[iDoorNum] );

        g_Doors[iDoorNum][DOOR_ENT] = DoorEnt;
        g_Doors[iDoorNum][DOOR_TYPE] = FUNC_DOOR_ROTATING;

        DoorEnt = find_ent( DoorEnt, "func_door_rotating" );

        g_iTotalDoors++;
    }

    // Sliding Doors

    /* CURRENTLY NO SUPPORT
       NEED *WORKING* GET_KEYVALUE() FIRST

    DoorEnt = find_ent( -1, "func_door" );

    while ( DoorEnt > 0 )
    {
        new iDoorNum = g_iTotalDoors;

        get_brush_entity_origin( DoorEnt, g_vDoorOrigins[iDoorNum] );

        g_Doors[iDoorNum][DOOR_ENT] = DoorEnt;
        g_Doors[iDoorNum][DOOR_TYPE] = FUNC_DOOR;

        DoorEnt = find_ent( DoorEnt, "func_door" );

        g_iTotalDoors++;
    }

    */

    // Disable plugin if no breakable doors are found

    if ( g_iTotalDoors == 0 )
        set_cvar_num( "mp_breakabledoors", 0 );

    return PLUGIN_HANDLED;
}


// Break Effect

public door_effect( Float:vDoor[3] ) {

    new vEffect[3];
    vEffect[0] = floatround( vDoor[0] );
    vEffect[1] = floatround( vDoor[1] );
    vEffect[2] = floatround( vDoor[2] );

    // Door Parts

    message_begin( MSG_BROADCAST, SVC_TEMPENTITY, vEffect );

    write_byte( 108 );              // TE_BREAKMODEL (108)
    write_coord( vEffect[0] );
    write_coord( vEffect[1] );
    write_coord( vEffect[2] );
    write_coord( 0 );
    write_coord( 0 );
    write_coord( 0 );
    write_coord( 5 );
    write_coord( 5 );
    write_coord( 5 );
    write_byte( 15 );
    write_short( DOOR_GIBS );
    write_byte( 50 );
    write_byte( 50 );
    write_byte( 0 );

    message_end();

    return PLUGIN_HANDLED;
}


/* - Core ------------------------------------------------------- */


public client_disconnect( id ) {

    g_bBreakHint[id] = false;
    return PLUGIN_CONTINUE;
}


public plugin_precache() {

    if ( !get_cvar_num( "mp_breakabledoors" ) )
        return PLUGIN_CONTINUE;

    DOOR_GIBS = precache_model( "models/woodgibs.mdl" );

    return PLUGIN_CONTINUE;
}


public plugin_init() {

    register_plugin( "Breakable Doors", "1.1", "Ryan" );

    // Grenade Purchase Events

    register_menucmd( register_menuid( "BuyItem" ), (1<<3), "on_BuyGrenade" );  // Buy HE (old style)
    register_menucmd(                          -34, (1<<3), "on_BuyGrenade" );  // Buy HE (VGUI)

    register_clcmd( "hegren", "on_BuyGrenade" );                                // Buy HE (Steam)

    // Events

    register_event( "23", "on_Explosion", "a", "1=3", "6=25" );     // SVC_TEMPENTITY
    register_logevent( "on_Log_World", 2, "0=World triggered" );    // Round End(s)

    // CVARS

    register_cvar( "mp_breakabledoors", "1" );

    // Find all door ents

    set_task( 1.0, "_door_find" );

    return PLUGIN_CONTINUE;
}

// End of BREAKABLE_DOORS.SMA
