class RscPicture;
class RscStructuredText;
class RscTitles {
    // One title for all three animation groups. It is cut once and then kept alive - the
    // picture, the colours and the text are set from awsr_awsr_fnc_displayUpdatedInfo, and
    // hiding it fades the controls rather than tearing the display down. Cutting a fresh title
    // on every change is what used to blank the number instead of updating it.
    class GVAR(IGUI_Display) {
        idd = -1;
        onLoad = QUOTE(uiNamespace setVariable [ARR_2(QQGVAR(speedDisplay_onLoadSave),_this select 0)]);
        onUnload = QUOTE(uiNamespace setVariable [ARR_2(QQGVAR(speedDisplay_onLoadSave),nil)]);
        fadeIn = 0;
        fadeOut = 0;
        duration = 1e+6;
        movingEnable = 0;
        class controls {
            class background: RscPicture {
                idc = IDC_SPEED_BACKGROUND;
                x = QUOTE(profileNamespace getVariable [ARR_2('TRIPLES(IGUI,GVAR(speedDisplay_Preset),X)',(safeZoneX + safeZoneW) - 3.8 * GUI_GRID_W)]);
                y = QUOTE(profileNamespace getVariable [ARR_2('TRIPLES(IGUI,GVAR(speedDisplay_Preset),Y)',safeZoneY + 0.08 * safeZoneH)]);
                w = QUOTE(profileNamespace getVariable [ARR_2('TRIPLES(IGUI,GVAR(speedDisplay_Preset),W)',3.4 * GUI_GRID_W)]);
                h = QUOTE(profileNamespace getVariable [ARR_2('TRIPLES(IGUI,GVAR(speedDisplay_Preset),H)',3.4 * GUI_GRID_H)]);
                text = QPATHTOF(assets\ui\IGUI_Display_Default.paa);
                colorText[] = {1, 1, 1, 1};
            };
            class speedText: RscStructuredText {
                idc = IDC_SPEED_TEXT;
                text = "";
                sizeEx = QUOTE(GUI_GRID_H);
                colorText[] = {1, 1, 1, 1};
                colorBackground[] = {0, 0, 0, 0};
                x = QUOTE((profileNamespace getVariable [ARR_2('TRIPLES(IGUI,GVAR(speedDisplay_Preset),X)',(safeZoneX + safeZoneW) - 3.8 * GUI_GRID_W)]));
                y = QUOTE(((profileNamespace getVariable [ARR_2('TRIPLES(IGUI,GVAR(speedDisplay_Preset),Y)',safeZoneY + 0.08 * safeZoneH)]) + ((profileNamespace getVariable [ARR_2('TRIPLES(IGUI,GVAR(speedDisplay_Preset),H)',3.4 * GUI_GRID_H)]) * 0.95)));
                w = QUOTE((profileNamespace getVariable [ARR_2('TRIPLES(IGUI,GVAR(speedDisplay_Preset),W)',3.4 * GUI_GRID_W)]));
                h = QUOTE((profileNamespace getVariable [ARR_2('TRIPLES(IGUI,GVAR(speedDisplay_Preset),H)',3.4 * GUI_GRID_H)]));
                font = "RobotoCondensed";
                class Attributes {
                    font = "RobotoCondensed";
                    color = "#EEEEEE";
                    align = "center";
                    valign = "middle";
                    shadow = 2;
                    shadowColor = "#3f4345";
                    size = "1";
                };
            };
        };
    };
};
