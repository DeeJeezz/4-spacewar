# 4-spacewar

Godot 4.8 / GL Compatibility — 2D two-player spacewar game.

## Setup

- Python 3.11 venv at `.venv/`. Activate before running pre-commit or tooling.
- Pre-commit hooks: `gdscript-formatter` (max-line-length=120, reorders code) + `gdlint` (config in `gdlintrc`).

## Commands

```bash
pre-commit run --all-files   # format + lint all GDScript
pre-commit run gdlint         # lint only
./run_tests.sh                # headless test suite
```

Don't read test files without necessity — only consult `tests/test_*.gd` when modifying tests or investigating a failing test; the table below documents their roles.

Run `./run_tests.sh` after every change to a script (`.gd`), scene (`.tscn`), `project.godot`, or `AGENTS.md` — the suite covers components, managers, settings persistence, and the screen-swap flow. The script imports resources headless first, so a fresh `class_name` or scene never blocks the runner.

Godot editor binary: `/Applications/Godot.app/Contents/MacOS/Godot` — run a scene with `--path .` from the project root.

After any change to a scene (`.tscn`) or its scripts, launch that scene in the Godot editor and verify it runs without errors (and run `./run_tests.sh`).

Keep this file in sync with the project — whenever the architecture changes (new/renamed scenes, scripts, autoloads, or signals), update `AGENTS.md` as part of the same change.

## Architecture

`run/main_scene` is `scenes/main/main.tscn` — the persistent root.

