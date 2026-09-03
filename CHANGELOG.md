# Changelog

## 1.2.0

Bug fix round based on the reports on the Steam Workshop page.

### Fixed

- **The custom IGUI only showed the first change.** Every key press cut a fresh title onto
  the layer, which tore down the display the number was about to be written into - so the
  second change and every one after it blanked the value instead of updating it, until the
  title timed out and the next press worked again. The title is now cut once and kept; the
  picture, the colours and the text are set on the display that is already there, and hiding
  it fades the controls rather than destroying the display.
  *(reported by Pat and malice20191)*

- **Speed reverted a moment after being set in some missions.** Ravage, Hetman and Hive drive
  the animation speed from their own loop, and whoever writes `setAnimSpeedCoef` last wins.
  A new setting, *Reapply Speed If Overwritten* (on by default), puts the value back when
  something else overwrites it, while the player is in an animation the mod owns.
  *(reported by HBAOplus, vat hom flaffie and rodrockwell)*

- **Audibility was never given back.** Turning the speed down set `audibleCoef` and nothing
  ever reset it, so the reduced value stayed on the unit after leaving the animation - and it
  was set locally, where the AI that does the listening usually is not. It is now set globally,
  restored when leaving a whitelisted animation, and restored to whatever the mission had set
  before the mod first touched it.
  *(reported by dyolF)*

- **Force walk could be lost while a reduced speed was still set.** Opening and closing the
  pause menu dropped it, and the mod only ever cleared force walk, never re-asserted it. It is
  now re-applied while it should be on, and only cleared when it was ours to clear.
  *(reported by dyolF)*

- **The mod stopped working after respawning.** The animation handler was added once to
  whatever `player` was at mission start. It now follows the player, so respawning, switching
  unit, or being remote controlled keeps it working.

- **Multiplayer traffic.** Every animation state change broadcast a JIP flagged remote call -
  several per second, per player, each one adding a new entry to the JIP queue that every
  joining player then replayed. The speed is now only broadcast when it actually changes, with
  one JIP entry per unit that gets replaced rather than added to, and it is applied locally
  first so a mission with a restrictive `CfgRemoteExec` cannot swallow the player's own speed.

- **Unticking "include non raised animations" did nothing until a restart.** The whitelists
  were built by adding to whatever was there; they are now rebuilt from the settings every
  time, which also means the whitelist and blacklist boxes no longer ask for a restart.

- **The blacklist could remove other mods' entries from ACE's advanced fatigue exclusions.**
  The mod now takes back exactly what it put there.

- Toggling settings could grow the whitelists with duplicates.
- The walk group's "include non raised animations" callback referenced an undefined variable.
- A script error on the first animation change of a mission when ACE was loaded, from looking
  up our own force walk reason before it had ever been registered.

### Added

- **Wildcards in the whitelist and blacklist.** `melee_armed_*` covers every animation whose
  name starts that way, so mods with a lot of custom animations no longer have to be listed
  one entry at a time. *(asked for by SSG and QWRT0987 for prone animations)*
- **IGUI Display Duration** per animation group. 0 keeps the display up permanently.
  *(asked for by dyolF)*
- Autorun, as its own `awsr_autorun` PBO. *(asked for by 42nfl19)*

### Changed

- The animation lookup is cached per animation name instead of concatenating and searching a
  few hundred strings on every animation state change.
- The three speed keybinds do nothing while their animation group is switched off, instead of
  storing a value that would never be applied.
- Switching the whole system, or audibility, off in the CBA settings now hands the unit back
  right away rather than at the next animation change.
- **The autorun keys moved into the CBA keybind menu**, next to the speed keys, under their
  own "Autorun" heading - they used to be vanilla key actions in the normal control options.
  The reason they were vanilla ones was that the run logic asks which key is currently down,
  and only vanilla actions answer `inputAction`; it now reads the live keybinds from CBA
  instead, so rebinding takes effect without a restart. They start out unbound: the keys they
  used to default to, F4 to F7, are the vanilla team select keys.
- With no stop key bound, pressing the walk, jog or run key during a run switched the type
  and stopped the run in the same breath. It only switches the type now.
- Autorun stops when the player unit changes, and no longer leaves its animation handler on
  the old unit.
- **Stopping an autorun no longer makes the player invulnerable.** Inherited from the
  original mod, the stop turned damage off outright and gave it back when the stop animation
  ended, or after three seconds - so every stop bought up to three seconds of immunity to
  everything, gunfire included, which in multiplayer is an exploit. It also wrote the same
  `allowDamage` flag ACE, Zeus and mission scripts use, after reading back a value that may
  have been theirs rather than ours. The stop now hangs a `HandleDamage` handler on the unit
  for a quarter of a second that cancels only damage with no projectile and nobody behind it
  - the fall or collision the forced animation can provoke. Being shot while stopping hurts
  exactly as much as it should, and no other damage handler is disturbed.
- The four IGUI title classes are one class; the picture and its colour come from script.

### Known and not changed

- **Force walk stays exclusive to the walk group.** Applying it from the tactical group would
  switch the player into a walk animation, which is the group they just left.
  *(asked for by A. Ares and nigel)*
- **AI are not affected.** The mod only ever touches the player's own unit.

## 1.1.0

- IGUI fix for the newest Arma version
- Two missing pistol animations
