/* Plugin generated by AMXX-Studio */


#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <dodx>
#include <dodfun>
#include <fun>
#include <xs>

#define PLUGIN "TRACELINES"
#define VERSION "1.0"
#define AUTHOR "[America][TheVaskov]"


public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	
	register_clcmd("say trace", "func_trace1") 
	// Add your code here...
}
public func_trace1(id){
	}