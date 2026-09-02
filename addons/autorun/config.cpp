#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {
            "awsr_main",
            "cba_main"
        };
        author = "Miss Heda";
        authors[] = {"Leon", "Legion", "Miss Heda"};
        url = ECSTRING(main,URL);
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"
#include "CfgUserActions.hpp"
#include "RscTitles.hpp"
