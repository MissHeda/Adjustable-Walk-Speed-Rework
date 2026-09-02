#include "script_component.hpp"

ADDON = false;

#include "XEH_PREP.hpp"

#define CBA_SETTINGS_AWSR "Adjustable Walking Speed - Rework"
#define CBA_SETTINGS_AWSR_GUI "Adjustable Walking Speed - Rework IGUI"

// Init toHex (copied from ACE3)
GVAR(hexArray) = [
"00","01","02","03","04","05","06","07","08","09","0A","0B","0C","0D","0E","0F",
"10","11","12","13","14","15","16","17","18","19","1A","1B","1C","1D","1E","1F",
"20","21","22","23","24","25","26","27","28","29","2A","2B","2C","2D","2E","2F",
"30","31","32","33","34","35","36","37","38","39","3A","3B","3C","3D","3E","3F",
"40","41","42","43","44","45","46","47","48","49","4A","4B","4C","4D","4E","4F",
"50","51","52","53","54","55","56","57","58","59","5A","5B","5C","5D","5E","5F",
"60","61","62","63","64","65","66","67","68","69","6A","6B","6C","6D","6E","6F",
"70","71","72","73","74","75","76","77","78","79","7A","7B","7C","7D","7E","7F",
"80","81","82","83","84","85","86","87","88","89","8A","8B","8C","8D","8E","8F",
"90","91","92","93","94","95","96","97","98","99","9A","9B","9C","9D","9E","9F",
"A0","A1","A2","A3","A4","A5","A6","A7","A8","A9","AA","AB","AC","AD","AE","AF",
"B0","B1","B2","B3","B4","B5","B6","B7","B8","B9","BA","BB","BC","BD","BE","BF",
"C0","C1","C2","C3","C4","C5","C6","C7","C8","C9","CA","CB","CC","CD","CE","CF",
"D0","D1","D2","D3","D4","D5","D6","D7","D8","D9","DA","DB","DC","DD","DE","DF",
"E0","E1","E2","E3","E4","E5","E6","E7","E8","E9","EA","EB","EC","ED","EE","EF",
"F0","F1","F2","F3","F4","F5","F6","F7","F8","F9","FA","FB","FC","FD","FE","FF"
];

// ------------------------------------------------------------------------------------------------------------------------ GENERAL

// Enable Adjustable Walking Speed - Rework
[
    QGVAR(Enable),
    "CHECKBOX",
    [LLSTRING(SETTING_Enable),LLSTRING(SETTING_Enable_DESC)],
    [CBA_SETTINGS_AWSR, LSTRING(SETTING_SubCategory_General)],
    [true],
    0
] call CBA_Settings_fnc_init;

// Effect sound detection
[
    QGVAR(adjustAudioDetection),
    "CHECKBOX",
    [LLSTRING(SETTING_adjustAudioDetection),LLSTRING(SETTING_adjustAudioDetection_DESC)],
    [CBA_SETTINGS_AWSR, LSTRING(SETTING_SubCategory_General)],
    [true],
    1
] call CBA_Settings_fnc_init;

// Only allow speed change while doing a animation of the animation group
[
    QGVAR(onlyChangeSpeedWhileAnimationIsPlaying),
    "CHECKBOX",
    [LLSTRING(SETTING_onlyChangeSpeedWhileAnimationIsPlaying),LLSTRING(SETTING_onlyChangeSpeedWhileAnimationIsPlaying_DESC)],
    [CBA_SETTINGS_AWSR, LSTRING(SETTING_SubCategory_General)],
    [false],
    0
] call CBA_Settings_fnc_init;

// ------------------------------------------------------------------------------------------------------------------------ WALK

// Enable speed adjustments (walking)
[
    QGVAR(Enable_Walk),
    "CHECKBOX",
    [LLSTRING(SETTING_Enable_Walk),LLSTRING(SETTING_Enable_Walk_DESC)],
    [CBA_SETTINGS_AWSR, LSTRING(SETTING_SubCategory_Walk)],
    [true],
    0
] call CBA_Settings_fnc_init;

