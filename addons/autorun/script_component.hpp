#define COMPONENT autorun
#define COMPONENT_BEAUTIFIED Autorun
#include "\z\awsr\addons\main\script_mod.hpp"
#include "\z\awsr\addons\main\script_macros.hpp"

// Animation "action" segments that mean the unit is in the water. The stance machine and
// the stop logic both branch on these, so they live in one place.
#define SWIM_ACTIONS ["sdv","bdv","dve","ssw","bsw","swm"]

// Autorun types, as handed over by the vanilla key actions.
#define AUTORUN_WALK 1
#define AUTORUN_JOG 2
#define AUTORUN_RUN 3

#define IDD_INDICATOR 80424
#define IDC_INDICATOR_HINT 80426
#define IDC_INDICATOR_ICON 80425
