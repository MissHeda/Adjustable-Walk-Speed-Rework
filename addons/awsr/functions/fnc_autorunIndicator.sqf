#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Redraws the autorun indicator, or takes it away when no run is going.
 *
 * Two lines: the pace the run is set to, and what the keys do from here. Which keys those are
 * is read from the bindings every time, so it says what the player actually has bound.
 *
 * It is the same kind of display as the three speed ones - same controls, same update path,
 * its own entry in the layout tab - so it can be moved and resized like the rest.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call awsr_awsr_fnc_autorunIndicator;
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

// What one of our own keybinds is bound to right now, readable.
private _keyName = {
    params ["_action"];

    private _keybind = ["AWSR", _action] call CBA_fnc_getKeybind;
    if (isNil "_keybind") exitWith {""};

    private _keys = _keybind param [8, []];
    if (_keys isEqualTo []) exitWith {""};

    toUpper ((_keys select 0) call CBA_fnc_localizeKey)
};

private _hints = [];

// Only worth mentioning once there is something to switch to.
if (GVAR(autorun_styleList) isNotEqualTo []) then {
    private _key = [QGVAR(autorun_styleKey)] call _keyName;

    if (_key != "") then {
        _hints pushBack format [
            "%1 " + LLSTRING(AUTORUN_style),
            _key,
            GVAR(autorun_styleIndex),
            count GVAR(autorun_styleList)
        ];
    };
};

private _pace = [[QGVAR(autorun_fasterKey)] call _keyName, [QGVAR(autorun_slowerKey)] call _keyName] select {_x != ""};

if (_pace isNotEqualTo []) then {
    _hints pushBack format ["%1 %2", _pace joinString "/", LLSTRING(AUTORUN_hint_pace)];
};

// Any movement key ends the run, so the forward key stands in for all of them.
private _move = actionKeysNamesArray "MoveForward";

if (_move isNotEqualTo []) then {
    _hints pushBack format ["%1 %2", toUpper (_move select 0), LLSTRING(AUTORUN_hint_stop)];
};

private _lines = ["<t size='1.15'>" + _tier + "</t>"];

if (_hints isNotEqualTo []) then {
    _lines pushBack ("<t size='0.8'>" + (_hints joinString "   ") + "</t>");
};

// Converted here rather than in the settings callback - see awsr_awsr_fnc_displayUpdatedInfo.
private _color = [GVAR(IGUI_textColor_Autorun)] call FUNC(colorToHex);
private _text = "<t color='" + _color + "'>" + (_lines joinString "<br/>") + "</t>";

[
    QGVAR(IGUI_Display_Autorun),
    QGVAR(display_Autorun),
    QUOTE(DOUBLES(IGUI,GVAR(grid_Autorun))),
    AUTORUN_X,
    AUTORUN_Y,
    count _lines,
    _text,
    GVAR(IGUI_textSize_Autorun),
    GVAR(IGUI_imageColor_Autorun),
    0
] call FUNC(updateIGUI);