// Include no raised animations
[
    QGVAR(includeNonRaisedAnimations_Walk),
    "CHECKBOX",
    [LLSTRING(SETTING_includeNonRaisedAnimations),LLSTRING(SETTING_includeNonRaisedAnimations_DESC)],
    [CBA_SETTINGS_AWSR, LSTRING(SETTING_SubCategory_Walk)],
    [true],
    1,
    {
        if (GVAR(includeNonRaisedAnimations_Walk)) then {

            [{
                private _array = GETMVAR(GVAR(allowedAnimationArray_Walk),[]);
                typeName _array == "ARRAY";
            }, 
            {
                private _array = GETMVAR(GVAR(allowedAnimationArray_Walk),[]);
                _array = _array + ALL_MOVE_WALK_ANIMATIONS_ADDITIONAL; 

                {
                    _array set [_forEachIndex, toLower _x];
                } forEach _array;
                
                SETMVAR(GVAR(allowedAnimationArray_Walk),_array);

                // If ace is loaded make sure to not allow it to override walking speed animations
                if (isClass (configfile >> "CfgPatches" >> "ace_advanced_fatigue")) then {
                    {ACEGVAR(advanced_fatigue,setAnimExclusions) pushBackUnique _x} forEach _array;
                };
            },[_array]] call CBA_fnc_waitUntilAndExecute;
        };
    },
    true
] call CBA_Settings_fnc_init;

// If a value is > or < force walk (requires onlyChangeSpeedWhileAnimationIsPlaying to be off)
[
    QGVAR(forceWalkWhenValueIsNotDefault),
    "CHECKBOX",
    [LLSTRING(SETTING_forceWalkWhenValueIsNotDefault),LLSTRING(SETTING_forceWalkWhenValueIsNotDefault_DESC)],
    [CBA_SETTINGS_AWSR, LSTRING(SETTING_SubCategory_Walk)],
    [false],
    0
] call CBA_Settings_fnc_init;

// Min speed value (walk)
[
    QGVAR(minAdjustSpeed_Walk),
    "SLIDER",
    [LLSTRING(SETTING_minAdjustSpeed),LLSTRING(SETTING_minAdjustSpeed_DESC)],
    [CBA_SETTINGS_AWSR, LSTRING(SETTING_SubCategory_Walk)],
    [0.1, 1, 0.3, 2],
    1,
    {
        SETMVAR(GVAR(minAdjustSpeed_Walk),[ARR_2(GVAR(minAdjustSpeed_Walk),2)] call BIS_fnc_cutDecimals);
    }
] call CBA_Settings_fnc_init;

// Max speed value (walk)
[
    QGVAR(maxAdjustSpeed_Walk),
    "SLIDER",
    [LLSTRING(SETTING_maxAdjustSpeed),LLSTRING(SETTING_maxAdjustSpeed_DESC)],
    [CBA_SETTINGS_AWSR, LSTRING(SETTING_SubCategory_Walk)],
    [1, 2, 1.7, 2],
    1,
    {
        SETMVAR(GVAR(maxAdjustSpeed_Walk),[ARR_2(GVAR(maxAdjustSpeed_Walk),2)] call BIS_fnc_cutDecimals);
    }
] call CBA_Settings_fnc_init;

// Speed adjust coefficient (walk)
[
    QGVAR(speedAdjustCoefficient_Walk),
    "SLIDER",
    [LLSTRING(SETTING_speedAdjustCoefficient),LLSTRING(SETTING_speedAdjustCoefficient_DESC)],
    [CBA_SETTINGS_AWSR, LSTRING(SETTING_SubCategory_Walk)],
    [0.05, 1, 0.1, 2],
    0,
    {
        SETMVAR(GVAR(speedAdjustCoefficient_Walk),[ARR_2(GVAR(speedAdjustCoefficient_Walk),2)] call BIS_fnc_cutDecimals);
    }
] call CBA_Settings_fnc_init;

// Custom animation whitelist (walk)
[
    QGVAR(allowedAnimationArray_Walk),
    "EDITBOX",
    [LLSTRING(SETTING_allowedAnimationArray),LLSTRING(SETTING_allowedAnimationArray_DESC)],
    [CBA_SETTINGS_AWSR, LSTRING(SETTING_SubCategory_Walk)],
    "",
    1,
    {
        private _string = GETMVAR(GVAR(allowedAnimationArray_Walk),[]);
        private _array = _string call CBA_fnc_removeWhitespace;
        _array = [_array, ","] call CBA_fnc_split;
        _array = _array + ALL_ADJUST_WALK_ANIMATIONS + ALL_MOVE_WALK_ANIMATIONS;
        
        {
            _array set [_forEachIndex, toLower _x];
        } forEach _array;
        
        SETMVAR(GVAR(allowedAnimationArray_Walk),_array);

        // If ace is loaded make sure to not allow it to override walking speed animations
        if (isClass (configfile >> "CfgPatches" >> "ace_advanced_fatigue")) then {
            {ACEGVAR(advanced_fatigue,setAnimExclusions) pushBackUnique _x} forEach _array;
        };
    },
    true
] call CBA_Settings_fnc_init;

