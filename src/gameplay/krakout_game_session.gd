extends RefCounted
class_name KrakoutGameSession

const BoardStateScript := preload("res://src/gameplay/krakout_board_state.gd")
const BrickSemanticsScript := preload("res://src/gameplay/krakout_brick_semantics.gd")
const RandomScript := preload("res://src/gameplay/krakout_random.gd")
const GameplayStateScript := preload("res://src/gameplay/krakout_gameplay_state.gd")
const AudioEventQueueScript := preload("res://src/gameplay/krakout_audio_event_queue.gd")
const BallTrackPoolScript := preload("res://src/gameplay/krakout_ball_track_pool.gd")
const BallRulesScript := preload("res://src/gameplay/rules/krakout_ball_rules.gd")
const RacketRulesScript := preload("res://src/gameplay/rules/krakout_racket_rules.gd")
const BonusCatalogScript := preload("res://src/gameplay/rules/krakout_bonus_catalog.gd")
const GameplayEventsScript := preload("res://src/gameplay/rules/krakout_gameplay_events.gd")
const EnemyRulesScript := preload("res://src/gameplay/rules/krakout_enemy_rules.gd")
const GameplayContextScript := preload("res://src/gameplay/krakout_gameplay_context.gd")
const BallSystemScript := preload("res://src/gameplay/systems/krakout_ball_system.gd")
const BonusSystemScript := preload("res://src/gameplay/systems/krakout_bonus_system.gd")
const EnemyHazardSystemScript := preload("res://src/gameplay/systems/krakout_enemy_hazard_system.gd")
const LevelReadySystemScript := preload("res://src/gameplay/systems/krakout_level_ready_system.gd")
const ProjectileSystemScript := preload("res://src/gameplay/systems/krakout_projectile_system.gd")
const RacketSystemScript := preload("res://src/gameplay/systems/krakout_racket_system.gd")
const TransientVfxPoolScript := preload("res://src/gameplay/krakout_transient_vfx_pool.gd")
const PlayfieldSpecScript := preload("res://src/playfield/krakout_playfield_spec.gd")

const STATE_READY := "ready"
const STATE_PLAYING := "playing"
const STATE_BALL_LOST := "ball_lost"
const STATE_LEVEL_COMPLETE := "level_complete"
const STATE_GAME_OVER := "game_over"

