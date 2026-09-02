#include "script_component.hpp"

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
        // If ace is loaded use ace to set forceWalk
        if (isClass (configfile >> "CfgPatches" >> "ace_common")) exitWith {
            [player, "forceWalk", QUOTE(ADDON), true] call ACEFUNC(common,statusEffect_set);
        };

        player forceWalk true;
    }, 
    {
        // If ace is loaded use ace to set forceWalk
        if (isClass (configfile >> "CfgPatches" >> "ace_common")) exitWith {
            [player, "forceWalk", QUOTE(ADDON), false] call ACEFUNC(common,statusEffect_set);
        };

        player forceWalk false;
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

// Exit if unit is not a player
if (!hasInterface) exitWith {};

// Adds a Event Handler to handle the animation speed.
player addEventHandler ["AnimStateChanged", { 
    params ["_unit", "_animation"];
    
    // Exit if system is disabled
    if (!GVAR(Enable)) exitWith {};

    _animation = toLower _animation;
    private _allowedAnimations = [];
    private _type = "";
    private _animationSpeedHashMap = GETVAR(_unit,GVAR(unitAnimationSpeed),(createHashMapFromArray [ARR_4([ARR_2("custom_animation_speed_coefficient",getAnimSpeedCoef _unit)],[ARR_2("walk_animation_speed_coefficient",getAnimSpeedCoef _unit)],[ARR_2("tactical_animation_speed_coefficient",getAnimSpeedCoef _unit)],[ARR_2("defaultSpeed",getAnimSpeedCoef _unit)])]));

    // Set the array of animations that are allowed
    switch (true) do {
        
        case (GVAR(Enable_Walk) && _animation in GVAR(allowedAnimationArray_Walk)): { 
            _allowedAnimations = _allowedAnimations + GVAR(allowedAnimationArray_Walk);
            _type = "walk";
        };
        
        case (GVAR(Enable_Tactical) && _animation in GVAR(allowedAnimationArray_Tactical)): { 
            _allowedAnimations = _allowedAnimations + GVAR(allowedAnimationArray_Tactical);
            _type = "tactical";
        };
        
        case (GVAR(Enable_Custom) && _animation in GVAR(allowedAnimationArray_Custom)): { 
            _allowedAnimations = _allowedAnimations + GVAR(allowedAnimationArray_Custom);
            _type = "custom";
        };
    };
    
    // Exit when animation is not whitelisted
    if !(_animation in _allowedAnimations) exitWith { 
        [_unit, (_animationSpeedHashMap get "defaultSpeed")] remoteExecCall ["setAnimSpeedCoef", 0, true];
        
        // We need this if due to other mods maybe setting force walk
        if (GVAR(forceWalkWhenValueIsNotDefault)) then {

            // If ace is loaded use ace to disable forceWalk
            if (isClass (configfile >> "CfgPatches" >> "ace_common")) exitWith {
                [player, "forceWalk", QUOTE(ADDON), false] call ACEFUNC(common,statusEffect_set);
            };

            player forceWalk false;
        };
    };

    // If ace is forcing walk & the value that should be applied is above 1 then set it to 1
    if (
        isClass (configfile >> "CfgPatches" >> "ace_common") && 
        _animationSpeedHashMap get (format ["%1_animation_speed_coefficient", _type]) > 1 && 
        {
            // Get ace unit status effect array (for forceWalking)
            private _ourStatusIndex = (GETMVAR(ACEGVAR(common,statusEffects_forceWalk),[])) find (toLowerANSI QUOTE(ADDON));
            private _activeForceWalkBoolArray = [GETVAR(_unit,ACEGVAR(common,effect_forceWalk),-1), count GETMVAR(ACEGVAR(common,statusEffects_forceWalk),[])] call ACEFUNC(common,binarizeNumber);
            private _isForceWalkFromUsON = _activeForceWalkBoolArray select _ourStatusIndex;
            private _trueFalseArray = [];
            private _return = false;

            // Get the current bool of every listed value that could cause forceWalking
            {
                _trueFalseArray pushBack _x; 
            } forEach _activeForceWalkBoolArray;

            // If a force value is present make sure it's not ours & if our force is present make sure the array has at least one other force that is enforcing forceWalk
            if ((({ _x == true } count _trueFalseArray) > 0 && !_isForceWalkFromUsON) || (_isForceWalkFromUsON && ({ _x == true } count _trueFalseArray) > 1)) then {
                _return = true;
            };

            _return
        }
    ) then {
        _animationSpeedHashMap set [(format ["%1_animation_speed_coefficient", _type]), 1];
    };

    // Update animation speed
    [_unit, (_animationSpeedHashMap get (format ["%1_animation_speed_coefficient", _type]))] remoteExecCall ["setAnimSpeedCoef", 0, true];

    // If players has forceWalk from us and getAnimSpeedCoef is 1 (default) reset forceWalk
    if (GVAR(forceWalkWhenValueIsNotDefault) && (_animationSpeedHashMap get (format ["%1_animation_speed_coefficient", _type]) == 1) && _type == "walk") then {

        // If ace is loaded use ace to disable forceWalk
        if (isClass (configfile >> "CfgPatches" >> "ace_common")) exitWith {
            [player, "forceWalk", QUOTE(ADDON), false] call ACEFUNC(common,statusEffect_set);            
        };

        player forceWalk false;
    };

    // Update audio detection (due to getAnimSpeedCoef == to audibleCoef we can use the same value)
    if (GVAR(adjustAudioDetection)) then {

        private _audioCoef = _animationSpeedHashMap get (format ["%1_animation_speed_coefficient", _type]);

        if (_audioCoef > 1) then {
            _audioCoef = 1;
        };
        
        _unit setUnitTrait ["audibleCoef", _audioCoef];
    };
}];
