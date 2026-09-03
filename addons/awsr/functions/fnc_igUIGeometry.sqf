#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Works out where a display's picture and its line of text go, from what the layout tab saved.
 *
 * Read every time something is shown rather than baked into the config, which is what ACE does
 * and the reason its elements move without restarting the game. The height is derived from the
 * width instead of being read, so dragging the box wide cannot stretch the picture out of shape.
 *
 * Arguments:
 * 0: IGUI grid variable, without the _X _Y _W _H suffix <STRING>
 * 1: Default x for this display <NUMBER>
 * 2: Default y for this display <NUMBER>
 * 3: Text size multiplier <NUMBER>
 * 4: Lines of text the box has to hold <NUMBER> (default: 1)
 *
 * Return Value:
 * 0: Picture position <ARRAY>
 * 1: Text position <ARRAY>
 * 2: Font height <NUMBER>
 *
 * Example:
 * [QUOTE(DOUBLES(IGUI,GVAR(grid_Walk))), DISPLAY_Y(0), 1, 1] call awsr_awsr_fnc_igUIGeometry;
 *
 * Public: No
 */

params ["_gridVar", ["_defaultX", 0], ["_defaultY", 0], ["_textSize", 1], ["_rows", 1]];

// A layout tab that saved something unusable - or nothing at all - must not leave a display at
// zero size, where it is on screen but impossible to find again.
private _read = {
    params ["_name", "_fallback"];

    private _value = profileNamespace getVariable [_name, _fallback];

    if (!(_value isEqualType 0) || {!finite _value}) exitWith {_fallback};

    _value
};

private _w = [_gridVar + "_W", DISPLAY_W] call _read;
if (_w <= 0.001) then {_w = DISPLAY_W};

private _x = [_gridVar + "_X", _defaultX] call _read;
private _y = [_gridVar + "_Y", _defaultY] call _read;

// Square in screen terms, whatever the grid was dragged to.
private _h = _w * GUI_GRID_H / GUI_GRID_W;

private _fontHeight = _h * 0.28 * _textSize;

// The text is wider than the picture and centred under it, so a long line has somewhere to go
// instead of being cut off at the edge of the artwork.
private _textW = _w * 3;

[
    [_x, _y, _w, _h],
    [_x + (_w - _textW) / 2, _y + _h, _textW, _fontHeight * 1.35 * _rows],
    _fontHeight
]
