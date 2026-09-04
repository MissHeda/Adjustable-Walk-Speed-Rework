#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Puts our animation speed back when something else has overwritten it.
 *
 * setAnimSpeedCoef is a single value per unit and whoever writes it last wins. Missions and
 * mods that drive animation speed from their own loop - Ravage, Hetman, Hive have all been
 * reported - reset the speed a moment after it was set, which looked like the mod losing the
 * setting on every key press or every footstep. We only ever write the value the player asked
 * for, and only while they are in an animation we own.
 *
 * Runs from a per frame handler, throttled - see XEH_postInit.sqf.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call awsr_awsr_fnc_reapplySpeed;
 *
 * Public: No
 */

if (!GVAR(Enable) || {!GVAR(reapplySpeed)}) exitWith {};

private _unit = player;
if (isNull _unit || {!alive _unit} || {!isNull objectParent _unit}) exitWith {};

private _type = GETVAR(_unit,GVAR(activeType),"");
if (_type isEqualTo "") exitWith {};

// The animation can change without the event handler reaching us at all, which is the whole
// reason this exists - so check it rather than trusting the last one we saw.
if ((animationState _unit) call FUNC(animationType) != _type) exitWith {};

private _wanted = GETVAR(_unit,GVAR(appliedSpeed),-1);
if (_wanted < 0) exitWith {};

// The default is not ours to defend. Holding it against whoever set something else is how this
// would end up fighting ACE's advanced fatigue for a value we do not care about.
if (_wanted == 1) exitWith {};

if (abs (getAnimSpeedCoef _unit - _wanted) > 0.001) then {
    SETVAR(_unit,GVAR(appliedSpeed),-1);
    [_unit, _wanted] call FUNC(applySpeed);
};

// Force walk gets dropped behind our back too, most reliably by opening and closing the
// pause menu.
if (GETVAR(_unit,GVAR(forceWalkSet),false) && {!isForcedWalk _unit}) then {
    [_unit, true] call FUNC(setForceWalk);
};
