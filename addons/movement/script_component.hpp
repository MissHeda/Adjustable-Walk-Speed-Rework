#define COMPONENT movement
#define COMPONENT_BEAUTIFIED Speed Adjustment
#include "\z\awsr\addons\main\script_mod.hpp"
#include "\z\awsr\addons\main\script_macros.hpp"

#include "\a3\ui_f\hpp\defineCommonGrids.inc"

// How the new speed is shown - the order the CBA list setting offers them in.
#define DISPLAY_NONE 0
#define DISPLAY_HINT 1
#define DISPLAY_SYSTEMCHAT 2
#define DISPLAY_IGUI 3

// Controls of a speed display title.
#define IDC_SPEED_BACKGROUND 1000
#define IDC_SPEED_TEXT 1001

// Where a display sits before the player moves it in the layout tab. Each group gets its own
// row so all three can be up at once without covering each other.
#define DISPLAY_W (3.4 * GUI_GRID_W)
#define DISPLAY_H (3.4 * GUI_GRID_H)
#define DISPLAY_X ((safeZoneX + safeZoneW) - 3.8 * GUI_GRID_W)
#define DISPLAY_Y(row) (safeZoneY + 0.08 * safeZoneH + row * 3.9 * GUI_GRID_H)

// The autorun indicator sits low and centred, where it was before it became a display like the
// others - it is read while moving, not while aiming at it.
#define AUTORUN_X (safeZoneX + safeZoneW / 2 - 1.7 * GUI_GRID_W)
#define AUTORUN_Y (safeZoneY + 0.78 * safeZoneH)

// ---------------------------------------------------------------------------------- AUTORUN

// Animation "action" segments that mean the unit is in the water.
#define SWIM_ACTIONS ["sdv","bdv","dve","ssw","bsw","swm"]

// Autorun tiers, lowest first. Stepping down out of WALK ends the run.
#define AUTORUN_OFF 0
#define AUTORUN_WALK 1
#define AUTORUN_JOG 2
#define AUTORUN_RUN 3

// How long the stop keeps its damage handler on. Long enough for the frames the engine needs
// to settle the forced animation, short enough that it cannot be used to sit out a firefight.
#define STOP_DAMAGE_GRACE 0.25

// Where the player animations live, so a name can be checked before it is played.
#define ANIMATION_STATES (configFile >> "CfgMovesMaleSdr" >> "States")

// The autorun indicator is the same shape as a speed display - a picture plus a line of text -
// so it uses the same controls, the same update path and the same layout tab treatment.
#define AUTORUN_ICON_FRAMES 6

