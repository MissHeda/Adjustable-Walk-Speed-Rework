#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Turns a CBA colour setting into the hex code structured text wants.
 * Already converted values are handed straight back, so it is safe to run over a setting
 * whose callback fires more than once.
 *
 * Arguments:
 * 0: Colour <ARRAY> (RGB or RGBA, 0..1) or an already converted hex code <STRING>
 *
 * Return Value:
 * Hex colour code, e.g. "#FF8000" <STRING>
 *
 * Example:
 * private _hex = [1, 0.5, 0] call awsr_awsr_fnc_colorToHex;
 *
 * Public: No
 */

params [["_color", [1,1,1]]];

if (_color isEqualType "") exitWith {_color};
if (!(_color isEqualType []) || {count _color < 3}) exitWith {"#FFFFFF"};

private _digits = "0123456789ABCDEF";
private _hex = "#";

// Alpha is dropped - structured text takes RGB only.
{
    private _byte = round (255 * ((_x max 0) min 1));
    _hex = _hex + (_digits select [floor (_byte / 16), 1]) + (_digits select [_byte mod 16, 1]);
} forEach (_color select [0, 3]);

_hex
