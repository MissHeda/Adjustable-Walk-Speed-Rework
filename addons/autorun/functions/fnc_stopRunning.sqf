#include "..\script_component.hpp"
/*
 * Author: leonz2019, Miss Heda
 * Ends a run and plays the matching stop animation.
 * Does nothing when no run is active, so the stop key is harmless on its own.
 *
 * Never suspends, so it can be called from anywhere. The call sites still spawn it: one of
 * them is an AnimDone handler, and playing a move from inside that handler feeds itself.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * 0 spawn awsr_autorun_fnc_stopRunning;
 *
 * Public: No
 */

if (!hasInterface) exitWith {};
if (!GVAR(active)) exitWith {};

GVAR(active) = false;
GVAR(isSwim) = false;

if (GVAR(animDoneEH) >= 0) then {
    player removeEventHandler ["AnimDone", GVAR(animDoneEH)];
    GVAR(animDoneEH) = -1;
};

if (GVAR(rscId) >= 0) then {
    GVAR(rscId) cutText ["", "PLAIN"];
};

if (!alive player || {!isNull objectParent player} || {incapacitatedState player != ""}) exitWith {};

private _unit = player;

// Killing the momentum and forcing a ground animation in the same frame can leave the engine
// booking the transition as a fall or a collision - the stop is triggered from mid-air too,
// the AnimDone handler calls us the moment a freefall starts. Catch that, on this unit, for
// a fraction of a second.
//
// This used to be `allowDamage false`, held until the stop animation finished or three
// seconds had passed. That made the player invulnerable to everything, gunfire included,
// which in multiplayer is an exploit; and it wrote a flag ACE, Zeus and mission scripts also
// own, after reading back a value that may have been theirs rather than ours.
private _damageEH = _unit addEventHandler ["HandleDamage", {call FUNC(handleStopDamage)}];

[{
    params ["_unit", "_damageEH"];
    _unit removeEventHandler ["HandleDamage", _damageEH];
}, [_unit, _damageEH], STOP_DAMAGE_GRACE] call CBA_fnc_waitAndExecute;

_unit setVelocity [0, 0, 0];

GVAR(animation) = [_unit, true] call FUNC(getAnimation);
_unit playMoveNow GVAR(animation);
