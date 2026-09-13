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
 * [-1] call awsr_movement_fnc_autorunStepTier;
 *
 * Public: No
 */

params [["_delta", 1]];

// Only while a run is already going. From a standstill these keys belong to whatever else they
// are bound to - stepping up out of nothing would take the key away from the player entirely.
if (!GVAR(autorun_active)) exitWith {};

// The next pace that has an animation for this stance and this weapon. A pace with an empty box
// is not a pace here, so stepping past it is the same as it not being there.
private _tier = [GVAR(autorun_tier), _delta] call FUNC(autorunNextTier);

// Nothing above: stay where you are. Nothing below: that is what ending a run means.
if (_tier isEqualTo AUTORUN_OFF) exitWith {
    if (_delta > 0) exitWith {};

    0 spawn FUNC(autorunStop);
};

[_tier] call FUNC(autorunSetTier);
