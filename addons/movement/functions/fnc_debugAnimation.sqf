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

hintSilent parseText format [
    "<t size='1.2'>%1</t><br/><br/><t size='1.1' color='#FFD766'>%2</t><br/><br/><t size='0.8'>%3</t><br/><t size='0.75' color='#AAAAAA'>%4</t>",
    LLSTRING(DEBUG_title),
    _animation,
    format [LLSTRING(DEBUG_copied), count _list],
    _list joinString ",<br/>"
];