// Custom animation blacklist (walk)
[
    QGVAR(notAllowedAnimationArray_Walk),
    "EDITBOX",
    [LLSTRING(SETTING_notAllowedAnimationArray),LLSTRING(SETTING_notAllowedAnimationArray_DESC)],
    [CBA_SETTINGS_AWSR, LSTRING(SETTING_SubCategory_Walk)],
    "",
    1,
    {
        private _removeString = GETMVAR(GVAR(notAllowedAnimationArray_Walk),[]);
        private _removeArray = _removeString call CBA_fnc_removeWhitespace;
        _removeArray = [_removeArray, ","] call CBA_fnc_split;
        
        {
            _removeArray set [_forEachIndex, toLower _x];
        } forEach _removeArray;

        private _arrayToRemoveFrom = GETMVAR(GVAR(allowedAnimationArray_Walk),[]);
        private _updatedArray = _arrayToRemoveFrom - _removeArray;
        
        SETMVAR(GVAR(allowedAnimationArray_Walk),_updatedArray);
        SETMVAR(GVAR(notAllowedAnimationArray_Walk),_removeArray);
        
        // If ace is loaded make sure to remove it here as well
        if (isClass (configfile >> "CfgPatches" >> "ace_advanced_fatigue")) then {
            _arrayToRemoveFrom = ACEGVAR(advanced_fatigue,setAnimExclusions);
            _updatedArray = _arrayToRemoveFrom - _removeArray;
            SETMVAR(ACEGVAR(advanced_fatigue,setAnimExclusions),_updatedArray);
        };
    },
    true
] call CBA_Settings_fnc_init;

// ------------------------------------------------------------------------------------------------------------------------ WALK IGUI

// IGUI Show limit values in red (walk)
[
    QGVAR(allowIGUIRedLimitValue_Walk),
    "CHECKBOX",
    [LLSTRING(SETTING_allowIGUIRedLimitValue),LLSTRING(SETTING_allowIGUIRedLimitValue_DESC)],
    [CBA_SETTINGS_AWSR_GUI, LSTRING(SETTING_SubCategory_Walk_IGUI)],
    [true],
    0
] call CBA_Settings_fnc_init;

// IGUI Updated speed display type (walk)
[
    QGVAR(speedUpdatedDisplayType_Walk),
    "LIST",
    [LLSTRING(SETTING_speedUpdatedDisplayType), LLSTRING(SETTING_speedUpdatedDisplayType_DESC)],
    [CBA_SETTINGS_AWSR_GUI, LSTRING(SETTING_SubCategory_Walk_IGUI)],
    [[0, 1, 2, 3], [LLSTRING(SETTING_None), LLSTRING(SETTING_Hint), LLSTRING(SETTING_Systemchat), LLSTRING(SETTING_Custom)], 3],
    0
] call CBA_settings_fnc_init;

// IGUI image color (walk)
[
    QGVAR(IGUI_imageColor_Walk),
    "COLOR",
    [LLSTRING(SETTING_IGUI_imageColor),LLSTRING(SETTING_IGUI_imageColor_DESC)],
    [CBA_SETTINGS_AWSR_GUI, LSTRING(SETTING_SubCategory_Walk_IGUI)],
    [1,1,1,1],
    0
] call CBA_Settings_fnc_init;

// IGUI text color (walk)
[
    QGVAR(IGUI_textColor_Walk),
    "COLOR",
    [LLSTRING(SETTING_IGUI_textColor),LLSTRING(SETTING_IGUI_textColor_DESC)],
    [CBA_SETTINGS_AWSR_GUI, LSTRING(SETTING_SubCategory_Walk_IGUI)],
    [1,1,1],
    0,
    {
        private _array = GVAR(IGUI_textColor_Walk);
        private _return = "";
        private _hashtag = "";
        private _hexCode = "";
        private _count = 0;

        {
            _count = _count + 1;
            _x = _x * 255;
            _hexCode  = GVAR(hexArray) select (((round abs _x) max 0) min 255);
            if (_count == 3) then { _hashtag = "#"; };
            _return = _hashtag + _return + _hexCode; 
        } forEach _array; //Get correct Hex color code
        
        SETMVAR(GVAR(IGUI_textColor_Walk),_return)
    }
] call CBA_Settings_fnc_init;

