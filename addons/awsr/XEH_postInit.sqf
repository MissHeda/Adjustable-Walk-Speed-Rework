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


// While holding set Speed Keybind: Undefined
[
    "AWSR",
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
    "AWSR",
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
    "AWSR",
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
    "AWSR",
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
    "AWSR",
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
    "AWSR",
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
    "AWSR",
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
    "AWSR",
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
    "AWSR",
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
    "AWSR",
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
    "AWSR",
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
    "AWSR",
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
    "AWSR",
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
    "AWSR",
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
    "AWSR",
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
    "AWSR",
    QGVAR(SetMax_Speed_Custom),
    LLSTRING(KEYBIND_custom_setMax),
    {
        [player, "max", "custom"] call FUNC(adjustSpeed);
    },
    "",
    []
] call CBA_fnc_addKeybind;

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
