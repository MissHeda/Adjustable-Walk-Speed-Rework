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
    "_coef", "_source", "_type", "_manual"
];

// Each display is only touched when what it would say has changed. Redrawing all three on every
// change restarted all three hide timers, so a walk change kept the tactical display on screen
// for exactly as long - and simply pressing W brought the tactical one up saying nothing.
private _draw = {
    params ["_uiVar", "_state", "_code"];

    if ((GVAR(displayState) getOrDefault [_uiVar, []]) isEqualTo _state) exitWith {};

    GVAR(displayState) set [_uiVar, _state];
    call _code;
};

// A group display answers for its own group and for nothing else.
{
    if (_x isEqualTo "custom" && {GVAR(customMode) == CUSTOM_MODE_ANIMATION}) then {continue};

    private _value = (_unit call FUNC(getSpeedHashMap)) getOrDefault [_x, 1];
    private _group = _x;

    [
        format [QGVAR(display_%1), _group],
        [_value],
        {
            [_unit, _value * 100, _group, false, "", MARKER_NONE] call FUNC(displayUpdatedInfo);
        }
    ] call _draw;
} forEach ["walk", "tactical", "custom"];

if (GVAR(customMode) != CUSTOM_MODE_ANIMATION) exitWith {};

// The custom display, standing for one animation at a time. It is the only one that says who is
// in charge, because it is the only one that can be switched.
private _shown = _coef;
if (_shown < 0) then {_shown = 1};

private _marker = switch (true) do {
    case (_manual > 0): {MARKER_ON};
    case (_manual isEqualTo OVERRIDE_SYNCED): {MARKER_SYNCED};
    default {MARKER_OFF};
};

[
    QGVAR(display_Custom),
    [_shown, _marker, _animation],
    {
        [_unit, _shown * 100, "custom", false, "", _marker] call FUNC(displayUpdatedInfo);
    }
] call _draw;
