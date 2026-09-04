#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Puts an animation speed coefficient onto the unit, and the matching audibility with it.
 *
 * Only does anything when the value actually changed. AnimStateChanged fires several times
 * a second while a unit moves, and this used to broadcast a JIP flagged remote call on every
 * single one of them - one growing JIP queue entry per animation step, replayed to everyone
 * who joined later.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Coefficient <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, 0.7] call awsr_movement_fnc_applySpeed;
 *
 * Public: No
 */

params ["_unit", ["_coef", 1]];

if (GETVAR(_unit,GVAR(appliedSpeed),-1) != _coef) then {
    SETVAR(_unit,GVAR(appliedSpeed),_coef);

    // Locally first: a mission with a restrictive CfgRemoteExec can drop the remote call,
    // and the player still has to get their own speed.
    _unit setAnimSpeedCoef _coef;

    // Tell ACE's advanced fatigue to keep its hands off while we are driving the speed, and
    // give it back the moment we are not.
    if (_unit isEqualTo player) then {
        [_coef != 1] call FUNC(aceAnimClaim);
    };

    if (isMultiplayer) then {
        // Everyone, including this machine - applying the same coefficient twice costs nothing,
        // and a negative target would have meant "all except owner id 2", which is the server:
        // on a listen server the host would never have seen anyone else's speed.
        private _jip = QGVAR(speed) + netId _unit;

        [_unit, _coef] remoteExecCall ["setAnimSpeedCoef", 0, _jip];

        // A string JIP id is only ever replaced, never dropped, so the default is the moment to
        // take the entry back out rather than leave one per unit in the queue for the mission.
        if (_coef == 1) then {
            remoteExecCall ["", _jip];
        };
    };
};

// Remember what the unit sounded like before we ever touched it, so switching the setting
// off or leaving a whitelisted animation gives the mission its own value back.
private _base = GETVAR(_unit,GVAR(baseAudibleCoef),-1);

if !(GVAR(adjustAudioDetection)) exitWith {
    // Never touched it, nothing to give back.
    if (_base < 0) exitWith {};

    if (GETVAR(_unit,GVAR(appliedAudible),-1) != _base) then {
        SETVAR(_unit,GVAR(appliedAudible),_base);
        _unit setUnitTrait ["audibleCoef", _base, true];
    };
};

if (_base < 0) then {
    _base = _unit getUnitTrait "audibleCoef";
    if !(_base isEqualType 0) then {_base = 1};
    SETVAR(_unit,GVAR(baseAudibleCoef),_base);
};

// Moving faster than default never makes you quieter than the unit already was.
private _audible = _base * (_coef min 1);

if (GETVAR(_unit,GVAR(appliedAudible),-1) != _audible) then {
    SETVAR(_unit,GVAR(appliedAudible),_audible);

    // Global: whoever runs the AI that is listening is usually not this machine.
    _unit setUnitTrait ["audibleCoef", _audible, true];
};
