#include <amxmodx>
#include <fakemeta>

public plugin_init(){
    register_clcmd("changebody", "cmd_ChangeBody")
}

public cmd_ChangeBody(id){
    set_pev(id, pev_body, 1399)
}


summodel 1 == body 0   // потому модель есть и на ноль умнодать нельзя потом // -1 

new final_body_idx 

target_body = 2
max_body = 6

target_helmet = 3
max_helmet  = 8

target_head = 3
max_head = 7

final_body_idx = max_body * (target_helmet-1) + (target_body-1) // 1  body  4 helmet  // работает для двуз групп субмоделей

final_body_idx = max_body * (target_helmet-1) + (target_body-1) //


final_body_idx = max_body * max_helmet + (target_head-1) // 






////////////////////

final_body_idx = body_idx + helmet_idx  

x  =  7 + 3 = 

(body_max * (helmet_idx-1)) + helmet_idx + body_idx
7 + 7 + 7 + 3

/*
pev_body ,  

     0 == body 1       ##     6 ==  body 1 head 2 
     1 == body 2       ##     7 ==  body 2 head 2
                                7 ==  body 1 head 2
     2 == body 3 
     3 == body 4 
     4 == body 5 
     5 == body 6 


g_body_index = 0 
*/