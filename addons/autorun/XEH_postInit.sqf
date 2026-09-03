#include "script_component.hpp"

if (!hasInterface) exitWith {};

////////////////////////////////////////////////////////////////////////////////////////////////////
// CBA key binding
////////////////////////////////////////////////////////////////////////////////////////////////////
//
// The autorun keys live in the CBA keybind menu next to the speed keys, under their own
// heading. They start out unbound: the keys this used to default to - F4 to F7 - are the
// vanilla team select keys, and a default that fires two actions at once is worse than none.
//
// The run logic needs to know which key is the stop key and which keys it must not treat as a
// stop. awsr_autorun_fnc_hasStopKey and awsr_autorun_fnc_isOwnKeybind ask CBA for that at the
// moment it matters, so rebinding takes effect without a restart.
//
////////////////////////////////////////////////////////////////////////////////////////////////////

["AWSR", "Adjustable Walking Speed - Rework"] call CBA_fnc_registerKeybindModPrettyName;

private _category = ["AWSR", LLSTRING(KEYBIND_Category)];

// Auto Walk: Undefined
[
    _category,
    QGVAR(walkKey),
    [LLSTRING(KEYBIND_walk), LLSTRING(KEYBIND_walk_DESC)],
    {
        [AUTORUN_WALK] call FUNC(onKeyDown);
        true
    },
    "",
    []
] call CBA_fnc_addKeybind;

// Auto Jog: Undefined
[
    _category,
    QGVAR(jogKey),
    [LLSTRING(KEYBIND_jog), LLSTRING(KEYBIND_jog_DESC)],
    {
        [AUTORUN_JOG] call FUNC(onKeyDown);
        true
    },
    "",
    []
] call CBA_fnc_addKeybind;

// Auto Run: Undefined
[
    _category,
    QGVAR(runKey),
    [LLSTRING(KEYBIND_run), LLSTRING(KEYBIND_run_DESC)],
    {
        [AUTORUN_RUN] call FUNC(onKeyDown);
        true
    },
    "",
    []
] call CBA_fnc_addKeybind;

// Stop Autorun: Undefined
[
    _category,
    QGVAR(stopKey),
    [LLSTRING(KEYBIND_stop), LLSTRING(KEYBIND_stop_DESC)],
    {
        // Harmless on its own, so the key keeps doing whatever else it does when no run is on.
        if (!GVAR(active)) exitWith {false};

        0 spawn FUNC(stopRunning);
        true
    },
    "",
    []
] call CBA_fnc_addKeybind;

// Ignored Key: Undefined
[
    _category,
    QGVAR(disabledKey),
    [LLSTRING(KEYBIND_disabled), LLSTRING(KEYBIND_disabled_DESC)],
    {
        // Does nothing by design. It exists so the display handler can recognise the key and
        // leave the run alone, and it never swallows the key it is bound to.
        false
    },
    "",
    []
] call CBA_fnc_addKeybind;

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
