#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Turns the animation slot settings into lists the keybinds can play.
 *
 * Names are checked against the config here rather than on every key press, so a typo drops out
 * of the list instead of being handed to playMoveNow.
 *
 * A name may carry a repeat count - "AmovPercMstpSnonWnonDnon_Salutex3" salutes three times -
 * which is expanded into the list here so nothing downstream has to know about it.
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
            private _entry = _x;
            private _times = 1;

            // "namex3" plays it three times. Checked as a whole name first, because the game has
            // animations that genuinely end in x2 - GestureReloadARX2 among them - and splitting
            // those would leave a name that does not exist.
            if !(isClass (ANIMATION_STATES >> _entry)) then {
                private _match = _entry regexFind [ARR_2("^(.+)[xX](\d+)$",0)];

                if (_match isNotEqualTo []) then {
                    private _parts = _match select 0;

                    _entry = (_parts select 1) select 0;
                    _times = parseNumber ((_parts select 2) select 0);
                };
            };

            if (_entry != "" && {_times > 0} && {isClass (ANIMATION_STATES >> _entry)}) then {
                for "_i" from 1 to (_times min ANIMATION_REPEAT_MAX) do {
                    _list pushBack _entry;
                };
            };
        } forEach ([_raw call CBA_fnc_removeWhitespace, ","] call CBA_fnc_split);
    };

    missionNamespace setVariable [format [QGVAR(animationSlotList_%1), _slot], _list];
};
