# Changelog

## 2.0.0

Everything below is measured against 1.1.0, the version on the Workshop. The bug fixes come from
the reports on the Workshop page; the reporter is named on each.

### Fixed

- **ACE advanced fatigue never ran again once this mod loaded.** Every whitelisted animation name
  was pushed into `ace_advanced_fatigue_setAnimExclusions`. That variable is not a list of
  animations - it is a list of claim tags, and ACE only ever asks whether it is empty. A list that
  never emptied meant ACE stopped touching `setAnimSpeedCoef` for the rest of the mission, so its
  exhaustion slowdown and its reset to default were both silently dead. One tag goes in now while
  this mod is actually driving the speed, and comes out again when it is not.

- **The custom IGUI only showed the first change.** Every key press cut a fresh title onto the
  layer, which tore down the display the number was about to be written into - so the second
  change and every one after it blanked the value instead of updating it, until the title timed
  out and the next press worked again. *(reported by Pat and malice20191)*

- **Speed reverted a moment after being set in some missions.** Ravage, Hetman and Hive drive the
  animation speed from their own loop, and whoever writes `setAnimSpeedCoef` last wins. A new
  setting, *Reapply Speed If Overwritten* (on by default), puts the value back.
  *(reported by HBAOplus, vat hom flaffie and rodrockwell)*

- **Audibility was never given back.** Turning the speed down set `audibleCoef` and nothing ever
  reset it, so the reduced value stayed on the unit after leaving the animation - and it was set
  locally, where the AI that does the listening usually is not. *(reported by dyolF)*

- **Force walk could be lost while a reduced speed was still set.** It was set from the keybind
  and cleared by the animation handler, so the two undid each other on the next animation change.
  It hangs off the walk speed alone now, decided in one place. *(reported by dyolF)*

- **The mod stopped working after respawning.** The animation handler was added once to whatever
  `player` was at mission start. It follows the player now, through respawn, team switch and Zeus
  remote control.

- **Multiplayer traffic.** Every animation state change broadcast a JIP flagged remote call -
  several per second, per player, each adding a queue entry that every joining player replayed.
  The speed is broadcast only when it changes, with one JIP entry per unit that gets replaced, and
  applied locally first so a mission with a restrictive `CfgRemoteExec` cannot swallow the
  player's own speed.

- **Unticking "include non raised animations" did nothing until a restart.** The whitelists were
  built by adding to whatever was there; they are rebuilt from the settings every time. The
  whitelist and blacklist boxes no longer ask for a restart either.

- **The blacklist could remove other mods' entries from ACE's exclusions.**

- Toggling settings could grow the whitelists with duplicates.
- The walk group's "include non raised animations" callback referenced an undefined variable.
- A script error on the first animation change of a mission when ACE was loaded, from looking up
  our own force walk reason before it had ever been registered.

### Added

- **Autorun.** Walk, jog and run as three paces, with one key pair to step up and down through
  them, in a display you place yourself. It keeps the animation in step with stamina, terrain,
  water, stance and injuries, and each pace can be pinned to an animation of your own - one set
  for a rifle, one for a handgun. Derived from Leon and Legion's Autorun Rework.
  *(asked for by 42nfl19)*

- **Wildcards in the whitelist and blacklist.** `melee_armed_*` covers every animation whose name
  starts that way, so mods with a lot of custom animations no longer have to be listed one entry
  at a time. *(asked for by SSG and QWRT0987 for prone animations)*

- **Each animation group has its own IGUI**, with its own entry in the layout tab, so walk,
  tactical and custom can be placed, sized and timed independently. They used to share one display
  whose picture was swapped, which meant they also shared its hide timer.

- **IGUI Display Duration** per group, defaulting to 0 - the display stays - and **IGUI Hide At
  Default Speed**, on by default. Together the display stands exactly as long as that group's
  speed is not 100%. *(asked for by dyolF)*

### Changed

- **Stopping an autorun no longer makes the player invulnerable.** Inherited from the original
  autorun mod, the stop turned damage off outright and gave it back when the stop animation ended
  or after three seconds. That was never a design: `allowDamage false` shipped there with no
  restore at all, and the three seconds are an artefact of the hotfix that added one. The stop now
  hangs a `HandleDamage` handler on the unit for a quarter of a second that cancels only damage
  with no projectile and nobody behind it. Being shot while stopping hurts exactly as much as it
  should.
- The animation lookup is cached per animation name instead of concatenating and searching a few
  hundred strings on every animation state change.
- Settings, IGUI settings and keybinds all read in the same numbered order, autorun first.
- The three speed keybinds do nothing while their animation group is switched off.
- Which movement keys end an autorun is a setting - forward and back by default, sideways off.
  They follow the vanilla movement actions, so rebinding WASD is picked up on its own.
- Switching the system, or audibility, off now hands the unit back right away.

### Known and not changed

- **Force walk stays exclusive to the walk group.** Applying it from the tactical group would
  switch the player into a walk animation, which is the group they just left.
  *(asked for by A. Ares and nigel)*
- **AI are not affected.** The mod only ever touches the player's own unit.

## 1.1.0

- IGUI fix for the newest Arma version
- Two missing pistol animations
