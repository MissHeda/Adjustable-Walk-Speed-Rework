#include "..\script_component.hpp"
/*
 * Author: leonz2019, Miss Heda
 * Installs the mission display input handlers. While a run is active they turn any key or
 * a left click into a stop, except for the view and stance keys.
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
        if (!GVAR(active)) exitWith {false};
        if !(call FUNC(checkDisplay)) exitWith {false};

        // No stop key bound: anything that is not a view or stance key stops the run.
        if (
            count (actionKeys QGVAR(stopKey)) == 0 &&
            {inputAction "lookAroundToggle" == 0} &&
            {inputAction "personView" == 0} &&
            {inputAction "commandWatch" == 0} &&
            {inputAction "MoveUp" == 0} &&
            {inputAction "MoveDown" == 0} &&
            {inputAction QGVAR(disabledKey) == 0}
        ) exitWith {
            [] call FUNC(onKeyDown);
            true
        };

        // Stance keys switch stance instead of stopping.
        if (
            !GVAR(isSwim) &&
            {inputAction "MoveUp" > 0 || {inputAction "MoveDown" > 0}}
        ) exitWith {
            call FUNC(updateStance);
            true
        };

        if (inputAction QGVAR(stopKey) > 0) exitWith {
            [] call FUNC(onKeyDown);
            true
        };

        false
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
