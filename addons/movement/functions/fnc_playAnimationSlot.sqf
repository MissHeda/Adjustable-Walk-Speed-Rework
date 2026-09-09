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

// Driven by AnimDone, and played with playMoveNow. switchMove skips the transition graph, which
// is what puts a frame of idle between two different animations - but it also snaps the pose
// without moving the unit, so a movement animation played that way only twitches on the spot.
// The frame of idle is the cheaper of the two.
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

    private _index = GVAR(animationSlotIndex) + 1;

    if (_index >= count _names) then {
        if !(missionNamespace getVariable [format [QGVAR(animationSlotLoop_%1), _slot], false]) exitWith {
            [_unit] call FUNC(stopAnimationSlot);
            _index = -1;
        };

        _index = 0;
    };

    if (_index < 0) exitWith {};

    GVAR(animationSlotIndex) = _index;
    _unit playMoveNow (_names select _index);
}];

SETVAR(_unit,GVAR(animationSlotEH),_id);

GVAR(animationSlotIndex) = 0;
_unit playMoveNow (_names select 0);
