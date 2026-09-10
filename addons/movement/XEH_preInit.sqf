#include "script_component.hpp"

ADDON = false;

#include "XEH_PREP.hpp"

// Three categories, split by feature rather than by how a setting happens to be drawn. The
// shared prefix keeps them next to each other: CBA sorts categories alphabetically by their
// display text. Only the variable name decides where a value is stored, so re-categorising
// never costs a player their settings - renaming would.
#define CBA_SETTINGS_AWSR_AUTORUN "AWSR - Autorun"
#define CBA_SETTINGS_AWSR "AWSR - Adjustable Walk Speed"
#define CBA_SETTINGS_AWSR_GUI "AWSR - Adjustable Walk Speed"
#define CBA_SETTINGS_AWSR_ANIM "AWSR - Animation Adjustment"

// Resolved whitelists. The settings themselves stay the strings the player typed;
// awsr_movement_fnc_rebuildAnimations turns them into these, and drops the lookup cache with it.
GVAR(animations_Walk) = [];
GVAR(animations_Tactical) = [];
GVAR(animations_Custom) = [];
GVAR(patterns_Walk) = [];
GVAR(patterns_Tactical) = [];
GVAR(patterns_Custom) = [];
GVAR(blocked_Walk) = [];
GVAR(blocked_Tactical) = [];
GVAR(blocked_Custom) = [];
GVAR(animationTypeCache) = createHashMap;
GVAR(debugAnimations) = [];
GVAR(debugLastSpeed) = -1;
GVAR(animationSpeeds) = createHashMap;
GVAR(animationSpeedPatterns) = [];
GVAR(animationSpeedCache) = createHashMap;

// One hide token per display, so the newest change to a group cancels the hide that group's
// previous change queued - and only that group's.
GVAR(displayTokens) = createHashMap;

// Autorun run state. Set up here so nothing ever reads one of these before the first
// activation - an undefined variable in a display event handler silently kills the handler.
GVAR(autorun_active) = false;
GVAR(autorun_tier) = AUTORUN_OFF;
GVAR(autorun_stance) = "Stand";
GVAR(autorun_animation) = "";
GVAR(autorun_stanceUntil) = 0;
GVAR(autorun_exhaustedUntil) = 0;
GVAR(notifyToken) = 0;
GVAR(customToken) = 0;
GVAR(animationSlotActive) = 0;
GVAR(animationSlotIndex) = 0;
GVAR(autorun_animDoneEH) = -1;
GVAR(autorun_animDoneUnit) = objNull;
GVAR(autorun_pfh) = -1;
GVAR(autorun_iconFrame) = 1;
GVAR(autorun_iconTime) = 0;
GVAR(autorun_nameCache) = createHashMap;
GVAR(autorun_animIndex) = 0;
GVAR(autorun_lastWeapon) = "";

// Displays a run keeps going under. 12 is the map; add your own display IDs from a mission or
// another mod if a run should survive them being open.
GVAR(autorun_displayAllow) = [12];

// Whitelist and blacklist settings all go through the same rebuild.
#define REBUILD_ANIMATIONS {call FUNC(rebuildAnimations)}

// Every animation box rebuilds all six lists.
#define REBUILD_ANIMATION_LISTS {call FUNC(autorunAnimationLists)}

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

// Speed for one animation by name, whatever group it is or is not in
[
    QGVAR(animationSpeedArray),
    "EDITBOX",
    [LLSTRING(SETTING_animationSpeedArray),LLSTRING(SETTING_animationSpeedArray_DESC)],
    [CBA_SETTINGS_AWSR_ANIM, LSTRING(SETTING_SubCategory_PerAnimation)],
    "Ladder*=1, Aswm*=1, Assw*=1, Absw*=1, Adve*=1, Abdv*=1, Asdv*=1",
    1,
    REBUILD_ANIMATIONS
] call CBA_Settings_fnc_init;

// Say why a speed or a pace was capped
[
    QGVAR(explainLimit),
    "CHECKBOX",
    [LLSTRING(SETTING_explainLimit),LLSTRING(SETTING_explainLimit_DESC)],
    [CBA_SETTINGS_AWSR, LSTRING(SETTING_SubCategory_General)],
    [true],
    0
] call CBA_Settings_fnc_init;

