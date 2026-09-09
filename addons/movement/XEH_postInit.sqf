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

////////////////////////////////////////////////////////////////////////////////////////////////////
// Autorun
////////////////////////////////////////////////////////////////////////////////////////////////////
//
// The three tier keys jump straight to a pace. Faster and Slower step through them, so one pair
// of keys covers starting a walk, working up to a run and stopping again - stepping down out of
// a walk ends the run.
//
// The pace keys keep the F row they have always had. Faster and Slower only do anything while a
// run is already going, so their keys stay free for whatever else they are bound to the rest of
// the time.
//
////////////////////////////////////////////////////////////////////////////////////////////////////

private _autorunCategory = ["AWSR", LLSTRING(KEYBIND_Category_Autorun)];

// Auto Walk: F5
[
    _autorunCategory,
    QGVAR(autorun_walkKey),
    [LLSTRING(KEYBIND_autorun_walk), LLSTRING(KEYBIND_autorun_walk_DESC)],
    {
        [AUTORUN_WALK] call FUNC(autorunSetTier);
        true
    },
    "",
    [0x3F, [false, false, false]]
] call CBA_fnc_addKeybind;

// Auto Jog: F6
[
    _autorunCategory,
    QGVAR(autorun_jogKey),
    [LLSTRING(KEYBIND_autorun_jog), LLSTRING(KEYBIND_autorun_jog_DESC)],
    {
        [AUTORUN_JOG] call FUNC(autorunSetTier);
        true
    },
    "",
    [0x40, [false, false, false]]
] call CBA_fnc_addKeybind;

// Auto Run: F7
[
    _autorunCategory,
    QGVAR(autorun_runKey),
    [LLSTRING(KEYBIND_autorun_run), LLSTRING(KEYBIND_autorun_run_DESC)],
    {
        [AUTORUN_RUN] call FUNC(autorunSetTier);
        true
    },
    "",
    [0x41, [false, false, false]]
] call CBA_fnc_addKeybind;

// One pace faster, while a run is going: Ctrl + W
[
    _autorunCategory,
    QGVAR(autorun_fasterKey),
    [LLSTRING(KEYBIND_autorun_faster), LLSTRING(KEYBIND_autorun_faster_DESC)],
    {
        // Not swallowed while no run is going, or holding ctrl would eat the movement
        // key this is bound alongside - which is exactly what stopped the player dead
        // the moment they held ctrl to change a speed.
        if (!GVAR(autorun_active)) exitWith {false};

        [1] call FUNC(autorunStepTier);
        true
    },
    "",
    [0x11, [false, true, false]]
] call CBA_fnc_addKeybind;

// One pace slower, ending the run below a walk: Ctrl + S
[
    _autorunCategory,
    QGVAR(autorun_slowerKey),
    [LLSTRING(KEYBIND_autorun_slower), LLSTRING(KEYBIND_autorun_slower_DESC)],
    {
        // Not swallowed while no run is going, or holding ctrl would eat the movement
        // key this is bound alongside - which is exactly what stopped the player dead
        // the moment they held ctrl to change a speed.
        if (!GVAR(autorun_active)) exitWith {false};

        [-1] call FUNC(autorunStepTier);
        true
    },
    "",
    [0x1F, [false, true, false]]
] call CBA_fnc_addKeybind;

// End Run: W and S
call FUNC(autorunSeedStopKeys);

[
    _autorunCategory,
    QGVAR(autorun_stopKey),
    [LLSTRING(KEYBIND_autorun_stop), LLSTRING(KEYBIND_autorun_stop_DESC)],
    {
        if (!GVAR(autorun_active)) exitWith {false};

        0 spawn FUNC(autorunStop);

        // Never swallowed. These are movement keys - the player pressed one because they want to
        // move, and the run getting out of the way is the whole point.
        false
    },
    "",
    [0x11, [false, false, false]]
] call CBA_fnc_addKeybind;

// Next Animation: J
[
    _autorunCategory,
    QGVAR(autorun_nextAnimationKey),
    [LLSTRING(KEYBIND_autorun_nextAnimation), LLSTRING(KEYBIND_autorun_nextAnimation_DESC)],
    {
        if (!GVAR(autorun_active)) exitWith {false};

        call FUNC(autorunNextAnimation);
        true
    },
    "",
    [0x24, [false, false, false]]
] call CBA_fnc_addKeybind;

call FUNC(autorunKeyHandler);

// Ten keys that play an animation of the player's choosing, unbound by default - the mod has no
// business claiming ten keys nobody asked it to.
private _animationCategory = ["AWSR", LLSTRING(KEYBIND_Category_Animations)];

for "_slot" from 1 to ANIMATION_SLOTS do {
    [
        _animationCategory,
        format [QGVAR(animationSlotKey_%1), _slot],
        [format [ARR_2(LLSTRING(KEYBIND_animationSlot),_slot)], LLSTRING(KEYBIND_animationSlot_DESC)],
        compile format [ARR_2("[%1] call " + QFUNC(playAnimationSlot) + "; true",_slot)],
        "",
        [DIK_UNBOUND, [ARR_3(false,false,false)]]
    ] call CBA_fnc_addKeybind;
};

