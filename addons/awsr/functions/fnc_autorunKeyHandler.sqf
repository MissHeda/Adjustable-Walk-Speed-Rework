#include "..\script_component.hpp"
/*
 * Author: leonz2019, Miss Heda
 * Installs the mission display handler that lets the stance keys change stance during a run.
 *
 * Everything else a key can do to a run now goes through a keybind of its own. The old handler
 * turned any key at all into a stop unless it was on an exempt list, which is why there used to
 * be an "ignored key" binding for the map, the compass and the watch, and why a left click
 * stopped the run instead of firing.
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
        if (!GVAR(autorun_active)) exitWith {false};
        if !(call FUNC(autorunCheckDisplay)) exitWith {false};

        // The player is in a scripted animation, so the engine will not change stance on its
        // own. Play the transition instead and let the run carry on in the new stance.
        if (
            !(GVAR(autorun_animation) select [1, 3] in SWIM_ACTIONS) &&
            {inputAction "MoveUp" > 0 || {inputAction "MoveDown" > 0}}
        ) exitWith {
            call FUNC(autorunUpdateStance);
            true
        };

        false
    }];
}] call CBA_fnc_waitUntilAndExecute;
