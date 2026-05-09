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
  `Backgr` sheet, `Walls`, and the selected level board, then creates a mutable
  board state for gameplay. It now supports all eight original 50x50 background
  tiles, keeps the original invalid-type reset-to-zero behavior, and shifts the
  selected tile field by one pixel on a strict 10ms gate, wrapping at the 50px
  tile size while preserving the static-background profile toggle.
- `KrakoutBrickSemantics` and `KrakoutBoardState` preserve the original brick
  active/completion rules, the IDA-backed behavior-case table, and delayed 3x3
  chain explosions for tile IDs 43/68.
- `KrakoutGameSession` adds the first playable ball/racket loop around that
  board state: mouse-following right-side racket, ready/launch/play/lost/complete
  states, original get-ready launch-skip behavior, wall/racket/brick collision,
  and redraw signaling.
- `KrakoutGameSession` now consumes the first 22 level-tail bytes as original
  bonus stock, uses the original RNG constants, applies the 3-second drop gate
  and stock-weighted drop chance, spawns falling bonuses with the original
  1.5px/call three-substep rightward drift, converts random selector hits into
  chain tiles, and stacks collected bonuses up to the original 16-entry cap.
- Pressing Space now activates the first collected bonus in the original stack
  order. The current supported effects are standard ball, fireball,
  non-stricked balls, ball size/speed, paddle size, shooting paddle projectiles,
  double paddle, magnet paddle, drunk paddle, extra life, destroy one ball,
  random bonus stacking, one-strike bricks, expanding exploding bricks,
  exploding all chain bricks, back wall, and jump to next level.
- `KrakoutBonusRenderer` draws falling bonuses, collected stack entries, and the
  stack pointer from the extracted `Bonuses_a`, `Bonuses_aa`, and
  `PointToBonusInStack` sheets.
- `KrakoutBulletRenderer` draws the one-shot and continuous shooting-paddle
  projectiles from the extracted `Bullets` sheet at native atlas-frame size,
  while `KrakoutGameSession` owns the original-backed 10-projectile pool,
  250ms fire gate, faster parity-tuned leftward travel, smaller rocket hitbox,
  brick-hit routing, and held-button repeat fire through the screen input loop.
- `Double Paddle` now adds the original secondary racket 20 px left of the
  primary paddle and lets mouse-x deltas slide it within the original horizontal
  bounds. `Magnet Paddle` draws the original 20-frame animated insert behind the
  paddle, catches balls on racket contact, eases attached balls toward the paddle
  center at the original tick pace, and releases them through the launch action
  with preserved speed, and `Drunk Paddle` accumulates original 30-second
  inverted-movement windows.
- `KrakoutGameSession` now owns the IDA-backed registered monster pool: five
  active slots, the original 11-way registered spawn range, 4.5-second spawn
  gate, 6.5-second lifetime, 70ms animation cadence, original 1px/call
  3-substep speed conversion, pre-launch spawning while the ready ball stays
  attached, ball/projectile collision scoring, original radius-based ball enemy
  contacts, ball trajectory changes, 32px visual-bound wall clamping, and paddle
  contact handling. Monster behavior runs through an explicit original-backed
  trait catalog: type 3 follows the paddle, type 6 uses the original random
  10..60 score step, type 10 tracks the active ball and clamps at walls without
  angle reflection, and type 9 is a registered-spawn stun hazard with the
  original 32px contact box and 30-point racket-contact score.
- `KrakoutMonsterRenderer` draws those transient monsters from `Monsters.png`
  through the source 32x32 type/frame grid. `KrakoutBeeRenderer` adds the
  first Bee floating hazard path, including the original-style
  racket-relative spawn, 3px/call 3-substep speed conversion, ball-hit removal
  without paddle stun, contact stun, original `InfoIcons` stuck-racket countdown,
  `EffBee` stop-on-removal routing, hit SFX, and impact VFX.
- `Snake.png` now has an evidence-backed VFX path for the original 100-slot
  10x10 segment chain: strict 50ms/10px segment stepping, 20-kind source-grid
  rendering, ball/projectile truncation, and original terminal-kind rewrites.
  The current IDA anchors are `sub_4194C0` for texture loading, `sub_419650`
  for drawing, `sub_419600` for reset, `sub_419B00`/`sub_41A9A0`/
  `sub_41B140`/`sub_41B2E0` for updates, and `sub_41B390` for ball/projectile
  truncation. The runtime audit found `sub_419600` clearing `0x190` dwords
  from `+0x0A74` for the 100-slot buffer, and `sub_40DAF0` calling
  `sub_419B00` from the main gameplay update path. `sub_419B00` only enters the
  Snake update block when that guard is already `1`, then advances existing
  slots behind the original 50ms `timeGetTime` gate; a direct
  `+0x0A70..+0x0A8C` write audit found reset/read/step/draw/truncation sites
  but no production initializer for the guard.
  A follow-up level-tail audit found suspicious nonzero bytes (`Flystone` #25
  byte 29 and `170` padding in late `Abstraction`/`Retro` tails), but IDA shows
  `sub_40FF40` only summing tail indices `0..21` into the original bonus-stock
  total at `+0x51C`, with `sub_410CC0` reading/swapping that same bonus-stock
  region. `sub_4110E0` bonus dispatch was also checked and does not write the
  Snake guard or initialize a Snake slot.
  Offset hits in `sub_415A70`/`sub_415C00` are DirectInput state-buffer traffic,
  not Snake activation. A follow-up level-start audit found the only plausible
  production initializer candidate: after `sub_419600` resets Snake state,
  `sub_40E580` can call `sub_41A780` behind the original level-number/RNG gate.
  In this unpacked executable, however, `sub_41A780` stores `ECX` and immediately
  jumps to its epilogue, so the candidate initializer is stubbed out. A broader
  pointer-derived write scan over `+0x0A70..+0x10B4` produced expected raw
  displacement hits from unrelated ball/projectile/menu object contexts; after
  filtering to the Snake load/reset/draw/update/truncation family, the audit
  still found no production write of `+0x0A74 := 1`. Normal gameplay spawning is
  therefore evidence-gated and remains disabled; the current preview is exposed
  only through tests and the non-original debug-cheats button.
