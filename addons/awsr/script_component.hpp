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

// Controls of the custom IGUI title.
#define IDC_SPEED_BACKGROUND 1000
#define IDC_SPEED_TEXT 1001