const MAX_BALLS := BallRulesScript.MAX_BALLS
const INITIAL_LIVES := 3
const NORMAL_BRICK_SCORE := 5
const CHAIN_BRICK_SCORE := 15
const HARD_BRICK_FORCE_SCORE := 30
const BRICK_SCORE := CHAIN_BRICK_SCORE
const EXTRA_LIFE_SCORE_STEP := 20000
const RACKET_X := RacketRulesScript.RACKET_X
const RACKET_WIDTH := RacketRulesScript.RACKET_WIDTH
const RACKET_HEIGHT := RacketRulesScript.RACKET_HEIGHT
# sub_4012D0 writes racket x = 575 on primary-paddle contact; sub_40DAF0
# walks it back to 570 one pixel at a strict 15 ms gate.
const RACKET_HIT_RECOIL_PIXELS := RacketRulesScript.RACKET_HIT_RECOIL_PIXELS
const RACKET_HIT_RECOIL_STEP_SECONDS := RacketRulesScript.RACKET_HIT_RECOIL_STEP_SECONDS
const RACKET_HIT_RECOIL_STEP_PIXELS := RacketRulesScript.RACKET_HIT_RECOIL_STEP_PIXELS
const RACKET_SEGMENT_PIXEL_STEP := RacketRulesScript.RACKET_SEGMENT_PIXEL_STEP
const RACKET_SEGMENT_MARGIN := RacketRulesScript.RACKET_SEGMENT_MARGIN
const RACKET_DEFAULT_SEGMENTS := RacketRulesScript.RACKET_DEFAULT_SEGMENTS
const RACKET_MIN_SEGMENTS := RacketRulesScript.RACKET_MIN_SEGMENTS
const RACKET_SHRINK_LIMIT_SEGMENTS := RacketRulesScript.RACKET_SHRINK_LIMIT_SEGMENTS
const RACKET_EXPAND_LIMIT_SEGMENTS := RacketRulesScript.RACKET_EXPAND_LIMIT_SEGMENTS
const RACKET_MAX_SEGMENTS := RacketRulesScript.RACKET_MAX_SEGMENTS
const RACKET_BONUS_STEP_SEGMENTS := RacketRulesScript.RACKET_BONUS_STEP_SEGMENTS
const RACKET_MIN_Y := RacketRulesScript.RACKET_MIN_Y
const RACKET_MAX_BOTTOM := RacketRulesScript.RACKET_MAX_BOTTOM
# sub_40E580 stores racket top y = 221 for the default 74 px racket, centered
# inside the original 63..453 playfield span.
const RACKET_READY_CENTER_Y := RacketRulesScript.RACKET_READY_CENTER_Y
const RACKET_READY_DEFAULT_Y := RacketRulesScript.RACKET_READY_DEFAULT_Y
const BALL_SIZE := BallRulesScript.BALL_SIZE
const BALL_MIN_SIZE := BallRulesScript.BALL_MIN_SIZE
const BALL_MAX_SIZE := BallRulesScript.BALL_MAX_SIZE
const BALL_SIZE_STEP := BallRulesScript.BALL_SIZE_STEP
const BALL_FRAME_COUNT := BallRulesScript.BALL_FRAME_COUNT
const BALL_TYPE_STANDARD := BallRulesScript.BALL_TYPE_STANDARD
const BALL_TYPE_FIREBALL := BallRulesScript.BALL_TYPE_FIREBALL
const BALL_TYPE_NON_STRICKED := BallRulesScript.BALL_TYPE_NON_STRICKED
const BALL_DEFAULT_SPEED_SCALE := BallRulesScript.BALL_DEFAULT_SPEED_SCALE
const BALL_MIN_SPEED_SCALE := BallRulesScript.BALL_MIN_SPEED_SCALE
const BALL_MAX_SPEED_SCALE := BallRulesScript.BALL_MAX_SPEED_SCALE
const BALL_SPEED_STEP := BallRulesScript.BALL_SPEED_STEP
const NON_STRICKED_DURATION_SECONDS := BallRulesScript.NON_STRICKED_DURATION_SECONDS
const BALL_TOP_Y := BallRulesScript.BALL_TOP_Y
const BALL_BOTTOM_Y := BallRulesScript.BALL_BOTTOM_Y
const BALL_LEFT_X := BallRulesScript.BALL_LEFT_X
const BALL_LOST_X := BallRulesScript.BALL_LOST_X
const BACK_WALL_BOUNCE_X := BallRulesScript.BACK_WALL_BOUNCE_X
# sub_40E580 creates the ready ball at racket_x - 20 with a 20 px ball crop.
const READY_BALL_GAP := BallRulesScript.READY_BALL_GAP
const ORIGINAL_UPDATE_HZ := BallRulesScript.ORIGINAL_UPDATE_HZ
# sub_4012D0 gates Balls.tga frame changes on timeGetTime() + 100 ms.
const BALL_FRAME_SECONDS := BallRulesScript.BALL_FRAME_SECONDS
const BALL_TRACK_SLOT_COUNT := BallRulesScript.BALL_TRACK_SLOT_COUNT
const BALL_TRACK_FRAME_COUNT := BallRulesScript.BALL_TRACK_FRAME_COUNT
const BALL_TRACK_SPAWN_SECONDS := BallRulesScript.BALL_TRACK_SPAWN_SECONDS
const BALL_TRACK_FRAME_SECONDS := BallRulesScript.BALL_TRACK_FRAME_SECONDS
const ORIGINAL_BALL_STEPS_PER_UPDATE := BallRulesScript.ORIGINAL_BALL_STEPS_PER_UPDATE
# sub_40DAF0 invokes the original enemy updater three times per gameplay step.
const ORIGINAL_ENEMY_STEPS_PER_UPDATE := 3.0
const ORIGINAL_ENEMY_UPDATE_HZ := ORIGINAL_UPDATE_HZ * ORIGINAL_ENEMY_STEPS_PER_UPDATE
const ORIGINAL_DEFAULT_BALL_SPEED_PER_TICK := BallRulesScript.ORIGINAL_DEFAULT_BALL_SPEED_PER_TICK
# sub_401A30 initializes the ready ball at table index 250. sub_401000 stores cos at
# +15 and sin at +375, and sub_4012D0 moves balls with x += sin(index), y -= cos(index).
const DEFAULT_BALL_LAUNCH_TABLE_INDEX := BallRulesScript.DEFAULT_BALL_LAUNCH_TABLE_INDEX
const DEFAULT_BALL_LAUNCH_DIRECTION := BallRulesScript.DEFAULT_BALL_LAUNCH_DIRECTION
const ORIGINAL_BALL_SPEEDUP_HIT_LIMIT := BallRulesScript.ORIGINAL_BALL_SPEEDUP_HIT_LIMIT
const ORIGINAL_BALL_SPEEDUP_PER_TICK := BallRulesScript.ORIGINAL_BALL_SPEEDUP_PER_TICK
const ORIGINAL_BALL_MAX_SPEED_PER_TICK := BallRulesScript.ORIGINAL_BALL_MAX_SPEED_PER_TICK
const DEFAULT_BALL_VELOCITY := BallRulesScript.DEFAULT_BALL_VELOCITY
const RACKET_BOUNCE_MAX_Y_SPEED := RacketRulesScript.RACKET_BOUNCE_MAX_Y_SPEED
const BONUS_TYPE_COUNT := BonusCatalogScript.BONUS_TYPE_COUNT
const BONUS_SELECTOR_COUNT := BonusCatalogScript.BONUS_SELECTOR_COUNT
const MAX_FALLING_BONUSES := BonusCatalogScript.MAX_FALLING_BONUSES
const MAX_STACKED_BONUSES := BonusCatalogScript.MAX_STACKED_BONUSES
const BONUS_DROP_GATE_SECONDS := BonusCatalogScript.BONUS_DROP_GATE_SECONDS
const BONUS_SIZE := BonusCatalogScript.BONUS_SIZE
const ORIGINAL_BONUS_STEPS_PER_UPDATE := BonusCatalogScript.ORIGINAL_BONUS_STEPS_PER_UPDATE
const ORIGINAL_BONUS_SUBSTEP_HZ := BonusCatalogScript.ORIGINAL_BONUS_SUBSTEP_HZ
# sub_402D10 advances falling bonuses by 1.5 px and 3 degrees per call; sub_40DAF0
# calls it three times per original 50 Hz gameplay step.
const BONUS_STEP_X := BonusCatalogScript.BONUS_STEP_X
const BONUS_WAVE_SCALE := BonusCatalogScript.BONUS_WAVE_SCALE
const BONUS_ANGLE_STEP := BonusCatalogScript.BONUS_ANGLE_STEP
const BONUS_MIN_Y := BonusCatalogScript.BONUS_MIN_Y
const BONUS_MAX_Y := BonusCatalogScript.BONUS_MAX_Y
const BONUS_EXPIRE_X := BonusCatalogScript.BONUS_EXPIRE_X
const BONUS_ANIMATION_FRAME_COUNT := BonusCatalogScript.BONUS_ANIMATION_FRAME_COUNT
const BONUS_FALLING_FRAME_SECONDS := BonusCatalogScript.BONUS_FALLING_FRAME_SECONDS
const BONUS_STACK_FRAME_SECONDS := BonusCatalogScript.BONUS_STACK_FRAME_SECONDS
const BONUS_POINTER_FRAME_SECONDS := BonusCatalogScript.BONUS_POINTER_FRAME_SECONDS
const BACK_WALL_DURATION_SECONDS := BonusCatalogScript.BACK_WALL_DURATION_SECONDS
const BACK_WALL_STATUS_ICON_INDEX := BonusCatalogScript.BACK_WALL_STATUS_ICON_INDEX
const LEVEL_READY_SEQUENCE_SECONDS := LevelReadySystemScript.SEQUENCE_SECONDS
const LEVEL_READY_STATUS_ICON_INDEX := LevelReadySystemScript.STATUS_ICON_INDEX
const RACKET_STUN_STATUS_ICON_INDEX := BonusCatalogScript.RACKET_STUN_STATUS_ICON_INDEX
const LOW_BLOCK_TIMER_TRIGGER_REQUIRED_BRICKS := BonusCatalogScript.LOW_BLOCK_TIMER_TRIGGER_REQUIRED_BRICKS
const LOW_BLOCK_TIMER_SECONDS := BonusCatalogScript.LOW_BLOCK_TIMER_SECONDS
const LOW_BLOCK_TIMER_STATUS_ICON_INDEX := BonusCatalogScript.LOW_BLOCK_TIMER_STATUS_ICON_INDEX
const LOW_BLOCK_TIMER_CHAIN_TILE_ID := BonusCatalogScript.LOW_BLOCK_TIMER_CHAIN_TILE_ID
# sub_40DAF0 rewrites the last eligible bricks to tile 43 and stores a 100-count
# tile timer; sub_40F940 decrements those tile timers on its 30 ms gate.
const LOW_BLOCK_TIMER_CHAIN_DELAY_SECONDS := BonusCatalogScript.LOW_BLOCK_TIMER_CHAIN_DELAY_SECONDS
# sub_40F940 draws Roller.tga as a 20x390 strip at x = 47 + reveal_offset
# and advances ten source frames while revealing the 20 board columns.
const LEVEL_READY_ROLLER_FRAME_COUNT := LevelReadySystemScript.ROLLER_FRAME_COUNT
const LEVEL_READY_ROLLER_STEP_SECONDS := LevelReadySystemScript.ROLLER_STEP_SECONDS
const LEVEL_READY_ROLLER_STEP_EPSILON := LevelReadySystemScript.ROLLER_STEP_EPSILON
const LEVEL_READY_ROLLER_STEP_PIXELS := LevelReadySystemScript.ROLLER_STEP_PIXELS
const LEVEL_READY_ROLLER_SOURCE_SIZE := LevelReadySystemScript.ROLLER_SOURCE_SIZE
const LEVEL_READY_ROLLER_POSITION := LevelReadySystemScript.ROLLER_POSITION
const LEVEL_READY_ROLLER_TRAVEL_PIXELS := LevelReadySystemScript.ROLLER_TRAVEL_PIXELS
const LEVEL_READY_ANIMATION_SECONDS := LevelReadySystemScript.ANIMATION_SECONDS
const MAX_PROJECTILES := ProjectileSystemScript.MAX_PROJECTILES
const PROJECTILE_FIRE_COOLDOWN_SECONDS := ProjectileSystemScript.PROJECTILE_FIRE_COOLDOWN_SECONDS
const PROJECTILE_STEP_X := ProjectileSystemScript.PROJECTILE_STEP_X
const PROJECTILE_EXPIRE_X := ProjectileSystemScript.PROJECTILE_EXPIRE_X
const PROJECTILE_SIZE := ProjectileSystemScript.PROJECTILE_SIZE
const PROJECTILE_TRAIL_OFFSET := ProjectileSystemScript.PROJECTILE_TRAIL_OFFSET
const PROJECTILE_HEAD_FRAME_COUNT := ProjectileSystemScript.PROJECTILE_HEAD_FRAME_COUNT
const PROJECTILE_TRAIL_FRAME_COUNT := ProjectileSystemScript.PROJECTILE_TRAIL_FRAME_COUNT
const PROJECTILE_HEAD_FRAME_SECONDS := ProjectileSystemScript.PROJECTILE_HEAD_FRAME_SECONDS
const PROJECTILE_TRAIL_FRAME_SECONDS := ProjectileSystemScript.PROJECTILE_TRAIL_FRAME_SECONDS
const PROJECTILE_TYPE_STRONG := ProjectileSystemScript.PROJECTILE_TYPE_STRONG
const PROJECTILE_TYPE_CONTINUOUS := ProjectileSystemScript.PROJECTILE_TYPE_CONTINUOUS
const PROJECTILE_MODE_DISABLED := 0
const PROJECTILE_MODE_CONTINUOUS := 1
const RACKET_VISUAL_MODE_NORMAL := RacketRulesScript.RACKET_VISUAL_MODE_NORMAL
const RACKET_VISUAL_MODE_SHOOTING_CONTINUOUS := RacketRulesScript.RACKET_VISUAL_MODE_SHOOTING_CONTINUOUS
const RACKET_VISUAL_MODE_SHOOTING_ONE_SHOT := RacketRulesScript.RACKET_VISUAL_MODE_SHOOTING_ONE_SHOT
const RACKET_VISUAL_MODE_MAGNET := RacketRulesScript.RACKET_VISUAL_MODE_MAGNET
const RACKET_VISUAL_FRAME_SECONDS := RacketRulesScript.RACKET_VISUAL_FRAME_SECONDS
const RACKET_VISUAL_MAX_FRAME := RacketRulesScript.RACKET_VISUAL_MAX_FRAME
const RACKET_MAGNET_VISUAL_FRAME_COUNT := RacketRulesScript.RACKET_MAGNET_VISUAL_FRAME_COUNT
const MAGNET_ATTACHED_Y_STEP_PER_UPDATE := RacketRulesScript.MAGNET_ATTACHED_Y_STEP_PER_UPDATE
const MAGNET_ATTACHED_X_PULL_LEFT_STEP_PER_UPDATE := RacketRulesScript.MAGNET_ATTACHED_X_PULL_LEFT_STEP_PER_UPDATE
const MAGNET_ATTACHED_X_PULL_RIGHT_STEP_PER_UPDATE := RacketRulesScript.MAGNET_ATTACHED_X_PULL_RIGHT_STEP_PER_UPDATE
const DOUBLE_PADDLE_OFFSET_X := RacketRulesScript.DOUBLE_PADDLE_OFFSET_X
const DOUBLE_PADDLE_MIN_X := RacketRulesScript.DOUBLE_PADDLE_MIN_X
const DOUBLE_PADDLE_MOUSE_X_MULTIPLIER := RacketRulesScript.DOUBLE_PADDLE_MOUSE_X_MULTIPLIER
const DRUNK_PADDLE_DURATION_SECONDS := RacketRulesScript.DRUNK_PADDLE_DURATION_SECONDS
const MAX_MONSTERS := 5
const MONSTER_TYPE_COUNT := 11
const MONSTER_SIZE := Vector2(32, 32)
const MONSTER_COLLISION_SIZE := Vector2(26, 26)
const MONSTER_COLLISION_OFFSET := Vector2(3, 3)
const MONSTER_TYPE9_COLLISION_SIZE := Vector2(32, 32)
const MONSTER_TYPE9_COLLISION_OFFSET := Vector2.ZERO
const MONSTER_BALL_COLLISION_RADIUS := 16.0
const MONSTER_LIFETIME_SECONDS := 6.5
const MONSTER_SPAWN_INTERVAL_SECONDS := 4.5
const MONSTER_FRAME_SECONDS := 0.07
const MONSTER_DEFAULT_SPEED := 1.0
const MONSTER_TYPE3_RIGHT_LIMIT := 510.0
const MONSTER_TYPE3_VERTICAL_JITTER_BASE := -5.0
const MONSTER_TYPE3_VERTICAL_JITTER_RANGE := 10
const MONSTER_TRACKING_TURN_STEP_DEGREES := 2.0
const MONSTER_SCORE := 15
const MONSTER_BALL_HIT_SCORE := 25
const MONSTER_TYPE6_SCORE_STEP := 10
const MONSTER_TYPE6_SCORE_VARIANTS := 6
const MONSTER_TYPE9_STUN_SCORE := 30
const MONSTER_BALL_HIT_MIN_ROTATION_DEGREES := 90
const MONSTER_BALL_HIT_RANDOM_ROTATION_DEGREES := 90
const MONSTER_TYPE1_BALL_ROTATION_DEGREES := 18
const MONSTER_MOTION_ANGLE := "angle"
const MONSTER_MOTION_PADDLE_FOLLOW := "paddle_follow"
const MONSTER_MOTION_BALL_TRACK := "ball_track"
const MONSTER_SCORE_MODE_DEFAULT := "default"
const MONSTER_SCORE_MODE_RANDOM_TYPE6 := "random_type6"
const MONSTER_SCORE_MODE_STUN_TYPE9 := "stun_type9"
const MONSTER_DEFAULT_TRAIT := {
	"frame_count": 11,
	"motion_mode": MONSTER_MOTION_ANGLE,
	"paddle_score_mode": MONSTER_SCORE_MODE_DEFAULT,
	"ball_score_mode": MONSTER_SCORE_MODE_DEFAULT,
	"collision_offset": MONSTER_COLLISION_OFFSET,
	"collision_size": MONSTER_COLLISION_SIZE,
	"stuns_racket": false,
	"natural_spawn": false,
}
const MONSTER_TRAITS := {
	0: {"frame_count": 20, "natural_spawn": true},
	1: {"frame_count": 20, "natural_spawn": true},
	2: {"frame_count": 20, "natural_spawn": true},
	3: {
		"frame_count": 20,
		"motion_mode": MONSTER_MOTION_PADDLE_FOLLOW,
		"natural_spawn": true,
	},
	4: {"frame_count": 20, "natural_spawn": true},
	5: {"frame_count": 20, "natural_spawn": true},
	6: {
		"frame_count": 20,
		"paddle_score_mode": MONSTER_SCORE_MODE_RANDOM_TYPE6,
		"ball_score_mode": MONSTER_SCORE_MODE_RANDOM_TYPE6,
		"natural_spawn": true,
	},
	7: {"frame_count": 11, "natural_spawn": true},
	8: {"frame_count": 10, "natural_spawn": true},
	9: {
		"frame_count": 20,
		"paddle_score_mode": MONSTER_SCORE_MODE_STUN_TYPE9,
		"collision_offset": MONSTER_TYPE9_COLLISION_OFFSET,
		"collision_size": MONSTER_TYPE9_COLLISION_SIZE,
		"stuns_racket": true,
		"natural_spawn": true,
	},
	10: {
		"frame_count": 11,
		"motion_mode": MONSTER_MOTION_BALL_TRACK,
		"natural_spawn": true,
	},
}
const BEE_SIZE := Vector2(48, 40)
const BEE_COLLISION_SIZE := Vector2(36, 36)
const BEE_COLLISION_OFFSET := Vector2(6, 6)
const BEE_FRAME_COUNT := 6
const BEE_FRAME_SECONDS := 0.005
const BEE_STEP_X := 3.0
const BEE_SPAWN_X := 50.0
const BEE_EXPIRE_X := 640.0
const BEE_SPAWN_DELAY_MAX_SECONDS := 30.0
const BEE_BALL_HIT_SCORE := MONSTER_BALL_HIT_SCORE
const BEE_STUN_SCORE := MONSTER_TYPE9_STUN_SCORE
const BEE_BALL_COLLISION_RADIUS := 24.0
const RACKET_STUN_DURATION_SECONDS := 3.0
const MAX_SNAKE_SEGMENTS := 100
const SNAKE_KIND_COUNT := 20
const SNAKE_SEGMENT_SIZE := Vector2(10, 10)
const SNAKE_UPDATE_SECONDS := 0.05
const SNAKE_STEP_PIXELS := 10.0
const SNAKE_KIND_UP := 0
const SNAKE_KIND_DOWN := 1
const SNAKE_KIND_LEFT := 2
const SNAKE_KIND_RIGHT := 3
const SNAKE_TERMINAL_UP := 16
const SNAKE_TERMINAL_DOWN := 17
const SNAKE_TERMINAL_LEFT := 18
const SNAKE_TERMINAL_RIGHT := 19
const SNAKE_RUNTIME_ACTIVATION_PROVEN := false
const SNAKE_ACTIVATION_POLICY := "evidence_gated"
const SNAKE_SLOT_OFFSET := "0x0A74"
const SNAKE_DIRECT_WRITE_AUDIT_RANGE := "+0x0A70..+0x10B4"
const SNAKE_LEVEL_TAIL_AUDIT_RANGE := "level_tail_bytes[22:50]"
const SNAKE_LEVEL_TAIL_AUDIT_FINDINGS := "Level-tail audit: Flystone #25 has tail byte 29 == 1; Abstraction #1-14 and Retro #27-30 carry 170 padding in tail bytes 30..49. IDA sub_40FF40 reads all 50 tail bytes into +0x4E8 but only sums indices 0..21 into +0x51C for bonus stock; sub_410CC0 reads/swaps that stock through +0x4E8/+0x51C and does not touch Snake state."
const SNAKE_BONUS_AUDIT := "Bonus audit: sub_4110E0 covers the 22 original bonus cases and writes ball/racket/board/level state, including board-cell timers under +0x5E8/+0x5F8 for exploding bricks, but no case writes Snake +0x0A74 or initializes a Snake slot."
const SNAKE_LEVEL_START_AUDIT := "Level-start audit: sub_40E580 calls sub_419600 to clear Snake state, then conditionally calls sub_41A780 after an original level-number/RNG gate. In this unpacked executable sub_41A780 stores ECX and immediately jumps to its epilogue, so the candidate production initializer is stubbed out."
const SNAKE_POINTER_WRITE_AUDIT := "Pointer-write audit: a raw displacement scan over +0x0A70..+0x10B4 includes unrelated ball/projectile/menu object contexts; filtering to the Snake load/reset/draw/update/truncation family leaves only reset clears, runtime guard clears, already-active movement/terminal rewrites, and truncation clears. No filtered path writes +0x0A74 := 1."
const SNAKE_IDA_EVIDENCE := "IDA anchors: sub_4194C0 load, sub_419650 draw, sub_419600 clears 100 16-byte slots from +0x0A74, sub_40DAF0 calls sub_419B00 from the runtime loop, sub_419B00 gates updates on +0x0A74 == 1 before calling sub_41A9A0/sub_41B140/sub_41B2E0, and sub_41B390 truncates from ball/projectile callers. sub_40E580 has the only level-start initializer candidate, but sub_41A780 is stubbed by an immediate jump to its epilogue. The +0x0A70..+0x10B4 pointer-write audit found reset/read/step/draw/truncation sites but no production initializer for +0x0A74. Level-tail anomalies in level_tail_bytes[22:50] and sub_4110E0 bonus cases were rechecked; neither path writes +0x0A74."
const MAX_IMPACT_EFFECTS := 100
const IMPACT_EFFECT_KIND_MONSTER_SPAWN := 0
const IMPACT_EFFECT_KIND_MONSTER_TIMEOUT := 1
# sub_419B00 uses the shared kind-1 Exploision column for Snake contact.
const IMPACT_EFFECT_KIND_SNAKE_HIT := IMPACT_EFFECT_KIND_MONSTER_TIMEOUT
const IMPACT_EFFECT_KIND_EXPLOSION := 2
const IMPACT_EFFECT_KIND_BRICK_CLEAR := 3
const IMPACT_EFFECT_KIND_HARD_BRICK_FORCE_BREAK := IMPACT_EFFECT_KIND_BRICK_CLEAR
const IMPACT_EFFECT_KIND_HARD_BRICK_IMPACT := 4
const IMPACT_EFFECT_KIND_BONUS_BRICK_CLEAR := 5
const IMPACT_EFFECT_KIND_MONSTER_HIT := IMPACT_EFFECT_KIND_EXPLOSION
const IMPACT_EFFECT_KIND_CHAIN_EXPLOSION := IMPACT_EFFECT_KIND_EXPLOSION
const CHAIN_EXPLOSION_IMPACT_OFFSET := Vector2(-8, 1)
const MAX_SCORE_POPUPS := 40
const SCORE_POPUP_FRAME_COUNT := 15
const SCORE_POPUP_FRAME_SECONDS := 0.035
const SCORE_POPUP_STEP_SECONDS := 1.0 / ORIGINAL_UPDATE_HZ
const SCORE_POPUP_STEP_PIXELS := 3.0
const SCORE_POPUP_MIN_Y := 10.0
const SCORE_POPUP_BRICK_OFFSET := Vector2(5, 0)
const SCORE_POPUP_CHAIN_OFFSET := Vector2(5, 5)
const FIREBALL_WALL_IMPACT_NONE := 0
const FIREBALL_WALL_IMPACT_LEFT := 1
const FIREBALL_WALL_IMPACT_BACK := 2
const FIREBALL_WALL_IMPACT_TOP := 3
const FIREBALL_WALL_IMPACT_BOTTOM := 4
const FIREBALL_WALL_IMPACT_OFFSET := Vector2(-16, -16)
const IMPACT_EFFECT_FRAME_SECONDS := 0.05
const IMPACT_EFFECT_FRAME_COUNT := 11
const IMPACT_EFFECT_DURATION_SECONDS := IMPACT_EFFECT_FRAME_SECONDS * IMPACT_EFFECT_FRAME_COUNT
const BONUS_ADD_STANDARD_BALL := BonusCatalogScript.BONUS_ADD_STANDARD_BALL
const BONUS_ADD_FIREBALL := BonusCatalogScript.BONUS_ADD_FIREBALL
const BONUS_NON_STRICKED_BALLS := BonusCatalogScript.BONUS_NON_STRICKED_BALLS
const BONUS_DECREASE_BALL_SIZE := BonusCatalogScript.BONUS_DECREASE_BALL_SIZE
const BONUS_INCREASE_BALL_SIZE := BonusCatalogScript.BONUS_INCREASE_BALL_SIZE
const BONUS_INCREASE_BALL_SPEED := BonusCatalogScript.BONUS_INCREASE_BALL_SPEED
const BONUS_DECREASE_BALL_SPEED := BonusCatalogScript.BONUS_DECREASE_BALL_SPEED
const BONUS_SHOOTING_PADDLE_TIMED := BonusCatalogScript.BONUS_SHOOTING_PADDLE_TIMED
const BONUS_SHOOTING_PADDLE_CONTINUOUS := BonusCatalogScript.BONUS_SHOOTING_PADDLE_CONTINUOUS
const BONUS_SHRINK_PADDLE := BonusCatalogScript.BONUS_SHRINK_PADDLE
const BONUS_EXPAND_PADDLE := BonusCatalogScript.BONUS_EXPAND_PADDLE
const BONUS_DOUBLE_PADDLE := BonusCatalogScript.BONUS_DOUBLE_PADDLE
const BONUS_MAGNET_PADDLE := BonusCatalogScript.BONUS_MAGNET_PADDLE
const BONUS_BACK_WALL := BonusCatalogScript.BONUS_BACK_WALL
const BONUS_EXTRA_LIFE := BonusCatalogScript.BONUS_EXTRA_LIFE
const BONUS_DESTROY_ONE_BALL := BonusCatalogScript.BONUS_DESTROY_ONE_BALL
const BONUS_RANDOM_BONUS := BonusCatalogScript.BONUS_RANDOM_BONUS
const BONUS_ONE_STRIKE_BRICKS := BonusCatalogScript.BONUS_ONE_STRIKE_BRICKS
const BONUS_DRUNK_PADDLE := BonusCatalogScript.BONUS_DRUNK_PADDLE
const BONUS_EXPAND_EXPLODING := BonusCatalogScript.BONUS_EXPAND_EXPLODING
const BONUS_JUMP_TO_NEXT_LEVEL := BonusCatalogScript.BONUS_JUMP_TO_NEXT_LEVEL
const BONUS_EXPLODE_ALL_EXPLODINGS := BonusCatalogScript.BONUS_EXPLODE_ALL_EXPLODINGS
const BONUS_TYPE_NAMES := BonusCatalogScript.BONUS_TYPE_NAMES
const SUPPORTED_BONUS_EFFECTS := BonusCatalogScript.SUPPORTED_BONUS_EFFECTS
const CHAIN_SELECTOR_TILE_IDS := BonusCatalogScript.CHAIN_SELECTOR_TILE_IDS
const BONUS_DISPLAY_INCREMENT_IDS := BonusCatalogScript.BONUS_DISPLAY_INCREMENT_IDS
const SFX_EVENT_BALL_LAUNCH := GameplayEventsScript.SFX_EVENT_BALL_LAUNCH
const SFX_EVENT_RACKET_BOUNCE := GameplayEventsScript.SFX_EVENT_RACKET_BOUNCE
const SFX_EVENT_BACK_WALL_BOUNCE := GameplayEventsScript.SFX_EVENT_BACK_WALL_BOUNCE
const SFX_EVENT_BRICK_CLEAR := GameplayEventsScript.SFX_EVENT_BRICK_CLEAR
const SFX_EVENT_HARD_BRICK_HIT := GameplayEventsScript.SFX_EVENT_HARD_BRICK_HIT
const SFX_EVENT_CHAIN_EXPLOSION := GameplayEventsScript.SFX_EVENT_CHAIN_EXPLOSION
const SFX_EVENT_BONUS_SPAWN := GameplayEventsScript.SFX_EVENT_BONUS_SPAWN
const SFX_EVENT_BONUS_EXPIRE := GameplayEventsScript.SFX_EVENT_BONUS_EXPIRE
const SFX_EVENT_BONUS_COLLECT := GameplayEventsScript.SFX_EVENT_BONUS_COLLECT
const SFX_EVENT_BONUS_APPLY := GameplayEventsScript.SFX_EVENT_BONUS_APPLY
const SFX_EVENT_BONUS_ADD_BALL_APPLY := GameplayEventsScript.SFX_EVENT_BONUS_ADD_BALL_APPLY
const SFX_EVENT_BONUS_DESTROY_BALL_APPLY := GameplayEventsScript.SFX_EVENT_BONUS_DESTROY_BALL_APPLY
const SFX_EVENT_BONUS_JUMP_LEVEL_APPLY := GameplayEventsScript.SFX_EVENT_BONUS_JUMP_LEVEL_APPLY
const SFX_EVENT_PROJECTILE_FIRE := GameplayEventsScript.SFX_EVENT_PROJECTILE_FIRE
const SFX_EVENT_PROJECTILE_HIT := GameplayEventsScript.SFX_EVENT_PROJECTILE_HIT
const SFX_EVENT_MONSTER_SPAWN := GameplayEventsScript.SFX_EVENT_MONSTER_SPAWN
const SFX_EVENT_MONSTER_EXPIRE := GameplayEventsScript.SFX_EVENT_MONSTER_EXPIRE
const SFX_EVENT_MONSTER_HIT := GameplayEventsScript.SFX_EVENT_MONSTER_HIT
const SFX_EVENT_BEE_SPAWN := GameplayEventsScript.SFX_EVENT_BEE_SPAWN
const SFX_EVENT_BEE_STOP := GameplayEventsScript.SFX_EVENT_BEE_STOP
const SFX_EVENT_LIFE_LOST := GameplayEventsScript.SFX_EVENT_LIFE_LOST
const SFX_EVENT_LEVEL_READY := GameplayEventsScript.SFX_EVENT_LEVEL_READY
const SFX_EVENT_LEVEL_COMPLETE := GameplayEventsScript.SFX_EVENT_LEVEL_COMPLETE
const SFX_EVENT_GAME_OVER := GameplayEventsScript.SFX_EVENT_GAME_OVER
const SFX_PAN_SOURCE_SCALE := GameplayEventsScript.SFX_PAN_SOURCE_SCALE
const SFX_PAN_SOURCE_OFFSET := GameplayEventsScript.SFX_PAN_SOURCE_OFFSET
const SFX_PAN_MIN := GameplayEventsScript.SFX_PAN_MIN
const SFX_PAN_MAX := GameplayEventsScript.SFX_PAN_MAX
const SFX_BEE_SPAWN_PAN100 := GameplayEventsScript.SFX_BEE_SPAWN_PAN100

