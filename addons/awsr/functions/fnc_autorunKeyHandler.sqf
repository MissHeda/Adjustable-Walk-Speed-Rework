#include "..\script_component.hpp"
/*
 * Author: leonz2019, Miss Heda
 * Installs the mission display handlers that let the movement and stance keys steer a run.
 *
 * They read the key that actually arrived and compare it against what the player has the
 * vanilla movement actions bound to, rather than asking inputAction whether it is held: while a
 * scripted animation is playing the engine reports those actions as not held at all, which is
 * why holding a direction, the sprint key or a stance key used to do nothing.
 *
 * Key up matters as much as key down. Which keys are held is what makes W+A a diagonal rather
 * than whichever of the two was pressed last.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call awsr_awsr_fnc_autorunKeyHandler;
 *
 * Public: No
 */

if (!hasInterface) exitWith {};
if (!isNil QGVAR(autorun_keyHandler)) exitWith {};

// Which of the four movement actions a key belongs to, if any.
GVAR(autorun_directionOf) = {
    params ["_key"];

    switch (true) do {
        case (_key in actionKeys "MoveForward"): {"f"};
        case (_key in actionKeys "MoveBack"): {"b"};
        case (_key in actionKeys "MoveLeft"): {"l"};
        case (_key in actionKeys "MoveRight"): {"r"};
        default {""};
    };
};

[{!isNull (findDisplay 46)}, {
    GVAR(autorun_keyHandler) = (findDisplay 46) displayAddEventHandler ["KeyDown", {
        params ["", "_key"];

        if (!GVAR(autorun_active)) exitWith {false};
        if !(call FUNC(autorunCheckDisplay)) exitWith {false};

        // The player is in a scripted animation, so the engine will not change stance on its
        // own. Play the transition instead and let the run carry on in the new stance.
        private _stanceKey = switch (true) do {
            case (_key in actionKeys "MoveUp"): {"up"};
            case (_key in actionKeys "MoveDown"): {"down"};
            default {""};
        };

        if (_stanceKey != "") exitWith {
            if !(GVAR(autorun_animation) select [1, 3] in SWIM_ACTIONS) then {
                [_stanceKey] call FUNC(autorunUpdateStance);
            };

            true
        };

        private _direction = [_key] call GVAR(autorun_directionOf);

        if (_direction != "") exitWith {
            GVAR(autorun_heldKeys) pushBackUnique _direction;
            call FUNC(autorunDirection);

            // Swallowed, or the engine would try to move the player as well and fight the
            // animation the run is playing.
            true
        };

        // A toggle rather than a hold, for the same reason the direction is read here at all:
        // there is no reliable way to see the key still being down while the run owns the
        // animation.
        if (_key in (actionKeys "Sprint" + actionKeys "MoveFastForward")) exitWith {
            GVAR(autorun_sprint) = !GVAR(autorun_sprint);
            true
        };

        false
    }];

    GVAR(autorun_keyUpHandler) = (findDisplay 46) displayAddEventHandler ["KeyUp", {
        params ["", "_key"];

        private _direction = [_key] call GVAR(autorun_directionOf);
        if (_direction == "") exitWith {false};

        GVAR(autorun_heldKeys) = GVAR(autorun_heldKeys) - [_direction];

        if (!GVAR(autorun_active)) exitWith {false};

        // Recomputed so letting go of one half of a diagonal leaves the other half running.
        // With nothing held at all the direction simply stays where it was.
        call FUNC(autorunDirection);

        true
    }];
}] call CBA_fnc_waitUntilAndExecute;