// IGUI text color limit reached (walk)
[
    QGVAR(IGUI_textColorLimitReached_Walk),
    "COLOR",
    [LLSTRING(SETTING_IGUI_textColorLimitReached),LLSTRING(SETTING_IGUI_textColorLimitReached_DESC)],
    [CBA_SETTINGS_AWSR_GUI, LSTRING(SETTING_SubCategory_Walk_IGUI)],
    [1,0,0],
    0,
    {
        private _array = GVAR(IGUI_textColorLimitReached_Walk);
        private _return = "";
        private _hashtag = "";
        private _hexCode = "";
        private _count = 0;

        {
            _count = _count + 1;
            _x = _x * 255;
            _hexCode  = GVAR(hexArray) select (((round abs _x) max 0) min 255);
            if (_count == 3) then { _hashtag = "#"; };
            _return = _hashtag + _return + _hexCode; 
        } forEach _array; //Get correct Hex color code
        
        SETMVAR(GVAR(IGUI_textColorLimitReached_Walk),_return)
    }
] call CBA_Settings_fnc_init;

// Custom text (walk)
[
    QGVAR(IGUI_Text_Walk),
    "EDITBOX",
    [LLSTRING(SETTING_IGUI_Text),LLSTRING(SETTING_IGUI_Text_DESC)],
    [CBA_SETTINGS_AWSR_GUI, LSTRING(SETTING_SubCategory_Walk_IGUI)],
    "%1",
    0
] call CBA_Settings_fnc_init;

// IGUI Text Size (walk)
[
    QGVAR(IGUI_textSize_Walk),
    "SLIDER",
    [LLSTRING(SETTING_IGUI_textSize), LLSTRING(SETTING_IGUI_textSize_DESC)],
    [CBA_SETTINGS_AWSR_GUI, LSTRING(SETTING_SubCategory_Walk_IGUI)],
    [0.1, 3, 1, 2],
    0,
    {
        SETMVAR(GVAR(IGUI_textSize_Walk),[ARR_2(GVAR(IGUI_textSize_Walk),2)] call BIS_fnc_cutDecimals);
    }
] call CBA_Settings_fnc_init;

// ------------------------------------------------------------------------------------------------------------------------ TACTICAL

// Enable speed adjustments (tactical)
[
    QGVAR(Enable_Tactical),
    "CHECKBOX",
    [LLSTRING(SETTING_Enable_Tactical),LLSTRING(SETTING_Enable_Tactical_DESC)],
    [CBA_SETTINGS_AWSR, LSTRING(SETTING_SubCategory_Tactical)],
    [true],
    0
] call CBA_Settings_fnc_init;

// Include no raised animations
[
    QGVAR(includeNonRaisedAnimations_Tactical),
    "CHECKBOX",
    [LLSTRING(SETTING_includeNonRaisedAnimations),LLSTRING(SETTING_includeNonRaisedAnimations_DESC)],
    [CBA_SETTINGS_AWSR, LSTRING(SETTING_SubCategory_Tactical)],
    [true],
    1,
    {
        if (GVAR(includeNonRaisedAnimations_Tactical)) then {

            [{
                private _array = GETMVAR(GVAR(allowedAnimationArray_Tactical),[]);
                typeName _array == "ARRAY";
            }, 
            {
                private _array = GETMVAR(GVAR(allowedAnimationArray_Tactical),[]);
                _array = _array + ALL_MOVE_TACTICAL_ANIMATIONS_ADDITIONAL; 

                {
                    _array set [_forEachIndex, toLower _x];
                } forEach _array;
                
                SETMVAR(GVAR(allowedAnimationArray_Tactical),_array);

                // If ace is loaded make sure to not allow it to override walking speed animations
                if (isClass (configfile >> "CfgPatches" >> "ace_advanced_fatigue")) then {
                    {ACEGVAR(advanced_fatigue,setAnimExclusions) pushBackUnique _x} forEach _array;
                };
            },[]] call CBA_fnc_waitUntilAndExecute;
        };
    },
    true
] call CBA_Settings_fnc_init;