// Percent or coefficient
[
    QGVAR(valueStyle),
    "LIST",
    [LLSTRING(SETTING_valueStyle),LLSTRING(SETTING_valueStyle_DESC)],
    [CBA_SETTINGS_AWSR_GUI, LSTRING(SETTING_SubCategory_Display_General)],
    [[ARR_2(VALUE_PERCENT,VALUE_COEFFICIENT)], [ARR_2(LLSTRING(SETTING_valueStyle_percent),LLSTRING(SETTING_valueStyle_coefficient))], VALUE_PERCENT],
    0
] call CBA_Settings_fnc_init;

// Print every animation and keep the last few on the clipboard
[
    QGVAR(debug),
    "CHECKBOX",
    [LLSTRING(SETTING_debug),LLSTRING(SETTING_debug_DESC)],
    [CBA_SETTINGS_AWSR_ANIM, LSTRING(SETTING_SubCategory_Debug)],
    [false],
    1,
    {
        GVAR(debugAnimations) = [];
    }
] call CBA_Settings_fnc_init;

// Put our speed back when another mod or mission overwrites it
[
    QGVAR(reapplySpeed),
    "CHECKBOX",
    [LLSTRING(SETTING_reapplySpeed),LLSTRING(SETTING_reapplySpeed_DESC)],
    [CBA_SETTINGS_AWSR, LSTRING(SETTING_SubCategory_General)],
    [true],
    1
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

// IGUI range bar (walk)
[
    QGVAR(IGUI_showSlider_Walk),
    "CHECKBOX",
    [LLSTRING(SETTING_IGUI_showSlider),LLSTRING(SETTING_IGUI_showSlider_DESC)],
    [CBA_SETTINGS_AWSR_GUI, LSTRING(SETTING_SubCategory_Walk_IGUI)],
    [true],
    0
] call CBA_Settings_fnc_init;

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

// IGUI range bar (tactical)
[
    QGVAR(IGUI_showSlider_Tactical),
    "CHECKBOX",
    [LLSTRING(SETTING_IGUI_showSlider),LLSTRING(SETTING_IGUI_showSlider_DESC)],
    [CBA_SETTINGS_AWSR_GUI, LSTRING(SETTING_SubCategory_Tactical_IGUI)],
    [true],
    0
] call CBA_Settings_fnc_init;

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
    QGVAR(customMode),
    "LIST",
    [LLSTRING(SETTING_customMode),LLSTRING(SETTING_customMode_DESC)],
    [CBA_SETTINGS_AWSR, LSTRING(SETTING_SubCategory_Custom)],
    [[ARR_2(CUSTOM_MODE_GROUP,CUSTOM_MODE_ANIMATION)], [ARR_2(LLSTRING(SETTING_customMode_group),LLSTRING(SETTING_customMode_animation))], CUSTOM_MODE_ANIMATION],
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

// Custom animation blacklist (custom)
[
    QGVAR(notAllowedAnimationArray_Custom),
    "EDITBOX",
    [LLSTRING(SETTING_notAllowedAnimationArray),LLSTRING(SETTING_notAllowedAnimationArray_DESC)],
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

// IGUI range bar (custom)
[
    QGVAR(IGUI_showSlider_Custom),
    "CHECKBOX",
    [LLSTRING(SETTING_IGUI_showSlider),LLSTRING(SETTING_IGUI_showSlider_DESC)],
    [CBA_SETTINGS_AWSR_GUI, LSTRING(SETTING_SubCategory_Custom_IGUI)],
    [true],
    0
] call CBA_Settings_fnc_init;

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
    [CBA_SETTINGS_AWSR_AUTORUN, LSTRING(SETTING_SubCategory_Autorun_General)],
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
    [CBA_SETTINGS_AWSR_AUTORUN, LSTRING(SETTING_SubCategory_Autorun_Animations)],
    "AmovPercMwlkSlowWrflDf_ver2, AmovPercMwlkSlowWrflDf",
    1,
    REBUILD_ANIMATION_LISTS
] call CBA_Settings_fnc_init;

// Animation this pace loops instead of the one worked out for the situation
[
    QGVAR(autorun_animation_Jog),
    "EDITBOX",
    [LLSTRING(SETTING_autorun_animation_Jog),LLSTRING(SETTING_autorun_animation_DESC)],
    [CBA_SETTINGS_AWSR_AUTORUN, LSTRING(SETTING_SubCategory_Autorun_Animations)],
    "AmovPercMrunSrasWrflDf, AmovPercMrunSlowWrflDf",
    1,
    REBUILD_ANIMATION_LISTS
] call CBA_Settings_fnc_init;

// Animation this pace loops instead of the one worked out for the situation
[
    QGVAR(autorun_animation_Run),
    "EDITBOX",
    [LLSTRING(SETTING_autorun_animation_Run),LLSTRING(SETTING_autorun_animation_DESC)],
    [CBA_SETTINGS_AWSR_AUTORUN, LSTRING(SETTING_SubCategory_Autorun_Animations)],
    "AmovPercMevaSrasWrflDf",
    1,
    REBUILD_ANIMATION_LISTS
] call CBA_Settings_fnc_init;

// Animation this pace loops with a handgun in hand
[
    QGVAR(autorun_animation_WalkPistol),
    "EDITBOX",
    [LLSTRING(SETTING_autorun_animation_WalkPistol),LLSTRING(SETTING_autorun_animation_DESC)],
    [CBA_SETTINGS_AWSR_AUTORUN, LSTRING(SETTING_SubCategory_Autorun_Animations)],
    "AmovPercMrunSlowWpstDf",
    1,
    REBUILD_ANIMATION_LISTS
] call CBA_Settings_fnc_init;

// Animation this pace loops with a handgun in hand
[
    QGVAR(autorun_animation_JogPistol),
    "EDITBOX",
    [LLSTRING(SETTING_autorun_animation_JogPistol),LLSTRING(SETTING_autorun_animation_DESC)],
    [CBA_SETTINGS_AWSR_AUTORUN, LSTRING(SETTING_SubCategory_Autorun_Animations)],
    "AmovPercMrunSrasWpstDf",
    1,
    REBUILD_ANIMATION_LISTS
] call CBA_Settings_fnc_init;

// Animation this pace loops with a handgun in hand
[
    QGVAR(autorun_animation_RunPistol),
    "EDITBOX",
    [LLSTRING(SETTING_autorun_animation_RunPistol),LLSTRING(SETTING_autorun_animation_DESC)],
    [CBA_SETTINGS_AWSR_AUTORUN, LSTRING(SETTING_SubCategory_Autorun_Animations)],
    "AmovPercMevaSrasWpstDf",
    1,
    REBUILD_ANIMATION_LISTS
] call CBA_Settings_fnc_init;


// Animation this pace loops crouched with a rifle in hand
[
    QGVAR(autorun_animation_CrouchWalk),
    "EDITBOX",
    [LLSTRING(SETTING_autorun_animation_CrouchWalk),LLSTRING(SETTING_autorun_animation_DESC)],
    [CBA_SETTINGS_AWSR_AUTORUN, LSTRING(SETTING_SubCategory_Autorun_Animations)],
    "AmovPknlMwlkSrasWrflDf, AmovPknlMwlkSlowWrflDf",
    1,
    REBUILD_ANIMATION_LISTS
] call CBA_Settings_fnc_init;

// Animation this pace loops crouched with a rifle in hand
[
    QGVAR(autorun_animation_CrouchJog),
    "EDITBOX",
    [LLSTRING(SETTING_autorun_animation_CrouchJog),LLSTRING(SETTING_autorun_animation_DESC)],
    [CBA_SETTINGS_AWSR_AUTORUN, LSTRING(SETTING_SubCategory_Autorun_Animations)],
    "AmovPknlMrunSrasWrflDf, AmovPknlMrunSlowWrflDf",
    1,
    REBUILD_ANIMATION_LISTS
] call CBA_Settings_fnc_init;

// Animation this pace loops crouched with a rifle in hand
[
    QGVAR(autorun_animation_CrouchRun),
    "EDITBOX",
    [LLSTRING(SETTING_autorun_animation_CrouchRun),LLSTRING(SETTING_autorun_animation_DESC)],
    [CBA_SETTINGS_AWSR_AUTORUN, LSTRING(SETTING_SubCategory_Autorun_Animations)],
    "AmovPknlMevaSrasWrflDf",
    1,
    REBUILD_ANIMATION_LISTS
] call CBA_Settings_fnc_init;

// Animation this pace loops crouched with a handgun in hand
[
    QGVAR(autorun_animation_CrouchWalkPistol),
    "EDITBOX",
    [LLSTRING(SETTING_autorun_animation_CrouchWalkPistol),LLSTRING(SETTING_autorun_animation_DESC)],
    [CBA_SETTINGS_AWSR_AUTORUN, LSTRING(SETTING_SubCategory_Autorun_Animations)],
    "AmovPknlMwlkSrasWpstDf, AmovPknlMwlkSlowWpstDf",
    1,
    REBUILD_ANIMATION_LISTS
] call CBA_Settings_fnc_init;

// Animation this pace loops crouched with a handgun in hand
[
    QGVAR(autorun_animation_CrouchJogPistol),
    "EDITBOX",
    [LLSTRING(SETTING_autorun_animation_CrouchJogPistol),LLSTRING(SETTING_autorun_animation_DESC)],
    [CBA_SETTINGS_AWSR_AUTORUN, LSTRING(SETTING_SubCategory_Autorun_Animations)],
    "AmovPknlMrunSrasWpstDf, AmovPknlMrunSlowWpstDf",
    1,
    REBUILD_ANIMATION_LISTS
] call CBA_Settings_fnc_init;

// Animation this pace loops crouched with a handgun in hand
[
    QGVAR(autorun_animation_CrouchRunPistol),
    "EDITBOX",
    [LLSTRING(SETTING_autorun_animation_CrouchRunPistol),LLSTRING(SETTING_autorun_animation_DESC)],
    [CBA_SETTINGS_AWSR_AUTORUN, LSTRING(SETTING_SubCategory_Autorun_Animations)],
    "AmovPknlMevaSrasWpstDf",
    1,
    REBUILD_ANIMATION_LISTS
] call CBA_Settings_fnc_init;

// Animation this pace loops prone with a rifle in hand
[
    QGVAR(autorun_animation_ProneWalk),
    "EDITBOX",
    [LLSTRING(SETTING_autorun_animation_ProneWalk),LLSTRING(SETTING_autorun_animation_DESC)],
    [CBA_SETTINGS_AWSR_AUTORUN, LSTRING(SETTING_SubCategory_Autorun_Animations)],
    "AmovPpneMevaSlowWrflDf",
    1,
    REBUILD_ANIMATION_LISTS
] call CBA_Settings_fnc_init;

// Animation this pace loops prone with a rifle in hand
[
    QGVAR(autorun_animation_ProneJog),
    "EDITBOX",
    [LLSTRING(SETTING_autorun_animation_ProneJog),LLSTRING(SETTING_autorun_animation_DESC)],
    [CBA_SETTINGS_AWSR_AUTORUN, LSTRING(SETTING_SubCategory_Autorun_Animations)],
    "AmovPpneMrunSlowWrflDf",
    1,
    REBUILD_ANIMATION_LISTS
] call CBA_Settings_fnc_init;

// Animation this pace loops prone with a rifle in hand
[
    QGVAR(autorun_animation_ProneRun),
    "EDITBOX",
    [LLSTRING(SETTING_autorun_animation_ProneRun),LLSTRING(SETTING_autorun_animation_DESC)],
    [CBA_SETTINGS_AWSR_AUTORUN, LSTRING(SETTING_SubCategory_Autorun_Animations)],
    "AmovPpneMsprSlowWrflDf",
    1,
    REBUILD_ANIMATION_LISTS
] call CBA_Settings_fnc_init;

// Animation this pace loops prone with a handgun in hand
[
    QGVAR(autorun_animation_ProneWalkPistol),
    "EDITBOX",
    [LLSTRING(SETTING_autorun_animation_ProneWalkPistol),LLSTRING(SETTING_autorun_animation_DESC)],
    [CBA_SETTINGS_AWSR_AUTORUN, LSTRING(SETTING_SubCategory_Autorun_Animations)],
    "AmovPpneMrunSlowWpstDf",
    1,
    REBUILD_ANIMATION_LISTS
] call CBA_Settings_fnc_init;

// Animation this pace loops prone with a handgun in hand
[
    QGVAR(autorun_animation_ProneJogPistol),
    "EDITBOX",
    [LLSTRING(SETTING_autorun_animation_ProneJogPistol),LLSTRING(SETTING_autorun_animation_DESC)],
    [CBA_SETTINGS_AWSR_AUTORUN, LSTRING(SETTING_SubCategory_Autorun_Animations)],
    "AmovPpneMrunSlowWpstDf",
    1,
    REBUILD_ANIMATION_LISTS
] call CBA_Settings_fnc_init;

// Animation this pace loops prone with a handgun in hand
[
    QGVAR(autorun_animation_ProneRunPistol),
    "EDITBOX",
    [LLSTRING(SETTING_autorun_animation_ProneRunPistol),LLSTRING(SETTING_autorun_animation_DESC)],
    [CBA_SETTINGS_AWSR_AUTORUN, LSTRING(SETTING_SubCategory_Autorun_Animations)],
    "AmovPpneMsprSlowWpstDf",
    1,
    REBUILD_ANIMATION_LISTS
] call CBA_Settings_fnc_init;


// Let stamina limit the pace
[
    QGVAR(autorun_useStamina),
    "CHECKBOX",
    [LLSTRING(SETTING_autorun_useStamina),LLSTRING(SETTING_autorun_useStamina_DESC)],
    [CBA_SETTINGS_AWSR_AUTORUN, LSTRING(SETTING_SubCategory_Autorun_General)],
    [true],
    1
] call CBA_Settings_fnc_init;

// ------------------------------------------------------------------------------------------------------------------------ ANIMATION SLOTS

// Animations played by keybind 1
[
    QGVAR(animationSlot_1),
    "EDITBOX",
    [format [ARR_2(LLSTRING(SETTING_animationSlot),1)],LLSTRING(SETTING_animationSlot_DESC)],
    [CBA_SETTINGS_AWSR_ANIM, LSTRING(SETTING_SubCategory_Slots)],
    "",
    1,
    {call FUNC(rebuildAnimationSlots)}
] call CBA_Settings_fnc_init;

// Repeat that slot until the key is pressed again
[
    QGVAR(animationSlotLoop_1),
    "CHECKBOX",
    [format [ARR_2(LLSTRING(SETTING_animationSlotLoop),1)],LLSTRING(SETTING_animationSlotLoop_DESC)],
    [CBA_SETTINGS_AWSR_ANIM, LSTRING(SETTING_SubCategory_Slots)],
    [false],
    1
] call CBA_Settings_fnc_init;

// Animations played by keybind 2
[
    QGVAR(animationSlot_2),
    "EDITBOX",
    [format [ARR_2(LLSTRING(SETTING_animationSlot),2)],LLSTRING(SETTING_animationSlot_DESC)],
    [CBA_SETTINGS_AWSR_ANIM, LSTRING(SETTING_SubCategory_Slots)],
    "",
    1,
    {call FUNC(rebuildAnimationSlots)}
] call CBA_Settings_fnc_init;

// Repeat that slot until the key is pressed again
[
    QGVAR(animationSlotLoop_2),
    "CHECKBOX",
    [format [ARR_2(LLSTRING(SETTING_animationSlotLoop),2)],LLSTRING(SETTING_animationSlotLoop_DESC)],
    [CBA_SETTINGS_AWSR_ANIM, LSTRING(SETTING_SubCategory_Slots)],
    [false],
    1
] call CBA_Settings_fnc_init;

// Animations played by keybind 3
[
    QGVAR(animationSlot_3),
    "EDITBOX",
    [format [ARR_2(LLSTRING(SETTING_animationSlot),3)],LLSTRING(SETTING_animationSlot_DESC)],
    [CBA_SETTINGS_AWSR_ANIM, LSTRING(SETTING_SubCategory_Slots)],
    "",
    1,
    {call FUNC(rebuildAnimationSlots)}
] call CBA_Settings_fnc_init;

// Repeat that slot until the key is pressed again
[
    QGVAR(animationSlotLoop_3),
    "CHECKBOX",
    [format [ARR_2(LLSTRING(SETTING_animationSlotLoop),3)],LLSTRING(SETTING_animationSlotLoop_DESC)],
    [CBA_SETTINGS_AWSR_ANIM, LSTRING(SETTING_SubCategory_Slots)],
    [false],
    1
] call CBA_Settings_fnc_init;

// Animations played by keybind 4
[
    QGVAR(animationSlot_4),
    "EDITBOX",
    [format [ARR_2(LLSTRING(SETTING_animationSlot),4)],LLSTRING(SETTING_animationSlot_DESC)],
    [CBA_SETTINGS_AWSR_ANIM, LSTRING(SETTING_SubCategory_Slots)],
    "",
    1,
    {call FUNC(rebuildAnimationSlots)}
] call CBA_Settings_fnc_init;

// Repeat that slot until the key is pressed again
[
    QGVAR(animationSlotLoop_4),
    "CHECKBOX",
    [format [ARR_2(LLSTRING(SETTING_animationSlotLoop),4)],LLSTRING(SETTING_animationSlotLoop_DESC)],
    [CBA_SETTINGS_AWSR_ANIM, LSTRING(SETTING_SubCategory_Slots)],
    [false],
    1
] call CBA_Settings_fnc_init;

// Animations played by keybind 5
[
    QGVAR(animationSlot_5),
    "EDITBOX",
    [format [ARR_2(LLSTRING(SETTING_animationSlot),5)],LLSTRING(SETTING_animationSlot_DESC)],
    [CBA_SETTINGS_AWSR_ANIM, LSTRING(SETTING_SubCategory_Slots)],
    "",
    1,
    {call FUNC(rebuildAnimationSlots)}
] call CBA_Settings_fnc_init;

// Repeat that slot until the key is pressed again
[
    QGVAR(animationSlotLoop_5),
    "CHECKBOX",
    [format [ARR_2(LLSTRING(SETTING_animationSlotLoop),5)],LLSTRING(SETTING_animationSlotLoop_DESC)],
    [CBA_SETTINGS_AWSR_ANIM, LSTRING(SETTING_SubCategory_Slots)],
    [false],
    1
] call CBA_Settings_fnc_init;

// Animations played by keybind 6
[
    QGVAR(animationSlot_6),
    "EDITBOX",
    [format [ARR_2(LLSTRING(SETTING_animationSlot),6)],LLSTRING(SETTING_animationSlot_DESC)],
    [CBA_SETTINGS_AWSR_ANIM, LSTRING(SETTING_SubCategory_Slots)],
    "",
    1,
    {call FUNC(rebuildAnimationSlots)}
] call CBA_Settings_fnc_init;

// Repeat that slot until the key is pressed again
[
    QGVAR(animationSlotLoop_6),
    "CHECKBOX",
    [format [ARR_2(LLSTRING(SETTING_animationSlotLoop),6)],LLSTRING(SETTING_animationSlotLoop_DESC)],
    [CBA_SETTINGS_AWSR_ANIM, LSTRING(SETTING_SubCategory_Slots)],
    [false],
    1
] call CBA_Settings_fnc_init;

// Animations played by keybind 7
[
    QGVAR(animationSlot_7),
    "EDITBOX",
    [format [ARR_2(LLSTRING(SETTING_animationSlot),7)],LLSTRING(SETTING_animationSlot_DESC)],
    [CBA_SETTINGS_AWSR_ANIM, LSTRING(SETTING_SubCategory_Slots)],
    "",
    1,
    {call FUNC(rebuildAnimationSlots)}
] call CBA_Settings_fnc_init;

// Repeat that slot until the key is pressed again
[
    QGVAR(animationSlotLoop_7),
    "CHECKBOX",
    [format [ARR_2(LLSTRING(SETTING_animationSlotLoop),7)],LLSTRING(SETTING_animationSlotLoop_DESC)],
    [CBA_SETTINGS_AWSR_ANIM, LSTRING(SETTING_SubCategory_Slots)],
    [false],
    1
] call CBA_Settings_fnc_init;

// Animations played by keybind 8
[
    QGVAR(animationSlot_8),
    "EDITBOX",
    [format [ARR_2(LLSTRING(SETTING_animationSlot),8)],LLSTRING(SETTING_animationSlot_DESC)],
    [CBA_SETTINGS_AWSR_ANIM, LSTRING(SETTING_SubCategory_Slots)],
    "",
    1,
    {call FUNC(rebuildAnimationSlots)}
] call CBA_Settings_fnc_init;

// Repeat that slot until the key is pressed again
[
    QGVAR(animationSlotLoop_8),
    "CHECKBOX",
    [format [ARR_2(LLSTRING(SETTING_animationSlotLoop),8)],LLSTRING(SETTING_animationSlotLoop_DESC)],
    [CBA_SETTINGS_AWSR_ANIM, LSTRING(SETTING_SubCategory_Slots)],
    [false],
    1
] call CBA_Settings_fnc_init;

// Animations played by keybind 9
[
    QGVAR(animationSlot_9),
    "EDITBOX",
    [format [ARR_2(LLSTRING(SETTING_animationSlot),9)],LLSTRING(SETTING_animationSlot_DESC)],
    [CBA_SETTINGS_AWSR_ANIM, LSTRING(SETTING_SubCategory_Slots)],
    "",
    1,
    {call FUNC(rebuildAnimationSlots)}
] call CBA_Settings_fnc_init;

// Repeat that slot until the key is pressed again
[
    QGVAR(animationSlotLoop_9),
    "CHECKBOX",
    [format [ARR_2(LLSTRING(SETTING_animationSlotLoop),9)],LLSTRING(SETTING_animationSlotLoop_DESC)],
    [CBA_SETTINGS_AWSR_ANIM, LSTRING(SETTING_SubCategory_Slots)],
    [false],
    1
] call CBA_Settings_fnc_init;

// Animations played by keybind 10
[
    QGVAR(animationSlot_10),
    "EDITBOX",
    [format [ARR_2(LLSTRING(SETTING_animationSlot),10)],LLSTRING(SETTING_animationSlot_DESC)],
    [CBA_SETTINGS_AWSR_ANIM, LSTRING(SETTING_SubCategory_Slots)],
    "",
    1,
    {call FUNC(rebuildAnimationSlots)}
] call CBA_Settings_fnc_init;

// Repeat that slot until the key is pressed again
[
    QGVAR(animationSlotLoop_10),
    "CHECKBOX",
    [format [ARR_2(LLSTRING(SETTING_animationSlotLoop),10)],LLSTRING(SETTING_animationSlotLoop_DESC)],
    [CBA_SETTINGS_AWSR_ANIM, LSTRING(SETTING_SubCategory_Slots)],
    [false],
    1
] call CBA_Settings_fnc_init;

// Show the animation indicator
[
    QGVAR(IGUI_showAnimation),
    "CHECKBOX",
    [LLSTRING(SETTING_IGUI_showAnimation),LLSTRING(SETTING_IGUI_showAnimation_DESC)],
    [CBA_SETTINGS_AWSR_ANIM, LSTRING(SETTING_SubCategory_Slots)],
    [true],
    0
] call CBA_Settings_fnc_init;

// What the animation indicator says
[
    QGVAR(IGUI_Text_Animation),
    "EDITBOX",
    [LLSTRING(SETTING_IGUI_Text_Animation),LLSTRING(SETTING_IGUI_Text_Animation_DESC)],
    [CBA_SETTINGS_AWSR_ANIM, LSTRING(SETTING_SubCategory_Slots)],
    "PLAYING ANIMATION %1",
    0
] call CBA_Settings_fnc_init;

// Size of the animation indicator text
[
    QGVAR(IGUI_textSize_Animation),
    "SLIDER",
    [LLSTRING(SETTING_IGUI_textSize_Animation),LLSTRING(SETTING_IGUI_textSize_Animation_DESC)],
    [CBA_SETTINGS_AWSR_ANIM, LSTRING(SETTING_SubCategory_Slots)],
    [ARR_5(0.5,3,1.4,1,true)],
    0
] call CBA_Settings_fnc_init;

// Colour of the animation indicator
[
    QGVAR(IGUI_textColor_Animation),
    "COLOR",
    [LLSTRING(SETTING_IGUI_textColor_Animation),LLSTRING(SETTING_IGUI_textColor_Animation_DESC)],
    [CBA_SETTINGS_AWSR_ANIM, LSTRING(SETTING_SubCategory_Slots)],
    [ARR_3(1,1,1)],
    0
] call CBA_Settings_fnc_init;

// ------------------------------------------------------------------------------------------------------------------------ AUTORUN IGUI

// Show the autorun indicator
[
    QGVAR(IGUI_showAutorun),
    "CHECKBOX",
    [LLSTRING(SETTING_IGUI_showAutorun),LLSTRING(SETTING_IGUI_showAutorun_DESC)],
    [CBA_SETTINGS_AWSR_AUTORUN, LSTRING(SETTING_SubCategory_Autorun_Indicator)],
    [true],
    0,
    {
        if (hasInterface) then {call FUNC(autorunIndicator)};
    }
] call CBA_Settings_fnc_init;

// Show the pace text on the autorun indicator
[
    QGVAR(IGUI_showAutorunPace),
    "CHECKBOX",
    [LLSTRING(SETTING_IGUI_showAutorunPace),LLSTRING(SETTING_IGUI_showAutorunPace_DESC)],
    [CBA_SETTINGS_AWSR_AUTORUN, LSTRING(SETTING_SubCategory_Autorun_Indicator)],
    [true],
    0,
    {
        if (hasInterface) then {call FUNC(autorunIndicator)};
    }
] call CBA_Settings_fnc_init;

// Show the keybinds on the autorun indicator
[
    QGVAR(IGUI_showAutorunKeys),
    "CHECKBOX",
    [LLSTRING(SETTING_IGUI_showAutorunKeys),LLSTRING(SETTING_IGUI_showAutorunKeys_DESC)],
    [CBA_SETTINGS_AWSR_AUTORUN, LSTRING(SETTING_SubCategory_Autorun_Indicator)],
    [true],
    0,
    {
        if (hasInterface) then {call FUNC(autorunIndicator)};
    }
] call CBA_Settings_fnc_init;

// Text of the autorun key line
[
    QGVAR(IGUI_Text_Autorun),
    "EDITBOX",
    [LLSTRING(SETTING_IGUI_Text_Autorun),LLSTRING(SETTING_IGUI_Text_Autorun_DESC)],
    [CBA_SETTINGS_AWSR_AUTORUN, LSTRING(SETTING_SubCategory_Autorun_Indicator)],
    "%1%2%3",
    0,
    {
        if (hasInterface) then {call FUNC(autorunIndicator)};
    }
] call CBA_Settings_fnc_init;

// Wording of one part of the autorun key line
[
    QGVAR(IGUI_TextPace_Autorun),
    "EDITBOX",
    [LLSTRING(SETTING_IGUI_TextPace_Autorun),LLSTRING(SETTING_IGUI_TextPart_Autorun_DESC)],
    [CBA_SETTINGS_AWSR_AUTORUN, LSTRING(SETTING_SubCategory_Autorun_Indicator)],
    "PACE: %1      ",
    0,
    {
        if (hasInterface) then {call FUNC(autorunIndicator)};
    }
] call CBA_Settings_fnc_init;

// Wording of one part of the autorun key line
[
    QGVAR(IGUI_TextStyle_Autorun),
    "EDITBOX",
    [LLSTRING(SETTING_IGUI_TextStyle_Autorun),LLSTRING(SETTING_IGUI_TextPart_Autorun_DESC)],
    [CBA_SETTINGS_AWSR_AUTORUN, LSTRING(SETTING_SubCategory_Autorun_Indicator)],
    "STYLE: %1      ",
    0,
    {
        if (hasInterface) then {call FUNC(autorunIndicator)};
    }
] call CBA_Settings_fnc_init;

// Wording of one part of the autorun key line
[
    QGVAR(IGUI_TextStop_Autorun),
    "EDITBOX",
    [LLSTRING(SETTING_IGUI_TextStop_Autorun),LLSTRING(SETTING_IGUI_TextPart_Autorun_DESC)],
    [CBA_SETTINGS_AWSR_AUTORUN, LSTRING(SETTING_SubCategory_Autorun_Indicator)],
    "STOP: %1",
    0,
    {
        if (hasInterface) then {call FUNC(autorunIndicator)};
    }
] call CBA_Settings_fnc_init;

// Colour of the keys inside the autorun key line
[
    QGVAR(IGUI_keyColor_Autorun),
    "COLOR",
    [LLSTRING(SETTING_IGUI_keyColor_Autorun),LLSTRING(SETTING_IGUI_keyColor_Autorun_DESC)],
    [CBA_SETTINGS_AWSR_AUTORUN, LSTRING(SETTING_SubCategory_Autorun_Indicator)],
    [1,0.85,0.4],
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
    [CBA_SETTINGS_AWSR_AUTORUN, LSTRING(SETTING_SubCategory_Autorun_Indicator)],
    [1,1,1,1],
    0
] call CBA_Settings_fnc_init;

// IGUI text color (autorun)
[
    QGVAR(IGUI_textColor_Autorun),
    "COLOR",
    [LLSTRING(SETTING_IGUI_textColor),LLSTRING(SETTING_IGUI_textColor_DESC)],
    [CBA_SETTINGS_AWSR_AUTORUN, LSTRING(SETTING_SubCategory_Autorun_Indicator)],
    [1,1,1],
    0
] call CBA_Settings_fnc_init;

// IGUI Text Size (autorun)
[
    QGVAR(IGUI_textSize_Autorun),
    "SLIDER",
    [LLSTRING(SETTING_IGUI_textSize), LLSTRING(SETTING_IGUI_textSize_DESC)],
    [CBA_SETTINGS_AWSR_AUTORUN, LSTRING(SETTING_SubCategory_Autorun_Indicator)],
    [0.1, 3, 1, 2],
    0,
    {
        SETMVAR(GVAR(IGUI_textSize_Autorun),[ARR_2(GVAR(IGUI_textSize_Autorun),2)] call BIS_fnc_cutDecimals);
    }
] call CBA_Settings_fnc_init;

ADDON = true;