var gameplay_state = GameplayStateScript.new()

var board_state:
	get:
		return gameplay_state.board_state
	set(value):
		gameplay_state.board_state = value

var state: String:
	get:
		return gameplay_state.phase
	set(value):
		gameplay_state.phase = value

var balls: Array[Dictionary]:
	get:
		return gameplay_state.balls
	set(value):
		gameplay_state.balls = value

var ball_tracks_enabled: bool:
	get:
		return gameplay_state.ball_tracks_enabled
	set(value):
		gameplay_state.ball_tracks_enabled = value

var ball_tracks: Array:
	get:
		return gameplay_state.ball_tracks
	set(value):
		gameplay_state.ball_tracks = value

var racket_y: float:
	get:
		return gameplay_state.racket_y
	set(value):
		gameplay_state.racket_y = value

var racket_segment_count: int:
	get:
		return gameplay_state.racket_segment_count
	set(value):
		gameplay_state.racket_segment_count = value

var ball_size: float:
	get:
		return gameplay_state.ball_size
	set(value):
		gameplay_state.ball_size = value

var ball_speed_scale: float:
	get:
		return gameplay_state.ball_speed_scale
	set(value):
		gameplay_state.ball_speed_scale = value

var board_changed: bool:
	get:
		return gameplay_state.board_changed
	set(value):
		gameplay_state.board_changed = value

var score: int:
	get:
		return gameplay_state.score
	set(value):
		gameplay_state.score = value

var displayed_score: int:
	get:
		return gameplay_state.displayed_score
	set(value):
		gameplay_state.displayed_score = value

var best_score: int:
	get:
		return gameplay_state.best_score
	set(value):
		gameplay_state.best_score = value

var lives_remaining: int:
	get:
		return gameplay_state.lives_remaining
	set(value):
		gameplay_state.lives_remaining = value

var points_to_next_extra_life: int:
	get:
		return gameplay_state.points_to_next_extra_life
	set(value):
		gameplay_state.points_to_next_extra_life = value

var display_level_number: int:
	get:
		return gameplay_state.display_level_number
	set(value):
		gameplay_state.display_level_number = value

var bonus_stock_counts: Array[int]:
	get:
		return gameplay_state.bonus_stock_counts
	set(value):
		gameplay_state.bonus_stock_counts = value

var remaining_bonus_stock: int:
	get:
		return gameplay_state.remaining_bonus_stock
	set(value):
		gameplay_state.remaining_bonus_stock = value

var falling_bonuses: Array[Dictionary]:
	get:
		return gameplay_state.falling_bonuses
	set(value):
		gameplay_state.falling_bonuses = value

var bonus_stack: Array[Dictionary]:
	get:
		return gameplay_state.bonus_stack
	set(value):
		gameplay_state.bonus_stack = value

var bonus_pointer_frame: int:
	get:
		return gameplay_state.bonus_pointer_frame
	set(value):
		gameplay_state.bonus_pointer_frame = value

var projectiles: Array[Dictionary]:
	get:
		return gameplay_state.projectiles
	set(value):
		gameplay_state.projectiles = value

var monsters: Array[Dictionary]:
	get:
		return gameplay_state.monsters
	set(value):
		gameplay_state.monsters = value

var bees: Array[Dictionary]:
	get:
		return gameplay_state.bees
	set(value):
		gameplay_state.bees = value

var snake_segments: Array[Dictionary]:
	get:
		return gameplay_state.snake_segments
	set(value):
		gameplay_state.snake_segments = value

var impact_effects: Array[Dictionary]:
	get:
		return gameplay_state.impact_effects
	set(value):
		gameplay_state.impact_effects = value

var score_popups: Array[Dictionary]:
	get:
		return gameplay_state.score_popups
	set(value):
		gameplay_state.score_popups = value

var back_wall_time_remaining: float:
	get:
		return gameplay_state.back_wall_time_remaining
	set(value):
		gameplay_state.back_wall_time_remaining = value

var level_ready_time_remaining: float:
	get:
		return gameplay_state.level_ready_time_remaining
	set(value):
		gameplay_state.level_ready_time_remaining = value

var low_block_timer_time_remaining: float:
	get:
		return gameplay_state.low_block_timer_time_remaining
	set(value):
		gameplay_state.low_block_timer_time_remaining = value


func _init() -> void:
	gameplay_state.audio_event_queue = AudioEventQueueScript.new(gameplay_state)
	gameplay_state.ball_system = BallSystemScript.new(gameplay_state)
	gameplay_state.ball_track_pool = BallTrackPoolScript.new(gameplay_state)
	gameplay_state.bonus_system = BonusSystemScript.new(gameplay_state)
	gameplay_state.level_ready_system = LevelReadySystemScript.new(gameplay_state)
	gameplay_state.gameplay_context = GameplayContextScript.new(self)
	gameplay_state.racket_system = RacketSystemScript.new(gameplay_state)
	gameplay_state.enemy_hazard_system = EnemyHazardSystemScript.new(gameplay_state)
	gameplay_state.projectile_system = ProjectileSystemScript.new(gameplay_state)
	gameplay_state.transient_vfx_pool = TransientVfxPoolScript.new(gameplay_state)
	gameplay_state.bonus_rng.set_seed(Time.get_ticks_msec())


func load_level(level: KrakoutLevelData) -> void:
	var next_display_level := 1
	if level != null and level.level_number > 0:
		next_display_level = level.level_number
	start_run(level, next_display_level)


func start_run(level: KrakoutLevelData, selected_display_level_number: int = 1, starting_best_score: int = 0) -> void:
	gameplay_state.audio_event_queue.clear()
	score = 0
	displayed_score = 0
	best_score = max(0, starting_best_score)
	lives_remaining = INITIAL_LIVES
	points_to_next_extra_life = EXTRA_LIFE_SCORE_STEP
	display_level_number = max(1, selected_display_level_number)
	_clear_bonus_run_state()
	_clear_monster_state()
	_reset_bonus_effect_state()
	_load_board_for_level(level)
	reset_round()


func advance_to_level(level: KrakoutLevelData, next_display_level_number: int) -> void:
	display_level_number = max(1, next_display_level_number)
	gameplay_state.bonus_system.clear_falling()
	_clear_monster_state()
	_clear_timed_bonus_state()
	_reset_bonus_drop_gate()
	_load_board_for_level(level)
	reset_round()


func set_board_state(state_value) -> void:
	gameplay_state.audio_event_queue.clear()
	board_state = state_value
	_load_bonus_stock_from_level(board_state.source_level if board_state != null else null)
	gameplay_state.bonus_system.clear_falling()
	_clear_timed_bonus_state()
	_reset_bonus_drop_gate()
	reset_round()


func reset_round() -> void:
	state = STATE_READY
	board_changed = false
	gameplay_state.ball_system.clear()
	_clear_ball_tracks()
	gameplay_state.bonus_system.clear_falling()
	_clear_monster_state()
	_clear_score_popups()
	_clear_timed_bonus_state()
	_clear_level_ready_sequence()
	_reset_bonus_drop_gate()
	_add_ready_ball()


func award_score(points: int) -> void:
	if points <= 0:
		return

	score += points
	best_score = max(best_score, score)
	while score >= points_to_next_extra_life:
		lives_remaining += 1
		points_to_next_extra_life += EXTRA_LIFE_SCORE_STEP


func _award_score_with_popup(points: int, position: Vector2) -> void:
	if points <= 0:
		return

	award_score(points)
	_spawn_score_popup(position, points)


func _award_chain_clear_score(cleared_count: int, cleared_cells: Array) -> void:
	var score_delta: int = maxi(0, cleared_count) * CHAIN_BRICK_SCORE
	if score_delta <= 0:
		return

	award_score(score_delta)
	for cell: Vector2i in cleared_cells:
		_spawn_score_popup(
			PlayfieldSpecScript.brick_rect(cell.x, cell.y).position + SCORE_POPUP_CHAIN_OFFSET,
			CHAIN_BRICK_SCORE
		)


func _chain_cells_source_x(cleared_cells: Array) -> float:
	for cell: Vector2i in cleared_cells:
		return PlayfieldSpecScript.brick_rect(cell.x, cell.y).position.x
	return PlayfieldSpecScript.GRID_ORIGIN.x


func visible_score_popups() -> Array[Dictionary]:
	return gameplay_state.transient_vfx_pool.visible_score_popups()


func visible_lives() -> int:
	return max(0, lives_remaining)


func _load_board_for_level(level: KrakoutLevelData) -> void:
	board_state = BoardStateScript.new() if level != null else null
	if board_state != null:
		board_state.load_level(level)
	_load_bonus_stock_from_level(level)


func move_racket_to(mouse_y: float, mouse_x = null) -> void:
	gameplay_state.racket_system.sync_from_state(gameplay_state)
	if is_racket_stunned():
		gameplay_state.racket_system.remember_input(mouse_y, mouse_x)
		gameplay_state.racket_system.sync_to_state(gameplay_state)
		return
	if is_level_ready_prompt_visible():
		gameplay_state.racket_system.remember_input(mouse_y, mouse_x)
		gameplay_state.racket_system.sync_to_state(gameplay_state)
		return
	var current_height: float = gameplay_state.racket_system.current_height()
	var target_center_y: float = mouse_y
	var mouse_delta_x: float = gameplay_state.racket_system.mouse_delta_x(mouse_x)
	if is_drunk_paddle_active():
		if gameplay_state.racket_system.has_last_input:
			target_center_y = gameplay_state.racket_system.y + current_height * 0.5 - (mouse_y - gameplay_state.racket_system.last_input_y)
		else:
			target_center_y = gameplay_state.racket_system.y + current_height * 0.5
		mouse_delta_x = -mouse_delta_x
	gameplay_state.racket_system.update_double_paddle_x(mouse_delta_x)
	gameplay_state.racket_system.remember_input(mouse_y, mouse_x)
	gameplay_state.racket_system.y = clampf(target_center_y - current_height * 0.5, RACKET_MIN_Y, RACKET_MAX_BOTTOM - current_height)
	gameplay_state.racket_system.sync_to_state(gameplay_state)
	if state == STATE_READY or state == STATE_BALL_LOST:
		_attach_ready_balls()


