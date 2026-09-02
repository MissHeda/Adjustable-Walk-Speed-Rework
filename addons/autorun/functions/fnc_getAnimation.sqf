#include "..\script_component.hpp"
/*
 * Author: leonz2019, Miss Heda
 * Builds the animation name that fits the unit's current state: stance, weapon, load,
 * fatigue, terrain, water and leg damage.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Stop animation instead of a movement one <BOOL> (default: false)
 *
 * Return Value:
 * Animation name <STRING>
 *
 * Example:
 * [player, true] call awsr_autorun_fnc_getAnimation;
 *
 * Public: No
 */

params ["_unit", ["_stop", false, [false]]];

private _isWetSuit = getText (configFile >> "CfgWeapons" >> uniform _unit >> "ItemInfo" >> "uniformType") == "Neopren";
private _isWater = surfaceIsWater (position _unit);
private _isLegHits = (_unit getHitPointDamage "hitlegs") >= 0.5;

private _atl = ASLToATL [position _unit select 0, position _unit select 1, 0] select 2;
if (_atl == 0) then {_atl = -0.0001};
private _asl = eyePos _unit select 2;
private _uw = underwater _unit;

private _isFW = isForcedWalk _unit || {GVAR(type) == AUTORUN_WALK};
private _fatigue = getFatigue _unit;

// Steep ground forces a walk, a moderate slope at least takes the sprint away.
private _terrainAngle = [getPos _unit, getDir _unit] call BIS_fnc_terrainGradAngle;
if (_terrainAngle >= 30) then {
    _isFW = true;
} else {
    if (_terrainAngle >= 17) then {
        _fatigue = 1;
    };
};

if (GVAR(type) == AUTORUN_JOG) then {
    _fatigue = 1;
};

private _cw = currentWeapon _unit;
private _isRfl = _cw != "" && {_cw == primaryWeapon _unit};
private _isPst = _cw != "" && {_cw == handgunWeapon _unit};
private _isLnr = _cw != "" && {_cw == secondaryWeapon _unit};
private _isBin = _cw != "" && {_cw == binocular _unit};

private _action = switch (true) do {
    case (GVAR(stance) == "Sit"): {"adj"};

    case (_isWater && _atl >= 1.7 && _isWetSuit && !_uw): {"sdv"};
    case (_isWater && _atl >= 1.7 && _isWetSuit && _uw && _atl >= 2 && _asl / _atl <= -0.6): {"bdv"};
    case (_isWater && _atl >= 1.7 && _isWetSuit && _uw): {"dve"};

    case (_isWater && _atl >= 1.7 && !_isWetSuit && !_uw): {"ssw"};
    case (_isWater && _atl >= 1.7 && !_isWetSuit && _uw && _atl >= 2 && _asl / _atl <= -0.6): {"bsw"};
    case (_isWater && _atl >= 1.7 && !_isWetSuit && _uw): {"swm"};

    default {"mov"};
};
private _isSwimming = _action in SWIM_ACTIONS;

private _pose = switch (true) do {
    case (_isSwimming): {"erc"};
    case (GVAR(stance) == "Crouch"): {"knl"};
    case (GVAR(stance) == "Prone"): {"pne"};
    case (GVAR(stance) == "Sit"): {"pne"};
    default {"erc"};
};

private _movement = switch (true) do {
    case (_stop): {"stp"};
    case (GVAR(stance) == "Sit"): {"wlk"};

    case (!_isFW && _fatigue < 1 && _isWetSuit && _isSwimming): {"spr"};
    case (!_isFW && _fatigue == 1 && _isWetSuit && _isSwimming): {"run"};
    case (!_isFW && _fatigue < 1 && !_isWetSuit && _isSwimming): {"run"};
    case (!_isFW && _fatigue == 1 && !_isWetSuit && _isSwimming): {"wlk"};
    case ((_isFW || _isLegHits) && _action in ["dve", "sdv", "ssw", "bdv"]): {"wlk"};

    case (_isLegHits && GVAR(stance) == "Prone" && _isBin): {"wlk"};
    case (_isLegHits && GVAR(stance) == "Prone"): {"run"};
    case (_isLegHits): {"lmp"};

    case (_isFW && GVAR(stance) == "Prone" && !_isBin): {"run"};
    case (_isFW): {"wlk"};

    case (_fatigue < 1 && _cw == "" && GVAR(stance) == "Prone"): {"spr"};
    case (_fatigue < 1): {"eva"};

    case (_fatigue == 1 && _isRfl && GVAR(stance) == "Prone"): {"spr"};
    case (_fatigue == 1): {"run"};
    default {"run"};
};

private _stance = switch (true) do {
    case (_isSwimming): {"non"};
    case (_isBin && _movement != "run" && _movement != "eva"): {"opt"};
    case (_isBin): {"non"};
    case (GVAR(stance) == "Sit"): {"ras"};
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

private _direction = switch (true) do {
    case (GVAR(stance) == "Sit" && _stop): {"up"};
    case (_stop): {"non"};
    case (GVAR(stance) == "Sit"): {"up_f"};
    case (!_isSwimming && _movement == "wlk" && _isRfl && _pose == "erc"): {"f_ver2"};
    default {"f"};
};

format ["a%1p%2m%3s%4w%5d%6", _action, _pose, _movement, _stance, _weapon, _direction]
