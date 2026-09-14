#include "..\script_component.hpp"
/*
 * Author: leonz2019, Miss Heda
 * Works out the stance the run should be in, from the player's current one plus the stance
 * keys and the water depth.
 *
 * Arguments:
 * 0: Key pressed - "stand", "crouch"/"up", "prone"/"down", or "" for none <STRING> (default: "")
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

// Vanilla toggles: the crouch key puts you in a crouch and stands you back up, the prone key
// the same for prone. MoveUp and MoveDown are what those keys are actually bound to on a
// default profile - verified in game with Debug on - so they get the same meaning rather than
// stepping one stance at a time, which is not how Arma feels without this mod running.
//
// The key comes from the display handler rather than from inputAction, which reports nothing
// while a scripted animation is playing.
private _stance = switch (_key) do {
    case "stand": {"Stand"};

    case "crouch";
    case "up": {["Crouch", "Stand"] select (_currentStance == "Crouch")};

    case "prone";
    case "down": {["Prone", "Stand"] select (_currentStance == "Prone")};

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
