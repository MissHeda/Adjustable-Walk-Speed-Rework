#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Shifts a running autorun one pace up or down. Stepping down out of a walk ends the run.
 * Does nothing while no run is on, so the keys stay free for everything else.
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

// Only while a run is already going. From a standstill these keys belong to whatever else they
// are bound to - stepping up out of nothing would take the key away from the player entirely.
if (!GVAR(autorun_active)) exitWith {};

[GVAR(autorun_tier) + _delta] call FUNC(autorunSetTier);
