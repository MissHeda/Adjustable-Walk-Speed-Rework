#include "..\script_component.hpp"
/*
 * Author: leonz2019, Miss Heda
 * Plays the transition into a new stance while a run is going.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Stance changed <BOOL>
 *
 * Example:
 * call awsr_autorun_fnc_updateStance;
 *
 * Public: No
 */

if (!hasInterface) exitWith {false};
if (!GVAR(active)) exitWith {false};
if (!isNull objectParent player) exitWith {false};
if (getUnitFreefallInfo player select 0) exitWith {false};
if (GVAR(updatingStance)) exitWith {false};

private _newStance = call FUNC(getStance);

if (_newStance select 0) then {
    GVAR(updatingStance) = true;
    GVAR(stance) = _newStance select 2;

    private _newAnimation = player call FUNC(getAnimation);
    player playMoveNow format ["%1_%2", GVAR(animation), _newAnimation];
};

GVAR(updatingStance) = false;

(_newStance select 0)
