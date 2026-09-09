#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Plays the animations listed in one of the keybind slots.
 *
 * One name plays that animation. Several, comma separated, play one after another, each waiting
 * for the one before it to finish - so a slot can be a whole sequence rather than a single pose.
 *
 * Pressing the key again while the slot is running stops it: an animation you cannot get out of
 * is worse than one that never started.
 *
 * Arguments:
 * 0: Slot number, 1 to ANIMATION_SLOTS <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [3] call awsr_movement_fnc_playAnimationSlot;
 *
 * Public: No
 */

params [["_slot", 0]];

if (!hasInterface) exitWith {};
if (_slot < 1 || {_slot > ANIMATION_SLOTS}) exitWith {};

private _unit = player;

if (!alive _unit) exitWith {};
if (!isNull objectParent _unit) exitWith {};
if (incapacitatedState _unit != "") exitWith {};

// Land animations in the water look exactly as wrong as they are, and the engine will not stop
// you walking out to sea - it is playing what it was told to play.
if (surfaceIsWater (position _unit)) exitWith {};

// Same key again: stop, and let the engine take the unit back.
if (GVAR(animationSlotActive) == _slot) exitWith {
    [_unit] call FUNC(stopAnimationSlot);
    _unit switchMove "";
};

private _names = missionNamespace getVariable [format [QGVAR(animationSlotList_%1), _slot], []];

if (_names isEqualTo []) exitWith {};

private _loop = missionNamespace getVariable [format [QGVAR(animationSlotLoop_%1), _slot], false];

GVAR(animationSlotActive) = _slot;

call FUNC(animationIndicator);

// Watched on the animation state itself rather than on AnimDone. Neither playMove nor a queue
// avoids the flicker: both route through the transition graph, and between two walk animations
// that route runs through the connected idle, which is the third animation that shows up. So
// the moment the unit lands anywhere that is not what this slot asked for, the next one is put
// on with switchMove, which takes no transition at all.
private _id = _unit addEventHandler ["AnimStateChanged", {
    params ["_unit", "_state"];

    if (GVAR(animationSlotActive) == 0) exitWith {};

    private _slot = GVAR(animationSlotActive);
    private _names = missionNamespace getVariable [format [QGVAR(animationSlotList_%1), _slot], []];

    if (
        _names isEqualTo [] ||
        {!alive _unit} ||
        {!isNull objectParent _unit} ||

        // Land animations do not belong in the water, and the engine will not stop you walking
        // in - it is playing what it was told to play.
        {surfaceIsWater (position _unit)}
    ) exitWith {
        [_unit] call FUNC(stopAnimationSlot);
    };

    // Still in the one that was asked for: nothing to do.
    if (toLowerANSI _state isEqualTo toLowerANSI (_names select GVAR(animationSlotIndex))) exitWith {};

    private _next = GVAR(animationSlotIndex) + 1;

    if (_next >= count _names) then {
        if !(missionNamespace getVariable [format [QGVAR(animationSlotLoop_%1), _slot], false]) exitWith {
            _next = -1;
        };

        _next = 0;
    };

    if (_next < 0) exitWith {
        [_unit] call FUNC(stopAnimationSlot);
    };

    GVAR(animationSlotIndex) = _next;
    _unit switchMove (_names select _next);
}];

SETVAR(_unit,GVAR(animationSlotEH),_id);

GVAR(animationSlotIndex) = 0;
_unit switchMove (_names select 0);
