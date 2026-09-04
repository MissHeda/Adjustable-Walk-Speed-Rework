# Adjustable Walk Speed - Rework
<p align="center">
    This mod allows you to change the animation speed for any animation (including custom ones)
    in Arma 3. While being mainly made as a rework for adjusting the walking speed it now provides
    you with the functionality to whitelist any animation you want and set its speed.
    It works with and without ACE 3.
</p>

<p align="center">
    <sup><strong>Download latest release on <a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3235153536">Steam</a><br/>
    Visit us on <a href="https://discord.gg/Jud6gyzFYx">Discord</a></strong></sup>
</p>

## Addons

| PBO | What it is |
| --- | --- |
| `awsr_main` | Version numbers and the macros every other addon builds on. No gameplay code. |
| `awsr_awsr` | Everything the mod does: speed adjustment, autorun, settings, keybinds, IGUI. |

## Speed adjustment

- Walk animation group speed (raised weapon only)
- Tactical animation group speed (raised weapon only)
- Custom animation group speed (by default empty)
- Saves & reapplies the set speed for the animation
- Ace compatible (auto resets your speed to default when you are exaused)
- Works as client-side only (server can override this)
- CBA keybinds (keybinds for animation groups & more)
- CBA options (functionality things like min / max speed)
- CBA IGUI options (settings for speed change display, including how long it stays up)
- Custom IGUI (can be resized in the layout tab from Arma)
- Puts the speed back when a mission or another mod overwrites it

## Whitelisting animations

Each animation group has a whitelist box in the CBA settings. Type animation names separated
by commas - capitalisation does not matter, and the change applies without a restart:

```
melee_armed_walkf, melee_armed_walkb, Rotary_Proper_Walk
```

An entry may contain `*` as a wildcard, which saves listing a mod's animations one by one:

```
melee_armed_*, Rotary_Proper_Walk*
```

The blacklist box takes the same syntax and removes animations from the group again, wildcards
included.

## Autorun

Walk, jog or run without holding the key, with the stance and the animation kept in step
with stamina, terrain, water and injuries.

- Separate keys for auto walk, auto jog and auto run
- Stance switching while running, by key or automatically in deep water
- Swimming, diving and the way back onto land
- A stop key, or any key when none is bound; keys you bind as "Ignored Key" (map, compass,
  watch) leave the run alone
- Can be switched off entirely in the CBA settings

- Walk, jog and run as three paces, with one key pair to step up and down through them
- Keeps the animation in step with stamina, terrain, water, stance and injuries
- Shows the pace in a display you place yourself
- Each pace can be pinned to an animation of your own, one set for a rifle and one for a handgun

The keys are in the CBA keybind menu next to the speed keys, under **Autorun**:

| Action | Default |
| --- | --- |
| Walk | `F5` |
| Jog | `F6` |
| Run | `F7` |
| One pace faster | `Ctrl + W` |
| One pace slower (ends the run below a walk) | `Ctrl + S` |

A run ends by pressing the pace key it is already on, by stepping below a walk, or by reaching
for a movement key - which then does what it normally does. Faster and slower only do anything
while a run is going, so those keys stay free for everything else the rest of the time.

## Bug Report

- [GitHub issues](https://github.com/MissHeda/Adjustable-Walk-Speed-Rework/issues)
- [Discord](https://discord.gg/Jud6gyzFYx)

Changes per version are in [CHANGELOG.md](CHANGELOG.md).

## Requirements

- [CBA_A3 v3.17.1.240424 or later](https://steamcommunity.com/sharedfiles/filedetails/?id=450814997)

## Building

[HEMTT](https://github.com/BrettMayson/HEMTT) 1.11.2:

```
hemtt check     # config and SQF checks, same thing CI runs
hemtt build     # unsigned PBOs in .hemttout/build
hemtt launch    # start Arma with the mod and CBA/ACE loaded
```

## Big thanks to

- Rad
- Leon (leonz2019) and Legion, for [Autorun Rework](https://github.com/LeonZ2019/autorun-rework),
  which the autorun part is derived from. That part stays under APL-SA - see
  [addons/awsr/LICENSE_autorun.txt](addons/awsr/LICENSE_autorun.txt).

## Note from the current Developers
- Currently there is no active development on this mod.
- Feel free to request features.
