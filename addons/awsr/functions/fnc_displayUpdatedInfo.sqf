#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Displays information about the currently set walk speed
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Value <NUMBER>
 * 2: Type <STRING> (walk, tactical, custom)
 * 3: ColorOverride <BOOL> (Optional)
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, 70, "walk", true] call awsr_core_fnc_displayUpdatedInfo;
 *
 * Public: No
 */

params ["_unit", "_value", "_type", "_displayInRedOverride"];

// To prevent errors from control
disableSerialization;

// Switch due to type provided
private _settingsType = -1;
private _maxAdjustSpeed = 0;
private _minAdjustSpeed = 0;
private _IGUItoDisplay = "";
private _text = "";
private _customTextColor = "";
private _customTextSize = 1;
private _showRedValueType = false;
private _textColorLimitReached = "";
_type = toLower _type;

switch (_type) do {
    case "walk": { 
        _settingsType = GVAR(speedUpdatedDisplayType_Walk);
        _maxAdjustSpeed = GVAR(maxAdjustSpeed_Walk);
        _minAdjustSpeed = GVAR(minAdjustSpeed_Walk);
        _IGUItoDisplay = QGVAR(IGUI_Display_Walk);
        _text = GVAR(IGUI_Text_Walk);
        _customTextColor = "<t color='" + GVAR(IGUI_textColor_Walk) + "'>";
        _customTextSize = GVAR(IGUI_textSize_Walk);
        _showRedValueType = GVAR(allowIGUIRedLimitValue_Walk);
        _textColorLimitReached = GVAR(IGUI_textColorLimitReached_Walk);
    };
    case "tactical": { 
        _settingsType = GVAR(speedUpdatedDisplayType_Tactical);
        _maxAdjustSpeed = GVAR(maxAdjustSpeed_Tactical);
        _minAdjustSpeed = GVAR(minAdjustSpeed_Tactical);
        _IGUItoDisplay = QGVAR(IGUI_Display_Tactical);
        _text = GVAR(IGUI_Text_Tactical);
        _customTextColor = "<t color='" + GVAR(IGUI_textColor_Tactical) + "'>";
        _customTextSize = GVAR(IGUI_textSize_Tactical);
        _showRedValueType = GVAR(allowIGUIRedLimitValue_Tactical);
        _textColorLimitReached = GVAR(IGUI_textColorLimitReached_Tactical);
    };
    case "custom": { 
        _settingsType = GVAR(speedUpdatedDisplayType_Custom);
        _maxAdjustSpeed = GVAR(maxAdjustSpeed_Custom);
        _minAdjustSpeed = GVAR(minAdjustSpeed_Custom);
        _IGUItoDisplay = QGVAR(IGUI_Display_Custom);
        _text = GVAR(IGUI_Text_Custom);
        _customTextColor = "<t color='" + GVAR(IGUI_textColor_Custom) + "'>";
        _customTextSize = GVAR(IGUI_textSize_Custom);
        _showRedValueType = GVAR(allowIGUIRedLimitValue_Custom);
        _textColorLimitReached = GVAR(IGUI_textColorLimitReached_Custom);
    };
};

// Get name and set to lowercase
private _displayCondition = ["None", "Hint", "Systemchat", "Custom"] select _settingsType;
_displayCondition = toLower _displayCondition;

// Get settings & apply color changes.
private _limitReached = "";
private _stringEnd = "</t>";
if ((((_value / 100) == _maxAdjustSpeed || (_value / 100) == _minAdjustSpeed) && _showRedValueType) || _displayInRedOverride) then {
    _limitReached = "<t color='" + _textColorLimitReached + "'>";
};

switch (_displayCondition) do {
    case "hint": { 
        hintSilent (parseText format ["%3" + _text + "%2", _limitReached + (str _value) + "%" + _customTextColor, _stringEnd, _customTextColor]);
    };
    case "systemchat": { 
        systemchat (format [_text, (str _value) + "%"]);
    };
    case "custom": {
        
        QGVAR(speedDisplay_onLoadSave) call BIS_fnc_rscLayer cutRsc [_IGUItoDisplay, "PLAIN", 1];

        // Get IGUI
        private _display = uiNamespace getvariable [QGVAR(speedDisplay_onLoadSave), displayNull];
        
        // Get textSize controll
        private _control = _display displayCtrl 1001;
        private _textSize = profileNamespace getVariable [QUOTE(TRIPLES(IGUI,GVAR(speedDisplay_Preset),H)), 0.136];
        _textSize = (_textSize * 0.357) * _customTextSize;

        _control ctrlSetStructuredText parseText format ["%3" + _text + "%2", _limitReached + (str _value) + "%" + _customTextColor, _stringEnd, _customTextColor];
        _control ctrlSetFontHeight _textSize;
    };
    default { };
};
