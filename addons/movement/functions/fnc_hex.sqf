#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * A number as fixed-width hex, for building colour markup.
 *
 * Arguments:
 * 0: Value <NUMBER>
 * 1: Digits <NUMBER> (default: 2)
 *
 * Return Value:
 * Hex digits, upper case <STRING>
 *
 * Example:
 * private _hex = [255, 2] call awsr_movement_fnc_hex;
 *
 * Public: No
 */

params [["_value", 0], ["_digits", 2]];

private _digitsOf = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"];

_value = round _value;

private _out = "";

for "_i" from 1 to _digits do {
    _out = (_digitsOf select (_value mod 16)) + _out;
    _value = floor (_value / 16);
};

_out
