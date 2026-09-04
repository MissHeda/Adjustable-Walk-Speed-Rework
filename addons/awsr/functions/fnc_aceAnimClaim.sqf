#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Claims the animation speed from ACE's advanced fatigue while this mod is driving it, and hands
 * it back when it is not.
 *
 * ace_advanced_fatigue_setAnimExclusions is a list of claim tags, not of animations - ACE only
 * ever asks whether it is empty (advanced_fatigue\functions\fnc_handleEffects.sqf), and leaves
 * setAnimSpeedCoef alone entirely while anything is in it. ACE's own medical treatment shows the
 * shape: push one QUOTE(ADDON) while you hold the speed, take it out again when you let go.
 *
 * This mod used to push every whitelisted animation name in there, which meant the list was never
 * empty and ACE's exhaustion slowdown never ran for the rest of the mission.
 *
 * Arguments:
 * 0: Hold the claim <BOOL>
 *
 * Return Value:
 * None
 *
 * Example:
 * [true] call awsr_awsr_fnc_aceAnimClaim;
 *
 * Public: No
 */

params [["_claim", false]];

if (isNil QUOTE(ACEGVAR(advanced_fatigue,setAnimExclusions))) exitWith {};

private _list = ACEGVAR(advanced_fatigue,setAnimExclusions);
if !(_list isEqualType []) exitWith {};

private _index = _list find QUOTE(ADDON);

if (_claim) then {
    if (_index < 0) then {
        _list pushBack QUOTE(ADDON);
    };
} else {
    if (_index >= 0) then {
        _list deleteAt _index;
    };
};
