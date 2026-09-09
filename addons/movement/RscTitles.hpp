class RscPictureKeepAspect;
class RscStructuredText;

// One title per animation group. They used to share a single title whose picture was swapped,
// which meant the groups also shared its position, its size and its hide timer - setting walk
// to stay up permanently only lasted until a tactical change came along and took the shared
// display away on the tactical timer.
//
// Each title is cut once and then kept for the rest of the mission. Do not go back to cutting a
// fresh one per change: that tears down the display the number is about to be written into.
//
// cls     - class name, also the layer name
// uivar   - variable the display is parked under in uiNamespace
// gridvar - IGUI grid variable, one per group so each can be moved and resized on its own
// defx    - default x before the layout tab has been used
// defy    - default y before the layout tab has been used
// rows    - how many lines of text the box under the picture has room for
// picture - the artwork
#define SPEED_DISPLAY(cls,uivar,gridvar,defx,defy,rows,picture) \
    class GVAR(cls) { \
        idd = -1; \
        onLoad = QUOTE(uiNamespace setVariable [ARR_2(QQGVAR(uivar),_this select 0)]); \
        onUnload = QUOTE(uiNamespace setVariable [ARR_2(QQGVAR(uivar),nil)]); \
        fadeIn = 0; \
        fadeOut = 0; \
        duration = 1e+6; \
        movingEnable = 0; \
        class controls { \
            class background: RscPictureKeepAspect { \
                idc = IDC_SPEED_BACKGROUND; \
                text = QPATHTOF(picture); \
                colorText[] = {1,1,1,1}; \
                x = QUOTE(profileNamespace getVariable [ARR_2('TRIPLES(IGUI,GVAR(gridvar),X)',defx)]); \
                y = QUOTE(profileNamespace getVariable [ARR_2('TRIPLES(IGUI,GVAR(gridvar),Y)',defy)]); \
                w = QUOTE(profileNamespace getVariable [ARR_2('TRIPLES(IGUI,GVAR(gridvar),W)',DISPLAY_W)]); \
                h = QUOTE(profileNamespace getVariable [ARR_2('TRIPLES(IGUI,GVAR(gridvar),H)',DISPLAY_H)]); \
            }; \
            class speedText: RscStructuredText { \
                idc = IDC_SPEED_TEXT; \
                text = ""; \
                sizeEx = QUOTE(GUI_GRID_H); \
                colorText[] = {1,1,1,1}; \
                colorBackground[] = {0,0,0,0}; \
                font = "RobotoCondensed"; \
                x = QUOTE(profileNamespace getVariable [ARR_2('TRIPLES(IGUI,GVAR(gridvar),X)',defx)]); \
                y = QUOTE((profileNamespace getVariable [ARR_2('TRIPLES(IGUI,GVAR(gridvar),Y)',defy)]) + 0.95 * (profileNamespace getVariable [ARR_2('TRIPLES(IGUI,GVAR(gridvar),H)',DISPLAY_H)])); \
                w = QUOTE(profileNamespace getVariable [ARR_2('TRIPLES(IGUI,GVAR(gridvar),W)',DISPLAY_W)]); \
                h = QUOTE(profileNamespace getVariable [ARR_2('TRIPLES(IGUI,GVAR(gridvar),H)',DISPLAY_H)]); \
                class Attributes { \
                    font = "RobotoCondensed"; \
                    color = "#EEEEEE"; \
                    align = "center"; \
                    valign = "middle"; \
                    shadow = 2; \
                    shadowColor = "#3f4345"; \
                    size = "1"; \
                }; \
            }; \
        }; \
    }

// A display with nothing but a line of text - the animation indicator has no artwork to show,
// and a stretched blank picture behind it only made the layout tab look broken.
#define TEXT_DISPLAY(cls,uivar,gridvar,defx,defy)     class GVAR(cls) {         idd = -1;         onLoad = QUOTE(uiNamespace setVariable [ARR_2(QQGVAR(uivar),_this select 0)]);         onUnload = QUOTE(uiNamespace setVariable [ARR_2(QQGVAR(uivar),nil)]);         fadeIn = 0;         fadeOut = 0;         duration = 1e+6;         movingEnable = 0;         class controls {             class speedText: RscStructuredText {                 idc = IDC_SPEED_TEXT;                 text = "";                 sizeEx = QUOTE(GUI_GRID_H);                 colorText[] = {1,1,1,1};                 colorBackground[] = {0,0,0,0};                 font = "RobotoCondensed";                 x = QUOTE(profileNamespace getVariable [ARR_2('TRIPLES(IGUI,GVAR(gridvar),X)',defx)]);                 y = QUOTE(profileNamespace getVariable [ARR_2('TRIPLES(IGUI,GVAR(gridvar),Y)',defy)]);                 w = QUOTE(profileNamespace getVariable [ARR_2('TRIPLES(IGUI,GVAR(gridvar),W)',TEXT_DISPLAY_W)]);                 h = QUOTE(profileNamespace getVariable [ARR_2('TRIPLES(IGUI,GVAR(gridvar),H)',TEXT_DISPLAY_H)]);                 class Attributes {                     font = "RobotoCondensed";                     color = "#EEEEEE";                     align = "center";                     valign = "middle";                     shadow = 2;                     shadowColor = "#3f4345";                     size = "1";                 };             };         };     }

class RscTitles {
    SPEED_DISPLAY(IGUI_Display_Walk,display_Walk,grid_Walk,DISPLAY_X,DISPLAY_Y(0),1,assets\ui\IGUI_Display_Default.paa);
    SPEED_DISPLAY(IGUI_Display_Tactical,display_Tactical,grid_Tactical,DISPLAY_X,DISPLAY_Y(1),1,assets\ui\IGUI_Display_Tactical.paa);
    SPEED_DISPLAY(IGUI_Display_Custom,display_Custom,grid_Custom,DISPLAY_X,DISPLAY_Y(2),1,assets\ui\IGUI_Display_Walk.paa);
    SPEED_DISPLAY(IGUI_Display_Autorun,display_Autorun,grid_Autorun,AUTORUN_X,AUTORUN_Y,3,assets\ui\running\run_01.paa);
    TEXT_DISPLAY(IGUI_Display_Animation,display_Animation,grid_Animation,ANIMATION_X,ANIMATION_Y);
};
