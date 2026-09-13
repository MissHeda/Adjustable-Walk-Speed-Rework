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

// The key that stops it, named from the binding the player actually has. A slot that loops has
// no other way of saying which key ends it, and a player who cannot find that key is stuck in an
// animation.
private _keyText = LLSTRING(ANIMATION_noKey);
private _keybind = ["AWSR", format [QGVAR(animationSlotKey_%1), GVAR(animationSlotActive)]] call CBA_fnc_getKeybind;

if (!isNil "_keybind") then {
    private _keys = _keybind param [8, []];

    if (_keys isNotEqualTo []) then {
        _keyText = toUpper ((_keys select 0) call CBA_fnc_localizeKey);
    };
};

private _text = "<t color='" + _color + "'>" +
    (format [GVAR(IGUI_Text_Animation), GVAR(animationSlotActive), _keyText]) + "</t>";

[
    QGVAR(IGUI_Display_Animation),
    QGVAR(display_Animation),
    QUOTE(DOUBLES(IGUI,GVAR(grid_Animation))),
    ANIMATION_X,
    ANIMATION_Y,
    2,
    _text,
    GVAR(IGUI_textSize_Animation),
    [0, 0, 0, 0],
    0,
    1,
    TEXT_DISPLAY_W,
    TEXT_DISPLAY_H
] call FUNC(updateIGUI);
