#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Adds S to the end-run keybind when it holds W and nothing else.
 *
 * CBA_fnc_addKeybind takes a single default, but an action holds a list of keys and the keybind
 * menu edits all of them - so the second one is written into the registry before CBA first looks
 * at it. Only that one shape is touched: a lone W is what addKeybind leaves behind, so it is the
 * only state that was nobody's decision.
 *
 * An empty list is a decision - somebody cleared the keybind - and is left empty. Anything else
 * is a decision too.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call awsr_movement_fnc_autorunSeedStopKeys;
 *
 * Public: No
 */

// CBA's own keybind registry. Only read after at least one keybind has been registered, so it
// exists - if CBA ever renames it we simply fall through and the addKeybind default stands.
private _registry = profileNamespace getVariable "cba_keybinding_registry_v3";
if (isNil "_registry") exitWith {};

private _action = toLower ("AWSR$" + QGVAR(autorun_stopKey));

// CBA_fnc_hashGet answers a missing key with the hash's own default rather than with nil, so an
// isNil check here never fires. Ask for an empty array instead.
private _existing = [_registry, _action, []] call CBA_fnc_hashGet;

private _w = [ARR_2(0x11,[ARR_3(false,false,false)])];
private _s = [ARR_2(0x1F,[ARR_3(false,false,false)])];

// Only the lone W that addKeybind leaves behind. An empty list stays empty, and a list somebody
// built themselves stays theirs.
if (_existing isNotEqualTo [_w]) exitWith {};

[_registry, _action, [ARR_2(_w,_s)]] call CBA_fnc_hashSet;
