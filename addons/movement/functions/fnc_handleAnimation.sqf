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

if (GVAR(debug)) then {
    [_animation] call FUNC(debugAnimation);
};

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

// A speed set for this animation by name beats every group, including no group at all - that is
// how swimming, ladders and crawling get a speed without being whitelisted into one.
private _pinned = _animation call FUNC(animationSpeed);

if (_pinned > 0) exitWith {
    // The setting is where this animation starts and the fastest it goes. The keys still work
    // inside that, and what they set is remembered per animation - so a ladder set to 5 starts
    // at 5, can be taken down to a crawl and put back up to 5, but no further.
    private _coef = _speeds getOrDefault [ANIM_KEY(_animation), _pinned];
    _coef = (_coef min _pinned) max ANIM_MIN_SPEED;

    if (_coef > 1 && {_unit call FUNC(isForceWalkedByOther)}) then {_coef = 1};

    [_unit, _coef] call FUNC(applySpeed);
    [_unit, GVAR(forceWalkWhenValueIsNotDefault) && {_speeds getOrDefault ["walk", 1] != 1}] call FUNC(setForceWalk);
};

// Not one of ours: default speed, default audibility, and drop our force walk if we set one.
if (_type isEqualTo "") exitWith {
    [_unit, _speeds getOrDefault ["defaultSpeed", 1]] call FUNC(applySpeed);
    [_unit, GVAR(forceWalkWhenValueIsNotDefault) && {_speeds getOrDefault ["walk", 1] != 1}] call FUNC(setForceWalk);
};

private _coef = _speeds getOrDefault [_type, 1];

// Something else is holding the unit at walking pace - speeding the animation up would let
// the player walk out from under it.
if (_coef > 1 && {_unit call FUNC(isForceWalkedByOther)}) then {
    _coef = 1;
};

[_unit, _coef] call FUNC(applySpeed);

// Force walk hangs off the walk speed itself, not off the animation the unit happens to be in.
// Deciding it here and nowhere else is what stops it being set in one place and cleared in the
// other on the very next animation change.
[_unit, GVAR(forceWalkWhenValueIsNotDefault) && {_speeds getOrDefault ["walk", 1] != 1}] call FUNC(setForceWalk);
