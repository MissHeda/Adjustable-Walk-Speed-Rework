#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Puts a short message on screen as a hint.
 *
 * One place for every message the mod shows, so the look is the same whichever one it is and
 * whichever mods are loaded.
 *
 * Arguments:
 * 0: Message, structured text markup allowed <STRING>
 * 1: Seconds to stay up <NUMBER> (default: 2)
 *
 * Return Value:
 * None
 *
 * Example:
 * ["Too exhausted"] call awsr_movement_fnc_notify;
 *
 * Public: No
 */

params [["_text", ""], ["_seconds", 2]];

if (!hasInterface) exitWith {};
if (_text isEqualTo "") exitWith {};

hintSilent parseText _text;

// A hint stays until something replaces it, so it needs taking down again - and only by the call
// that put it up, or a quick second message would have the first one clear it.
GVAR(notifyToken) = GVAR(notifyToken) + 1;

[{
    if (GVAR(notifyToken) isEqualTo _this) then {hintSilent ""};
}, GVAR(notifyToken), _seconds] call CBA_fnc_waitAndExecute;
