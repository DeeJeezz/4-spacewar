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

## Architecture

| Path | Role |
|---|---|
| `scripts/autoload/game.gd` | Autoload singleton providing `Game.SCREEN_SIZE` |
| `scripts/components/wrapped.gd` | `Wrapped` component — screen-wrap child for any Node2D |
| `scenes/player/player.gd` | `Player` ship (CharacterBody2D) — thrust, rotation, fire |
| `scenes/player/hurtbox.gd` | `Hurtbox` — collision kill on bullet/player contact |
| `scenes/bullet/bullet.gd` | `Bullet` with speed and TTL |
| `scenes/game/star.gd` | `Star` — orbital gravity (wrap-aware offset) |

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

## Gotchas

- `2d/default_gravity=0.0` — no built-in gravity. All gravity comes from `Star` nodes.
- Bullets are added to `get_tree().current_scene` (not as children of the player).
- Player velocity is capped to 50 via `limit_length`.
- `Wrapped` component reads `Game.SCREEN_SIZE` from the autoload singleton.