func move_racket_by_mouse_delta(mouse_delta_y: float, mouse_delta_x: float = 0.0) -> void:
	gameplay_state.racket_system.sync_from_state(gameplay_state)
	if is_racket_stunned():
		return
	if is_level_ready_prompt_visible():
		return
	var current_height: float = gameplay_state.racket_system.current_height()
	var target_center_y: float = gameplay_state.racket_system.y + current_height * 0.5 + mouse_delta_y
	var adjusted_mouse_delta_x: float = mouse_delta_x
	if is_drunk_paddle_active():
		target_center_y = gameplay_state.racket_system.y + current_height * 0.5 - mouse_delta_y
		adjusted_mouse_delta_x = -adjusted_mouse_delta_x
	gameplay_state.racket_system.update_double_paddle_x(adjusted_mouse_delta_x)
	gameplay_state.racket_system.y = clampf(target_center_y - current_height * 0.5, RACKET_MIN_Y, RACKET_MAX_BOTTOM - current_height)
	gameplay_state.racket_system.sync_to_state(gameplay_state)
	if state == STATE_READY or state == STATE_BALL_LOST:
		_attach_ready_balls()


func launch_ready_ball() -> bool:
	if state == STATE_PLAYING:
		return _release_magnet_attached_balls()

	if state != STATE_READY and state != STATE_BALL_LOST:
		return false
	if is_level_ready_prompt_visible():
		_skip_level_ready_prompt()
		return false

	if balls.is_empty():
		_add_ready_ball()

	var ball := balls[0]
	ball["active"] = true
	ball["velocity"] = _velocity_for_current_speed(DEFAULT_BALL_VELOCITY)
	ball["target_speed"] = Vector2(ball["velocity"]).length()
	ball["speed_hit_count"] = 0
	balls[0] = ball
	state = STATE_PLAYING
	_clear_level_ready_sequence()
	return true


func update(delta: float) -> void:
	board_changed = false
	_update_displayed_score()
	_update_ball_animation(delta)
	_update_ball_tracks(delta)
	_update_level_ready_sequence(delta)
	_update_bonus_timers(delta)
	_update_impact_effects(delta)
	_update_score_popups(delta)
	_update_racket_visual(delta)
	_update_racket_hit_recoil(delta)
	_update_bonus_stack(delta)

	if board_state != null:
		var chain_result: Dictionary = board_state.process_chain_explosions_with_result(delta)
		var chain_cleared_count := int(chain_result.get("cleared_count", 0))
		if chain_cleared_count > 0:
			board_changed = true
			var chain_cells: Array = chain_result.get("cleared_cells", [])
			_award_chain_clear_score(chain_cleared_count, chain_cells)
			_spawn_chain_explosion_impact_effects(chain_cells)
			_queue_audio_event_at_x(SFX_EVENT_CHAIN_EXPLOSION, _chain_cells_source_x(chain_cells))

	_update_low_block_timer(delta)
	_arm_low_block_timer_if_needed()
	if board_state != null and board_state.is_complete():
		_mark_level_complete()
		return

	if state == STATE_GAME_OVER:
		return

	_update_snake_segments(delta)
	_update_monsters(delta)
	_update_bees(delta)

	if state != STATE_PLAYING:
		_attach_ready_balls()
		_auto_launch_ready_ball_if_needed()
		return

	_update_falling_bonuses(delta)
	_update_projectiles(delta)
	_arm_low_block_timer_if_needed()
	if board_state != null and board_state.is_complete():
		_mark_level_complete()
		return
	_update_projectile_fire(delta)

	var active_count := 0
	for index in range(balls.size()):
		var ball := balls[index]
		if not bool(ball.get("active", false)):
			continue

		_advance_ball(ball, delta)
		balls[index] = ball
		if bool(ball.get("active", false)):
			active_count += 1

	_arm_low_block_timer_if_needed()
	if board_state != null and board_state.is_complete():
		_mark_level_complete()
	elif active_count <= 0:
		_handle_round_lost()


func consume_board_changed() -> bool:
	var changed := board_changed
	board_changed = false
	return changed


func visible_balls() -> Array[Dictionary]:
	return gameplay_state.ball_system.visible_balls()


func set_ball_tracks_enabled(is_enabled: bool) -> void:
	ball_tracks_enabled = is_enabled
	gameplay_state.ball_track_pool.set_enabled(ball_tracks_enabled)


func are_ball_tracks_enabled() -> bool:
	return ball_tracks_enabled


func visible_ball_tracks() -> Array[Dictionary]:
	gameplay_state.ball_track_pool.set_enabled(ball_tracks_enabled)
	return gameplay_state.ball_track_pool.visible_tracks()


func visible_falling_bonuses() -> Array[Dictionary]:
	return gameplay_state.bonus_system.visible_falling()


func visible_projectiles() -> Array[Dictionary]:
	return gameplay_state.projectile_system.visible_projectiles()


func visible_monsters() -> Array[Dictionary]:
	return gameplay_state.enemy_hazard_system.visible_monsters()


func visible_bees() -> Array[Dictionary]:
	return gameplay_state.enemy_hazard_system.visible_bees()


func visible_snake_segments() -> Array[Dictionary]:
	return gameplay_state.enemy_hazard_system.visible_snake_segments()


func visible_impact_effects() -> Array[Dictionary]:
	return gameplay_state.transient_vfx_pool.visible_impact_effects()


func bonus_stack_entries() -> Array[Dictionary]:
	return gameplay_state.bonus_system.stack_entries()


func debug_add_bonus_to_stack(type_id: int) -> Dictionary:
	if type_id < 0 or type_id >= BONUS_TYPE_COUNT:
		return {
			"status": "invalid",
			"type_id": type_id,
			"count": bonus_stack.size(),
			"limit": MAX_STACKED_BONUSES,
		}
	if not _push_bonus_stack(type_id):
		return {
			"status": "full",
			"type_id": type_id,
			"name": bonus_type_name(type_id),
			"count": bonus_stack.size(),
			"limit": MAX_STACKED_BONUSES,
		}
	return {
		"status": "added",
		"type_id": type_id,
		"name": bonus_type_name(type_id),
		"count": bonus_stack.size(),
		"limit": MAX_STACKED_BONUSES,
	}


func debug_remove_bonus_from_stack(index: int) -> Dictionary:
	if index < 0 or index >= bonus_stack.size():
		return {
			"status": "invalid",
			"index": index,
			"count": bonus_stack.size(),
		}
	var removed_entry: Dictionary = gameplay_state.bonus_system.remove_stack_entry(index)
	var type_id := int(removed_entry.get("type_id", -1))
	return {
		"status": "removed",
		"index": index,
		"type_id": type_id,
		"name": bonus_type_name(type_id),
		"count": bonus_stack.size(),
	}


func debug_clear_bonus_stack() -> int:
	return gameplay_state.bonus_system.clear_stack()


static func snake_runtime_activation_evidence() -> Dictionary:
	return {
		"proven": SNAKE_RUNTIME_ACTIVATION_PROVEN,
		"policy": SNAKE_ACTIVATION_POLICY,
		"activation_flag_offset": SNAKE_SLOT_OFFSET,
		"slot_count": MAX_SNAKE_SEGMENTS,
		"slot_bytes": 16,
		"load": "sub_4194C0 loads Snake.tga/Snake_a.bmp.",
		"draw": "sub_419650 draws contiguous already-active Snake slots from the 20-kind 10x10 Snake atlas.",
		"reset": "sub_419600 clears 0x190 dwords from +0x0A74, matching 100 16-byte Snake slots.",
		"runtime_loop": "sub_40DAF0 calls sub_419B00 from the main gameplay update path.",
		"update": "sub_419B00 reads +0x0A74 and only steps existing active slots through sub_41A9A0/sub_41B140/sub_41B2E0 after a 50 ms timeGetTime gate.",
		"update_guard": "sub_419B00 gates the Snake update block on dword +0x0A74 == 1 before calling the movement and terminal-rewrite helpers.",
		"collision": "sub_41B390 truncates existing slots from ball and projectile callers.",
		"level_start_candidate": SNAKE_LEVEL_START_AUDIT,
		"pointer_write_scan": SNAKE_POINTER_WRITE_AUDIT,
		"write_scan": "The direct and pointer-derived write scan over %s found reset clears, reads, step rewrites, terminal-kind rewrites, truncation clears, and no production writer of +0x0A74 := 1." % SNAKE_DIRECT_WRITE_AUDIT_RANGE,
		"input_state_overlap": "Offset hits in sub_415A70/sub_415C00 belong to DirectInput current/previous state buffers and are not Snake activation writes.",
		"level_tail_audit_range": SNAKE_LEVEL_TAIL_AUDIT_RANGE,
		"level_tail_audit": SNAKE_LEVEL_TAIL_AUDIT_FINDINGS,
		"bonus_activation_audit": SNAKE_BONUS_AUDIT,
		"activation": "No production write that sets the +0x0A74 Snake activation guard or first active slot was found in direct writes, pointer-derived writes, the stubbed level-start candidate, level-tail handling, or bonus-case dispatch; normal gameplay spawning stays disabled.",
	}


func debug_spawn_snake_vfx_preview() -> Dictionary:
	var preview_segments: Array[Dictionary] = []
	var origin := Vector2(420, 242)
	for index in range(8):
		preview_segments.append({
			"active": true,
			"position": origin + Vector2(float(index) * SNAKE_SEGMENT_SIZE.x, 0.0),
			"kind": SNAKE_KIND_LEFT,
		})
	preview_segments[preview_segments.size() - 1]["kind"] = SNAKE_TERMINAL_LEFT
	var count := force_snake_vfx_segments_for_test(preview_segments)
	return {
		"status": "spawned",
		"count": count,
		"source": "debug_only",
		"runtime_activation_proven": SNAKE_RUNTIME_ACTIVATION_PROVEN,
		"evidence": snake_runtime_activation_evidence(),
	}


func debug_clear_snake_vfx_preview() -> Dictionary:
	var removed_count := visible_snake_segments().size()
	_clear_snake_state()
	return {
		"status": "cleared",
		"count": removed_count,
	}


func active_bonus_indicators() -> Array[Dictionary]:
	var indicators: Array[Dictionary] = []
	if is_level_ready_sequence_active():
		indicators.append({
			"icon_index": LEVEL_READY_STATUS_ICON_INDEX,
			"value": ceili(gameplay_state.level_ready_system.time_remaining()),
		})
	if is_racket_stunned():
		indicators.append({
			"icon_index": RACKET_STUN_STATUS_ICON_INDEX,
			"value": ceili(gameplay_state.enemy_hazard_system.racket_stun_time_remaining),
		})
	if is_low_block_timer_active():
		indicators.append({
			"icon_index": LOW_BLOCK_TIMER_STATUS_ICON_INDEX,
			"value": ceili(low_block_timer_time_remaining),
		})
	if is_back_wall_active():
		indicators.append({
			"icon_index": BACK_WALL_STATUS_ICON_INDEX,
			"value": ceili(back_wall_time_remaining),
		})
	return indicators


func start_level_ready_sequence(queue_audio := true) -> void:
	_reset_racket_to_ready_center()
	gameplay_state.level_ready_system.start()
	if queue_audio:
		_queue_audio_event(SFX_EVENT_LEVEL_READY)


func is_level_ready_sequence_active() -> bool:
	return gameplay_state.level_ready_system.is_sequence_active()


func is_level_ready_prompt_visible() -> bool:
	return gameplay_state.level_ready_system.is_prompt_visible()


func is_racket_visible() -> bool:
	return gameplay_state.level_ready_system.are_gameplay_actors_visible()


func are_balls_visible() -> bool:
	return gameplay_state.level_ready_system.are_gameplay_actors_visible()


func level_ready_animation_progress() -> float:
	return gameplay_state.level_ready_system.animation_progress()


func level_ready_roller_layout() -> Dictionary:
	return gameplay_state.level_ready_system.roller_layout()


func is_back_wall_active() -> bool:
	return back_wall_time_remaining > 0.0


func is_low_block_timer_active() -> bool:
	return low_block_timer_time_remaining > 0.0


func is_shooting_paddle_active() -> bool:
	return gameplay_state.shooting_paddle_mode == PROJECTILE_MODE_CONTINUOUS


func is_single_shot_paddle_armed() -> bool:
	return gameplay_state.single_shot_projectile_armed


func is_double_paddle_active() -> bool:
	gameplay_state.racket_system.sync_from_state(gameplay_state)
	return gameplay_state.double_paddle_active


func is_magnet_paddle_active() -> bool:
	gameplay_state.racket_system.sync_from_state(gameplay_state)
	return gameplay_state.magnet_paddle_active


func is_drunk_paddle_active() -> bool:
	gameplay_state.racket_system.sync_from_state(gameplay_state)
	return gameplay_state.drunk_paddle_time_remaining > 0.0


func drunk_paddle_time_remaining() -> float:
	gameplay_state.racket_system.sync_from_state(gameplay_state)
	return gameplay_state.drunk_paddle_time_remaining


func magnet_attached_ball_count() -> int:
	var count := 0
	for ball: Dictionary in balls:
		if _is_ball_magnet_attached(ball):
			count += 1
	return count


func is_racket_stunned() -> bool:
	return gameplay_state.enemy_hazard_system.is_racket_stunned()


func current_racket_visual_mode() -> int:
	gameplay_state.racket_system.sync_from_state(gameplay_state)
	return gameplay_state.racket_visual_mode


func current_racket_visual_frame() -> int:
	gameplay_state.racket_system.sync_from_state(gameplay_state)
	return gameplay_state.racket_visual_frame


func fire_shooting_paddle() -> Dictionary:
	if state != STATE_PLAYING:
		return {"status": "inactive"}
	var projectile_type := -1
	if gameplay_state.shooting_paddle_mode == PROJECTILE_MODE_CONTINUOUS:
		projectile_type = PROJECTILE_TYPE_CONTINUOUS
	elif gameplay_state.single_shot_projectile_armed:
		projectile_type = PROJECTILE_TYPE_STRONG
	else:
		return {"status": "unarmed"}

	var projectile_fire_cooldown: float = float(gameplay_state.projectile_system.fire_cooldown_remaining())
	if projectile_fire_cooldown > 0.0:
		return {"status": "cooldown", "remaining": projectile_fire_cooldown, "projectile_type": projectile_type}

	if _spawn_projectile(projectile_type):
		if projectile_type == PROJECTILE_TYPE_STRONG:
			gameplay_state.single_shot_projectile_armed = false
			_set_racket_visual_target(RACKET_VISUAL_MODE_NORMAL)
		gameplay_state.projectile_system.start_fire_cooldown()
		return {"status": "fired", "projectile_type": projectile_type}
	return {"status": "blocked", "projectile_type": projectile_type}


static func sfx_pan100_for_source_x(source_x: float) -> float:
	return GameplayEventsScript.pan100_for_source_x(source_x)


static func sfx_pan_for_source_x(source_x: float) -> float:
	return AudioEventQueueScript.sfx_pan_for_source_x(source_x)


func pop_audio_events() -> Array[String]:
	return gameplay_state.audio_event_queue.pop_event_names()


func pop_audio_event_payloads() -> Array[Dictionary]:
	return gameplay_state.audio_event_queue.pop_payloads()


