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

private _existing = [_registry, _action] call CBA_fnc_hashGet;
if (!isNil "_existing") exitWith {};

[
    _registry,
    _action,
    [
        [0x11, [false, false, false]],
        [0x1F, [false, false, false]]
    ]
] call CBA_fnc_hashSet;
