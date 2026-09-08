#include "..\script_component.hpp"
/*
 * Author: leonz2019, Miss Heda
 * Works out the stance the run should be in, from the player's current one plus the stance
 * keys and the water depth.
 *
 * Arguments:
 * 0: Stance key that was pressed - "up", "down", or "" for none <STRING> (default: "")
 *
 * Return Value:
 * 0: Stance changed <BOOL>
 * 1: Current stance <STRING>
 * 2: New stance <STRING>
 *
 * Example:
 * ["up"] call awsr_movement_fnc_autorunStance;
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

// Stance keys toggle between the stance they stand for and standing up again. The key comes
// from the display handler rather than from inputAction, which reports nothing while a scripted
// animation is playing.
private _isCrouch = _key == "up";
private _isProne = _key == "down";
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
