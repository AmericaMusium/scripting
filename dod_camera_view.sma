#include <amxmodx>
#include <fakemeta>

public plugin_init() 
{
    register_plugin("CrosshairAngle Tracker", "1.0", "YourNick");
    register_forward(FM_MessageBegin, "OnMessageBegin");
}

public OnMessageBegin(msg_dest, msg_type, const Float:origin[3], id) 
{
    static msg_name[32];
    get_msg_name(msg_type, msg_name, charsmax(msg_name));

    // Если это сообщение "Crosshair" (стандартное для GoldSrc)
    if (equal(msg_name, "Crosshair")) 
    {
        // Получаем параметры угла прицела
        new Float:angle_x = get_msg_arg_float(1);
        new Float:angle_y = get_msg_arg_float(2);

        // Логируем данные
        server_print("CrosshairAngle: Player %d | X: %f, Y: %f", id, angle_x, angle_y);
    }
}