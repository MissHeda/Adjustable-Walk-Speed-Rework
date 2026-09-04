# Changelog

## 2.0.0

Measured against **1.0.6**, the version on the Workshop. The bug fixes come from the reports on the
Workshop page; the reporter is named on each.

### Upgrading

The addon inside the mod is called `movement` instead of `core`, so every setting, keybind and IGUI
position carries a new name. **They all fall back to their defaults once on first launch.** Nothing
else is lost - set them again and they stay.

### Added

- **Autorun.** Walk, jog and run as three paces. One key pair steps up and down through them, and a
  run ends on the pace key it is already on, on stepping below a walk, or on a movement key. The
  animation follows stamina, terrain, water, stance and injuries.

  Each pace has its own animation setting, one set for a rifle and one for a handgun, filled in
  with what the run resolves to. Put several names in a box, comma separated, and a key steps
  between them mid-run. A run only starts with a rifle or a handgun in hand - a launcher or
  binoculars have no animations to run with.

  Derived from Leon and Legion's [Autorun Rework](https://github.com/LeonZ2019/autorun-rework),
  which stays under APL-SA. One thing works differently from that mod: stopping a run there turned
  damage off outright and gave it back when the stop animation ended, so every stop bought seconds
  of invulnerability. Here the stop hangs a damage handler on the unit for a quarter of a second
  that cancels only damage with no projectile and nobody behind it - the fall the forced animation
  can provoke. Being shot while stopping hurts exactly as much as it should.
  *(asked for by 42nfl19)*

- **An indicator for the autorun**, placed and sized in the layout tab like everything else. It
  shows the pace and what the keys do:

  ```
  PACE: CTRL + W / S      STYLE: J      STOP: W / S / F5
  ```

  Both lines can be switched off, and the wording is yours: one box assembles the parts, three more
  word each part on its own. Keys are named after the bindings you actually have, keys sharing a
  modifier are written with it once, and the key that ends a run changes with the pace. A part with
  no key is left out whole, so the style part takes its label with it while a pace has only one
  animation. The keys take a colour of their own so they stand out from the wording.

- **Wildcards in the whitelist and blacklist.** `melee_armed_*` covers every animation whose name
  starts that way, so a mod with a lot of custom animations no longer has to be listed one entry at
  a time. *(asked for by SSG and QWRT0987 for prone animations)*

- **Every animation group has its own display**, with its own entry in the layout tab, so walk,
  tactical and custom can be placed, sized and timed on their own. They used to share one display
  whose picture was swapped, which meant they shared its hide timer as well.

- **IGUI Display Duration** per group, defaulting to 0 - the display stays - and **IGUI Hide At
  Default Speed**, on by default. Together a display stands exactly as long as that group's speed
  is not 100%. *(asked for by dyolF)*

- **Reapply Speed If Overwritten**, on by default. Missions that drive the animation speed from
  their own loop used to win by writing last; this puts your speed back. It is a server setting:
  whether this mod outranks a mission's own speed handling is the mission's call, not something
  each player decides. *(from the reports below)*

### Fixed

- **ACE advanced fatigue stopped working as soon as this mod loaded.** Every whitelisted animation
  name was pushed into `ace_advanced_fatigue_setAnimExclusions`. That is not a list of animations -
  it is a list of claim tags, and ACE only ever asks whether it is empty. A list that never emptied
  meant ACE left `setAnimSpeedCoef` alone for the rest of the mission, so its exhaustion slowdown
  and its reset to default were both silently dead. One tag goes in now while this mod is actually
  driving the speed, and comes back out when it is not.

- **The custom display only showed the first change.** Every key press cut a fresh title onto the
  layer, which tore down the display the number was about to be written into - so the second change
  and every one after it blanked the value instead of updating it, until the title timed out and
  the next press worked again. *(reported by Pat and malice20191)*

- **Speed reverted a moment after being set in some missions.** Ravage, Hetman and Hive drive the
  animation speed from their own loop, and whoever writes it last wins. See *Reapply Speed If
  Overwritten* above. *(reported by HBAOplus, vat hom flaffie and rodrockwell)*

- **Audibility was never given back.** Turning the speed down set `audibleCoef` and nothing ever
  reset it, so the reduced value stayed on the unit after leaving the animation. It was also set
  locally, where the AI doing the listening usually is not. *(reported by dyolF)*

- **Force walk could be lost while a reduced speed was still set.** It was set from the keybind and
  cleared by the animation handler, so the two undid each other on the next animation change. It
  hangs off the walk speed alone now, decided in one place. *(reported by dyolF)*

- **The mod stopped working after respawning.** The animation handler was added once to whatever
  `player` was at mission start. It follows the player now, through respawn, team switch and Zeus
  remote control.

- **Multiplayer traffic.** Every animation state change broadcast a JIP flagged remote call -
  several per second, per player, each adding a queue entry that every joining player replayed. The
  speed is broadcast only when it changes, with one JIP entry per unit that is replaced rather than
  added to and dropped once the speed is back at default, and it is applied locally first so a
  mission with a restrictive `CfgRemoteExec` cannot swallow the player's own speed.

- **`awsr_movement_fnc_setDefaultSpeed`**, the one function missions are meant to call, writes to a
  variable on the unit that only the machine owning it reads. Called anywhere else it silently did
  nothing. It now runs on the unit's owner wherever it is called from.

- **Unticking "include non raised animations" did nothing until a restart.** The whitelists were
  built by adding to whatever was already there; they are rebuilt from the settings every time. The
  whitelist and blacklist boxes no longer ask for a restart either.

- **The blacklist could remove other mods' entries from ACE's exclusion list.**

- **A blacklisted animation could not overrule a whitelist wildcard.** Blacklisting a single name
  out of a `melee_armed_*` sort of entry did nothing - a wildcard was only ever cancelled by
  another wildcard. The name wins now.

- Toggling settings could grow the whitelists with duplicate entries.
- The walk group's "include non raised animations" callback referenced an undefined variable.
- A script error on the first animation change of a mission with ACE loaded, from looking up our
  own force walk reason before it had ever been registered.

### Changed

- Speed keybinds do nothing while their animation group is switched off, rather than storing a
  value that would never be applied.
- Switching the whole system, or audibility, off hands the unit back straight away instead of at
  the next animation change.
- The animation lookup is cached per animation name instead of concatenating and searching a few
  hundred strings on every animation state change.
- Settings, IGUI settings and keybinds are numbered so they read in the same order everywhere.

### Known and not changed

- **Force walk stays exclusive to the walk group.** Applying it from the tactical group would
  switch the player into a walk animation, which is the group they just left.
  *(asked for by A. Ares and nigel)*
- **AI are not affected.** The mod only ever touches the player's own unit.