func activate_next_bonus() -> Dictionary:
	if bonus_stack.is_empty():
		return {"status": "empty"}

	if state != STATE_PLAYING:
		return {"status": "inactive", "type_id": int(bonus_stack[0].get("type_id", -1))}

	var type_id := int(bonus_stack[0].get("type_id", -1))
	if not SUPPORTED_BONUS_EFFECTS.has(type_id):
		return {
			"status": "unsupported",
			"type_id": type_id,
			"name": bonus_type_name(type_id),
		}

	_consume_next_bonus()
	var result := _apply_bonus_effect(type_id)
	result["status"] = "applied"
	result["type_id"] = type_id
	result["name"] = bonus_type_name(type_id)
	var audio_event := _bonus_apply_audio_event(type_id, result)
	if not audio_event.is_empty():
		if result.has("source_x"):
			_queue_audio_event_at_x(audio_event, float(result["source_x"]))
		else:
			_queue_audio_event(audio_event)
	elif _should_queue_generic_bonus_apply_event(type_id):
		_queue_audio_event(SFX_EVENT_BONUS_APPLY)
	return result


func _bonus_apply_audio_event(type_id: int, result: Dictionary) -> String:
	match type_id:
		BONUS_ADD_STANDARD_BALL, BONUS_ADD_FIREBALL:
			if bool(result.get("applied", false)):
				return SFX_EVENT_BONUS_ADD_BALL_APPLY
		BONUS_DESTROY_ONE_BALL:
			if bool(result.get("applied", false)):
				return SFX_EVENT_BONUS_DESTROY_BALL_APPLY
		BONUS_JUMP_TO_NEXT_LEVEL:
			return SFX_EVENT_BONUS_JUMP_LEVEL_APPLY
	return ""


func _should_queue_generic_bonus_apply_event(type_id: int) -> bool:
	return type_id != BONUS_ADD_STANDARD_BALL \
		and type_id != BONUS_ADD_FIREBALL \
		and type_id != BONUS_DESTROY_ONE_BALL \
		and type_id != BONUS_JUMP_TO_NEXT_LEVEL


static func bonus_type_name(type_id: int) -> String:
	var name := BonusCatalogScript.bonus_type_name(type_id)
	if name == "Unknown":
		return "Unknown Bonus"
	return name


static func monster_trait_for_type(type_id: int) -> Dictionary:
	return EnemyRulesScript.monster_trait_for_type(type_id)


static func monster_spawn_pool() -> Array[int]:
	return EnemyRulesScript.monster_spawn_pool()


static func monster_frame_count_for_type(type_id: int) -> int:
	return EnemyRulesScript.monster_frame_count_for_type(type_id)


static func monster_motion_mode_for_type(type_id: int) -> String:
	return EnemyRulesScript.monster_motion_mode_for_type(type_id)


static func monster_collision_offset_for_type(type_id: int) -> Vector2:
	return EnemyRulesScript.monster_collision_offset_for_type(type_id)


static func monster_collision_size_for_type(type_id: int) -> Vector2:
	return EnemyRulesScript.monster_collision_size_for_type(type_id)


static func monster_stuns_racket(type_id: int) -> bool:
	return EnemyRulesScript.monster_stuns_racket(type_id)


static func monster_type_is_original_spawned(type_id: int) -> bool:
	return EnemyRulesScript.monster_type_is_original_spawned(type_id)


static func _monster_score_mode_for_type(type_id: int, contact_key: String) -> String:
	return EnemyRulesScript.monster_score_mode_for_type(type_id, contact_key)


static func _monster_trait_value(type_id: int, key: String, default_value):
	return EnemyHazardSystemScript._monster_trait_value(type_id, key, default_value)


func set_bonus_rng_seed(seed_value: int) -> void:
	gameplay_state.bonus_rng.set_seed(seed_value)


func set_monster_rng_seed(seed_value: int) -> void:
	gameplay_state.enemy_hazard_system.set_monster_rng_seed(seed_value)


func active_monster_spawn_pool() -> Array[int]:
	return monster_spawn_pool()


func set_collision_rng_seed(seed_value: int) -> void:
	gameplay_state.enemy_hazard_system.set_collision_rng_seed(seed_value)


func set_ball_track_rng_seed(seed_value: int) -> void:
	gameplay_state.ball_track_rng.set_seed(seed_value)


func force_bonus_drop_ready() -> void:
	gameplay_state.bonus_system.force_drop_ready()


func force_monster_spawn_ready() -> void:
	gameplay_state.enemy_hazard_system.force_monster_spawn_ready()


func force_bee_spawn_ready() -> void:
	gameplay_state.enemy_hazard_system.force_bee_spawn_ready()


func set_projectile_fire_cooldown_for_test(seconds: float) -> void:
	gameplay_state.projectile_system.set_fire_cooldown_for_test(seconds)


func replace_projectiles_for_test(next_projectiles: Array) -> void:
	gameplay_state.projectile_system.replace_projectiles_for_test(next_projectiles)


func clear_projectiles_for_test() -> void:
	gameplay_state.projectile_system.clear()


func set_monster_spawn_cooldown_for_test(seconds: float) -> void:
	gameplay_state.enemy_hazard_system.set_monster_spawn_cooldown_for_test(seconds)


func set_bee_spawn_delay_for_test(seconds: float) -> void:
	gameplay_state.enemy_hazard_system.set_bee_spawn_delay_for_test(seconds)


func set_monster_age_for_test(index: int, age: float) -> bool:
	return gameplay_state.enemy_hazard_system.set_monster_age_for_test(index, age)


func active_ball_count() -> int:
	return gameplay_state.ball_system.active_count()


func active_projectile_count() -> int:
	return gameplay_state.projectile_system.active_count()


func active_monster_count() -> int:
	return gameplay_state.enemy_hazard_system.active_monster_count()


func active_bee_count() -> int:
	return gameplay_state.enemy_hazard_system.active_bee_count()


func active_snake_segment_count() -> int:
	return gameplay_state.enemy_hazard_system.active_snake_segment_count()


func current_racket_height() -> float:
	gameplay_state.racket_system.sync_from_state(gameplay_state)
	return gameplay_state.racket_system.current_height()


func current_racket_x() -> float:
	gameplay_state.racket_system.sync_from_state(gameplay_state)
	return gameplay_state.racket_system.current_x()


func racket_rect() -> Rect2:
	gameplay_state.racket_system.sync_from_state(gameplay_state)
	return gameplay_state.racket_system.primary_rect()


func racket_rects() -> Array[Rect2]:
	gameplay_state.racket_system.sync_from_state(gameplay_state)
	return gameplay_state.racket_system.rects()


func ball_rect(ball: Dictionary) -> Rect2:
	return gameplay_state.ball_system.ball_rect(ball)


func projectile_rect(projectile: Dictionary) -> Rect2:
	return gameplay_state.projectile_system.projectile_rect(projectile)


func monster_rect(monster: Dictionary) -> Rect2:
	return EnemyHazardSystemScript.monster_rect(monster)


func bee_rect(bee: Dictionary) -> Rect2:
	return EnemyHazardSystemScript.bee_rect(bee)


func snake_rect(segment: Dictionary) -> Rect2:
	return EnemyHazardSystemScript.snake_rect(segment)


func first_ball_position() -> Vector2:
	if balls.is_empty():
		return Vector2.ZERO
	return balls[0].get("position", Vector2.ZERO)


func first_ball_velocity() -> Vector2:
	if balls.is_empty():
		return Vector2.ZERO
	return balls[0].get("velocity", Vector2.ZERO)


func first_ball_type_id() -> int:
	if balls.is_empty():
		return BALL_TYPE_STANDARD
	return gameplay_state.ball_system.ball_type(balls[0])


func active_non_stricked_ball_count() -> int:
	return gameplay_state.ball_system.active_non_stricked_count()


func force_ball(position: Vector2, velocity: Vector2, size: float = BALL_SIZE, type_id: int = BALL_TYPE_STANDARD) -> void:
	gameplay_state.ball_system.force_ball(position, velocity, size, type_id, ball_speed_scale, _target_speed_for_new_ball(velocity))
	_clear_ball_tracks()
	state = STATE_PLAYING


func force_monster(position: Vector2, type_id: int = 3, angle: int = 0) -> bool:
	var forced: bool = gameplay_state.enemy_hazard_system.force_monster(position, type_id, angle)
	if forced:
		state = STATE_PLAYING
	return forced


func force_bee(position: Vector2, frame: int = 0) -> bool:
	var forced: bool = gameplay_state.enemy_hazard_system.force_bee(position, frame)
	if forced:
		state = STATE_PLAYING
	return forced


func force_snake_vfx_segments_for_test(segments: Array) -> int:
	return gameplay_state.enemy_hazard_system.force_snake_vfx_segments_for_test(segments)


func _add_ready_ball() -> void:
	_add_ball(_ready_ball_position(), Vector2.ZERO, true)


func _add_ball(position: Vector2, velocity: Vector2, active := true, type_id := BALL_TYPE_STANDARD) -> bool:
	return gameplay_state.ball_system.add_ball(
		position,
		velocity,
		active,
		ball_size,
		type_id,
		ball_speed_scale,
		_target_speed_for_new_ball(velocity)
	)


func _add_active_standard_ball() -> bool:
	return _add_ball(_ready_ball_position(), _velocity_for_current_speed(DEFAULT_BALL_VELOCITY), true, BALL_TYPE_STANDARD)


func _add_active_fireball() -> bool:
	return _add_ball(_ready_ball_position(), _velocity_for_current_speed(DEFAULT_BALL_VELOCITY), true, BALL_TYPE_FIREBALL)


func _attach_ready_balls() -> void:
	for index in range(balls.size()):
		var ball := balls[index]
		ball["active"] = true
		ball["position"] = _ready_ball_position()
		ball["velocity"] = Vector2.ZERO
		ball["size"] = ball_size
		ball["speed_scale"] = ball_speed_scale
		ball["target_speed"] = _target_speed_for_new_ball(_velocity_for_current_speed(DEFAULT_BALL_VELOCITY))
		ball["speed_hit_count"] = 0
		_clear_ball_magnet_attachment(ball)
		balls[index] = ball


func _ready_ball_position() -> Vector2:
	return Vector2(
		RACKET_X - ball_size - READY_BALL_GAP,
		racket_y + current_racket_height() * 0.5 - ball_size * 0.5
	)


func _ball_type(ball: Dictionary) -> int:
	return gameplay_state.ball_system.ball_type(ball)


func _is_non_stricked_ball(ball: Dictionary) -> bool:
	return gameplay_state.ball_system.is_non_stricked_ball(ball)


func _ball_force_breaks_board(ball: Dictionary) -> bool:
	return _ball_type(ball) == BALL_TYPE_FIREBALL


func _ball_pierces_board(ball: Dictionary) -> bool:
	return _ball_type(ball) == BALL_TYPE_FIREBALL


func _ball_collides_with_enemies(ball: Dictionary) -> bool:
	return _ball_type(ball) <= BALL_TYPE_FIREBALL


func _restore_ball_type_after_non_stricked(ball: Dictionary) -> void:
	var previous_type := int(ball.get("previous_type_id", BALL_TYPE_STANDARD))
	if previous_type == BALL_TYPE_NON_STRICKED:
		previous_type = BALL_TYPE_STANDARD
	ball["type_id"] = previous_type
	ball["non_stricked_time_remaining"] = 0.0
	ball.erase("previous_type_id")


func _reset_racket_to_ready_center() -> void:
	gameplay_state.racket_system.sync_from_state(gameplay_state)
	gameplay_state.racket_system.reset_to_ready_center()
	gameplay_state.racket_system.sync_to_state(gameplay_state)
	if state == STATE_READY or state == STATE_BALL_LOST:
		_attach_ready_balls()


func _advance_ball(ball: Dictionary, delta: float) -> void:
	if _is_ball_magnet_attached(ball):
		_update_magnet_attached_ball_position(ball, delta)
		return

	var previous_position: Vector2 = ball.get("position", Vector2.ZERO)
	var position := previous_position + Vector2(ball.get("velocity", Vector2.ZERO)) * delta
	var velocity: Vector2 = ball.get("velocity", Vector2.ZERO)
	var size := float(ball.get("size", BALL_SIZE))
	var wall_hit := false
	var fireball_wall_impact_side := FIREBALL_WALL_IMPACT_NONE

	if position.y <= BALL_TOP_Y:
		position.y = BALL_TOP_Y
		velocity.y = absf(velocity.y)
		wall_hit = true
		fireball_wall_impact_side = FIREBALL_WALL_IMPACT_TOP
	elif position.y + size >= BALL_BOTTOM_Y:
		position.y = BALL_BOTTOM_Y - size
		velocity.y = -absf(velocity.y)
		wall_hit = true
		fireball_wall_impact_side = FIREBALL_WALL_IMPACT_BOTTOM

	if position.x <= BALL_LEFT_X:
		position.x = BALL_LEFT_X
		velocity.x = absf(velocity.x)
		wall_hit = true
		fireball_wall_impact_side = FIREBALL_WALL_IMPACT_LEFT

	ball["position"] = position
	ball["velocity"] = velocity
	if wall_hit:
		_register_ball_speed_hit(ball)

	if _collide_with_racket(ball):
		position = ball.get("position", position)
		velocity = ball.get("velocity", velocity)

	if _collide_with_back_wall(ball):
		position = ball.get("position", position)
		velocity = ball.get("velocity", velocity)
		if fireball_wall_impact_side != FIREBALL_WALL_IMPACT_LEFT:
			fireball_wall_impact_side = FIREBALL_WALL_IMPACT_BACK
	elif position.x > BALL_LOST_X:
		_spawn_fireball_wall_impact_if_needed(ball, fireball_wall_impact_side)
		_queue_audio_event_at_x(SFX_EVENT_LIFE_LOST, BALL_LOST_X)
		ball["active"] = false
		return

	_spawn_fireball_wall_impact_if_needed(ball, fireball_wall_impact_side)

	if _ball_collides_with_enemies(ball):
		if _collide_ball_with_monsters(ball):
			return
		if _collide_ball_with_bees(ball):
			return
	_collide_ball_with_snake(ball)
	_collide_with_board(ball, previous_position)


func _update_ball_animation(delta: float) -> void:
	gameplay_state.ball_system.update_animation(delta)


func _update_ball_tracks(delta: float) -> void:
	gameplay_state.ball_track_pool.set_enabled(ball_tracks_enabled)
	gameplay_state.ball_track_pool.update(delta, balls, ball_size)


func _ensure_ball_track_slots() -> void:
	gameplay_state.ball_track_pool.ensure_slots(balls.size())


func _new_ball_track_slots() -> Array[Dictionary]:
	return gameplay_state.ball_track_pool.new_track_slots()


func _clear_ball_tracks() -> void:
	gameplay_state.ball_track_pool.clear()


func _clear_ball_track_slots(ball_index: int) -> void:
	gameplay_state.ball_track_pool.clear_slots(ball_index)


func _advance_ball_track_slots(ball_index: int, delta: float) -> void:
	gameplay_state.ball_track_pool.advance_slots(ball_index, delta)


