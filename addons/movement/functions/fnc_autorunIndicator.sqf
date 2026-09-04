#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Redraws the autorun indicator, or takes it away when no run is going.
 *
 * One line: the pace the run is set to. It is the same kind of display as the three speed ones -
 * same controls, same update path, its own entry in the layout tab - so it can be moved and
 * resized like the rest.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call awsr_movement_fnc_autorunIndicator;
 *
 * Public: No
 */

if (!hasInterface) exitWith {};

if (!GVAR(autorun_active) || {!GVAR(IGUI_showAutorun)}) exitWith {
    [QGVAR(display_Autorun)] call FUNC(hideIGUI);
};

private _tier = switch (GVAR(autorun_tier)) do {
    case AUTORUN_WALK: {LLSTRING(AUTORUN_tier_walk)};
    case AUTORUN_JOG: {LLSTRING(AUTORUN_tier_jog)};
    default {LLSTRING(AUTORUN_tier_run)};
};

// Converted here rather than in the settings callback - see awsr_movement_fnc_displayUpdatedInfo.
private _color = [GVAR(IGUI_textColor_Autorun)] call FUNC(colorToHex);

[
    QGVAR(IGUI_Display_Autorun),
    QGVAR(display_Autorun),
    QUOTE(DOUBLES(IGUI,GVAR(grid_Autorun))),
    AUTORUN_X,
    AUTORUN_Y,
    1,
    "<t color='" + _color + "'>" + _tier + "</t>",
    GVAR(IGUI_textSize_Autorun),
    GVAR(IGUI_imageColor_Autorun),
    0
] call FUNC(updateIGUI);
