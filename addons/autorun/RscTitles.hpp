class RscTitles {
    class GVAR(indicator) {
        idd = IDD_INDICATOR;
        duration = 1e+6;
        movingEnable = 0;
        enableSimulation = 1;
        fadein = 0;
        fadeOut = 0;
        onLoad = QUOTE(_this call FUNC(onload));
        class controls {
            class Hint {
                idc = IDC_INDICATOR_HINT;
                type = 0;
                style = 2;
                x = 0;
                y = 0.75;
                w = 1;
                h = 0.25;
                font = "RobotoCondensed";
                sizeEx = 0.035;
                colorBackground[] = {0,0,0,0};
                colorText[] = {1,1,1,1};
                text = CSTRING(HUD_StopAnyKey);
            };
            class Icon {
                idc = IDC_INDICATOR_ICON;
                type = 0;
                style = 2096;
                x = 0;
                y = 0.8;
                w = 1;
                h = 0.05;
                font = "RobotoCondensed";
                sizeEx = 0.004;
                colorBackground[] = {0,0,0,0};
                colorText[] = {1,1,1,1};
                deletable = 0;
                text = QPATHTOF(running\run_01.paa);
            };
        };
    };
};
