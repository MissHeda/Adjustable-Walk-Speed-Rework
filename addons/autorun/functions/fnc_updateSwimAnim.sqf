#include "..\script_component.hpp"
/*
 * Author: leonz2019, Miss Heda
 * Keeps the swimming animation in step with surfacing, diving and the sea floor.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * 0 spawn awsr_autorun_fnc_updateSwimAnim;
 *
 * Public: No
 */

if (!hasInterface) exitWith {};
if (!GVAR(active)) exitWith {};
if (!GVAR(isSwim)) exitWith {};
if (!isNull objectParent player) exitWith {};
if (getUnitFreefallInfo player select 0) exitWith {};

while {sleep 0.1; GVAR(isSwim) && {GVAR(active)}} do {
    private _newAnimation = player call FUNC(getAnimation);

    if (
        _newAnimation select [1, 3] in SWIM_ACTIONS &&
        {_newAnimation != GVAR(animation)}
    ) then {
        player playMoveNow _newAnimation;
    };
};
