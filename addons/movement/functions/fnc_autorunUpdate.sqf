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
 * [awsr_movement_fnc_autorunUpdate, 0] call CBA_fnc_addPerFrameHandler;
 *
 * Public: No
 */

if (!GVAR(autorun_active)) exitWith {};

if (
    !alive player ||
    {focusOn != player} ||
    {!isNull objectParent player} ||
    {incapacitatedState player == "UNCONSCIOUS"} ||

    // Switched to a launcher, binoculars or bare hands mid run - there is nothing to run with.
    {([player] call FUNC(autorunWeapon)) isEqualTo ""}
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
if (diag_tickTime < GVAR(autorun_stanceUntil)) exitWith {};

// Out of breath: down a pace, the same moment ACE would take it away by itself.
private _max = [player, GVAR(autorun_tier)] call FUNC(autorunMaxTier);

if (GVAR(autorun_tier) > _max) then {
    GVAR(autorun_tier) = _max;
    [] call FUNC(autorunExhausted);
    call FUNC(autorunIndicator);
};

// The key hints name the animations for whatever is in the hands, so a weapon swap redraws them.
private _weapon = [player] call FUNC(autorunWeapon);

if (_weapon != GVAR(autorun_lastWeapon)) then {
    GVAR(autorun_lastWeapon) = _weapon;
    call FUNC(autorunIndicator);
};

private _animation = [player] call FUNC(autorunAnimation);

// Against the unit, not against what we last asked for. Anything that takes the animation away -
// a stance key the engine got to first, another mod, a scripted sequence - used to leave the run
// dead while the indicator carried on, because our own bookkeeping still agreed with itself.
if (_animation != GVAR(autorun_animation) || {toLowerANSI (animationState player) != toLowerANSI _animation}) then {
    GVAR(autorun_animation) = _animation;
    player playMoveNow _animation;
};
