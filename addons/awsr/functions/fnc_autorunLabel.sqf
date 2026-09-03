#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Turns the segments of an animation name into something readable, so the indicator can say
 * what the run is actually doing rather than only that it is running.
 *
 * Arguments:
 * 0: Movement segment <STRING>
 * 1: Pose segment <STRING>
 * 2: Weapon stance segment <STRING>
 * 3: Weapon segment <STRING>
 * 4: In the water <BOOL>
 *
 * Return Value:
 * Label, e.g. "Jogging - Standing - Weapon lowered" <STRING>
 *
 * Example:
 * ["run", "erc", "low", "rfl", false] call awsr_awsr_fnc_autorunLabel;
 *
 * Public: No
 */

params ["_movement", "_pose", "_stance", "_weapon", ["_swimming", false]];

private _parts = [];

_parts pushBack (switch (_movement) do {
    case "wlk": {LLSTRING(AUTORUN_move_walk)};
    case "run": {LLSTRING(AUTORUN_move_jog)};
    case "eva": {LLSTRING(AUTORUN_move_run)};
    case "spr": {LLSTRING(AUTORUN_move_sprint)};
    case "lmp": {LLSTRING(AUTORUN_move_limp)};
    case "stp": {LLSTRING(AUTORUN_move_stop)};
    default {LLSTRING(AUTORUN_move_run)};
});

_parts pushBack (switch (true) do {
    case (_swimming): {LLSTRING(AUTORUN_pose_swimming)};
    case (_pose == "knl"): {LLSTRING(AUTORUN_pose_crouched)};
    case (_pose == "pne"): {LLSTRING(AUTORUN_pose_prone)};
    default {LLSTRING(AUTORUN_pose_standing)};
});

if (!_swimming) then {
    _parts pushBack (switch (true) do {
        case (_weapon == "non"): {LLSTRING(AUTORUN_weapon_none)};
        case (_stance == "ras"): {LLSTRING(AUTORUN_weapon_raised)};
        default {LLSTRING(AUTORUN_weapon_lowered)};
    });
};

_parts joinString " - "
