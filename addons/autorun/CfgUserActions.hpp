// Autorun uses vanilla key actions rather than CBA keybinds on purpose: the run logic asks
// the engine through actionKeys/inputAction whether the stop key or an ignored key is
// currently down, and only CfgUserActions entries answer that.
class CfgUserActions {
    class GVAR(walkKey) {
        displayName = CSTRING(KEYBIND_walk);
        tooltip = CSTRING(KEYBIND_walk_DESC);
        onActivate = QUOTE([AUTORUN_WALK] call FUNC(onKeyDown));
        onDeactivate = "";
        onAnalog = "";
        analogChangeThreshold = 0.1;
    };
    class GVAR(jogKey) {
        displayName = CSTRING(KEYBIND_jog);
        tooltip = CSTRING(KEYBIND_jog_DESC);
        onActivate = QUOTE([AUTORUN_JOG] call FUNC(onKeyDown));
        onDeactivate = "";
        onAnalog = "";
        analogChangeThreshold = 0.1;
    };
    class GVAR(runKey) {
        displayName = CSTRING(KEYBIND_run);
        tooltip = CSTRING(KEYBIND_run_DESC);
        onActivate = QUOTE([AUTORUN_RUN] call FUNC(onKeyDown));
        onDeactivate = "";
        onAnalog = "";
        analogChangeThreshold = 0.1;
    };
    class GVAR(disabledKey) {
        displayName = CSTRING(KEYBIND_disabled);
        tooltip = CSTRING(KEYBIND_disabled_DESC);
        onActivate = "";
        onDeactivate = "";
        onAnalog = "";
        analogChangeThreshold = 0.1;
    };
    class GVAR(stopKey) {
        displayName = CSTRING(KEYBIND_stop);
        tooltip = CSTRING(KEYBIND_stop_DESC);
        onActivate = QUOTE(0 spawn FUNC(stopRunning));
        onDeactivate = "";
        onAnalog = "";
        analogChangeThreshold = 0.1;
    };
};

// Every other preset inherits from Arma2, so defaults set here reach all of them.
class CfgDefaultKeysPresets {
    class Arma2 {
        class Mappings {
            GVAR(stopKey)[] = {
                0x3E // F4
            };
            GVAR(runKey)[] = {
                0x3F // F5
            };
            GVAR(walkKey)[] = {
                0x40 // F6
            };
            GVAR(jogKey)[] = {
                0x41 // F7
            };
            GVAR(disabledKey)[] = {
                0x18, // watch
                "256 + 0x18", // watch (toggle)
                0x25, // compass
                "256 + 0x25", // compass (toggle)
                0x32, // map
                0x31 // night vision
            };
        };
    };
};

class UserActionGroups {
    class GVAR(keyCategory) {
        name = CSTRING(KEYBIND_Category);
        isAddon = 1;
        group[] = {QGVAR(walkKey), QGVAR(jogKey), QGVAR(runKey), QGVAR(disabledKey), QGVAR(stopKey)};
    };
};
