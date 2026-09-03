#include "script_component.hpp"

// Settings can finish loading either side of this file, so rebuild once now and once when CBA
// says they are all in.
call FUNC(rebuildAnimations);
["CBA_SettingsInitialized", {call FUNC(rebuildAnimations)}] call CBA_fnc_addEventHandler;

if (!hasInterface) exitWith {};

////////////////////////////////////////////////////////////////////////////////////////////////////
// CBA key binding
////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  Function: CBA_fnc_addKeybind
//
//  Description:
//   Adds or updates the keybind handler for a specified mod action, and associates
//   a function with that keybind being pressed.
//
//  Parameters:
//   _modName           Name of the registering mod [String]
//   _actionId  	    Id of the key action. [String]
//   _displayName       Pretty name, or an array of strings for the pretty name and a tool tip [String]
//   _downCode          Code for down event, empty string for no code. [Code]
//   _upCode            Code for up event, empty string for no code. [Code]
//
//  Optional:
//   _defaultKeybind    The keybinding data in the format [DIK, [shift, ctrl, alt]] [Array]
//   _holdKey           Will the key fire every frame while down [Bool]
//   _holdDelay         How long after keydown will the key event fire, in seconds. [Float]
//   _overwrite         Overwrite any previously stored default keybind [Bool]
//
//  Returns:
//   Returns the current keybind for the action [Array]
//
////////////////////////////////////////////////////////////////////////////////////////////////////

// Associates a pretty name to a keybinding mod entry.
["AWSR", "Adjustable Walking Speed - Rework"] call CBA_fnc_registerKeybindModPrettyName;

// Every keybind sits under one heading, so the menu reads the same way the settings do.
private _generalCategory = ["AWSR", LLSTRING(KEYBIND_Category_General)];
private _walkCategory = ["AWSR", LLSTRING(KEYBIND_Category_Walk)];
private _tacticalCategory = ["AWSR", LLSTRING(KEYBIND_Category_Tactical)];
private _customCategory = ["AWSR", LLSTRING(KEYBIND_Category_Custom)];


// While holding set Speed Keybind: Undefined
[
    _generalCategory,
    QGVAR(Hold_forceWalk),
    LLSTRING(KEYBIND_general_forceWalkHold),
    {
        [player, true] call FUNC(setForceWalk);
    },
    {
        [player, false] call FUNC(setForceWalk);
    },
    []
] call CBA_fnc_addKeybind;

// Increase Speed Keybind: Mouse UP + CTRL
[
    _walkCategory,
    QGVAR(Increase_Speed_Walk),
    LLSTRING(KEYBIND_walk_increaseSpeed),
    {
        [player, "increase", "walk"] call FUNC(adjustSpeed);
    },
    "",
    [0xF8, [false, true, false]]
] call CBA_fnc_addKeybind;


// Decrease Speed Keybind: Mouse DOWN + CTRL
[
    _walkCategory,
    QGVAR(Decrease_Speed_Walk),
    LLSTRING(KEYBIND_walk_decreaseSpeed),
    {
        [player, "decrease", "walk"] call FUNC(adjustSpeed);
    },
    "",
    [0xF9, [false, true, false]]
] call CBA_fnc_addKeybind;

// Reset Speed Keybind: Undefined
[
    _walkCategory,
    QGVAR(Reset_Speed_Walk),
    LLSTRING(KEYBIND_walk_resetSpeed),
    {
        [player, "reset", "walk"] call FUNC(adjustSpeed);
    },
    "",
    []
] call CBA_fnc_addKeybind;

// Set Min Speed Keybind: Undefined
[
    _walkCategory,
    QGVAR(SetMin_Speed_Walk),
    LLSTRING(KEYBIND_walk_setMin),
    {
        [player, "min", "walk"] call FUNC(adjustSpeed);
    },
    "",
    []
] call CBA_fnc_addKeybind;

// Set Max Speed Keybind: Undefined
[
    _walkCategory,
    QGVAR(SetMax_Speed_Walk),
    LLSTRING(KEYBIND_walk_setMax),
    {
        [player, "max", "walk"] call FUNC(adjustSpeed);
    },
    "",
    []
] call CBA_fnc_addKeybind;

