#include "..\script_component.hpp"
/*
 * Author: leonz2019, Miss Heda
 * Fills in the run indicator: the stop hint and the running figure animation.
 *
 * Arguments:
 * 0: Indicator display <DISPLAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * _this call awsr_autorun_fnc_onload;
 *
 * Public: No
 */

params ["_display"];

private _hint = _display displayCtrl IDC_INDICATOR_HINT;

if (call FUNC(hasStopKey)) then {
    private _keybind = ((["AWSR", QGVAR(stopKey)] call CBA_fnc_getKeybind) select 8) select 0;
    _hint ctrlSetText format [LLSTRING(HUD_StopKey), toUpper (_keybind call CBA_fnc_localizeKey)];
} else {
    _hint ctrlSetText LLSTRING(HUD_StopAnyKey);
};

[_display displayCtrl IDC_INDICATOR_ICON] spawn {
    params ["_ctrl"];

    private _id = 1;

    // Stops with the run, and with the indicator being cut - not, as it used to, only when
    // the player dies.
    while {sleep 0.1; GVAR(active) && {!isNull _ctrl}} do {
        _ctrl ctrlSetText format [QPATHTOF(running\run_0%1.paa), _id];
        _id = if (_id >= 6) then {1} else {_id + 1};
    };
};
