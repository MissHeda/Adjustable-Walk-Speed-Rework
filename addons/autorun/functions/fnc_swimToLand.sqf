#include "..\script_component.hpp"
/*
 * Author: leonz2019, Miss Heda
 * Waits for the player to leave the water and puts them back on a land animation.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * 0 spawn awsr_autorun_fnc_swimToLand;
 *
 * Public: No
 */

if (!hasInterface) exitWith {};
if (!GVAR(active)) exitWith {};
if (!GVAR(isSwim)) exitWith {};
if (!isNull objectParent player) exitWith {};
if (getUnitFreefallInfo player select 0) exitWith {};

private _newAnimation = "";

waitUntil {
    sleep 0.1;
    _newAnimation = player call FUNC(getAnimation);
    !GVAR(active) || {GVAR(isSwim) && {!(_newAnimation select [1, 3] in SWIM_ACTIONS)}}
};

// The run may have been stopped while we were waiting.
if (!GVAR(active)) exitWith {};

player playMoveNow _newAnimation;
GVAR(isSwim) = false;