func _spawn_ball_track(ball_index: int, ball: Dictionary) -> bool:
	if ball_index < 0:
		return false
	gameplay_state.ball_track_pool.ensure_slots(balls.size())
	if ball_index >= ball_tracks.size():
		return false
	return gameplay_state.ball_track_pool.spawn_track(ball_index, ball, ball_size)


func _ball_track_position(ball: Dictionary) -> Vector2:
	return gameplay_state.ball_track_pool.track_position(ball, ball_size)


func _update_level_ready_sequence(delta: float) -> void:
	gameplay_state.level_ready_system.update(delta)


func _clear_level_ready_sequence() -> void:
	gameplay_state.level_ready_system.clear()


func _skip_level_ready_prompt() -> void:
	gameplay_state.level_ready_system.skip_prompt()


func _auto_launch_ready_ball_if_needed() -> bool:
	if not gameplay_state.level_ready_system.consume_auto_launch_pending():
		return false
	return launch_ready_ball()


func _collide_with_racket(ball: Dictionary) -> bool:
	var rect := ball_rect(ball)
	var velocity: Vector2 = ball.get("velocity", Vector2.ZERO)
	if velocity.x <= 0.0:
		return false

	var current_racket_rects := racket_rects()
	for racket_index in range(current_racket_rects.size()):
		var racket_hit_rect: Rect2 = current_racket_rects[racket_index]
		if not rect.intersects(racket_hit_rect):
			continue
		if is_magnet_paddle_active():
			_attach_ball_to_magnet(ball, racket_hit_rect)
		else:
			_bounce_ball_from_racket(ball, racket_hit_rect)
		if racket_index == 0:
			_start_racket_hit_recoil()
		_queue_audio_event_at_x(SFX_EVENT_RACKET_BOUNCE, ball_rect(ball).position.x)
		return true

	return false


func _collide_with_back_wall(ball: Dictionary) -> bool:
	if not is_back_wall_active():
		return false

	var rect := ball_rect(ball)
	if rect.end.x < BACK_WALL_BOUNCE_X:
		return false

	var velocity: Vector2 = ball.get("velocity", Vector2.ZERO)
	if velocity.x <= 0.0:
		return false

	rect.position.x = BACK_WALL_BOUNCE_X - rect.size.x
	velocity.x = -absf(velocity.x)
	ball["position"] = rect.position
	ball["velocity"] = velocity
	_register_ball_speed_hit(ball)
	_queue_audio_event_at_x(SFX_EVENT_BACK_WALL_BOUNCE, rect.position.x)
	return true


func _collide_with_board(ball: Dictionary, previous_position: Vector2) -> bool:
	if board_state == null:
		return false
	if _is_non_stricked_ball(ball):
		return false

	var rect := ball_rect(ball)
	var hit := _first_board_hit(rect)
	if hit.is_empty():
		return false

	var column := int(hit["column"])
	var row := int(hit["row"])
	var tile_id := int(hit["tile_id"])
	var hit_result := _resolve_board_tile_hit(column, row, tile_id, _ball_force_breaks_board(ball))
	_apply_board_hit_result(hit_result)

	if _ball_pierces_board(ball):
		return true

	_reflect_from_tile(ball, previous_position, PlayfieldSpecScript.brick_rect(column, row))
	_register_ball_speed_hit(ball)
	return true


func _resolve_board_tile_hit(column: int, row: int, tile_id: int, force_break := false) -> Dictionary:
	var cleared_count := 0
	var did_change_board := false
	var score_delta := 0
	var audio_event := ""
	var chain_impact_cells: Array[Vector2i] = []
	var impact_effects_to_spawn: Array[Dictionary] = []
	var score_popups_to_spawn: Array[Dictionary] = []
	var brick_origin := PlayfieldSpecScript.brick_rect(column, row).position
	var hit_kind := BrickSemanticsScript.hit_kind(tile_id)
	if hit_kind == BrickSemanticsScript.HIT_KIND_CHAIN_EXPLOSION:
		var explosion_result: Dictionary = board_state.explode_at_with_result(column, row)
		cleared_count = int(explosion_result.get("cleared_count", 0))
		for cell: Vector2i in explosion_result.get("cleared_cells", []):
			chain_impact_cells.append(cell)
			score_popups_to_spawn.append({
				"position": PlayfieldSpecScript.brick_rect(cell.x, cell.y).position + SCORE_POPUP_CHAIN_OFFSET,
				"value": CHAIN_BRICK_SCORE,
			})
		did_change_board = cleared_count > 0
		if cleared_count > 0:
			score_delta = cleared_count * CHAIN_BRICK_SCORE
			audio_event = SFX_EVENT_CHAIN_EXPLOSION
	elif hit_kind == BrickSemanticsScript.HIT_KIND_FORCE_BREAK_ONLY:
		if force_break and board_state.clear_tile(column, row):
			cleared_count = 1
			did_change_board = true
			score_delta = HARD_BRICK_FORCE_SCORE
			audio_event = SFX_EVENT_BRICK_CLEAR
			score_popups_to_spawn.append({
				"position": brick_origin,
				"value": HARD_BRICK_FORCE_SCORE,
			})
			impact_effects_to_spawn.append({
				"position": brick_origin,
				"kind": IMPACT_EFFECT_KIND_HARD_BRICK_FORCE_BREAK,
			})
		else:
			audio_event = SFX_EVENT_HARD_BRICK_HIT
			impact_effects_to_spawn.append({
				"position": brick_origin,
				"kind": IMPACT_EFFECT_KIND_HARD_BRICK_IMPACT,
			})
	elif hit_kind == BrickSemanticsScript.HIT_KIND_DOWNGRADE:
		if force_break:
			if board_state.clear_tile(column, row):
				cleared_count = 1
				did_change_board = true
				score_delta = NORMAL_BRICK_SCORE
				audio_event = SFX_EVENT_BRICK_CLEAR
				score_popups_to_spawn.append({
					"position": brick_origin + SCORE_POPUP_BRICK_OFFSET,
					"value": NORMAL_BRICK_SCORE,
				})
				impact_effects_to_spawn.append({
					"position": brick_origin,
					"kind": IMPACT_EFFECT_KIND_HARD_BRICK_FORCE_BREAK,
				})
		else:
			var next_tile_id := BrickSemanticsScript.downgraded_tile_id(tile_id)
			if board_state.set_tile(column, row, next_tile_id):
				did_change_board = true
				score_delta = NORMAL_BRICK_SCORE
				audio_event = SFX_EVENT_BRICK_CLEAR
				score_popups_to_spawn.append({
					"position": brick_origin + SCORE_POPUP_BRICK_OFFSET,
					"value": NORMAL_BRICK_SCORE,
				})
	else:
		var regular_hit_result := _resolve_regular_brick_hit(column, row, tile_id)
		cleared_count = int(regular_hit_result.get("cleared_count", 0))
		did_change_board = bool(regular_hit_result.get("changed", false))
		score_delta = int(regular_hit_result.get("score", 0))
		audio_event = String(regular_hit_result.get("audio_event", ""))
		for effect: Dictionary in regular_hit_result.get("impact_effects", []):
			impact_effects_to_spawn.append(effect)
		for popup: Dictionary in regular_hit_result.get("score_popups", []):
			score_popups_to_spawn.append(popup)

	return {
		"changed": did_change_board,
		"cleared_count": cleared_count,
		"score": score_delta,
		"audio_event": audio_event,
		"source_x": brick_origin.x,
		"impact_effects": impact_effects_to_spawn,
		"chain_impact_cells": chain_impact_cells,
		"score_popups": score_popups_to_spawn,
	}


func _apply_board_hit_result(hit_result: Dictionary) -> void:
	var did_change_board := bool(hit_result.get("changed", false))
	var score_delta := int(hit_result.get("score", 0))
	if did_change_board:
		board_changed = true
	if score_delta > 0:
		award_score(score_delta)
	var popup_entries: Array = hit_result.get("score_popups", [])
	for popup: Dictionary in popup_entries:
		_spawn_score_popup(popup.get("position", Vector2.ZERO), int(popup.get("value", 0)))
	var impact_effects: Array = hit_result.get("impact_effects", [])
	for effect: Dictionary in impact_effects:
		_spawn_impact_effect(
			effect.get("position", Vector2.ZERO),
			int(effect.get("kind", IMPACT_EFFECT_KIND_EXPLOSION))
		)
	_spawn_chain_explosion_impact_effects(hit_result.get("chain_impact_cells", []))
	var audio_event := String(hit_result.get("audio_event", ""))
	if not audio_event.is_empty():
		if hit_result.has("source_x"):
			_queue_audio_event_at_x(audio_event, float(hit_result["source_x"]))
		else:
			_queue_audio_event(audio_event)


func _resolve_regular_brick_hit(column: int, row: int, tile_id: int) -> Dictionary:
	var bonus_result := _try_resolve_bonus_drop(column, row, tile_id)
	var action := String(bonus_result.get("action", "clear"))
	var brick_origin := PlayfieldSpecScript.brick_rect(column, row).position
	if action == "chain":
		return {
			"changed": true,
			"cleared_count": 0,
			"score": NORMAL_BRICK_SCORE,
			"audio_event": SFX_EVENT_BRICK_CLEAR,
			"impact_effects": [{
				"position": brick_origin,
				"kind": IMPACT_EFFECT_KIND_BONUS_BRICK_CLEAR,
			}],
			"score_popups": [{
				"position": brick_origin + SCORE_POPUP_BRICK_OFFSET,
				"value": NORMAL_BRICK_SCORE,
			}],
		}

	var cleared_count := 0
	if board_state.clear_tile(column, row):
		cleared_count = 1

	var impact_kind := IMPACT_EFFECT_KIND_BRICK_CLEAR
	if action == "spawn":
		if _spawn_falling_bonus(
			int(bonus_result.get("type_id", 0)),
			brick_origin
		):
			impact_kind = IMPACT_EFFECT_KIND_BONUS_BRICK_CLEAR
			_queue_audio_event_at_x(SFX_EVENT_BONUS_SPAWN, brick_origin.x)

	var impact_effects: Array[Dictionary] = []
	var score_popup_entries: Array[Dictionary] = []
	if cleared_count > 0:
		impact_effects.append({
			"position": brick_origin,
			"kind": impact_kind,
		})
		score_popup_entries.append({
			"position": brick_origin + SCORE_POPUP_BRICK_OFFSET,
			"value": NORMAL_BRICK_SCORE,
		})

	return {
		"changed": cleared_count > 0,
		"cleared_count": cleared_count,
		"score": NORMAL_BRICK_SCORE if cleared_count > 0 else 0,
		"audio_event": SFX_EVENT_BRICK_CLEAR if cleared_count > 0 else "",
		"impact_effects": impact_effects,
		"score_popups": score_popup_entries,
	}


func _try_resolve_bonus_drop(column: int, row: int, tile_id: int) -> Dictionary:
	return gameplay_state.bonus_system.resolve_drop_for_hit(column, row, tile_id, board_state)


func _first_board_hit(rect: Rect2) -> Dictionary:
	var grid_rect := PlayfieldSpecScript.grid_rect()
	if not rect.intersects(grid_rect):
		return {}

	var first_column := clampi(int(floorf((rect.position.x - grid_rect.position.x) / PlayfieldSpecScript.BRICK_SIZE.x)), 0, board_state.columns - 1)
	var last_column := clampi(int(floorf((rect.end.x - 0.001 - grid_rect.position.x) / PlayfieldSpecScript.BRICK_SIZE.x)), 0, board_state.columns - 1)
	var first_row := clampi(int(floorf((rect.position.y - grid_rect.position.y) / PlayfieldSpecScript.BRICK_SIZE.y)), 0, board_state.rows_count - 1)
	var last_row := clampi(int(floorf((rect.end.y - 0.001 - grid_rect.position.y) / PlayfieldSpecScript.BRICK_SIZE.y)), 0, board_state.rows_count - 1)

	for row in range(first_row, last_row + 1):
		for column in range(first_column, last_column + 1):
			var tile_id: int = board_state.tile_at(column, row)
			if BrickSemanticsScript.is_active_tile(tile_id):
				return {
					"column": column,
					"row": row,
					"tile_id": tile_id,
				}

	return {}


func _reflect_from_tile(ball: Dictionary, previous_position: Vector2, tile_rect: Rect2) -> void:
	var rect := ball_rect(ball)
	var previous_rect := Rect2(previous_position, rect.size)
	var velocity: Vector2 = ball.get("velocity", Vector2.ZERO)

	if previous_rect.end.x <= tile_rect.position.x or previous_rect.position.x >= tile_rect.end.x:
		velocity.x = -velocity.x
	else:
		velocity.y = -velocity.y

	ball["velocity"] = velocity


func _load_bonus_stock_from_level(level: KrakoutLevelData) -> void:
	gameplay_state.bonus_system.load_stock_from_level(level)


func _clear_bonus_run_state() -> void:
	gameplay_state.bonus_system.reset_run_state()
	_clear_timed_bonus_state()


func _reset_bonus_effect_state() -> void:
	racket_segment_count = RACKET_DEFAULT_SEGMENTS
	ball_size = BALL_SIZE
	ball_speed_scale = BALL_DEFAULT_SPEED_SCALE
	_clear_paddle_mode_state(false)
	gameplay_state.drunk_paddle_time_remaining = 0.0
	gameplay_state.has_last_racket_input = false
	gameplay_state.has_last_racket_x_input = false
	gameplay_state.last_racket_input_y = RACKET_READY_CENTER_Y
	gameplay_state.last_racket_input_x = RACKET_X
	racket_y = clampf(racket_y, RACKET_MIN_Y, RACKET_MAX_BOTTOM - current_racket_height())


func _reset_bonus_drop_gate() -> void:
	gameplay_state.bonus_system.reset_drop_gate()


func _clear_timed_bonus_state() -> void:
	back_wall_time_remaining = 0.0
	low_block_timer_time_remaining = 0.0
	gameplay_state.low_block_timer_started = false
	gameplay_state.projectile_system.reset()
	_clear_paddle_mode_state(false)
	_clear_racket_hit_recoil()
	gameplay_state.drunk_paddle_time_remaining = 0.0


func _update_bonus_timers(delta: float) -> void:
	gameplay_state.bonus_system.update_drop_gate(delta)
	if back_wall_time_remaining > 0.0:
		back_wall_time_remaining = maxf(0.0, back_wall_time_remaining - delta)
	gameplay_state.enemy_hazard_system.update_racket_stun(delta)
	if gameplay_state.drunk_paddle_time_remaining > 0.0:
		gameplay_state.drunk_paddle_time_remaining = maxf(0.0, gameplay_state.drunk_paddle_time_remaining - delta)
	_update_non_stricked_balls(delta)


func _arm_low_block_timer_if_needed() -> void:
	if gameplay_state.low_block_timer_started:
		return
	if state != STATE_PLAYING or board_state == null:
		return
	if board_state.remaining_required_bricks <= 0:
		return
	if board_state.remaining_required_bricks > LOW_BLOCK_TIMER_TRIGGER_REQUIRED_BRICKS:
		return

	gameplay_state.low_block_timer_started = true
	low_block_timer_time_remaining = LOW_BLOCK_TIMER_SECONDS


func _update_low_block_timer(delta: float) -> void:
	if not gameplay_state.low_block_timer_started:
		return
	if state != STATE_PLAYING:
		return
	if low_block_timer_time_remaining <= 0.0:
		return

	low_block_timer_time_remaining = maxf(0.0, low_block_timer_time_remaining - delta)
	if low_block_timer_time_remaining <= 0.0:
		_expire_low_block_timer()


