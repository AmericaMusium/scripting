/*
=========================================================================================================================================================================================================================================
C:\
=       Aim Realism        -  AMX Mod X script. Copyright © 2020-2023, WATCH_DOGS UNITED.
=
=========================================================================================================================================================================================================================================
=
============================ ================================================================================================= ==========================================================================================================
=         Credits          | |                                        Credits Reason                                         | |                             Web Address
============================ ================================================================================================= ==========================================================================================================
=                          | |                                                                                               | |
=  λMX Mod X               | | Plugin creation opportunity; © Copyright AMX Mod X Dev Team;                                  | | https://www.amxmodx.org
=  WATCH_DOGS UNITED       | | Plugin creation;                                                                              | | https://gamebanana.com/members/1725138
=  VEN                     | | "Fix_Recoil" plugin base code ( 2007 ); used to control the bullets accuracy by distancement; | | https://forums.alliedmods.net/member.php?u=3695
=  hellmonja               | | Code required for shotgun pellets to act properly when shooting players;                      | | https://gamebanana.com/members/1421238
=  ot_207                  | | Some codes of the "recoil_control" plugin ( 2009 ) + useful coding examples;                  | | https://forums.alliedmods.net/member.php?u=34309
=  ConnorMcLeod            | | Snipers scope detection through camera FOV + useful coding examples;                          | | https://forums.alliedmods.net/member.php?u=18946
=  Bugsy                   | | Detection of events through boolean variables + useful coding examples;                       | | https://forums.alliedmods.net/member.php?u=4234
=  Ark_Procession          | | By reporting the plugin functionality, helped us improve it;                                  | | https://forums.alliedmods.net/member.php?u=301170
=  RojedaVZLA              | | Bug reporting and other plugin functionality reports.                                         | | https://gamebanana.com/members/1704571
=  Google Bard             | | Some help with code optimization questions and ideas.                                         | | https://bard.google.com
============================ ================================================================================================= ==========================================================================================================
=========================================================================================================================================================================================================================================
=
================
=  Description |
================
=
=  This plugin makes your weapons as accurate as a real one;
=  Accuracy works in any case: stopped, running, jumping, on air, on ladder, on water, using snipers without scope, etc.
=  All weapons accuracy and recoil can be edited and saved in a proper configuration file.
=
=  If you're shooting from a ladder you'll notice a slight difference in accuracy also realistic;
=  Accuracy of shotgun pellets adjusted to be as realistic as possible;
=  Fixes the game's engine bad shot registration bug;
=  Fixes bad shot registration bug when playing online on slow speed internet connections;
=  Includes customizable crosshairs via console;
=  Allows you to see players name even in long ranges;
=  Includes a new BotProfile made for realism;
=  Fixes the slow players health update in spectator mode. New
=  Fixes the need of switching weapons to reset accuracy (game bug fix). New
=
=  BotProfile Characteristics
=
=  Includes all CS / CZ bots
=
=  Includes a Mixed bot level, which any bot from any level will participate;
=  Bots act in a more independent way;
=
=  4 levels (Easy, Normal, Hard and Expert) instead of 8 (Easy, Fair, Normal, Tough, Hard, VeryHard, Expert and Elite)
=
=  No injustices:
=
=  Bots from a same level have the same skill;
=  Bots can't know your exact position.
=
=  Skills are scaled:
=
=  Easy: 30 | Normal: 50 | Hard: 70 | Expert: 90
=
=  Attack delays are scaled:
=
=  Easy: 1.1 | Normal: 0.55 | Hard: 0.275 | Expert: 0.1375
=
=  A total of 210 bots with static skins (bots that already had static skins in original will keep the same)
=
=  Bot skins was divided for better variation: 42 bots for every of the 5 CZ player classes.
=
=========================================================================================================================================================================================================================================
=  Changelog   |
================
=
=  Dec 22, 2020 - v1.0     -  Initial release
=
=  Aug 05, 2021 - v2.0     -  Optimized code + Added features
=
=      [ ADDED ]           -  Cvar for custom recoil
=      [ ADDED ]           -  Shotgun pellets accuracy control
=      [ ADDED ]           -  Cvar for custom shotgun pellets accuracy
=      [ ADDED ]           -  Customizable crosshair: No Crosshair, Static and Accurate ( Standard + Static )
=      [ ADDED ]           -  Cvar for custom crosshairs
=      [ ADDED ]           -  Snipers crosshair ( static crosshair )
=      [ ADDED ]           -  Cvar for snipers crosshair
=      [ ADDED ]           -  Command to display crosshair modes in console
=
=  [ OPTIMIZED ]           -  Realism function code reduced and ultra optimized for bullet processing performance
=  [ OPTIMIZED ]           -  Now the realism function works even if the targets are behind walls and objects
=  [ OPTIMIZED ]           -  Realism function now works only when you shoot keeping your gameplay more lighter
=
=  [ UNALTERED ]           -  Recoil stills the same as v1.0 ( 0.237 ) as already the best approximation for realism.
=
=  Aug 11, 2021 - v2.1     -  Optimized code + Added features + Removed commands
=
=  [ OPTIMIZED ]           -  You can now enable/disable standard and static crosshairs with proper cvars.
=  [ OPTIMIZED ]           -  Now you can use the snipers crosshair independent that static crosshair is disabled on other weapons.
=
=    [ REMOVED ]           -  command to show crosshair modes.
=    [ REMOVED ]           -  cvar to set crosshair modes.
=
=      [ ADDED ]           -  cvar for standard crosshair.
=      [ ADDED ]           -  cvar for static crosshair.
=
=  Aug 30, 2021 - v2.2     -  Code optimized + Updated txt file + BotProfile updated to Hitman Edition.
=
=  [ OPTIMIZED ]           -  Realism function code reduced.
=     [ UNDONE ]           -  Shotgun pellets now are better represented in "Advanced Weapon Tracers" plugin even if shooting entities.
=  [ OPTIMIZED ]           -  Now bots have from 25 ( Easy ) to 100 ( Expert ) sequential skills with a more agitated behavior.
=
=      [ ADDED ]           -  Custom static crosshair tutorial.
=
=  Sep 02, 2021 - v2.2.1   -  Now compatible with latest Amx Mod X versions.
=
=  Sep 03, 2021 - v2.2.2   -  Code optimized + Shotgun precision works even with entities ( breakable objects , doors etc. ).
=
=  Sep 25, 2021 - v2.2.3   -  Code optimized + Added crosshair options for spectator mode + BotProfile updated.
=
=      [ ADDED ]           -  cvar for standard crosshair on spectator mode.
=      [ ADDED ]           -  cvar for static crosshair on spectator mode.
=      [ ADDED ]           -  cvar for snipers crosshair on spectator mode.
=
=  Sep 27, 2021 - v2.2.4   -  Changed "observer" to "static" crosshair and "normal" to "standard" crosshair for better understanding.
=
=  Oct 04, 2021 - v2.2.5   -  Code optimized + optimized shotgun system for long ranges + BotProfile updated.
=
=  Jan 23, 2022 - v2.2.6   -  Code optimized + Now the plugin is fully customizable.
=
=  [ OPTIMIZED ]           -  Now you can control weapon recoil on every weapon separately.
=  [ OPTIMIZED ]           -  You can now control shotgun pellets accuracy on every shotgun separately.
=     [ UNDONE ]           -  Paused time for avoiding flashbang effect conflict reduced to only 0.1s with no interference!
=
=    [ REMOVED ]           -  Cvar aim__shotguns_accuracy.
=
=      [ ADDED ]           -  Now you can control the bullets accuracy via cvar on every weapon or all weapons at the same time.
=      [ ADDED ]           -  Cvar for recoil control mode.
=      [ ADDED ]           -  Cvars for recoil control for every weapon.
=      [ ADDED ]           -  Cvar for accuracy control mode.
=      [ ADDED ]           -  Cvar for accuracy control for all weapons.
=      [ ADDED ]           -  Cvars for accuracy control for every weapon.
=      [ ADDED ]           -  Now you can configure the plugin with a proper configuration file in the "configs" folder.
=
=  [ UNALTERED ]           -  No settings was changed in this version. BotProfile stills the same as v2.2.5.
=
=  Feb 24, 2022 - v2.2.7   -  Code optimized + BotProfile updated.
=
=  Dec 31, 2022 - v2.2.8   -  Fixed noflash bug.
=
=  Jan 10, 2023 - v2.2.9   -  Accuracy and recoil improvements + BotProfile update.
=
=  [ GAME BUG FIX ]        -  No more need of switching weapons to reset accuracy, the plugin will reset accuracy automatically.
=  [ OPTIMIZED ]           -  Even lighter gameplay experience. All shooting related functions are only activated when players shot.
=  [ OPTIMIZED ]           -  Bot Profile updated for a better co-op.
=
=  Jan 25, 2023 - v2.3.0   -  Improved accuracy + fixed console commands + code optimized + BotProfile updated.
=
=  Jan 27, 2023 - v2.3.1   -  Code optimized + recoil control optimized + BotProfile updated.
=
=  Jan 30, 2023 - v2.3.2   -  Code optimized + BotProfile updated + now you can change crosshair settings on every weapon.
=
=      [ FIXED ]           -  Invalid cvar pointer log errors on accuracy mode 2.
=
=      [ ADDED ]           -  Now you can enable/disable static/standard crosshairs on every weapon/equipment separately.
=      [ ADDED ]           -  Cvar to enable/disable crosshair features (aim_crosshairs).
=      [ ADDED ]           -  Cvars to enable/disable static/standard crosshairs for every weapon(aim_<crosshair type>_c_<weapon>).
=
=  [ OPTIMIZED ]           -  Better accuracy of shotgun pellets.
=  [ OPTIMIZED ]           -  Even lighter gameplay experience with no errors.
=
=  Jan 31, 2023 - v2.3.3   -  Code optimized + fixed crosshair commands for every weapon not working.
=
=  [ OPTIMIZED ]           -  Easily access all weapon commands by typing 'aim_<weaponname>' (accuracy, recoil, standard and static crosshair).
=
=  Feb 13, 2023 - v2.3.4   -  Several code optimizations + new better way for hooking player shot + BotProfile updated + reinforced noflash bug fix.
=
=  [ OPTIMIZED ]           -  New shot hook detects when players really shot, excluding all other player button actions and sync with recoil control for faster response.
=  [ OPTIMIZED ]           -  Even lighter gameplay. The new shot hook removed all unnecessary task calls.
=  [ OPTIMIZED ]           -  Best possible accuracy and shot registration to seize every projectile fired.
=  [ OPTIMIZED ]           -  Reinforced generic flash effect detector. No flash errors were found after hundreds of attempts.
=
=  Feb 17, 2023 - v2.3.5   -  Code optimized + BotProfile updated + Added features.
=
=      [ ADDED ]           -  Now you can turn off shotgun pellets accuracy for map entities (objects, doors, etc.) to not interfer when shooting players close to it.
=      [ ADDED ]           -  Added economic shot mode for bots. When enabled, bots will shot less bullets than generally. May vary due to several factors.
=      [ ADDED ]           -  Cvar to enable/disable shotgun accuracy for map entities (aim_shotgun_ac_map_ents).
=      [ ADDED ]           -  Cvars to enable/disable bots economic shot mode (aim_bots_shot_ec_).
=
=  Feb 18, 2023 - v2.3.6   -  Code optimized + BotProfile updated to Hitman v2 Edition.
=
=  Feb 20, 2023 - v2.3.7   -  Code optimized + BotProfile updated.
=
=  Mar 28, 2023 - v2.3.8   -  Code optimized + BotProfile updated + Added feature.
=
=   [ ADJUSTED ]           -  Added valid(id) verifications for players for fixing the possibility of invalid player indexes.
=      [ FIXED ]           -  Fixed a problem with shot detection. Advanced tests were made to detect when players shot. All inconsistences detected has been fixed.
=   [ IMPROVED ]           -  Much better shot registration, accuracy and recoil control. This optimization was resulted due to the new precise shot detection.
=  [ OPTIMIZED ]           -  Much better spread of shotgun pellets. You will now hit players more easier with shotguns. This fix was resulted due to some code optimizations.
=  [ OPTIMIZED ]           -  More lighter gameplay. Shooting functions are now completely inactive when players are not shooting. Tests using a old computer showed up perceptible high fps rates.
=      [ ADDED ]           -  Now you can select what bot level you want to replace by the mixed level or choose a file with no mixed level.
=      [ ADDED ]           -  Added camera degree control (fov) feature for adjustable screen zoom level when in first person mode.
=      [ ADDED ]           -  Cvars for FOV control (aim__fov ).
=
=  Apr 09, 2023 - v2.3.9   -  Shot hook updated + BotProfile updated + Removed feature.
=
=   [ IMPROVED ]           -  New accurate shot detection method for detecting the exact moment of every shot separately.
=  [ OPTIMIZED ]           -  Lighter gameplay. With the new shot detector, the accuracy functions are activated and deactivated in a extremely short period of time, reducing CPU/RAM usage.
=  [ OPTIMIZED ]           -  As the accuracy functions are now activated and deactivated in a too short period of time, the flashbang effect will no more be affected by it.
=  [ OPTIMIZED ]           -  No more interferences affecting accuracy. Due to the optimization above, is no more needed for the plugin to pause the accuracy for 0.21s when a flashbang is thrown.
=    [ REMOVED ]           -  Economic shot mode for bots were removed, as it will not to work with the new shot detection method.
=
=  Oct 28, 2023 - v2.4.0   -  Code optimized + Added features + Removed commands + BotProfile updated
=
=  [ OPTIMIZED ]           -  This plugin version has several optimizations regarding CPU and RAM usage.
=   [ IMPROVED ]           -  This plugin version uses a method which we've named self-checking. Self-checking ensures the plugin is not applying data if the current data is equal the data to be applyed.
=      	[ INFO ]           -  Self-checking is a powerful method for reducing both CPU and RAM usage and also avoiding instability. It can solve problems like creating many entities which leads to 'ED_alloc: no free edicts' crash.
=  [ OPTIMIZED ]           -  The plugin will now detect the total players in the server in real-time and only apply functions for these players, saving CPU and RAM.
=  [ OPTIMIZED ]           -  New method for detecting alive and dead players which limits the functions for the first person camera scope, which may save CPU in certain cases. No problem with 3rd person camera plugins.
=   [ IMPROVED ]           -  Crosshairs and FOV are now applyed instantly. No more need to shoot or switch the gun to refresh.
=      [ ADDED ]           -  Now you can turn on/off crosshairs when shield is closed. To enable, set the crosshair value to '2' for the desired pistol/grenade or knife. Example: aim_usp_standard_c "2". To turn off, "1".
=      [ ADDED ]           -  Now you can turn off the recoil and accuracy control for the specified weapon by setting the value to -1.
=    [ EXAMPLE ]           -  Play with the original game recoil and control only bullet accuracy: aim_ak47_recoil "-1"; aim_ak47_accuracy "9999"
=   [ IMPROVED ]           -  Snipers FOV < 90 is now possible.
=    [ NOTE 01 ]           -  The models included in the package are a renamed copy of the original game models. They are used to make the game engine to not detect the v_<sniper> term which turns the model invisible.
=    [ NOTE 02 ]           -  To enable the plugin from applying the models, set the cvar "aim__sniper_allow_mdls" to 1. It is set to 0 by default. Please save your settings in the config file.
=    [ NOTE 03 ]           -  If you are using the default game v_ models, simply extract the models to the game dir.
=    [ NOTE 04 ]           -  If you are using modified snipers v_ models, please make a copy of the files and rename it: If you are playing CS 1.6, rename your snipers v_ model to cs_<weapon>.mdl, for CZ, cz_<weapon>.mdl.
=    [ NOTE 05 ]           -  These models are at your option. You can use the plugin without it. If the plugin detects your sniper v_ model has the invisibility term and FOV is less than 90, FOV is set to 90 automatically.
=      [ ADDED ]           -  As we are using these CS and CZ models, we have added the extra options below:
=  [ OPTION 01 ]           -  You can "invert" the v_ models from CS 1.6 to CZ and from CZ to CS 1.6 respectively by using the cvar "aim__sniper_cs_<>_cz".
=    [ EXAMPLE ]           -  If you are playing CS 1.6 and set the cvar 'aim__sniper_cs_<>_cz' to 1, your snipers will become the Condition-Zero snipers (and vice-versa). Make sure the cvar "aim__sniper_allow_mdls" is set to 1.
=  [ OPTION 02 ]           -  Added sniper scope modes. When the cvar "aim__sniper_scope_mode" is set to 1 and you use the sniper scope, the sniper model will become visible, so you will be able to see shells and flares.
=    [ NOTE 07 ]           -  Depending on the screen resolution, you may see the gun barrel. When "aim__sniper_scope_mode" is set to 0, the sniper model will become invisible (game default) (except if you click both buttons).
=    [ NOTE 08 ]           -  The CurWeapon event is used here instead of Ham_Item_Deploy because we need to catch the sniper scope moment, which CurWeapon is also called.
=    [ NOTE 09 ]           -  The CurWeapon event will apply the gun mdls in the same moments as Ham_Item_Deploy (when the player got his gun) and only for the player who owns the gun, not for the spectator.
=    [ NOTE 10 ]           -  The gun model on CurWeapon event and all other plugin functions are only applyed once, when data is changed. The plugin will never re-aplly data if the current value is already the value to apply.
=    [ NOTE 11 ]           -  If you are using a AMXX gun mod which uses a sniper rifle as a base, the plugin will detect this and will not apply the model for the weapon.
=  [ OPTIMIZED ]           -  TraceLine forward is now registered on Ham_Weapon_PrimaryAttack and unregistered on Ham_Weapon_PrimaryAttack_Post, so the Traceline forward is no more active when players are not attacking, saving CPU.
=       [ NOTE ]           -  Although, the current method for detecting 'shots' uses Ham_Weapon_PrimaryAttack, which is subject to execute code when the gun has no bullets or when you keep fire pressed with pistols.
=       [ NOTE ]           -  No intervention in the fake shots cited above were made because the method for fixing it will cause more CPU usage than the fake shots themself.
=    [ REMOVED ]           -  xs natives has been removed as they are used only once per function. Extracted code logics from the respective natives were added instead.
=  [ OPTIMIZED ]           -  FOV control is no more active when the value is the game default (90). The plugin is able to set the FOV to 90 and then turn off the FOV control.
=      [ ISSUE ]           -  When a player spectates another player in 1st person mode and the last one picks a new sniper gun, the returned string from pev native will be the original game v_mdl, then FOV 90 is applyed if FOV < 90.
=  [ ISSUE FIX ]           -  Simply switch to another player and come back to the previous.
=    [ REMOVED ]           -  aim__fov_control cvar. When the cvar aim__fov is 90 the FOV control is turned off.
=       [ NOTE ]           -  Due to the high complexity of the FOV control for it to work properly, catch the moments the game set FOV back to 90, and etc. the get_fov array needs to still store data even if FOV is set to 90.
=       [ NOTE ]           -  Except the 'P_Cvar', 'W_VAR', 'get/set_fov', 'Mod', 'v_mdl' and 'term' arrays, all other arrays in the plugin are storing no data during 99.99% of the time. All the data gathered is eliminated after use.
=  [ OPTIMIZED ]           -  Now you can turn on/off recoil and accuracy control separately from cvar aim__realism: 0 = both are disabled; 1 = only accuracy is enabled; 2 = only recoil is enabled; 3 = both are enabled.
=       [ NOTE ]           -  The ASSAULT_SCOPE static is not used in the plugin code. Use it if you want to apply/gather something for/from the player who is using the aug/sg552 scope.
=       [ NOTE ]           -  The joiner static is not used in the plugin code. Use it if you want to apply/gather something for/from the client who connected (On_Client_Connect). Example: client_print(joiner,print_chat,"WELCOME!")
=
=========================================================================================================================================================================================================================================
=
================
=  Commands    |
================
=
=  aim__realism            -  Allows the plugin to control the weapons accuracy and recoil. Default: 1 ( On )
=
=  ACCURACY MEANS THE BULLET DIRECTION IN RELATION TO THE CROSSHAIR CENTER.
=
=  aim_accuracy__mode      -  Weapons accuracy control mode; mode 1 = all weapons; mode 2 = specified weapons. Default: 1 ( all )
=  aim_accuracy            -  Controls the accuracy of all weapons except shotguns. "aim_accuracy__mode" must be = 1. Default: 9999
=  aim_<weapon>_accuracy   -  Controls the accuracy of the specified weapon. "aim_accuracy__mode" must be = 2. Default: 9999; Off: -1
=  aim_shotgun_ac_map_ents -  Pellets accuracy on objects, glass, walls, etc. May interfere if players are close to ents. Default: 0 ( Disabled )
=
=  NOTE: THE HIGHER THE ACCURACY VALUE, THE LESS DAMAGE DIFFERENCE IN CLOSE AND LONG RANGES.
=
=  RECOIL MEANS THE SHAKE OF THE SHOT WHICH CONSEQUENTLY CHANGES THE CROSSHAIR DIRECTION.
=
=  aim_recoil__mode        -  Weapons recoil control mode; mode 1 = all weapons; mode 2 = specified weapons.
=  aim_recoil              -  Controls the recoil of all weapons. "aim_recoil__mode" must be = 1. Default: 0.237
=  aim_<weapon>_recoil     -  Controls the recoil of the specified weapon. "aim_recoil__mode" must be = 2. Default: 0.237; Off: -1
=
=  NOTE: THE HIGHER THE RECOIL VALUE, THE LESS CONTROL OVER THE CROSSHAIR DIRECTION.
=
=  aim_crosshairs          -  Allows the plugin to change crosshairs. Default: 1 ( Allowed )
=
=  aim__standard_crosshair -  Allows the standard crosshair to be displayed. Default: 1 ( Allowed )
=  aim__static_crosshair   -  Allows the static crosshair to be displayed. Default: 1 ( Allowed )
=  aim__snipers_crosshair  -  Allows the static crosshair to be displayed while holding sniper rifles. Default: 1 ( Allowed )
=
=  aim_spec_standard_cross -  Allows the standard crosshair on spectator mode. Default: 1 ( Allowed )
=  aim_spec_static_cross   -  Allows the static crosshair on spectator mode. Default: 1 ( Allowed )
=  aim_spec_snipers_cross  -  Allows the snipers crosshair on spectator mode. Default: 1 ( Allowed )
=
=  aim_<weapon>_standard_c -  Allows the standard crosshair for the specified weapon/equipment. Default: 1 ( Allowed ); if set to '2', it also appears when shield is closed.
=  aim_<weapon>_static_c   -  Allows the static crosshair for the specified weapon/equipment. Default: 1 ( Allowed ); if set to '2', it also appears when shield is closed.
=
=  Note: Static crosshair is the observer crosshair, so keep the observer crosshair enabled in your game options section.
=
=  aim__fov                -  Sets the camera FOV degrees. Default: 90 (Disabled).
=
=  aim__sniper_allow_mdls  -  Allows the plugin to apply the renamed sniper v_ models for these to become visible when FOV < 90, for 'inverting' models, and for the sniper scope modes.
=  aim__sniper_cs_<>_cz    -  If you are playing CS 1.6, your snipers v_ models will become the Condition-Zero snipers (and vice-versa). Make sure the cvar "aim__sniper_allow_mdls" is set to 1. Default: 0 (Disabled)
=  aim__sniper_scope_mode  -  When set to 1, the sniper model will become visible on scope, so you will be able to see shells and flares, and depending on screen resolution, the gun barrel. Default: 1. [aim__sniper_allow_mdls needed]
=
=========================================================================================================================================================================================================================================
=
=====================
=  Plugin File Info |
=====================
=
=  Lines: 574              -  Code: 232
=  Size : 36.0 KB          -  Code: 8.89 KB
=
=========================================================================================================================================================================================================================================
=
=====================
=  Coding Reference |
=====================
=
======================================================================================
=  CSW_NONE                -  0
=  SHOW STANDARD CROSSHAIR -  0
=  DONT_IGNORE_MONSTERS    -  0
=  MIN PLAYERS             -  1
=  CSW_P228                -  1
=  CSW_SCOUT               -  3
=  CSW_HEGRENADE           -  4
=  CSW_XM1014              -  5
=  CSW_C4                  -  6
=  CSW_AUG                 -  8
=  CSW_SMOKEGRENADE        -  9
=  CSW_FIVESEVEN           -  11
=  CSW_SG550               -  13
=  CSW_USP                 -  16
=  CSW_GLOCK18             -  17
=  CSW_AWP                 -  18
=  CSW_M3                  -  21
=  CSW_G3SG1               -  24
=  CSW_FLASHBANG           -  25
=  CSW_DEAGLE              -  26
=  CSW_SG552               -  27
=  CSW_KNIFE               -  29
=  MAX PLAYERS             -  31
=  SNIPERS SCOPE FsOV      -  < 41 (1ST ZOOM = 40; 2ND ZOOM = 15 (10 FOR AWP))
=  AUG / SG552 SCOPE FOV   -  55
=  HIDE STANDARD CROSSHAIR -  64
=  DEFAULT FOV             -  90
======================================================================================
=
=========================================================================================================================================================================================================================================
*/

