#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * How far the custom keys may take the animation the unit is in, while the custom category is
 * set to adjust animations rather than to be a third group.
 *
 * The animation's own speed is one end of the range - it is what somebody deliberately asked
 * this animation to run at, so there is no reason to let a key go past it. The other end is 1,
 * or the opposite bound of the group the animation belongs to, so a group that has been given a
 * range keeps it. Tactical wins over walk when an animation is in both.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Animation name <STRING>
 *
 * Return Value:
 * 0: Lowest <NUMBER>
 * 1: Highest <NUMBER>
 * 2: Where the animation itself sits <NUMBER>
 *
 * Example:
 * ([player, animationState player] call awsr_movement_fnc_customBounds) params ["_min", "_max"];
 *
 * Public: No
 */

params ["_unit", ["_animation", ""]];

// The animation's own speed anchors the range. Not the speed in force: that moves as the keys
// are pressed, and a range that grows every time you push against it has no end.
private _anchor = _animation call FUNC(animationSpeed);
if (_anchor < 0) then {_anchor = 1};

// The group's range is the counterweight. Tactical is asked first: an animation in both is the
// tactical pace as far as the player is concerned. In no group at all there is only default to
// measure against.
private _low = 1;
private _high = 1;

switch (true) do {
    case (_animation call FUNC(isTacticalAnimation)): {
        _low = GVAR(minAdjustSpeed_Tactical);
        _high = GVAR(maxAdjustSpeed_Tactical);
    };
    case ((_animation call FUNC(animationType)) isEqualTo "walk"): {
        _low = GVAR(minAdjustSpeed_Walk);
        _high = GVAR(maxAdjustSpeed_Walk);
    };
};

[_low min _anchor, _high max _anchor, _anchor]
