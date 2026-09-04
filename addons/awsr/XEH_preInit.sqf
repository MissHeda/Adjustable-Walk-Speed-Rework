#include "script_component.hpp"

ADDON = false;

#include "XEH_PREP.hpp"

#define CBA_SETTINGS_AWSR "Adjustable Walking Speed - Rework"
#define CBA_SETTINGS_AWSR_GUI "Adjustable Walking Speed - Rework IGUI"

// Resolved whitelists. The settings themselves stay the strings the player typed;
// awsr_awsr_fnc_rebuildAnimations turns them into these, and drops the lookup cache with it.
GVAR(animations_Walk) = [];
GVAR(animations_Tactical) = [];
GVAR(animations_Custom) = [];
GVAR(patterns_Walk) = [];
GVAR(patterns_Tactical) = [];
GVAR(patterns_Custom) = [];
GVAR(animationTypeCache) = createHashMap;
GVAR(aceExclusions) = [];

// One hide token per display, so the newest change to a group cancels the hide that group's
// previous change queued - and only that group's.
GVAR(displayTokens) = createHashMap;

// Autorun run state. Set up here so nothing ever reads one of these before the first
// activation - an undefined variable in a display event handler silently kills the handler.
GVAR(autorun_active) = false;
GVAR(autorun_tier) = AUTORUN_OFF;
GVAR(autorun_stance) = "Stand";
GVAR(autorun_animation) = "";
GVAR(autorun_updatingStance) = false;
GVAR(autorun_animDoneEH) = -1;
GVAR(autorun_pfh) = -1;
GVAR(autorun_iconFrame) = 1;
GVAR(autorun_iconTime) = 0;
GVAR(autorun_nameCache) = createHashMap;
GVAR(autorun_checkedOverride) = "";

// Displays a run keeps going under. 12 is the map; add your own display IDs from a mission or
// another mod if a run should survive them being open.
GVAR(autorun_displayAllow) = [12];

// Whitelist and blacklist settings all go through the same rebuild.
#define REBUILD_ANIMATIONS {call FUNC(rebuildAnimations)}

// The enable switches decide which group owns an animation, so the cache goes with them.
#define DROP_ANIMATION_CACHE {GVAR(animationTypeCache) = createHashMap}

// ------------------------------------------------------------------------------------------------------------------------ GENERAL

// Enable Adjustable Walking Speed - Rework
[
    QGVAR(Enable),
    "CHECKBOX",
    [LLSTRING(SETTING_Enable),LLSTRING(SETTING_Enable_DESC)],
    [CBA_SETTINGS_AWSR, LSTRING(SETTING_SubCategory_General)],
    [true],
    0,
    {
        // Switching the system off has to give the unit its speed back right away, not at the
        // next animation change.
        if (hasInterface && {!isNull player}) then {
            [player, animationState player] call FUNC(handleAnimation);
        };
    }
] call CBA_Settings_fnc_init;

