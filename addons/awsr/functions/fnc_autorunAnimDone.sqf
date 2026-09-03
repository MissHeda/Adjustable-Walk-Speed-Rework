#include "..\script_component.hpp"
/*
 * Author: leonz2019, Miss Heda
 * Loops the run. A movement animation plays once and hands back to the engine, so the run only
 * keeps going for as long as something puts the next one on when the last one is done.
 *
 * Arguments:
 * AnimDone event handler arguments <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * player addEventHandler ["AnimDone", {call awsr_awsr_fnc_autorunAnimDone}];
 *
 * Public: No
 */

if (!GVAR(autorun_active)) exitWith {};
if (GVAR(autorun_updatingStance)) exitWith {};

if (
    !alive player ||
    {focusOn != player} ||
    {!isNull objectParent player} ||
    {incapacitatedState player == "UNCONSCIOUS"} ||
    {
        getUnitFreefallInfo player select 0 &&
        {(ATLToASL [getPos player select 0, getPos player select 1, 0]) distance (getPosASL player) > getUnitFreefallInfo player select 2}
    }
) exitWith {
    0 spawn FUNC(autorunStop);
};

([player] call FUNC(autorunAnimation)) params ["_animation", "_label"];

GVAR(autorun_animation) = _animation;
GVAR(autorun_label) = _label;

player playMoveNow _animation;
