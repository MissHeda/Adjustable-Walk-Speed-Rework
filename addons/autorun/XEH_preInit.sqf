#include "script_component.hpp"

ADDON = false;

#include "XEH_PREP.hpp"

#define CBA_SETTINGS_AWSR "Adjustable Walking Speed - Rework"

// Run state. Set up here so nothing ever reads one of these before the first activation -
// an undefined variable in a display event handler silently kills the whole handler.
GVAR(active) = false;
GVAR(updatingStance) = false;
GVAR(isSwim) = false;
GVAR(damageAllowed) = false;
GVAR(type) = AUTORUN_RUN;
GVAR(stance) = "Stand";
GVAR(animation) = "";
GVAR(rscId) = -1;
GVAR(animDoneEH) = -1;

// Displays autorun keeps running under. 12 is the map; add your own display IDs from a
// mission or another mod if a run should survive them being open.
GVAR(displayAllow) = [12];

// Enable autorun
[
    QGVAR(enable),
    "CHECKBOX",
    [LLSTRING(SETTING_enable),LLSTRING(SETTING_enable_DESC)],
    [CBA_SETTINGS_AWSR, LSTRING(SETTING_SubCategory)],
    [true],
    0
] call CBA_Settings_fnc_init;

ADDON = true;
