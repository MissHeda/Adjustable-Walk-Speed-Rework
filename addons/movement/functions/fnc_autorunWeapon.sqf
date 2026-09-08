#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * What the unit is holding, as far as autorun cares.
 *
 * A run is pinned to an animation per pace, and an animation carries the weapon in its name, so
 * there has to be one for whatever is in the hands. Rifles and handguns have a set each;
 * launchers, binoculars and empty hands do not, which is why a run will not start with those.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * "rfl", "pst", or "" for something a run has no animations for <STRING>
 *
 * Example:
 * private _weapon = [player] call awsr_movement_fnc_autorunWeapon;
 *
 * Public: No
 */

params ["_unit"];

private _weapon = currentWeapon _unit;

if (_weapon == "") exitWith {""};
if (_weapon == primaryWeapon _unit) exitWith {"rfl"};
if (_weapon == handgunWeapon _unit) exitWith {"pst"};

""
