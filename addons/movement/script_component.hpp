#define COMPONENT movement
#define COMPONENT_BEAUTIFIED Speed Adjustment
#include "\z\awsr\addons\main\script_mod.hpp"
#include "\z\awsr\addons\main\script_macros.hpp"

#include "\a3\ui_f\hpp\defineCommonGrids.inc"

// How the new speed is shown - the order the CBA list setting offers them in.
// How many animation names the debug setting keeps on the clipboard.
// Per-animation speeds live in the same hashmap as the groups, under their own prefix.
#define ANIM_KEY(anim) ("anim:" + toLowerANSI (anim))
#define ANIM_MIN_SPEED 0.1

// How many key-to-animation slots there are. Ten is enough for a set of gestures without
// turning the settings page into a wall.
// The unit the player is actually driving. `player` and this one part company under Zeus remote
// control, which is why a speed set while controlling a puppet used to land on the player's own
// body instead - CBA's player event handler watches this, not `player`.
#define CURRENT_UNIT (call CBA_fnc_currentUnit)

// The animation indicator sits above the autorun one, in the same column.
#define TEXT_DISPLAY_W (14 * GUI_GRID_W)
#define TEXT_DISPLAY_H (1.2 * GUI_GRID_H)

#define ANIMATION_X (safeZoneX + safeZoneW / 2 - 7 * GUI_GRID_W)
#define ANIMATION_Y (safeZoneY + 0.72 * safeZoneH)

#define ANIMATION_SLOTS 10

// CBA reads 0 as "no key", which is what an unbound default is.
#define DIK_UNBOUND 0

// The custom category is either a third animation group or the thing that adjusts one animation
// at a time. The second is the default: the group was switched off out of the box anyway, and
// per-animation speeds are the reason most people open it.
// Who is deciding the speed right now.
// What a display says about its own value: nothing, "this is the one in force", or "something
// else is winning over this".
#define MARKER_NONE 0
#define MARKER_ACTIVE 1
#define MARKER_OVERRIDDEN 2

#define SOURCE_NONE 0
#define SOURCE_PINNED 1
#define SOURCE_GROUP 2
#define SOURCE_MANUAL 3

#define CUSTOM_MODE_GROUP 0
#define CUSTOM_MODE_ANIMATION 1

// The bar under the custom display. An odd count so there is a true middle cell for default
// speed, and box-drawing characters because RobotoCondensed has them at a consistent width.
#define SPEED_SLIDER_CELLS 21
#define SPEED_SLIDER_TRACK "-"
#define SPEED_SLIDER_MARK "|"
#define SPEED_SLIDER_MARKUP "<t size='0.7'>%1 %2 %3</t>"

// How long the custom display stays after the speed is back to normal.
#define CUSTOM_FADE_TIME 1.5

// The same grace for every display that is set to hide at default speed.
#define DEFAULT_HIDE_DELAY 1.5

#define DEBUG_LEGEND_MARKUP "<t size='0.7' color='#00FF00'>%1</t><t size='0.7' color='#AAAAAA'> - </t><t size='0.7' color='#FF0000'>%2</t>"
#define DEBUG_ANIMATION_COUNT 20
#define DEBUG_REFRESH_INTERVAL 0.25

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
// As wide as Arma's own stance indicator, which is 2.3 of the weapon-info grid - and
// IGUI_GRID_WEAPON_W/H are GUI_GRID_W/H (a3/ui_f/hpp/definecommongrids.inc:112). The height is
// the same count of cells rather than the indicator's 3.7: that shape is drawn for a standing
// figure, and this artwork is square, so matching it exactly only squashed it.
#define DISPLAY_W (2.3 * GUI_GRID_W)
#define DISPLAY_H (2.3 * GUI_GRID_H)
#define DISPLAY_X ((safeZoneX + safeZoneW) - 3.8 * GUI_GRID_W)
#define DISPLAY_Y(row) (safeZoneY + 0.105 * safeZoneH + row * 4.1 * GUI_GRID_H)

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

