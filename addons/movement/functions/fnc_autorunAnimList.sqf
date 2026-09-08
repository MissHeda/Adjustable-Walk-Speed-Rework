#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * The animation list a pace loops in a given stance, with a given weapon in hand.
 *
 * One lookup for the three places that need it, so the indicator can never name a key that steps
 * through a different list than the run is actually using.
 *
 * An empty list is not an error: it means this combination has no pinned animation and the run
 * works one out from the situation instead.
 *
 * Arguments:
 * 0: Pace <NUMBER>
 * 1: Stance - "Stand", "Crouch", "Prone" or "Sit" <STRING> (default: "Stand")
 * 2: Handgun in hand <BOOL> (default: false)
 *
 * Return Value:
 * Animation names <ARRAY>
 *
 * Example:
 * [AUTORUN_JOG, "Crouch", false] call awsr_movement_fnc_autorunAnimList;
 *
 * Public: No
 */

params [["_tier", AUTORUN_WALK], ["_stance", "Stand"], ["_pistol", false]];

private _pace = switch (_tier) do {
    case AUTORUN_WALK: {"Walk"};
    case AUTORUN_JOG: {"Jog"};
    default {"Run"};
};

// Sitting has no run of its own, so it borrows the standing set - it is a transitional state
// the run leaves again on the next stance key.
private _prefix = switch (_stance) do {
    case "Crouch": {"Crouch"};
    case "Prone": {"Prone"};
    default {""};
};

private _name = _prefix + _pace + (["", "Pistol"] select _pistol);

missionNamespace getVariable [format [QGVAR(autorun_animList_%1), _name], []]
