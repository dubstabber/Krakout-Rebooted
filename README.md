# Krakout-Rebooted

Godot 4.6 reimplementation foundation for Krakout, using the extracted original
assets as the runtime source of truth. The tracked `assets/krakout` tree contains
the Godot-ready textures, audio, level JSON, and a normalized manifest with
`res://` runtime paths plus original extraction provenance.

## Current Slice

- `KrakoutAssets` autoload indexes textures, audio, and level paths from the manifest.
- `KrakoutLevels` autoload loads raw 20x13 board JSON plus the preserved 50-byte
  level tail into `KrakoutLevelData`.
- `KrakoutPlayfieldSpec` centralizes the original 640x480 display and brick-grid
  coordinate constants.
- `KrakoutGameplaySheetCatalog` records the IDA-backed gameplay texture sheets
  and verified dimensions without guessing unknown animation/frame semantics.
- `LevelGridRenderer` renders raw visual board IDs through an isolated IDA-backed
  brick atlas mapping. Most tile gameplay semantics remain intentionally unmapped.
- `PlayfieldRenderer` composes the 640x480 playfield shell from `Backgr`, `Walls`,
  and the selected level board, then creates a mutable board state for gameplay.
- `KrakoutBrickSemantics` and `KrakoutBoardState` preserve the original brick
  active/completion rules plus delayed 3x3 chain explosions for tile IDs 43/68.
- `KrakoutGameSession` adds the first playable ball/racket loop around that
  board state: mouse-following right-side racket, ready/launch/play/lost/complete
  states, wall/racket/brick collision, and redraw signaling.
- The gameplay loop now tracks the original-backed run counters around that
  loop: 15-point brick scoring, gradual displayed-score catch-up, three spare
  balls, a 20,000-point extra-ball threshold, wrapped episode progression, and
  a lightweight HUD/game-over route back to the menu.
- `KrakoutApp` now starts on a Godot `Control` main menu, routes `Start Game`
  into an episode browser backed by decoded episode metadata, and starts the
  selected episode at its first level.

## Validation

```bash
./Godot_v4.6.2-stable_linux.x86_64 --headless --path . --import --quit
./Godot_v4.6.2-stable_linux.x86_64 --headless --path . --script tests/test_runner.gd
./Godot_v4.6.2-stable_linux.x86_64 --headless --path . --scene res://scenes/app/app.tscn --quit-after 3
```
