#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * A bar showing where the current speed sits between what the keys can reach.
 *
 * Default speed is the middle of the bar rather than the middle of the range, so the two halves
 * are read separately: everything left of centre is slower than normal, everything right of it
 * faster. A range of 0.3 to 5 would otherwise put 1 almost at the left edge and make every
 * ordinary value look the same.
 *
 * Arguments:
 * 0: Lowest <NUMBER>
 * 1: Highest <NUMBER>
 * 2: Current <NUMBER>
 *
 * Return Value:
 * Structured text markup <STRING>
 *
 * Example:
 * private _bar = [0.5, 2, 1.4] call awsr_movement_fnc_speedSlider;
 *
 * Public: No
 */

params [["_min", 0], ["_max", 1], ["_value", 1]];

private _half = floor (SPEED_SLIDER_CELLS / 2);

private _cell = switch (true) do {
    // A range that does not straddle the default has nothing to split, so it is read straight.
    case (_min >= 1 || {_max <= 1}): {
        round ((SPEED_SLIDER_CELLS - 1) * (((_value - _min) / ((_max - _min) max 0.0001)) max 0 min 1))
    };
    case (_value < 1): {
        round (_half * (((_value - _min) / ((1 - _min) max 0.0001)) max 0 min 1))
    };
    default {
        _half + round (_half * (((_value - 1) / ((_max - 1) max 0.0001)) max 0 min 1))
    };
};

private _bar = "";

for "_i" from 0 to (SPEED_SLIDER_CELLS - 1) do {
    _bar = _bar + ([SPEED_SLIDER_TRACK, SPEED_SLIDER_MARK] select (_i == _cell));
};

format [
    SPEED_SLIDER_MARKUP,
    [_min, 2] call BIS_fnc_cutDecimals,
    _bar,
    [_max, 2] call BIS_fnc_cutDecimals
]
