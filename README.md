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
  brick atlas mapping, keeping gameplay meaning out of the visual loader.
- `PlayfieldRenderer` composes the 640x480 playfield shell from `Backgr`, `Walls`,
  and the selected level board, then creates a mutable board state for gameplay.
- `KrakoutBrickSemantics` and `KrakoutBoardState` preserve the original brick
  active/completion rules, the IDA-backed behavior-case table, and delayed 3x3
  chain explosions for tile IDs 43/68.
- `KrakoutGameSession` adds the first playable ball/racket loop around that
  board state: mouse-following right-side racket, ready/launch/play/lost/complete
  states, wall/racket/brick collision, and redraw signaling.
- `KrakoutGameSession` now consumes the first 22 level-tail bytes as original
  bonus stock, uses the original RNG constants, applies the 3-second drop gate
  and stock-weighted drop chance, spawns falling bonuses, converts random
  selector hits into chain tiles, and stacks collected bonuses up to the original
  16-entry cap. Individual collected-bonus effects are still pending parity work.
- `KrakoutBonusRenderer` draws falling bonuses, collected stack entries, and the
  stack pointer from the extracted `Bonuses_a`, `Bonuses_aa`, and
  `PointToBonusInStack` sheets.
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