// Min speed value (tactical)
[
    QGVAR(minAdjustSpeed_Tactical),
    "SLIDER",
    [LLSTRING(SETTING_minAdjustSpeed),LLSTRING(SETTING_minAdjustSpeed_DESC)],
    [CBA_SETTINGS_AWSR, LSTRING(SETTING_SubCategory_Tactical)],
    [0.1, 1, 0.7, 2],
    1,
    {
        SETMVAR(GVAR(minAdjustSpeed_Tactical),[ARR_2(GVAR(minAdjustSpeed_Tactical),2)] call BIS_fnc_cutDecimals);
    }
] call CBA_Settings_fnc_init;

// Max speed value (tactical)
[
    QGVAR(maxAdjustSpeed_Tactical),
    "SLIDER",
    [LLSTRING(SETTING_maxAdjustSpeed),LLSTRING(SETTING_maxAdjustSpeed_DESC)],
    [CBA_SETTINGS_AWSR, LSTRING(SETTING_SubCategory_Tactical)],
    [1, 2, 1.3, 2],
    1,
    {
        SETMVAR(GVAR(maxAdjustSpeed_Tactical),[ARR_2(GVAR(maxAdjustSpeed_Tactical),2)] call BIS_fnc_cutDecimals);
    }
] call CBA_Settings_fnc_init;

// Speed adjust coefficient (tactical)
[
    QGVAR(speedAdjustCoefficient_Tactical),
    "SLIDER",
    [LLSTRING(SETTING_speedAdjustCoefficient),LLSTRING(SETTING_speedAdjustCoefficient_DESC)],
    [CBA_SETTINGS_AWSR, LSTRING(SETTING_SubCategory_Tactical)],
    [0.05, 1, 0.1, 2],
    0,
    {
        SETMVAR(GVAR(speedAdjustCoefficient_Tactical),[ARR_2(GVAR(speedAdjustCoefficient_Tactical),2)] call BIS_fnc_cutDecimals);
    }
] call CBA_Settings_fnc_init;

// Custom animation whitelist (tactical)
[
    QGVAR(allowedAnimationArray_Tactical),
    "EDITBOX",
    [LLSTRING(SETTING_allowedAnimationArray),LLSTRING(SETTING_allowedAnimationArray_DESC)],
    [CBA_SETTINGS_AWSR, LSTRING(SETTING_SubCategory_Tactical)],
    "",
    1,
    {
        private _string = GETMVAR(GVAR(allowedAnimationArray_Tactical),[]);
        private _array = _string call CBA_fnc_removeWhitespace;
        _array = [_array, ","] call CBA_fnc_split;
        _array = _array + ALL_MOVE_TACTICAL_ANIMATIONS + ALL_ADJUST_TACTICAL_ANIMATIONS;
        
        {
            _array set [_forEachIndex, toLower _x];
        } forEach _array;
        
        SETMVAR(GVAR(allowedAnimationArray_Tactical),_array);

        // If ace is loaded make sure to not allow it to override walking speed animations
        if (isClass (configfile >> "CfgPatches" >> "ace_advanced_fatigue")) then {
            {ACEGVAR(advanced_fatigue,setAnimExclusions) pushBackUnique _x} forEach _array;
        };
    },
    true
] call CBA_Settings_fnc_init;

// Custom animation blacklist (tactical)
[
    QGVAR(notAllowedAnimationArray_Tactical),
    "EDITBOX",
    [LLSTRING(SETTING_notAllowedAnimationArray),LLSTRING(SETTING_notAllowedAnimationArray_DESC)],
    [CBA_SETTINGS_AWSR, LSTRING(SETTING_SubCategory_Tactical)],
    "",
    1,
    {
        private _removeString = GETMVAR(GVAR(notAllowedAnimationArray_Tactical),[]);
        private _removeArray = _removeString call CBA_fnc_removeWhitespace;
        _removeArray = [_removeArray, ","] call CBA_fnc_split;
        
        {
            _removeArray set [_forEachIndex, toLower _x];
        } forEach _removeArray;

        private _arrayToRemoveFrom = GETMVAR(GVAR(allowedAnimationArray_Tactical),[]);
        private _updatedArray = _arrayToRemoveFrom - _removeArray;
        
        SETMVAR(GVAR(allowedAnimationArray_Tactical),_updatedArray);
        SETMVAR(GVAR(notAllowedAnimationArray_Tactical),_removeArray);
        
        // If ace is loaded make sure to remove it here as well
        if (isClass (configfile >> "CfgPatches" >> "ace_advanced_fatigue")) then {
            _arrayToRemoveFrom = ACEGVAR(advanced_fatigue,setAnimExclusions);
            _updatedArray = _arrayToRemoveFrom - _removeArray;
            SETMVAR(ACEGVAR(advanced_fatigue,setAnimExclusions),_updatedArray);
        };
    },
    true
] call CBA_Settings_fnc_init;

