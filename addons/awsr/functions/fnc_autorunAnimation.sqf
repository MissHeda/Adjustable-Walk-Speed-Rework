#include "..\script_component.hpp"
/*
 * Author: leonz2019, Miss Heda
 * Builds the animation that fits the unit's current state: tier, stance, weapon, stamina,
 * terrain, water, injuries - and the direction the player is asking for.
 *
 * The run used to be forwards and nothing else. The name is assembled from the same six
 * segments the engine uses, and the last of them is the direction, so feeding it the movement
 * keys is what lets a running player strafe or back up without dropping out of the run.
 *
 * Not every segment combination exists as an animation - there is no sprinting backwards - so
 * the name is checked against the config and simpler ones are tried until one exists. That way
 * a missing combination degrades instead of handing playMoveNow a name that does nothing.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Stop animation instead of a movement one <BOOL> (default: false)
 *
 * Return Value:
 * Animation name <STRING>
 *
 * Example:
 * private _animation = [player] call awsr_awsr_fnc_autorunAnimation;
 *
 * Public: No
 */

params ["_unit", ["_stop", false, [false]]];



private _tier = GVAR(autorun_tier);

// Water first, and only the water. This runs twenty times a second, and a pinned animation -
// which is what every pace ships with - needs nothing else to answer with, so everything the
// full lookup wants stays below the shortcut rather than being worked out and thrown away.
private _isWater = surfaceIsWater (position _unit);
private _isWetSuit = false;
private _uw = false;
private _asl = 0;

// Never zero: the switch below divides by it, and SQF's && evaluates both sides even when the
// left one already answered the question, so that division runs on dry land too.
private _atl = -0.0001;

if (_isWater) then {
    _atl = ASLToATL [ARR_3(position _unit select 0,position _unit select 1,0)] select 2;
    if (_atl == 0) then {_atl = -0.0001};

    _asl = eyePos _unit select 2;
    _uw = underwater _unit;
    _isWetSuit = getText (configFile >> "CfgWeapons" >> uniform _unit >> "ItemInfo" >> "uniformType") == "Neopren";
};

private _cw = currentWeapon _unit;
private _isRfl = _cw != "" && {_cw == primaryWeapon _unit};
private _isPst = _cw != "" && {_cw == handgunWeapon _unit};
private _isLnr = _cw != "" && {_cw == secondaryWeapon _unit};
private _isBin = _cw != "" && {_cw == binocular _unit};

private _action = switch (true) do {
    case (GVAR(autorun_stance) == "Sit"): {"adj"};

    case (_isWater && _atl >= 1.7 && _isWetSuit && !_uw): {"sdv"};
    case (_isWater && _atl >= 1.7 && _isWetSuit && _uw && _atl >= 2 && _asl / _atl <= -0.6): {"bdv"};
    case (_isWater && _atl >= 1.7 && _isWetSuit && _uw): {"dve"};

    case (_isWater && _atl >= 1.7 && !_isWetSuit && !_uw): {"ssw"};
    case (_isWater && _atl >= 1.7 && !_isWetSuit && _uw && _atl >= 2 && _asl / _atl <= -0.6): {"bsw"};
    case (_isWater && _atl >= 1.7 && !_isWetSuit && _uw): {"swm"};

    default {"mov"};
};
private _isSwimming = _action in SWIM_ACTIONS;

// The pinned animation for this pace, if there is a usable one. Everything past here only runs
// when there is not - in the water, during a stop, or with a box emptied out.
private _animation = "";

if (!_stop && {!_isSwimming}) then {
    private _pistol = ([_unit] call FUNC(autorunWeapon)) isEqualTo "pst";

    private _override = switch (_tier) do {
        case AUTORUN_WALK: {[ARR_2(GVAR(autorun_animation_Walk),GVAR(autorun_animation_WalkPistol))] select _pistol};
        case AUTORUN_JOG: {[ARR_2(GVAR(autorun_animation_Jog),GVAR(autorun_animation_JogPistol))] select _pistol};
        default {[ARR_2(GVAR(autorun_animation_Run),GVAR(autorun_animation_RunPistol))] select _pistol};
    };

    // Checked against the config once per name rather than twenty times a second - the box only
    // changes when someone edits it.
    if (
        _override != "" &&
        {_override == GVAR(autorun_checkedOverride) || {isClass (ANIMATION_STATES >> _override)}}
    ) then {
        GVAR(autorun_checkedOverride) = _override;
        _animation = _override;
    };
};

if (_animation != "") exitWith {_animation};

private _isLegHits = (_unit getHitPointDamage "hitlegs") >= 0.5;
private _fatigue = getFatigue _unit;
private _isFW = isForcedWalk _unit || {_tier <= AUTORUN_WALK};

// Steep ground forces a walk, a moderate slope at least takes the sprint away.
private _terrainAngle = [getPos _unit, getDir _unit] call BIS_fnc_terrainGradAngle;
if (_terrainAngle >= 30) then {
    _isFW = true;
} else {
    if (_terrainAngle >= 17) then {
        _fatigue = 1;
    };
};

