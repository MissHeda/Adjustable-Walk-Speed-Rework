#include "..\script_component.hpp"
/*
 * Author: leonz2019, Miss Heda
 * Installs the mission display handler that watches the movement and stance keys during a run.
 *
 * Reaching for a movement key means the player wants to steer for themselves, so the run ends
 * and the key goes through to the engine untouched. Which of the four count is a setting, and
 * they are matched as vanilla actions, so it follows whatever the player has WASD bound to.
 * Holding ctrl is the exception: that is the pace keys, and those belong to the run.
 *
 * Stance keys change stance instead, because the player is in a scripted animation and the
 * engine will not do it on its own.
 *
 * The keys are matched against what the player has the vanilla actions bound to, not asked of
 * inputAction - during a scripted animation the engine reports them as not held at all.
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
        params ["", "_key", "", "_ctrl"];

        if (!GVAR(autorun_active)) exitWith {false};
        if !(call FUNC(autorunCheckDisplay)) exitWith {false};

        // Ctrl held means the pace keys, which steer the run rather than ending it.
        if (_ctrl) exitWith {false};

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

        // Which movement keys end a run is a setting. They are read as the vanilla actions
        // rather than as fixed keys, so this follows whatever the player has WASD bound to.
        private _endsRun = false;

        {
            _x params ["_enabled", "_actions"];

            if (_enabled && {_actions findIf {_key in actionKeys _x} > -1}) exitWith {
                _endsRun = true;
            };
        } forEach [
            [GVAR(autorun_stopOnForward), ["MoveForward"]],
            [GVAR(autorun_stopOnBack), ["MoveBack"]],
            [GVAR(autorun_stopOnSideways), ["MoveLeft", "MoveRight"]]
        ];

        if (_endsRun) exitWith {
            0 spawn FUNC(autorunStop);

            // Not swallowed: the player asked to move, so let them.
            false
        };

        false
    }];
}] call CBA_fnc_waitUntilAndExecute;
