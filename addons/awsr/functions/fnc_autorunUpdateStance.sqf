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
 * call awsr_awsr_fnc_autorunUpdateStance;
 *
 * Public: No
 */

if (!hasInterface) exitWith {false};
if (!GVAR(autorun_active)) exitWith {false};
if (!isNull objectParent player) exitWith {false};
if (getUnitFreefallInfo player select 0) exitWith {false};
if (GVAR(autorun_updatingStance)) exitWith {false};

private _newStance = call FUNC(autorunStance);

if (_newStance select 0) then {
    GVAR(autorun_updatingStance) = true;
    GVAR(autorun_stance) = _newStance select 2;

    private _from = GVAR(autorun_animation);
    ([player] call FUNC(autorunAnimation)) params ["_animation", "_label"];

    GVAR(autorun_animation) = _animation;
    GVAR(autorun_label) = _label;

    player playMoveNow format ["%1_%2", _from, _animation];

    call FUNC(autorunIndicator);
};

GVAR(autorun_updatingStance) = false;

(_newStance select 0)
