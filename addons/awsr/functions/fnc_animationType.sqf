#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Works out which animation group an animation belongs to. Walk wins over tactical, tactical
 * over custom, so an animation listed twice still has one owner.
 *
 * The answer is cached per animation name. The whitelists hold a few hundred entries and this
 * runs on every animation state change, which is several times a second while a unit moves.
 * awsr_awsr_fnc_rebuildAnimations drops the cache whenever a whitelist setting changes.
 *
 * Arguments:
 * 0: Animation name <STRING>
 *
 * Return Value:
 * "walk", "tactical", "custom", or "" when the animation is not whitelisted <STRING>
 *
 * Example:
 * private _type = (animationState player) call awsr_awsr_fnc_animationType;
 *
 * Public: No
 */

params [["_animation", ""]];

_animation = toLowerANSI _animation;

private _cached = GVAR(animationTypeCache) get _animation;
if (!isNil "_cached") exitWith {_cached};

private _type = "";

{
    _x params ["_group", "_enabled", "_names", "_patterns"];

    if (
        _enabled &&
        {_animation in _names || {_patterns findIf {_animation regexMatch _x} > -1}}
    ) exitWith {
        _type = _group;
    };
} forEach [
    ["walk", GVAR(Enable_Walk), GVAR(animations_Walk), GVAR(patterns_Walk)],
    ["tactical", GVAR(Enable_Tactical), GVAR(animations_Tactical), GVAR(patterns_Tactical)],
    ["custom", GVAR(Enable_Custom), GVAR(animations_Custom), GVAR(patterns_Custom)]
];

GVAR(animationTypeCache) set [_animation, _type];

_type
