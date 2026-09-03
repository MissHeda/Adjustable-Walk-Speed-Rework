#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Works the run's direction out of the movement keys that are currently held, and remembers it.
 *
 * All eight directions the engine has come out of this: the straight key and the sideways key
 * are combined, so W+A is "fl" and S+D is "br". Opposite keys held at once cancel each other.
 *
 * Letting every key go does not reset anything. The run carries on the way it was last pointed
 * until another key says otherwise - the whole point of an autorun is not having to hold one.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Direction segment, e.g. "fl" <STRING>
 *
 * Example:
 * call awsr_awsr_fnc_autorunDirection;
 *
 * Public: No
 */

private _held = GVAR(autorun_heldKeys);

private _straight = "";
if ("f" in _held) then {_straight = "f"};
if ("b" in _held) then {_straight = ["b", ""] select ("f" in _held)};

private _sideways = "";
if ("l" in _held) then {_sideways = "l"};
if ("r" in _held) then {_sideways = ["r", ""] select ("l" in _held)};

private _direction = _straight + _sideways;

if (_direction != "") then {
    GVAR(autorun_direction) = _direction;
};

GVAR(autorun_direction)
