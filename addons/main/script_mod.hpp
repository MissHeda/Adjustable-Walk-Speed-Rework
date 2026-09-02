// COMPONENT is defined in each addon's script_component.hpp, which includes this file first.

#define MAINPREFIX z
#define PREFIX awsr

#include "script_version.hpp"

#define VERSION_CONFIG version = MAJOR.MINOR; versionStr = QUOTE(MAJOR.MINOR.PATCH); versionAr[] = {MAJOR,MINOR,PATCH}

// Minimum Arma version the mod is built against.
#define REQUIRED_VERSION 2.16

#ifdef COMPONENT_BEAUTIFIED
    #define COMPONENT_NAME QUOTE(Adjustable Walking Speed - Rework - COMPONENT_BEAUTIFIED)
#else
    #define COMPONENT_NAME QUOTE(Adjustable Walking Speed - Rework - COMPONENT)
#endif
