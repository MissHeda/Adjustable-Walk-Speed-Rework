#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Is this animation in the tactical group, whatever else it is also in?
 *
 * fnc_animationType answers with the first group that claims an animation, walk before tactical.
 * The custom range wants the other order - an animation in both is the tactical pace as far as
 * the player is concerned - so it asks this instead.
 *
 * Arguments:
 * 0: Animation name <STRING>
 *
 * Return Value:
 * In the tactical group <BOOL>
 *
 * Example:
 * private _tactical = "AmovPercMwlkSrasWrflDf" call awsr_movement_fnc_isTacticalAnimation;
 *
 * Public: No
 */

params [["_animation", ""]];

if (!GVAR(Enable_Tactical)) exitWith {false};

_animation = toLowerANSI _animation;

if (_animation in GVAR(animations_Tactical)) exitWith {true};
if (_animation in GVAR(blocked_Tactical)) exitWith {false};

GVAR(patterns_Tactical) findIf {_animation regexMatch _x} > -1
