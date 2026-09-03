#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Applies the movement style the player has stepped to, on top of the animation the run worked
 * out for itself.
 *
 * An entry starting with an underscore is a suffix - "_v2" turns AmovPercMwlkSlowWrflDf into
 * AmovPercMwlkSlowWrflDf_v2 - so a style keeps following the weapon, the stance and the pace.
 * Anything else is taken as a whole animation name, which is how an animation from another mod
 * gets in.
 *
 * A style that does not exist for the animation the unit is in right now is simply not applied.
 * Vanilla only has variants for erect walking with a lowered rifle.
 *
 * Arguments:
 * 0: Animation the run worked out <STRING>
 * 1: Style index, 0 for none <NUMBER>
 *
 * Return Value:
 * Animation to play <STRING>
 *
 * Example:
 * ["AmovPercMwlkSlowWrflDf", 2] call awsr_awsr_fnc_autorunStyleAnimation;
 *
 * Public: No
 */

params ["_base", ["_index", 0]];

if (_index <= 0 || {!GVAR(autorun_enableStyles)}) exitWith {_base};

private _entry = GVAR(autorun_styleList) param [_index - 1, ""];
if (_entry == "") exitWith {_base};

private _candidate = _entry;
if (_entry find "_" == 0) then {_candidate = _base + _entry};

if (isClass (ANIMATION_STATES >> _candidate)) exitWith {_candidate};

_base
