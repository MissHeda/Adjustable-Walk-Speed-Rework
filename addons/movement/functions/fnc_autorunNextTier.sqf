#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * The next pace in a direction that the unit actually has an animation for.
 *
 * Not every pace exists in every stance with every weapon: there is no tactical pace with empty
 * hands, no walking or tactical crawl at all, and no sprint standing or crouched - what looks
 * like a sprint there is the evasive pace. A pace with an empty box is stepped over as though it
 * were not there, which is also how somebody switches one off.
 *
 * Arguments:
 * 0: Pace to start from <NUMBER>
 * 1: Direction, 1 up or -1 down <NUMBER>
 *
 * Return Value:
 * A usable pace, or AUTORUN_OFF when there is none in that direction <NUMBER>
 *
 * Example:
 * private _next = [AUTORUN_WALK, 1] call awsr_movement_fnc_autorunNextTier;
 *
 * Public: No
 */

params [["_from", AUTORUN_OFF], ["_step", 1]];

private _weapon = [player] call FUNC(autorunWeapon);
private _stance = GVAR(autorun_stance);

private _tier = _from;

for "_i" from 1 to AUTORUN_SPRINT do {
    _tier = _tier + _step;

    if (_tier < AUTORUN_WALK || {_tier > AUTORUN_SPRINT}) exitWith {_tier = AUTORUN_OFF};

    if (([_tier, _stance, _weapon] call FUNC(autorunAnimList)) isNotEqualTo []) exitWith {};

    // Nothing here, keep going in the same direction.
    if (_tier == AUTORUN_SPRINT && _step > 0) exitWith {_tier = AUTORUN_OFF};
    if (_tier == AUTORUN_WALK && _step < 0) exitWith {_tier = AUTORUN_OFF};
};

_tier
