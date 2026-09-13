# Changelog

## 2.0.0

Measured against **1.0.6**, the version on the Workshop. The bug fixes come from the reports on the
Workshop page; the reporter is named on each.

### Upgrading

The addon inside the mod is called `movement` instead of `core`, so every setting, keybind and IGUI
position carries a new name. **They all fall back to their defaults once on first launch.** Nothing
else is lost - set them again and they stay.

### Added

- **Autorun.** One key starts and ends a run; the mouse wheel steps through five paces - walk,
  tactical, jog, run and sprint - and does nothing at all outside a run, so it stays yours the
  rest of the time. A run also ends on a movement key.
  The animation follows stamina, terrain, water, stance and injuries.

  Not every pace exists in every stance with every weapon: there is no tactical pace with empty
  hands, no walking or tactical crawl at all, and no sprint standing or crouched - what looks
  like a sprint there is the game's evasive pace. Those boxes ship empty, and an empty box is
  stepped over as though the pace were not there, which is also how one is switched off.

  Each pace has its own animation setting, one set for a rifle, one for a handgun and one for
  empty hands, filled in with what the run resolves to. Put several names in a box, comma
  separated, and a key steps between them mid-run. A launcher or binoculars still end a run -
  the game has no animations for running with either.

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

- **Cover Jogging Animations As Well**, a tick on the tactical group, on by default. A tactical
  pace people actually use runs through a jog as often as through a walk, and the group covered
  none of it.

- **ANIMATIONS.txt in the mod folder** - what each segment of an animation name means, and every
  name the walking and tactical groups cover, listed per setting. Paste any of it straight into a
  settings box.

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

- **Debug**, off by default. With it on, every animation the player enters is shown in a hint and
  the last 20 - one entry per animation, not one per loop - are kept in the clipboard as a comma
  separated list, which is exactly the format the whitelist and animation boxes take. Meant for
  finding the name of an animation without opening the config viewer: switch it on, do the move,
  switch it off, paste. It works with the rest of the mod switched off.

  A group that has been moved off default overrules a speed an animation was given by name - a
  walk group at 10% slows an animation set to 200% - and a group left at default leaves it
  alone.

- **A repeat count on an animation.** `AmovPercMstpSnonWnonDnon_Salutex3` salutes three times.
  Checked as a whole name first, since the game ships animations that genuinely end in `x2`.

- **What the segments of an animation name mean** is in every box that takes one - the group
  whitelists and blacklist, the autorun animations, the per-animation speeds and the animation
  keys - not only in Debug.

- **Speed Up Transitions**, on by default. The game's own transition between two animations in a
  sequence belongs to no group and has no speed of its own, so it ran at normal speed however
  fast the rest was set - which reads as the sequence stopping for a moment. It is given the
  speed of the animation it is heading for.

- **Default speed reads as "Default"** rather than as 100% or 1.

- **A range bar under every speed display**, with a checkbox each, showing where the value sits
  between the lowest and highest the keys reach - default speed in the middle, the two halves
  read separately so an ordinary value does not sit squashed against one end.

- **Per-Animation Speeds.** A speed for single animations by name, whatever group they are or are
  not in - `Aswm*=2, Ladder*=1.5`. Swimming, ladders and crawling are in no group at all, which is
  why they were out of reach until now. It beats all three groups, so the number on the display is
  always the number being applied. The number also widens what the speed keys can reach: above the
  group's maximum it becomes the new maximum, below its minimum the new minimum. Ladders and
  swimming are filled in at 1 already, ready to be turned up.

- **Stamina limits the autorun.** Out of breath drops the run a pace and refuses a faster one, at
  the same points ACE takes the sprint away and forces a walk. Where ACE advanced fatigue is
  running it reads ACE's reserves; otherwise the engine's own fatigue. Can be switched off.

- **A reason when a limit is hit**, instead of a value that just looks stuck - "Too exhausted"
  while ACE holds a force walk for fatigue, and when a pace is refused. It is only ever named when
  the reason is actually known.

- **Percent or coefficient** for every speed shown - 150% or 1.5, whichever you think in.

- **Ten animation keys.** Bind a key, put an animation name in its box, and the key plays it -
  a salute, a gesture, a pose. Several names, comma separated, play one after another as a
  sequence, and each key can be set to repeat until it is pressed again. Pressing the key while
  it runs stops it. None of the ten are bound by default.

- **An indicator for the animation keys**, placed in the layout tab like the others, saying which
  key is running and which key stops it, the key in a colour of its own, named from the binding
  you actually have - a looping key
  has no other way of telling you either. It is a line of text rather than another icon, since
  there is nothing to draw, and its wording is yours like every other display's.

- **A blacklist for the custom group**, now that wildcards make one worth having.

