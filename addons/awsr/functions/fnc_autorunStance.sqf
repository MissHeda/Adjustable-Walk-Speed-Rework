#include "..\script_component.hpp"
/*
 * Author: leonz2019, Miss Heda
 * Works out the stance the run should be in, from the player's current one plus the stance
 * keys and the water depth.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * 0: Stance changed <BOOL>
 * 1: Current stance <STRING>
 * 2: New stance <STRING>
 *
 * Example:
 * call awsr_awsr_fnc_autorunStance;
 *
 * Public: No
 */

private _isSit = animationState player select [1, 7] == "adjppne";
private _currentStance = switch (true) do {
    case (_isSit): {"Sit"};
    case (stance player == "PRONE"): {"Prone"};
    case (stance player == "CROUCH"): {"Crouch"};
    default {"Stand"};
};

// Stance keys toggle between the stance they stand for and standing up again.
private _isCrouch = inputAction "MoveUp" > 0;
private _isProne = inputAction "MoveDown" > 0;
private _stance = switch (true) do {
    case (_isProne && _currentStance == "Prone"): {"Stand"};
    case (_isProne): {"Prone"};
    case (_isCrouch && _currentStance == "Crouch"): {"Stand"};
    case (_isCrouch): {"Crouch"};
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
