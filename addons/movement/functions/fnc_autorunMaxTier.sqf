#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * The fastest pace the unit still has the stamina for.
 *
 * The thresholds are ACE's own: it takes the sprint away at 0.7 and gives it back at 0.6, and it
 * forces a walk at 1 and lets go at 0.7. Matching them means an ACE player meets one limit rather
 * than two that disagree. Without ACE the same numbers are read off the engine's own fatigue,
 * which behaves closely enough.
 *
 * The pace it is in decides which end of each pair applies, so a run does not flap on and off
 * while the value sits on a threshold.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Pace it is in now <NUMBER> (default: AUTORUN_OFF)
 *
 * Return Value:
 * AUTORUN_WALK, AUTORUN_JOG or AUTORUN_RUN <NUMBER>
 *
 * Example:
 * private _max = [player, AUTORUN_RUN] call awsr_movement_fnc_autorunMaxTier;
 *
 * Public: No
 */

params ["_unit", ["_current", AUTORUN_OFF]];

if (!GVAR(autorun_useStamina)) exitWith {AUTORUN_RUN};

private _spent = [_unit] call FUNC(fatigueLevel);

private _run = [FATIGUE_RUN_ENTER, FATIGUE_RUN_LEAVE] select (_current >= AUTORUN_RUN);
private _jog = [FATIGUE_JOG_ENTER, FATIGUE_JOG_LEAVE] select (_current >= AUTORUN_JOG);

switch (true) do {
    case (_spent < _run): {AUTORUN_RUN};
    case (_spent < _jog): {AUTORUN_JOG};
    default {AUTORUN_WALK};
}