// ------------------------------------------------------------------------------------------------------------------------ TACTICAL IGUI

// IGUI Show limit values in red (tactical)
[
    QGVAR(allowIGUIRedLimitValue_Tactical),
    "CHECKBOX",
    [LLSTRING(SETTING_allowIGUIRedLimitValue),LLSTRING(SETTING_allowIGUIRedLimitValue_DESC)],
    [CBA_SETTINGS_AWSR_GUI, LSTRING(SETTING_SubCategory_Tactical_IGUI)],
    [true],
    0
] call CBA_Settings_fnc_init;

// IGUI Updated speed display type (tactical)
[
    QGVAR(speedUpdatedDisplayType_Tactical),
    "LIST",
    [LLSTRING(SETTING_speedUpdatedDisplayType), LLSTRING(SETTING_speedUpdatedDisplayType_DESC)],
    [CBA_SETTINGS_AWSR_GUI, LSTRING(SETTING_SubCategory_Tactical_IGUI)],
    [[0, 1, 2, 3], [LLSTRING(SETTING_None), LLSTRING(SETTING_Hint), LLSTRING(SETTING_Systemchat), LLSTRING(SETTING_Custom)], 3],
    0
] call CBA_settings_fnc_init;

// IGUI image color (tactical)
[
    QGVAR(IGUI_imageColor_Tactical),
    "COLOR",
    [LLSTRING(SETTING_IGUI_imageColor),LLSTRING(SETTING_IGUI_imageColor_DESC)],
    [CBA_SETTINGS_AWSR_GUI, LSTRING(SETTING_SubCategory_Tactical_IGUI)],
    [1,1,1,1],
    0
] call CBA_Settings_fnc_init;

// IGUI text color (tactical)
[
    QGVAR(IGUI_textColor_Tactical),
    "COLOR",
    [LLSTRING(SETTING_IGUI_textColor),LLSTRING(SETTING_IGUI_textColor_DESC)],
    [CBA_SETTINGS_AWSR_GUI, LSTRING(SETTING_SubCategory_Tactical_IGUI)],
    [1,1,1],
    0,
    {
        private _array = GVAR(IGUI_textColor_Tactical);
        private _return = "";
        private _hashtag = "";
        private _hexCode = "";
        private _count = 0;

        {
            _count = _count + 1;
            _x = _x * 255;
            _hexCode  = GVAR(hexArray) select (((round abs _x) max 0) min 255);
            if (_count == 3) then { _hashtag = "#"; };
            _return = _hashtag + _return + _hexCode; 
        } forEach _array; //Get correct Hex color code
        
        SETMVAR(GVAR(IGUI_textColor_Tactical),_return)
    }
] call CBA_Settings_fnc_init;

// IGUI text color limit reached (tactical)
[
    QGVAR(IGUI_textColorLimitReached_Tactical),
    "COLOR",
    [LLSTRING(SETTING_IGUI_textColorLimitReached),LLSTRING(SETTING_IGUI_textColorLimitReached_DESC)],
    [CBA_SETTINGS_AWSR_GUI, LSTRING(SETTING_SubCategory_Tactical_IGUI)],
    [1,0,0],
    0,
    {
        private _array = GVAR(IGUI_textColorLimitReached_Tactical);
        private _return = "";
        private _hashtag = "";
        private _hexCode = "";
        private _count = 0;

        {
            _count = _count + 1;
            _x = _x * 255;
            _hexCode  = GVAR(hexArray) select (((round abs _x) max 0) min 255);
            if (_count == 3) then { _hashtag = "#"; };
            _return = _hashtag + _return + _hexCode; 
        } forEach _array; //Get correct Hex color code
        
        SETMVAR(GVAR(IGUI_textColorLimitReached_Tactical),_return)
    }
] call CBA_Settings_fnc_init;

// Custom text (tactical)
[
    QGVAR(IGUI_Text_Tactical),
    "EDITBOX",
    [LLSTRING(SETTING_IGUI_Text),LLSTRING(SETTING_IGUI_Text_DESC)],
    [CBA_SETTINGS_AWSR_GUI, LSTRING(SETTING_SubCategory_Tactical_IGUI)],
    "%1",
    0
] call CBA_Settings_fnc_init;

