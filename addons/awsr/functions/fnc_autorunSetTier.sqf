#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Sets the autorun tier, starting or ending the run as needed. The single way in for every
 * autorun key.
 *
 * Arguments:
 * 0: AUTORUN_OFF, AUTORUN_WALK, AUTORUN_JOG or AUTORUN_RUN <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [AUTORUN_JOG] call awsr_awsr_fnc_autorunSetTier;
 *
 * Public: No
 */

params [["_tier", AUTORUN_OFF]];

if (!hasInterface) exitWith {};
if (!GVAR(autorun_enable)) exitWith {};
if !(call FUNC(autorunCheckDisplay)) exitWith {};

_tier = (round _tier max AUTORUN_OFF) min AUTORUN_RUN;

if (_tier == AUTORUN_OFF) exitWith {
    0 spawn FUNC(autorunStop);
};

// Already going: this is a gear change, not a new run.
if (GVAR(autorun_active)) exitWith {
    GVAR(autorun_tier) = _tier;
    call FUNC(autorunIndicator);
};

if (!alive player) exitWith {};
if (focusOn != player) exitWith {};
if (!isNull objectParent player) exitWith {};
if (incapacitatedState player != "") exitWith {};
if (visibleMap && {!(12 in GVAR(autorun_displayAllow))}) exitWith {};
if (getUnitFreefallInfo player select 0) exitWith {};

GVAR(autorun_tier) = _tier;

call FUNC(autorunStart);
