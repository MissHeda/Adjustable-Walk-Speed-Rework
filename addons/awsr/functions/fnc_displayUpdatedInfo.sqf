#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Shows the speed that was just set, as a hint, a system chat line or the custom IGUI.
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
            QPATHTOF(assets\ui\IGUI_Display_Walk.paa), GVAR(IGUI_imageColor_Walk),
            GVAR(IGUI_Text_Walk), GVAR(IGUI_textColor_Walk), GVAR(IGUI_textSize_Walk),
            GVAR(allowIGUIRedLimitValue_Walk), GVAR(IGUI_textColorLimitReached_Walk),
            GVAR(IGUI_displayDuration_Walk)
        ]
    };
    case "tactical": {
        [
            GVAR(speedUpdatedDisplayType_Tactical), GVAR(minAdjustSpeed_Tactical), GVAR(maxAdjustSpeed_Tactical),
            QPATHTOF(assets\ui\IGUI_Display_Tactical.paa), GVAR(IGUI_imageColor_Tactical),
            GVAR(IGUI_Text_Tactical), GVAR(IGUI_textColor_Tactical), GVAR(IGUI_textSize_Tactical),
            GVAR(allowIGUIRedLimitValue_Tactical), GVAR(IGUI_textColorLimitReached_Tactical),
            GVAR(IGUI_displayDuration_Tactical)
        ]
    };
    case "custom": {
        [
            GVAR(speedUpdatedDisplayType_Custom), GVAR(minAdjustSpeed_Custom), GVAR(maxAdjustSpeed_Custom),
            QPATHTOF(assets\ui\IGUI_Display_Default.paa), GVAR(IGUI_imageColor_Custom),
            GVAR(IGUI_Text_Custom), GVAR(IGUI_textColor_Custom), GVAR(IGUI_textSize_Custom),
            GVAR(allowIGUIRedLimitValue_Custom), GVAR(IGUI_textColorLimitReached_Custom),
            GVAR(IGUI_displayDuration_Custom)
        ]
    };
    default {[]};
};

if (_settings isEqualTo []) exitWith {};

_settings params [
    "_displayType", "_min", "_max", "_picture", "_imageColor",
    "_format", "_color", "_size", "_showLimit", "_limitColor", "_duration"
];

if (_displayType == DISPLAY_NONE) exitWith {};

private _valueText = str _value + "%";

if (_limitReached || {_showLimit && {_value / 100 == _min || {_value / 100 == _max}}}) then {
    _valueText = "<t color='" + _limitColor + "'>" + _valueText;
};

private _open = "<t color='" + _color + "'>";

// The same three arguments the custom text has always had: %1 value, %2 closing tag, %3 colour.
private _text = format ["%3" + _format + "%2", _valueText + _open, "</t>", _open];

switch (_displayType) do {
    case DISPLAY_HINT: {
        hintSilent parseText _text;
    };

    case DISPLAY_SYSTEMCHAT: {
        systemChat format [_format, str _value + "%"];
    };

    case DISPLAY_IGUI: {
        private _fontHeight = (profileNamespace getVariable [QUOTE(TRIPLES(IGUI,GVAR(speedDisplay_Preset),H)), 0.136]) * 0.357 * _size;

        private _write = {
            params ["_structuredText", "_fontHeight", "_picture", "_imageColor"];

            private _display = uiNamespace getVariable [QGVAR(speedDisplay_onLoadSave), displayNull];
            if (isNull _display) exitWith {};

            private _background = _display displayCtrl IDC_SPEED_BACKGROUND;
            _background ctrlSetText _picture;
            _background ctrlSetTextColor _imageColor;

            private _label = _display displayCtrl IDC_SPEED_TEXT;
            _label ctrlSetStructuredText parseText _structuredText;
            _label ctrlSetFontHeight _fontHeight;

            {
                _x ctrlSetFade 0;
                _x ctrlCommit 0;
            } forEach [_background, _label];
        };

        private _payload = [_text, _fontHeight, _picture, _imageColor];

        if (isNull (uiNamespace getVariable [QGVAR(speedDisplay_onLoadSave), displayNull])) then {
            // The title is cut once and then kept for the rest of the mission. cutRsc only
            // creates the display on the next frame, so the first write has to wait for it.
            (QGVAR(speedDisplay) call BIS_fnc_rscLayer) cutRsc [QGVAR(IGUI_Display), "PLAIN", 0, false];

            [
                {!isNull (uiNamespace getVariable [QGVAR(speedDisplay_onLoadSave), displayNull])},
                _write,
                _payload
            ] call CBA_fnc_waitUntilAndExecute;
        } else {
            _payload call _write;
        };

        // Every change cancels the hide the change before it queued.
        GVAR(displayToken) = GVAR(displayToken) + 1;

        if (_duration > 0) then {
            [
                {
                    params ["_token"];

                    if (_token != GVAR(displayToken)) exitWith {};

                    private _display = uiNamespace getVariable [QGVAR(speedDisplay_onLoadSave), displayNull];
                    if (isNull _display) exitWith {};

                    {
                        _x ctrlSetFade 1;
                        _x ctrlCommit 0.2;
                    } forEach [_display displayCtrl IDC_SPEED_BACKGROUND, _display displayCtrl IDC_SPEED_TEXT];
                },
                [GVAR(displayToken)],
                _duration
            ] call CBA_fnc_waitAndExecute;
        };
    };

    default {};
};
