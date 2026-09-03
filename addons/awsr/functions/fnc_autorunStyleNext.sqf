#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Steps to the next movement style during a run.
 *
 * Style 0 is whatever fits the situation - the animation the run works out for itself. Anything
 * after that comes from the styles setting, so a walk animation another mod brings along only
 * has to be typed into that box to become something the run can be switched to in game.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call awsr_awsr_fnc_autorunStyleNext;
 *
 * Public: No
 */

if (!GVAR(autorun_active)) exitWith {};
if (!GVAR(autorun_enableStyles)) exitWith {};
if (GVAR(autorun_styleList) isEqualTo []) exitWith {};

GVAR(autorun_styleIndex) = (GVAR(autorun_styleIndex) + 1) % ((count GVAR(autorun_styleList)) + 1);

call FUNC(autorunIndicator);
