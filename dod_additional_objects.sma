#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <fakemeta_util>
#include <fakemeta_stocks>
#include <dodx>
#include <dodfun>
#include <fun>
#include <engine>

#pragma semicolon 1

// определяем настройки
new const szFilePath[] = "addons/amxmodx/configs/additional_objects/";
new symbol_x[4] = "";
new szTemp[128];


// объявляем переменные
new szMapName[32]; // get_mapname(szMapName, charsmax(szMapName));
new szFile[128]; // Current Configfile for current map
new line_text[256], line_len, line_num, lines_max;
new current_object_numerline, current_object_idx;
new szModelName[128], iOrigin[3], Float:fOrigin[3];


new tmp_iValue[32][32];
new float:tmp_fValue[32][32];
// Запуск
public plugin_init()
{   
register_plugin("DOD Additional object", "0.0", "America");

/*
upload_ini();
set_task(1.0, "upload_ini");

register_clcmd("say", "CustomWeapon_Give");
*/

}



// Precache required files
public plugin_precache()
{   
    upload_ini();
    return PLUGIN_CONTINUE;
}

public upload_ini()
{   
get_mapname(szMapName, charsmax(szMapName));


format(szFile, charsmax(szFile) , "%s%s.ini",  szFilePath, szMapName);
//format(banmessage, 255, "amx_ban ^"%s^" ^"%d^" ^"%s^"", a_steamid, b_time, r_reason)
server_print("[Additional Objects] Filename: %s", szFile);



// Creating dirrectory
// new bool:is_catalog_exists = dir_exists(szFilePath)
if(!dir_exists(szFilePath))
{
server_print("(!)[Additional Objects] Dirrectory not exists = %s", szFilePath);
mkdir(szFilePath);
upload_ini();
return PLUGIN_CONTINUE;
}
else if (dir_exists(szFilePath))
{
if (!file_exists(szFile))
{   
    server_print("(!)[Additional Objects] file not exists = %s", szFile);
    write_file(szFile, "1 (1 == Enable all Obejects on this map | 0 == Diable all Objects" , 0); 
    upload_ini();
    return PLUGIN_CONTINUE;
}

if (file_exists(szFile))
{   
    server_print("[Additional Objects] file exists = %s", szFile);
    read_file(szFile, line_num, line_text, 1, line_len);
    //new mode = str_to_num(line_text[0]);
    switch (str_to_num(line_text[0]))
    {   
        case 0: server_print("[Additional Objects] All Objects Diabled");
        case 1: load_objects();
       
    }
}
else
return PLUGIN_CONTINUE;

}
return PLUGIN_CONTINUE;
}

public load_objects()
{
    server_print("[Additional Objects] Objects Enabled");
    lines_max = file_size(szFile, FSOPT_LINES_COUNT);
    lines_max-=2;
    server_print("[Additional Objects] Total Objects %d", lines_max);
    if(lines_max<0)
    {   
        server_print("[Additional Objects] load_objects()>> lines_max < 0", lines_max);
        pause("d");
        return PLUGIN_CONTINUE;
    }
    else if(lines_max==0)
    {
        server_print("[Additional Objects] load_objects()>> No object to load. File empty .");
        pause("d");
        return PLUGIN_CONTINUE;
    }
    else if(lines_max>0)
    {
        server_print("[Additional Objects] load_objects()>> loading...");
        current_object_numerline = 1;
        for (current_object_numerline = 1; current_object_numerline <= lines_max; current_object_numerline++)
        {
            read_file(szFile, current_object_numerline, line_text,  charsmax(line_text)-1, line_len);
            switch (str_to_num(line_text[0]))
                {   
                case 0: server_print("[Additional Objects] Object #%d Diabled", current_object_numerline);
                case 1: load_object(current_object_numerline);
                }
        }
        return PLUGIN_CONTINUE;
        }
    else 
    return PLUGIN_CONTINUE;
}

public load_object(current_object_numerline)
{
    server_print("[Additional Objects] load_object()>> creating #%d ...", current_object_numerline );
    current_object_idx = create_entity("info_target");
    read_file(szFile, current_object_numerline, line_text,  charsmax(line_text), line_len);
    parse(line_text, szTemp, 2, szModelName, charsmax(szModelName), tmp_iValue[1], charsmax(tmp_iValue), tmp_iValue[2], charsmax(tmp_iValue), tmp_iValue[3], charsmax(tmp_iValue), tmp_iValue[4], charsmax(tmp_iValue), tmp_iValue[5], charsmax(tmp_iValue), tmp_iValue[6], charsmax(tmp_iValue));
    if(szModelName[0]!=symbol_x[0])
    {   
        engfunc(EngFunc_PrecacheModel, szModelName);
        entity_set_model( current_object_idx, szModelName );
        server_print("[Additional Objects] load_object()>> %s Precached", szModelName);
    }
    // set origin
    fOrigin[0] = str_to_float(tmp_iValue[1]);
    fOrigin[1] = str_to_float(tmp_iValue[2]);
    fOrigin[2] = str_to_float(tmp_iValue[3]);
    entity_set_origin( current_object_idx,  fOrigin );

    /*
    // set size and solid/clip
    fOrigin[0] = str_to_float(tmp_iValue[4]);
    fOrigin[1] = str_to_float(tmp_iValue[5]);
    fOrigin[2] = str_to_float(tmp_iValue[6]);
    if(fOrigin[0] > 0.0)
    {   
        set_pev(current_object_idx, pev_movetype, MOVETYPE_TOSS);
        set_pev(current_object_idx, pev_solid, SOLID_BBOX);
        engfunc(EngFunc_SetSize, current_object_idx, fOrigin, fOrigin);
    }

    */

    return PLUGIN_CONTINUE;
}


















/// Write current object Data 
public override_current_object_data(idx_object)
{
    // write_file(path, text , -1); 
    //  Нумерация начиается с ноля ( 0) Если поставить -1 то будет записано последней строкой в файле
}


public client_PreThink(idx_player)
{  
    
    new fOrigin_2[3];
    pev(idx_player, pev_origin, fOrigin_2);
    client_print(idx_player, print_center, "origin is %f.0  %f.0  %f.0  ", fOrigin_2[0], fOrigin_2[1], fOrigin_2[2]);

}