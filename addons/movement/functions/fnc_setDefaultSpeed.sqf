#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Sets the speed the unit falls back to outside a whitelisted animation, optionally for a
 * limited time. Meant for missions and other mods that want a temporary global slowdown.
 *
 * Calling it again before an earlier reset is due cancels that reset, so back to back calls
 * no longer have the first timer clear the value the second one just set.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Speed <NUMBER>
 * 2: Seconds until it goes back to 1, or -1 to keep it <NUMBER> (default: -1)
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, 1.2, -1] call awsr_movement_fnc_setDefaultSpeed;
 *
 * Public: Yes
 */

params ["_unit", ["_speed", 1], ["_time", -1]];

(_unit call FUNC(getSpeedHashMap)) set ["defaultSpeed", _speed];

// Takes effect now rather than at the next animation change.
[_unit, animationState _unit] call FUNC(handleAnimation);

if (_time <= 0) exitWith {};

private _token = GETVAR(_unit,GVAR(defaultSpeedToken),0) + 1;
SETVAR(_unit,GVAR(defaultSpeedToken),_token);

[
    {
        params ["_unit", "_token"];

        if (GETVAR(_unit,GVAR(defaultSpeedToken),0) != _token) exitWith {};

        (_unit call FUNC(getSpeedHashMap)) set ["defaultSpeed", 1];
        [_unit, animationState _unit] call FUNC(handleAnimation);
    },
    [_unit, _token],
    _time
] call CBA_fnc_waitAndExecute;