func _expire_low_block_timer() -> void:
	if board_state == null:
		return

	var converted_count := 0
	if board_state.has_method("convert_required_bricks_to_chain_explosions"):
		converted_count = int(board_state.call(
			"convert_required_bricks_to_chain_explosions",
			LOW_BLOCK_TIMER_CHAIN_TILE_ID,
			LOW_BLOCK_TIMER_CHAIN_DELAY_SECONDS
		))
	if converted_count > 0:
		board_changed = true


func _update_non_stricked_balls(delta: float) -> void:
	if delta <= 0.0:
		return

	for index in range(balls.size()):
		var ball := balls[index]
		if not _is_non_stricked_ball(ball):
			continue

		var remaining := maxf(0.0, float(ball.get("non_stricked_time_remaining", 0.0)) - delta)
		if remaining > 0.0:
			ball["non_stricked_time_remaining"] = remaining
		else:
			_restore_ball_type_after_non_stricked(ball)
		balls[index] = ball


func _set_racket_visual_target(visual_mode: int) -> void:
	gameplay_state.racket_system.sync_from_state(gameplay_state)
	gameplay_state.racket_system.set_visual_target(visual_mode)
	gameplay_state.racket_system.sync_to_state(gameplay_state)


func _update_racket_visual(delta: float) -> void:
	gameplay_state.racket_system.sync_from_state(gameplay_state)
	gameplay_state.racket_system.update_visual(delta)
	gameplay_state.racket_system.sync_to_state(gameplay_state)


func _start_racket_hit_recoil() -> void:
	gameplay_state.racket_system.sync_from_state(gameplay_state)
	gameplay_state.racket_system.start_hit_recoil()
	gameplay_state.racket_system.sync_to_state(gameplay_state)


func _clear_racket_hit_recoil() -> void:
	gameplay_state.racket_system.sync_from_state(gameplay_state)
	gameplay_state.racket_system.clear_hit_recoil()
	gameplay_state.racket_system.sync_to_state(gameplay_state)


func _update_racket_hit_recoil(delta: float) -> void:
	gameplay_state.racket_system.sync_from_state(gameplay_state)
	gameplay_state.racket_system.update_hit_recoil(delta)
	gameplay_state.racket_system.sync_to_state(gameplay_state)


func _mouse_delta_x(mouse_x) -> float:
	gameplay_state.racket_system.sync_from_state(gameplay_state)
	return gameplay_state.racket_system.mouse_delta_x(mouse_x)


func _remember_racket_input(mouse_y: float, mouse_x = null) -> void:
	gameplay_state.racket_system.sync_from_state(gameplay_state)
	gameplay_state.racket_system.remember_input(mouse_y, mouse_x)
	gameplay_state.racket_system.sync_to_state(gameplay_state)


func _update_double_paddle_x(mouse_delta_x: float) -> void:
	gameplay_state.racket_system.sync_from_state(gameplay_state)
	gameplay_state.racket_system.update_double_paddle_x(mouse_delta_x)
	gameplay_state.racket_system.sync_to_state(gameplay_state)


func _clear_paddle_mode_state(release_attached_balls := true) -> void:
	if release_attached_balls:
		_release_magnet_attached_balls()
	else:
		_clear_all_magnet_attachments()
	gameplay_state.shooting_paddle_mode = PROJECTILE_MODE_DISABLED
	gameplay_state.single_shot_projectile_armed = false
	gameplay_state.racket_system.sync_from_state(gameplay_state)
	gameplay_state.racket_system.clear_paddle_mode_state()
	gameplay_state.racket_system.sync_to_state(gameplay_state)


func _is_ball_magnet_attached(ball: Dictionary) -> bool:
	return bool(ball.get("active", false)) and bool(ball.get("magnet_attached", false))


func _clear_ball_magnet_attachment(ball: Dictionary) -> void:
	ball["magnet_attached"] = false
	ball.erase("magnet_offset_y")
	ball.erase("magnet_release_speed")


func _clear_all_magnet_attachments() -> void:
	for index in range(balls.size()):
		var ball := balls[index]
		_clear_ball_magnet_attachment(ball)
		balls[index] = ball


func _update_magnet_attached_ball_positions(delta := 0.0) -> void:
	for index in range(balls.size()):
		var ball := balls[index]
		if _is_ball_magnet_attached(ball):
			_update_magnet_attached_ball_position(ball, delta)
			balls[index] = ball


func _update_magnet_attached_ball_position(ball: Dictionary, delta := 0.0) -> void:
	var rect := ball_rect(ball)
	var primary_racket := racket_rect()
	if delta > 0.0:
		if rect.position.y > primary_racket.end.y:
			rect.position.y = primary_racket.end.y
		elif rect.end.y < primary_racket.position.y:
			rect.position.y = primary_racket.position.y - rect.size.y

		var target_y := primary_racket.position.y + (primary_racket.size.y - rect.size.y) * 0.5
		rect.position.y = move_toward(
			rect.position.y,
			target_y,
			MAGNET_ATTACHED_Y_STEP_PER_UPDATE * ORIGINAL_UPDATE_HZ * delta
		)

		var target_x := primary_racket.position.x - rect.size.x
		if rect.position.x > target_x:
			rect.position.x = maxf(
				target_x,
				rect.position.x - MAGNET_ATTACHED_X_PULL_LEFT_STEP_PER_UPDATE * ORIGINAL_UPDATE_HZ * delta
			)
		elif rect.position.x < target_x:
			rect.position.x = minf(
				target_x,
				rect.position.x + MAGNET_ATTACHED_X_PULL_RIGHT_STEP_PER_UPDATE * ORIGINAL_UPDATE_HZ * delta
			)
	ball["position"] = rect.position
	ball["velocity"] = Vector2.ZERO


func _attach_ball_to_magnet(ball: Dictionary, racket_hit_rect: Rect2) -> void:
	var rect := ball_rect(ball)
	rect.position.x = racket_hit_rect.position.x - rect.size.x
	var speed := _target_speed_for_ball(ball)
	if speed <= 0.0:
		speed = _velocity_for_current_speed(DEFAULT_BALL_VELOCITY).length()
	ball["position"] = rect.position
	ball["velocity"] = Vector2.ZERO
	ball["target_speed"] = speed
	ball["magnet_release_speed"] = speed
	ball["magnet_attached"] = true


func _release_magnet_attached_balls() -> bool:
	var released_any := false
	for index in range(balls.size()):
		var ball := balls[index]
		if not _is_ball_magnet_attached(ball):
			continue

		_update_magnet_attached_ball_position(ball)
		var speed := float(ball.get("magnet_release_speed", _target_speed_for_ball(ball)))
		if speed <= 0.0:
			speed = _velocity_for_current_speed(DEFAULT_BALL_VELOCITY).length()
		_clear_ball_magnet_attachment(ball)
		ball["velocity"] = _racket_bounce_velocity(ball_rect(ball), racket_rect(), speed)
		ball["target_speed"] = speed
		balls[index] = ball
		released_any = true
	return released_any


func _bounce_ball_from_racket(ball: Dictionary, racket_hit_rect: Rect2) -> void:
	var rect := ball_rect(ball)
	var speed := _target_speed_for_ball(ball)
	rect.position.x = racket_hit_rect.position.x - rect.size.x
	ball["position"] = rect.position
	ball["velocity"] = _racket_bounce_velocity(rect, racket_hit_rect, speed)
	ball["target_speed"] = speed
	_register_ball_speed_hit(ball)


func _racket_bounce_velocity(ball_hit_rect: Rect2, racket_hit_rect: Rect2, speed: float) -> Vector2:
	return RacketRulesScript.bounce_velocity(ball_hit_rect, racket_hit_rect, speed)


func _bonus_intersects_any_racket(bonus: Dictionary) -> bool:
	var rect := bonus_rect(bonus)
	for current_racket_rect: Rect2 in racket_rects():
		if rect.intersects(current_racket_rect):
			return true
	return false


func _spawn_falling_bonus(type_id: int, position: Vector2) -> bool:
	return gameplay_state.bonus_system.spawn_falling(type_id, position)


func _update_falling_bonuses(delta: float) -> void:
	var bonus_events: Array[Dictionary] = gameplay_state.bonus_system.update_falling(
		delta,
		Callable(self, "_bonus_intersects_any_racket")
	)
	_queue_bonus_system_events(bonus_events)


func _advance_falling_bonus(bonus: Dictionary, delta: float) -> void:
	var bonus_event: Dictionary = gameplay_state.bonus_system.advance_falling_bonus(bonus, delta)
	if not bonus_event.is_empty():
		_queue_bonus_system_events([bonus_event])


func _queue_bonus_system_events(events: Array) -> void:
	for event: Dictionary in events:
		var action := String(event.get("action", ""))
		var source_x := float(event.get("source_x", 0.0))
		match action:
			"expire":
				_queue_audio_event_at_x(SFX_EVENT_BONUS_EXPIRE, source_x)
			"collect":
				_queue_audio_event_at_x(SFX_EVENT_BONUS_COLLECT, source_x)


func _update_projectile_fire(delta: float) -> void:
	gameplay_state.projectile_system.update_fire_cooldown(delta)


func _spawn_projectile(projectile_type: int) -> bool:
	var position := _projectile_spawn_position()
	if not gameplay_state.projectile_system.spawn_projectile(projectile_type, position):
		return false
	_queue_audio_event_at_x(SFX_EVENT_PROJECTILE_FIRE, position.x)
	return true


func _projectile_spawn_position() -> Vector2:
	var original_muzzle_y := floorf((RACKET_SEGMENT_PIXEL_STEP * float(racket_segment_count) + 9.0) * 0.5) - 1.0
	return Vector2(
		RACKET_X - 20.0,
		racket_y + original_muzzle_y
	)


func _update_projectiles(delta: float) -> void:
	gameplay_state.projectile_system.update(delta, Callable(self, "_resolve_projectile_collision"))


func _resolve_projectile_collision(projectile: Dictionary) -> bool:
	if _collide_projectile_with_snake(projectile):
		return true
	if _collide_projectile_with_monsters(projectile):
		return true
	if _collide_projectile_with_board(projectile):
		return int(projectile.get("type", PROJECTILE_TYPE_CONTINUOUS)) == PROJECTILE_TYPE_CONTINUOUS
	return false


func _advance_projectile(projectile: Dictionary, delta: float) -> void:
	gameplay_state.projectile_system.advance_projectile(projectile, delta)


func _collide_projectile_with_board(projectile: Dictionary) -> bool:
	if board_state == null:
		return false

	var hit := _first_board_hit(projectile_rect(projectile))
	if hit.is_empty():
		return false

	var hit_result := _resolve_board_tile_hit(
		int(hit["column"]),
		int(hit["row"]),
		int(hit["tile_id"]),
		int(projectile.get("type", PROJECTILE_TYPE_CONTINUOUS)) == PROJECTILE_TYPE_STRONG
	)
	_apply_board_hit_result(hit_result)
	_queue_audio_event_at_x(SFX_EVENT_PROJECTILE_HIT, projectile_rect(projectile).position.x)
	return true


func _enemy_hazard_ports() -> Dictionary:
	return gameplay_state.gameplay_context.to_ports()


func _current_racket_segment_count() -> int:
	return racket_segment_count


func _clear_monster_state() -> void:
	gameplay_state.enemy_hazard_system.clear(Callable(self, "_queue_audio_event"))
	impact_effects.clear()


func _clear_snake_state() -> void:
	gameplay_state.enemy_hazard_system.clear_snake_state()


func _update_snake_segments(delta: float) -> void:
	gameplay_state.enemy_hazard_system.update_snake_segments(delta, _enemy_hazard_ports())


func _collide_ball_with_snake(ball: Dictionary) -> bool:
	return gameplay_state.enemy_hazard_system.collide_ball_with_snake(ball, _enemy_hazard_ports())


func _collide_projectile_with_snake(projectile: Dictionary) -> bool:
	return gameplay_state.enemy_hazard_system.collide_projectile_with_snake(projectile, _enemy_hazard_ports())


func _has_active_snake_segments() -> bool:
	return gameplay_state.enemy_hazard_system.has_active_snake_segments()


func _update_monsters(delta: float) -> void:
	gameplay_state.enemy_hazard_system.update_monsters(delta, balls, _enemy_hazard_ports())


func _collide_ball_with_monsters(ball: Dictionary) -> bool:
	return gameplay_state.enemy_hazard_system.collide_ball_with_monsters(ball, balls, _enemy_hazard_ports())


func _collide_ball_with_bees(ball: Dictionary) -> bool:
	return gameplay_state.enemy_hazard_system.collide_ball_with_bees(ball, _enemy_hazard_ports())


func _ball_intersects_enemy_circle(ball: Dictionary, enemy_position: Vector2, enemy_radius: float) -> bool:
	var ball_position: Vector2 = ball.get("position", Vector2.ZERO)
	var ball_radius := float(ball.get("size", BALL_SIZE)) * 0.5
	return ball_position.distance_to(enemy_position) < ball_radius + enemy_radius


func _collide_projectile_with_monsters(projectile: Dictionary) -> bool:
	return gameplay_state.enemy_hazard_system.collide_projectile_with_monsters(projectile, _enemy_hazard_ports())


func _update_bees(delta: float) -> void:
	gameplay_state.enemy_hazard_system.update_bees(delta, _enemy_hazard_ports())


func _apply_racket_stun() -> void:
	gameplay_state.enemy_hazard_system.apply_racket_stun()


func _update_impact_effects(delta: float) -> void:
	gameplay_state.transient_vfx_pool.update_impact_effects(delta)


func _update_score_popups(delta: float) -> void:
	gameplay_state.transient_vfx_pool.update_score_popups(delta)


func _spawn_impact_effect(position: Vector2, kind: int) -> bool:
	return gameplay_state.transient_vfx_pool.spawn_impact_effect(position, kind)


func _spawn_score_popup(position: Vector2, value: int) -> bool:
	return gameplay_state.transient_vfx_pool.spawn_score_popup(position, value)


func _spawn_chain_explosion_impact_effects(cleared_cells: Array) -> int:
	var spawned_count := 0
	for cell: Vector2i in cleared_cells:
		var brick_origin := PlayfieldSpecScript.brick_rect(cell.x, cell.y).position
		if _spawn_impact_effect(brick_origin + CHAIN_EXPLOSION_IMPACT_OFFSET, IMPACT_EFFECT_KIND_CHAIN_EXPLOSION):
			spawned_count += 1
	return spawned_count


func _spawn_fireball_wall_impact_if_needed(ball: Dictionary, impact_side: int) -> bool:
	if impact_side == FIREBALL_WALL_IMPACT_NONE:
		return false
	if _ball_type(ball) != BALL_TYPE_FIREBALL:
		return false

	var rect := ball_rect(ball)
	var center := rect.get_center()
	var impact_anchor := Vector2.ZERO
	match impact_side:
		FIREBALL_WALL_IMPACT_LEFT:
			impact_anchor = Vector2(BALL_LEFT_X, center.y)
		FIREBALL_WALL_IMPACT_BACK:
			impact_anchor = Vector2(BACK_WALL_BOUNCE_X, center.y)
		FIREBALL_WALL_IMPACT_TOP:
			impact_anchor = Vector2(center.x, BALL_TOP_Y)
		FIREBALL_WALL_IMPACT_BOTTOM:
			impact_anchor = Vector2(center.x, BALL_BOTTOM_Y)
		_:
			return false

	return _spawn_impact_effect(
		impact_anchor + FIREBALL_WALL_IMPACT_OFFSET,
		IMPACT_EFFECT_KIND_EXPLOSION
	)