call FUNC(rebuildAnimationSlots);


// Every keybind sits under one heading, so the menu reads the same way the settings do.
// General sits with the speed keys: it is the mod's own on/off and its reset, which is what
// someone looking under Adjustable Walk Speed expects to find there.
private _generalCategory = ["AWSR", LLSTRING(KEYBIND_Category_Speed)];
// The three speed groups share one heading. Split up, the menu read as five AWSR sections and
// you had to know which was which; together it reads as the three things the mod does.
private _walkCategory = ["AWSR", LLSTRING(KEYBIND_Category_Speed)];
private _tacticalCategory = _walkCategory;
private _customCategory = _walkCategory;


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
        [CURRENT_UNIT, "increase", "walk"] call FUNC(adjustSpeed);
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
        [CURRENT_UNIT, "decrease", "walk"] call FUNC(adjustSpeed);
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
        [CURRENT_UNIT, "reset", "walk"] call FUNC(adjustSpeed);
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
        [CURRENT_UNIT, "min", "walk"] call FUNC(adjustSpeed);
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
        [CURRENT_UNIT, "max", "walk"] call FUNC(adjustSpeed);
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
        [CURRENT_UNIT, "increase", "tactical"] call FUNC(adjustSpeed);
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
        [CURRENT_UNIT, "decrease", "tactical"] call FUNC(adjustSpeed);
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
        [CURRENT_UNIT, "reset", "tactical"] call FUNC(adjustSpeed);
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
        [CURRENT_UNIT, "min", "tactical"] call FUNC(adjustSpeed);
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
        [CURRENT_UNIT, "max", "tactical"] call FUNC(adjustSpeed);
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
        [CURRENT_UNIT, "increase", "custom"] call FUNC(adjustSpeed);
    },
    "",
    [0xF8, [ARR_3(true,true,true)]]
] call CBA_fnc_addKeybind;

// Decrease Speed Keybind: Undefined
[
    _customCategory,
    QGVAR(Decrease_Speed_Custom),
    LLSTRING(KEYBIND_custom_decreaseSpeed),
    {
        [CURRENT_UNIT, "decrease", "custom"] call FUNC(adjustSpeed);
    },
    "",
    [0xF9, [ARR_3(true,true,true)]]
] call CBA_fnc_addKeybind;

// Reset Speed Keybind: Undefined
[
    _customCategory,
    QGVAR(Reset_Speed_Custom),
    LLSTRING(KEYBIND_custom_resetSpeed),
    {
        [CURRENT_UNIT, "reset", "custom"] call FUNC(adjustSpeed);
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
        [CURRENT_UNIT, "min", "custom"] call FUNC(adjustSpeed);
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
        [CURRENT_UNIT, "max", "custom"] call FUNC(adjustSpeed);
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

        // Each body keeps its own speeds. Taking over a unit through Zeus puts you in one that has
        // none set, so the displays have to go with the body you left rather than carry on showing
        // what it was doing.
        {
            [_x] call FUNC(hideIGUI);
        } forEach [QGVAR(display_Walk), QGVAR(display_Tactical), QGVAR(display_Custom)];

        if (!isNull _oldUnit) then {
            private _oldId = GETVAR(_oldUnit,GVAR(animEHId),-1);

            if (_oldId >= 0) then {
                _oldUnit removeEventHandler ["AnimStateChanged", _oldId];
                SETVAR(_oldUnit,GVAR(animEHId),-1);
            };

            // Hand the body back the way we found it. Nothing is watching it any more, so
            // whatever coefficient or force walk was left on it would stay there for good.
            [_oldUnit, 1] call FUNC(applySpeed);
            [_oldUnit, false] call FUNC(setForceWalk);
        };

        // A run belongs to the unit that started it.
        if (GVAR(autorun_active)) then {
            GVAR(autorun_active) = false;
            GVAR(autorun_tier) = AUTORUN_OFF;

            if (GVAR(autorun_pfh) >= 0) then {
                [GVAR(autorun_pfh)] call CBA_fnc_removePerFrameHandler;
                GVAR(autorun_pfh) = -1;
            };

            call FUNC(autorunRemoveAnimDone);

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

// Debug redraws on a loop as well as on an animation change: the speed moves while the animation
// stays the same, so the handler alone would show a stale number. Cheap, and only while Debug is
// on - which is a server setting precisely so nobody leaves this running.
[{
    if (!GVAR(debug)) exitWith {};

    private _coef = getAnimSpeedCoef CURRENT_UNIT;

    if (_coef isEqualTo GVAR(debugLastSpeed)) exitWith {};

    GVAR(debugLastSpeed) = _coef;
    [""] call FUNC(debugAnimation);
}, DEBUG_REFRESH_INTERVAL] call CBA_fnc_addPerFrameHandler;

// Watches for another mod overwriting the speed we set - see awsr_movement_fnc_reapplySpeed.
[FUNC(reapplySpeed), 0.25] call CBA_fnc_addPerFrameHandler;
