#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Answers whether ACE is forcing the unit to walk because it is exhausted, as opposed to any of
 * the other things that force a walk - dragging, carrying, a fractured leg.
 *
 * Only used to word a message, so it answers false whenever it cannot be sure. Saying "too
 * exhausted" at someone who is dragging a casualty would be worse than saying nothing.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * ACE is holding a force walk for fatigue <BOOL>
 *
 * Example:
 * private _spent = player call awsr_movement_fnc_isAceExhaustionWalk;
 *
 * Public: No
 */

params ["_unit"];

if !(isClass (configFile >> "CfgPatches" >> "ace_common")) exitWith {false};

// ACE's own public getter rather than a hand-rolled decode of the bitmask - it handles the
// unset and zero cases itself and returns the reasons already lower-cased.
private _reasons = ([_unit, "forceWalk"] call ACEFUNC(common,statusEffect_get)) param [1, []];

"ace_advanced_fatigue" in _reasons