func _has_active_bee() -> bool:
	return gameplay_state.enemy_hazard_system.has_active_bee()


func _compact_impact_effects() -> void:
	gameplay_state.transient_vfx_pool.compact_impact_effects()


func _compact_score_popups() -> void:
	gameplay_state.transient_vfx_pool.compact_score_popups()


func _clear_score_popups() -> void:
	gameplay_state.transient_vfx_pool.clear_score_popups()


func _compact_projectiles() -> void:
	gameplay_state.projectile_system.compact()


func _compact_falling_bonuses() -> void:
	gameplay_state.bonus_system.compact_falling()


func bonus_rect(bonus: Dictionary) -> Rect2:
	return gameplay_state.bonus_system.bonus_rect(bonus)


func _push_bonus_stack(type_id: int) -> bool:
	return gameplay_state.bonus_system.push_stack(clampi(type_id, 0, BONUS_TYPE_COUNT - 1))


func _consume_next_bonus() -> void:
	gameplay_state.bonus_system.consume_next_stack_entry()


func _update_bonus_stack(delta: float) -> void:
	gameplay_state.bonus_system.update_stack(delta)


func _visible_bonus_type_for_stock_id(stock_id: int) -> int:
	return gameplay_state.bonus_system.visible_bonus_type_for_stock_id(stock_id)


func _apply_bonus_effect(type_id: int) -> Dictionary:
	match type_id:
		BONUS_ADD_STANDARD_BALL:
			var standard_ball_source_x := _ready_ball_position().x
			return {"effect": "add_standard_ball", "applied": _add_active_standard_ball(), "source_x": standard_ball_source_x}
		BONUS_ADD_FIREBALL:
			var fireball_source_x := _ready_ball_position().x
			return {"effect": "add_fireball", "applied": _add_active_fireball(), "source_x": fireball_source_x}
		BONUS_NON_STRICKED_BALLS:
			return _activate_non_stricked_balls()
		BONUS_DECREASE_BALL_SIZE:
			return _adjust_ball_size(-BALL_SIZE_STEP)
		BONUS_INCREASE_BALL_SIZE:
			return _adjust_ball_size(BALL_SIZE_STEP)
		BONUS_INCREASE_BALL_SPEED:
			return _adjust_ball_speed(BALL_SPEED_STEP)
		BONUS_DECREASE_BALL_SPEED:
			return _adjust_ball_speed(-BALL_SPEED_STEP)
		BONUS_SHOOTING_PADDLE_TIMED:
			return _activate_shooting_paddle_one_shot()
		BONUS_SHOOTING_PADDLE_CONTINUOUS:
			return _activate_shooting_paddle_continuous()
		BONUS_SHRINK_PADDLE:
			return _adjust_racket_segments(-RACKET_BONUS_STEP_SEGMENTS)
		BONUS_EXPAND_PADDLE:
			return _adjust_racket_segments(RACKET_BONUS_STEP_SEGMENTS)
		BONUS_DOUBLE_PADDLE:
			return _activate_double_paddle()
		BONUS_MAGNET_PADDLE:
			return _activate_magnet_paddle()
		BONUS_BACK_WALL:
			return _activate_back_wall()
		BONUS_EXTRA_LIFE:
			lives_remaining += 1
			return {"effect": "extra_life", "lives_remaining": lives_remaining}
		BONUS_DESTROY_ONE_BALL:
			return _activate_destroy_one_ball_bonus()
		BONUS_RANDOM_BONUS:
			return _activate_random_bonus()
		BONUS_ONE_STRIKE_BRICKS:
			return _activate_one_strike_bricks()
		BONUS_DRUNK_PADDLE:
			return _activate_drunk_paddle()
		BONUS_EXPAND_EXPLODING:
			return _activate_expand_exploding()
		BONUS_JUMP_TO_NEXT_LEVEL:
			_mark_level_complete(false)
			return {"effect": "jump_to_next_level"}
		BONUS_EXPLODE_ALL_EXPLODINGS:
			return _activate_explode_all_explodings()
	return {"effect": "unsupported"}


func _adjust_ball_size(delta_size: float) -> Dictionary:
	ball_size = clampf(ball_size + delta_size, BALL_MIN_SIZE, BALL_MAX_SIZE)
	for index in range(balls.size()):
		var ball := balls[index]
		ball["size"] = ball_size
		balls[index] = ball
	_update_magnet_attached_ball_positions()
	return {"effect": "ball_size", "ball_size": ball_size}


func _adjust_ball_speed(delta_speed: float) -> Dictionary:
	var previous_speed_scale := ball_speed_scale
	ball_speed_scale = clampf(ball_speed_scale + delta_speed, BALL_MIN_SPEED_SCALE, BALL_MAX_SPEED_SCALE)
	if previous_speed_scale <= 0.0:
		previous_speed_scale = ball_speed_scale

	var ratio := ball_speed_scale / previous_speed_scale
	for index in range(balls.size()):
		var ball := balls[index]
		var velocity: Vector2 = ball.get("velocity", Vector2.ZERO)
		var target_speed := _target_speed_for_ball(ball)
		if not velocity.is_zero_approx():
			ball["velocity"] = velocity * ratio
		ball["target_speed"] = target_speed * ratio
		ball["speed_scale"] = ball_speed_scale
		balls[index] = ball
	return {"effect": "ball_speed", "ball_speed_scale": ball_speed_scale}


func _activate_non_stricked_balls() -> Dictionary:
	var affected_count := 0
	for index in range(balls.size()):
		var ball := balls[index]
		if not bool(ball.get("active", false)):
			continue

		var current_type := _ball_type(ball)
		if current_type != BALL_TYPE_NON_STRICKED:
			ball["previous_type_id"] = current_type
		ball["type_id"] = BALL_TYPE_NON_STRICKED
		ball["non_stricked_time_remaining"] = NON_STRICKED_DURATION_SECONDS
		balls[index] = ball
		affected_count += 1
	return {
		"effect": "non_stricked_balls",
		"seconds_remaining": NON_STRICKED_DURATION_SECONDS,
		"affected": affected_count,
	}


func _adjust_racket_segments(delta_segments: int) -> Dictionary:
	gameplay_state.racket_system.sync_from_state(gameplay_state)
	gameplay_state.racket_system.adjust_segments(delta_segments)
	gameplay_state.racket_system.sync_to_state(gameplay_state)
	_update_magnet_attached_ball_positions()
	if state == STATE_READY or state == STATE_BALL_LOST:
		_attach_ready_balls()
	return {
		"effect": "racket_size",
		"racket_segment_count": racket_segment_count,
		"racket_height": current_racket_height(),
	}


func _activate_back_wall() -> Dictionary:
	back_wall_time_remaining = BACK_WALL_DURATION_SECONDS
	return {"effect": "back_wall", "seconds_remaining": back_wall_time_remaining}


func _activate_double_paddle() -> Dictionary:
	_clear_paddle_mode_state()
	gameplay_state.racket_system.sync_from_state(gameplay_state)
	gameplay_state.racket_system.double_paddle_active = true
	gameplay_state.racket_system.sync_to_state(gameplay_state)
	return {
		"effect": "double_paddle",
		"active": true,
		"racket_count": racket_rects().size(),
	}


func _activate_magnet_paddle() -> Dictionary:
	_clear_paddle_mode_state()
	gameplay_state.racket_system.sync_from_state(gameplay_state)
	gameplay_state.racket_system.magnet_paddle_active = true
	gameplay_state.racket_system.sync_to_state(gameplay_state)
	_set_racket_visual_target(RACKET_VISUAL_MODE_MAGNET)
	return {
		"effect": "magnet_paddle",
		"active": true,
	}


func _activate_drunk_paddle() -> Dictionary:
	gameplay_state.racket_system.sync_from_state(gameplay_state)
	gameplay_state.racket_system.drunk_time_remaining += DRUNK_PADDLE_DURATION_SECONDS
	gameplay_state.racket_system.sync_to_state(gameplay_state)
	return {
		"effect": "drunk_paddle",
		"seconds_remaining": gameplay_state.drunk_paddle_time_remaining,
	}


func _activate_one_strike_bricks() -> Dictionary:
	var changed_count := 0
	if board_state != null and board_state.has_method("weaken_all_for_one_strike"):
		changed_count = int(board_state.call("weaken_all_for_one_strike"))
	if changed_count > 0:
		board_changed = true
	return {
		"effect": "one_strike_bricks",
		"changed": changed_count,
	}


func _activate_random_bonus() -> Dictionary:
	var selected_type_id := BONUS_RANDOM_BONUS
	while selected_type_id == BONUS_RANDOM_BONUS:
		selected_type_id = gameplay_state.bonus_rng.next_mod(BONUS_TYPE_COUNT)

	var pushed := _push_bonus_stack(selected_type_id)
	return {
		"effect": "random_bonus",
		"selected_type_id": selected_type_id,
		"selected_name": bonus_type_name(selected_type_id),
		"stacked": pushed,
	}


func _activate_expand_exploding() -> Dictionary:
	var changed_count := 0
	if board_state != null and board_state.has_method("expand_exploding_tiles"):
		changed_count = int(board_state.call("expand_exploding_tiles"))
	if changed_count > 0:
		board_changed = true
	return {
		"effect": "expand_exploding",
		"changed": changed_count,
	}


func _activate_explode_all_explodings() -> Dictionary:
	var scheduled_count := 0
	if board_state != null and board_state.has_method("schedule_all_chain_explosions"):
		scheduled_count = int(board_state.call("schedule_all_chain_explosions"))
	return {
		"effect": "explode_all_explodings",
		"scheduled": scheduled_count,
	}


func _activate_shooting_paddle_one_shot() -> Dictionary:
	_clear_paddle_mode_state()
	gameplay_state.shooting_paddle_mode = PROJECTILE_MODE_DISABLED
	gameplay_state.single_shot_projectile_armed = true
	_set_racket_visual_target(RACKET_VISUAL_MODE_SHOOTING_ONE_SHOT)
	return {
		"effect": "shooting_paddle_one_shot",
		"armed": true,
	}


func _activate_shooting_paddle_continuous() -> Dictionary:
	_clear_paddle_mode_state()
	gameplay_state.shooting_paddle_mode = PROJECTILE_MODE_CONTINUOUS
	gameplay_state.single_shot_projectile_armed = false
	_set_racket_visual_target(RACKET_VISUAL_MODE_SHOOTING_CONTINUOUS)
	return {
		"effect": "shooting_paddle_continuous",
		"armed": true,
	}


func _activate_destroy_one_ball_bonus() -> Dictionary:
	var removed_ball := _pop_first_active_ball()
	if removed_ball.is_empty():
		return {"effect": "destroy_one_ball", "applied": false}

	var removed_position: Vector2 = removed_ball.get("position", Vector2.ZERO)
	_spawn_impact_effect(removed_position, IMPACT_EFFECT_KIND_EXPLOSION)
	return {"effect": "destroy_one_ball", "applied": true, "source_x": removed_position.x}


func _pop_first_active_ball() -> Dictionary:
	for index in range(balls.size()):
		var ball := balls[index]
		if bool(ball.get("active", false)):
			balls.remove_at(index)
			if index < ball_tracks.size():
				ball_tracks.remove_at(index)
			if index < gameplay_state.ball_track_spawn_elapsed.size():
				gameplay_state.ball_track_spawn_elapsed.remove_at(index)
			return ball.duplicate()
	return {}


func _velocity_for_current_speed(base_velocity: Vector2) -> Vector2:
	return base_velocity * (ball_speed_scale / BALL_DEFAULT_SPEED_SCALE)


func _target_speed_for_new_ball(velocity: Vector2) -> float:
	if not velocity.is_zero_approx():
		return velocity.length()
	return _velocity_for_current_speed(DEFAULT_BALL_VELOCITY).length()


func _target_speed_for_ball(ball: Dictionary) -> float:
	var target_speed := float(ball.get("target_speed", 0.0))
	if target_speed > 0.0:
		return target_speed

	var velocity: Vector2 = ball.get("velocity", Vector2.ZERO)
	if not velocity.is_zero_approx():
		return velocity.length()
	return _velocity_for_current_speed(DEFAULT_BALL_VELOCITY).length()


func _register_ball_speed_hit(ball: Dictionary) -> void:
	var hit_count := int(ball.get("speed_hit_count", 0)) + 1
	if hit_count <= ORIGINAL_BALL_SPEEDUP_HIT_LIMIT:
		ball["speed_hit_count"] = hit_count
		return

	ball["speed_hit_count"] = 0
	var target_speed := _target_speed_for_ball(ball)
	var max_speed := ORIGINAL_BALL_MAX_SPEED_PER_TICK * ORIGINAL_BALL_STEPS_PER_UPDATE * ORIGINAL_UPDATE_HZ
	if target_speed >= max_speed:
		ball["target_speed"] = max_speed
		return

	var next_speed := minf(
		max_speed,
		target_speed + ORIGINAL_BALL_SPEEDUP_PER_TICK * ORIGINAL_BALL_STEPS_PER_UPDATE * ORIGINAL_UPDATE_HZ
	)
	ball["target_speed"] = next_speed

	var velocity: Vector2 = ball.get("velocity", Vector2.ZERO)
	if not velocity.is_zero_approx():
		ball["velocity"] = velocity.normalized() * next_speed


func _handle_round_lost() -> void:
	lives_remaining -= 1
	if lives_remaining < 0:
		state = STATE_GAME_OVER
		gameplay_state.ball_system.clear()
		_clear_ball_tracks()
		gameplay_state.bonus_system.clear_falling()
		_clear_level_ready_sequence()
		_clear_timed_bonus_state()
		_clear_monster_state()
		_queue_audio_event(SFX_EVENT_GAME_OVER)
		return

	reset_round()
	start_level_ready_sequence(false)


func _update_displayed_score() -> void:
	if displayed_score + 10 < score:
		displayed_score += 10
	elif displayed_score < score:
		displayed_score += 1


func _mark_level_complete(play_audio_event := true) -> void:
	if state == STATE_LEVEL_COMPLETE:
		return
	state = STATE_LEVEL_COMPLETE
	if play_audio_event:
		_queue_audio_event(SFX_EVENT_LEVEL_COMPLETE)


func _queue_audio_event(event_name: String) -> void:
	gameplay_state.audio_event_queue.queue_event(event_name)


func _queue_audio_event_at_x(event_name: String, source_x: float) -> void:
	gameplay_state.audio_event_queue.queue_event_at_x(event_name, source_x)


func _queue_audio_event_with_pan100(event_name: String, pan100: float) -> void:
	gameplay_state.audio_event_queue.queue_event_with_pan100(event_name, pan100)


func _queue_audio_event_payload(event_payload: Dictionary) -> void:
	gameplay_state.audio_event_queue.queue_payload(event_payload)
