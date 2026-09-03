#include "..\script_component.hpp"
/*
 * Author: leonz2019, Miss Heda
 * Installs the mission display handler that lets the movement and stance keys steer a run.
 *
 * It reads the key that was actually pressed and compares it against what the player has those
 * vanilla actions bound to, rather than asking inputAction whether they are held: while a
 * scripted animation is playing the engine reports those actions as not held at all, which is
 * why holding a direction, the sprint key or a stance key used to do nothing.
 *
 * A direction sticks. Pressing back turns the run around and it stays turned around after the
 * key is let go, until another direction key says otherwise.
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

        private _direction = switch (true) do {
            case (_key in actionKeys "MoveForward"): {"f"};
            case (_key in actionKeys "MoveBack"): {"b"};
            case (_key in actionKeys "MoveLeft"): {"l"};
            case (_key in actionKeys "MoveRight"): {"r"};
            default {""};
        };

        if (_direction != "") exitWith {
            GVAR(autorun_direction) = _direction;
            true
        };

        // A toggle rather than a hold, for the same reason: there is no reliable way to see the
        // key still being held while the run owns the animation.
        if (_key in (actionKeys "Sprint" + actionKeys "MoveFastForward")) exitWith {
            GVAR(autorun_sprint) = !GVAR(autorun_sprint);
            true
        };

        false
    }];
}] call CBA_fnc_waitUntilAndExecute;
