
#include <amxmodx>
#include <cstrike>
#include <engine>
#include <hamsandwich>

#define PLUGIN "Uncommon Knife Warmup"
#define VERSION "0.5"
#define AUTHOR "Safety1st"

/*------------------EDIT ME------------------*/
// INTEGERS
#define WARMUP_TIME 60 // in seconds
#define MP3_BEFORE 5 // the delay BEFORE warmup end to start the music; 0 means no delay (start right in the end); comment to disable

// FLOATS
#define RESPAWN_DELAY 2.5 // in seconds
#define CUSTOM_GRAVITY 0.5 // 1.0 - normal gravity; comment to disable
//#define CUSTOM_HEALTH 35.0 // uncomment to enable

// STRINGS
#define MP3_FILE "media/Suspense07.mp3" // full path here starting from mod directory; means nothing when MP3_BEFORE is commented
/*---------------STOP EDIT HERE--------------*/

const DELAY_RESTART = 5    // normal game delay after end round messages
const HIDE_ICON = 0

#define PLAYER_CLASS "player"

enum {
WARMUP_OFF,
WARMUP_START,
WARMUP_ON,
WARMUP_END
}
new giWarmupState

const WARMUP_TASK_ID = 782491247    // arbitrary value

// macro; %1 - variable being modified, %2 - player index
#define CheckFlag(%1,%2) (%1 & (1 << (%2 & 31)))
#define SetFlag(%1,%2) (%1 |= (1 << (%2 & 31)))
#define ClearFlag(%1,%2) (%1 &= ~(1 << (%2 & 31)))
new gbAlive

new HamHook:giHhCBasePlayerSpawn, HamHook:giHhCBasePlayerKilled, HamHook:giHhCBasePlayerAddItem, HamHook:giHhCBasePlayerGiveAmmo,
gMsgRoundTime, hMsgRoundTime,
gMsgScenarioIcon,
giTimeRemaining,
pCvarRestart

public plugin_init() {
register_plugin( PLUGIN, VERSION, AUTHOR )

register_event( "TextMsg", "Event_NewGame", "a", "1=4" /* print_center */, "2=#Game_Commencing" )
register_event( "HLTV", "Event_NewRound", "a", "1=0", "2=0" )
register_event( "TextMsg", "Event_GameScoring", "a", "1=2" /* print_console */, "2=#Game_scoring" )

gMsgRoundTime = get_user_msgid( "RoundTime" )
gMsgScenarioIcon = get_user_msgid( "Scenario" )

pCvarRestart = get_cvar_pointer( "sv_restart" )

DisableHamForward( giHhCBasePlayerSpawn = RegisterHam( Ham_Spawn, PLAYER_CLASS, "OnCBasePlayer_Spawn_Post", .Post = 1 ) )
DisableHamForward( giHhCBasePlayerKilled = RegisterHam( Ham_Killed, PLAYER_CLASS, "OnCBasePlayer_Killed_Post", 1 ) )
DisableHamForward( giHhCBasePlayerAddItem = RegisterHam( Ham_AddPlayerItem, PLAYER_CLASS, "OnCBasePlayer_AddItem_Pre", 0 ) )
DisableHamForward( giHhCBasePlayerGiveAmmo = RegisterHam( Ham_GiveAmmo, PLAYER_CLASS, "OnCBasePlayer_GiveAmmo_Pre", 0 ) )
}

public Event_NewGame() {
giWarmupState = WARMUP_START
}

public Event_NewRound() {
// such msg is fired at new round only; see CHalfLifeMultiplay::RestartRound() for more info
switch( giWarmupState ) {
case WARMUP_START : Warmup_Start()
case WARMUP_END : Warmup_End()
}
}

public Event_GameScoring() {
switch( giWarmupState ) {
case WARMUP_START : {
// some team became empty right after warmup had been planned to run
giWarmupState = WARMUP_OFF
}
case WARMUP_ON : {
// some team became empty during warmup
remove_task(WARMUP_TASK_ID)
SendScenarioIcon(HIDE_ICON)
Warmup_End()
// decided to don't reset custom gravity & health
}
case WARMUP_END : {
// some team became empty right after warmup had been planned to finish
Warmup_End()
}
}
}

