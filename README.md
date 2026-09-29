# kbplay

A Balatro mod that makes the entire game playable from the keyboard, with no mouse required.

## Installation

kbplay requires [Lovely](https://github.com/ethangreen-dev/lovely-injector). Steamodded is supported but not required.

1. Install Lovely by following its instructions.
2. Download or clone this repository into `%AppData%\Balatro\Mods\kbplay`.
3. Launch the game. The Lovely console shows `[kbplay] loaded` once the mod is active.

### Development setup

Link the repository into the Mods folder with a directory junction, so every change is picked up on the next game launch:

```bat
mklink /J "%AppData%\Balatro\Mods\kbplay" "C:\path\to\balatro-kbplay"
```

## Controls

Each screen is divided into **zones**: hand, jokers, consumables, shop and booster pack. `Tab` moves focus between zones, and the number keys select cards within the focused zone.

| Key | Action |
|---|---|
| `1`–`9`, `0` | Select or deselect the Nth card in the focused zone |
| `Tab` / `Shift+Tab` | Focus the next / previous zone |
| `Enter` | Primary action: play hand, select blind, cash out, buy, use, or pick from a pack |
| `Shift+Enter` | Buy and use (consumables in the shop) |
| `D` | Discard |
| `Delete` | Sell the selected joker or consumable |
| `Backspace` | Deselect all |
| `Shift+←` / `Shift+→` | Move the selected card left / right |
| `Z` / `X` | Sort hand by rank / suit |
| `K` | Skip blind / skip booster pack |
| `R` | Reroll shop / reroll boss blind |
| `N` | Leave the shop and continue to the next round |
| `V` (tap) | Open / close the full deck view |
| `V` (hold) | While choosing a hand, show a summary of the cards left in the deck until released |

`Esc` and all menus keep their default behavior.

> **Note:** tap `R` rather than holding it. Holding `R` restarts the run in the base game.

### Custom keybinds

Any keybind can be changed without editing the mod. Create `%AppData%\Balatro\kbplay-keys.lua` and return the actions to override:

```lua
return {
  discard = "q",
  sell = "ctrl+backspace",
  sort_suit = false, -- disables the action
}
```

Available action names are listed in [`src/keymap.lua`](src/keymap.lua). Key names follow [LÖVE's KeyConstant](https://love2d.org/wiki/KeyConstant), and modifiers are written as `ctrl+`, `alt+` and `shift+`.

## Architecture

| Path | Responsibility |
|---|---|
| [`lovely/`](lovely) | Registers the files in `src/` as Lua modules and loads the mod right after `G = Game()` |
| [`src/init.lua`](src/init.lua) | Wraps `Controller:key_press_update`. Bound keys are handled by the mod; all others pass through to the game |
| [`src/states.lua`](src/states.lua) | Maps each game screen (`G.STATE`) to its zones and available actions |
| [`src/actions.lua`](src/actions.lua) | Game actions: playing, discarding, buying, selling, rerolling and more |
| [`src/zones.lua`](src/zones.lua) | Card zones: selection, tooltips and reordering |
| [`src/ui.lua`](src/ui.lua) | Presses the game's own UI buttons |
| [`src/keymap.lua`](src/keymap.lua) | Default keybinds and user overrides |

### Design principles

- **The game stays authoritative.** Instead of reimplementing game rules, kbplay presses the same buttons the mouse would, and only when the game has them enabled. Costs, boss blind effects, input locks and other mods' changes are respected automatically.
- **Failures are contained.** Errors raised inside the mod are written to the Lovely console, and the key press is forwarded to the game, so a bug never crashes a run.

## Credits

Inspired by [Typist](https://github.com/kasimeka/balatro-typist-mod) by kasimeka. kbplay is an independent implementation and does not reuse its code.

## License

[MIT](LICENSE)
