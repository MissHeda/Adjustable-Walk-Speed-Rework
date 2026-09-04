#include "..\script_component.hpp"
/*
 * Author: leonz2019, Miss Heda
 * Plays the transition into a new stance while a run is going.
 *
 * Arguments:
 * 0: Stance key that was pressed - "up" or "down" <STRING>
 *
 * Return Value:
 * Stance changed <BOOL>
 *
 * Example:
 * ["up"] call awsr_movement_fnc_autorunUpdateStance;
 *
 * Public: No
 */

params [["_key", ""]];

if (!hasInterface) exitWith {false};
if (!GVAR(autorun_active)) exitWith {false};
if (!isNull objectParent player) exitWith {false};
if (getUnitFreefallInfo player select 0) exitWith {false};
if (GVAR(autorun_updatingStance)) exitWith {false};

private _newStance = [_key] call FUNC(autorunStance);

if (_newStance select 0) then {
    GVAR(autorun_updatingStance) = true;
    GVAR(autorun_stance) = _newStance select 2;

    private _from = GVAR(autorun_animation);

    GVAR(autorun_animation) = [player] call FUNC(autorunAnimation);

    player playMoveNow format [ARR_3("%1_%2",_from,GVAR(autorun_animation))];

    call FUNC(autorunIndicator);
};

GVAR(autorun_updatingStance) = false;

(_newStance select 0)
