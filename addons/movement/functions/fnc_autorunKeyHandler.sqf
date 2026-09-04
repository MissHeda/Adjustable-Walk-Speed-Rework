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


        false
    }];
}] call CBA_fnc_waitUntilAndExecute;
