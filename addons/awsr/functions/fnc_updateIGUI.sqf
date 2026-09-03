#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Puts one animation group's speed display on screen and schedules its hide.
 *
 * Each group owns its own title, its own layer and its own hide timer, so a change in one
 * group never takes another group's display away.
 *
 * Arguments:
 * 0: RscTitles class, also used as the layer name <STRING>
 * 1: uiNamespace variable the title parks its display under <STRING>
 * 2: Structured text to write <STRING>
 * 3: Font height <NUMBER>
 * 4: Picture colour <ARRAY>
 * 5: Seconds until it hides again, 0 to leave it up <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [QGVAR(IGUI_Display_Walk), QGVAR(display_Walk), "<t>70%</t>", 0.05, [1,1,1,1], 0] call awsr_awsr_fnc_updateIGUI;
 *
 * Public: No
 */

params ["_resource", "_uiVar", "_structuredText", "_fontHeight", "_imageColor", ["_duration", 0]];

private _write = {
    params ["_uiVar", "_structuredText", "_fontHeight", "_imageColor"];

    private _display = uiNamespace getVariable [_uiVar, displayNull];
    if (isNull _display) exitWith {};

    private _background = _display displayCtrl IDC_SPEED_BACKGROUND;
    private _label = _display displayCtrl IDC_SPEED_TEXT;

    _background ctrlSetTextColor _imageColor;

    _background ctrlShow true;
    _label ctrlShow true;

    // The structured text goes on last, and nothing on this control is committed as an
    // animation afterwards: ctrlCommit re-applies the control's own colorText and wipes the
    // colours parseText put into the markup, which is what stopped the text colour and the
    // limit colour from having any effect.
    _label ctrlSetFontHeight _fontHeight;
    _label ctrlSetStructuredText parseText _structuredText;
};

private _args = [_uiVar, _structuredText, _fontHeight, _imageColor];

if (isNull (uiNamespace getVariable [_uiVar, displayNull])) then {
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

// Every change to this group cancels the hide the change before it queued.
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
