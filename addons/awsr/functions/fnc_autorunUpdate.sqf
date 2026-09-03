#include "..\script_component.hpp"
/*
 * Author: leonz2019, Miss Heda
 * Keeps the run in step with what the player is doing. Runs every frame while a run is on.
 *
 * The run used to change animation only when the last one finished, which is why it could
 * only ever go forwards: by the time it asked again, the key press was long over. Asking every
 * frame is what lets holding a movement key turn the run, and what picks up entering the water,
 * stamina running out and the ground getting steeper without a loop of its own for each.
 *
 * Arguments:
 * Per frame handler arguments <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [awsr_awsr_fnc_autorunUpdate, 0] call CBA_fnc_addPerFrameHandler;
 *
 * Public: No
 */

if (!GVAR(autorun_active)) exitWith {};

if (
    !alive player ||
    {focusOn != player} ||
    {!isNull objectParent player} ||
    {incapacitatedState player == "UNCONSCIOUS"}
) exitWith {
    0 spawn FUNC(autorunStop);
};

// The running figure keeps moving even when nothing else changes.
if (diag_tickTime > GVAR(autorun_iconTime)) then {
    GVAR(autorun_iconTime) = diag_tickTime + 0.1;
    GVAR(autorun_iconFrame) = (GVAR(autorun_iconFrame) % AUTORUN_ICON_FRAMES) + 1;

    private _display = uiNamespace getVariable [QGVAR(display_Autorun), displayNull];

    if (!isNull _display) then {
        (_display displayCtrl IDC_SPEED_BACKGROUND) ctrlSetText format [QPATHTOF(assets\ui\running\run_0%1.paa), GVAR(autorun_iconFrame)];
    };
};

// A stance transition is playing and owns the animation until it is done.
if (GVAR(autorun_updatingStance)) exitWith {};

private _animation = [player] call FUNC(autorunAnimation);

if (_animation != GVAR(autorun_animation)) then {
    GVAR(autorun_animation) = _animation;
    player playMoveNow _animation;
};
