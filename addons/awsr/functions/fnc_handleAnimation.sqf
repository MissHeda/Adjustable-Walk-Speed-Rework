#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Applies the saved speed for whatever animation the unit just went into, and hands the unit
 * back to the game when it leaves a whitelisted one.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Animation name <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, animationState player] call awsr_awsr_fnc_handleAnimation;
 *
 * Public: No
 */

params ["_unit", ["_animation", ""]];

// Switched off mid mission: hand the unit back before going quiet.
if (!GVAR(Enable)) exitWith {
    if (GETVAR(_unit,GVAR(activeType),"") isEqualTo "" && {GETVAR(_unit,GVAR(appliedSpeed),1) == 1}) exitWith {};

    SETVAR(_unit,GVAR(activeType),"");
    [_unit, 1] call FUNC(applySpeed);
    [_unit, false] call FUNC(setForceWalk);
};

private _speeds = _unit call FUNC(getSpeedHashMap);
private _type = _animation call FUNC(animationType);

SETVAR(_unit,GVAR(activeType),_type);

// Not one of ours: default speed, default audibility, and drop our force walk if we set one.
if (_type isEqualTo "") exitWith {
    [_unit, _speeds getOrDefault ["defaultSpeed", 1]] call FUNC(applySpeed);
    [_unit, false] call FUNC(setForceWalk);
};

private _coef = _speeds getOrDefault [_type, 1];

// Something else is holding the unit at walking pace - speeding the animation up would let
// the player walk out from under it.
if (_coef > 1 && {_unit call FUNC(isForceWalkedByOther)}) then {
    _coef = 1;
};

[_unit, _coef] call FUNC(applySpeed);
[_unit, GVAR(forceWalkWhenValueIsNotDefault) && {_type isEqualTo "walk"} && {_coef != 1}] call FUNC(setForceWalk);
