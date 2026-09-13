#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Gives the transition into an animation the speed of the animation it leads to.
 *
 * A transition state belongs to no animation group and has no speed set for it by name, so the
 * mod leaves it alone and it plays at normal speed - which between two quick animations reads
 * as the sequence stopping for a moment. Held only until the animation actually asked for is on
 * screen, so nothing is left applied to whatever comes after the slot ends.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Animation the transition leads to <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, "AmovPercMwlkSlowWrflDf"] call awsr_movement_fnc_matchTransitionSpeed;
 *
 * Public: No
 */

params ["_unit", ["_animation", ""]];

private _coef = ([_unit, _animation] call FUNC(speedSource)) select 0;

if (_coef <= 0) exitWith {};

[_unit, _coef] call FUNC(applySpeed);

// The animation handler takes over the moment the target is reached, and the slot ending is the
// other way out - without it a sequence stopped mid-transition would leave the speed behind.
[{
    params ["_unit", "_animation"];

    (toLowerANSI (animationState _unit) isEqualTo toLowerANSI _animation) ||
    {GVAR(animationSlotActive) == 0}
}, {
    params ["_unit"];
    [_unit, animationState _unit] call FUNC(handleAnimation);
}, [_unit, _animation], TRANSITION_MATCH_TIMEOUT] call CBA_fnc_waitUntilAndExecute;
