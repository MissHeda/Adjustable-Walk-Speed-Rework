#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * How spent the unit is, as one number, whichever stamina system is actually running.
 *
 * With ACE advanced fatigue switched on this reproduces ACE's own "perceived fatigue", so the
 * autorun gives up at the same moment ACE takes the sprint away rather than at some number of
 * its own. Without it - no ACE, or ACE with advanced fatigue off - it is the engine's fatigue,
 * which is what still moves in that case.
 *
 * ACE's reserves are read with a default of 1, which reads as "fresh": they do not exist until
 * ACE's main loop has ticked once, about a second after settings init, and a run refused on
 * spawn would be worse than a run allowed a second too early.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * 0 fresh to 1 spent <NUMBER>
 *
 * Example:
 * private _spent = [player] call awsr_movement_fnc_fatigueLevel;
 *
 * Public: No
 */

params ["_unit"];

if (
    !isNil QUOTE(ACEGVAR(advanced_fatigue,anReservePercentage)) &&
    {missionNamespace getVariable [QUOTE(ACEGVAR(advanced_fatigue,enabled)), false]}
) exitWith {
    // Recomputed from the two reserves rather than read off the unit: ACE stops writing its
    // mirrored value while swimming, and swimming is exactly where the run needs it.
    private _an = missionNamespace getVariable [QUOTE(ACEGVAR(advanced_fatigue,anReservePercentage)), 1];
    private _ae = missionNamespace getVariable [QUOTE(ACEGVAR(advanced_fatigue,aeReservePercentage)), 1];

    (1 - (_an min _ae)) max 0 min 1
};

getFatigue _unit