- `KrakoutImpactEffectRenderer` draws enemy spawn, timeout, hit, chain,
  brick-clear, bonus-clear, and hard-brick board-impact effects from the
  original `Exploision` vertical-frame columns, with the original 11-frame/50ms
  cadence, narrow 20x32 source regions for columns 3..5, the original
  chain-impact brick-cell offset, and the original bonus/chain-selector clear
  flash. Fireballs now also spawn the original wall-impact `Exploision` flash
  on left/top/bottom wall hits and active back-wall bounces.
- `KrakoutScorePopupRenderer` draws original floating score numbers from
  `DigitsSmall`, with the 40-slot pool, 15-frame/35ms animation rows, 3px
  upward drift at the original 50Hz cadence, y<10 expiry cutoff, and IDA-backed
  spawn offsets for normal bricks, chain clears, monsters, and Bees.
- `KrakoutBallRenderer` draws standard balls from the extracted `Balls` atlas,
  tints non-stricked balls, and composes fireballs from a warm-tinted `Balls`
  base plus the extracted native 24px `Fb` overlay, with the session advancing
  the stored ball frame clock at the original 100ms cadence even while a ball is
  attached to the racket or stationary. Ball tracks now use the original
  50-slot-per-ball `Fb` trail pool, strict 30ms spawn/frame gates, twelve
  12x12 frames, standard/fireball source columns, over-ball compositing, and no
  visible non-stricked trails; the ready ball sits on the original short 2px
  paddle gap.
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
- Level starts now trigger an explicit 30-second ready sequence: `eff05` plays
  once when the board is loaded, the original `Get Ready!`, `Level #`, and
  mouse-button prompt text appears at the original y positions, and the
  `InfoIcons` countdown runs until launch.
- Gameplay controls now flow through Godot InputMap actions for launching,
  bonus use, pause, the Escape leave-board confirmation, FPS, bonus-stack
  visibility, ball-track visibility, full original background-type cycling,
  moving-background toggling, music/SFX enable toggles, fullscreen toggling, and
  a debug-cheats stack editor. Runtime presentation and audio toggles persist
  through `KrakoutProfile`, and the original `+/-` and `Shift +/-` shortcuts
  adjust music and SFX volume during gameplay.
- The non-original debug-cheats action pauses gameplay and opens a stack editor
  for adding, removing, or clearing collected bonus items during testing.
- `KrakoutApp` hides the system cursor on menu, episode, high-score, options,
  and credits screens and draws the original `Cursor` asset as a shared
  overlay with the `Welogo` 30-frame animation inset. Name-entry keeps all mouse
  cursors hidden for the keyboard-only prompt; gameplay now keeps the
  system cursor confined to the original 640x480 viewport by default, releases
  it on `Ctrl+U`, and keeps the original hourglass cursor overlay visible while
  paused.
- The Escape leave-board prompt and Game Over summary render through the
  original bitmap `Font` path at the IDA-backed y positions, then mouse
  confirmation reuses the qualifying-score name-entry and persisted high-score
  table route.
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
- The episode browser follows the original `sub_41BD60` presentation: title and
  column labels use the recovered y `13`/`60` positions, rows use the original
  `5..585` by `100..430` mouse bounds, page arrows keep their original
  coordinates and frame gates, the two `BgEpisode` tiles scroll diagonally with
  the original strict 30ms one-pixel/three-pixel gates, and the selected episode
  name uses the original 5px sine-wave bitmap text with a strict
  40ms/20-degree phase gate.
- The main menu now routes every original icon into a Godot-native screen:
  episode selection, executable-backed game rules, high score, options,
  executable-backed credits, and exit.
