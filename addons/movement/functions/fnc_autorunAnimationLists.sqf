#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Turns the animation settings into lists the run can step through - one per pace, per
 * stance and per weapon.
 *
 * One name in a box is the animation that pace loops. Several, comma separated, are alternatives:
 * the first is played, and the next-animation key walks through the rest and back round.
 *
 * Names are checked against the config here rather than every frame, so a typo simply drops out
 * of the list instead of being handed to playMoveNow twenty times a second.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call awsr_movement_fnc_autorunAnimationLists;
 *
 * Public: No
 */

{
    private _raw = missionNamespace getVariable [format [QGVAR(autorun_animation_%1), _x], ""];
    private _list = [];

    if (_raw isEqualType "") then {
        {
            if (_x != "" && {isClass (ANIMATION_STATES >> _x)}) then {
                _list pushBackUnique _x;
            };
        } forEach ([_raw call CBA_fnc_removeWhitespace, ","] call CBA_fnc_split);
    };

    missionNamespace setVariable [format [QGVAR(autorun_animList_%1), _x], _list];
} forEach [
    "Walk", "WalkPistol", "WalkUnarmed",
    "Tactical", "TacticalPistol", "TacticalUnarmed",
    "Jog", "JogPistol", "JogUnarmed",
    "Run", "RunPistol", "RunUnarmed",
    "Sprint", "SprintPistol", "SprintUnarmed",
    "CrouchWalk", "CrouchWalkPistol", "CrouchWalkUnarmed",
    "CrouchTactical", "CrouchTacticalPistol", "CrouchTacticalUnarmed",
    "CrouchJog", "CrouchJogPistol", "CrouchJogUnarmed",
    "CrouchRun", "CrouchRunPistol", "CrouchRunUnarmed",
    "CrouchSprint", "CrouchSprintPistol", "CrouchSprintUnarmed",
    "ProneWalk", "ProneWalkPistol", "ProneWalkUnarmed",
    "ProneTactical", "ProneTacticalPistol", "ProneTacticalUnarmed",
    "ProneJog", "ProneJogPistol", "ProneJogUnarmed",
    "ProneRun", "ProneRunPistol", "ProneRunUnarmed",
    "ProneSprint", "ProneSprintPistol", "ProneSprintUnarmed"
];