// Effect sound detection
[
    QGVAR(adjustAudioDetection),
    "CHECKBOX",
    [LLSTRING(SETTING_adjustAudioDetection),LLSTRING(SETTING_adjustAudioDetection_DESC)],
    [CBA_SETTINGS_AWSR, LSTRING(SETTING_SubCategory_General)],
    [true],
    1,
    {
        if (hasInterface && {!isNull player}) then {
            [player, animationState player] call FUNC(handleAnimation);
        };
    }
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

// Put our speed back when another mod or mission overwrites it
[
    QGVAR(reapplySpeed),
    "CHECKBOX",
    [LLSTRING(SETTING_reapplySpeed),LLSTRING(SETTING_reapplySpeed_DESC)],
    [CBA_SETTINGS_AWSR, LSTRING(SETTING_SubCategory_General)],
    [true],
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
    0,
    DROP_ANIMATION_CACHE
] call CBA_Settings_fnc_init;

// Include no raised animations
[
    QGVAR(includeNonRaisedAnimations_Walk),
    "CHECKBOX",
    [LLSTRING(SETTING_includeNonRaisedAnimations),LLSTRING(SETTING_includeNonRaisedAnimations_DESC)],
    [CBA_SETTINGS_AWSR, LSTRING(SETTING_SubCategory_Walk)],
    [true],
    1,
    REBUILD_ANIMATIONS
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
    REBUILD_ANIMATIONS
] call CBA_Settings_fnc_init;

// Custom animation blacklist (walk)
[
    QGVAR(notAllowedAnimationArray_Walk),
    "EDITBOX",
    [LLSTRING(SETTING_notAllowedAnimationArray),LLSTRING(SETTING_notAllowedAnimationArray_DESC)],
    [CBA_SETTINGS_AWSR, LSTRING(SETTING_SubCategory_Walk)],
    "",
    1,
    REBUILD_ANIMATIONS
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
    [[ARR_4(DISPLAY_NONE,DISPLAY_HINT,DISPLAY_SYSTEMCHAT,DISPLAY_IGUI)], [ARR_4(LLSTRING(SETTING_None),LLSTRING(SETTING_Hint),LLSTRING(SETTING_Systemchat),LLSTRING(SETTING_Custom))], 3],
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
    0
] call CBA_Settings_fnc_init;

// IGUI text color limit reached (walk)
[
    QGVAR(IGUI_textColorLimitReached_Walk),
    "COLOR",
    [LLSTRING(SETTING_IGUI_textColorLimitReached),LLSTRING(SETTING_IGUI_textColorLimitReached_DESC)],
    [CBA_SETTINGS_AWSR_GUI, LSTRING(SETTING_SubCategory_Walk_IGUI)],
    [1,0,0],
    0
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

// IGUI display duration (walk)
[
    QGVAR(IGUI_displayDuration_Walk),
    "SLIDER",
    [LLSTRING(SETTING_IGUI_displayDuration), LLSTRING(SETTING_IGUI_displayDuration_DESC)],
    [CBA_SETTINGS_AWSR_GUI, LSTRING(SETTING_SubCategory_Walk_IGUI)],
    [0, 30, 0, 0],
    0
] call CBA_Settings_fnc_init;

// IGUI hide once the speed is back at default (walk)
[
    QGVAR(IGUI_hideAtDefault_Walk),
    "CHECKBOX",
    [LLSTRING(SETTING_IGUI_hideAtDefault), LLSTRING(SETTING_IGUI_hideAtDefault_DESC)],
    [CBA_SETTINGS_AWSR_GUI, LSTRING(SETTING_SubCategory_Walk_IGUI)],
    [true],
    0
] call CBA_Settings_fnc_init;

// ------------------------------------------------------------------------------------------------------------------------ TACTICAL

// Enable speed adjustments (tactical)
[
    QGVAR(Enable_Tactical),
    "CHECKBOX",
    [LLSTRING(SETTING_Enable_Tactical),LLSTRING(SETTING_Enable_Tactical_DESC)],
    [CBA_SETTINGS_AWSR, LSTRING(SETTING_SubCategory_Tactical)],
    [true],
    0,
    DROP_ANIMATION_CACHE
] call CBA_Settings_fnc_init;

// Include no raised animations
[
    QGVAR(includeNonRaisedAnimations_Tactical),
    "CHECKBOX",
    [LLSTRING(SETTING_includeNonRaisedAnimations),LLSTRING(SETTING_includeNonRaisedAnimations_DESC)],
    [CBA_SETTINGS_AWSR, LSTRING(SETTING_SubCategory_Tactical)],
    [true],
    1,
    REBUILD_ANIMATIONS
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
    REBUILD_ANIMATIONS
] call CBA_Settings_fnc_init;

// Custom animation blacklist (tactical)
[
    QGVAR(notAllowedAnimationArray_Tactical),
    "EDITBOX",
    [LLSTRING(SETTING_notAllowedAnimationArray),LLSTRING(SETTING_notAllowedAnimationArray_DESC)],
    [CBA_SETTINGS_AWSR, LSTRING(SETTING_SubCategory_Tactical)],
    "",
    1,
    REBUILD_ANIMATIONS
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
    [[ARR_4(DISPLAY_NONE,DISPLAY_HINT,DISPLAY_SYSTEMCHAT,DISPLAY_IGUI)], [ARR_4(LLSTRING(SETTING_None),LLSTRING(SETTING_Hint),LLSTRING(SETTING_Systemchat),LLSTRING(SETTING_Custom))], 3],
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
    0
] call CBA_Settings_fnc_init;

// IGUI text color limit reached (tactical)
[
    QGVAR(IGUI_textColorLimitReached_Tactical),
    "COLOR",
    [LLSTRING(SETTING_IGUI_textColorLimitReached),LLSTRING(SETTING_IGUI_textColorLimitReached_DESC)],
    [CBA_SETTINGS_AWSR_GUI, LSTRING(SETTING_SubCategory_Tactical_IGUI)],
    [1,0,0],
    0
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

// IGUI display duration (tactical)
[
    QGVAR(IGUI_displayDuration_Tactical),
    "SLIDER",
    [LLSTRING(SETTING_IGUI_displayDuration), LLSTRING(SETTING_IGUI_displayDuration_DESC)],
    [CBA_SETTINGS_AWSR_GUI, LSTRING(SETTING_SubCategory_Tactical_IGUI)],
    [0, 30, 0, 0],
    0
] call CBA_Settings_fnc_init;

// IGUI hide once the speed is back at default (tactical)
[
    QGVAR(IGUI_hideAtDefault_Tactical),
    "CHECKBOX",
    [LLSTRING(SETTING_IGUI_hideAtDefault), LLSTRING(SETTING_IGUI_hideAtDefault_DESC)],
    [CBA_SETTINGS_AWSR_GUI, LSTRING(SETTING_SubCategory_Tactical_IGUI)],
    [true],
    0
] call CBA_Settings_fnc_init;

// ------------------------------------------------------------------------------------------------------------------------ CUSTOM

// Enable speed adjustments (custom)
[
    QGVAR(Enable_Custom),
    "CHECKBOX",
    [LLSTRING(SETTING_Enable_Custom),LLSTRING(SETTING_Enable_Custom_DESC)],
    [CBA_SETTINGS_AWSR, LSTRING(SETTING_SubCategory_Custom)],
    [false],
    0,
    DROP_ANIMATION_CACHE
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
    REBUILD_ANIMATIONS
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
    [[ARR_4(DISPLAY_NONE,DISPLAY_HINT,DISPLAY_SYSTEMCHAT,DISPLAY_IGUI)], [ARR_4(LLSTRING(SETTING_None),LLSTRING(SETTING_Hint),LLSTRING(SETTING_Systemchat),LLSTRING(SETTING_Custom))], 3],
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
    0
] call CBA_Settings_fnc_init;

// IGUI text color limit reached (custom)
[
    QGVAR(IGUI_textColorLimitReached_Custom),
    "COLOR",
    [LLSTRING(SETTING_IGUI_textColorLimitReached),LLSTRING(SETTING_IGUI_textColorLimitReached_DESC)],
    [CBA_SETTINGS_AWSR_GUI, LSTRING(SETTING_SubCategory_Custom_IGUI)],
    [1,0,0],
    0
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
    [LLSTRING(SETTING_IGUI_textSize), LLSTRING(SETTING_IGUI_textSize_DESC)],
    [CBA_SETTINGS_AWSR_GUI, LSTRING(SETTING_SubCategory_Custom_IGUI)],
    [0.1, 3, 1, 2],
    0,
    {
        SETMVAR(GVAR(IGUI_textSize_Custom),[ARR_2(GVAR(IGUI_textSize_Custom),2)] call BIS_fnc_cutDecimals);
    }
] call CBA_Settings_fnc_init;

// IGUI display duration (custom)
[
    QGVAR(IGUI_displayDuration_Custom),
    "SLIDER",
    [LLSTRING(SETTING_IGUI_displayDuration), LLSTRING(SETTING_IGUI_displayDuration_DESC)],
    [CBA_SETTINGS_AWSR_GUI, LSTRING(SETTING_SubCategory_Custom_IGUI)],
    [0, 30, 0, 0],
    0
] call CBA_Settings_fnc_init;

// IGUI hide once the speed is back at default (custom)
[
    QGVAR(IGUI_hideAtDefault_Custom),
    "CHECKBOX",
    [LLSTRING(SETTING_IGUI_hideAtDefault), LLSTRING(SETTING_IGUI_hideAtDefault_DESC)],
    [CBA_SETTINGS_AWSR_GUI, LSTRING(SETTING_SubCategory_Custom_IGUI)],
    [true],
    0
] call CBA_Settings_fnc_init;

// ------------------------------------------------------------------------------------------------------------------------ AUTORUN

// Enable autorun
[
    QGVAR(autorun_enable),
    "CHECKBOX",
    [LLSTRING(SETTING_autorun_enable),LLSTRING(SETTING_autorun_enable_DESC)],
    [CBA_SETTINGS_AWSR, LSTRING(SETTING_SubCategory_Autorun)],
    [true],
    0,
    {
        if (!GVAR(autorun_enable) && {GVAR(autorun_active)}) then {
            0 spawn FUNC(autorunStop);
        };
    }
] call CBA_Settings_fnc_init;


// Animation this pace loops instead of the one worked out for the situation
[
    QGVAR(autorun_animation_Walk),
    "EDITBOX",
    [LLSTRING(SETTING_autorun_animation_Walk),LLSTRING(SETTING_autorun_animation_DESC)],
    [CBA_SETTINGS_AWSR, LSTRING(SETTING_SubCategory_Autorun)],
    "AmovPercMwlkSlowWrflDf_ver2",
    1
] call CBA_Settings_fnc_init;

// Animation this pace loops instead of the one worked out for the situation
[
    QGVAR(autorun_animation_Jog),
    "EDITBOX",
    [LLSTRING(SETTING_autorun_animation_Jog),LLSTRING(SETTING_autorun_animation_DESC)],
    [CBA_SETTINGS_AWSR, LSTRING(SETTING_SubCategory_Autorun)],
    "AmovPercMrunSrasWrflDf",
    1
] call CBA_Settings_fnc_init;

// Animation this pace loops instead of the one worked out for the situation
[
    QGVAR(autorun_animation_Run),
    "EDITBOX",
    [LLSTRING(SETTING_autorun_animation_Run),LLSTRING(SETTING_autorun_animation_DESC)],
    [CBA_SETTINGS_AWSR, LSTRING(SETTING_SubCategory_Autorun)],
    "AmovPercMevaSrasWrflDf",
    1
] call CBA_Settings_fnc_init;

// Animation this pace loops with a handgun in hand
[
    QGVAR(autorun_animation_WalkPistol),
    "EDITBOX",
    [LLSTRING(SETTING_autorun_animation_WalkPistol),LLSTRING(SETTING_autorun_animation_DESC)],
    [CBA_SETTINGS_AWSR, LSTRING(SETTING_SubCategory_Autorun)],
    "AmovPercMrunSlowWpstDf",
    1
] call CBA_Settings_fnc_init;

// Animation this pace loops with a handgun in hand
[
    QGVAR(autorun_animation_JogPistol),
    "EDITBOX",
    [LLSTRING(SETTING_autorun_animation_JogPistol),LLSTRING(SETTING_autorun_animation_DESC)],
    [CBA_SETTINGS_AWSR, LSTRING(SETTING_SubCategory_Autorun)],
    "AmovPercMrunSrasWpstDf",
    1
] call CBA_Settings_fnc_init;

// Animation this pace loops with a handgun in hand
[
    QGVAR(autorun_animation_RunPistol),
    "EDITBOX",
    [LLSTRING(SETTING_autorun_animation_RunPistol),LLSTRING(SETTING_autorun_animation_DESC)],
    [CBA_SETTINGS_AWSR, LSTRING(SETTING_SubCategory_Autorun)],
    "AmovPercMevaSrasWpstDf",
    1
] call CBA_Settings_fnc_init;

// ------------------------------------------------------------------------------------------------------------------------ AUTORUN IGUI

// Show the autorun indicator
[
    QGVAR(IGUI_showAutorun),
    "CHECKBOX",
    [LLSTRING(SETTING_IGUI_showAutorun),LLSTRING(SETTING_IGUI_showAutorun_DESC)],
    [CBA_SETTINGS_AWSR_GUI, LSTRING(SETTING_SubCategory_Autorun_IGUI)],
    [true],
    0,
    {
        if (hasInterface) then {call FUNC(autorunIndicator)};
    }
] call CBA_Settings_fnc_init;

// IGUI image color (autorun)
[
    QGVAR(IGUI_imageColor_Autorun),
    "COLOR",
    [LLSTRING(SETTING_IGUI_imageColor),LLSTRING(SETTING_IGUI_imageColor_DESC)],
    [CBA_SETTINGS_AWSR_GUI, LSTRING(SETTING_SubCategory_Autorun_IGUI)],
    [1,1,1,1],
    0
] call CBA_Settings_fnc_init;

// IGUI text color (autorun)
[
    QGVAR(IGUI_textColor_Autorun),
    "COLOR",
    [LLSTRING(SETTING_IGUI_textColor),LLSTRING(SETTING_IGUI_textColor_DESC)],
    [CBA_SETTINGS_AWSR_GUI, LSTRING(SETTING_SubCategory_Autorun_IGUI)],
    [1,1,1],
    0
] call CBA_Settings_fnc_init;

// IGUI Text Size (autorun)
[
    QGVAR(IGUI_textSize_Autorun),
    "SLIDER",
    [LLSTRING(SETTING_IGUI_textSize), LLSTRING(SETTING_IGUI_textSize_DESC)],
    [CBA_SETTINGS_AWSR_GUI, LSTRING(SETTING_SubCategory_Autorun_IGUI)],
    [0.1, 3, 1, 2],
    0,
    {
        SETMVAR(GVAR(IGUI_textSize_Autorun),[ARR_2(GVAR(IGUI_textSize_Autorun),2)] call BIS_fnc_cutDecimals);
    }
] call CBA_Settings_fnc_init;

ADDON = true;
