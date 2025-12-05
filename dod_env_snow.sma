#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>

#define PLUGIN "Snowflake Array"
#define VERSION "1.0"
#define AUTHOR "America/TheVaskov"

new const sz_map_model[][] = 
{	
	"models/1944/snowflake_array.mdl"
}

// snows
new g_snow_count, Float:g_snow_speed, Float:g_snow_radius;

// Array to store entity indexes
new g_entities[32];
new g_entity_count;

public plugin_precache()
{
    engfunc(EngFunc_PrecacheModel, sz_map_model[0]);
}

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR);
    
    // snows
    g_snow_count = 32
    g_snow_speed = 10.0;
    g_snow_radius = 1536.0;
    
    // Command to create snowflakes
    register_concmd("snowflake_create", "cmd_create_snowflakes", -1, "Create snowflake entities");
    
    // Auto-create on map start
    set_task(1.0, "delayed_create");
}

public delayed_create()
{
    env_model_create();
}

public cmd_create_snowflakes()
{
    // Remove existing snowflakes
    remove_snowflakes();
    
    // Create new ones
    env_model_create();
    
    new count = g_snow_count;
    client_print(0, print_chat, "[SNOWFLAKE] Created %d snowflake entities", count);
    
    return PLUGIN_HANDLED;
}

public env_model_create()
{
    new count = g_snow_count
    new Float:speed = g_snow_speed;
    new Float:radius = g_snow_radius;

    new Float:avel[3];
    new Float:angl[3];
    
    // Validate count
    if(count < 1) count = 1;
    if(count > sizeof(g_entities)) count = sizeof(g_entities);
    
    g_entity_count = count;
    
    new Float:center[3] = {0.0, 0.0, 0.0}; // Center of the map
    
    for(new i = 0; i < count; i++)
    {
        new iEntity = create_entity("info_target");
        
        if(!pev_valid(iEntity))
            continue;
        
        // Calculate position in circle
        new Float:angle = float(i) * (360.0 / float(count));
        new Float:position[3];
        
        position[0] = center[0] + radius * floatcos(angle, degrees);
        position[1] = center[1] + radius * floatsin(angle, degrees);
        position[2] = -128.0; //center[2]; // Z = 0
        
        set_pev(iEntity, pev_classname, "snowflake");
        set_pev(iEntity, pev_movetype, MOVETYPE_NOCLIP);
        set_pev(iEntity, pev_solid, SOLID_NOT);
        set_pev(iEntity, pev_sequence, 0);
        
        // Set model
        engfunc(EngFunc_SetModel, iEntity, sz_map_model[0]);
        
        // Set position
        engfunc(EngFunc_SetOrigin, iEntity, position);
        
        // Set rotation (each snowflake rotates around its own Y axis)
        //avel[0] = random_float(-5.0, 5.0);
        avel[1] = random_float(5.0, 10.0);
        // avel[2] = random_float(-5.0, 5.0);
        set_pev(iEntity, pev_avelocity, avel);
        
        // Set angles to avoid visual glitches
        angl[0] = random_float(-25.0, 25.0);
        set_pev(iEntity, pev_angles, angl);
        
        // Optional: Set size (adjust if needed)
        engfunc(EngFunc_SetSize, iEntity, Float:{-4096.0, -4096.0, -4096.0}, Float:{4096.0, 4096.0, 4096.0});   
        
        // Store entity index
        g_entities[i] = iEntity;
        
        // Log creation
        server_print("[SNOWFLAKE] Created entity %d at position (%.1f, %.1f, %.1f)", 
                     iEntity, position[0], position[1], position[2]);
    }
    
    client_print(0, print_chat, "[SNOWFLAKE] Successfully created %d rotating snowflakes", count);
}

public remove_snowflakes()
{
    new classname[32];
    
    for(new i = 0; i < g_entity_count; i++)
    {
        if(pev_valid(g_entities[i]))
        {
            pev(g_entities[i], pev_classname, classname, charsmax(classname));
            
            if(equal(classname, "snowflake"))
            {
                remove_entity(g_entities[i]);
            }
        }
        g_entities[i] = 0;
    }
    
    g_entity_count = 0;
}

// Clean up on plugin end
public plugin_end()
{
    remove_snowflakes();
}