// IGUI Text Size (tactical)
[
    QGVAR(IGUI_textSize_Tactical),
    "SLIDER",
    [LLSTRING(SETTING_IGUI_textSize),LLSTRING(SETTING_IGUI_textSize_DESC)],
    [CBA_SETTINGS_AWSR_GUI, LSTRING(SETTING_SubCategory_Tactical_IGUI)],
    [0.1, 3, 1, 2],
    0,
    {
        SETMVAR(GVAR(IGUI_textSize_Tactical),[ARR_2(GVAR(IGUI_textSize_Tactical),2)] call BIS_fnc_cutDecimals);
    }
] call CBA_Settings_fnc_init;

// ------------------------------------------------------------------------------------------------------------------------ CUSTOM

// Enable speed adjustments (custom)
[
    QGVAR(Enable_Custom),
    "CHECKBOX",
    [LLSTRING(SETTING_Enable_Custom),LLSTRING(SETTING_Enable_Custom_DESC)],
    [CBA_SETTINGS_AWSR, LSTRING(SETTING_SubCategory_Custom)],
    [false],
    0
] call CBA_Settings_fnc_init;

// Min speed value (custom)
[
    QGVAR(minAdjustSpeed_Custom),
    "SLIDER",
    [LLSTRING(SETTING_minAdjustSpeed),LLSTRING(SETTING_minAdjustSpeed_DESC)],
    [CBA_SETTINGS_AWSR, LSTRING(SETTING_SubCategory_Custom)],
    [0.1, 1, 0.5, 2],
    1,
    {
        SETMVAR(GVAR(minAdjustSpeed_Custom),[ARR_2(GVAR(minAdjustSpeed_Custom),2)] call BIS_fnc_cutDecimals);
    }
] call CBA_Settings_fnc_init;

// Max speed value (custom)
[
    QGVAR(maxAdjustSpeed_Custom),
    "SLIDER",
    [LLSTRING(SETTING_maxAdjustSpeed),LLSTRING(SETTING_maxAdjustSpeed_DESC)],
    [CBA_SETTINGS_AWSR, LSTRING(SETTING_SubCategory_Custom)],
    [1, 3, 1.5, 2],
    1,
    {
        SETMVAR(GVAR(maxAdjustSpeed_Custom),[ARR_2(GVAR(maxAdjustSpeed_Custom),2)] call BIS_fnc_cutDecimals);
    }
] call CBA_Settings_fnc_init;

// Speed adjust coefficient (custom)
[
    QGVAR(speedAdjustCoefficient_Custom),
    "SLIDER",
    [LLSTRING(SETTING_speedAdjustCoefficient),LLSTRING(SETTING_speedAdjustCoefficient_DESC)],
    [CBA_SETTINGS_AWSR, LSTRING(SETTING_SubCategory_Custom)],
    [0.05, 1, 0.1, 2],
    0,
    {
        SETMVAR(GVAR(speedAdjustCoefficient_Custom),[ARR_2(GVAR(speedAdjustCoefficient_Custom),2)] call BIS_fnc_cutDecimals);
    }
] call CBA_Settings_fnc_init;

// Custom animation whitelist (custom)
[
    QGVAR(allowedAnimationArray_Custom),
    "EDITBOX",
    [LLSTRING(SETTING_allowedAnimationArray),LLSTRING(SETTING_allowedAnimationArray_DESC)],
    [CBA_SETTINGS_AWSR, LSTRING(SETTING_SubCategory_Custom)],
    "",
    1,
    {
        private _string = GETMVAR(GVAR(allowedAnimationArray_Custom),[]);
        private _array = _string call CBA_fnc_removeWhitespace;
        _array = [_array, ","] call CBA_fnc_split;
        
        {
            _array set [_forEachIndex, toLower _x];
        } forEach _array;
        
        SETMVAR(GVAR(allowedAnimationArray_Custom),_array);

        // If ace is loaded make sure to not allow it to override walking speed animations
        if (isClass (configfile >> "CfgPatches" >> "ace_advanced_fatigue")) then {
            {ACEGVAR(advanced_fatigue,setAnimExclusions) pushBackUnique _x} forEach _array;
        };
    },
    true
] call CBA_Settings_fnc_init;

// ------------------------------------------------------------------------------------------------------------------------ CUSTOM IGUI

// IGUI Show limit values in red (custom)
[
    QGVAR(allowIGUIRedLimitValue_Custom),
    "CHECKBOX",
    [LLSTRING(SETTING_allowIGUIRedLimitValue),LLSTRING(SETTING_allowIGUIRedLimitValue_DESC)],
    [CBA_SETTINGS_AWSR_GUI, LSTRING(SETTING_SubCategory_Custom_IGUI)],
    [true],
    0
] call CBA_Settings_fnc_init;

