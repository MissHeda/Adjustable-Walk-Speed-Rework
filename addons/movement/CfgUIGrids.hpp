// One entry per animation group in the layout tab, so each display can be dragged and resized
// on its own. gridvar has to match the one the matching RscTitles class reads.
#define SPEED_DISPLAY_PRESET(gridvar,defx,defy) \
    GVAR(gridvar)[] = { \
        { \
            QUOTE(defx), \
            QUOTE(defy), \
            QUOTE(DISPLAY_W), \
            QUOTE(DISPLAY_H) \
        }, \
        QUOTE(GUI_GRID_W), \
        QUOTE(GUI_GRID_H) \
    }

#define TEXT_DISPLAY_PRESET(gridvar,defx,defy)     GVAR(gridvar)[] = {         {             QUOTE(defx),             QUOTE(defy),             QUOTE(TEXT_DISPLAY_W),             QUOTE(TEXT_DISPLAY_H)         },         QUOTE(GUI_GRID_W),         QUOTE(GUI_GRID_H)     }

// No preview: there is no artwork behind this one, and lending it a speed display's picture
// only made the layout tab claim something that is not there.
#define TEXT_DISPLAY_VARIABLE(gridvar,name)     class GVAR(gridvar) {         displayName = name;         description = CSTRING(IGUI_Description);         saveToProfile[] = {0, 1};         canResize = 1;     }

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
                    SPEED_DISPLAY_PRESET(grid_Walk,DISPLAY_X,DISPLAY_Y(0));
                    SPEED_DISPLAY_PRESET(grid_Tactical,DISPLAY_X,DISPLAY_Y(1));
                    SPEED_DISPLAY_PRESET(grid_Custom,DISPLAY_X,DISPLAY_Y(2));
                    SPEED_DISPLAY_PRESET(grid_Autorun,AUTORUN_X,AUTORUN_Y);
                    TEXT_DISPLAY_PRESET(grid_Animation,ANIMATION_X,ANIMATION_Y);
                };
            };
        };
        class Variables {
            SPEED_DISPLAY_VARIABLE(grid_Walk,CSTRING(IGUI_DisplayName_Walk),assets\ui\IGUI_Display_Walk.paa);
            SPEED_DISPLAY_VARIABLE(grid_Tactical,CSTRING(IGUI_DisplayName_Tactical),assets\ui\IGUI_Display_Tactical.paa);
            SPEED_DISPLAY_VARIABLE(grid_Custom,CSTRING(IGUI_DisplayName_Custom),assets\ui\IGUI_Display_Default.paa);
            SPEED_DISPLAY_VARIABLE(grid_Autorun,CSTRING(IGUI_DisplayName_Autorun),assets\ui\running\run_01.paa);
            TEXT_DISPLAY_VARIABLE(grid_Animation,CSTRING(IGUI_DisplayName_Animation));
        };
    };
};