// Increase Speed Keybind: Mouse UP + CTRL + Alt
[
    _tacticalCategory,
    QGVAR(Increase_Speed_Tactical),
    LLSTRING(KEYBIND_tactical_increaseSpeed),
    {
        [player, "increase", "tactical"] call FUNC(adjustSpeed);
    },
    "",
    [0xF8, [false, true, true]]
] call CBA_fnc_addKeybind;


// Decrease Speed Keybind: Mouse DOWN + CTRL + Alt
[
    _tacticalCategory,
    QGVAR(Decrease_Speed_Tactical),
    LLSTRING(KEYBIND_tactical_decreaseSpeed),
    {
        [player, "decrease", "tactical"] call FUNC(adjustSpeed);
    },
    "",
    [0xF9, [false, true, true]]
] call CBA_fnc_addKeybind;

// Reset Speed Keybind: Undefined
[
    _tacticalCategory,
    QGVAR(Reset_Speed_Tactical),
    LLSTRING(KEYBIND_tactical_resetSpeed),
    {
        [player, "reset", "tactical"] call FUNC(adjustSpeed);
    },
    "",
    []
] call CBA_fnc_addKeybind;

// Set Min Speed Keybind: Undefined
[
    _tacticalCategory,
    QGVAR(SetMin_Speed_Tactical),
    LLSTRING(KEYBIND_tactical_setMin),
    {
        [player, "min", "tactical"] call FUNC(adjustSpeed);
    },
    "",
    []
] call CBA_fnc_addKeybind;

// Set Max Speed Keybind: Undefined
[
    _tacticalCategory,
    QGVAR(SetMax_Speed_Tactical),
    LLSTRING(KEYBIND_tactical_setMax),
    {
        [player, "max", "tactical"] call FUNC(adjustSpeed);
    },
    "",
    []
] call CBA_fnc_addKeybind;

// Increase Speed Keybind: Undefined
[
    _customCategory,
    QGVAR(Increase_Speed_Custom),
    LLSTRING(KEYBIND_custom_increaseSpeed),
    {
        [player, "increase", "custom"] call FUNC(adjustSpeed);
    },
    "",
    []
] call CBA_fnc_addKeybind;

// Decrease Speed Keybind: Undefined
[
    _customCategory,
    QGVAR(Decrease_Speed_Custom),
    LLSTRING(KEYBIND_custom_decreaseSpeed),
    {
        [player, "decrease", "custom"] call FUNC(adjustSpeed);
    },
    "",
    []
] call CBA_fnc_addKeybind;

// Reset Speed Keybind: Undefined
[
    _customCategory,
    QGVAR(Reset_Speed_Custom),
    LLSTRING(KEYBIND_custom_resetSpeed),
    {
        [player, "reset", "custom"] call FUNC(adjustSpeed);
    },
    "",
    []
] call CBA_fnc_addKeybind;

// Set Min Speed Keybind: Undefined
[
    _customCategory,
    QGVAR(SetMin_Speed_Custom),
    LLSTRING(KEYBIND_custom_setMin),
    {
        [player, "min", "custom"] call FUNC(adjustSpeed);
    },
    "",
    []
] call CBA_fnc_addKeybind;

// Set Max Speed Keybind: Undefined
[
    _customCategory,
    QGVAR(SetMax_Speed_Custom),
    LLSTRING(KEYBIND_custom_setMax),
    {
        [player, "max", "custom"] call FUNC(adjustSpeed);
    },
    "",
    []
] call CBA_fnc_addKeybind;

////////////////////////////////////////////////////////////////////////////////////////////////////
// Autorun
////////////////////////////////////////////////////////////////////////////////////////////////////
//
// The three tier keys jump straight to a pace. Faster and Slower step through them, so one pair
// of keys covers starting a walk, working up to a run and stopping again - stepping down out of
// a walk ends the run.
//
// The defaults are Ctrl based because plain keys and the F row are already spoken for in vanilla:
// F1 to F12 select team members, which is what the old F4 to F7 defaults collided with.
//
////////////////////////////////////////////////////////////////////////////////////////////////////

private _autorunCategory = ["AWSR", LLSTRING(KEYBIND_Category_Autorun)];

// Auto Walk: Ctrl + Alt + 1
[
    _autorunCategory,
    QGVAR(autorun_walkKey),
    [LLSTRING(KEYBIND_autorun_walk), LLSTRING(KEYBIND_autorun_walk_DESC)],
    {
        [AUTORUN_WALK] call FUNC(autorunSetTier);
        true
    },
    "",
    [0x02, [false, true, true]]
] call CBA_fnc_addKeybind;