// IGUI Updated speed display type (custom)
[
    QGVAR(speedUpdatedDisplayType_Custom),
    "LIST",
    [LLSTRING(SETTING_speedUpdatedDisplayType), LLSTRING(SETTING_speedUpdatedDisplayType_DESC)],
    [CBA_SETTINGS_AWSR_GUI, LSTRING(SETTING_SubCategory_Custom_IGUI)],
    [[0, 1, 2, 3], [LLSTRING(SETTING_None), LLSTRING(SETTING_Hint), LLSTRING(SETTING_Systemchat), LLSTRING(SETTING_Custom)], 3],
    0
] call CBA_settings_fnc_init;

// IGUI image color (custom)
[
    QGVAR(IGUI_imageColor_Custom),
    "COLOR",
    [LLSTRING(SETTING_IGUI_imageColor),LLSTRING(SETTING_IGUI_imageColor_DESC)],
    [CBA_SETTINGS_AWSR_GUI, LSTRING(SETTING_SubCategory_Custom_IGUI)],
    [1,1,1,1],
    0
] call CBA_Settings_fnc_init;

// IGUI text color (custom)
[
    QGVAR(IGUI_textColor_Custom),
    "COLOR",
    [LLSTRING(SETTING_IGUI_textColor),LLSTRING(SETTING_IGUI_textColor_DESC)],
    [CBA_SETTINGS_AWSR_GUI, LSTRING(SETTING_SubCategory_Custom_IGUI)],
    [1,1,1],
    0,
    {
        private _array = GVAR(IGUI_textColor_Custom);
        private _return = "";
        private _hashtag = "";
        private _hexCode = "";
        private _count = 0;

        {
            _count = _count + 1;
            _x = _x * 255;
            _hexCode  = GVAR(hexArray) select (((round abs _x) max 0) min 255);
            if (_count == 3) then { _hashtag = "#"; };
            _return = _hashtag + _return + _hexCode; 
        } forEach _array; //Get correct Hex color code
        
        SETMVAR(GVAR(IGUI_textColor_Custom),_return)
    }
] call CBA_Settings_fnc_init;

// IGUI text color limit reached (custom)
[
    QGVAR(IGUI_textColorLimitReached_Custom),
    "COLOR",
    [LLSTRING(SETTING_IGUI_textColorLimitReached),LLSTRING(SETTING_IGUI_textColorLimitReached_DESC)],
    [CBA_SETTINGS_AWSR_GUI, LSTRING(SETTING_SubCategory_Custom_IGUI)],
    [1,0,0],
    0,
    {
        private _array = GVAR(IGUI_textColorLimitReached_Custom);
        private _return = "";
        private _hashtag = "";
        private _hexCode = "";
        private _count = 0;

        {
            _count = _count + 1;
            _x = _x * 255;
            _hexCode  = GVAR(hexArray) select (((round abs _x) max 0) min 255);
            if (_count == 3) then { _hashtag = "#"; };
            _return = _hashtag + _return + _hexCode; 
        } forEach _array; //Get correct Hex color code
        
        SETMVAR(GVAR(IGUI_textColorLimitReached_Custom),_return)
    }
] call CBA_Settings_fnc_init;

// Custom text (custom)
[
    QGVAR(IGUI_Text_Custom),
    "EDITBOX",
    [LLSTRING(SETTING_IGUI_Text),LLSTRING(SETTING_IGUI_Text_DESC)],
    [CBA_SETTINGS_AWSR_GUI, LSTRING(SETTING_SubCategory_Custom_IGUI)],
    "%1",
    0
] call CBA_Settings_fnc_init;

// IGUI Text Size (custom)
[
    QGVAR(IGUI_textSize_Custom),
    "SLIDER",
    [LLSTRING(SETTING_IGUI_textSize),LLSTRING(SETTING_IGUI_textSize_DESC)],
    [CBA_SETTINGS_AWSR_GUI, LSTRING(SETTING_SubCategory_Custom_IGUI)],
    [0.1, 3, 1, 2],
    0,
    {
        SETMVAR(GVAR(IGUI_textSize_Custom),[ARR_2(GVAR(IGUI_textSize_Custom),2)] call BIS_fnc_cutDecimals);
    }
] call CBA_Settings_fnc_init;

ADDON = true;
