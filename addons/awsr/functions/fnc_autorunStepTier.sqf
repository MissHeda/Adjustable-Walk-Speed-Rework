#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Shifts the autorun one tier up or down. Stepping up from a standstill starts a walk;
 * stepping down out of a walk ends the run.
 *
 * Arguments:
 * 0: Tiers to shift, negative to slow down <NUMBER> (default: 1)
 *
 * Return Value:
 * None
 *
 * Example:
 * [-1] call awsr_awsr_fnc_autorunStepTier;
 *
 * Public: No
 */

params [["_delta", 1]];

private _tier = [ARR_2(AUTORUN_OFF,GVAR(autorun_tier))] select GVAR(autorun_active);

[_tier + _delta] call FUNC(autorunSetTier);
