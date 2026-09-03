#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Redraws the autorun indicator, or takes it away when no run is going.
 *
 * It is the same kind of display as the three speed ones - same controls, same update path,
 * its own entry in the layout tab - so it can be moved and resized like the rest.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call awsr_awsr_fnc_autorunIndicator;
 *
 * Public: No
 */

if (!hasInterface) exitWith {};

if (!GVAR(autorun_active) || {!GVAR(IGUI_showAutorun)}) exitWith {
    [QGVAR(display_Autorun)] call FUNC(hideIGUI);
};

private _tier = switch (GVAR(autorun_tier)) do {
    case AUTORUN_WALK: {LLSTRING(AUTORUN_tier_walk)};
    case AUTORUN_JOG: {LLSTRING(AUTORUN_tier_jog)};
    default {LLSTRING(AUTORUN_tier_run)};
};

private _lines = ["<t size='1.15'>" + _tier + "</t>", GVAR(autorun_label)];

// Whatever the player has the stop bound to right now, rather than what it was at start up.
private _keybind = ["AWSR", QGVAR(autorun_stopKey)] call CBA_fnc_getKeybind;

if (!isNil "_keybind") then {
    private _keys = _keybind param [8, []];

    if (_keys isNotEqualTo []) then {
        _lines pushBack format [LLSTRING(AUTORUN_HUD_stop), toUpper ((_keys select 0) call CBA_fnc_localizeKey)];
    };
};

private _text = "<t color='" + GVAR(IGUI_textColor_Autorun) + "'>" + (_lines joinString "<br/>") + "</t>";
private _fontHeight = (profileNamespace getVariable [QUOTE(TRIPLES(IGUI,GVAR(grid_Autorun),H)), DISPLAY_H]) * 0.357 * GVAR(IGUI_textSize_Autorun);

[
    QGVAR(IGUI_Display_Autorun),
    QGVAR(display_Autorun),
    _text,
    _fontHeight,
    GVAR(IGUI_imageColor_Autorun),
    0
] call FUNC(updateIGUI);
