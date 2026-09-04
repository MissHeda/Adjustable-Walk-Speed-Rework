#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Gives the end-run keybind two default keys instead of one.
 *
 * CBA_fnc_addKeybind takes a single default, but an action holds a list of keys and the keybind
 * menu edits all of them - so the pair is written into the registry before CBA first looks at it.
 * Once the action has an entry, CBA leaves it alone, which is also why this only ever writes when
 * there is nothing there: a player who rebound the keys keeps what they chose.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call awsr_awsr_fnc_autorunSeedStopKeys;
 *
 * Public: No
 */

// CBA's own keybind registry. Only read after at least one keybind has been registered, so it
// exists - if CBA ever renames it we simply fall through and the addKeybind default stands.
private _registry = profileNamespace getVariable "cba_keybinding_registry_v3";
if (isNil "_registry") exitWith {};

private _action = toLower ("AWSR$" + QGVAR(autorun_stopKey));

// CBA_fnc_hashGet answers a missing key with the hash's own default rather than with nil, so an
// isNil check here never fires and the pair never got written. Ask for an empty array instead.
private _existing = [_registry, _action, []] call CBA_fnc_hashGet;

// Whatever the player chose stays. The exception is the lone W this shipped with while the seed
// was broken - that was the addKeybind fallback, not a choice anyone made.
private _staleFallback = [[0x11, [false, false, false]]];

if (_existing isNotEqualTo [] && {_existing isNotEqualTo _staleFallback}) exitWith {};

[
    _registry,
    _action,
    [
        [0x11, [false, false, false]],
        [0x1F, [false, false, false]]
    ]
] call CBA_fnc_hashSet;
