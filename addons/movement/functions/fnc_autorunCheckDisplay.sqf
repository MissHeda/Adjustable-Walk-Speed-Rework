#include "..\script_component.hpp"
/*
 * Author: leonz2019, Miss Heda
 * Checks whether every display autorun refuses to run under is closed.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * All of them are closed <BOOL>
 *
 * Example:
 * call awsr_movement_fnc_autorunCheckDisplay;
 *
 * Public: No
 */

private _isDisplayClosed = true;

{
    if (_x == 12) then {
        _isDisplayClosed = !visibleMap;
    } else {
        if (_isDisplayClosed) then {
            _isDisplayClosed = isNull (findDisplay _x);
        };
    };
} forEach (GVAR(autorun_displayAllow) select {_x isEqualType 0 && {_x >= 0}});

_isDisplayClosed
