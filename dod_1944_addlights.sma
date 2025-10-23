#include <amxmodx>
#include <engine>

new const g_szLightClass[] = "light";
new const g_szSpotLightClass[] = "light_spot";
new const g_szEnvLightClass[] = "env_light";

public plugin_init()
{
    register_plugin("Custom Lights", "1.0", "Your Name");
    register_concmd("amx_addlight", "cmd_add_light", ADMIN_CFG, "Add a light entity");
    register_concmd("amx_addspot", "cmd_add_spotlight", ADMIN_CFG, "Add a light_spot entity");
    register_concmd("amx_addenvlight", "cmd_add_env_light", ADMIN_CFG, "Add an env_light entity");
}

public cmd_add_light(id, level, cid)
{

    new Float:origin[3];
    // entity_get_vector(id, EV_VEC_origin, origin);
    origin[0] = -1560;
    origin[1] = 56;
    origin[2] = 16;

    new ent = create_entity(g_szLightClass);
    if (!ent)
    {
        client_print(id, print_chat, "[AMXX] Failed to create light entity.");
        return PLUGIN_HANDLED;
    }
    /// 255 255 128 200
    entity_set_string(ent, EV_SZ_classname, g_szLightClass);
    entity_set_origin(ent, origin);
    entity_set_string(ent, EV_SZ_globalname, "255 255 128 200");
    entity_set_string(ent, EV_SZ_model, "255 255 128 200");
    entity_set_string(ent, EV_SZ_target, "255 255 128 200");
    entity_set_string(ent, EV_SZ_targetname, "255 255 128 200");
    entity_set_string(ent, EV_SZ_netname, "255 255 128 200");
    entity_set_string(ent, EV_SZ_message, "255 255 128 200");
    entity_set_string(ent, EV_SZ_noise, "255 255 128 200");
    entity_set_string(ent, EV_SZ_noise1, "255 255 128 200");
    entity_set_string(ent, EV_SZ_noise2, "255 255 128 200");
    entity_set_string(ent, EV_SZ_noise3, "255 255 128 200");
    entity_set_string(ent, EV_SZ_viewmodel, "255 255 128 200");
    entity_set_string(ent, EV_SZ_weaponmodel, "255 255 128 200");


    // entity_set_string(ent, EV_SZ_message, "_shelldon"); // Яркость и цвет (в GoldSrc через message)
    // entity_set_float(ent, EV_FL_brightness, 10.0);

    client_print(id, print_chat, "[AMXX] Light added at your position.");

    return PLUGIN_HANDLED;
}

public cmd_add_spotlight(id, level, cid)
{

    new Float:origin[3];
    entity_get_vector(id, EV_VEC_origin, origin);

    new ent = create_entity(g_szSpotLightClass);
    if (!ent)
    {
        client_print(id, print_chat, "[AMXX] Failed to create light_spot entity.");
        return PLUGIN_HANDLED;
    }

    entity_set_string(ent, EV_SZ_classname, g_szSpotLightClass);
    entity_set_origin(ent, origin);
    entity_set_string(ent, EV_SZ_message, "_shelldon"); // Яркость
    // entity_set_float(ent, EV_FL_brightness, 10.0);
    entity_set_int(ent, EV_INT_spawnflags, 0);

    client_print(id, print_chat, "[AMXX] Spot light added at your position.");

    return PLUGIN_HANDLED;
}

public cmd_add_env_light(id, level, cid)
{


    new ent = create_entity(g_szEnvLightClass);
    if (!ent)
    {
        client_print(id, print_chat, "[AMXX] Failed to create env_light entity.");
        return PLUGIN_HANDLED;
    }

    entity_set_string(ent, EV_SZ_classname, g_szEnvLightClass);
    entity_set_string(ent, EV_SZ_message, "255 255 255"); // Цвет (R G B)
    // entity_set_float(ent, EV_FL_brightness, 0.8);

    client_print(id, print_chat, "[AMXX] env_light added.");

    return PLUGIN_HANDLED;
}