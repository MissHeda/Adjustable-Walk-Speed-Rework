#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Which of the three speeds is in force for an animation, and what the other two would be.
 *
 * The one place the priority is decided, so the handler that applies it and the displays that
 * report it can never disagree about who is in charge.
 *
 * A group that has been moved off default overrules a speed the animation was given by name -
 * so a walk group at 0.1 slows an animation set to 2, and a walk group left at default leaves
 * that 2 alone.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Animation name <STRING>
 *
 * Return Value:
 * 0: Coefficient in force, -1 for none of ours <NUMBER>
 * 1: Source - SOURCE_GROUP, SOURCE_PINNED or SOURCE_NONE <NUMBER>
 * 2: Animation group, "" for none <STRING>
 * 3: What the group is set to <NUMBER>
 * 4: What the animation was given by name, -1 for nothing <NUMBER>
 *
 * Example:
 * ([player, animationState player] call awsr_movement_fnc_speedSource) params ["_coef", "_source"];
 *
 * Public: No
 */

params ["_unit", ["_animation", ""]];

private _speeds = _unit call FUNC(getSpeedHashMap);

private _type = _animation call FUNC(animationType);
// A transition the game walks through in the middle of a sequence is in no group and has no
// speed of its own, so it would run at normal speed and read as the sequence stopping. It takes
// the speed of the animation it is heading for instead. Decided here rather than applied from
// the slot, because the animation handler fires for the transition and would overwrite it.
if (GVAR(animationSlotActive) != 0 && {GVAR(animationMatchTransitions)}) then {
    private _names = missionNamespace getVariable [format [QGVAR(animationSlotList_%1), GVAR(animationSlotActive)], []];
    private _target = _names param [GVAR(animationSlotIndex), ""];

    if (_target != "" && {toLowerANSI _animation != toLowerANSI _target}) then {
        _animation = _target;
    };
};

private _pinned = _animation call FUNC(animationSpeed);
private _group = 1;

if (_type isNotEqualTo "") then {
    _group = _speeds getOrDefault [_type, 1];
};

private _coef = -1;
private _source = SOURCE_NONE;

// A group that has been moved off default wins. Left alone it says nothing, and the animation
// runs on the speed it was given by name.
switch (true) do {
    case (_type isNotEqualTo "" && {_group != 1}): {_coef = _group; _source = SOURCE_GROUP};
    case (_pinned > 0): {_coef = _pinned; _source = SOURCE_PINNED};
};

[_coef, _source, _type, _group, _pinned]
