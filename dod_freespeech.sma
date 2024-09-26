/*
   VOICE PROXIMITY
   Created by the 29th Infantry Division
   www.29th.org
   www.dodrealism.branzone.com -- Revolutionizing Day of Defeat Realism
   
   DESCRIPTION
   This plugin forces voice communication only to players within a certain
   radius of the speaker, which makes it so you cannot communicate to 
   players accross the map; but rather within "speaking range," which is a
   distance defined in a cvar. This also allows communication between teams
   if the players are within proximity.

   CREDITS
   TwilightSuzuka for the original idea and loop code.
   
   FREQUENTLY ASKED QUESTION
   If alltalk is ON, the dead and spectators will be able to communicate with
   alive players. If it is OFF, they will not be able to, but either way 
   players will be able to communicate to the other team.
   Also, it is less buggy with alltalk OFF.
*/

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>

#define PLUGIN "FREE SPEACH PLAYER"
#define VERSION "1.0"
#define AUTHOR "29th ID"

new g_enabled, g_distance

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	new id
	set_task(10.0, freespeech, id)
	
}



public freespeech(id){
		new players[32]
	new i, pNum
	get_players(players, pNum, "a")
	for (i=0; i < pNum; i++) {
		if(players[i] == id)
		{
		engfunc(EngFunc_SetClientListening, id, players[i], 1)
	}
}


