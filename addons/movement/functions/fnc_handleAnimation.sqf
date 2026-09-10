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
 * [player, animationState player] call awsr_movement_fnc_handleAnimation;
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

    if (GVAR(debug)) then {[_animation] call FUNC(debugAnimation)};
};

private _speeds = _unit call FUNC(getSpeedHashMap);
private _type = _animation call FUNC(animationType);

SETVAR(_unit,GVAR(activeType),_type);

([_unit, _animation] call FUNC(speedSource)) params ["_coef", "", "", "", "_group"];

if (_coef > 0) exitWith {
    if (_coef > 1 && {_unit call FUNC(isForceWalkedByOther)}) then {_coef = 1};

    private _changed = GETVAR(_unit,GVAR(appliedSpeed),-1) != _coef;

    [_unit, _coef] call FUNC(applySpeed);
    [_unit, GVAR(forceWalkWhenValueIsNotDefault) && {_speeds getOrDefault ["walk", 1] != 1}] call FUNC(setForceWalk);

    if (_changed) then {[_unit] call FUNC(refreshDisplays)};
    if (GVAR(debug)) then {[_animation] call FUNC(debugAnimation)};
};

// Not one of ours: default speed, default audibility, and drop our force walk if we set one.
if (_type isEqualTo "") exitWith {
    [_unit, _speeds getOrDefault ["defaultSpeed", 1]] call FUNC(applySpeed);
    [_unit, GVAR(forceWalkWhenValueIsNotDefault) && {_speeds getOrDefault ["walk", 1] != 1}] call FUNC(setForceWalk);

    if (GVAR(debug)) then {[_animation] call FUNC(debugAnimation)};
};

private _coef2 = _group;

// Something else is holding the unit at walking pace - speeding the animation up would let
// the player walk out from under it.
if (_coef2 > 1 && {_unit call FUNC(isForceWalkedByOther)}) then {
    _coef2 = 1;
};

private _changed = GETVAR(_unit,GVAR(appliedSpeed),-1) != _coef2;

[_unit, _coef2] call FUNC(applySpeed);

if (_changed) then {[_unit] call FUNC(refreshDisplays)};

// Force walk hangs off the walk speed itself, not off the animation the unit happens to be in.
// Deciding it here and nowhere else is what stops it being set in one place and cleared in the
// other on the very next animation change.
[_unit, GVAR(forceWalkWhenValueIsNotDefault) && {_speeds getOrDefault ["walk", 1] != 1}] call FUNC(setForceWalk);

// Last, so the numbers on it are the ones that were just applied rather than the ones that
// were there when this call started.
if (GVAR(debug)) then {[_animation] call FUNC(debugAnimation)};