#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>

#define joiner (clients)
#define quitter (clients + 1)
#define valid(%0) (clients >= %0 > 0)
#define num get_pcvar_num
#define SNIPER ((1<<3 | 1<<13 | 1<<18 | 1<<24) & (1<<WPN[id]))
#define SNIPER_SCOPE (SNIPER && ((1<<40 | 1<<15 | 1<<10) & (1<<get_fov[id])))
#define ASSAULT_SCOPE ((1<<8 | 1<<27) & (1<<WPN(id)) && ((1<<55) & (1<<get_fov[id])))
#define HAS_SHIELD_IDLE_STATE ((1<<1 | 1<<4 | 1<<9 | 1<<11 | 1<<16 | 1<<17 | 1<<25 | 1<<26 | 1<<29) & (1<<WPN[id]))
#define DEF_FOV (num(P_Cvar[13]) == 90)
#define SHOTGUN ((1<<5 | 1<<21) & (1<<WPN[id]))
#define r_id pev(ent,pev_owner)

const NOSHOT = (1<<0 | 1<<4 | 1<<6 | 1<<9 | 1<<25 | 1<<29)

new const v_mdl[][] = {"models/cs_awp.mdl","models/cs_g3sg1.mdl","models/cs_scout.mdl","models/cs_sg550.mdl","models/cz_awp.mdl","models/cz_g3sg1.mdl","models/cz_scout.mdl","models/cz_sg550.mdl"}
new const term[][] = {"v_awp","v_g3sg1","v_scout","v_sg550"}

