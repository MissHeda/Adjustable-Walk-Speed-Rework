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

// Called with nothing from the refresh loop: redraw whatever is on screen with the numbers as
// they are now. The speed changes without the animation changing - that is the whole point of
// the mod - so an animation handler on its own would show a value that is already stale.
if (_animation isEqualTo "") then {
    _animation = animationState CURRENT_UNIT;
};

if (_animation == "") exitWith {};

private _list = GVAR(debugAnimations);

// A loop re-enters the same state, and a list of the same name twenty times helps nobody. The
// hint is still redrawn, so the speed on it keeps up.
if ((_list param [count _list - 1, ""]) != _animation) then {
    _list pushBack _animation;
};

while {count _list > DEBUG_ANIMATION_COUNT} do {
    _list deleteAt 0;
};

GVAR(debugAnimations) = _list;

// Proper case, read back from the config. Every name the game hands an event handler is
// lowercase, which is exactly the form nobody can read the segments in.
private _named = _list apply {
    private _class = ANIMATION_STATES >> _x;
    [_x, configName _class] select (isClass _class)
};

// One block that explains itself, so it is worth pasting somewhere as it stands - the list on
// its own line, comma separated, still goes straight into a whitelist or a speed box.
private _plain = DEBUG_HEADER + endl + endl +
    LLSTRING(DEBUG_explain) + endl + endl +
    LLSTRING(DEBUG_listHeader) + endl +
    (_named joinString ", ") + endl + endl +
    DEBUG_FOOTER;

copyToClipboard _plain;

// Newest green, oldest red, the rest of the way between - so a glance says which end of the
// list you are reading without counting entries.
private _ordered = +_named;

// reverse turns an array round in place and hands back nothing at all, so its result cannot be
// iterated - which is why this list was empty on screen while the clipboard was fine.
reverse _ordered;

private _last = (count _ordered) - 1;
private _lines = [];

{
    // Both sides of a select are worked out before it picks one, so the division has to be kept
    // away from a single-entry list rather than guarded by the select.
    private _fraction = 0;
    if (_last > 0) then {_fraction = _forEachIndex / _last};

    // Green to red through yellow, which is the only two-channel ramp that stays readable on a
    // dark hint at this size.
    private _red = round (255 * (2 * _fraction min 1));
    private _green = round (255 * (2 * (1 - _fraction) min 1));

    private _colour = ([ARR_2(_red,2)] call FUNC(hex)) + ([ARR_2(_green,2)] call FUNC(hex)) + "00";

    _lines pushBack format [ARR_3("<t color='#%1'>%2</t>",_colour,_x)];
} forEach _ordered;

private _pinned = _animation call FUNC(animationSpeed);
private _group = _animation call FUNC(animationType);

private _groupText = LLSTRING(DEBUG_noGroup);
if (_group isNotEqualTo "") then {_groupText = _group};

private _pinnedText = LLSTRING(DEBUG_noPinned);
if (_pinned > 0) then {_pinnedText = str _pinned};

private _detail = format [
    LLSTRING(DEBUG_speed),
    getAnimSpeedCoef CURRENT_UNIT,
    _groupText,
    _pinnedText
];

private _current = _named param [count _named - 1, _animation];

[format [
    DEBUG_MARKUP,
    LLSTRING(DEBUG_title),
    _current,
    _detail,
    format [ARR_2(LLSTRING(DEBUG_copied),count _named)],
    (format [ARR_3(DEBUG_LEGEND_MARKUP,LLSTRING(DEBUG_legend),LLSTRING(DEBUG_legendOld))]) +
        ARR_SEPARATOR + (_lines joinString ARR_SEPARATOR)
], 6] call FUNC(notify);
