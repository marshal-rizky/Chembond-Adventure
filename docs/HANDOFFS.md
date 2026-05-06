# ChemBond Adventure — Handoff Doc
**Last updated:** 2026-05-06

---

## What It Is

Top-down 2D chemistry maze game. Player navigates pixel-art ASCII maze, collects exact element atoms to form a molecule, exits through the gate. Gate opens **only** on exact inventory match — wrong atoms lock it.

**Engine:** Godot 4.6 · **Language:** GDScript · **Platform:** Desktop + touch

---

## Three Modes

| Mode | Description |
|---|---|
| **Normal** | 10 levels (H₂O → CH₃COOH). 20×15 maze, 3× scale. Decoy count scales with level. |
| **Tutorial** | H₂O only. Gated 5-step interactive tutorial — atoms glow, decoy warning on wrong pick. |
| **Legend** | 3 ultra-hard levels (Glucose, Ca-Phosphate, Al-Sulfate). 30×20 maze, 2× scale. Dual-player mirror mechanic — right player mirrors left's x-axis input. Both must reach center gate together. |

---

## Architecture

- **Autoloads:** `GameManager` (level/mode state flags) · `AudioManager` (sfx + music)
- **Entry:** `main_menu.tscn` → `main.tscn` (spawns everything at runtime)
- **Maze:** ASCII layouts in `maze_manager.gd`, parsed to TileMapLayer + StaticBody2D walls at load
- **Pathfinding:** BFS in `level_generator.gd` — validates spawn plans, ensures solvability
- **Signals:** `element.collected` → `player.collected_signal` → `main._on_player_collected` → `gate.check_requirements`

---

## Visual Identity

**Theme:** Abandoned chemical lab on lockdown. System Shock / Alien aesthetic.

**Palette:** Deep navy `#070b14` · teal accent `#14b8a6` · teal-hi `#5eead4` · text `#cfeae6`

**Player:** Scientist character (PixelLab AI `96105254-4d27-495a-98c6-61df38902d5b`), 48×48 frames, 4 directions × idle/walk/run/collect animations via `scientist.tres` SpriteFrames.

**Tileset:** Wang tileset `assets/tiles_wang.png` — wall at cell (0,3), floor at (2,1).

**Font:** Pixelify Sans (`assets/fonts/PixelifySans-Regular.ttf`), loaded via `UITheme.create_game_theme()`.

---

## Current State (2026-05-06)

**Completed and shipped:**
- All 10 normal levels + tutorial + 3 legend levels — fully playable
- Tutorial interactivity — gated steps, atom glow highlight, decoy warning
- Visual polish pass — Pixelify Sans font, grid shader on menu, atom orb sprite, HUD button icons (↺ ✕ →), main menu logo row + colored dot particles
- Scientist AnimatedSprite with directional walk/run/idle/collect animations
- Vignette shader (dark red tint), screen shake, trail particles

**In progress / next up:**
- Element pickup hex chip redesign (orb → pixel-art hexagon via `_draw()`)
- Main menu dense ghost element symbols (high-volume faint drifting)
- Tutorial panel HUD restyle (step dots, styled OK button, dark bg)

**Known issues:**
- `legend_unlocked = true` hardcoded — should gate behind level 9 completion before shipping
- Legend maze layouts may need BFS tuning — atom split by x<15 / x≥15 can leave one side sparse

---

## Key Files

| File | Purpose |
|---|---|
| `CLAUDE.md` | Canonical architecture ref — node paths, audio keys, conventions |
| `assets/questions.json` | All 13 level questions (10 normal + 3 legend, `"legend": true`) |
| `scripts/game_manager.gd` | Mode flags: `is_tutorial`, `is_legend_mode`, `legend_level` |
| `scripts/maze_manager.gd` | All ASCII maze layouts + load functions + spawn validation |
| `scripts/level_generator.gd` | Static BFS helpers |
| `scripts/player.gd` | Movement, collection, animation state machine, mirror input |
| `scripts/tutorial_manager.gd` | 5-step gated tutorial sequence |
| `scripts/ui_theme.gd` | Color constants + `create_game_theme()` |
| `design/art-spec.md` | Pixel art asset specs (sizes, palette, delivery format) |

---

## Future Plans

- Gate Legend mode behind level 9 completion (`legend_unlocked` flag)
- Sound design pass — current SFX are placeholders
- Mobile export — touch input already wired via virtual joystick
- Leaderboard / time tracking per level (no backend yet)
- Additional legend levels (3 → 5+)
