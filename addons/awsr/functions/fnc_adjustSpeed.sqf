#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Increases or Decreases the walking speed & saves it as a variable.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Mode <STRING>
 * 2: Type <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, "increase", "walk"] call awsr_core_fnc_adjustSpeed;
 *
 * Public: No
 */

params ["_unit", "_mode", "_type"];

// Set mode & type to lowercase to prevent case sensetive errors
_mode = toLower _mode;
_type = toLower _type;

// Set variables that are required for _type switch
private _animationInArrayBool = false;
private _animation_speed_coefficient_hashmapVAR = "";
private _speedAdjustCoefficient = 0;
private _maxAdjustSpeed = 0;
private _minAdjustSpeed = 0;

// Get saved speed & audio (if not set create hashmap with current values) (audio uses same value as speed)
private _currentAnimationSpeed = GETVAR(_unit,GVAR(unitAnimationSpeed),(createHashMapFromArray [ARR_4([ARR_2("custom_animation_speed_coefficient",getAnimSpeedCoef _unit)],[ARR_2("walk_animation_speed_coefficient",getAnimSpeedCoef _unit)],[ARR_2("tactical_animation_speed_coefficient",getAnimSpeedCoef _unit)],[ARR_2("defaultSpeed",getAnimSpeedCoef _unit)])]));
private _newAnimationSpeed = 1;
private _displayInRedOverride = false;

switch (_type) do {
    case "walk": { 
        _animationInArrayBool = animationState _unit in GVAR(allowedAnimationArray_Walk);
        _animation_speed_coefficient_hashmapVAR = "walk_animation_speed_coefficient";
        _speedAdjustCoefficient = GVAR(speedAdjustCoefficient_Walk);
        _maxAdjustSpeed = GVAR(maxAdjustSpeed_Walk);
        _minAdjustSpeed = GVAR(minAdjustSpeed_Walk);
    };
    case "tactical": { 
        _animationInArrayBool = animationState _unit in GVAR(allowedAnimationArray_Tactical);
        _animation_speed_coefficient_hashmapVAR = "tactical_animation_speed_coefficient";
        _speedAdjustCoefficient = GVAR(speedAdjustCoefficient_Tactical);
        _maxAdjustSpeed = GVAR(maxAdjustSpeed_Tactical);
        _minAdjustSpeed = GVAR(minAdjustSpeed_Tactical);
    };
    case "custom": { 
        _animationInArrayBool = animationState _unit in GVAR(allowedAnimationArray_Custom);
        _animation_speed_coefficient_hashmapVAR = "custom_animation_speed_coefficient";
        _speedAdjustCoefficient = GVAR(speedAdjustCoefficient_Custom);
        _maxAdjustSpeed = GVAR(maxAdjustSpeed_Custom);
        _minAdjustSpeed = GVAR(minAdjustSpeed_Custom);
    };
};

if ( // Exit if:

    // System is disabled
    !GVAR(Enable) ||

    // Player is not on foot
    !isNull objectParent _unit ||

    // Anmiation change is only allowed while animation of a animation group is done
    GVAR(onlyChangeSpeedWhileAnimationIsPlaying) && !_animationInArrayBool
) exitWith {};

// Calculate new values
switch (_mode) do {
    case "increase": { 
        _newAnimationSpeed = (_currentAnimationSpeed get _animation_speed_coefficient_hashmapVAR) + _speedAdjustCoefficient;
    };
    case "decrease": { 
        _newAnimationSpeed = (_currentAnimationSpeed get _animation_speed_coefficient_hashmapVAR) - _speedAdjustCoefficient;
    };
    case "reset": { 
        _newAnimationSpeed = 1; // Default
    };
    case "min": { 
        _newAnimationSpeed = _minAdjustSpeed;
    };
    case "max": {
        _newAnimationSpeed = _maxAdjustSpeed;
    };
    default {};
};

// Make sure number is correct before saving
_newAnimationSpeed = [_newAnimationSpeed, 2] call BIS_fnc_cutDecimals;

switch (true) do {

    // If ace is loaded and something is focring walk set max to 100
    case (
        isClass (configfile >> "CfgPatches" >> "ace_common") && 
        (_newAnimationSpeed >= 1) && 
        {
            // Get ace unit status effect array (for forceWalking)
            private _ourStatusIndex = (GETMVAR(ACEGVAR(common,statusEffects_forceWalk),[])) find (toLowerANSI QUOTE(ADDON));
            private _activeForceWalkBoolArray = [GETVAR(_unit,ACEGVAR(common,effect_forceWalk),-1), count GETMVAR(ACEGVAR(common,statusEffects_forceWalk),[])] call ace_common_fnc_binarizeNumber;
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
    ): {
        _newAnimationSpeed = 1; // Set to default
        _displayInRedOverride = true;
    };

    // If value is above max, set to highest possible value
    case (_newAnimationSpeed >= _maxAdjustSpeed): {
        _newAnimationSpeed = _maxAdjustSpeed; // Set to maximum speed value
    };

    // If value is below min, set to lowest possible value
    case (_newAnimationSpeed <= _minAdjustSpeed): {
        _newAnimationSpeed = _minAdjustSpeed; // Set to minimum speed value
    };

    default {};
};

// Set new values into hashmap
_currentAnimationSpeed set [_animation_speed_coefficient_hashmapVAR,_newAnimationSpeed];

// Set updated hashmap as var onto unit
SETVAR(_unit,GVAR(unitAnimationSpeed),_currentAnimationSpeed);

// Update animation speed (this is needed here and not just in preinit event handler due to it requiring a anim change to apply new value, this overrides that)
if (_animationInArrayBool) then {
    [_unit, _newAnimationSpeed] remoteExecCall ["setAnimSpeedCoef", 0, true];

    // Update audio detection
    if (GVAR(adjustAudioDetection)) then {
        
        private _audioCoef = _newAnimationSpeed;

        if (_audioCoef > 1) then {
            _audioCoef = 1;
        };
        
        _unit setUnitTrait ["audibleCoef", _audioCoef];
    };
};

if (GVAR(forceWalkWhenValueIsNotDefault)) then {

    // If players has forceWalk on set/remove forceWalk
    if (_newAnimationSpeed != 1 && _type == "walk") then {

        // If ace is loaded use ace to set forceWalk
        if (isClass (configfile >> "CfgPatches" >> "ace_common")) exitWith {
            [player, "forceWalk", QUOTE(ADDON), true] call ACEFUNC(common,statusEffect_set);
        };

        player forceWalk true;
    } else {

        // If ace is loaded use ace to disable forceWalk
        if (isClass (configfile >> "CfgPatches" >> "ace_common")) exitWith {
            [player, "forceWalk", QUOTE(ADDON), false] call ACEFUNC(common,statusEffect_set);
        };

        player forceWalk false;
    };
};

// Call fnc to display speed changes
[_unit, (_newAnimationSpeed * 100), _type, _displayInRedOverride] call FUNC(displayUpdatedInfo);
