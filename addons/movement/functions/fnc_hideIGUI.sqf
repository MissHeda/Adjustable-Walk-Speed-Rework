#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Takes one animation group's speed display off screen.
 *
 * The title itself stays alive and keeps its place in the layout - only its controls are
 * hidden. Cutting the title away and back is what used to blank the number.
 *
 * Arguments:
 * 0: uiNamespace variable the title parks its display under <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * [QGVAR(display_Walk)] call awsr_movement_fnc_hideIGUI;
 *
 * Public: No
 */

params ["_uiVar"];

// A hide queued before this one has nothing left to do.
GVAR(displayTokens) set [_uiVar, (GVAR(displayTokens) getOrDefault [_uiVar, 0]) + 1];

private _display = uiNamespace getVariable [_uiVar, displayNull];
if (isNull _display) exitWith {};

{
    _x ctrlShow false;
} forEach [_display displayCtrl IDC_SPEED_BACKGROUND, _display displayCtrl IDC_SPEED_TEXT];
