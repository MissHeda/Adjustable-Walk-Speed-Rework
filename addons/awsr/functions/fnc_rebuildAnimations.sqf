#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Rebuilds all three animation whitelists from the settings and drops the lookup cache.
 * Every whitelist related setting calls this, so the lists are always the whole truth rather
 * than whatever the last callback happened to add - unticking "include non raised animations"
 * used to leave those animations in the list until the next restart.
 *
 * Entries may contain "*" as a wildcard: "melee_armed_*" covers every melee walk animation
 * without listing them one by one.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call awsr_awsr_fnc_rebuildAnimations;
 *
 * Public: No
 */

// Splits a comma separated setting into plain names and wildcard patterns turned into regexes.
private _parse = {
    params ["_string"];

    private _names = [];
    private _patterns = [];

    if !(_string isEqualType "") exitWith {[_names, _patterns]};

    {
        private _entry = toLowerANSI _x;

        if (_entry != "") then {
            if ("*" in _entry) then {
                private _regex = "";

                {
                    private _char = toString [_x];
                    _regex = _regex + (switch (_char) do {
                        case "*": {".*"};
                        // Anything the engine's regex would read as syntax rather than as part
                        // of an animation name.
                        case ".";
                        case "+";
                        case "?";
                        case "(";
                        case ")";
                        case "[";
                        case "]";
                        case "{";
                        case "}";
                        case "^";
                        case "$";
                        case "|";
                        case "\": {"\" + _char};
                        default {_char};
                    });
                } forEach (toArray _entry);

                _patterns pushBackUnique _regex;
            } else {
                _names pushBackUnique _entry;
            };
        };
    } forEach ([_string call CBA_fnc_removeWhitespace, ","] call CBA_fnc_split);

    [_names, _patterns]
};

// Built in lists, plus whatever the player typed into the whitelist box.
private _walk = ALL_ADJUST_WALK_ANIMATIONS + ALL_MOVE_WALK_ANIMATIONS;
if (GETMVAR(GVAR(includeNonRaisedAnimations_Walk),true)) then {
    _walk = _walk + ALL_MOVE_WALK_ANIMATIONS_ADDITIONAL;
};

private _tactical = ALL_ADJUST_TACTICAL_ANIMATIONS + ALL_MOVE_TACTICAL_ANIMATIONS;
if (GETMVAR(GVAR(includeNonRaisedAnimations_Tactical),true)) then {
    _tactical = _tactical + ALL_MOVE_TACTICAL_ANIMATIONS_ADDITIONAL;
};

private _groups = [
    ["Walk", _walk, GETMVAR(GVAR(allowedAnimationArray_Walk),""), GETMVAR(GVAR(notAllowedAnimationArray_Walk),"")],
    ["Tactical", _tactical, GETMVAR(GVAR(allowedAnimationArray_Tactical),""), GETMVAR(GVAR(notAllowedAnimationArray_Tactical),"")],
    ["Custom", [], GETMVAR(GVAR(allowedAnimationArray_Custom),""), ""]
];

private _exclusions = [];

{
    _x params ["_group", "_builtIn", "_allowed", "_notAllowed"];

    ([_allowed] call _parse) params ["_names", "_patterns"];
    ([_notAllowed] call _parse) params ["_removeNames", "_removePatterns"];

    {_names pushBackUnique toLowerANSI _x} forEach _builtIn;

    _names = _names - _removeNames;

    // A wildcard on the blacklist takes the names it matches out of the list, and cancels an
    // identical wildcard on the whitelist.
    if !(_removePatterns isEqualTo []) then {
        _names = _names select {private _name = _x; _removePatterns findIf {_name regexMatch _x} == -1};
        _patterns = _patterns - _removePatterns;
    };

    missionNamespace setVariable [format [QGVAR(animations_%1), _group], _names];
    missionNamespace setVariable [format [QGVAR(patterns_%1), _group], _patterns];

    _exclusions append _names;
} forEach _groups;

GVAR(animationTypeCache) = createHashMap;

// ACE's advanced fatigue sets the animation speed itself. Hand it the animations we own so it
// leaves them alone - and take back exactly what we handed it last time, rather than
// subtracting the blacklist from whatever other mods put in there.
if (isClass (configFile >> "CfgPatches" >> "ace_advanced_fatigue")) then {
    private _ours = GETMVAR(GVAR(aceExclusions),[]);
    private _all = GETMVAR(ACEGVAR(advanced_fatigue,setAnimExclusions),[]);

    _all = _all - _ours;
    {_all pushBackUnique _x} forEach _exclusions;

    SETMVAR(ACEGVAR(advanced_fatigue,setAnimExclusions),_all);
    SETMVAR(GVAR(aceExclusions),_exclusions);
};