- **An animation setting per stance, pace and weapon** - forty-five boxes, a sub-category per
  stance, ordered rifle, handgun, empty hands. Twenty-nine ship filled and sixteen empty, taken
  from what the game actually has, so a stance change during a run plays something built for that stance. Every pace
  ships with its lowered and raised variants as alternatives, so the next-animation key switches
  between them - except prone, which the game only has lowered, and whose two crawl speeds are
  all there is.

### Fixed

- **ACE advanced fatigue stopped working as soon as this mod loaded.** Every whitelisted animation
  name was pushed into `ace_advanced_fatigue_setAnimExclusions`. That is not a list of animations -
  it is a list of claim tags, and ACE only ever asks whether it is empty. A list that never emptied
  meant ACE left `setAnimSpeedCoef` alone for the rest of the mission, so its exhaustion slowdown
  and its reset to default were both silently dead. One tag goes in now while this mod is actually
  driving the speed, and comes back out when it is not. *(reported by Pixelated_Grunt on Discord,
  with a video, on a server running ACE advanced fatigue)*

- **The custom display only showed the first change.** Every key press cut a fresh title onto the
  layer, which tore down the display the number was about to be written into - so the second change
  and every one after it blanked the value instead of updating it, until the title timed out and
  the next press worked again. *(reported by Pat, malice20191 and A. Ares on Discord)*

- **Speed reverted a moment after being set in some missions.** Ravage, Hetman and Hive drive the
  animation speed from their own loop, and whoever writes it last wins. See *Reapply Speed If
  Overwritten* above. *(reported by HBAOplus, vat hom flaffie and rodrockwell)*

- **Audibility was never given back.** Turning the speed down set `audibleCoef` and nothing ever
  reset it, so the reduced value stayed on the unit after leaving the animation. It was also set
  locally, where the AI doing the listening usually is not. *(reported by dyolF)*

- **Force walk could be lost while a reduced speed was still set.** It was set from the keybind and
  cleared by the animation handler, so the two undid each other on the next animation change. It
  hangs off the walk speed alone now, decided in one place. *(reported by dyolF, and by A. Ares on
  Discord, who could not get back to a tactical pace until the speed was at 100% again)*

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

- **Stance keys did nothing during an autorun, and left the indicator lying.** Four things at
  once: the handler watched `MoveUp` and `MoveDown`, which ship unbound, while the stance keys are
  `Stand`, `Crouch` and `Prone`; the transition animation it built - `<from>_<to>` - exists for no
  pair the run can produce; the pinned animation was returned before the stance was ever read; and
  nothing compared the animation against the unit, so once the engine took it away the run was
  dead while the indicator carried on. A run now heals itself on the next tick whatever takes the
  animation, which also covers other mods and scripted sequences.
- **The speed keys wrote to the wrong unit under Zeus remote control.** They used `player`, which
  parts company with the unit actually being driven - so a speed set while controlling a puppet
  did nothing to it and landed on the player's own body instead, showing up the moment control was
  handed back. They follow the controlled unit now, the same one CBA's own player event handler
  watches. Taking over also hides the speed displays, since each body keeps its own speeds.
- **A sequence of three played only the first and the last.** The transition the game walks
  through between two animations finishes too, and fires the same event the sequence was counting
  - so every transition ate an entry. Only the animation the sequence actually asked for advances
  it now.
- **The autorun and an animation key could both drive the unit at once.** Whichever started
  second fought the first for the animation. They refuse each other, and say why.
- **A sequence flickered through a third animation between its own two.** Both `playMove` and
  `playMoveNow` follow the game's transition graph, and between two walk animations that route
  runs through the connected idle - which is the animation that kept appearing. The sequence
  watches the animation state instead and puts the next one on with `switchMove`, which takes no
  transition at all.
- **The autorun sat still while sitting.** Dropping from a crouch towards prone puts the
  character in the game's sit state, which has no pinned animation set - so it borrowed the
  standing one and pinned a standing animation onto someone sitting down. It resolves its own
  now, which is the shuffle forward the game has for exactly that state.
- **The autorun stopped at the water's edge.** The weapon segment kept saying rifle once the
  swim started, and plain swimming has no rifle animations at all - only the three diving actions
  do, and those want a wetsuit. The name built did not exist, the fallback had nowhere to go, and
  the run halted.
- **The autorun sprinted on a broken leg.** It read the engine's leg hitpoint, which ACE leaves
  alone; ACE keeps fractures of its own. A fractured leg limits the run the same way it limits
  everything else.
- **Switching the speed groups off switched off more than the groups.** Per-animation speeds and
  Debug are their own category and keep working - that switch is the three groups, their keys and
  their displays.
- **The first speed set brought all three displays up at once**, each announcing it was at 100%.
  A group that has never shown anything and is still at default has nothing to say.
