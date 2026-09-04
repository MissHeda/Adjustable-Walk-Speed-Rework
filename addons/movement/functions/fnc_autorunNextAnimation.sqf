#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Steps to the next animation in the list for the pace the run is in.
 *
 * The index is shared across the paces and wrapped by whichever list is being read, so it always
 * lands somewhere - a pace with one animation simply keeps playing it.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call awsr_movement_fnc_autorunNextAnimation;
 *
 * Public: No
 */

if (!GVAR(autorun_active)) exitWith {};

GVAR(autorun_animIndex) = GVAR(autorun_animIndex) + 1;
