#include "..\script_component.hpp"
/*
 * Author: leonz2019, Miss Heda
 * Starts autorun, switches its type while it runs, or stops it again.
 *
 * Arguments:
 * 0: Autorun type - AUTORUN_WALK, AUTORUN_JOG or AUTORUN_RUN <NUMBER> (default: keep the current one)
 *
 * Return Value:
 * None
 *
 * Example:
 * [AUTORUN_RUN] call awsr_autorun_fnc_onKeyDown;
 *
 * Public: No
 */

params [["_type", -1]];

// Called straight out of a display event handler the argument is whatever that handler was
// passed, so only take a real type over.
if !(_type isEqualType 0) then {_type = -1};

if (!hasInterface) exitWith {};
if (!GVAR(enable)) exitWith {};
if !(call FUNC(checkDisplay)) exitWith {};

// While running, a type key only switches between walk, jog and run.
if (GVAR(active) && {_type >= 0}) exitWith {
    GVAR(type) = _type;
};

// With a stop key bound, that key is the only thing that stops a run.
if (
    GVAR(active) &&
    {count (actionKeys QGVAR(stopKey)) > 0} &&
    {inputAction QGVAR(stopKey) == 0}
) exitWith {};

if (focusOn != player) exitWith {};
if (!isNull objectParent player) exitWith {};
if (visibleMap && {!(12 in GVAR(displayAllow))}) exitWith {};
if (getUnitFreefallInfo player select 0) exitWith {};

GVAR(stance) = (call FUNC(getStance)) select 1;

if (GVAR(active)) exitWith {
    0 spawn FUNC(stopRunning);
};

if (_type >= 0) then {GVAR(type) = _type};

GVAR(rscId) = [QGVAR(indicator)] call BIS_fnc_rscLayer;
GVAR(rscId) cutRsc [QGVAR(indicator), "PLAIN"];

GVAR(animation) = player call FUNC(getAnimation);
GVAR(isSwim) = GVAR(animation) select [1, 3] in SWIM_ACTIONS;
GVAR(active) = true;

// A run that was stopped without its handler firing again leaves the old one behind.
if (GVAR(animDoneEH) >= 0) then {
    player removeEventHandler ["AnimDone", GVAR(animDoneEH)];
    GVAR(animDoneEH) = -1;
};

GVAR(animDoneEH) = player addEventHandler ["AnimDone", {
    if (
        !alive player ||
        {!GVAR(active)} ||
        {focusOn != player} ||
        {!isNull objectParent player} ||
        {
            getUnitFreefallInfo player select 0 &&
            {(ATLToASL [getPos player select 0, getPos player select 1, 0]) distance (getPosASL player) > getUnitFreefallInfo player select 2}
        } ||
        {incapacitatedState player == "UNCONSCIOUS"}
    ) exitWith {
        0 spawn FUNC(stopRunning);
    };

    call FUNC(updateStance);

    GVAR(animation) = player call FUNC(getAnimation);

    // Entered the water mid-run - hand over to the swimming animation loop.
    if (!GVAR(isSwim) && {GVAR(animation) select [1, 3] in SWIM_ACTIONS}) then {
        GVAR(stance) = (call FUNC(getStance)) select 1;
        GVAR(isSwim) = true;
        0 spawn FUNC(swimToLand);
        0 spawn FUNC(updateSwimAnim);
    };

    if (!GVAR(updatingStance)) then {
        player playMoveNow GVAR(animation);
    };
}];

player playMoveNow GVAR(animation);
