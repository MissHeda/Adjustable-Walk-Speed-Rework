class RscPicture;
class RscStructuredText;
class RscTitles {
    class GVAR(IGUI_Display_Default) {
        idd = -1;
        onLoad = QUOTE(uiNamespace setVariable [ARR_2(QQGVAR(speedDisplay_onLoadSave),_this select 0)]);
        onUnload = QUOTE(uiNamespace setVariable [ARR_2(QQGVAR(speedDisplay_onLoadSave),nil)]);
        fadeIn = 0;
        fadeOut = 0.2;
        duration = 5;
        movingEnable = 0;
        class controls {
            class background: RscPicture {
                idc = 1000;
                x = QUOTE(profileNamespace getVariable [ARR_2('TRIPLES(IGUI,GVAR(speedDisplay_Preset),X)',(safeZoneX + safeZoneW) - 3.8 * GUI_GRID_W)]);
                y = QUOTE(profileNamespace getVariable [ARR_2('TRIPLES(IGUI,GVAR(speedDisplay_Preset),Y)',safeZoneY + 0.08 * safeZoneH)]);
                w = QUOTE(profileNamespace getVariable [ARR_2('TRIPLES(IGUI,GVAR(speedDisplay_Preset),W)',3.4 * GUI_GRID_W)]);
                h = QUOTE(profileNamespace getVariable [ARR_2('TRIPLES(IGUI,GVAR(speedDisplay_Preset),H)',3.4 * GUI_GRID_H)]);
                text = QPATHTOF(assets\ui\IGUI_Display_Default.paa);
                colorText[] = {QUOTE(missionNamespace getVariable [ARR_2(QQGVAR(IGUI_imageColor_Custom),[ARR_4(1,1,1,1)])] select 0), QUOTE(missionNamespace getVariable [ARR_2(QQGVAR(IGUI_imageColor_Custom),[ARR_4(1,1,1,1)])] select 1), QUOTE(missionNamespace getVariable [ARR_2(QQGVAR(IGUI_imageColor_Custom),[ARR_4(1,1,1,1)])] select 2), QUOTE(missionNamespace getVariable [ARR_2(QQGVAR(IGUI_imageColor_Custom),[ARR_4(1,1,1,1)])] select 3)};
            };
            class speedText: RscStructuredText {
                idc = 1001;
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
    class GVAR(IGUI_Display_Walk): GVAR(IGUI_Display_Default) {
        class controls: controls {
            class background: background {
                text = QPATHTOF(assets\ui\IGUI_Display_Walk.paa);
                colorText[] = {QUOTE(missionNamespace getVariable [ARR_2(QQGVAR(IGUI_imageColor_Walk),[ARR_4(1,1,1,1)])] select 0), QUOTE(missionNamespace getVariable [ARR_2(QQGVAR(IGUI_imageColor_Walk),[ARR_4(1,1,1,1)])] select 1), QUOTE(missionNamespace getVariable [ARR_2(QQGVAR(IGUI_imageColor_Walk),[ARR_4(1,1,1,1)])] select 2), QUOTE(missionNamespace getVariable [ARR_2(QQGVAR(IGUI_imageColor_Walk),[ARR_4(1,1,1,1)])] select 3)};
            };
            class speedText: speedText {
                class Attributes: Attributes {
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
    class GVAR(IGUI_Display_Tactical): GVAR(IGUI_Display_Default) {
        class controls: controls {
            class background: background {
                text = QPATHTOF(assets\ui\IGUI_Display_Tactical.paa);
                colorText[] = {QUOTE(missionNamespace getVariable [ARR_2(QQGVAR(IGUI_imageColor_Tactical),[ARR_4(1,1,1,1)])] select 0), QUOTE(missionNamespace getVariable [ARR_2(QQGVAR(IGUI_imageColor_Tactical),[ARR_4(1,1,1,1)])] select 1), QUOTE(missionNamespace getVariable [ARR_2(QQGVAR(IGUI_imageColor_Tactical),[ARR_4(1,1,1,1)])] select 2), QUOTE(missionNamespace getVariable [ARR_2(QQGVAR(IGUI_imageColor_Tactical),[ARR_4(1,1,1,1)])] select 3)};
            };
            class speedText: speedText {
                class Attributes: Attributes {
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
    class GVAR(IGUI_Display_Custom): GVAR(IGUI_Display_Default) {
        class controls: controls {
            class background: background {
                text = QPATHTOF(assets\ui\IGUI_Display_Default.paa);
                colorText[] = {QUOTE(missionNamespace getVariable [ARR_2(QQGVAR(IGUI_imageColor_Custom),[ARR_4(1,1,1,1)])] select 0), QUOTE(missionNamespace getVariable [ARR_2(QQGVAR(IGUI_imageColor_Custom),[ARR_4(1,1,1,1)])] select 1), QUOTE(missionNamespace getVariable [ARR_2(QQGVAR(IGUI_imageColor_Custom),[ARR_4(1,1,1,1)])] select 2), QUOTE(missionNamespace getVariable [ARR_2(QQGVAR(IGUI_imageColor_Custom),[ARR_4(1,1,1,1)])] select 3)};
            };
            class speedText: speedText {
                class Attributes: Attributes {
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
