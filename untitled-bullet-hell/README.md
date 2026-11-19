# Untitled Bullet Hell

A Godot 4 top-down boss-fight prototype about reading attack patterns, dodging, and fighting back with a magical staff.

The project is in an early playable-prototype stage. The first original pixel-art visual slice is in `assets/pixel/`; these are prototype sprites, not final production art. The direction aims for characterful pixel art with a darker fantasy mood, bold silhouettes, readable projectiles, and detailed rooms. Enter the Gungeon is a reference for clarity and polish, not a source of assets or designs. The proposed boss roster is in [docs/BOSS_ROSTER.md](docs/BOSS_ROSTER.md).

## Requirements

- Godot 4.7 or a compatible newer Godot 4 release

## Run the prototype

1. Open this folder in the Godot Project Manager, or import `project.godot`.
2. Open `scenes/main.tscn` if it is not already open.
3. Press **F6** to run the current scene or **F5** to run the project.

## Validate the visual slice

Run the lightweight Godot smoke test from a terminal:

```powershell
& "C:\Program Files\Godot\Godot_console.exe" --path . --headless --script res://tools/visual_slice_smoke_test.gd
```

Regenerate the original prototype sprites with `res://tools/generate_visual_slice.gd` if you edit their source drawing.

## Controls

| Input | Action |
| --- | --- |
| WASD | Move |
| Mouse | Aim |
| Hold Left Mouse Button | Fire the staff (about 3 shots per second) |
| Space | Dash |
| Q or Right Mouse Button | Use the current prototype ability |
| R | Restart the encounter |

## Prototype features

- One arena and a first Rimebound Warden visual prototype.
- A player health bar and boss health bar.
- A steady staff attack and a five-shot spread ability.
- Three telegraphed boss patterns: a repeated aimed fan, a ring with a gap, and a rotating spiral.
- A faster, denser boss phase below half health.
- Hit sparks, a short dash afterimage, and brief hit-stop on successful hits.
- A boss defeat dissolve and a choice between an active Frost Blast or passive Frost Resistance.
- After choosing, the boss automatically returns for a rematch so the selected reward can be tested without restarting.
- Original pixel-art sprites for the player, Warden, staff, floor/wall tiles, projectiles, ice crystals, broken pillars, and rubble. Some transient effects and the UI are still drawn by code and need a later consistency pass.

## Project map

- `scenes/` - Godot scenes.
- `scripts/` - Gameplay, visuals, and prototype logic.
- `assets/` - Art and other imported assets.
- `resources/` - Godot resources.
- [ROADMAP.md](ROADMAP.md) - Planned development steps.
- [CHANGELOG.md](CHANGELOG.md) - Notable project changes.
- [docs/GAMEPLAY.md](docs/GAMEPLAY.md) - Current controls, combat, and boss-pattern notes.
- [docs/BOSS_ROSTER.md](docs/BOSS_ROSTER.md) - Proposed stage-based boss lineup and encounter hooks.
- `tools/generate_visual_slice.gd` - Rebuilds the prototype PNG art assets.
- `tools/visual_slice_smoke_test.gd` - Checks sprite integration and frost-hit slow.

## Scope and art direction

The project is a boss-focused action prototype, not a room-by-room dungeon crawler. Combat readability and distinct boss behavior take priority over adding large numbers of ordinary enemies or rooms. See [docs/GAMEPLAY.md](docs/GAMEPLAY.md) for the current prototype behavior.
