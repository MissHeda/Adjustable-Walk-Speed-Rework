#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Sets or clears the force walk this mod owns, through ACE where ACE is loaded.
 *
 * Turning it on is always re-applied: force walk can be dropped behind our back - opening
 * and closing the pause menu used to leave the player free to jog with a reduced speed
 * still set. Turning it off only happens when we were the ones who set it, so another mod's
 * force walk is left alone.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Force walk <BOOL>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, true] call awsr_movement_fnc_setForceWalk;
 *
 * Public: No
 */

params ["_unit", ["_state", false]];

if (!_state && {!GETVAR(_unit,GVAR(forceWalkSet),false)}) exitWith {};

SETVAR(_unit,GVAR(forceWalkSet),_state);

if (isClass (configFile >> "CfgPatches" >> "ace_common")) exitWith {
    [_unit, "forceWalk", QUOTE(ADDON), _state] call ACEFUNC(common,statusEffect_set);
};

_unit forceWalk _state;
