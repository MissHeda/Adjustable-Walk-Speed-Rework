#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Sets the default speed that is being used by the animation eventhandler in preInit
 * Note: I know that this function breaks when calling it mutiple times back to back. It needs a rework.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Speed <NUMBER>
 * 2: Reset time in seconds <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, 1.2, -1] call awsr_core_fnc_setDefaultSpeed;
 *
 * Public: No
 */

params ["_unit", "_speed", "_time"];

// Get units variables
private _unitHashmap = GETVAR(_unit,GVAR(unitAnimationSpeed),(createHashMapFromArray [ARR_4([ARR_2("custom_animation_speed_coefficient",getAnimSpeedCoef _unit)],[ARR_2("walk_animation_speed_coefficient",getAnimSpeedCoef _unit)],[ARR_2("tactical_animation_speed_coefficient",getAnimSpeedCoef _unit)],[ARR_2("defaultSpeed",getAnimSpeedCoef _unit)])]));

// Set new default speed
_unitHashmap set ["defaultSpeed",_speed];

// Set updated hashmap as var onto unit
SETVAR(_unit,GVAR(unitAnimationSpeed),_unitHashmap);

// Set var to check if this file has been called mutiple times
SETVAR(_unit,GVAR(setDefaultSpeed),(GETVAR(_unit,GVAR(setDefaultSpeed),0) + 1));

// Set timer to reset to arma default
[
    {
        params ["_unit", "_speed"];

        private _count = GETVAR(_unit,GVAR(setDefaultSpeed),0);
        private _newUnitHashmap = GETVAR(_unit,GVAR(unitAnimationSpeed),(createHashMapFromArray [ARR_4([ARR_2("custom_animation_speed_coefficient",getAnimSpeedCoef _unit)],[ARR_2("walk_animation_speed_coefficient",getAnimSpeedCoef _unit)],[ARR_2("tactical_animation_speed_coefficient",getAnimSpeedCoef _unit)],[ARR_2("defaultSpeed",getAnimSpeedCoef _unit)])]));
        private _currentSpeed = _newUnitHashmap get "defaultSpeed";
        private _removeNum = 1;

        if ((_count - 1) == -1 ) then {
            _removeNum = 0;
        };

        SETVAR(_unit,GVAR(setDefaultSpeed),(GETVAR(_unit,GVAR(setDefaultSpeed),0) - _removeNum));
        
        // If value is still the same & there are more then one functions queued exit
        if (_count > 1 || _currentSpeed != _speed) exitWith {};
        
        _newUnitHashmap set ["defaultSpeed",1];
        SETVAR(_unit,GVAR(unitAnimationSpeed),_newUnitHashmap);
    }, 
    [
        _unit, _speed
    ], 
    _time
] call CBA_fnc_waitAndExecute;