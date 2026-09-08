#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Shows the animation the unit just went into and keeps the last few on the clipboard.
 *
 * This is the way to collect animation names without the animation viewer or the debug console:
 * switch the setting on, move the way you want to cover, and the names are already in the
 * clipboard in the form the whitelist boxes take.
 *
 * Arguments:
 * 0: Animation name <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * ["AmovPercMwlkSlowWrflDf"] call awsr_movement_fnc_debugAnimation;
 *
 * Public: No
 */

params [["_animation", ""]];

if (!hasInterface) exitWith {};
if (_animation == "") exitWith {};

private _list = GVAR(debugAnimations);

// A loop re-enters the same state, and a list of the same name twenty times helps nobody.
if ((_list param [count _list - 1, ""]) == _animation) exitWith {};

_list pushBack _animation;

while {count _list > DEBUG_ANIMATION_COUNT} do {
    _list deleteAt 0;
};

GVAR(debugAnimations) = _list;

// Comma separated rather than an SQF array, because that is what the whitelist and the autorun
// animation boxes take - paste straight in, no editing.
copyToClipboard (_list joinString ", ");

// The speed alongside the name, because the two questions people open Debug for are "what is
// this animation called" and "is my speed actually being applied to it".
private _pinned = _animation call FUNC(animationSpeed);
private _group = _animation call FUNC(animationType);

private _groupText = LLSTRING(DEBUG_noGroup);
if (_group isNotEqualTo "") then {_groupText = _group};

private _pinnedText = LLSTRING(DEBUG_noPinned);
if (_pinned > 0) then {_pinnedText = str _pinned};

private _detail = format [
    LLSTRING(DEBUG_speed),
    getAnimSpeedCoef player,
    _groupText,
    _pinnedText
];

private _joined = _list joinString ARR_SEPARATOR;

private _text = format [
    DEBUG_MARKUP,
    LLSTRING(DEBUG_title),
    _animation,
    _detail,
    format [ARR_2(LLSTRING(DEBUG_copied),count _list)],
    _joined
];

[_text, 6] call FUNC(notify);
