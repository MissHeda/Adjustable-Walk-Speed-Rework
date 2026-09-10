#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Which of the three speeds is in force for an animation, and what the other two would be.
 *
 * The one place the priority is decided, so the handler that applies it and the displays that
 * report it can never disagree about who is in charge.
 *
 * Order: a speed the player set for this animation with the custom keys, then the group's speed
 * while the group is off default, then the speed the animation was given by name.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Animation name <STRING>
 *
 * Return Value:
 * 0: Coefficient in force, -1 for none of ours <NUMBER>
 * 1: Source - SOURCE_MANUAL, SOURCE_GROUP, SOURCE_PINNED or SOURCE_NONE <NUMBER>
 * 2: Animation group, "" for none <STRING>
 * 3: What the custom keys have set, -1 for nothing <NUMBER>
 * 4: What the group is set to <NUMBER>
 * 5: What the animation was given by name, -1 for nothing <NUMBER>
 *
 * Example:
 * ([player, animationState player] call awsr_movement_fnc_speedSource) params ["_coef", "_source"];
 *
 * Public: No
 */

params ["_unit", ["_animation", ""]];

private _speeds = _unit call FUNC(getSpeedHashMap);

private _type = _animation call FUNC(animationType);
private _manual = _speeds getOrDefault [ANIM_KEY(_animation), -1];
private _pinned = _animation call FUNC(animationSpeed);
private _group = 1;

if (_type isNotEqualTo "") then {
    _group = _speeds getOrDefault [_type, 1];
};

private _coef = -1;
private _source = SOURCE_NONE;

switch (true) do {
    case (_manual > 0): {_coef = _manual; _source = SOURCE_MANUAL};
    case (_type isNotEqualTo "" && {_group != 1}): {_coef = _group; _source = SOURCE_GROUP};
    case (_pinned > 0): {_coef = _pinned; _source = SOURCE_PINNED};
};

[_coef, _source, _type, _manual, _group, _pinned]
