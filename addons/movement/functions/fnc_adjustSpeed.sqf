#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Changes the speed stored for one animation group and applies it if the unit is in one of
 * that group's animations right now.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Mode - "increase", "decrease", "reset", "min" or "max" <STRING>
 * 2: Animation group - "walk", "tactical" or "custom" <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, "increase", "walk"] call awsr_movement_fnc_adjustSpeed;
 *
 * Public: No
 */

params ["_unit", ["_mode", ""], ["_type", ""]];

_mode = toLowerANSI _mode;
_type = toLowerANSI _type;

private _settings = switch (_type) do {
    case "walk": {
        [GVAR(Enable_Walk), GVAR(minAdjustSpeed_Walk), GVAR(maxAdjustSpeed_Walk), GVAR(speedAdjustCoefficient_Walk)]
    };
    case "tactical": {
        [GVAR(Enable_Tactical), GVAR(minAdjustSpeed_Tactical), GVAR(maxAdjustSpeed_Tactical), GVAR(speedAdjustCoefficient_Tactical)]
    };
    case "custom": {
        [GVAR(Enable_Custom), GVAR(minAdjustSpeed_Custom), GVAR(maxAdjustSpeed_Custom), GVAR(speedAdjustCoefficient_Custom)]
    };
    default {[]};
};

if (_settings isEqualTo []) exitWith {};

_settings params ["_enabled", "_min", "_max", "_step"];

private _isActiveAnimation = (animationState _unit) call FUNC(animationType) isEqualTo _type;

if ( // Exit if:

    // The system, or this group, is switched off
    !GVAR(Enable) ||
    {!_enabled} ||

    // The unit is not on foot
    {!isNull objectParent _unit} ||

    // The speed may only be changed while one of the group's animations is playing
    {GVAR(onlyChangeSpeedWhileAnimationIsPlaying) && {!_isActiveAnimation}}
) exitWith {};

private _speeds = _unit call FUNC(getSpeedHashMap);

// An animation with a speed of its own is adjusted on its own, whichever group's key was
// pressed - the animations this is for, swimming and ladders, belong to no group, so waiting
// for the right group's key would mean waiting forever.
private _animation = toLowerANSI (animationState _unit);
private _pinned = _animation call FUNC(animationSpeed);

if (_pinned > 0) exitWith {
    // The setting widens the group's range rather than replacing it: above the group's maximum
    // it becomes the new maximum, below the group's minimum the new minimum. So an animation set
    // to 5 can be taken all the way down to the group's own floor and back up to 5, and one set
    // to 0.2 can be taken up to the group's ceiling and back down to 0.2.
    private _low = _min min _pinned;
    private _high = _max max _pinned;

    private _was = _speeds getOrDefault [ANIM_KEY(_animation), _pinned];

    private _to = switch (_mode) do {
        case "increase": {_was + _step};
        case "decrease": {_was - _step};
        case "reset": {_pinned};
        case "min": {_low};
        case "max": {_high};
        default {_was};
    };

    _to = [((_to max _low) min _high), 2] call BIS_fnc_cutDecimals;

    _speeds set [ANIM_KEY(_animation), _to];

    [_unit, animationState _unit] call FUNC(handleAnimation);

    [_unit, _to * 100, _type, _to == _low || {_to == _high}, ""] call FUNC(displayUpdatedInfo);
};

private _current = _speeds getOrDefault [_type, 1];

private _new = switch (_mode) do {
    case "increase": {_current + _step};
    case "decrease": {_current - _step};
    case "reset": {1};
    case "min": {_min};
    case "max": {_max};
    default {_current};
};

_new = [((_new max _min) min _max), 2] call BIS_fnc_cutDecimals;

// Something other than us is forcing walk, so going faster than default is off the table.
// The display says so by drawing the value in the limit colour.
private _limitReached = false;
private _reason = "";
if (_new > 1 && {_unit call FUNC(isForceWalkedByOther)}) then {
    _new = 1;
    _limitReached = true;

    // Named only when we can actually name it. Without ACE nothing else registers a reason, and
    // guessing "exhausted" at a force walk that came from dragging a body would be a lie.
    if (GVAR(explainLimit) && {_unit call FUNC(isAceExhaustionWalk)}) then {
        _reason = LLSTRING(LIMIT_exhausted);
    };
};

_speeds set [_type, _new];

// Applied through the animation handler rather than here. It knows which group owns the
// animation the unit is in at this moment, and it is the single place force walk is decided -
// doing it twice is how the two used to end up disagreeing. Without this the new value would
// sit unused until the next animation change.
[_unit, animationState _unit] call FUNC(handleAnimation);

[_unit, _new * 100, _type, _limitReached, _reason] call FUNC(displayUpdatedInfo);
