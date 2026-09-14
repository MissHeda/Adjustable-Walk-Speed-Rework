#include "..\script_component.hpp"
/*
 * Author: leonz2019, Miss Heda
 * Puts the run into a new stance while it is going.
 *
 * Arguments:
 * 0: Stance key that was pressed <STRING>
 *
 * Return Value:
 * Stance changed <BOOL>
 *
 * Example:
 * ["crouch"] call awsr_movement_fnc_autorunUpdateStance;
 *
 * Public: No
 */

params [["_key", ""]];

if (!hasInterface) exitWith {false};
if (!GVAR(autorun_active)) exitWith {false};
if (!isNull objectParent player) exitWith {false};
if (getUnitFreefallInfo player select 0) exitWith {false};
if (diag_tickTime < GVAR(autorun_stanceUntil)) exitWith {false};

private _newStance = [_key] call FUNC(autorunStance);

if (_newStance select 0) then {
    // Held for the length of the transition rather than the length of this call. Setting a flag
    // and clearing it two lines later left it never observably true, and the animation the
    // transition was meant to be protected from overwrote it on the very next AnimDone.
    GVAR(autorun_stanceUntil) = diag_tickTime + STANCE_TRANSITION_TIME;
    GVAR(autorun_stance) = _newStance select 2;

    // Straight into the new stance's animation. There is no "<from>_<to>" state to play: of the
    // 314 combined transitions the game ships, none has identical halves and every one of them
    // ends standing still, which would end the run. The engine interpolates well enough.
    GVAR(autorun_animation) = [player] call FUNC(autorunAnimation);

    player playMoveNow GVAR(autorun_animation);

    call FUNC(autorunIndicator);
};

(_newStance select 0)