new P_Cvar[17],W_VAR[4][31],wname[20],Mod[8],clients,fwd_camera,mdl_path[30],dir[8],new_mdl[31],def_mdl[32],old_mdl[48],cur_mdl[48],fwd_trace

static set_fov[32],get_fov[32],WPN[32],ALIVE[32],STC_C_CHANGED[32],HDW[32],HID_WPN[32],check_mdl[32],mdl_visible_on_zoom[32],CM[32],SC[32],FM[32],target,body,AM

public plugin_init() {
	register_plugin("Aim Realism","2.4.0","WATCH_DOGS UNITED"    )
	P_Cvar[0]  = register_cvar("aim__realism"           , "3"    )
	P_Cvar[1]  = register_cvar("aim_recoil"             , "0.237")
	P_Cvar[2]  = register_cvar("aim__snipers_crosshair" , "1"    )
	P_Cvar[3]  = register_cvar("aim__standard_crosshair", "1"    )
	P_Cvar[4]  = register_cvar("aim__static_crosshair"  , "1"    )
	P_Cvar[5]  = register_cvar("aim_spec_standard_cross", "1"    )
	P_Cvar[6]  = register_cvar("aim_spec_static_cross"  , "1"    )
	P_Cvar[7]  = register_cvar("aim_spec_snipers_cross" , "1"    )
	P_Cvar[8]  = register_cvar("aim_recoil__mode"       , "1"    )
	P_Cvar[9]  = register_cvar("aim_accuracy__mode"     , "1"    )
	P_Cvar[10] = register_cvar("aim_accuracy"           , "9999" )
	P_Cvar[11] = register_cvar("aim_crosshairs"         , "1"    )
	P_Cvar[12] = register_cvar("aim_shotgun_ac_map_ents", "0"    )
	P_Cvar[13] = register_cvar("aim__fov"               , "90"   )
	P_Cvar[14] = register_cvar("aim__sniper_scope_mode" , "1"    )
	P_Cvar[15] = register_cvar("aim__sniper_cs_<>_cz"   , "0"    )
	P_Cvar[16] = register_cvar("aim__sniper_allow_mdls" , "0"    )
	new rec_wname[21],acc_wname[23],stat_c_wname[23],stand_c_wname[28]
	for(new i = CSW_P228; i <= CSW_P90; i++) {
		if(get_weaponname(i,wname,20)) {
			formatex(stat_c_wname,charsmax(stat_c_wname),"aim_%s_static_c",wname[7])
			formatex(stand_c_wname,charsmax(stand_c_wname),"aim_%s_standard_c",wname[7])
			W_VAR[2][i] = register_cvar(stat_c_wname,"1")
			W_VAR[3][i] = register_cvar(stand_c_wname,"1")
			if(!(NOSHOT & (1<<i))) {
				formatex(rec_wname,charsmax(rec_wname),"aim_%s_recoil",wname[7])
				formatex(acc_wname,charsmax(acc_wname),"aim_%s_accuracy",wname[7])
				W_VAR[0][i] = register_cvar(rec_wname,"0.237")
				W_VAR[1][i] = register_cvar(acc_wname,"9999")
				RegisterHam(Ham_Weapon_PrimaryAttack,wname,"Rec_Control",1)
				RegisterHam(Ham_Weapon_PrimaryAttack,wname,"On_Gun_Trigger",0)
			}
			rec_wname=""; acc_wname=""; stat_c_wname=""; stand_c_wname=""; wname=""
		}
	}
	register_logevent("On_Client_Connect",2,"1=entered the game")
	register_logevent("On_Client_Disconnect",2,"1=disconnected")
	register_event("CurWeapon","Event_CurWpn","b","1=1")
	register_event("HideWeapon","Event_HideWpn","b")	
	register_event("SetFOV","Event_SetFOV","b")
	get_modname(Mod,8)
}

