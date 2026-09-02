class CfgUIGrids {
    class IGUI {
        class Presets {
            class Arma3 {
                class Variables {
                    GVAR(speedDisplay_Preset)[] = {
                        {
                            QUOTE((safeZoneX + safeZoneW) - 3.8 * GUI_GRID_W),
                            QUOTE(safeZoneY + 0.1 * safeZoneH),
                            QUOTE(3.4 * GUI_GRID_W),
                            QUOTE(3.4 * GUI_GRID_H)
                        },
                        QUOTE(GUI_GRID_W),
                        QUOTE(GUI_GRID_H)
                    };
                };
            };
        };
        class Variables {
            class GVAR(speedDisplay_Preset) {
                displayName = CSTRING(IGUI_DisplayName);
                description = CSTRING(IGUI_Description);
                preview = QPATHTOF(assets\ui\IGUI_Display_Default.paa);
                saveToProfile[] = {0, 1};
                canResize = 1;
            };
        };
    };
};
