#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * The speed set for one animation by name, or -1 when none is.
 *
 * This is the per-animation setting, not one of the three groups. It wins over all of them: the
 * animations people reach for here - swimming, ladders, crawling - are in no group at all, so an
 * overlap only happens when someone builds one, and a rule that multiplied the two would make
 * the display show a number that is not the speed being applied.
 *
 * Cached per name, like the group lookup, so a wildcard is only matched once per animation for
 * the life of the setting.
 *
 * Arguments:
 * 0: Animation name <STRING>
 *
 * Return Value:
 * Speed coefficient, or -1 for none <NUMBER>
 *
 * Example:
 * private _speed = "AswmPercMrunSnonWnonDf" call awsr_movement_fnc_animationSpeed;
 *
 * Public: No
 */

params [["_animation", ""]];

if (_animation isEqualTo "") exitWith {-1};

_animation = toLowerANSI _animation;

private _cached = GVAR(animationSpeedCache) get _animation;
if (!isNil "_cached") exitWith {_cached};

private _speed = GVAR(animationSpeeds) getOrDefault [_animation, -1];

// First wildcard in the order they were typed, so a broad entry after a narrow one cannot
// silently take it over.
if (_speed < 0) then {
    private _index = GVAR(animationSpeedPatterns) findIf {_animation regexMatch (_x select 0)};

    if (_index > -1) then {
        _speed = (GVAR(animationSpeedPatterns) select _index) select 1;
    };
};

GVAR(animationSpeedCache) set [_animation, _speed];

_speed
