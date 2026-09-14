#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Puts one display on screen and schedules its hide.
 *
 * Each display owns its own title, its own layer and its own hide timer, so one of them going
 * away never takes another with it. Position and size are read from the layout tab every time
 * rather than baked in when the title was cut, so moving one takes effect straight away.
 *
 * Arguments:
 * 0: RscTitles class, also used as the layer name <STRING>
 * 1: uiNamespace variable the title parks its display under <STRING>
 * 2: IGUI grid variable, without the _X _Y _W _H suffix <STRING>
 * 3: Default x for this display <NUMBER>
 * 4: Default y for this display <NUMBER>
 * 5: Lines of text <NUMBER>
 * 10: How many picture widths the text box is <NUMBER> (default: 3)
 * 6: Structured text to write <STRING>
 * 7: Text size multiplier <NUMBER>
 * 8: Picture colour <ARRAY>
 * 9: Seconds until it hides again, 0 to leave it up <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [QGVAR(IGUI_Display_Walk), QGVAR(display_Walk), "IGUI_awsr_movement_grid_Walk", 0.9, 0.2, 1, "<t>70%</t>", 1, [1,1,1,1], 0] call awsr_movement_fnc_updateIGUI;
 *
 * Public: No
 */

params [
    "_resource", "_uiVar", "_gridVar", "_defaultX", "_defaultY", ["_rows", 1],
    ["_structuredText", ""], ["_textSize", 1], ["_imageColor", [1,1,1,1]], ["_duration", 0],
    ["_widths", 3], ["_defaultW", DISPLAY_W], ["_defaultH", DISPLAY_H]
];

private _write = {
    params [
        "_uiVar", "_gridVar", "_defaultX", "_defaultY", "_rows", "_structuredText", "_textSize",
        "_imageColor", "_widths", "_defaultW", "_defaultH"
    ];

    private _display = uiNamespace getVariable [_uiVar, displayNull];
    if (isNull _display) exitWith {};

    ([_gridVar, _defaultX, _defaultY, _textSize, _rows, _widths, _defaultW, _defaultH] call FUNC(igUIGeometry)) params ["_picture", "_text", "_fontHeight"];

    private _background = _display displayCtrl IDC_SPEED_BACKGROUND;
    private _label = _display displayCtrl IDC_SPEED_TEXT;

    // A text-only display has no picture at all, and its text fills the box rather than sitting
    // under one.
    private _hasPicture = !isNull _background;

    if (_hasPicture) then {
        _background ctrlSetTextColor _imageColor;
        _background ctrlSetPosition _picture;
        _background ctrlCommit 0;
    } else {
        _text = _picture;
    };

    _label ctrlSetPosition _text;
    _label ctrlCommit 0;
    _label ctrlSetFontHeight _fontHeight;
    _label ctrlSetStructuredText parseText _structuredText;

    if (_hasPicture) then {_background ctrlShow true};
    _label ctrlShow true;
};

private _args = [_uiVar, _gridVar, _defaultX, _defaultY, _rows, _structuredText, _textSize, _imageColor, _widths, _defaultW, _defaultH];

if (isNull (uiNamespace getVariable [_uiVar, displayNull])) then {
    // The title is cut once and then kept for the rest of the mission. Cutting a fresh one per
    // change tears down the display the text is about to go into.
    (_resource call BIS_fnc_rscLayer) cutRsc [_resource, "PLAIN", 0, false];

    // cutRsc only creates the display on the next frame.
    [
        {!isNull (uiNamespace getVariable [_this select 0, displayNull])},
        _write,
        _args
    ] call CBA_fnc_waitUntilAndExecute;
} else {
    _args call _write;
};

// Every change to this display cancels the hide the change before it queued.
private _token = (GVAR(displayTokens) getOrDefault [_uiVar, 0]) + 1;
GVAR(displayTokens) set [_uiVar, _token];

if (_duration <= 0) exitWith {};

[
    {
        params ["_uiVar", "_token"];

        if ((GVAR(displayTokens) getOrDefault [_uiVar, 0]) != _token) exitWith {};

        [_uiVar] call FUNC(hideIGUI);
    },
    [_uiVar, _token],
    _duration
] call CBA_fnc_waitAndExecute;
