#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Answers whether a pressed key is bound to one of autorun's own keybinds.
 *
 * While a run is going, the display handler turns every other key into a stop. It must leave
 * our own keys alone: CBA has its own handler for them and runs the action itself, and the
 * ignored key exists precisely so that it does not stop the run.
 *
 * Arguments:
 * 0: DIK code <NUMBER>
 * 1: Shift held <BOOL>
 * 2: Ctrl held <BOOL>
 * 3: Alt held <BOOL>
 *
 * Return Value:
 * The key belongs to one of our keybinds <BOOL>
 *
 * Example:
 * [_key, _shift, _ctrl, _alt] call awsr_autorun_fnc_isOwnKeybind;
 *
 * Public: No
 */

params ["_key", ["_shift", false], ["_ctrl", false], ["_alt", false]];

private _pressed = [_key, [_shift, _ctrl, _alt]];

(AUTORUN_KEY_ACTIONS findIf {
    private _keybind = ["AWSR", _x] call CBA_fnc_getKeybind;

    !isNil "_keybind" && {(_keybind param [8, []]) findIf {_x isEqualTo _pressed} > -1}
}) > -1
