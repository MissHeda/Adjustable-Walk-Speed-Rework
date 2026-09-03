#include "..\script_component.hpp"
/*
 * Author: leonz2019, Miss Heda
 * Installs the mission display input handlers. While a run is active they turn any key or a
 * left click into a stop, except for autorun's own keys and the view and stance keys.
 *
 * Our own keys are recognised and handed back to CBA rather than acted on here, so it does
 * not matter which of the two handlers the engine reaches first.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call awsr_autorun_fnc_addEHKeybind;
 *
 * Public: No
 */

if (!hasInterface) exitWith {};
if (!isNil QGVAR(stopKeyID)) exitWith {};

[{!isNull (findDisplay 46)}, {
    GVAR(stopKeyID) = (findDisplay 46) displayAddEventHandler ["KeyDown", {
        params ["", "_key", "_shift", "_ctrl", "_alt"];

        if (!GVAR(active)) exitWith {false};
        if !(call FUNC(checkDisplay)) exitWith {false};

        // One of ours - the walk, jog, run, stop or ignored key. CBA runs the action itself.
        if ([_key, _shift, _ctrl, _alt] call FUNC(isOwnKeybind)) exitWith {false};

        // Stance keys switch stance instead of stopping.
        if (
            !GVAR(isSwim) &&
            {inputAction "MoveUp" > 0 || {inputAction "MoveDown" > 0}}
        ) exitWith {
            call FUNC(updateStance);
            true
        };

        // In the water they do nothing, but they still must not stop the run.
        if (inputAction "MoveUp" > 0 || {inputAction "MoveDown" > 0}) exitWith {false};

        // Neither do the keys that only move the camera.
        if (
            inputAction "lookAroundToggle" > 0 ||
            {inputAction "personView" > 0} ||
            {inputAction "commandWatch" > 0}
        ) exitWith {false};

        // With a stop key bound, that key is the only thing that stops a run, and it was
        // handled above. Everything else carries on doing whatever it normally does.
        if (call FUNC(hasStopKey)) exitWith {false};

        [] call FUNC(onKeyDown);
        true
    }];

    GVAR(stopMouseID) = (findDisplay 46) displayAddEventHandler ["MouseButtonDown", {
        params ["", "_button"];

        if (
            GVAR(active) &&
            {_button == 0} &&
            {call FUNC(checkDisplay)}
        ) exitWith {
            [] call FUNC(onKeyDown);
            true
        };

        false
    }];
}] call CBA_fnc_waitUntilAndExecute;
