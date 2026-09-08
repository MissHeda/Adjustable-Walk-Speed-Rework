#include "..\script_component.hpp"
/*
 * Author: leonz2019, Miss Heda
 * Installs the mission display handler that lets the stance keys work during a run.
 *
 * Only the stance keys: ending a run is a keybind of its own now.
 *
 * The player is in a scripted animation, so the engine will not change stance on its own. The key
 * is matched against what the vanilla stance actions are bound to rather than asked of
 * inputAction, which reports them as not held at all while an animation is playing.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call awsr_movement_fnc_autorunKeyHandler;
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

        // Stand, Crouch and Prone are what the stance keys are actually bound to - MoveUp and
        // MoveDown ship unbound, which is why none of this used to fire on a default profile.
        // Both sets are read so a player who has bound the step keys keeps them.
        private _stanceKey = switch (true) do {
            case (_key in actionKeys "Prone"): {"prone"};
            case (_key in actionKeys "Crouch"): {"crouch"};
            case (_key in actionKeys "Stand"): {"stand"};
            case (_key in actionKeys "MoveUp"): {"up"};
            case (_key in actionKeys "MoveDown"): {"down"};
            default {""};
        };

        if (_stanceKey != "") exitWith {
            // In the water there is no stance to change, and the key belongs to whoever else
            // wants it.
            if (GVAR(autorun_animation) select [1, 3] in SWIM_ACTIONS) exitWith {false};

            [_stanceKey] call FUNC(autorunUpdateStance);

            // Swallowed whether or not the stance changed. A press inside the transition window
            // is refused, and key repeat produces plenty of those - handing those on let the
            // engine change stance itself and tear the run's animation down.
            true
        };


        false
    }];
}] call CBA_fnc_waitUntilAndExecute;