| Path | Role |
|---|---|
| `scenes/main/main.gd` | Root scene manager — swaps the current screen (`_set_scene()`); preloads `menu.tscn`, `game.tscn`, `settings.tscn`, and `victory.tscn`; connects the game's `game_over` to the victory screen and the menu's `settings_pressed` to the settings screen |
| `scenes/menu/menu.gd` | `MainMenu` (Control) — emits `play_pressed` / `settings_pressed` / `quit_pressed`; buttons `%PlayButton`, `%SettingsButton`, `%QuitButton` |
| `scenes/game/game.gd` | `GameScene` — root script of `game.tscn`; `@export ship_textures` (empty by default, filled in the inspector) — with at least 2 variants it picks 2 random distinct textures and assigns them to the players, otherwise warns without assigning; forwards `game_over(winner_player_index, winner_score)` from `RespawnManager` and `restart_pressed` / `menu_pressed` from `PauseMenu` to `Main` |
| `scripts/autoload/game.gd` | Autoload singleton providing `Game.SCREEN_SIZE` — the content-space size (`get_visible_rect().size`), set once in `_ready` |
| `scripts/autoload/settings.gd` | Autoload singleton `Settings` — persists audio volumes (linear 0..1) to `user://user_data.ini` (section `[audio]`, keys `master`/`music`/`effects`); loads on startup and applies them to the `Master`/`Music`/`SFX` audio buses; setter methods `set_master_volume` / `set_music_volume` / `set_effects_volume` each apply and save; creates missing buses as a fallback |
| `scripts/autoload/event_bus.gd` | Autoload singleton `EventBus` — global signal bus decoupling gameplay components; `ship_damage_received(amount, damaged_player_index, attacker_player_index)` is emitted by a `Hurtbox` on bullet hit |
| `scripts/components/wrapped.gd` | `Wrapped` component — screen-wrap child for any Node2D |
| `scenes/player/player.gd` | `Player` ship (CharacterBody2D) — thrust, rotation, fire; hides on death and `respawn(spawn_position)` restores it; `set_ship_texture(texture)` swaps the ship sprite; keeps the `HealthBar` `ProgressBar` child upright and hovering above the ship by counter-rotating it each frame (`HEALTH_BAR_OFFSET`), updating its value from `Health.health_changed`; plays `ShootSFX` / `DamageSFX` / `ExplosionSFX` (three `AudioStreamPlayer2D` children of `player.tscn`, `bus` `SFX`) on fire, on damage (via `EventBus.ship_damage_received`), and on death; on damage also blinks the ship sprite red by tweening `flash_amount` of the `damage_flash` shader material, reading `blink_count` / `blink_duration` uniforms from it |
| `assets/shaders/damage_flash.gdshader` | Canvas-item shader on the player `Sprite2D` via a `ShaderMaterial` (`resource_local_to_scene = true` so the two players don't share it) — mixes the sprite toward `flash_color` by `flash_strength * flash_amount`; editor-tunable uniforms `flash_color` / `flash_strength` / `blink_count` / `blink_duration` / `flash_amount` |
| `assets/shaders/bullet_glow.gdshader` | Canvas-item shader (`blend_add`) on the bullet `Sprite2D` via a `ShaderMaterial` — fully procedural: elongated glowing core along the bullet's forward axis (-Y), radial glow halo with pulse, and hash-driven sparks whose direction is mixed between a radial burst and a backward tail stream (`tail_bias`); editor-tunable uniforms `core_color` / `core_length` / `core_width` / `core_brightness`, `glow_color` / `glow_strength` / `glow_size` / `pulse_speed`, `particle_color` / `particle_count` / `particle_size` / `particle_speed` / `particle_lifetime` / `particle_spread` / `tail_bias` — plus pixelation uniforms `pixel_size` (pixel grid in texture pixels, snapped via `TEXTURE_PIXEL_SIZE`) and `shade_levels` (intensity bands for the glow halo and particles) |
| `scenes/player/hurtbox.gd` | `Hurtbox` — emits `EventBus.ship_damage_received(amount, damaged_player_index, attacker_player_index)` on bullet hit, `ship_collided` on ship collision; a ship-ship collision destroys both ships (`ship_collided` kills the local ship and the colliding body's `Health` is killed directly); ignores events once either ship is dead and discards `body_entered` signals where the ships aren't actually overlapping (`SHIP_COLLISION_DISTANCE`), since the physics server can emit spurious events after a respawn teleport |
| `scenes/player/health.gd` | `Health` component — HP, listens to `EventBus.ship_damage_received` for bullet damage (ignores hits on the other ship via `damaged_player_index`) and `Hurtbox.ship_collided` for instant kills, emits `died(attacker_player_index)` when killed; `kill()` emits index `0` (collision scores nobody); `reset()` restores full HP |
| `scenes/bullet/bullet.gd` | `Bullet` with speed and TTL; carries `owner_player_index` of the shooter; its `Sprite2D` carries the `bullet_glow` `ShaderMaterial` (additive, `scale = (4, 4)` so the glow/particles have room; the plasma texture only defines the sprite rect) |
| `scenes/game/star.gd` | `Star` — orbital gravity (wrap-aware offset); public `apply_initial_radial_velocity(player)` applies an initial orbital velocity |
| `scenes/game/camera_shake.gd` | `ShakingCamera` (Camera2D) — child of the `Game` root; centers on `Game.SCREEN_SIZE`; on `EventBus.ship_damage_received` builds shake intensity (scaled by `intensity_per_damage`, capped at `shake_intensity`) and jitters `offset` at `shake_frequency`, decaying at `shake_decay` |
| `scenes/game/score_manager.gd` | `ScoreManager` — child of the `Game` root; listens to `EventBus.ship_damage_received` (scores `attacker_player_index`) and both players' `Health.died`, +50 per hit (`HIT_POINTS`), +150 per kill (`KILL_POINTS`); emits `score_changed(player_index, score)` |
| `scenes/game/respawn_manager.gd` | `RespawnManager` — child of the `Game` root; gives each player `INITIAL_RESPAWNS` (3); respawns a player at the screen periphery after `RESPAWN_DELAY` (3 s) and re-applies the star's initial radial velocity; emits `respawns_changed(player_index, respawns_left)` on each count change and `game_over(winner_player_index, winner_score)` when a player runs out of respawns |
| `scenes/game/ui_manager.gd` | `UIManager` (CanvasLayer) — child of the `Game` root; renders scores into `%P1ScoreLabel` (top-left) / `%P2ScoreLabel` (top-right) and remaining respawns into `%P1RespawnsLabel` / `%P2RespawnsLabel` (each with an icon `TextureRect` placeholder) |
| `scenes/game/pause_menu.gd` | `PauseMenu` (CanvasLayer) — child of the `Game` root; runs with `PROCESS_MODE_ALWAYS` and is hidden by default; `_unhandled_input` toggles `get_tree().paused` on the `pause` input action, and `pause()` / `resume()` show/hide the overlay (resume always unpauses first); buttons `%ResumeButton` / `%RestartButton` / `%MenuButton` — resume unpauses, restart and menu unpause then emit `restart_pressed` / `menu_pressed` |
| `scenes/settings/settings.gd` | `SettingsScreen` (Control) — three `HSlider`s for master/music/effects volume; writes each change to the `Settings` autoload; button `%BackButton` emits `back_pressed` |
| `scenes/victory/victory.gd` | `VictoryScreen` (Control) — `setup(winner_index, score)` fills labels; buttons `%RestartButton` / `%MenuButton` emit `restart_pressed` / `menu_pressed` |

`menu.tscn` / `game.tscn` / `settings.tscn` / `victory.tscn` are children of `Main` that get swapped — never instantiated as the main scene. Each of `menu.tscn`, `settings.tscn`, and `game.tscn` has a `Music` `AudioStreamPlayer` child (bus `Music`, `autoplay`, stream assigned manually in the inspector).

Audio buses are defined in `default_bus_layout.tres` (`Master`, `Music`, `SFX`); audio volumes are applied via `AudioServer`.

## Testing

Tests live in `tests/` and run headless via `./run_tests.sh`.

| Path | Role |
|---|---|
| `tests/run_tests.tscn` + `run_tests.gd` | Runner — discovers every `tests/test_*.gd` file, runs each `test_*(framework)` method, prints a summary, and exits non-zero on failure; sets `Game.SCREEN_SIZE` to (640, 360) and deletes `user://user_data.ini` when done |
| `tests/test_framework.gd` | Assertion framework — a test method receives a `framework` argument with `check_true` / `check_false` / `check_equal` / `check_almost_equal` / `check_null` / `check_not_null` |
| `tests/fixtures.gd` | Static fixture builders — `make_player(index)`, `make_bullet(owner)`, `make_player_with_health()`, `make_game_root()` (players + star + managers wired like `game.tscn`) |
| `tests/test_camera_shake.gd` | `ShakingCamera` — screen-center placement, shake on `EventBus.ship_damage_received`, intensity cap, decay back to `offset == Vector2.ZERO` |
| `tests/test_pause_menu.gd` | `PauseMenu` — Escape toggles `get_tree().paused` and overlay visibility, resume button unpauses, restart/menu buttons emit their signals (all unpausing first) |
Test files must not declare a `class_name` (the runner loads them by path); methods are discovered by the `test_` prefix with exactly one argument.

## Input (no Input Map — actions defined in `project.godot`)

| Action | P1 | P2 |
|---|---|---|
| `p%d_thrust` | W | Up |
| `p%d_rotate_left` | A | Left |
| `p%d_rotate_right` | D | Right |
| `p%d_shoot` | S | Down |
| `pause` | Escape (both) | Escape (both) |

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
- `get_tree().paused` freezes the whole `Game` scene except `PauseMenu` (`PROCESS_MODE_ALWAYS`); it must always unpause before emitting restart/menu signals, otherwise the next screen stays frozen.
