#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Shows the speed that was just set, as a hint, a system chat line or the group's own IGUI.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Value in percent <NUMBER>
 * 2: Animation group - "walk", "tactical" or "custom" <STRING>
 * 3: Draw the value in the limit colour <BOOL> (default: false)
 * 4: Why the value was capped, already localised - "" for no reason <STRING> (default: "")
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, 70, "walk", false, ""] call awsr_movement_fnc_displayUpdatedInfo;
 *
 * Public: No
 */

params ["_unit", ["_value", 100], ["_type", ""], ["_limitReached", false], ["_reason", ""]];

if (!hasInterface) exitWith {};

disableSerialization;

_type = toLowerANSI _type;

private _settings = switch (_type) do {
    case "walk": {
        [
            GVAR(speedUpdatedDisplayType_Walk), GVAR(minAdjustSpeed_Walk), GVAR(maxAdjustSpeed_Walk),
            QGVAR(IGUI_Display_Walk), QGVAR(display_Walk), QUOTE(DOUBLES(IGUI,GVAR(grid_Walk))), DISPLAY_X, DISPLAY_Y(0),
            GVAR(IGUI_imageColor_Walk), GVAR(IGUI_Text_Walk), GVAR(IGUI_textColor_Walk),
            GVAR(IGUI_textSize_Walk), GVAR(allowIGUIRedLimitValue_Walk),
            GVAR(IGUI_textColorLimitReached_Walk), GVAR(IGUI_displayDuration_Walk),
            GVAR(IGUI_hideAtDefault_Walk)
        ]
    };
    case "tactical": {
        [
            GVAR(speedUpdatedDisplayType_Tactical), GVAR(minAdjustSpeed_Tactical), GVAR(maxAdjustSpeed_Tactical),
            QGVAR(IGUI_Display_Tactical), QGVAR(display_Tactical), QUOTE(DOUBLES(IGUI,GVAR(grid_Tactical))), DISPLAY_X, DISPLAY_Y(1),
            GVAR(IGUI_imageColor_Tactical), GVAR(IGUI_Text_Tactical), GVAR(IGUI_textColor_Tactical),
            GVAR(IGUI_textSize_Tactical), GVAR(allowIGUIRedLimitValue_Tactical),
            GVAR(IGUI_textColorLimitReached_Tactical), GVAR(IGUI_displayDuration_Tactical),
            GVAR(IGUI_hideAtDefault_Tactical)
        ]
    };
    case "custom": {
        [
            GVAR(speedUpdatedDisplayType_Custom), GVAR(minAdjustSpeed_Custom), GVAR(maxAdjustSpeed_Custom),
            QGVAR(IGUI_Display_Custom), QGVAR(display_Custom), QUOTE(DOUBLES(IGUI,GVAR(grid_Custom))), DISPLAY_X, DISPLAY_Y(2),
            GVAR(IGUI_imageColor_Custom), GVAR(IGUI_Text_Custom), GVAR(IGUI_textColor_Custom),
            GVAR(IGUI_textSize_Custom), GVAR(allowIGUIRedLimitValue_Custom),
            GVAR(IGUI_textColorLimitReached_Custom), GVAR(IGUI_displayDuration_Custom),
            GVAR(IGUI_hideAtDefault_Custom)
        ]
    };
    default {[]};
};

if (_settings isEqualTo []) exitWith {};

_settings params [
    "_displayType", "_min", "_max", "_resource", "_uiVar", "_gridVar", "_defaultX", "_defaultY",
    "_imageColor", "_format", "_color", "_size", "_showLimit",
    "_limitColor", "_duration", "_hideAtDefault"
];

// Converted here rather than in the settings callback, so it does not matter whether CBA has
// handed the setting back as an array or a hex string.
//
// The colour goes in wrapped in an array. `_colour call fnc` makes the colour itself the
// argument list, so params pulls its first element out and hands the function a number - which
// it rejects, returning white. That is why no colour setting ever did anything.
_color = [_color] call FUNC(colorToHex);
_limitColor = [_limitColor] call FUNC(colorToHex);

if (_displayType == DISPLAY_NONE) exitWith {};

// Percent reads better for most people; the coefficient is what setAnimSpeedCoef actually takes,
// which is what a mission maker wants to see.
private _valueText = if (GVAR(valueStyle) == VALUE_COEFFICIENT) then {
    str ([_value / 100, 2] call BIS_fnc_cutDecimals)
} else {
    str _value + "%"
};

if (_limitReached || {_showLimit && {_value / 100 == _min || {_value / 100 == _max}}}) then {
    _valueText = "<t color='" + _limitColor + "'>" + _valueText + "</t>";
};

// %1 is the value. %2 and %3 used to be the raw closing tag and the colour tag, back when the
// markup was assembled out of them; they are kept as empty so an old custom text still works.
private _text = "<t color='" + _color + "'>" + (format [_format, _valueText, "", ""]) + "</t>";

// A capped value on its own only says "it stopped here". The reason says why, in the limit
// colour, so it reads as belonging to the cap rather than as a second value.
private _rows = 1;
if (_reason != "") then {
    _text = _text + "<br/><t size='0.75' color='" + _limitColor + "'>" + _reason + "</t>";
    _rows = 2;
};

switch (_displayType) do {
    case DISPLAY_HINT: {
        hintSilent parseText _text;
    };

    case DISPLAY_SYSTEMCHAT: {
        private _line = format [_format, _valueText, "", ""];
        if (_reason != "") then {_line = _line + " - " + _reason};
        systemChat _line;
    };

    case DISPLAY_IGUI: {
        // Back at the default speed and set to get out of the way.
        if (_hideAtDefault && {_value == 100}) exitWith {
            [_uiVar] call FUNC(hideIGUI);
        };

        [_resource, _uiVar, _gridVar, _defaultX, _defaultY, _rows, _text, _size, _imageColor, _duration] call FUNC(updateIGUI);
    };

    default {};
};
