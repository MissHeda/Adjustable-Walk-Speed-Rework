#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Redraws every speed display to match what is actually in force.
 *
 * One place, called from the animation handler and from the keys, so the three displays can
 * never disagree with each other or with the unit. Each one answers for its own group and for
 * nothing else.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player] call awsr_movement_fnc_refreshDisplays;
 *
 * Public: No
 */

params ["_unit"];

if (!hasInterface) exitWith {};
if !(_unit isEqualTo CURRENT_UNIT) exitWith {};

// Each display is only touched when what it would say has changed. Redrawing all three on every
// change restarted all three hide timers, so a walk change kept the tactical display on screen
// for exactly as long - and simply pressing W brought the tactical one up saying nothing.
{
    private _uiVar = format [QGVAR(display_%1), _x];
    private _value = (_unit call FUNC(getSpeedHashMap)) getOrDefault [_x, 1];

    if ((GVAR(displayState) getOrDefault [_uiVar, -1]) isEqualTo _value) then {continue};

    GVAR(displayState) set [_uiVar, _value];

    [_unit, _value * 100, _x, false, ""] call FUNC(displayUpdatedInfo);
} forEach ["walk", "tactical", "custom"];