- **The walk and tactical displays came and went together.** Every change redrew all three, which
  restarted all three hide timers - so changing the walk speed kept the tactical display up for
  exactly as long, and simply walking brought it up saying nothing. Each is only touched when
  what it would say has changed.
- **The custom range grew as you pushed against it.** It was anchored to the speed currently in
  force, which is the value the keys were moving, so the ceiling ran away ahead of them. It is
  anchored to the animation's own speed, which does not move.
- **A group's display showed values that were not its own.** A change from anywhere redrew every
  group. Each one answers for its own group now, and only while that group is off default.
- **A speed set per animation did not reach the display.** It was only redrawn on a key press, so
  a sequence stepping through animations with different speeds left the display showing the one
  before. It follows the applied value now, and an animation that is in no group - swimming, a
  ladder - is shown on the custom display rather than nowhere.
- **An animation key would walk you into the sea.** Land animations do not stop at the waterline
  and the engine plays what it is told, so a slot now refuses to start in water and ends when it
  reaches it.
- **The animation keys stuttered every few metres.** The sequence was driven by a poll, which
  only notices an animation has ended a tick late - and in that gap the engine has already
  dropped the unit into a standing idle. It runs off `AnimDone` now, the same as the autorun.
- **Speed flickered back to default under Zeus remote control.** ACE's advanced fatigue was never
  told to keep its hands off, because the claim was made only for `player` - which is not the
  unit being driven. ACE reset the coefficient, the reapply loop put it back, once a second.
- **The debug list never appeared**, though the clipboard was right. `reverse` turns an array
  round in place and hands back nothing at all, so the list being iterated was nothing. Placing a
  single entry in the colour ramp also divided by zero, since SQF works out both sides of a
  `select` before it picks one.
- **Half the walking animations were never covered.** The built-in lists held the rifle and
  handgun sets and nothing else: no launcher, no binoculars, no unarmed, and the plain lowered
  erect rifle walk only ever shipped as its `_ver2` twin. Walking went from 64 of the game's 128
  to all 128, tactical from 64 of 88 to all 88 - taken from the config rather than typed, and
  checked back against it.
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
- **Settings are split by feature into `AWSR - Autorun`, `AWSR - Adjustable Walk Speed` and
  `AWSR - Animation Adjustment`**, rather than by whether a setting draws something. Autorun and
  Walking each used to appear twice, on two different pages; a group's speed and its display now
  sit in one place. No value is lost: CBA stores a setting under its own name, never under its
  category.
- Every display lines up with Arma's own stance indicator by default, and is as wide as it, and starts clear of the
  vanilla interface. The artwork keeps its aspect inside the box, and the box is the one the
  layout tab saved rather than a square worked out from its width - the two used to disagree,
  which is what made the layout tab look wrong.
- **Debug redraws on a loop as well as on an animation change**, so the speed on it keeps up -
  the speed moves while the animation stays the same, which is the whole point of the mod. It
  also reports after the speed has been applied rather than before, so the number on it is the
  one in force and not the one from the animation before.
- **Debug reads as something you can hand to someone else**: a header, what Debug collected, what
  the six segments of an animation name mean with a worked example, the list newest first in the
  capitalisation the config uses rather than the lowercase the game reports, and a footer. The
  whole block goes to the clipboard.
- **Text sizes read as percentages**, 100% being normal.
- **Debug is a server setting** and says `AWSR DEBUG` on the hint, so nobody wonders whose it is
  or turns it on mid mission - it draws on every animation change. It also shows the speed being
  applied and which group the animation belongs to.
- Autorun animation settings are named `Stance - Pace (Weapon)` throughout, so the rifle set says
  it is the rifle set.
- Debug and Per-Animation Speeds have sub-categories of their own rather than sitting in General.
- The debug list runs newest-green to oldest-red, so which end you are reading takes a glance
  rather than a count.
- Keybind headings lost their numbers, and General moved in with the speed keys.
- The three speed groups share one keybind heading instead of one each, so the menu reads as the
  three things the mod does rather than as five sections you have to know apart.
- Ladders and swimming are filled into Per-Animation Speeds at 1, ready to be changed.

### Known and not changed

- **Force walk stays exclusive to the walk group.** Applying it from the tactical group would
  switch the player into a walk animation, which is the group they just left.
  *(asked for by A. Ares and nigel)*
- **AI are not affected.** The mod only ever touches the player's own unit.

### Thanks

To everyone who reported something, sat in a voice channel to show it, or recorded it: Pat,
malice20191, dyolF, HBAOplus, vat hom flaffie, rodrockwell, SSG, QWRT0987, 42nfl19, nigel,
A. Ares, Pixelated_Grunt and Scarecrow1625.

And to Leon (LeonZ) and Legion for [Autorun Rework](https://github.com/LeonZ2019/autorun-rework),
which the autorun here is derived from and which stays under APL-SA.
