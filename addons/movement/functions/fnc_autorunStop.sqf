#include "..\script_component.hpp"
/*
 * Author: leonz2019, Miss Heda
 * Ends a run and plays the matching stop animation.
 * Does nothing when no run is active, so a stop key is harmless on its own.
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
 * 0 spawn awsr_movement_fnc_autorunStop;
 *
 * Public: No
 */

if (!hasInterface) exitWith {};
if (!GVAR(autorun_active)) exitWith {};

GVAR(autorun_active) = false;
GVAR(autorun_tier) = AUTORUN_OFF;

if (GVAR(autorun_animDoneEH) >= 0) then {
    player removeEventHandler ["AnimDone", GVAR(autorun_animDoneEH)];
    GVAR(autorun_animDoneEH) = -1;
};

if (GVAR(autorun_pfh) >= 0) then {
    [GVAR(autorun_pfh)] call CBA_fnc_removePerFrameHandler;
    GVAR(autorun_pfh) = -1;
};

call FUNC(autorunIndicator);

if (!alive player || {!isNull objectParent player} || {incapacitatedState player != ""}) exitWith {};

private _unit = player;

// Killing the momentum and forcing a ground animation in the same frame can leave the engine
// booking the transition as a fall or a collision - the stop is triggered from mid-air too,
// the moment a freefall starts. Catch that, on this unit, for a fraction of a second.
//
// This used to be `allowDamage false`, held until the stop animation finished or three
// seconds had passed. That made the player invulnerable to everything, gunfire included,
// which in multiplayer is an exploit; and it wrote a flag ACE, Zeus and mission scripts also
// own, after reading back a value that may have been theirs rather than ours.
private _damageEH = _unit addEventHandler ["HandleDamage", {call FUNC(autorunStopDamage)}];

[{
    params ["_unit", "_damageEH"];
    _unit removeEventHandler ["HandleDamage", _damageEH];
}, [_unit, _damageEH], STOP_DAMAGE_GRACE] call CBA_fnc_waitAndExecute;

_unit setVelocity [0, 0, 0];

GVAR(autorun_animation) = [_unit, true] call FUNC(autorunAnimation);

_unit playMoveNow GVAR(autorun_animation);
