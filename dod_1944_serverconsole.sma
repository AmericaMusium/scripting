#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <dodx>
#include <dodfun>


// Done in init to remove entities that were already created
public plugin_init()
{
    register_plugin("DOD FM TEST", "0.0", "00")

    register_forward(FM_ClientPrintf, "forward_FM_ServerPrint") // works

}

public forward_FM_ServerPrint(const string[])
{
    server_print("FM_ServerPrint :: %s" , string)
}