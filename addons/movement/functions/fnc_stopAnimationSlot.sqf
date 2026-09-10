#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Ends whatever animation slot is running and takes its handler back off the unit.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player] call awsr_movement_fnc_stopAnimationSlot;
 *
 * Public: No
 */

params ["_unit"];

private _id = GETVAR(_unit,GVAR(animationSlotEH),-1);

if (_id >= 0) then {
    _unit removeEventHandler ["AnimDone", _id];
    SETVAR(_unit,GVAR(animationSlotEH),-1);
};

GVAR(animationSlotActive) = 0;
GVAR(animationSlotIndex) = 0;

call FUNC(animationIndicator);
