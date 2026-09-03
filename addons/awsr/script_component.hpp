#define COMPONENT awsr
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
