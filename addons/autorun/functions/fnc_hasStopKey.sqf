#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Answers whether the player has a stop key bound. With one bound it is the only thing that
 * stops a run; without one, any key does.
 *
 * Read from CBA rather than remembered, so rebinding the key in the CBA keybind menu takes
 * effect without a restart.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * A stop key is bound <BOOL>
 *
 * Example:
 * if (call awsr_autorun_fnc_hasStopKey) then {...};
 *
 * Public: No
 */

private _keybind = ["AWSR", QGVAR(stopKey)] call CBA_fnc_getKeybind;

!isNil "_keybind" && {(_keybind param [8, []]) isNotEqualTo []}
