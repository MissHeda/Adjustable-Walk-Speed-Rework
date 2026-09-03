// One entry per animation group in the layout tab, so each display can be dragged and resized
// on its own. gridvar has to match the one the matching RscTitles class reads.
#define SPEED_DISPLAY_PRESET(gridvar,row) \
    GVAR(gridvar)[] = { \
        { \
            QUOTE(DISPLAY_X), \
            QUOTE(DISPLAY_Y(row)), \
            QUOTE(DISPLAY_W), \
            QUOTE(DISPLAY_H) \
        }, \
        QUOTE(GUI_GRID_W), \
        QUOTE(GUI_GRID_H) \
    }

#define SPEED_DISPLAY_VARIABLE(gridvar,name,picture) \
    class GVAR(gridvar) { \
        displayName = name; \
        description = CSTRING(IGUI_Description); \
        preview = QPATHTOF(picture); \
        saveToProfile[] = {0, 1}; \
        canResize = 1; \
    }

class CfgUIGrids {
    class IGUI {
        class Presets {
            class Arma3 {
                class Variables {
                    SPEED_DISPLAY_PRESET(grid_Walk,0);
                    SPEED_DISPLAY_PRESET(grid_Tactical,1);
                    SPEED_DISPLAY_PRESET(grid_Custom,2);
                    SPEED_DISPLAY_PRESET(grid_Autorun,3);
                };
            };
        };
        class Variables {
            SPEED_DISPLAY_VARIABLE(grid_Walk,CSTRING(IGUI_DisplayName_Walk),assets\ui\IGUI_Display_Walk.paa);
            SPEED_DISPLAY_VARIABLE(grid_Tactical,CSTRING(IGUI_DisplayName_Tactical),assets\ui\IGUI_Display_Tactical.paa);
            SPEED_DISPLAY_VARIABLE(grid_Custom,CSTRING(IGUI_DisplayName_Custom),assets\ui\IGUI_Display_Default.paa);
            SPEED_DISPLAY_VARIABLE(grid_Autorun,CSTRING(IGUI_DisplayName_Autorun),assets\ui\running\run_01.paa);
        };
    };
};
