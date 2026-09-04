#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Redraws the autorun indicator, or takes it away when no run is going.
 *
 * Up to two lines: the pace, and what the keys do from here. Both can be switched off. The keys
 * are read from the bindings every time, so it names what the player actually has bound rather
 * than what it shipped with - including the pace key that ends the run, which is a different key
 * depending on the pace the run is in.
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

// Every key an action is bound to, readable.
private _keyNames = {
    params ["_action"];

    private _keybind = ["AWSR", _action] call CBA_fnc_getKeybind;
    if (isNil "_keybind") exitWith {[]};

    (_keybind param [8, []]) apply {toUpper (_x call CBA_fnc_localizeKey)}
};

// The pace decides both what it is called and which key ends it, since a pace key pressed on the
// pace it is already on is one of the ways out.
private _tier = switch (GVAR(autorun_tier)) do {
    case AUTORUN_WALK: {[LLSTRING(AUTORUN_tier_walk), QGVAR(autorun_walkKey)]};
    case AUTORUN_JOG: {[LLSTRING(AUTORUN_tier_jog), QGVAR(autorun_jogKey)]};
    default {[LLSTRING(AUTORUN_tier_run), QGVAR(autorun_runKey)]};
};
_tier params ["_tierName", "_tierAction"];

private _lines = [];

if (!GVAR(IGUI_hideAutorunPace)) then {
    _lines pushBack ("<t size='1.15'>" + _tierName + "</t>");
};

if (GVAR(IGUI_showAutorunKeys)) then {
    private _hints = [];

    private _pace = ([QGVAR(autorun_fasterKey)] call _keyNames) + ([QGVAR(autorun_slowerKey)] call _keyNames);
    if (_pace isNotEqualTo []) then {
        _hints pushBack format ["%1: %2", LLSTRING(AUTORUN_hint_pace), _pace joinString " / "];
    };

    // Only worth naming when there is more than one animation to step between.
    private _pistol = ([player] call FUNC(autorunWeapon)) isEqualTo "pst";
    private _list = switch (GVAR(autorun_tier)) do {
        case AUTORUN_WALK: {[ARR_2(GVAR(autorun_animList_Walk),GVAR(autorun_animList_WalkPistol))] select _pistol};
        case AUTORUN_JOG: {[ARR_2(GVAR(autorun_animList_Jog),GVAR(autorun_animList_JogPistol))] select _pistol};
        default {[ARR_2(GVAR(autorun_animList_Run),GVAR(autorun_animList_RunPistol))] select _pistol};
    };

    if (count _list > 1) then {
        private _style = [QGVAR(autorun_nextAnimationKey)] call _keyNames;

        if (_style isNotEqualTo []) then {
            _hints pushBack format ["%1: %2", LLSTRING(AUTORUN_hint_style), _style joinString " / "];
        };
    };

    private _stop = ([QGVAR(autorun_stopKey)] call _keyNames) + ([_tierAction] call _keyNames);
    if (_stop isNotEqualTo []) then {
        _hints pushBack format ["%1: %2", LLSTRING(AUTORUN_hint_stop), _stop joinString " / "];
    };

    if (_hints isNotEqualTo []) then {
        _lines pushBack ("<t size='0.8'>" + (_hints joinString "     ") + "</t>");
    };
};

if (_lines isEqualTo []) exitWith {
    [QGVAR(display_Autorun)] call FUNC(hideIGUI);
};

// Converted here rather than in the settings callback - see awsr_movement_fnc_displayUpdatedInfo.
private _color = [GVAR(IGUI_textColor_Autorun)] call FUNC(colorToHex);

[
    QGVAR(IGUI_Display_Autorun),
    QGVAR(display_Autorun),
    QUOTE(DOUBLES(IGUI,GVAR(grid_Autorun))),
    AUTORUN_X,
    AUTORUN_Y,
    count _lines,
    "<t color='" + _color + "'>" + (_lines joinString "<br/>") + "</t>",
    GVAR(IGUI_textSize_Autorun),
    GVAR(IGUI_imageColor_Autorun),
    0
] call FUNC(updateIGUI);
