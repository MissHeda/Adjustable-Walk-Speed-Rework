#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Changes the speed stored for one animation group and applies it if the unit is in one of
 * that group's animations right now.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Mode - "increase", "decrease", "reset", "min" or "max" <STRING>
 * 2: Animation group - "walk", "tactical" or "custom" <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, "increase", "walk"] call awsr_movement_fnc_adjustSpeed;
 *
 * Public: No
 */

params ["_unit", ["_mode", ""], ["_type", ""]];

_mode = toLowerANSI _mode;
_type = toLowerANSI _type;

private _settings = switch (_type) do {
    case "walk": {
        [GVAR(Enable_Walk), GVAR(minAdjustSpeed_Walk), GVAR(maxAdjustSpeed_Walk), GVAR(speedAdjustCoefficient_Walk)]
    };
    case "tactical": {
        [GVAR(Enable_Tactical), GVAR(minAdjustSpeed_Tactical), GVAR(maxAdjustSpeed_Tactical), GVAR(speedAdjustCoefficient_Tactical)]
    };
    case "custom": {
        [GVAR(Enable_Custom), GVAR(minAdjustSpeed_Custom), GVAR(maxAdjustSpeed_Custom), GVAR(speedAdjustCoefficient_Custom)]
    };
    default {[]};
};

if (_settings isEqualTo []) exitWith {};

_settings params ["_enabled", "_min", "_max", "_step"];

private _isActiveAnimation = (animationState _unit) call FUNC(animationType) isEqualTo _type;

if ( // Exit if:

    // The system, or this group, is switched off
    !GVAR(Enable) ||
    {!_enabled} ||

    // The unit is not on foot
    {!isNull objectParent _unit} ||

    // The speed may only be changed while one of the group's animations is playing
    {GVAR(onlyChangeSpeedWhileAnimationIsPlaying) && {!_isActiveAnimation}}
) exitWith {};

private _speeds = _unit call FUNC(getSpeedHashMap);
private _current = _speeds getOrDefault [_type, 1];

private _new = switch (_mode) do {
    case "increase": {_current + _step};
    case "decrease": {_current - _step};
    case "reset": {1};
    case "min": {_min};
    case "max": {_max};
    default {_current};
};

_new = [((_new max _min) min _max), 2] call BIS_fnc_cutDecimals;

// Something other than us is forcing walk, so going faster than default is off the table.
// The display says so by drawing the value in the limit colour.
private _limitReached = false;
if (_new > 1 && {_unit call FUNC(isForceWalkedByOther)}) then {
    _new = 1;
    _limitReached = true;
};

_speeds set [_type, _new];

// Applied through the animation handler rather than here. It knows which group owns the
// animation the unit is in at this moment, and it is the single place force walk is decided -
// doing it twice is how the two used to end up disagreeing. Without this the new value would
// sit unused until the next animation change.
[_unit, animationState _unit] call FUNC(handleAnimation);

[_unit, _new * 100, _type, _limitReached] call FUNC(displayUpdatedInfo);