public plugin_cfg()
	server_cmd("exec addons/amxmodx/configs/aim_realism.cfg")

public plugin_precache() {
	for(new i; i<sizeof(v_mdl); i++)
		if(file_exists(v_mdl[i]))
			precache_model(v_mdl[i])
}

public On_Client_Connect() {
	clients++
	if(clients == 1)
		fwd_camera = register_forward(FM_UpdateClientData,"Camera_Misc")
}

public On_Client_Disconnect() {
	clients--
	get_fov[quitter] = 0
	set_fov[quitter] = 0
	if(!clients) {
		unregister_forward(FM_UpdateClientData,fwd_camera)
		fwd_camera = 0
	}
}

public Event_CurWpn(const id) {
	if(valid(id) && (31 > (WPN[id] = read_data(2)) > 0)) {
		ALIVE[id] = pev(id,pev_viewmodel) > 0
		STC_C_CHANGED[id] = num(P_Cvar[11])
		if(SNIPER && !(pev(id,pev_button) & IN_ATTACK)) {
			if(ALIVE[id] && num(P_Cvar[16])) {
				mdl_path = SNIPER_SCOPE && !num(P_Cvar[14]) ? ("models/v_%s.mdl") : ((dir = !num(P_Cvar[15]) ? "cstrike" : "czero") && equal(Mod,dir) ? "models/cs_%s.mdl" : "models/cz_%s.mdl")
				if(get_weaponname(WPN[id],wname,20) && formatex(new_mdl,30,mdl_path,wname[7]) && formatex(def_mdl,30,"models/v_%s.mdl",wname[7]) && file_exists(new_mdl)) {
					pev(id,pev_viewmodel2,old_mdl,48)
					if((SNIPER_SCOPE && !num(P_Cvar[14]) || equali(old_mdl,def_mdl,30)) && !equali(new_mdl,old_mdl,30))
						set_pev(id,pev_viewmodel2,new_mdl)
					mdl_path=""; dir=""; wname=""; new_mdl=""; def_mdl=""; old_mdl=""
				}
			}
			if(num(P_Cvar[13]) < 90) {
				check_mdl[id] = 1
				mdl_visible_on_zoom[id] = 1
				return PLUGIN_HANDLED
			}
			return PLUGIN_HANDLED
		}
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public Event_HideWpn(const id) {
	if(num(P_Cvar[11]) && HAS_SHIELD_IDLE_STATE) {
		HDW[id] = read_data(1)
		pev(ALIVE[id] ? id : pev(id,pev_iuser2),pev_viewmodel2,cur_mdl,22)
		if(containi(cur_mdl,"v_shield") != -1)
			HID_WPN[id] = 1
		cur_mdl=""
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public Event_SetFOV(const id) {
	if(valid(id)) {
		set_fov[id] = 0
		get_fov[id] = read_data(1)
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public Camera_Misc(const id) {
	if(valid(id) && !((1<<0) & (1<<WPN[id]))) {
		if(num(P_Cvar[11]) && !SNIPER_SCOPE) {
			if(CM[id] != (CM[id] = (num(P_Cvar[3]) && ALIVE[id] || num(P_Cvar[5]) && !ALIVE[id]) && num(W_VAR[3][WPN[id]]) ? 0 : 64) || HID_WPN[id] && !(HDW[id] == 64 && num(W_VAR[3][WPN[id]]) < 2)) {
				message_begin(MSG_ONE_UNRELIABLE,get_user_msgid("HideWeapon"),_,id)
				write_byte(CM[id])
				message_end
			}
			if(SC[id] != (SC[id] = (num(P_Cvar[4]) &&  ALIVE[id] && !SNIPER
					||  			num(P_Cvar[2]) &&  ALIVE[id] &&  SNIPER
					||  			num(P_Cvar[6]) && !ALIVE[id] && !SNIPER
					||  			num(P_Cvar[7]) && !ALIVE[id] &&  SNIPER
					||  			HDW[id] == 64 && num(W_VAR[2][WPN[id]]) == 2) && num(W_VAR[2][WPN[id]])) || STC_C_CHANGED[id] && SC[id] || HID_WPN[id] && !(HDW[id] == 64 && num(W_VAR[2][WPN[id]]) < 2)) {
				message_begin(MSG_ONE_UNRELIABLE,get_user_msgid("Crosshair"),_,id)
				write_byte(SC[id])
				message_end
				STC_C_CHANGED[id] = 0
			}
			HID_WPN[id] = 0
		}
		if(check_mdl[id]) {
			pev(ALIVE[id] ? id : pev(id,pev_iuser2),pev_viewmodel2,cur_mdl,48)
			for(new i; i<sizeof(term); i++) {
				if(containi(cur_mdl,term[i]) != -1) {
					mdl_visible_on_zoom[id] = 0
					break;
				}
			}
			cur_mdl=""
			check_mdl[id] = 0
		}
		if((!DEF_FOV || DEF_FOV && (!((1<<90 | 1<<0) & (1<<FM[id])) || !FM[id] && set_fov[id])) && get_fov[id] == 90) {
			if(!set_fov[id] && FM[id] && !(SNIPER && FM[id] == 90) || FM[id] != (FM[id] = (!DEF_FOV && !(SNIPER && !mdl_visible_on_zoom[id])) ? num(P_Cvar[13]) : 90)) {
				message_begin(MSG_ONE_UNRELIABLE,get_user_msgid("SetFOV"),_,id)
				write_byte(FM[id])
				message_end
				set_fov[id] = 1
				return FMRES_HANDLED
			}
			return FMRES_HANDLED
		}
		return FMRES_HANDLED
	}
	return FMRES_IGNORED
}

public On_Gun_Trigger(const ent) {
	if(((1<<1 | 1<<3) & (1<<num(P_Cvar[0]))) && num(W_VAR[1][WPN[r_id]]) != -1)
		fwd_trace = register_forward(FM_TraceLine,"fwTraceLine",1)
	return HAM_HANDLED
}

public fwTraceLine(const Float:start[3],Float:dest[3],const HIT_PARAM,const id,const ptr) {
	if(valid(id) && ALIVE[id] && !(NOSHOT & (1<<WPN[id]))) {
		if((!SHOTGUN || SHOTGUN && get_user_aiming(id,target,body,2000) && (num(P_Cvar[12]) ? target : body)) && ((1<<0) & (1<<HIT_PARAM))) {
			AM = num(num(P_Cvar[9]) == 1 && !SHOTGUN ? P_Cvar[10] : W_VAR[1][WPN[id]])
			velocity_by_aim(id,AM,dest)
			dest[0] = (start[0] + dest[0])
			dest[1] = (start[1] + dest[1])
			dest[2] = (start[2] + dest[2])
			engfunc(EngFunc_TraceLine,start,dest,HIT_PARAM,id,ptr)
			return FMRES_HANDLED
		}
		return FMRES_HANDLED
	}
	return FMRES_IGNORED
}

public Rec_Control(const ent,Float:push[2],Float:RM) {
	if(num(P_Cvar[0])) {
		if(((1<<1 | 1<<3) & (1<<num(P_Cvar[0])))) {
			unregister_forward(FM_TraceLine,fwd_trace,1)
			fwd_trace = 0
		}
		if(((1<<2 | 1<<3) & (1<<num(P_Cvar[0]))) && num(W_VAR[0][WPN[r_id]]) != -1) {
			RM = get_pcvar_float(num(P_Cvar[8]) == 1 ? P_Cvar[1] : W_VAR[0][WPN[r_id]])
			pev(r_id,pev_punchangle,push)
			push[0] = (push[0] * RM)
			push[1] = (push[1] * RM)
			set_pev(r_id,pev_punchangle,push)
			RM = RM * pev(r_id,pev_punchangle,push,"")
			return HAM_HANDLED
		}
		return HAM_HANDLED
	}
	return HAM_IGNORED
}

public plugin_end()
	Mod=""