#include "..\script_component.hpp"
/*
 * Author: leonz2019, Miss Heda
 * Ends a run and plays the matching stop animation.
 * Does nothing when no run is active, so the stop key is harmless on its own.
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

if (GVAR(rscId) >= 0) then {
    GVAR(rscId) cutText ["", "PLAIN"];
};

if (alive player && {isNull objectParent player} && {incapacitatedState player == ""}) then {
    player setVelocity [0, 0, 0];

    GVAR(damageAllowed) = isDamageAllowed player;
    if (GVAR(damageAllowed)) then {
        player allowDamage false;
    };

    GVAR(animation) = [player, true] call FUNC(getAnimation);
    player playMoveNow GVAR(animation);

    // Give up after a few seconds either way. If the stop animation never takes, waiting
    // forever would leave the player invulnerable.
    private _timeout = diag_tickTime + 3;
    waitUntil {animationState player != GVAR(animation) || {diag_tickTime > _timeout}};

    if (GVAR(damageAllowed)) then {
        player allowDamage true;
        GVAR(damageAllowed) = false;
    };
};

GVAR(isSwim) = false;
