#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Decides which displays a change of speed should be seen on, and shows it there.
 *
 * Two rules, both of them about not saying more than is true:
 *
 * A group's display belongs to that group and appears only while that group has been moved off
 * default. It never shows a value another group or an animation put on the unit, and it is not
 * touched when the change came from somewhere else - the value it holds stays what it was.
 *
 * The custom display, while the custom category is adjusting animations rather than being a
 * group, is the one place that says what is actually in force right now, whatever set it. It
 * carries the range the custom keys can reach as a bar, so it is obvious both that the keys are
 * available and how far they go. It goes away a moment after the speed is back to normal, rather
 * than at once, so a value that flicks past is still readable.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Coefficient now in force <NUMBER>
 * 2: Animation group, "" for none <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, 1.4, "walk"] call awsr_movement_fnc_showSpeed;
 *
 * Public: No
 */

params ["_unit", ["_coef", 1], ["_type", ""]];

if (!hasInterface) exitWith {};

// The group's own display, only when the group itself is the reason.
if (_type isNotEqualTo "" && {_type isNotEqualTo "custom"}) then {
    private _group = (_unit call FUNC(getSpeedHashMap)) getOrDefault [_type, 1];

    if (_group != 1) then {
        [_unit, _group * 100, _type, false, ""] call FUNC(displayUpdatedInfo);
    };
};

if (GVAR(customMode) != CUSTOM_MODE_ANIMATION) exitWith {};

// Back to normal: leave it up for a moment, then take it down - but only if nothing else has
// been shown in the meantime.
if (_coef == 1) exitWith {
    private _token = GVAR(customToken) + 1;
    GVAR(customToken) = _token;

    [{
        if (GVAR(customToken) isEqualTo _this) then {
            [QGVAR(display_Custom)] call FUNC(hideIGUI);
        };
    }, _token, CUSTOM_FADE_TIME] call CBA_fnc_waitAndExecute;
};

GVAR(customToken) = GVAR(customToken) + 1;

([_unit, animationState _unit] call FUNC(customBounds)) params ["_low", "_high"];

private _valueText = if (GVAR(valueStyle) == VALUE_COEFFICIENT) then {
    str ([_coef, 2] call BIS_fnc_cutDecimals)
} else {
    str round (_coef * 100) + "%"
};

private _color = [GVAR(IGUI_textColor_Custom)] call FUNC(colorToHex);

// At the limits the value takes the limit colour, the same as a group display does.
if (_coef <= _low || {_coef >= _high}) then {
    _color = [GVAR(IGUI_textColorLimitReached_Custom)] call FUNC(colorToHex);
};

private _text = "<t color='" + _color + "'>" +
    (format [GVAR(IGUI_Text_Custom), _valueText, "", ""]) + "</t><br/>" +
    ([_low, _high, _coef] call FUNC(speedSlider));

[
    QGVAR(IGUI_Display_Custom),
    QGVAR(display_Custom),
    QUOTE(DOUBLES(IGUI,GVAR(grid_Custom))),
    DISPLAY_X,
    DISPLAY_Y(2),
    2,
    _text,
    GVAR(IGUI_textSize_Custom),
    GVAR(IGUI_imageColor_Custom),
    0
] call FUNC(updateIGUI);
