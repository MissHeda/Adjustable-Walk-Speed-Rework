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

// Same key again: stop, and let the engine take the unit back.
if (GVAR(animationSlotActive) == _slot) exitWith {
    GVAR(animationSlotActive) = 0;
    _unit switchMove "";
};

private _names = missionNamespace getVariable [format [QGVAR(animationSlotList_%1), _slot], []];

if (_names isEqualTo []) exitWith {};

private _loop = missionNamespace getVariable [format [QGVAR(animationSlotLoop_%1), _slot], false];

GVAR(animationSlotActive) = _slot;

// The sequence is driven by AnimDone rather than by sleeping for a guessed length: animations
// differ in length, and a speed set by this very mod changes it again.
[{
    params ["_args", "_handle"];
    _args params ["_unit", "_slot", "_names", "_loop", "_index"];

    if (GVAR(animationSlotActive) != _slot || {!alive _unit} || {!isNull objectParent _unit}) exitWith {
        [_handle] call CBA_fnc_removePerFrameHandler;
        if (GVAR(animationSlotActive) == _slot) then {GVAR(animationSlotActive) = 0};
    };

    // Still in the one that was asked for, so there is nothing to do yet.
    if (_index > 0 && {toLowerANSI (animationState _unit) == toLowerANSI (_names select (_index - 1))}) exitWith {};

    if (_index >= count _names) exitWith {
        if (!_loop) exitWith {
            [_handle] call CBA_fnc_removePerFrameHandler;
            GVAR(animationSlotActive) = 0;
        };

        _args set [4, 0];
    };

    _unit playMoveNow (_names select _index);
    _args set [4, _index + 1];
}, 0.1, [_unit, _slot, _names, _loop, 0]] call CBA_fnc_addPerFrameHandler;
