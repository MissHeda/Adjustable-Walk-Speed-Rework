#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Redraws the animation indicator, or takes it away when no slot is playing.
 *
 * Placed and sized in the layout tab like every other display. It says which slot is running,
 * because a slot that loops has no other way of telling you it is still going - and no way of
 * telling you which key ends it.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call awsr_movement_fnc_animationIndicator;
 *
 * Public: No
 */

if (!hasInterface) exitWith {};

if (GVAR(animationSlotActive) == 0 || {!GVAR(IGUI_showAnimation)}) exitWith {
    [QGVAR(display_Animation)] call FUNC(hideIGUI);
};

// Converted here rather than in the settings callback - see awsr_movement_fnc_displayUpdatedInfo.
private _color = [GVAR(IGUI_textColor_Animation)] call FUNC(colorToHex);

private _text = "<t color='" + _color + "'>" +
    (format [GVAR(IGUI_Text_Animation), GVAR(animationSlotActive)]) + "</t>";

[
    QGVAR(IGUI_Display_Animation),
    QGVAR(display_Animation),
    QUOTE(DOUBLES(IGUI,GVAR(grid_Animation))),
    ANIMATION_X,
    ANIMATION_Y,
    1,
    _text,
    1,
    [0, 0, 0, 0],
    0,
    9
] call FUNC(updateIGUI);
