#define COMPONENT autorun
#define COMPONENT_BEAUTIFIED Autorun
#include "\z\awsr\addons\main\script_mod.hpp"
#include "\z\awsr\addons\main\script_macros.hpp"

// Animation "action" segments that mean the unit is in the water. The stance machine and
// the stop logic both branch on these, so they live in one place.
#define SWIM_ACTIONS ["sdv","bdv","dve","ssw","bsw","swm"]

// How long the stop keeps its damage handler on. Long enough for the frames the engine needs
// to settle the forced animation, short enough that it cannot be used to sit out a firefight.
#define STOP_DAMAGE_GRACE 0.25

// Autorun types, as handed over by the keybinds.
#define AUTORUN_WALK 1
#define AUTORUN_JOG 2
#define AUTORUN_RUN 3

// Every keybind this addon registers, under the shared "AWSR" mod name. The display handler
// checks a pressed key against all of them before deciding it should stop the run.
#define AUTORUN_KEY_ACTIONS [QGVAR(walkKey),QGVAR(jogKey),QGVAR(runKey),QGVAR(stopKey),QGVAR(disabledKey)]

#define IDD_INDICATOR 80424
#define IDC_INDICATOR_HINT 80426
#define IDC_INDICATOR_ICON 80425
