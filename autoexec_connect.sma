#include <amxmisc>
#include <hamsandwich>

new cmdarray[128]
public plugin_init() 
{
    register_plugin("Client Autoexec on Connect","1.0","Torch")

    RegisterHam(Ham_Spawn, "player", "fwd_PlayerSpawn_Post", 1)

    return PLUGIN_CONTINUE
}

public fwd_PlayerSpawn_Post(id)
{
	set_task(2.0,"task_exec",id);
}

public task_exec(id)
{
    client_cmd(id, "throw_smoke")
}
