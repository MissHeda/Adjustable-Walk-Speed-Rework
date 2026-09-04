#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Returns the unit's speed hashmap, creating it from the unit's current animation speed the
 * first time. Every other function goes through here so the map only exists in one shape.
 *
 * Keys: "walk", "tactical", "custom" - the coefficient set for that animation group.
 *       "defaultSpeed"               - what the unit falls back to outside a whitelisted animation.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * Speed hashmap <HASHMAP>
 *
 * Example:
 * private _speeds = player call awsr_movement_fnc_getSpeedHashMap;
 *
 * Public: No
 */

params ["_unit"];

private _speeds = GETVAR(_unit,GVAR(unitAnimationSpeed),false);

if !(_speeds isEqualType createHashMap) then {
    private _current = getAnimSpeedCoef _unit;

    _speeds = createHashMapFromArray [
        ["walk", _current],
        ["tactical", _current],
        ["custom", _current],
        ["defaultSpeed", _current]
    ];

    SETVAR(_unit,GVAR(unitAnimationSpeed),_speeds);
};

_speeds
