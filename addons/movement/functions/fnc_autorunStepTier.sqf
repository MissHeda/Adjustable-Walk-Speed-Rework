#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Shifts a running autorun one pace up or down, past any pace this stance and weapon do not
 * have. At either end of the list it stays put - ending a run belongs to the start key and the
 * stop keys, not to one scroll too many.
 *
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

// Nothing in that direction: stay where you are. Ending a run is the start key's job and the
// stop keys' - scrolling off the bottom of the list should not do it by accident.
if (_tier isEqualTo AUTORUN_OFF) exitWith {};

[_tier] call FUNC(autorunSetTier);
