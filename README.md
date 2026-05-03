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
- `PlayfieldRenderer` composes the 640x480 playfield shell from the original
  lattice `Backgr` tile, `Walls`, and the selected level board, then creates a
  mutable board state for gameplay.
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
  16-entry cap.
- Pressing Space now activates the first collected bonus in the original stack
  order. The current supported effects are standard ball, ball size/speed,
  paddle size, shooting paddle projectiles, extra life, destroy one ball, back
  wall, and jump to next level; fireball, magnet, random, and explosion-family
  effects remain explicit pending parity work.
- `KrakoutBonusRenderer` draws falling bonuses, collected stack entries, and the
  stack pointer from the extracted `Bonuses_a`, `Bonuses_aa`, and
  `PointToBonusInStack` sheets.
- `KrakoutBulletRenderer` draws the one-shot and continuous shooting-paddle
  projectiles from the extracted `Bullets` sheet, while `KrakoutGameSession`
  owns the original-backed 10-projectile pool, 250ms fire gate, leftward travel,
  and brick-hit routing.
- `KrakoutGameSession` now owns the first IDA-backed monster pool: five active
  slots, the original 3/6/10 type cycle, 4.5-second spawn gate, 6.5-second
  lifetime, 70ms animation cadence, original 1px/call 3-substep speed conversion,
  paddle-following type-3 eye movement, ball/projectile collision scoring, ball
  trajectory changes, wall-boundary reflection, and paddle contact handling.
- `KrakoutMonsterRenderer` draws those transient monsters from `Monsters.png`
  through the source 32x32 type/frame grid. `KrakoutBeeRenderer` adds the
  first Bee/type-9 floating hazard path, including the original-style
  racket-relative spawn, 3px/call 3-substep speed conversion, ball-hit removal
  without paddle stun, contact stun, hit SFX, and impact VFX.
- `KrakoutImpactEffectRenderer` draws enemy spawn, timeout, and hit effects from
  the original `Exploision` 32x32 vertical-frame columns, with the original
  11-frame/50ms cadence.
- `KrakoutBallRenderer` draws standard balls from the extracted `Balls` atlas
  using the original visible size rows, so size-changing bonuses use matching
  10/18/26/34/42 px ball frames instead of scaling a fixed crop.
- `Back Wall (30 sec)` now uses a timed session effect, reflects missed balls
  at the original right-side wall boundary, syncs the wall visual through the
  playfield renderer, and reports its countdown through the original
  `InfoIcons` HUD strip.
- The gameplay loop now tracks the original-backed run counters around that
  loop: 15-point brick scoring, gradual displayed-score catch-up, three spare
  balls, the faster original-style launch cadence, a 20,000-point extra-ball
  threshold, wrapped episode progression, and an original-layout gameplay
  HUD/game-over confirmation path.
- The gameplay presentation keeps the original 640x480 aspect ratio, uses the
  source `Statistic` header strip, and draws dynamic HUD digits through the
  IDA-backed original bitmap width tables instead of heuristic glyph cropping.
- Gameplay controls now flow through Godot InputMap actions for launching,
  bonus use, pause, the Escape leave-board confirmation, FPS, bonus-stack
  visibility, ball-track visibility, and a provisional background-cycle action.
  Runtime presentation toggles persist through `KrakoutProfile`.
- Confirming the Escape leave-board prompt first shows the original Game Over
  summary, then mouse confirmation reuses the qualifying-score name-entry and
  persisted high-score table route.
- Right-side ball misses now wait for the original off-screen x=640 threshold
  instead of ending as soon as the ball passes the racket/back-wall line.
- The project stretch settings render through the original 640x480 viewport and
  preserve the original 4:3 aspect ratio, so resized widescreen windows scale
  the game with black side bars instead of reshaping the playfield.
- `KrakoutProfile` persists both the compatibility best score and a Godot-native
  top-10 high-score table through a narrow `user://` profile file. Table entries
  keep player name, score, reached level, and episode slug while preserving the
  old `best_score()`/`record_score()` callers.
- `KrakoutApp` now starts on a Godot `Control` main menu, routes `Start Game`
  into an episode browser backed by decoded episode metadata, and starts the
  selected episode at its first level.
- The main menu now routes every original icon into a Godot-native screen:
  episode selection, game rules, high score, options, credits, and exit.
- Qualifying game-over scores now enter the original-backed name-entry slice:
  `BgGetName` background art, the original Enter/Backspace prompt strings,
  `theme3` music context, `Anonymous` fallback names, and submission into the
  persisted high-score table. Binary-compatible `Krakout.high` import/export
  and online score posting remain out of scope.
- `KrakoutAudio` owns manifest-backed music/SFX playback through a music player
  and small SFX pool. The options screen persists music/SFX enable flags and
  volumes through `KrakoutProfile`.
- `KrakoutAudioCueCatalog` maps the first IDA-backed music contexts into Godot
  scene flow: main menu/rules/options use `Abnormal`, high score uses `theme2`,
  credits uses `theme5`, episode select uses `theme1`, gameplay uses `theme4`,
  and name entry uses `theme3`.
- Gameplay now queues semantic SFX events from the session and drains them
  through `KrakoutAudio` in the Godot scene layer. IDA-backed mappings now cover
  launch, racket bounce, brick clear, chain explosion, bonus spawn/collect,
  projectile fire, monster spawn/timeout/hit, life lost, level complete, and
  game over; back-wall bounce, generic bonus apply, and generic projectile hit
  remain named but silent until original evidence proves a direct sample.

## Validation

```bash
./Godot_v4.6.2-stable_linux.x86_64 --headless --path . --import --quit
./Godot_v4.6.2-stable_linux.x86_64 --headless --path . --script tests/test_runner.gd
./Godot_v4.6.2-stable_linux.x86_64 --headless --path . --scene res://scenes/app/app.tscn --quit-after 3
```