// Auto Jog: Ctrl + Alt + 2
[
    _autorunCategory,
    QGVAR(autorun_jogKey),
    [LLSTRING(KEYBIND_autorun_jog), LLSTRING(KEYBIND_autorun_jog_DESC)],
    {
        [AUTORUN_JOG] call FUNC(autorunSetTier);
        true
    },
    "",
    [0x03, [false, true, true]]
] call CBA_fnc_addKeybind;

// Auto Run: Ctrl + Alt + 3
[
    _autorunCategory,
    QGVAR(autorun_runKey),
    [LLSTRING(KEYBIND_autorun_run), LLSTRING(KEYBIND_autorun_run_DESC)],
    {
        [AUTORUN_RUN] call FUNC(autorunSetTier);
        true
    },
    "",
    [0x04, [false, true, true]]
] call CBA_fnc_addKeybind;

// One tier faster, starting a walk from a standstill: Ctrl + W
[
    _autorunCategory,
    QGVAR(autorun_fasterKey),
    [LLSTRING(KEYBIND_autorun_faster), LLSTRING(KEYBIND_autorun_faster_DESC)],
    {
        [1] call FUNC(autorunStepTier);
        true
    },
    "",
    [0x11, [false, true, false]]
] call CBA_fnc_addKeybind;

// One tier slower, ending the run below a walk: Ctrl + S
[
    _autorunCategory,
    QGVAR(autorun_slowerKey),
    [LLSTRING(KEYBIND_autorun_slower), LLSTRING(KEYBIND_autorun_slower_DESC)],
    {
        [-1] call FUNC(autorunStepTier);
        true
    },
    "",
    [0x1F, [false, true, false]]
] call CBA_fnc_addKeybind;

// Stop Autorun: Ctrl + X
[
    _autorunCategory,
    QGVAR(autorun_stopKey),
    [LLSTRING(KEYBIND_autorun_stop), LLSTRING(KEYBIND_autorun_stop_DESC)],
    {
        // Harmless on its own, so the key keeps doing whatever else it does when no run is on.
        if (!GVAR(autorun_active)) exitWith {false};

        0 spawn FUNC(autorunStop);
        true
    },
    "",
    [0x2D, [false, true, false]]
] call CBA_fnc_addKeybind;

call FUNC(autorunKeyHandler);

// The animation handler follows the player rather than sitting on whichever unit happened to
// exist at mission start. Adding it once to "player" meant respawning, switching unit or taking
// remote control of one left the mod doing nothing until the next restart.
[
    "unit",
    {
        params ["_newUnit", "_oldUnit"];

        if (!isNull _oldUnit) then {
            private _oldId = GETVAR(_oldUnit,GVAR(animEHId),-1);

            if (_oldId >= 0) then {
                _oldUnit removeEventHandler ["AnimStateChanged", _oldId];
                SETVAR(_oldUnit,GVAR(animEHId),-1);
            };
        };

        // A run belongs to the unit that started it.
        if (GVAR(autorun_active)) then {
            GVAR(autorun_active) = false;
            GVAR(autorun_tier) = AUTORUN_OFF;

            if (GVAR(autorun_pfh) >= 0) then {
                [GVAR(autorun_pfh)] call CBA_fnc_removePerFrameHandler;
                GVAR(autorun_pfh) = -1;
            };

            if (!isNull _oldUnit && {GVAR(autorun_animDoneEH) >= 0}) then {
                _oldUnit removeEventHandler ["AnimDone", GVAR(autorun_animDoneEH)];
            };

            GVAR(autorun_animDoneEH) = -1;

            call FUNC(autorunIndicator);
        };

        if (isNull _newUnit) exitWith {};

        private _newId = _newUnit addEventHandler ["AnimStateChanged", {_this call FUNC(handleAnimation)}];
        SETVAR(_newUnit,GVAR(animEHId),_newId);

        // The unit is already in an animation, so do not wait for the next one.
        [_newUnit, animationState _newUnit] call FUNC(handleAnimation);
    },
    true
] call CBA_fnc_addPlayerEventHandler;

// Watches for another mod overwriting the speed we set - see awsr_awsr_fnc_reapplySpeed.
[FUNC(reapplySpeed), 0.25] call CBA_fnc_addPerFrameHandler;
