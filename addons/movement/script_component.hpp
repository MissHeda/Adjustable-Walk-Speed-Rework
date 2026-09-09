#define COMPONENT movement
#define COMPONENT_BEAUTIFIED Speed Adjustment
#include "\z\awsr\addons\main\script_mod.hpp"
#include "\z\awsr\addons\main\script_macros.hpp"

#include "\a3\ui_f\hpp\defineCommonGrids.inc"

// How the new speed is shown - the order the CBA list setting offers them in.
// How many animation names the debug setting keeps on the clipboard.
// Per-animation speeds live in the same hashmap as the groups, under their own prefix.
#define ANIM_KEY(anim) ("anim:" + anim)
#define ANIM_MIN_SPEED 0.1

// How many key-to-animation slots there are. Ten is enough for a set of gestures without
// turning the settings page into a wall.
#define ANIMATION_SLOTS 10

// CBA reads 0 as "no key", which is what an unbound default is.
#define DIK_UNBOUND 0

#define DEBUG_ANIMATION_COUNT 20

// Kept here so the commas inside them never reach a macro argument list.
#define ARR_SEPARATOR ",<br/>"
#define DEBUG_MARKUP "<t size='1.1'>%1</t><br/><t size='1.2' color='#FFD766'>%2</t><br/><t size='0.85'>%3</t><br/><t size='0.8'>%4</t><br/><t size='0.75' color='#AAAAAA'>%5</t>"

#define DISPLAY_NONE 0
#define DISPLAY_HINT 1
#define DISPLAY_SYSTEMCHAT 2
#define DISPLAY_IGUI 3

// Controls of a speed display title.
#define IDC_SPEED_BACKGROUND 1000
#define IDC_SPEED_TEXT 1001

// Where a display sits before the player moves it in the layout tab. Each group gets its own
// row so all three can be up at once without covering each other.
// The same size as Arma's own stance indicator, which is 2.3 x 3.7 of the weapon-info grid -
// and IGUI_GRID_WEAPON_W/H are GUI_GRID_W/H (a3/ui_f/hpp/definecommongrids.inc:112).
#define DISPLAY_W (2.3 * GUI_GRID_W)
#define DISPLAY_H (3.7 * GUI_GRID_H)
#define DISPLAY_X ((safeZoneX + safeZoneW) - 3.8 * GUI_GRID_W)
#define DISPLAY_Y(row) (safeZoneY + 0.125 * safeZoneH + row * 4.1 * GUI_GRID_H)

// The autorun indicator sits low and centred, where it was before it became a display like the
// others - it is read while moving, not while aiming at it.
#define AUTORUN_X (safeZoneX + safeZoneW / 2 - 1.15 * GUI_GRID_W)
#define AUTORUN_Y (safeZoneY + 0.78 * safeZoneH)

// ---------------------------------------------------------------------------------- AUTORUN

// Animation "action" segments that mean the unit is in the water.
#define SWIM_ACTIONS ["sdv","bdv","dve","ssw","bsw","swm"]

// Autorun tiers, lowest first. Stepping down out of WALK ends the run.
// ACE's own fatigue thresholds - it blocks sprint at 0.7 and frees it at 0.6, forces a walk at
// 1 and lets go at 0.7. Matched so an ACE player meets one limit, not two.
#define FATIGUE_RUN_ENTER 0.6
#define FATIGUE_RUN_LEAVE 0.7
#define FATIGUE_JOG_ENTER 0.7
#define FATIGUE_JOG_LEAVE 1

// How a speed is written out
#define VALUE_PERCENT 0
#define VALUE_COEFFICIENT 1

#define AUTORUN_OFF 0
#define AUTORUN_WALK 1
#define AUTORUN_JOG 2
#define AUTORUN_RUN 3

// How long the stop keeps its damage handler on. Long enough for the frames the engine needs
// to settle the forced animation, short enough that it cannot be used to sit out a firefight.
#define STOP_DAMAGE_GRACE 0.25

// How long a stance transition owns the animation. A bound rather than the exact length - long
// enough that AnimDone and the update loop keep their hands off it, short enough that a
// transition which never lands does not freeze the run.
#define STANCE_TRANSITION_TIME 0.7

// Long enough that a breather is explained once, not once a frame.
#define EXHAUSTED_MESSAGE_COOLDOWN 6

// Where the player animations live, so a name can be checked before it is played.
#define ANIMATION_STATES (configFile >> "CfgMovesMaleSdr" >> "States")

// The autorun indicator is the same shape as a speed display - a picture plus a line of text -
// so it uses the same controls, the same update path and the same layout tab treatment.
#define AUTORUN_ICON_FRAMES 6

