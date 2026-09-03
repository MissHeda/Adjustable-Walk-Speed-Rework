#include "script_component.hpp"

if (!hasInterface) exitWith {};

call FUNC(addEHKeybind);

// A run belongs to the unit that started it. Respawning, switching unit or being remote
// controlled used to leave the indicator up and the animation handler on a body that is no
// longer ours.
[
    "unit",
    {
        params ["", "_oldUnit"];

        if (!isNull _oldUnit && {GVAR(animDoneEH) >= 0}) then {
            _oldUnit removeEventHandler ["AnimDone", GVAR(animDoneEH)];
        };

        GVAR(animDoneEH) = -1;

        if (!GVAR(active)) exitWith {};

        GVAR(active) = false;
        GVAR(isSwim) = false;

        if (GVAR(rscId) >= 0) then {
            GVAR(rscId) cutText ["", "PLAIN"];
        };
    }
] call CBA_fnc_addPlayerEventHandler;
