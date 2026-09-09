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

// Three sources, in this order:
//
//   1. what the player set for this animation with the custom keys - the highest, because it is
//      the one thing here they chose deliberately for the animation in front of them
//   2. the group's speed, when the group has been moved off default
//   3. the speed the animation was given by name in the settings
//
// A group left at default does not outrank a per-animation speed, which is what lets swimming
// keep its own speed while the walk group sits at 100%.
private _pinned = _animation call FUNC(animationSpeed);
private _manual = _speeds getOrDefault [ANIM_KEY(_animation), -1];
private _group = _speeds getOrDefault [_type, 1];

private _coef = -1;

switch (true) do {
    case (_manual > 0): {_coef = _manual};
    case (_type isNotEqualTo "" && {_group != 1}): {_coef = _group};
    case (_pinned > 0): {_coef = _pinned};
};

if (_coef > 0) exitWith {
    if (_coef > 1 && {_unit call FUNC(isForceWalkedByOther)}) then {_coef = 1};

    private _changed = GETVAR(_unit,GVAR(appliedSpeed),-1) != _coef;

    [_unit, _coef] call FUNC(applySpeed);
    [_unit, GVAR(forceWalkWhenValueIsNotDefault) && {_speeds getOrDefault ["walk", 1] != 1}] call FUNC(setForceWalk);

    if (_changed && {_unit isEqualTo CURRENT_UNIT}) then {
        [_unit, _coef, _type] call FUNC(showSpeed);
    };

    if (GVAR(debug)) then {[_animation] call FUNC(debugAnimation)};
};

// Not one of ours: default speed, default audibility, and drop our force walk if we set one.
if (_type isEqualTo "") exitWith {
    [_unit, _speeds getOrDefault ["defaultSpeed", 1]] call FUNC(applySpeed);
    [_unit, GVAR(forceWalkWhenValueIsNotDefault) && {_speeds getOrDefault ["walk", 1] != 1}] call FUNC(setForceWalk);

    if (GVAR(debug)) then {[_animation] call FUNC(debugAnimation)};
};

_coef = _group;

// Something else is holding the unit at walking pace - speeding the animation up would let
// the player walk out from under it.
if (_coef > 1 && {_unit call FUNC(isForceWalkedByOther)}) then {
    _coef = 1;
};

private _changed = GETVAR(_unit,GVAR(appliedSpeed),-1) != _coef;

[_unit, _coef] call FUNC(applySpeed);

if (_changed && {_unit isEqualTo CURRENT_UNIT}) then {
    [_unit, _coef, _type] call FUNC(showSpeed);
};

// Force walk hangs off the walk speed itself, not off the animation the unit happens to be in.
// Deciding it here and nowhere else is what stops it being set in one place and cleared in the
// other on the very next animation change.
[_unit, GVAR(forceWalkWhenValueIsNotDefault) && {_speeds getOrDefault ["walk", 1] != 1}] call FUNC(setForceWalk);

// Last, so the numbers on it are the ones that were just applied rather than the ones that
// were there when this call started.
if (GVAR(debug)) then {[_animation] call FUNC(debugAnimation)};
