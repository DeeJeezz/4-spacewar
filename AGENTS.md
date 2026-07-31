# 4-spacewar

Godot 4.8 / GL Compatibility — 2D two-player spacewar game.

## Setup

- Python 3.11 venv at `.venv/`. Activate before running pre-commit or tooling.
- Pre-commit hooks: `gdscript-formatter` (max-line-length=120, reorders code) + `gdlint` (config in `gdlintrc`).

## Commands

```bash
pre-commit run --all-files   # format + lint all GDScript
pre-commit run gdlint         # lint only
```

No test, build, or dev-server commands. Open the project in Godot editor to run.

Godot editor binary: `/Applications/Godot.app/Contents/MacOS/Godot` — run a scene with `--path .` from the project root.

After any change to a scene (`.tscn`) or its scripts, launch that scene in the Godot editor and verify it runs without errors.

Keep this file in sync with the project — whenever the architecture changes (new/renamed scenes, scripts, autoloads, or signals), update `AGENTS.md` as part of the same change.

## Architecture

`run/main_scene` is `scenes/main/main.tscn` — the persistent root.

| Path | Role |
|---|---|
| `scenes/main/main.gd` | Root scene manager — swaps the current screen (`_set_scene()`); preloads `menu.tscn`, `game.tscn`, and `victory.tscn`; connects the game's `game_over` to the victory screen |
| `scenes/menu/menu.gd` | `MainMenu` (Control) — emits `play_pressed` / `quit_pressed`; buttons `%PlayButton`, `%QuitButton` |
| `scenes/game/game.gd` | `GameScene` — root script of `game.tscn`; forwards `game_over(winner_player_index, winner_score)` from `RespawnManager` to `Main` |
| `scripts/autoload/game.gd` | Autoload singleton providing `Game.SCREEN_SIZE` — the content-space size (`get_visible_rect().size`), set once in `_ready` |
| `scripts/components/wrapped.gd` | `Wrapped` component — screen-wrap child for any Node2D |
| `scenes/player/player.gd` | `Player` ship (CharacterBody2D) — thrust, rotation, fire; hides on death and `respawn(spawn_position)` restores it |
| `scenes/player/hurtbox.gd` | `Hurtbox` — emits `damage_received(amount, attacker_player_index)` on bullet hit, `ship_collided` on ship collision |
| `scenes/player/health.gd` | `Health` component — HP, listens to `Hurtbox` signals, emits `died(attacker_player_index)` when killed; `kill()` emits index `0` (collision scores nobody); `reset()` restores full HP |
| `scenes/bullet/bullet.gd` | `Bullet` with speed and TTL; carries `owner_player_index` of the shooter |
| `scenes/game/star.gd` | `Star` — orbital gravity (wrap-aware offset); public `apply_initial_radial_velocity(player)` applies an initial orbital velocity |
| `scenes/game/score_manager.gd` | `ScoreManager` — child of the `Game` root; listens to both players' `Hurtbox`/`Health`, +50 per hit (`HIT_POINTS`), +150 per kill (`KILL_POINTS`); emits `score_changed(player_index, score)` |
| `scenes/game/respawn_manager.gd` | `RespawnManager` — child of the `Game` root; gives each player `INITIAL_RESPAWNS` (3); respawns a player at the screen periphery after `RESPAWN_DELAY` (3 s) and re-applies the star's initial radial velocity; emits `respawns_changed(player_index, respawns_left)` on each count change and `game_over(winner_player_index, winner_score)` when a player runs out of respawns |
| `scenes/game/ui_manager.gd` | `UIManager` (CanvasLayer) — child of the `Game` root; renders scores into `%P1ScoreLabel` (top-left) / `%P2ScoreLabel` (top-right) and remaining respawns into `%P1RespawnsLabel` / `%P2RespawnsLabel` (each with an icon `TextureRect` placeholder) |
| `scenes/victory/victory.gd` | `VictoryScreen` (Control) — `setup(winner_index, score)` fills labels; buttons `%RestartButton` / `%MenuButton` emit `restart_pressed` / `menu_pressed` |

`menu.tscn` / `game.tscn` / `victory.tscn` are children of `Main` that get swapped — never instantiated as the main scene.

## Input (no Input Map — actions defined in `project.godot`)

| Action | P1 | P2 |
|---|---|---|
| `p%d_thrust` | W | Up |
| `p%d_rotate_left` | A | Left |
| `p%d_rotate_right` | D | Right |
| `p%d_shoot` | S | Down |

Player index is `@export_enum("LEFT:1", "RIGHT:2")` — set to 1 or 2 in the scene.

## GDScript conventions

- Tabs for indentation (`tab-characters: 1` in gdlintrc)
- Max line length 120
- Naming patterns in `gdlintrc` — snake_case for functions/vars, PascalCase for classes/enums, UPPER_CASE for constants
- Class member order defined in `gdlintrc` (tools → classnames → extends → docstrings → signals → enums → consts → staticvars → exports → pubvars → prvvars → onreadypubvars → onreadyprvvars → others)
- Don't use `StringName` where the documentation doesn't require it. Use the `StringName` type only for Input action names and animation names.

## Gotchas

- `2d/default_gravity=0.0` — no built-in gravity. All gravity comes from `Star` nodes.
- Bullets are added to `get_parent()` — the `Game` scene root (not as children of the player). `get_tree().current_scene` is always `Main`, not the game.
- Player velocity is capped to 50 via `limit_length`.
- `Wrapped` component reads `Game.SCREEN_SIZE` from the autoload singleton.
- `Game.SCREEN_SIZE` is in content space (`get_visible_rect().size`); the autoload skips updating it under the headless display server, so headless tests must set it manually (it stays `(0, 0)`).