Warmup_Start() {
hMsgRoundTime = register_message( gMsgRoundTime, "Message_RoundTime" )

EnableHamForward( giHhCBasePlayerSpawn )
EnableHamForward( giHhCBasePlayerKilled )
EnableHamForward( giHhCBasePlayerAddItem )
EnableHamForward( giHhCBasePlayerGiveAmmo )

giTimeRemaining = WARMUP_TIME

set_task( 1.0, "Warmup_Counter", WARMUP_TASK_ID, .flags = "a", .repeat = WARMUP_TIME )    // it is suggested don't loop tasks

gbAlive = 0 // players will be spawned in the next moment

giWarmupState = WARMUP_ON
}

public Warmup_Counter() {
if( --giTimeRemaining == 0 ) {
giWarmupState = WARMUP_END
set_pcvar_num( pCvarRestart, max( DELAY_RESTART, floatround( RESPAWN_DELAY ) ) )    // let all possible respawn tasks to finish
}

#if defined MP3_BEFORE
if( giTimeRemaining == MP3_BEFORE )
client_cmd( 0, "mp3 play %s", MP3_FILE )
#endif
}

Warmup_End() {
/* It seems that unreg produces msg sending which could lead to re-entrancy or even infinite loop.
That's why I reg 'HLTV' msg as event & unreg 'RoundTime' msg later than I could. */
unregister_message( gMsgRoundTime, hMsgRoundTime )

DisableHamForward( giHhCBasePlayerSpawn )
DisableHamForward( giHhCBasePlayerKilled )
DisableHamForward( giHhCBasePlayerAddItem )
DisableHamForward( giHhCBasePlayerGiveAmmo )

giWarmupState = WARMUP_OFF

#if defined MP3_BEFORE
// in case music is still playing
client_cmd( 0, "mp3 stop" )
#endif
}

public Message_RoundTime( msgid, dest, receiver ) {
const ARG_TIME_REMAINING = 1

/* Msg is sent at player spawn, Round_Start and during HUD initialization in UpdateClientData().
Just fake the timer, it is easier than adjusting of 'mp_roundtime' cvar */
set_msg_arg_int( ARG_TIME_REMAINING, ARG_SHORT, giTimeRemaining )
}

public OnCBasePlayer_Spawn_Post(id) {
if( !is_user_alive(id) )
return

SetFlag( gbAlive, id )

SendScenarioIcon(id)

#if defined CUSTOM_HEALTH
entity_set_float( id, EV_FL_health, CUSTOM_HEALTH )
#endif
#if defined CUSTOM_GRAVITY
entity_set_float( id, EV_FL_gravity, CUSTOM_GRAVITY )
#endif
}

SendScenarioIcon(id) {
static szKnifeIcon[] = "d_knife"

const ICON_OFF = 0
const ICON_ON = 1

if( id ) {
// to show icon I use per player msgs to make sure every player will get msg
message_begin( MSG_ONE_UNRELIABLE, gMsgScenarioIcon, _, id )
write_byte(ICON_ON)
write_string( szKnifeIcon )
write_byte(0)    // no alpha value
message_end()
}
else {
// it is 'global' msg that I use to hide icon only
message_begin( MSG_BROADCAST, gMsgScenarioIcon )
write_byte(ICON_OFF)
message_end()
}
}

public OnCBasePlayer_AddItem_Pre( id, weapon ) {
if( cs_get_weapon_id(weapon) != CSW_KNIFE ) {
// only knifes are allowed. it is the most simple (but smart) way to prevent using all toher weapons
entity_set_int( weapon, EV_INT_flags, entity_get_int( weapon, EV_INT_flags ) | FL_KILLME )
SetHamReturnInteger(0)
return HAM_SUPERCEDE
}

return HAM_IGNORED
}

public OnCBasePlayer_GiveAmmo_Pre() {
const NO_AMMO_STOP_PROCESSING = -1    // exactly as gamedll does

SetHamReturnInteger(NO_AMMO_STOP_PROCESSING)
return HAM_SUPERCEDE
}

public OnCBasePlayer_Killed_Post(id) {
ClearFlag( gbAlive, id )

set_task( RESPAWN_DELAY, "RespawnPlayer", id )
}

public RespawnPlayer(id) {
switch( cs_get_user_team(id) ) {
case CS_TEAM_T, CS_TEAM_CT : {
if( !CheckFlag( gbAlive, id ) )
ExecuteHam( Ham_CS_RoundRespawn, id )
}
}
}

#if defined MP3_BEFORE
public plugin_precache() {
precache_generic( MP3_FILE )
}
#endif

public client_disconnect(id) {
// there is no need to remove a task since it is executed against in-team players only
ClearFlag( gbAlive, id )
} 