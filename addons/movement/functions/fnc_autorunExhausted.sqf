#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Says why a pace was refused or dropped, once, rather than every frame the run spends out of
 * breath.
 *
 * Without this the pace simply does not change and the player has no way to tell a stamina limit
 * from a broken keybind - which is the kind of thing that turns into a bug report.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * [] call awsr_movement_fnc_autorunExhausted;
 *
 * Public: No
 */

if (!hasInterface) exitWith {};
if (!GVAR(explainLimit)) exitWith {};

// One message per breather. The run drops a pace on one frame and refuses to climb back on all
// the ones after it, so without this it would be said several times a second.
if (diag_tickTime < GVAR(autorun_exhaustedUntil)) exitWith {};

GVAR(autorun_exhaustedUntil) = diag_tickTime + EXHAUSTED_MESSAGE_COOLDOWN;

hintSilent parseText format [
    "<t align='center' color='#FFD766'>%1</t>",
    LLSTRING(LIMIT_exhausted)
];
