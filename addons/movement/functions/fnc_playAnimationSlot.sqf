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

// The engine is kept one animation ahead. playMoveNow only interrupts what is playing; the ones
// after it are queued with playMove, and the queue is topped up as each finishes. Let the queue
// run dry and the engine drops into the connected idle for a frame before the next one starts,
// which is the flicker into a third animation you would otherwise see between two.
private _id = _unit addEventHandler ["AnimDone", {
    params ["_unit"];

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
    _unit playMove (_names select _next);
}];

SETVAR(_unit,GVAR(animationSlotEH),_id);

GVAR(animationSlotIndex) = 0;
_unit playMoveNow (_names select 0);

// The second one goes in straight away, so there is always something queued behind what plays.
if (count _names > 1 || {_loop}) then {
    GVAR(animationSlotIndex) = 1 % (count _names);
    _unit playMove (_names select GVAR(animationSlotIndex));
};
