#include <amxmodx>

const startpos = 3791044

new file
new newpos
new bodypart[16]

public plugin_init(){

    cmd_ReadMDL()
}

public cmd_ReadMDL(){
    file = fopen("models/player/axis-inf/axis-inf.mdl", "rb")

    fseek(file, startpos, SEEK_SET)

    newpos = startpos

    for (new j = 0; j < 4; j++){
        for (new i = 0; i < sizeof(bodypart); i++)
            fread(file, bodypart[i], BLOCK_CHAR)

        fseek(file, newpos += 76, SEEK_SET)

        server_print("%d: %s", newpos - 3791044, bodypart)
    }

    fclose(file)
}