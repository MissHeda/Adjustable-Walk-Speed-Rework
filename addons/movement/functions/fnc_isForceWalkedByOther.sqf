#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Answers whether anything other than this mod is currently forcing the unit to walk.
 * When something is, speeding an animation up past its default would let the player outrun
 * the force walk, so the callers cap the coefficient at 1 instead.
 *
 * Only ACE knows about several sources at once, so without ACE this is always false.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * Something other than us is forcing walk <BOOL>
 *
 * Example:
 * private _blocked = player call awsr_movement_fnc_isForceWalkedByOther;
 *
 * Public: No
 */

params ["_unit"];

if !(isClass (configFile >> "CfgPatches" >> "ace_common")) exitWith {false};

private _reasons = GETMVAR(ACEGVAR(common,statusEffects_forceWalk),[]);
if (_reasons isEqualTo []) exitWith {false};

// ACE keeps one bit per registered reason in a single number on the unit.
private _bits = [GETVAR(_unit,ACEGVAR(common,effect_forceWalk),0), count _reasons] call ACEFUNC(common,binarizeNumber);

// Our own reason is only in the list once we have set it at least once, so -1 is normal here.
private _ourIndex = _reasons find (toLowerANSI QUOTE(ADDON));
private _ourBit = _ourIndex >= 0 && {_bits param [_ourIndex, false]};

({_x} count _bits) > parseNumber _ourBit
