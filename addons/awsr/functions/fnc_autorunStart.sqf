#include "..\script_component.hpp"
/*
 * Author: leonz2019, Miss Heda
 * Starts a run at the tier that is already set.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call awsr_awsr_fnc_autorunStart;
 *
 * Public: No
 */

if (!hasInterface) exitWith {};

// Passed explicitly: a bare call leaves _this as whatever the caller had, and the function
// reads a stance key out of it.
GVAR(autorun_stance) = ([""] call FUNC(autorunStance)) select 1;

GVAR(autorun_animation) = [player] call FUNC(autorunAnimation);
GVAR(autorun_active) = true;
GVAR(autorun_iconFrame) = 1;
GVAR(autorun_iconTime) = 0;

// A run that ended without its handler firing again leaves the old one behind.
if (GVAR(autorun_animDoneEH) >= 0) then {
    player removeEventHandler ["AnimDone", GVAR(autorun_animDoneEH)];
};

GVAR(autorun_animDoneEH) = player addEventHandler ["AnimDone", {call FUNC(autorunAnimDone)}];

if (GVAR(autorun_pfh) >= 0) then {
    [GVAR(autorun_pfh)] call CBA_fnc_removePerFrameHandler;
};

// Often enough that letting go of a movement key is felt straight away, rarely enough that the
// state it works out is not rebuilt on every single frame.
GVAR(autorun_pfh) = [FUNC(autorunUpdate), 0.05] call CBA_fnc_addPerFrameHandler;

call FUNC(autorunIndicator);

player playMoveNow GVAR(autorun_animation);
