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

// Every key an action is bound to, as raw [dik, modifiers] entries.
private _keysOf = {
    params ["_action"];

    private _keybind = ["AWSR", _action] call CBA_fnc_getKeybind;
    if (isNil "_keybind") exitWith {[]};

    _keybind param [8, []]
};

// Keys that share a modifier are written with it once - CTRL + W / S rather than CTRL+W / CTRL+S.
private _readable = {
    params ["_binds"];

    if (_binds isEqualTo []) exitWith {""};

    private _modifiers = (_binds select 0) param [1, [false, false, false]];

    if (_binds findIf {(_x param [1, [false, false, false]]) isNotEqualTo _modifiers} > -1) exitWith {
        (_binds apply {toUpper (_x call CBA_fnc_localizeKey)}) joinString " / "
    };

    _modifiers params ["_shift", "_ctrl", "_alt"];

    private _prefix = "";
    if (_alt) then {_prefix = _prefix + (toUpper (localize "str_dik_alt")) + " + "};
    if (_ctrl) then {_prefix = _prefix + (toUpper (localize "str_dik_control")) + " + "};
    if (_shift) then {_prefix = _prefix + (toUpper (localize "str_dik_shift")) + " + "};

    _prefix + ((_binds apply {toUpper ([ARR_2(_x select 0,[ARR_3(false,false,false)])] call CBA_fnc_localizeKey)}) joinString " / ")
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

if (GVAR(IGUI_showAutorunPace)) then {
    _lines pushBack ("<t size='1.15'>" + _tierName + "</t>");
};

if (GVAR(IGUI_showAutorunKeys)) then {
    private _pace = [([QGVAR(autorun_fasterKey)] call _keysOf) + ([QGVAR(autorun_slowerKey)] call _keysOf)] call _readable;

    // Only worth naming when there is more than one animation to step between.
    private _pistol = ([player] call FUNC(autorunWeapon)) isEqualTo "pst";
    private _list = switch (GVAR(autorun_tier)) do {
        case AUTORUN_WALK: {[ARR_2(GVAR(autorun_animList_Walk),GVAR(autorun_animList_WalkPistol))] select _pistol};
        case AUTORUN_JOG: {[ARR_2(GVAR(autorun_animList_Jog),GVAR(autorun_animList_JogPistol))] select _pistol};
        default {[ARR_2(GVAR(autorun_animList_Run),GVAR(autorun_animList_RunPistol))] select _pistol};
    };

    // Empty when there is nothing to step to, so the line does not offer a key that does nothing.
    private _style = "";
    if (count _list > 1) then {
        _style = [[QGVAR(autorun_nextAnimationKey)] call _keysOf] call _readable;
    };

    private _stop = [([QGVAR(autorun_stopKey)] call _keysOf) + ([_tierAction] call _keysOf)] call _readable;

    // Each part is worded on its own and left out whole when it has no key, so a part that is
    // not available takes its label with it rather than leaving a bare "style:" behind.
    private _keyColor = [GVAR(IGUI_keyColor_Autorun)] call FUNC(colorToHex);
    private _parts = [];

    {
        _x params ["_keys", "_wording"];

        if (_keys == "") then {
            _parts pushBack "";
        } else {
            // Only the keys are recoloured - the wording around them stays the text colour.
            _parts pushBack (format [_wording, "<t color='" + _keyColor + "'>" + _keys + "</t>"]);
        };
    } forEach [
        [_pace, GVAR(IGUI_TextPace_Autorun)],
        [_style, GVAR(IGUI_TextStyle_Autorun)],
        [_stop, GVAR(IGUI_TextStop_Autorun)]
    ];

    _parts params ["_paceText", "_styleText", "_stopText"];

    private _line = format [GVAR(IGUI_Text_Autorun), _paceText, _styleText, _stopText];

    if (_line != "") then {
        _lines pushBack ("<t size='0.8'>" + _line + "</t>");
    };
};

// No text at all still leaves the picture: the run is on, and that is what the picture says.

// Converted here rather than in the settings callback - see awsr_movement_fnc_displayUpdatedInfo.
private _color = [GVAR(IGUI_textColor_Autorun)] call FUNC(colorToHex);

[
    QGVAR(IGUI_Display_Autorun),
    QGVAR(display_Autorun),
    QUOTE(DOUBLES(IGUI,GVAR(grid_Autorun))),
    AUTORUN_X,
    AUTORUN_Y,
    1 max count _lines,
    "<t color='" + _color + "'>" + (_lines joinString "<br/>") + "</t>",
    GVAR(IGUI_textSize_Autorun),
    GVAR(IGUI_imageColor_Autorun),
    0,
    9
] call FUNC(updateIGUI);
