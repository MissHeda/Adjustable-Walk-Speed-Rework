#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Swallows the damage the engine can book against the player in the moment the stop
 * animation is forced on, and nothing else.
 *
 * awsr_awsr_fnc_autorunStop registers this for a fraction of a second and takes it off again.
 * Only damage with no projectile and nobody behind it - a fall, a collision with the terrain -
 * is cancelled. Anything a weapon, an explosion or another unit caused is handed on untouched,
 * so stopping a run has never been a way to survive being shot.
 *
 * Returning nil rather than a number for those leaves the decision to whoever else handles
 * damage on this unit, so ACE medical, Zeus and mission scripts keep their own answer.
 *
 * Arguments:
 * HandleDamage event handler arguments <ARRAY>
 *
 * Return Value:
 * Damage to apply, or nil to leave it to the other handlers <NUMBER>
 *
 * Example:
 * player addEventHandler ["HandleDamage", {call awsr_awsr_fnc_autorunStopDamage}];
 *
 * Public: No
 */

params ["_unit", "", "", "_shooter", "_ammo", "_hitPointIndex", "_instigator"];

if (
    _ammo != "" ||
    {!isNull _shooter && {_shooter != _unit}} ||
    {!isNull _instigator && {_instigator != _unit}}
) exitWith {nil};

// Give back the damage that was already on the hitpoint, so this hit adds nothing. A
// negative index is the structural hit, which is not a hitpoint.
if (_hitPointIndex < 0) exitWith {damage _unit};

_unit getHitIndex _hitPointIndex