- Qualifying game-over scores now enter the original-backed name-entry slice:
  `BgGetName` background art, the original two-layer 48px background scroll
  with the first layer vertical and the second diagonal, 400ms blinking name
  cursor, Enter/Backspace prompt strings at the recovered y positions,
  keyboard-only confirmation/editing, `theme3` music context,
  `Anonymous` fallback names, and submission into the persisted high-score
  table. IDA anchors are `sub_40B2F0` for `theme3.s3m`, `sub_40B480`/
  `sub_40B4F0` for `BgGetName.tga`, `sub_40BF30` for the background offsets,
  and `sub_40B530` for name input, prompt text, and cursor blinking. The
  name-entry path has no proven SFX route, so typing/submission stay silent.
  The profile now imports and mirrors the original binary-compatible 2080-byte
  `Krakout.high` table with the IDA-backed byte-index XOR encoding, while
  online score posting remains out of scope.
- `KrakoutAudio` owns manifest-backed music/SFX playback through a music player
  and small SFX pool. The options screen persists music/SFX enable flags and
  volumes through `KrakoutProfile`.
- `KrakoutAudioCueCatalog` maps the first IDA-backed music contexts into Godot
  scene flow: main menu/rules/options use `Abnormal`, high score uses `theme2`,
  credits uses `theme5`, episode select uses `theme1`, gameplay uses `theme4`,
  and name entry uses `theme3`.
- The rules page now follows the original `sub_4181B0` layout: the content is
  clipped to y `50..435`, the title and scroll hint sit at y `20` and `445`,
  the `Backward` art sits at `(539,379)`, held Up/Down scrolling uses the
  original per-frame 3px step, PgUp/PgDn use 400px jumps over the `50..-1090`
  range, and all 22 bonus labels use animated 10-frame bonus icons with the
  original 50ms frame gate.
- The high-score page now follows the original `sub_417850` table presentation:
  the title/header/row/footer coordinates match the executable, the `Backward`
  art sits at `(539,379)`, just-submitted rows use the original 5px sine-wave
  bitmap-text effect with a strict 40ms/20-degree phase gate, and hovering a row
  shows its episode name beside the cursor. The last finished player highlight
  is app-owned, so it remains active if the table is closed and reopened during
  the same session.
- Front-end interaction cues now route through the same semantic audio layer:
  main-menu selection/activation use `eff02`/`eff01`, while episode-browser
  selection/activation use `eff04`/`eff03`. Options-screen control selection,
  page changes, toggles, and Back reuse the original front-end `eff02`/`eff01`
  cue pair, and static info screens use the original animated `Backward` art
  plus `eff01` for Back activation. Startup focus, unchanged selection, and
  slider adjustments stay silent.
- The credits screen now follows the original menu VFX path from `sub_417D60`:
  the credit rows auto-roll from y `480`, move one pixel per 50 Hz front-end
  tick, wrap below `-1260`, keep the executable-backed row offsets, and place
  the `Backward` animation at the original credits position `(539,379)`.
- The options screen keeps page 1 as an original-backed audio control panel
  using the executable's four hit indices (`128..131`) for Music/SFX toggles
  and volume sliders. Those controls draw from the original `SoundSlider`,
  `Vx`, and `Backward` sheets, keep the IDA-backed inclusive hitboxes, and use
  strict sampled animation gates. Pages 2-3 remain Godot-only extension pages
  for presentation/gameplay toggles, separated by the original-style page-arrow
  flow.
- Gameplay now queues semantic SFX events from the session and drains them
  through `KrakoutAudio` in the Godot scene layer. The event queue now carries
  optional source-x payloads and applies the original pan formula
  `clamp(x * 0.3125 - 100, -100, 100)` through the positioned SFX pool while
  preserving the older event-name drain for compatibility. IDA-backed mappings
  now cover racket bounce, brick clear, hard-brick impact, chain explosion, bonus
  spawn/expire/collect, add-ball bonus apply, destroy-ball bonus apply,
  jump-level bonus apply,
  projectile fire, monster spawn/timeout/hit, life lost, level-ready, level
  complete, and game over. `Destroy One Ball` now maps to `eff24` and reuses
  the shared `Exploision` effect pool at the removed ball position. Hard-brick
  collisions now also expose the original `Exploision` force-break/non-clearing
  VFX columns. The remaining semantic SFX gaps are closed as audited silence:
  initial ball launch, back-wall bounce, generic bonus apply, and generic
  projectile hit stay named for gameplay flow but intentionally unmapped. The
  audit anchors are `sub_40DA00`/`sub_40E580`/`sub_4012D0` for ready and ball
  motion, `sub_4110E0` for bonus activation, and
  `sub_403630`/`sub_411B80`/`sub_4121C0` for projectile fire and hit routing.
  Snake remains silent too: its audited load/update/draw/truncation path has no
  Snake-specific sample route, and Snake runtime activation remains unproven.
  Extracted `eff06`, `eff20`, and `eff21` are preserved as DAT assets, but the
  unpacked executable does not reference them from its sample-load strings, so
  they remain unwired.

## Validation

```bash
./Godot_v4.6.2-stable_linux.x86_64 --headless --path . --import --quit
./Godot_v4.6.2-stable_linux.x86_64 --headless --path . --script tests/test_runner.gd
./Godot_v4.6.2-stable_linux.x86_64 --headless --path . --scene res://scenes/app/app.tscn --quit-after 3
```
