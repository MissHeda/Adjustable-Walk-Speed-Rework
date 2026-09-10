#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Redraws every speed display to match what is actually in force.
 *
 * One place, called from the animation handler and from the keys, so the three displays can
 * never disagree with each other or with the unit. Each one says what its own source is set to
 * and whether that source is the one being obeyed - a group holding 140% while an animation
 * overrides it should say so rather than quietly showing a number nothing is using.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player] call awsr_movement_fnc_refreshDisplays;
 *
 * Public: No
 */

params ["_unit"];

if (!hasInterface) exitWith {};
if !(_unit isEqualTo CURRENT_UNIT) exitWith {};

private _animation = animationState _unit;

([_unit, _animation] call FUNC(speedSource)) params [
    "_coef", "_source", "_type", "_manual", "_group", "_pinned"
];

// The three groups. A group shows its own value, and says whether that value is what the unit
// is actually doing.
{
    private _value = (_unit call FUNC(getSpeedHashMap)) getOrDefault [_x, 1];

    // The custom display is not a group display while the custom keys adjust animations.
    if (_x isEqualTo "custom" && {GVAR(customMode) == CUSTOM_MODE_ANIMATION}) then {continue};

    private _marker = MARKER_NONE;

    if (_value != 1) then {
        _marker = [MARKER_OVERRIDDEN, MARKER_ACTIVE] select (_source == SOURCE_GROUP && {_type isEqualTo _x});
    };

    [_unit, _value * 100, _x, false, "", _marker] call FUNC(displayUpdatedInfo);
} forEach ["walk", "tactical", "custom"];

if (GVAR(customMode) != CUSTOM_MODE_ANIMATION) exitWith {};

// The custom display, in the mode where it stands for one animation at a time. It shows what is
// in force whatever set it, so it is the one place that always answers "what am I doing now".
private _shown = _coef;
if (_shown < 0) then {_shown = 1};

private _marker = MARKER_NONE;

if (_manual > 0) then {
    _marker = MARKER_ACTIVE;
} else {
    // A speed the animation was given by name, with a group sitting on top of it.
    if (_pinned > 0 && {_source == SOURCE_GROUP}) then {_marker = MARKER_OVERRIDDEN};
};

[_unit, _shown * 100, "custom", false, "", _marker] call FUNC(displayUpdatedInfo);
