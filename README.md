# Krakout Rebooted

Krakout Rebooted is a Godot 4.6.2 reimplementation of the classic brick-breaker
Krakout, rebuilt from extracted runtime assets, decoded level data, and
reverse-engineered executable behavior.
<div align="center">
  <img src="screenshots/kr1.png" width="350"/>
  <img src="screenshots/kr2.png" width="350"/>
</div>

## Project Status

This is an active reimplementation with a playable core loop and a substantial
front-end flow already in place.

- Godot-native app shell with main menu, episode browser, options, rules,
  credits, high scores, name entry, exit confirmation, and gameplay screens.
- Original 640x480 presentation model with fixed viewport scaling and preserved
  4:3 aspect ratio.
- Runtime asset catalog built from a normalized manifest under
  `assets/krakout`.
- 17 decoded episodes and 441 decoded level files.
- Manifest-backed catalog for 37 textures, 25 sound effects, and 10 music
  tracks.
- Playable paddle, ball, wall, brick, level-ready, life-loss, level-complete,
  game-over, bonus, projectile, monster, and transient VFX systems.
- Local high-score persistence, including compatibility support for the
  original `Krakout.high` file format.
- Headless test runner covering asset loading, level parsing, presentation
  constants, menu routing, gameplay contracts, high scores, audio cue routing,
  and scene smoke checks.

## Engineering Highlights

### Evidence-First Reimplementation

Gameplay, UI, timing, audio, and visual behavior are implemented only after they
are backed by original runtime evidence, decoded data, extracted assets, or
explicit reverse-engineering notes. Unknown behavior is kept isolated behind
small adapters or left intentionally unmapped until verified.

### Data-Driven Runtime

The project uses committed runtime data instead of hard-coded assumptions:

- `KrakoutAssets` indexes textures, audio, levels, hashes, and provenance from
  `assets/krakout/manifest.json`.
- `KrakoutLevels` loads decoded level JSON into `KrakoutLevelData`.
- `KrakoutLevelData` preserves raw 20x13 board data and the original 50-byte
  level tail payload.
- Playfield constants such as the 640x480 viewport, 20x13 grid, brick size, and
  grid origin live in one shared specification.

### Maintainable Godot Architecture

The codebase is split into small ownership areas:

```text
scenes/
  app/                 Main app shell and screen routing
  game/                Gameplay scene composition
  menu/                Godot-native menu screens

src/
  app/                 App controller and cursor overlay
  autoloads/           Asset, level, profile, and audio services
  audio/               Music and SFX cue catalog
  data/                Level and high-score data codecs
  gameplay/            Deterministic session state, rules, and systems
  menu/                Menu behavior and original-style controls
  playfield/           Playfield constants and shell composition
  render/              Bitmap, brick, ball, paddle, monster, HUD, and VFX renderers

assets/krakout/        Godot-ready runtime assets and decoded levels
tests/                 Headless validation runner
```

The gameplay model is intentionally deterministic and testable. Session state is
kept separate from rendering, and original-backed rule tables are isolated from
Godot scene composition.

## Current Gameplay Features

- Mouse-controlled right-side paddle.
- Original-style get-ready reveal and launch flow.
- Ball movement, wall/racket collision, brick clearing, chain explosions, and
  level completion.
- Bonus stock derived from preserved level-tail bytes.
- Stackable bonus system with activation order, falling bonus rendering, and
  original-style stack pointer.
- Paddle-size, ball, fireball, projectile, wall, extra-life, destroy-ball,
  random, magnet, double-paddle, drunk-paddle, explosion, and jump-level bonus
  behaviors.
- Registered-version monster and hazard systems, including visual rendering,
  scoring, collision, stun behavior, and mapped SFX/VFX where verified.
- Bitmap HUD, score popups, ball tracks, explosion effects, ready roller, and
  game-over overlays.

## Controls

| Action | Input |
| --- | --- |
| Move paddle | Mouse |
| Launch / confirm | Left mouse button |
| Fire paddle projectile | Right mouse button |
| Use selected bonus | Space |
| Toggle bonus stack selection | Tab |
| Pause | P |
| Leave board / back | Escape |
| Toggle fullscreen | Alt+Enter |
| Toggle music | F7 |
| Toggle SFX | F8 |
| Release confined gameplay cursor | Ctrl+U |
| Toggle FPS display | F5 |


## Requirements

- Godot 4.6.2.

## Running

Open the project in Godot and run:

```text
res://scenes/app/app.tscn
```

From the command line:

```bash
godot --path . --scene res://scenes/app/app.tscn
```

## Validation

Use temporary Godot home/config paths so headless runs do not modify local editor
settings:

```bash
env HOME=/tmp/krakout-godot-home \
  XDG_CONFIG_HOME=/tmp/krakout-godot-config \
  XDG_DATA_HOME=/tmp/krakout-godot-data \
  godot --headless --path . --import --quit
```

```bash
env HOME=/tmp/krakout-godot-home \
  XDG_CONFIG_HOME=/tmp/krakout-godot-config \
  XDG_DATA_HOME=/tmp/krakout-godot-data \
  godot --headless --path . --script tests/test_runner.gd
```

```bash
env HOME=/tmp/krakout-godot-home \
  XDG_CONFIG_HOME=/tmp/krakout-godot-config \
  XDG_DATA_HOME=/tmp/krakout-godot-data \
  godot --headless --path . \
  --scene res://scenes/app/app.tscn --quit-after 3
```


## Development Principles

- Preserve original behavior before adding polish.
- Keep unknown parity details explicit rather than guessing.
- Prefer small, testable systems over monolithic gameplay scripts.
- Keep rendering, session state, data loading, audio routing, and UI flow
  independently replaceable.
- Preserve source provenance, hashes, and decoded data formats when normalizing
  assets for Godot.
- Add focused regression coverage for every behavior that was recovered from
  executable evidence.


Krakout Rebooted is an independent reimplementation and is not affiliated with
the original Krakout rights holders.
