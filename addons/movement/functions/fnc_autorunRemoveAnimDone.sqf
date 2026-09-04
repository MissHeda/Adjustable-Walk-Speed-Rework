#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Takes the autorun's AnimDone handler off the unit it was actually added to.
 *
 * The id alone is not enough: an event handler index only means anything on the object it was
 * registered on, and by the time a run is torn down - a team switch, Zeus taking over - `player`
 * may already be somebody else. So the unit is remembered alongside the id.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call awsr_movement_fnc_autorunRemoveAnimDone;
 *
 * Public: No
 */

if (GVAR(autorun_animDoneEH) < 0) exitWith {};

private _unit = GVAR(autorun_animDoneUnit);

if (!isNull _unit) then {
    _unit removeEventHandler ["AnimDone", GVAR(autorun_animDoneEH)];
};

GVAR(autorun_animDoneEH) = -1;
GVAR(autorun_animDoneUnit) = objNull;