if (_tier == AUTORUN_JOG) then {
    _fatigue = 1;
};

private _wantsSprint = _tier >= AUTORUN_RUN;

private _pose = switch (true) do {
    case (_isSwimming): {"erc"};
    case (GVAR(autorun_stance) == "Crouch"): {"knl"};
    case (GVAR(autorun_stance) == "Prone"): {"pne"};
    case (GVAR(autorun_stance) == "Sit"): {"pne"};
    default {"erc"};
};

private _movement = switch (true) do {
    case (_stop): {"stp"};
    case (GVAR(autorun_stance) == "Sit"): {"wlk"};

    case (!_isFW && _fatigue < 1 && _isWetSuit && _isSwimming): {"spr"};
    case (!_isFW && _fatigue == 1 && _isWetSuit && _isSwimming): {"run"};
    case (!_isFW && _fatigue < 1 && !_isWetSuit && _isSwimming): {"run"};
    case (!_isFW && _fatigue == 1 && !_isWetSuit && _isSwimming): {"wlk"};
    case ((_isFW || _isLegHits) && _action in ["dve", "sdv", "ssw", "bdv"]): {"wlk"};

    case (_isLegHits && GVAR(autorun_stance) == "Prone" && _isBin): {"wlk"};
    case (_isLegHits && GVAR(autorun_stance) == "Prone"): {"run"};
    case (_isLegHits): {"lmp"};

    case (_isFW && GVAR(autorun_stance) == "Prone" && !_isBin): {"run"};
    case (_isFW): {"wlk"};

    case (_wantsSprint): {"spr"};
    case (_fatigue < 1 && _cw == "" && GVAR(autorun_stance) == "Prone"): {"spr"};
    case (_fatigue < 1): {"eva"};

    case (_fatigue == 1 && _isRfl && GVAR(autorun_stance) == "Prone"): {"spr"};
    default {"run"};
};

private _stance = switch (true) do {
    case (_isSwimming): {"non"};
    case (_isBin && _movement != "run" && _movement != "eva"): {"opt"};
    case (_isBin): {"non"};
    case (GVAR(autorun_stance) == "Sit"): {"ras"};
    case (_cw == ""): {"non"};
    case (_isLnr && _movement == "eva"): {"low"};
    case (_isLnr): {"ras"};
    case (_isLegHits && (_isRfl || _isPst)): {"low"};
    case ((_pose == "pne" || _isFW) && (_isRfl || _isPst)): {"low"};
    case (_pose != "pne" && (_isRfl || _isPst)): {"ras"};
    default {"low"};
};

private _weapon = switch (true) do {
    case (_cw == ""): {"non"};
    case (_isRfl): {"rfl"};
    case (_isPst): {"pst"};
    case (_isLnr): {"lnr"};
    case (_isBin): {"bin"};
    default {"non"};
};

// Forwards. Reaching for a movement key ends the run rather than steering it.
private _direction = "f";

// Directions the stop and the sitting animations do not have.
private _directions = switch (true) do {
    case (GVAR(autorun_stance) == "Sit" && _stop): {["up"]};
    case (_stop): {["non"]};
    case (GVAR(autorun_stance) == "Sit"): {["up_f"]};

    // Erect walking with a lowered rifle only exists as the _ver2 set.
    case (!_isSwimming && _movement == "wlk" && _isRfl && _pose == "erc"): {
        [_direction + "_ver2", _direction, "f_ver2", "f"]
    };

    default {[_direction, "f"]};
};

// Fall back through slower movements when the exact one does not exist for this direction -
// there is no sprinting sideways, but there is running sideways.
private _movements = [_movement];
switch (_movement) do {
    case "spr": {_movements append ["eva", "run", "wlk"]};
    case "eva": {_movements append ["run", "wlk"]};
    case "run": {_movements append ["wlk"]};
    case "lmp": {_movements append ["wlk"]};
};

// Resolving a name is a handful of config lookups and this runs many times a second, so the
// answer for a given set of segments is worked out once.
private _key = format ["%1%2%3%4%5%6", _action, _pose, _movement, _stance, _weapon, _directions param [0, "f"]];
_animation = GVAR(autorun_nameCache) getOrDefault [_key, ""];

if (_animation == "") then {
    {
        private _try = _x;

        {
            private _candidate = format ["a%1p%2m%3s%4w%5d%6", _action, _pose, _try, _stance, _weapon, _x];

            if (isClass (ANIMATION_STATES >> _candidate)) exitWith {_animation = _candidate};
        } forEach _directions;

        if (_animation != "") exitWith {};
    } forEach _movements;

    // Nothing matched - hand back the plain forwards name and let the engine ignore it rather
    // than returning something empty.
    if (_animation == "") then {
        _animation = format ["a%1p%2m%3s%4w%5d%6", _action, _pose, _movement, _stance, _weapon, _directions param [0, "f"]];
    };

    GVAR(autorun_nameCache) set [_key, _animation];
};

_animation
