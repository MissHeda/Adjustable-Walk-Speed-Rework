#include "..\script_component.hpp"
/*
 * Author: leonz2019, Miss Heda
 * Works out the stance the run should be in, from the player's current one plus the stance
 * keys and the water depth.
 *
 * Arguments:
 * 0: Key pressed - "stand", "crouch", "prone", "up", "down", or "" for none <STRING> (default: "")
 *
 * Return Value:
 * 0: Stance changed <BOOL>
 * 1: Current stance <STRING>
 * 2: New stance <STRING>
 *
 * Example:
 * ["crouch"] call awsr_movement_fnc_autorunStance;
 *
 * Public: No
 */

params [["_key", ""]];

private _isSit = animationState player select [1, 7] == "adjppne";
private _currentStance = switch (true) do {
    case (_isSit): {"Sit"};
    case (stance player == "PRONE"): {"Prone"};
    case (stance player == "CROUCH"): {"Crouch"};
    default {"Stand"};
};

// The named keys toggle against standing, the way they do outside a run; the step keys move one
// stance at a time. The key comes from the display handler rather than from inputAction, which
// reports nothing while a scripted animation is playing.
private _stance = switch (_key) do {
    case "stand": {"Stand"};
    case "crouch": {["Crouch", "Stand"] select (_currentStance == "Crouch")};
    case "prone": {["Prone", "Stand"] select (_currentStance == "Prone")};

    case "up": {
        switch (_currentStance) do {
            case "Prone": {"Crouch"};
            case "Crouch": {"Stand"};
            case "Sit": {"Stand"};
            default {_currentStance};
        }
    };

    case "down": {
        switch (_currentStance) do {
            case "Stand": {"Crouch"};
            case "Crouch": {"Prone"};
            default {_currentStance};
        }
    };

    default {_currentStance};
};

// Deep enough water forces the stance back up: below -1.2 you cannot crouch, below -0.5
// you cannot go prone or sit.
private _asl = getPosASL player select 2;
_stance = switch (true) do {
    case (_asl <= -1.2 && _stance == "Crouch"): {"Stand"};
    case (_asl <= -0.5 && _stance == "Prone"): {"Crouch"};
    case (_asl <= -0.5 && _stance == "Sit"): {"Crouch"};
    default {_stance};
};

[_currentStance != _stance, _currentStance, _stance]
