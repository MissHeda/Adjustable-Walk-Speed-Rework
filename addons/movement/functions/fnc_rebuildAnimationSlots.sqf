#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Turns the animation slot settings into lists the keybinds can play.
 *
 * Names are checked against the config here rather than on every key press, so a typo drops out
 * of the list instead of being handed to playMoveNow.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call awsr_movement_fnc_rebuildAnimationSlots;
 *
 * Public: No
 */

for "_slot" from 1 to ANIMATION_SLOTS do {
    private _raw = missionNamespace getVariable [format [QGVAR(animationSlot_%1), _slot], ""];
    private _list = [];

    if (_raw isEqualType "") then {
        {
            if (_x != "" && {isClass (ANIMATION_STATES >> _x)}) then {
                _list pushBack _x;
            };
        } forEach ([_raw call CBA_fnc_removeWhitespace, ","] call CBA_fnc_split);
    };

    missionNamespace setVariable [format [QGVAR(animationSlotList_%1), _slot], _list];
};
