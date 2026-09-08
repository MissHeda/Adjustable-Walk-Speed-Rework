#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Puts a short message on screen, the way ACE puts one there.
 *
 * A hint takes over the whole top right corner and stays until something replaces it, which is
 * far too much for "too exhausted". ACE's own notification is the right size and the right
 * place, and where ACE is loaded this is that function - so the mod's messages sit with every
 * other message the player is already used to reading.
 *
 * Without ACE it falls back to a hint, which is the only thing vanilla offers that does not
 * scroll away in the chat.
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

if (isClass (configFile >> "CfgPatches" >> "ace_common")) exitWith {
    [parseText _text, 1.5, nil, _seconds] call ACEFUNC(common,displayTextStructured);
};

hintSilent parseText _text;

// A hint stays until something replaces it, so it needs taking down again - and only by the call
// that put it up, or a quick second message would have the first one clear it.
GVAR(notifyToken) = GVAR(notifyToken) + 1;

[{
    if (GVAR(notifyToken) isEqualTo _this) then {hintSilent ""};
}, GVAR(notifyToken), _seconds] call CBA_fnc_waitAndExecute;
