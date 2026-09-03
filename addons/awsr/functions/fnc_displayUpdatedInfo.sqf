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
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, 70, "walk", false] call awsr_awsr_fnc_displayUpdatedInfo;
 *
 * Public: No
 */

params ["_unit", ["_value", 100], ["_type", ""], ["_limitReached", false]];

if (!hasInterface) exitWith {};

disableSerialization;

_type = toLowerANSI _type;

private _settings = switch (_type) do {
    case "walk": {
        [
            GVAR(speedUpdatedDisplayType_Walk), GVAR(minAdjustSpeed_Walk), GVAR(maxAdjustSpeed_Walk),
            QGVAR(IGUI_Display_Walk), QGVAR(display_Walk), QUOTE(TRIPLES(IGUI,GVAR(grid_Walk),H)),
            GVAR(IGUI_imageColor_Walk), GVAR(IGUI_Text_Walk), GVAR(IGUI_textColor_Walk),
            GVAR(IGUI_textSize_Walk), GVAR(allowIGUIRedLimitValue_Walk),
            GVAR(IGUI_textColorLimitReached_Walk), GVAR(IGUI_displayDuration_Walk),
            GVAR(IGUI_hideAtDefault_Walk)
        ]
    };
    case "tactical": {
        [
            GVAR(speedUpdatedDisplayType_Tactical), GVAR(minAdjustSpeed_Tactical), GVAR(maxAdjustSpeed_Tactical),
            QGVAR(IGUI_Display_Tactical), QGVAR(display_Tactical), QUOTE(TRIPLES(IGUI,GVAR(grid_Tactical),H)),
            GVAR(IGUI_imageColor_Tactical), GVAR(IGUI_Text_Tactical), GVAR(IGUI_textColor_Tactical),
            GVAR(IGUI_textSize_Tactical), GVAR(allowIGUIRedLimitValue_Tactical),
            GVAR(IGUI_textColorLimitReached_Tactical), GVAR(IGUI_displayDuration_Tactical),
            GVAR(IGUI_hideAtDefault_Tactical)
        ]
    };
    case "custom": {
        [
            GVAR(speedUpdatedDisplayType_Custom), GVAR(minAdjustSpeed_Custom), GVAR(maxAdjustSpeed_Custom),
            QGVAR(IGUI_Display_Custom), QGVAR(display_Custom), QUOTE(TRIPLES(IGUI,GVAR(grid_Custom),H)),
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
    "_displayType", "_min", "_max", "_resource", "_uiVar", "_gridHeightVar",
    "_imageColor", "_format", "_color", "_size", "_showLimit",
    "_limitColor", "_duration", "_hideAtDefault"
];

if (_displayType == DISPLAY_NONE) exitWith {};

private _valueText = str _value + "%";

if (_limitReached || {_showLimit && {_value / 100 == _min || {_value / 100 == _max}}}) then {
    _valueText = "<t color='" + _limitColor + "'>" + _valueText + "</t>";
};

// %1 is the value. %2 and %3 used to be the raw closing tag and the colour tag, back when the
// markup was assembled out of them; they are kept as empty so an old custom text still works.
private _text = "<t color='" + _color + "'>" + (format [_format, _valueText, "", ""]) + "</t>";

switch (_displayType) do {
    case DISPLAY_HINT: {
        hintSilent parseText _text;
    };

    case DISPLAY_SYSTEMCHAT: {
        systemChat format [_format, str _value + "%", "", ""];
    };

    case DISPLAY_IGUI: {
        // Back at the default speed and set to get out of the way.
        if (_hideAtDefault && {_value == 100}) exitWith {
            [_uiVar] call FUNC(hideIGUI);
        };

        private _fontHeight = (profileNamespace getVariable [_gridHeightVar, DISPLAY_H]) * 0.357 * _size;

        [_resource, _uiVar, _text, _fontHeight, _imageColor, _duration] call FUNC(updateIGUI);
    };

    default {};
};
