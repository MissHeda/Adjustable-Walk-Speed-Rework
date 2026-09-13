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
 * 2: What is in the hands - "rfl", "pst" or "non" <STRING> (default: "rfl")
 *
 * Return Value:
 * Animation names <ARRAY>
 *
 * Example:
 * [AUTORUN_JOG, "Crouch", "pst"] call awsr_movement_fnc_autorunAnimList;
 *
 * Public: No
 */

params [["_tier", AUTORUN_WALK], ["_stance", "Stand"], ["_weapon", "rfl"]];

private _pace = switch (_tier) do {
    case AUTORUN_WALK: {"Walk"};
    case AUTORUN_JOG: {"Jog"};
    default {"Run"};
};

// Sitting has no pinned set. It borrowed the standing one, which pinned a standing animation
// onto a character who is sitting down - so the run simply sat there. An empty list hands it to
// the resolver, which builds the shuffle-forward the game has for exactly this state.
if (_stance isEqualTo "Sit") exitWith {[]};

private _prefix = switch (_stance) do {
    case "Crouch": {"Crouch"};
    case "Prone": {"Prone"};
    default {""};
};

private _suffix = switch (_weapon) do {
    case "pst": {"Pistol"};
    case "non": {"Unarmed"};
    default {""};
};

private _name = _prefix + _pace + _suffix;

missionNamespace getVariable [format [QGVAR(autorun_animList_%1), _name], []]
