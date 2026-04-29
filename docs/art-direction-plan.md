# Art Direction Plan: Lab Escape Theme

## Context
Transform ChemBond Adventure's visual identity into a **"scientist trapped in a hazardous chemical laboratory"** escape scenario. The player is a scientist who must collect the exact chemical elements to synthesize compounds and unlock the emergency exit. All visual sprite assets will be regenerated using PixelLab AI, character animations will be wired into Godot, and minor code/shader tweaks will reinforce the theme.

**Preview assets already generated and approved:**
- Scientist character: `96105254-4d27-495a-98c6-61df38902d5b` (walk animation complete)
- Element orb: `0ebb05ee-3901-4e7c-bd5c-4ce4736512df`

---

## Visual Direction

### Mood & Palette
- **Setting**: Abandoned / dangerous chemical research lab — dark corridors, metal walls, glowing chemicals
- **Tone**: Tense, industrial, slightly eerie — like a facility on lockdown
- **Colors**:
  - Floors: Dark grey concrete / metal grating with faint grid lines
  - Walls: Reinforced steel panels with pipes and rivets
  - Elements: Glowing neon vials (color-tinted by existing code — cyan H, red O, etc.)
  - Gate locked: Red emergency warning lights, heavy blast door
  - Gate open: Green EXIT signage, blast door raised
  - Vignette tint: Shift from blue `(0.05, 0.05, 0.15)` → dark red `(0.15, 0.03, 0.03)`

---

## Phase 1 — Asset Generation (PixelLab)

### Character (reuse approved preview)
**Character ID:** `96105254-4d27-495a-98c6-61df38902d5b`

Queue these additional animations via `animate_character`:

| Animation ID | Template | Description |
|---|---|---|
| `breathing-idle` | breathing-idle | Scientist standing still, slight breathe |
| `picking-up` | picking-up | Bending down to collect element |
| `running-4-frames` | running-4-frames | Sprinting to exit when gate opens |

Walk animation already complete (all 4 directions).

**Download:** `curl --fail -o scientist.zip "https://api.pixellab.ai/mcp/characters/96105254-4d27-495a-98c6-61df38902d5b/download"`

---

### Map Objects to Generate

| Asset | File | Size | Prompt |
|---|---|---|---|
| Element orb | `assets/sprites/element.png` | 32×32 | Already done — `0ebb05ee-3901-4e7c-bd5c-4ce4736512df` |
| Gate locked | `assets/sprites/gate_locked.png` | 32×32 | "top-down heavy steel blast door, red warning light bar across top, yellow hazard stripes, dark metal, pixel art" |
| Gate open | `assets/sprites/gate_open.png` | 32×32 | "top-down blast door raised open, bright green EXIT light, glowing green frame, dark metal, pixel art" |
| Joystick base | `assets/sprites/joystick_base.png` | 64×64 | "circular dark metal control panel base, subtle grid markings, industrial style, pixel art" |
| Joystick handle | `assets/sprites/joystick_handle.png` | 32×32 | "small round yellow control knob, top-down view, pixel art" |

---

### Tileset
Use `create_topdown_tileset` with `tile_size: {width: 16, height: 16}`:
- `lower_description`: "dark concrete lab floor with subtle tile grid lines and faint scuff marks"
- `upper_description`: "reinforced metal wall panel with rivets, pipes and conduit"
- `shading`: "medium shading"
- `outline`: "single color outline"
- `detail`: "highly detailed"

Returns Wang tileset (16 tiles). From these, identify:
- Pure floor tile (all-lower) → slot 0 in tileset strip
- Pure wall tile (all-upper) → slot 1

---

## Phase 2 — Godot Asset Integration

### Sprite Files
All map objects (32×32) replace existing 16×16 sprites. Scale fix needed:
- `element_pickup.gd`: `$Sprite2D.scale = Vector2(0.5, 0.5)` in `_ready()`
- `exit_gate.gd`: `$Sprite2D.scale = Vector2(0.5, 0.5)` in `_ready()`

### Character Spritesheet Assembly
PixelLab ZIP contains individual PNGs per direction per frame. Import workflow:
1. Download and unzip `scientist.zip` into `assets/sprites/scientist/`
2. Directory structure from zip: `{animation}/{direction}/{frame}.png`
3. Create `assets/sprites/scientist.tres` (SpriteFrames resource) in Godot
4. Add animations: `idle`, `walk_south`, `walk_north`, `walk_east`, `walk_west`, `collect`, `run_south`, `run_north`, `run_east`, `run_west`
5. FPS: walk=8, idle=4, collect=12, run=10

### `scenes/player.tscn` changes
- Replace `Sprite2D` node → `AnimatedSprite2D`
- Assign `scientist.tres` as `sprite_frames`
- Default animation: `idle`

---

## Phase 3 — Code Changes

### `scripts/player.gd`
Add animation state machine — switch animation based on velocity and events:

```gdscript
# In _physics_process after move_and_slide():
var anim_node = $AnimatedSprite2D
if velocity.length() > 0:
    var dir = _get_direction_name(velocity)
    var anim = "walk_" + dir
    if anim_node.animation != anim:
        anim_node.play(anim)
else:
    if anim_node.animation != "idle":
        anim_node.play("idle")

func _get_direction_name(vel: Vector2) -> String:
    if abs(vel.x) > abs(vel.y):
        return "east" if vel.x > 0 else "west"
    return "south" if vel.y > 0 else "north"
```

Add collect animation trigger in `_on_element_collected()`:
```gdscript
$AnimatedSprite2D.play("collect")
await $AnimatedSprite2D.animation_finished
$AnimatedSprite2D.play("idle")
```

Add run trigger — expose `set_running(bool)` method, called from `main.gd` when gate opens.

### `scripts/element_pickup.gd`
```gdscript
func _ready():
    $Sprite2D.scale = Vector2(0.5, 0.5)
    # rest of existing _ready code
```

### `scripts/exit_gate.gd`
```gdscript
func _ready():
    $Sprite2D.scale = Vector2(0.5, 0.5)
    # rest of existing _ready code
```

### `scripts/main.gd`
Change vignette shader tint in `setup_vignette()`:
```gdscript
# Change from:
mat.set_shader_parameter("tint_color", Color(0.05, 0.05, 0.15, 1.0))
# To:
mat.set_shader_parameter("tint_color", Color(0.15, 0.03, 0.03, 1.0))
```

When exit gate opens, trigger run animation on player:
```gdscript
# In _on_exit_reached(), before showing overlay:
var player = current_maze.get_node_or_null("Player")
if player: player.set_running(true)
```

### `assets/tileset.tres`
Update to use generated Wang tileset PNG. If Wang autotiling is adopted:
- Set up terrain set 0 with 2 terrains (floor, wall)
- `maze_manager.gd`: replace `set_cell()` calls with `set_cells_terrain_connect()`

---

## Phase 4 — Shader & UI Polish

### Vignette color
`main.gd → setup_vignette()`: tint → `Color(0.15, 0.03, 0.03)` (dark red)

### HUD border accent
`main.gd → _ready()`: navbar border color → `Color(0.5, 0.0, 0.0, 0.4)` (red emergency)

### Glow shader on elements
`assets/shaders/glow.gdshader`: change default `glow_color` → `(0.0, 1.0, 0.8, 0.7)` teal-green for lab chemical feel, increase `pulse_speed` from `2.0` → `3.0`

---

## Execution Order

1. Queue remaining PixelLab animations (idle, picking-up, running) on approved character
2. Generate gate locked + gate open map objects (parallel)
3. Generate joystick sprites (parallel)
4. Start tileset generation (~100s async)
5. Download all completed assets, place in repo
6. Update `player.tscn` + `player.gd` for AnimatedSprite2D + state machine
7. Fix sprite scale in `element_pickup.gd` + `exit_gate.gd`
8. Update `tileset.tres` with new Wang tileset
9. Apply shader/HUD color tweaks in `main.gd`
10. Test via `mcp__godot__run_project`
11. Commit + push to GitHub

---

## Verification
1. Run game via `mcp__godot__run_project`
2. Player scientist sprite shows correct direction when moving (walk_south/north/east/west)
3. Idle animation plays when standing still
4. Collect animation triggers on element pickup
5. Run animation plays when exit gate opens
6. Element pickups render at correct size with glow + color tint
7. Gate locked (red) → gate open (green) transition visible
8. Lab tileset floors and walls render correctly in maze
9. Vignette has red tint, HUD has red border
10. Push final assets + code to GitHub: `https://github.com/marshal-rizky/Chemistry-Maze`

---

## Files Modified Summary

| File | Change |
|---|---|
| `assets/sprites/player.png` | Replaced with scientist spritesheet (or folder) |
| `assets/sprites/element.png` | Replaced with glowing orb |
| `assets/sprites/gate_locked.png` | Replaced with blast door locked |
| `assets/sprites/gate_open.png` | Replaced with blast door open |
| `assets/sprites/joystick_base.png` | Replaced with metal panel |
| `assets/sprites/joystick_handle.png` | Replaced with control knob |
| `assets/tiles.png` | Replaced with lab Wang tileset |
| `assets/tileset.tres` | Updated for Wang terrain |
| `assets/sprites/scientist/` | New folder — animation frames from PixelLab ZIP |
| `assets/sprites/scientist.tres` | New — SpriteFrames resource |
| `scenes/player.tscn` | Sprite2D → AnimatedSprite2D |
| `scripts/player.gd` | Animation state machine added |
| `scripts/element_pickup.gd` | Sprite scale fix |
| `scripts/exit_gate.gd` | Sprite scale fix |
| `scripts/main.gd` | Vignette tint + run trigger |
| `assets/shaders/glow.gdshader` | Glow color + pulse speed tweak |
