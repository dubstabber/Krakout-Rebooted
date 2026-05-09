extends RefCounted
class_name KrakoutGameSession

const BoardStateScript := preload("res://src/gameplay/krakout_board_state.gd")
const BrickSemanticsScript := preload("res://src/gameplay/krakout_brick_semantics.gd")
const RandomScript := preload("res://src/gameplay/krakout_random.gd")
const PlayfieldSpecScript := preload("res://src/playfield/krakout_playfield_spec.gd")

const STATE_READY := "ready"
const STATE_PLAYING := "playing"
const STATE_BALL_LOST := "ball_lost"
const STATE_LEVEL_COMPLETE := "level_complete"
const STATE_GAME_OVER := "game_over"

const MAX_BALLS := 5
const INITIAL_LIVES := 3
const NORMAL_BRICK_SCORE := 5
const CHAIN_BRICK_SCORE := 15
const HARD_BRICK_FORCE_SCORE := 30
const BRICK_SCORE := CHAIN_BRICK_SCORE
const EXTRA_LIFE_SCORE_STEP := 20000
const RACKET_X := 570.0
const RACKET_WIDTH := 16.0
const RACKET_HEIGHT := 74.0
const RACKET_SEGMENT_PIXEL_STEP := 5.0
const RACKET_SEGMENT_MARGIN := 24.0
const RACKET_DEFAULT_SEGMENTS := 10
const RACKET_MIN_SEGMENTS := 1
const RACKET_SHRINK_LIMIT_SEGMENTS := 3
const RACKET_EXPAND_LIMIT_SEGMENTS := 36
const RACKET_MAX_SEGMENTS := 37
const RACKET_BONUS_STEP_SEGMENTS := 3
const RACKET_MIN_Y := PlayfieldSpecScript.WALL_INNER_TOP_Y
const RACKET_MAX_BOTTOM := PlayfieldSpecScript.WALL_INNER_BOTTOM_Y
# sub_40E580 stores racket top y = 221 for the default 74 px racket, centered
# inside the original 63..453 playfield span.
const RACKET_READY_CENTER_Y := (PlayfieldSpecScript.WALL_INNER_TOP_Y + PlayfieldSpecScript.WALL_INNER_BOTTOM_Y) * 0.5
const RACKET_READY_DEFAULT_Y := RACKET_READY_CENTER_Y - RACKET_HEIGHT * 0.5
const BALL_SIZE := 18.0
const BALL_MIN_SIZE := 10.0
const BALL_MAX_SIZE := 42.0
const BALL_SIZE_STEP := 8.0
const BALL_FRAME_COUNT := 10
const BALL_TYPE_STANDARD := 0
const BALL_TYPE_FIREBALL := 1
const BALL_TYPE_NON_STRICKED := 2
const BALL_DEFAULT_SPEED_SCALE := 2.0
const BALL_MIN_SPEED_SCALE := 2.0
const BALL_MAX_SPEED_SCALE := 6.0
const BALL_SPEED_STEP := 1.0
const NON_STRICKED_DURATION_SECONDS := 8.0
const BALL_TOP_Y := PlayfieldSpecScript.WALL_INNER_TOP_Y
const BALL_BOTTOM_Y := PlayfieldSpecScript.WALL_INNER_BOTTOM_Y
const BALL_LEFT_X := PlayfieldSpecScript.WALL_INNER_LEFT_X
const BALL_LOST_X := 640.0
const BACK_WALL_BOUNCE_X := PlayfieldSpecScript.WALL_INNER_RIGHT_X
# sub_40E580 creates the ready ball at racket_x - 20 with a 20 px ball crop.
const READY_BALL_GAP := 2.0
const ORIGINAL_UPDATE_HZ := 50.0
# sub_4012D0 gates Balls.tga frame changes on timeGetTime() + 100 ms.
const BALL_FRAME_SECONDS := 0.1
const BALL_TRACK_SLOT_COUNT := 50
const BALL_TRACK_FRAME_COUNT := 12
const BALL_TRACK_SPAWN_SECONDS := 0.03
const BALL_TRACK_FRAME_SECONDS := 0.03
const ORIGINAL_BALL_STEPS_PER_UPDATE := 3.0
# sub_40DAF0 invokes the original enemy updater three times per gameplay step.
const ORIGINAL_ENEMY_STEPS_PER_UPDATE := 3.0
const ORIGINAL_ENEMY_UPDATE_HZ := ORIGINAL_UPDATE_HZ * ORIGINAL_ENEMY_STEPS_PER_UPDATE
const ORIGINAL_DEFAULT_BALL_SPEED_PER_TICK := 2.5
# sub_401A30 initializes the ready ball at table index 250. sub_401000 stores cos at
# +15 and sin at +375, and sub_4012D0 moves balls with x += sin(index), y -= cos(index).
const DEFAULT_BALL_LAUNCH_TABLE_INDEX := 250
const DEFAULT_BALL_LAUNCH_DIRECTION := Vector2(-0.93969262, 0.34202015)
const ORIGINAL_BALL_SPEEDUP_HIT_LIMIT := 100
const ORIGINAL_BALL_SPEEDUP_PER_TICK := 0.3
const ORIGINAL_BALL_MAX_SPEED_PER_TICK := 6.0
const DEFAULT_BALL_VELOCITY := DEFAULT_BALL_LAUNCH_DIRECTION \
	* ORIGINAL_DEFAULT_BALL_SPEED_PER_TICK \
	* ORIGINAL_BALL_STEPS_PER_UPDATE \
	* ORIGINAL_UPDATE_HZ
const RACKET_BOUNCE_MAX_Y_SPEED := 180.0
const BONUS_TYPE_COUNT := 22
const BONUS_SELECTOR_COUNT := 23
const MAX_FALLING_BONUSES := 20
const MAX_STACKED_BONUSES := 16
const BONUS_DROP_GATE_SECONDS := 3.0
const BONUS_SIZE := 32.0
const ORIGINAL_BONUS_STEPS_PER_UPDATE := 3.0
const ORIGINAL_BONUS_SUBSTEP_HZ := ORIGINAL_UPDATE_HZ * ORIGINAL_BONUS_STEPS_PER_UPDATE
# sub_402D10 advances falling bonuses by 1.5 px and 3 degrees per call; sub_40DAF0
# calls it three times per original 50 Hz gameplay step.
const BONUS_STEP_X := 1.5
const BONUS_WAVE_SCALE := 1.0 / 12.0
const BONUS_ANGLE_STEP := 3
const BONUS_MIN_Y := 10.0
const BONUS_MAX_Y := 438.0
const BONUS_EXPIRE_X := 600.0
const BONUS_ANIMATION_FRAME_COUNT := 10
const BONUS_FALLING_FRAME_SECONDS := 0.1
const BONUS_STACK_FRAME_SECONDS := 0.07
const BONUS_POINTER_FRAME_SECONDS := 0.05
const BACK_WALL_DURATION_SECONDS := 30.0
const BACK_WALL_STATUS_ICON_INDEX := 3
const LEVEL_READY_SEQUENCE_SECONDS := 30.0
const LEVEL_READY_STATUS_ICON_INDEX := 2
const RACKET_STUN_STATUS_ICON_INDEX := 1
# sub_40F940 draws Roller.tga as a 20x390 strip at x = 47 + reveal_offset
# and advances ten source frames while revealing the 20 board columns.
const LEVEL_READY_ROLLER_FRAME_COUNT := 10
const LEVEL_READY_ROLLER_STEP_SECONDS := 1.0 / ORIGINAL_UPDATE_HZ
const LEVEL_READY_ROLLER_STEP_EPSILON := 0.000001
const LEVEL_READY_ROLLER_STEP_PIXELS := 4.0
const LEVEL_READY_ROLLER_SOURCE_SIZE := Vector2(20, 390)
const LEVEL_READY_ROLLER_POSITION := Vector2(47, 63)
const LEVEL_READY_ROLLER_TRAVEL_PIXELS := 380.0
const LEVEL_READY_ANIMATION_SECONDS := LEVEL_READY_ROLLER_TRAVEL_PIXELS / LEVEL_READY_ROLLER_STEP_PIXELS * LEVEL_READY_ROLLER_STEP_SECONDS
const MAX_PROJECTILES := 10
const PROJECTILE_FIRE_COOLDOWN_SECONDS := 0.25
const PROJECTILE_STEP_X := 7.0
const PROJECTILE_EXPIRE_X := 27.0
const PROJECTILE_SIZE := Vector2(30, 13)
const PROJECTILE_TRAIL_OFFSET := Vector2(26, 0)
const PROJECTILE_HEAD_FRAME_COUNT := 5
const PROJECTILE_TRAIL_FRAME_COUNT := 10
const PROJECTILE_HEAD_FRAME_SECONDS := 0.05
const PROJECTILE_TRAIL_FRAME_SECONDS := 0.01
const PROJECTILE_TYPE_STRONG := 0
const PROJECTILE_TYPE_CONTINUOUS := 1
const PROJECTILE_MODE_DISABLED := 0
const PROJECTILE_MODE_CONTINUOUS := 1
const RACKET_VISUAL_MODE_NORMAL := 0
const RACKET_VISUAL_MODE_SHOOTING_CONTINUOUS := 1
const RACKET_VISUAL_MODE_SHOOTING_ONE_SHOT := 2
const RACKET_VISUAL_MODE_MAGNET := 3
const RACKET_VISUAL_FRAME_SECONDS := 0.05
const RACKET_VISUAL_MAX_FRAME := 4
const RACKET_MAGNET_VISUAL_FRAME_COUNT := 20
const MAGNET_ATTACHED_Y_STEP_PER_UPDATE := 1.0
const MAGNET_ATTACHED_X_PULL_LEFT_STEP_PER_UPDATE := 2.0
const MAGNET_ATTACHED_X_PULL_RIGHT_STEP_PER_UPDATE := 1.0
const DOUBLE_PADDLE_OFFSET_X := -20.0
const DOUBLE_PADDLE_MIN_X := 77.0
const DOUBLE_PADDLE_MOUSE_X_MULTIPLIER := 2.0
const DRUNK_PADDLE_DURATION_SECONDS := 30.0
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
const BONUS_ADD_STANDARD_BALL := 0
const BONUS_ADD_FIREBALL := 1
const BONUS_NON_STRICKED_BALLS := 2
const BONUS_DECREASE_BALL_SIZE := 3
const BONUS_INCREASE_BALL_SIZE := 4
const BONUS_INCREASE_BALL_SPEED := 5
const BONUS_DECREASE_BALL_SPEED := 6
const BONUS_SHOOTING_PADDLE_TIMED := 7
const BONUS_SHOOTING_PADDLE_CONTINUOUS := 8
const BONUS_SHRINK_PADDLE := 9
const BONUS_EXPAND_PADDLE := 10
const BONUS_DOUBLE_PADDLE := 11
const BONUS_MAGNET_PADDLE := 12
const BONUS_BACK_WALL := 13
const BONUS_EXTRA_LIFE := 14
const BONUS_DESTROY_ONE_BALL := 15
const BONUS_RANDOM_BONUS := 16
const BONUS_ONE_STRIKE_BRICKS := 17
const BONUS_DRUNK_PADDLE := 18
const BONUS_EXPAND_EXPLODING := 19
const BONUS_JUMP_TO_NEXT_LEVEL := 20
const BONUS_EXPLODE_ALL_EXPLODINGS := 21
const BONUS_TYPE_NAMES := [
	"Add standard Ball",
	"Add FireBall",
	"All Balls non stricked (8 sec)",
	"Decrease all Ball size",
	"Increase all Ball size",
	"Increase all Ball speed",
	"Decrease all Ball speed",
	"Shooting Paddle (on time shoot)",
	"Shooting Paddle (continiously)",
	"Shrink Paddle size",
	"Expand Paddle size",
	"Double Paddle",
	"Magnet Paddle",
	"Back Wall (30 sec)",
	"Extra Life",
	"Destroy one Ball",
	"Random Bonus",
	"All Bricks destroy by one strike",
	"Drunk Paddle",
	"Expand Exploding",
	"Jump to Next Level",
	"Explode all Explodings",
]
const SUPPORTED_BONUS_EFFECTS := {
	BONUS_ADD_STANDARD_BALL: true,
	BONUS_ADD_FIREBALL: true,
	BONUS_NON_STRICKED_BALLS: true,
	BONUS_DECREASE_BALL_SIZE: true,
	BONUS_INCREASE_BALL_SIZE: true,
	BONUS_INCREASE_BALL_SPEED: true,
	BONUS_DECREASE_BALL_SPEED: true,
	BONUS_SHOOTING_PADDLE_TIMED: true,
	BONUS_SHOOTING_PADDLE_CONTINUOUS: true,
	BONUS_SHRINK_PADDLE: true,
	BONUS_EXPAND_PADDLE: true,
	BONUS_DOUBLE_PADDLE: true,
	BONUS_MAGNET_PADDLE: true,
	BONUS_BACK_WALL: true,
	BONUS_EXTRA_LIFE: true,
	BONUS_DESTROY_ONE_BALL: true,
	BONUS_RANDOM_BONUS: true,
	BONUS_ONE_STRIKE_BRICKS: true,
	BONUS_DRUNK_PADDLE: true,
	BONUS_EXPAND_EXPLODING: true,
	BONUS_JUMP_TO_NEXT_LEVEL: true,
	BONUS_EXPLODE_ALL_EXPLODINGS: true,
}
const CHAIN_SELECTOR_TILE_IDS := [68, 43]
const BONUS_DISPLAY_INCREMENT_IDS := {
	1: true,
	11: true,
	14: true,
	16: true,
	17: true,
	18: true,
	19: true,
	20: true,
	21: true,
}
const SFX_EVENT_BALL_LAUNCH := "ball_launch"
const SFX_EVENT_RACKET_BOUNCE := "racket_bounce"
const SFX_EVENT_BACK_WALL_BOUNCE := "back_wall_bounce"
const SFX_EVENT_BRICK_CLEAR := "brick_clear"
const SFX_EVENT_HARD_BRICK_HIT := "hard_brick_hit"
const SFX_EVENT_CHAIN_EXPLOSION := "chain_explosion"
const SFX_EVENT_BONUS_SPAWN := "bonus_spawn"
const SFX_EVENT_BONUS_EXPIRE := "bonus_expire"
const SFX_EVENT_BONUS_COLLECT := "bonus_collect"
const SFX_EVENT_BONUS_APPLY := "bonus_apply"
const SFX_EVENT_BONUS_ADD_BALL_APPLY := "bonus_add_ball_apply"
const SFX_EVENT_BONUS_DESTROY_BALL_APPLY := "bonus_destroy_ball_apply"
const SFX_EVENT_BONUS_JUMP_LEVEL_APPLY := "bonus_jump_level_apply"
const SFX_EVENT_PROJECTILE_FIRE := "projectile_fire"
const SFX_EVENT_PROJECTILE_HIT := "projectile_hit"
const SFX_EVENT_MONSTER_SPAWN := "monster_spawn"
const SFX_EVENT_MONSTER_EXPIRE := "monster_expire"
const SFX_EVENT_MONSTER_HIT := "monster_hit"
const SFX_EVENT_BEE_SPAWN := "bee_spawn"
const SFX_EVENT_BEE_STOP := "bee_stop"
const SFX_EVENT_LIFE_LOST := "life_lost"
const SFX_EVENT_LEVEL_READY := "level_ready"
const SFX_EVENT_LEVEL_COMPLETE := "level_complete"
const SFX_EVENT_GAME_OVER := "game_over"
const SFX_PAN_SOURCE_SCALE := 0.3125
const SFX_PAN_SOURCE_OFFSET := -100.0
const SFX_PAN_MIN := -100.0
const SFX_PAN_MAX := 100.0
const SFX_BEE_SPAWN_PAN100 := -100.0

var board_state
var state := STATE_READY
var balls: Array[Dictionary] = []
var ball_tracks_enabled := true
var ball_tracks: Array = []
var racket_y := RACKET_MIN_Y
var racket_segment_count := RACKET_DEFAULT_SEGMENTS
var ball_size := BALL_SIZE
var ball_speed_scale := BALL_DEFAULT_SPEED_SCALE
var board_changed := false
var score := 0
var displayed_score := 0
var best_score := 0
var lives_remaining := INITIAL_LIVES
var points_to_next_extra_life := EXTRA_LIFE_SCORE_STEP
var display_level_number := 1
var bonus_stock_counts: Array[int] = []
var remaining_bonus_stock := 0
var falling_bonuses: Array[Dictionary] = []
var bonus_stack: Array[Dictionary] = []
var bonus_pointer_frame := 0
var projectiles: Array[Dictionary] = []
var monsters: Array[Dictionary] = []
var bees: Array[Dictionary] = []
var snake_segments: Array[Dictionary] = []
var impact_effects: Array[Dictionary] = []
var score_popups: Array[Dictionary] = []
var back_wall_time_remaining := 0.0
var level_ready_time_remaining := 0.0
var _drunk_paddle_time_remaining := 0.0
var _bonus_rng = RandomScript.new()
var _ball_animation_rng = RandomScript.new(31415)
var _bonus_animation_rng = RandomScript.new(31415)
var _monster_rng = RandomScript.new(31415)
var _collision_rng = RandomScript.new(31415)
var _ball_track_rng = RandomScript.new(31415)
var _bonus_drop_cooldown := BONUS_DROP_GATE_SECONDS
var _bee_spawn_delay_remaining := BEE_SPAWN_DELAY_MAX_SECONDS
var _racket_stun_time_remaining := 0.0
var _bonus_pointer_elapsed := 0.0
var _projectile_fire_cooldown := 0.0
var _shooting_paddle_mode := PROJECTILE_MODE_DISABLED
var racket_visual_mode := RACKET_VISUAL_MODE_NORMAL
var racket_visual_frame := 0
var _racket_visual_target_mode := RACKET_VISUAL_MODE_NORMAL
var _racket_visual_elapsed := 0.0
var _single_shot_projectile_armed := false
var _double_paddle_active := false
var _double_paddle_x := RACKET_X + DOUBLE_PADDLE_OFFSET_X
var _magnet_paddle_active := false
var _last_racket_input_y := RACKET_READY_CENTER_Y
var _last_racket_input_x := RACKET_X
var _has_last_racket_input := false
var _has_last_racket_x_input := false
var _monster_spawn_cooldown := MONSTER_SPAWN_INTERVAL_SECONDS
var _level_ready_animation_time_remaining := 0.0
var _level_ready_roller_offset := 0.0
var _level_ready_roller_frame := 0
var _level_ready_roller_step_elapsed := 0.0
var _level_ready_auto_launch_pending := false
var _ball_track_spawn_elapsed: Array[float] = []
var _snake_update_elapsed := 0.0
var _audio_events: Array[Dictionary] = []


func _init() -> void:
	_bonus_rng.set_seed(Time.get_ticks_msec())


func load_level(level: KrakoutLevelData) -> void:
	var next_display_level := 1
	if level != null and level.level_number > 0:
		next_display_level = level.level_number
	start_run(level, next_display_level)


func start_run(level: KrakoutLevelData, selected_display_level_number: int = 1, starting_best_score: int = 0) -> void:
	_audio_events.clear()
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
	falling_bonuses.clear()
	_clear_monster_state()
	_clear_timed_bonus_state()
	_reset_bonus_drop_gate()
	_load_board_for_level(level)
	reset_round()


func set_board_state(state_value) -> void:
	_audio_events.clear()
	board_state = state_value
	_load_bonus_stock_from_level(board_state.source_level if board_state != null else null)
	falling_bonuses.clear()
	_clear_timed_bonus_state()
	_reset_bonus_drop_gate()
	reset_round()


func reset_round() -> void:
	state = STATE_READY
	board_changed = false
	balls.clear()
	_clear_ball_tracks()
	falling_bonuses.clear()
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
	var visible: Array[Dictionary] = []
	for popup: Dictionary in score_popups:
		if bool(popup.get("active", false)):
			visible.append(popup.duplicate())
	return visible


func visible_lives() -> int:
	return max(0, lives_remaining)


func _load_board_for_level(level: KrakoutLevelData) -> void:
	board_state = BoardStateScript.new() if level != null else null
	if board_state != null:
		board_state.load_level(level)
	_load_bonus_stock_from_level(level)


func move_racket_to(mouse_y: float, mouse_x = null) -> void:
	if is_racket_stunned():
		_remember_racket_input(mouse_y, mouse_x)
		return
	if is_level_ready_prompt_visible():
		_remember_racket_input(mouse_y, mouse_x)
		return
	var current_height := current_racket_height()
	var target_center_y := mouse_y
	var mouse_delta_x := _mouse_delta_x(mouse_x)
	if is_drunk_paddle_active():
		if _has_last_racket_input:
			target_center_y = racket_y + current_height * 0.5 - (mouse_y - _last_racket_input_y)
		else:
			target_center_y = racket_y + current_height * 0.5
		mouse_delta_x = -mouse_delta_x
	_update_double_paddle_x(mouse_delta_x)
	_remember_racket_input(mouse_y, mouse_x)
	racket_y = clampf(target_center_y - current_height * 0.5, RACKET_MIN_Y, RACKET_MAX_BOTTOM - current_height)
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

	if board_state != null and board_state.is_complete():
		_mark_level_complete()
	elif active_count <= 0:
		_handle_round_lost()


func consume_board_changed() -> bool:
	var changed := board_changed
	board_changed = false
	return changed


func visible_balls() -> Array[Dictionary]:
	var visible: Array[Dictionary] = []
	for ball: Dictionary in balls:
		if bool(ball.get("active", false)):
			visible.append(ball)
	return visible


func set_ball_tracks_enabled(is_enabled: bool) -> void:
	ball_tracks_enabled = is_enabled
	if not ball_tracks_enabled:
		_clear_ball_tracks()


func are_ball_tracks_enabled() -> bool:
	return ball_tracks_enabled


func visible_ball_tracks() -> Array[Dictionary]:
	var visible: Array[Dictionary] = []
	if not ball_tracks_enabled:
		return visible

	for slots in ball_tracks:
		for track: Dictionary in slots:
			if bool(track.get("active", false)):
				visible.append(track.duplicate())
	return visible


func visible_falling_bonuses() -> Array[Dictionary]:
	var visible: Array[Dictionary] = []
	for bonus: Dictionary in falling_bonuses:
		if bool(bonus.get("active", false)):
			visible.append(bonus.duplicate())
	return visible


func visible_projectiles() -> Array[Dictionary]:
	var visible: Array[Dictionary] = []
	for projectile: Dictionary in projectiles:
		if bool(projectile.get("active", false)):
			visible.append(projectile.duplicate())
	return visible


func visible_monsters() -> Array[Dictionary]:
	var visible: Array[Dictionary] = []
	for monster: Dictionary in monsters:
		if bool(monster.get("active", false)):
			visible.append(monster.duplicate())
	return visible


func visible_bees() -> Array[Dictionary]:
	var visible: Array[Dictionary] = []
	for bee: Dictionary in bees:
		if bool(bee.get("active", false)):
			visible.append(bee.duplicate())
	return visible


func visible_snake_segments() -> Array[Dictionary]:
	var visible: Array[Dictionary] = []
	for segment: Dictionary in snake_segments:
		if bool(segment.get("active", false)):
			visible.append(segment.duplicate())
		else:
			break
	return visible


func visible_impact_effects() -> Array[Dictionary]:
	var visible: Array[Dictionary] = []
	for effect: Dictionary in impact_effects:
		if bool(effect.get("active", false)):
			visible.append(effect.duplicate())
	return visible


func bonus_stack_entries() -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	for entry: Dictionary in bonus_stack:
		entries.append(entry.duplicate())
	return entries


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
	var removed_entry: Dictionary = bonus_stack[index].duplicate()
	bonus_stack.remove_at(index)
	var type_id := int(removed_entry.get("type_id", -1))
	return {
		"status": "removed",
		"index": index,
		"type_id": type_id,
		"name": bonus_type_name(type_id),
		"count": bonus_stack.size(),
	}


func debug_clear_bonus_stack() -> int:
	var removed_count := bonus_stack.size()
	bonus_stack.clear()
	return removed_count


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
			"value": ceili(level_ready_time_remaining),
		})
	if is_racket_stunned():
		indicators.append({
			"icon_index": RACKET_STUN_STATUS_ICON_INDEX,
			"value": ceili(_racket_stun_time_remaining),
		})
	if is_back_wall_active():
		indicators.append({
			"icon_index": BACK_WALL_STATUS_ICON_INDEX,
			"value": ceili(back_wall_time_remaining),
		})
	return indicators


func start_level_ready_sequence(queue_audio := true) -> void:
	_reset_racket_to_ready_center()
	level_ready_time_remaining = LEVEL_READY_SEQUENCE_SECONDS
	_level_ready_animation_time_remaining = LEVEL_READY_ANIMATION_SECONDS
	_level_ready_roller_offset = 0.0
	_level_ready_roller_frame = 0
	_level_ready_roller_step_elapsed = 0.0
	_level_ready_auto_launch_pending = false
	if queue_audio:
		_queue_audio_event(SFX_EVENT_LEVEL_READY)


func is_level_ready_sequence_active() -> bool:
	return level_ready_time_remaining > 0.0


func is_level_ready_prompt_visible() -> bool:
	return _level_ready_animation_time_remaining > 0.0


func is_racket_visible() -> bool:
	return not is_level_ready_prompt_visible()


func are_balls_visible() -> bool:
	return not is_level_ready_prompt_visible()


func level_ready_animation_progress() -> float:
	if LEVEL_READY_ROLLER_TRAVEL_PIXELS <= 0.0:
		return 1.0
	return clampf(_level_ready_roller_offset / LEVEL_READY_ROLLER_TRAVEL_PIXELS, 0.0, 1.0)


func level_ready_roller_layout() -> Dictionary:
	if not is_level_ready_prompt_visible():
		return {"visible": false}

	var roller_position := LEVEL_READY_ROLLER_POSITION + Vector2(_level_ready_roller_offset, 0.0)
	return {
		"visible": true,
		"position": roller_position,
		"destination": Rect2(roller_position, LEVEL_READY_ROLLER_SOURCE_SIZE),
		"source": Rect2(Vector2(_level_ready_roller_frame * LEVEL_READY_ROLLER_SOURCE_SIZE.x, 0), LEVEL_READY_ROLLER_SOURCE_SIZE),
		"frame": _level_ready_roller_frame,
		"progress": level_ready_animation_progress(),
	}


func is_back_wall_active() -> bool:
	return back_wall_time_remaining > 0.0


func is_shooting_paddle_active() -> bool:
	return _shooting_paddle_mode == PROJECTILE_MODE_CONTINUOUS


func is_single_shot_paddle_armed() -> bool:
	return _single_shot_projectile_armed


func is_double_paddle_active() -> bool:
	return _double_paddle_active


func is_magnet_paddle_active() -> bool:
	return _magnet_paddle_active


func is_drunk_paddle_active() -> bool:
	return _drunk_paddle_time_remaining > 0.0


func drunk_paddle_time_remaining() -> float:
	return _drunk_paddle_time_remaining


func magnet_attached_ball_count() -> int:
	var count := 0
	for ball: Dictionary in balls:
		if _is_ball_magnet_attached(ball):
			count += 1
	return count


func is_racket_stunned() -> bool:
	return _racket_stun_time_remaining > 0.0


func current_racket_visual_mode() -> int:
	return racket_visual_mode


func current_racket_visual_frame() -> int:
	return racket_visual_frame


func fire_shooting_paddle() -> Dictionary:
	if state != STATE_PLAYING:
		return {"status": "inactive"}
	var projectile_type := -1
	if _shooting_paddle_mode == PROJECTILE_MODE_CONTINUOUS:
		projectile_type = PROJECTILE_TYPE_CONTINUOUS
	elif _single_shot_projectile_armed:
		projectile_type = PROJECTILE_TYPE_STRONG
	else:
		return {"status": "unarmed"}

	if _projectile_fire_cooldown > 0.0:
		return {"status": "cooldown", "remaining": _projectile_fire_cooldown, "projectile_type": projectile_type}

	if _spawn_projectile(projectile_type):
		if projectile_type == PROJECTILE_TYPE_STRONG:
			_single_shot_projectile_armed = false
			_set_racket_visual_target(RACKET_VISUAL_MODE_NORMAL)
		_projectile_fire_cooldown = PROJECTILE_FIRE_COOLDOWN_SECONDS
		return {"status": "fired", "projectile_type": projectile_type}
	return {"status": "blocked", "projectile_type": projectile_type}


static func sfx_pan100_for_source_x(source_x: float) -> float:
	return clampf(source_x * SFX_PAN_SOURCE_SCALE + SFX_PAN_SOURCE_OFFSET, SFX_PAN_MIN, SFX_PAN_MAX)


static func sfx_pan_for_source_x(source_x: float) -> float:
	return sfx_pan100_for_source_x(source_x) / SFX_PAN_MAX


func pop_audio_events() -> Array[String]:
	var events: Array[String] = []
	for event_payload: Dictionary in _audio_events:
		var event_name := String(event_payload.get("event", ""))
		if not event_name.is_empty():
			events.append(event_name)
	_audio_events.clear()
	return events


func pop_audio_event_payloads() -> Array[Dictionary]:
	var events: Array[Dictionary] = []
	for event_payload: Dictionary in _audio_events:
		events.append(event_payload.duplicate(true))
	_audio_events.clear()
	return events


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
	if type_id >= 0 and type_id < BONUS_TYPE_NAMES.size():
		return String(BONUS_TYPE_NAMES[type_id])
	return "Unknown Bonus"


static func monster_trait_for_type(type_id: int) -> Dictionary:
	var monster_trait := MONSTER_DEFAULT_TRAIT.duplicate()
	if MONSTER_TRAITS.has(type_id):
		monster_trait.merge(MONSTER_TRAITS[type_id], true)
	return monster_trait


static func monster_spawn_pool() -> Array[int]:
	var spawn_pool: Array[int] = []
	for type_id in range(MONSTER_TYPE_COUNT):
		if monster_type_is_original_spawned(type_id):
			spawn_pool.append(type_id)
	return spawn_pool


static func monster_frame_count_for_type(type_id: int) -> int:
	return int(_monster_trait_value(type_id, "frame_count", MONSTER_DEFAULT_TRAIT["frame_count"]))


static func monster_motion_mode_for_type(type_id: int) -> String:
	return String(_monster_trait_value(type_id, "motion_mode", MONSTER_MOTION_ANGLE))


static func monster_collision_offset_for_type(type_id: int) -> Vector2:
	return _monster_trait_value(type_id, "collision_offset", MONSTER_COLLISION_OFFSET) as Vector2


static func monster_collision_size_for_type(type_id: int) -> Vector2:
	return _monster_trait_value(type_id, "collision_size", MONSTER_COLLISION_SIZE) as Vector2


static func monster_stuns_racket(type_id: int) -> bool:
	return bool(_monster_trait_value(type_id, "stuns_racket", false))


static func monster_type_is_original_spawned(type_id: int) -> bool:
	return bool(_monster_trait_value(type_id, "natural_spawn", false))


static func _monster_score_mode_for_type(type_id: int, contact_key: String) -> String:
	return String(_monster_trait_value(type_id, contact_key, MONSTER_SCORE_MODE_DEFAULT))


static func _monster_trait_value(type_id: int, key: String, default_value):
	if MONSTER_TRAITS.has(type_id):
		var monster_trait: Dictionary = MONSTER_TRAITS[type_id]
		if monster_trait.has(key):
			return monster_trait[key]
	if MONSTER_DEFAULT_TRAIT.has(key):
		return MONSTER_DEFAULT_TRAIT[key]
	return default_value


func set_bonus_rng_seed(seed_value: int) -> void:
	_bonus_rng.set_seed(seed_value)


func set_monster_rng_seed(seed_value: int) -> void:
	_monster_rng.set_seed(seed_value)


func active_monster_spawn_pool() -> Array[int]:
	return monster_spawn_pool()


func set_collision_rng_seed(seed_value: int) -> void:
	_collision_rng.set_seed(seed_value)


func set_ball_track_rng_seed(seed_value: int) -> void:
	_ball_track_rng.set_seed(seed_value)


func force_bonus_drop_ready() -> void:
	_bonus_drop_cooldown = 0.0


func force_monster_spawn_ready() -> void:
	_monster_spawn_cooldown = 0.0


func force_bee_spawn_ready() -> void:
	_bee_spawn_delay_remaining = 0.0


func active_ball_count() -> int:
	return visible_balls().size()


func active_projectile_count() -> int:
	return visible_projectiles().size()


func active_monster_count() -> int:
	return visible_monsters().size()


func active_bee_count() -> int:
	return visible_bees().size()


func active_snake_segment_count() -> int:
	return visible_snake_segments().size()


func current_racket_height() -> float:
	return RACKET_SEGMENT_PIXEL_STEP * float(racket_segment_count) + RACKET_SEGMENT_MARGIN


func racket_rect() -> Rect2:
	return Rect2(Vector2(RACKET_X, racket_y), Vector2(RACKET_WIDTH, current_racket_height()))


func racket_rects() -> Array[Rect2]:
	var rects: Array[Rect2] = []
	rects.append(racket_rect())
	if is_double_paddle_active():
		rects.append(Rect2(
			Vector2(_double_paddle_x, racket_y),
			Vector2(RACKET_WIDTH, current_racket_height())
		))
	return rects


func ball_rect(ball: Dictionary) -> Rect2:
	var size := float(ball.get("size", BALL_SIZE))
	return Rect2(ball.get("position", Vector2.ZERO), Vector2(size, size))


func projectile_rect(projectile: Dictionary) -> Rect2:
	return Rect2(projectile.get("position", Vector2.ZERO), PROJECTILE_SIZE)


func monster_rect(monster: Dictionary) -> Rect2:
	var type_id := int(monster.get("type_id", 0))
	return Rect2(
		monster.get("position", Vector2.ZERO) + monster_collision_offset_for_type(type_id),
		monster_collision_size_for_type(type_id)
	)


func bee_rect(bee: Dictionary) -> Rect2:
	return Rect2(bee.get("position", Vector2.ZERO) + BEE_COLLISION_OFFSET, BEE_COLLISION_SIZE)


func snake_rect(segment: Dictionary) -> Rect2:
	return Rect2(segment.get("position", Vector2.ZERO), SNAKE_SEGMENT_SIZE)


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
	return _ball_type(balls[0])


func active_non_stricked_ball_count() -> int:
	var count := 0
	for ball: Dictionary in balls:
		if bool(ball.get("active", false)) and _is_non_stricked_ball(ball):
			count += 1
	return count


func force_ball(position: Vector2, velocity: Vector2, size: float = BALL_SIZE, type_id: int = BALL_TYPE_STANDARD) -> void:
	balls = [{
		"active": true,
		"position": position,
		"velocity": velocity,
		"size": size,
		"type_id": type_id,
		"previous_type_id": BALL_TYPE_STANDARD,
		"non_stricked_time_remaining": 0.0,
		"frame": 0,
		"frame_elapsed": 0.0,
		"speed_scale": ball_speed_scale,
		"target_speed": _target_speed_for_new_ball(velocity),
		"speed_hit_count": 0,
		"magnet_attached": false,
	}]
	_clear_ball_tracks()
	state = STATE_PLAYING


func force_monster(position: Vector2, type_id: int = 3, angle: int = 0) -> bool:
	if monsters.size() >= MAX_MONSTERS:
		return false
	monsters.append(_new_monster(position, type_id, angle))
	state = STATE_PLAYING
	return true


func force_bee(position: Vector2, frame: int = 0) -> bool:
	if bees.size() >= 1:
		return false
	bees.append(_new_bee(position, frame))
	state = STATE_PLAYING
	return true


func force_snake_vfx_segments_for_test(segments: Array) -> int:
	_clear_snake_state()
	for segment in segments:
		if snake_segments.size() >= MAX_SNAKE_SEGMENTS:
			break
		if typeof(segment) != TYPE_DICTIONARY:
			continue
		var entry: Dictionary = segment
		var position := Vector2.ZERO
		var raw_position = entry.get("position", Vector2.ZERO)
		if raw_position is Vector2:
			position = raw_position
		snake_segments.append({
			"active": bool(entry.get("active", true)),
			"position": position,
			"kind": clampi(int(entry.get("kind", 0)), 0, SNAKE_KIND_COUNT - 1),
		})
	return snake_segments.size()


func _add_ready_ball() -> void:
	_add_ball(_ready_ball_position(), Vector2.ZERO, true)


func _add_ball(position: Vector2, velocity: Vector2, active := true, type_id := BALL_TYPE_STANDARD) -> bool:
	if balls.size() >= MAX_BALLS:
		return false
	balls.append({
		"active": active,
		"position": position,
		"velocity": velocity,
		"size": ball_size,
		"type_id": type_id,
		"previous_type_id": BALL_TYPE_STANDARD,
		"non_stricked_time_remaining": 0.0,
		"frame": _ball_animation_rng.next_mod(BALL_FRAME_COUNT),
		"frame_elapsed": 0.0,
		"speed_scale": ball_speed_scale,
		"target_speed": _target_speed_for_new_ball(velocity),
		"speed_hit_count": 0,
		"magnet_attached": false,
	})
	return true


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
	return int(ball.get("type_id", BALL_TYPE_STANDARD))


func _is_non_stricked_ball(ball: Dictionary) -> bool:
	return _ball_type(ball) == BALL_TYPE_NON_STRICKED \
		and float(ball.get("non_stricked_time_remaining", 0.0)) > 0.0


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
	racket_y = clampf(
		RACKET_READY_CENTER_Y - current_racket_height() * 0.5,
		RACKET_MIN_Y,
		RACKET_MAX_BOTTOM - current_racket_height()
	)
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
	for index in range(balls.size()):
		var ball := balls[index]
		if not bool(ball.get("active", false)):
			continue

		var frame_elapsed := float(ball.get("frame_elapsed", 0.0)) + delta
		var frame := int(ball.get("frame", 0))
		while frame_elapsed >= BALL_FRAME_SECONDS:
			frame = (frame + 1) % BALL_FRAME_COUNT
			frame_elapsed -= BALL_FRAME_SECONDS
		ball["frame"] = frame
		ball["frame_elapsed"] = frame_elapsed
		balls[index] = ball


func _update_ball_tracks(delta: float) -> void:
	if not ball_tracks_enabled:
		return

	_ensure_ball_track_slots()
	for index in range(balls.size()):
		var ball := balls[index]
		if not bool(ball.get("active", false)):
			_clear_ball_track_slots(index)
			continue

		_advance_ball_track_slots(index, delta)
		if _ball_type(ball) == BALL_TYPE_NON_STRICKED:
			_clear_ball_track_slots(index)
			continue

		_ball_track_spawn_elapsed[index] = float(_ball_track_spawn_elapsed[index]) + delta
		while float(_ball_track_spawn_elapsed[index]) > BALL_TRACK_SPAWN_SECONDS:
			_ball_track_spawn_elapsed[index] = float(_ball_track_spawn_elapsed[index]) - BALL_TRACK_SPAWN_SECONDS
			_spawn_ball_track(index, ball)


func _ensure_ball_track_slots() -> void:
	while ball_tracks.size() > balls.size():
		ball_tracks.pop_back()
	while _ball_track_spawn_elapsed.size() > balls.size():
		_ball_track_spawn_elapsed.pop_back()
	while ball_tracks.size() < balls.size():
		ball_tracks.append(_new_ball_track_slots())
	while _ball_track_spawn_elapsed.size() < balls.size():
		_ball_track_spawn_elapsed.append(0.0)


func _new_ball_track_slots() -> Array[Dictionary]:
	var slots: Array[Dictionary] = []
	for _slot_index in range(BALL_TRACK_SLOT_COUNT):
		slots.append({
			"active": false,
			"position": Vector2.ZERO,
			"frame": 0,
			"frame_elapsed": 0.0,
			"type_id": BALL_TYPE_STANDARD,
		})
	return slots


func _clear_ball_tracks() -> void:
	ball_tracks.clear()
	_ball_track_spawn_elapsed.clear()


func _clear_ball_track_slots(ball_index: int) -> void:
	if ball_index < 0 or ball_index >= ball_tracks.size():
		return
	for track_index in range(ball_tracks[ball_index].size()):
		var track: Dictionary = ball_tracks[ball_index][track_index]
		track["active"] = false
		track["frame_elapsed"] = 0.0
		ball_tracks[ball_index][track_index] = track
	if ball_index < _ball_track_spawn_elapsed.size():
		_ball_track_spawn_elapsed[ball_index] = 0.0


func _advance_ball_track_slots(ball_index: int, delta: float) -> void:
	if ball_index < 0 or ball_index >= ball_tracks.size():
		return
	for track_index in range(ball_tracks[ball_index].size()):
		var track: Dictionary = ball_tracks[ball_index][track_index]
		if not bool(track.get("active", false)):
			continue

		var frame_elapsed := float(track.get("frame_elapsed", 0.0)) + delta
		var frame := int(track.get("frame", 0))
		while frame_elapsed > BALL_TRACK_FRAME_SECONDS and bool(track.get("active", false)):
			frame += 1
			frame_elapsed -= BALL_TRACK_FRAME_SECONDS
			if frame >= BALL_TRACK_FRAME_COUNT:
				track["active"] = false
				frame_elapsed = 0.0
		track["frame"] = frame
		track["frame_elapsed"] = frame_elapsed
		ball_tracks[ball_index][track_index] = track


func _spawn_ball_track(ball_index: int, ball: Dictionary) -> bool:
	if ball_index < 0:
		return false
	_ensure_ball_track_slots()
	if ball_index >= ball_tracks.size():
		return false

	for track_index in range(ball_tracks[ball_index].size()):
		var track: Dictionary = ball_tracks[ball_index][track_index]
		if bool(track.get("active", false)):
			continue

		track["active"] = true
		track["position"] = _ball_track_position(ball)
		track["frame"] = 0
		track["frame_elapsed"] = 0.0
		track["type_id"] = _ball_type(ball)
		ball_tracks[ball_index][track_index] = track
		return true
	return false


func _ball_track_position(ball: Dictionary) -> Vector2:
	var position: Vector2 = ball.get("position", Vector2.ZERO)
	var ball_pixel_size: int = max(1, int(float(ball.get("size", ball_size))))
	var half_size: int = max(1, int(float(ball_pixel_size) / 2.0))
	var random_span: int = max(1, 2 * half_size - 8)
	var center_x: int = int(position.x) + half_size
	var center_y: int = int(position.y) + half_size
	var track_x: int = center_x - _ball_track_rng.next_mod(random_span) + half_size - 10
	var track_y: int = center_y - _ball_track_rng.next_mod(random_span) + half_size - 10
	return Vector2(float(track_x), float(track_y))


func _update_level_ready_sequence(delta: float) -> void:
	if level_ready_time_remaining > 0.0:
		level_ready_time_remaining = maxf(0.0, level_ready_time_remaining - delta)
		if level_ready_time_remaining <= 0.0:
			_level_ready_auto_launch_pending = true
	if _level_ready_animation_time_remaining > 0.0:
		_level_ready_roller_step_elapsed += delta
		while _level_ready_roller_step_elapsed + LEVEL_READY_ROLLER_STEP_EPSILON >= LEVEL_READY_ROLLER_STEP_SECONDS and _level_ready_animation_time_remaining > 0.0:
			_level_ready_roller_step_elapsed -= LEVEL_READY_ROLLER_STEP_SECONDS
			if _level_ready_roller_step_elapsed < 0.0:
				_level_ready_roller_step_elapsed = 0.0
			_level_ready_roller_offset = minf(LEVEL_READY_ROLLER_TRAVEL_PIXELS, _level_ready_roller_offset + LEVEL_READY_ROLLER_STEP_PIXELS)
			_level_ready_roller_frame = (_level_ready_roller_frame + 1) % LEVEL_READY_ROLLER_FRAME_COUNT
			_level_ready_animation_time_remaining = maxf(0.0, _level_ready_animation_time_remaining - LEVEL_READY_ROLLER_STEP_SECONDS)
		if _level_ready_roller_offset >= LEVEL_READY_ROLLER_TRAVEL_PIXELS:
			_level_ready_animation_time_remaining = 0.0
			_level_ready_roller_step_elapsed = 0.0


func _clear_level_ready_sequence() -> void:
	level_ready_time_remaining = 0.0
	_level_ready_animation_time_remaining = 0.0
	_level_ready_roller_offset = 0.0
	_level_ready_roller_frame = 0
	_level_ready_roller_step_elapsed = 0.0
	_level_ready_auto_launch_pending = false


func _skip_level_ready_prompt() -> void:
	_level_ready_animation_time_remaining = 0.0
	_level_ready_roller_offset = LEVEL_READY_ROLLER_TRAVEL_PIXELS
	_level_ready_roller_step_elapsed = 0.0


func _auto_launch_ready_ball_if_needed() -> bool:
	if not _level_ready_auto_launch_pending:
		return false
	_level_ready_auto_launch_pending = false
	return launch_ready_ball()


func _collide_with_racket(ball: Dictionary) -> bool:
	var rect := ball_rect(ball)
	var velocity: Vector2 = ball.get("velocity", Vector2.ZERO)
	if velocity.x <= 0.0:
		return false

	for racket_hit_rect: Rect2 in racket_rects():
		if not rect.intersects(racket_hit_rect):
			continue
		if is_magnet_paddle_active():
			_attach_ball_to_magnet(ball, racket_hit_rect)
		else:
			_bounce_ball_from_racket(ball, racket_hit_rect)
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
	if not BrickSemanticsScript.can_spawn_bonus(tile_id):
		return {"action": "clear"}
	if _bonus_drop_cooldown > 0.0:
		return {"action": "clear"}

	_reset_bonus_drop_gate()
	if remaining_bonus_stock <= 0:
		return {"action": "clear"}
	if board_state == null or board_state.remaining_required_bricks <= 0:
		return {"action": "clear"}

	var chance_denominator: int = int((2 * board_state.remaining_required_bricks) / remaining_bonus_stock)
	if chance_denominator <= 0:
		return {"action": "clear"}
	if _bonus_rng.next_mod(chance_denominator) != 0:
		return {"action": "clear"}

	var selector := _bonus_rng.next_mod(BONUS_SELECTOR_COUNT)
	var attempts := BONUS_SELECTOR_COUNT
	while attempts > 0:
		if selector >= BONUS_TYPE_COUNT:
			var tile_selector := _bonus_rng.next_mod(CHAIN_SELECTOR_TILE_IDS.size())
			var chain_tile_id := int(CHAIN_SELECTOR_TILE_IDS[tile_selector])
			if board_state.convert_to_chain_explosion_tile(column, row, chain_tile_id):
				return {"action": "chain"}
			return {"action": "clear"}

		if selector < bonus_stock_counts.size() and int(bonus_stock_counts[selector]) > 0:
			bonus_stock_counts[selector] = int(bonus_stock_counts[selector]) - 1
			remaining_bonus_stock -= 1
			return {
				"action": "spawn",
				"type_id": _visible_bonus_type_for_stock_id(selector),
			}

		selector = (selector + 1) % BONUS_TYPE_COUNT
		attempts -= 1

	return {"action": "clear"}


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
	bonus_stock_counts.clear()
	remaining_bonus_stock = 0
	if level == null:
		for index in range(BONUS_TYPE_COUNT):
			bonus_stock_counts.append(0)
		return

	var source_counts: Array[int] = level.bonus_stock_counts()
	for index in range(BONUS_TYPE_COUNT):
		var count := 0
		if index < source_counts.size():
			count = max(0, int(source_counts[index]))
		bonus_stock_counts.append(count)
		remaining_bonus_stock += count


func _clear_bonus_run_state() -> void:
	falling_bonuses.clear()
	bonus_stack.clear()
	bonus_pointer_frame = 0
	_bonus_pointer_elapsed = 0.0
	_clear_timed_bonus_state()
	_reset_bonus_drop_gate()


func _reset_bonus_effect_state() -> void:
	racket_segment_count = RACKET_DEFAULT_SEGMENTS
	ball_size = BALL_SIZE
	ball_speed_scale = BALL_DEFAULT_SPEED_SCALE
	_clear_paddle_mode_state(false)
	_drunk_paddle_time_remaining = 0.0
	_has_last_racket_input = false
	_has_last_racket_x_input = false
	_last_racket_input_y = RACKET_READY_CENTER_Y
	_last_racket_input_x = RACKET_X
	racket_y = clampf(racket_y, RACKET_MIN_Y, RACKET_MAX_BOTTOM - current_racket_height())


func _reset_bonus_drop_gate() -> void:
	_bonus_drop_cooldown = BONUS_DROP_GATE_SECONDS


func _clear_timed_bonus_state() -> void:
	back_wall_time_remaining = 0.0
	projectiles.clear()
	_clear_paddle_mode_state(false)
	_drunk_paddle_time_remaining = 0.0
	_projectile_fire_cooldown = 0.0


func _update_bonus_timers(delta: float) -> void:
	if _bonus_drop_cooldown > 0.0:
		_bonus_drop_cooldown = maxf(0.0, _bonus_drop_cooldown - delta)
	if back_wall_time_remaining > 0.0:
		back_wall_time_remaining = maxf(0.0, back_wall_time_remaining - delta)
	if _racket_stun_time_remaining > 0.0:
		_racket_stun_time_remaining = maxf(0.0, _racket_stun_time_remaining - delta)
	if _drunk_paddle_time_remaining > 0.0:
		_drunk_paddle_time_remaining = maxf(0.0, _drunk_paddle_time_remaining - delta)
	_update_non_stricked_balls(delta)


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
	_racket_visual_target_mode = visual_mode
	if visual_mode != RACKET_VISUAL_MODE_NORMAL:
		racket_visual_mode = visual_mode
	elif racket_visual_frame <= 0:
		racket_visual_mode = RACKET_VISUAL_MODE_NORMAL


func _update_racket_visual(delta: float) -> void:
	_racket_visual_elapsed += delta
	while _racket_visual_elapsed >= RACKET_VISUAL_FRAME_SECONDS:
		_racket_visual_elapsed -= RACKET_VISUAL_FRAME_SECONDS
		if _racket_visual_target_mode == RACKET_VISUAL_MODE_NORMAL:
			if racket_visual_frame > 0:
				racket_visual_frame -= 1
			if racket_visual_frame <= 0:
				racket_visual_frame = 0
				racket_visual_mode = RACKET_VISUAL_MODE_NORMAL
		elif _racket_visual_target_mode == RACKET_VISUAL_MODE_MAGNET:
			racket_visual_mode = RACKET_VISUAL_MODE_MAGNET
			racket_visual_frame = (racket_visual_frame + 1) % RACKET_MAGNET_VISUAL_FRAME_COUNT
		else:
			racket_visual_mode = _racket_visual_target_mode
			if racket_visual_frame < RACKET_VISUAL_MAX_FRAME:
				racket_visual_frame += 1


func _mouse_delta_x(mouse_x) -> float:
	if mouse_x == null:
		return 0.0
	var next_mouse_x := float(mouse_x)
	if not _has_last_racket_x_input:
		return 0.0
	return next_mouse_x - _last_racket_input_x


func _remember_racket_input(mouse_y: float, mouse_x = null) -> void:
	_last_racket_input_y = mouse_y
	_has_last_racket_input = true
	if mouse_x != null:
		_last_racket_input_x = float(mouse_x)
		_has_last_racket_x_input = true


func _update_double_paddle_x(mouse_delta_x: float) -> void:
	if not is_double_paddle_active() or is_zero_approx(mouse_delta_x):
		return
	_double_paddle_x = clampf(
		_double_paddle_x + mouse_delta_x * DOUBLE_PADDLE_MOUSE_X_MULTIPLIER,
		DOUBLE_PADDLE_MIN_X,
		RACKET_X + DOUBLE_PADDLE_OFFSET_X
	)


func _clear_paddle_mode_state(release_attached_balls := true) -> void:
	if release_attached_balls:
		_release_magnet_attached_balls()
	else:
		_clear_all_magnet_attachments()
	_double_paddle_active = false
	_double_paddle_x = RACKET_X + DOUBLE_PADDLE_OFFSET_X
	_magnet_paddle_active = false
	_shooting_paddle_mode = PROJECTILE_MODE_DISABLED
	_single_shot_projectile_armed = false
	racket_visual_mode = RACKET_VISUAL_MODE_NORMAL
	racket_visual_frame = 0
	_racket_visual_target_mode = RACKET_VISUAL_MODE_NORMAL
	_racket_visual_elapsed = 0.0


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
	var racket_height := racket_hit_rect.size.y
	var racket_center := racket_hit_rect.get_center().y
	var ball_center := ball_hit_rect.get_center().y
	var normalized_hit := clampf((ball_center - racket_center) / (racket_height * 0.5), -1.0, 1.0)
	var max_y_speed := minf(RACKET_BOUNCE_MAX_Y_SPEED, speed * 0.95)
	var velocity_y := normalized_hit * max_y_speed
	var velocity_x := -sqrt(maxf(0.0, speed * speed - velocity_y * velocity_y))
	return Vector2(velocity_x, velocity_y)


func _bonus_intersects_any_racket(bonus: Dictionary) -> bool:
	var rect := bonus_rect(bonus)
	for current_racket_rect: Rect2 in racket_rects():
		if rect.intersects(current_racket_rect):
			return true
	return false


func _spawn_falling_bonus(type_id: int, position: Vector2) -> bool:
	if falling_bonuses.size() >= MAX_FALLING_BONUSES:
		return false

	falling_bonuses.append({
		"active": true,
		"type_id": clampi(type_id, 0, BONUS_TYPE_COUNT - 1),
		"position": position,
		"base_y": position.y,
		"angle": 0,
		"frame": _bonus_animation_rng.next_mod(BONUS_ANIMATION_FRAME_COUNT),
		"frame_elapsed": 0.0,
		"substep_accumulator": 0.0,
	})
	return true


func _update_falling_bonuses(delta: float) -> void:
	for index in range(falling_bonuses.size()):
		var bonus := falling_bonuses[index]
		if not bool(bonus.get("active", false)):
			continue

		_advance_falling_bonus(bonus, delta)
		if _bonus_intersects_any_racket(bonus) and _push_bonus_stack(int(bonus.get("type_id", 0))):
			var bonus_position: Vector2 = bonus.get("position", Vector2.ZERO)
			bonus["active"] = false
			_queue_audio_event_at_x(SFX_EVENT_BONUS_COLLECT, bonus_position.x)

		falling_bonuses[index] = bonus

	_compact_falling_bonuses()


func _advance_falling_bonus(bonus: Dictionary, delta: float) -> void:
	var position: Vector2 = bonus.get("position", Vector2.ZERO)
	var next_x := position.x
	var next_y := position.y
	var next_angle := int(bonus.get("angle", 0))
	var base_y := float(bonus.get("base_y", position.y))
	var substep_accumulator := float(bonus.get("substep_accumulator", 0.0)) \
		+ maxf(delta, 0.0) * ORIGINAL_BONUS_SUBSTEP_HZ
	var substep_count := int(floorf(substep_accumulator))
	substep_accumulator -= float(substep_count)

	for _step in range(substep_count):
		next_x += BONUS_STEP_X
		next_angle = (next_angle + BONUS_ANGLE_STEP) % 360
		next_y = base_y + next_x * BONUS_WAVE_SCALE * cos(deg_to_rad(float(next_angle)))
		next_y = clampf(next_y, BONUS_MIN_Y, BONUS_MAX_Y)
		if next_x > BONUS_EXPIRE_X:
			bonus["active"] = false
			_queue_audio_event_at_x(SFX_EVENT_BONUS_EXPIRE, next_x)
			substep_accumulator = 0.0
			break

	var frame_elapsed := float(bonus.get("frame_elapsed", 0.0)) + delta
	var frame := int(bonus.get("frame", 0))
	while frame_elapsed >= BONUS_FALLING_FRAME_SECONDS:
		frame = (frame + 1) % BONUS_ANIMATION_FRAME_COUNT
		frame_elapsed -= BONUS_FALLING_FRAME_SECONDS

	bonus["position"] = Vector2(next_x, next_y)
	bonus["angle"] = next_angle
	bonus["frame"] = frame
	bonus["frame_elapsed"] = frame_elapsed
	bonus["substep_accumulator"] = substep_accumulator


func _update_projectile_fire(delta: float) -> void:
	if _projectile_fire_cooldown > 0.0:
		_projectile_fire_cooldown = maxf(0.0, _projectile_fire_cooldown - delta)
		if is_zero_approx(_projectile_fire_cooldown):
			_projectile_fire_cooldown = 0.0


func _spawn_projectile(projectile_type: int) -> bool:
	_compact_projectiles()
	if projectiles.size() >= MAX_PROJECTILES:
		return false

	var position := _projectile_spawn_position()
	projectiles.append({
		"active": true,
		"type": projectile_type,
		"position": position,
		"head_frame": 0,
		"head_frame_elapsed": 0.0,
		"trail_frame": 0,
		"trail_frame_elapsed": 0.0,
	})
	_queue_audio_event_at_x(SFX_EVENT_PROJECTILE_FIRE, position.x)
	return true


func _projectile_spawn_position() -> Vector2:
	var original_muzzle_y := floorf((RACKET_SEGMENT_PIXEL_STEP * float(racket_segment_count) + 9.0) * 0.5) - 1.0
	return Vector2(
		RACKET_X - 20.0,
		racket_y + original_muzzle_y
	)


func _update_projectiles(delta: float) -> void:
	for index in range(projectiles.size()):
		var projectile := projectiles[index]
		if not bool(projectile.get("active", false)):
			continue

		_advance_projectile(projectile, delta)
		if bool(projectile.get("active", false)) and _collide_projectile_with_snake(projectile):
			projectile["active"] = false
		if bool(projectile.get("active", false)) and _collide_projectile_with_monsters(projectile):
			projectile["active"] = false
		if bool(projectile.get("active", false)) and _collide_projectile_with_board(projectile):
			if int(projectile.get("type", PROJECTILE_TYPE_CONTINUOUS)) == PROJECTILE_TYPE_CONTINUOUS:
				projectile["active"] = false
		projectiles[index] = projectile

	_compact_projectiles()


func _advance_projectile(projectile: Dictionary, delta: float) -> void:
	var position: Vector2 = projectile.get("position", Vector2.ZERO)
	position.x -= PROJECTILE_STEP_X
	projectile["position"] = position
	if position.x <= PROJECTILE_EXPIRE_X:
		projectile["active"] = false

	var head_elapsed := float(projectile.get("head_frame_elapsed", 0.0)) + delta
	var head_frame := int(projectile.get("head_frame", 0))
	while head_elapsed >= PROJECTILE_HEAD_FRAME_SECONDS:
		head_frame = (head_frame + 1) % PROJECTILE_HEAD_FRAME_COUNT
		head_elapsed -= PROJECTILE_HEAD_FRAME_SECONDS
	projectile["head_frame"] = head_frame
	projectile["head_frame_elapsed"] = head_elapsed

	var trail_elapsed := float(projectile.get("trail_frame_elapsed", 0.0)) + delta
	var trail_frame := int(projectile.get("trail_frame", 0))
	while trail_elapsed >= PROJECTILE_TRAIL_FRAME_SECONDS:
		trail_frame = (trail_frame + 1) % PROJECTILE_TRAIL_FRAME_COUNT
		trail_elapsed -= PROJECTILE_TRAIL_FRAME_SECONDS
	projectile["trail_frame"] = trail_frame
	projectile["trail_frame_elapsed"] = trail_elapsed


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


func _clear_monster_state() -> void:
	if _has_active_bee():
		_queue_audio_event(SFX_EVENT_BEE_STOP)
	monsters.clear()
	bees.clear()
	_clear_snake_state()
	impact_effects.clear()
	_monster_spawn_cooldown = MONSTER_SPAWN_INTERVAL_SECONDS
	_bee_spawn_delay_remaining = BEE_SPAWN_DELAY_MAX_SECONDS
	_racket_stun_time_remaining = 0.0


func _clear_snake_state() -> void:
	snake_segments.clear()
	_snake_update_elapsed = 0.0


func _update_snake_segments(delta: float) -> void:
	if delta <= 0.0 or not _has_active_snake_segments():
		return

	_snake_update_elapsed += delta
	while _snake_update_elapsed > SNAKE_UPDATE_SECONDS and _has_active_snake_segments():
		_snake_update_elapsed -= SNAKE_UPDATE_SECONDS
		_step_snake_segments()


func _step_snake_segments() -> void:
	for index in range(snake_segments.size()):
		var segment := snake_segments[index]
		if not bool(segment.get("active", false)):
			break
		var position: Vector2 = segment.get("position", Vector2.ZERO)
		segment["position"] = position + _snake_direction_for_kind(int(segment.get("kind", 0))) * SNAKE_STEP_PIXELS
		snake_segments[index] = segment


func _snake_direction_for_kind(kind: int) -> Vector2:
	match posmod(kind, 4):
		SNAKE_KIND_UP:
			return Vector2(0, -1)
		SNAKE_KIND_DOWN:
			return Vector2(0, 1)
		SNAKE_KIND_LEFT:
			return Vector2(-1, 0)
		SNAKE_KIND_RIGHT:
			return Vector2(1, 0)
	return Vector2.ZERO


func _collide_ball_with_snake(ball: Dictionary) -> bool:
	return _truncate_snake_at_rect(ball_rect(ball))


func _collide_projectile_with_snake(projectile: Dictionary) -> bool:
	return _truncate_snake_at_rect(projectile_rect(projectile))


func _truncate_snake_at_rect(hit_rect: Rect2) -> bool:
	for index in range(snake_segments.size()):
		var segment: Dictionary = snake_segments[index]
		if not bool(segment.get("active", false)):
			break
		if snake_rect(segment).intersects(hit_rect):
			_spawn_impact_effect(segment.get("position", Vector2.ZERO), IMPACT_EFFECT_KIND_SNAKE_HIT)
			_truncate_snake_at_index(index)
			return true
	return false


func _truncate_snake_at_index(hit_index: int) -> void:
	if hit_index < 0 or hit_index >= snake_segments.size():
		return

	if hit_index > 0:
		var terminal_source_index := maxi(0, hit_index - 2)
		var terminal_target_index := hit_index - 1
		var terminal_source: Dictionary = snake_segments[terminal_source_index]
		var terminal_target: Dictionary = snake_segments[terminal_target_index]
		terminal_target["kind"] = _terminal_snake_kind_for_previous_kind(int(terminal_source.get("kind", 0)))
		snake_segments[terminal_target_index] = terminal_target

	for index in range(hit_index, snake_segments.size()):
		var segment := snake_segments[index]
		segment["active"] = false
		snake_segments[index] = segment


func _terminal_snake_kind_for_previous_kind(kind: int) -> int:
	match clampi(kind, 0, SNAKE_KIND_COUNT - 1):
		4, 11, 14:
			return SNAKE_TERMINAL_UP
		5, 10, 15:
			return SNAKE_TERMINAL_DOWN
		6, 8, 13:
			return SNAKE_TERMINAL_LEFT
		7, 9, 12:
			return SNAKE_TERMINAL_RIGHT
	match posmod(kind, 4):
		SNAKE_KIND_UP:
			return SNAKE_TERMINAL_UP
		SNAKE_KIND_DOWN:
			return SNAKE_TERMINAL_DOWN
		SNAKE_KIND_LEFT:
			return SNAKE_TERMINAL_LEFT
		SNAKE_KIND_RIGHT:
			return SNAKE_TERMINAL_RIGHT
	return SNAKE_TERMINAL_LEFT


func _has_active_snake_segments() -> bool:
	for segment: Dictionary in snake_segments:
		if bool(segment.get("active", false)):
			return true
		break
	return false


func _update_monsters(delta: float) -> void:
	for index in range(monsters.size()):
		var monster := monsters[index]
		if not bool(monster.get("active", false)):
			continue
		_advance_monster(monster, delta)
		if bool(monster.get("active", false)) and _collide_monster_with_racket(index, monster):
			continue
		monsters[index] = monster

	_compact_monsters()

	_monster_spawn_cooldown = maxf(0.0, _monster_spawn_cooldown - delta)
	if _monster_spawn_cooldown > 0.0:
		return

	_spawn_next_monster()
	_monster_spawn_cooldown = MONSTER_SPAWN_INTERVAL_SECONDS


func _spawn_next_monster() -> bool:
	if monsters.size() >= MAX_MONSTERS:
		return false

	var type_id := _next_monster_type()
	var position := Vector2(
		260.0 + float(_monster_rng.next_mod(200)),
		100.0 + float(_monster_rng.next_mod(320))
	)
	var angle_seed := _monster_rng.next_mod(4)
	var angle := 0
	if angle_seed >= 2:
		angle = 330 + _monster_rng.next_mod(60)
	else:
		angle = 150 + _monster_rng.next_mod(60)

	monsters.append(_new_monster(position, type_id, angle))
	_spawn_impact_effect(position, IMPACT_EFFECT_KIND_MONSTER_SPAWN)
	_queue_audio_event_at_x(SFX_EVENT_MONSTER_SPAWN, position.x)
	return true


func _next_monster_type() -> int:
	return int(_monster_rng.next_mod(MONSTER_TYPE_COUNT))


func _new_monster(position: Vector2, type_id: int, angle: int) -> Dictionary:
	return {
		"active": true,
		"type_id": type_id,
		"position": position,
		"frame": 0,
		"frame_elapsed": 0.0,
		"angle": float(posmod(angle, 360)),
		"speed": MONSTER_DEFAULT_SPEED,
		"age": 0.0,
	}


func _advance_monster(monster: Dictionary, delta: float) -> void:
	var age := float(monster.get("age", 0.0)) + delta
	monster["age"] = age
	if age >= MONSTER_LIFETIME_SECONDS:
		var expire_position: Vector2 = monster.get("position", Vector2.ZERO)
		monster["active"] = false
		_spawn_impact_effect(monster.get("position", Vector2.ZERO), IMPACT_EFFECT_KIND_MONSTER_TIMEOUT)
		_queue_audio_event_at_x(SFX_EVENT_MONSTER_EXPIRE, expire_position.x)
		return

	var type_id := int(monster.get("type_id", 0))
	var frame_elapsed := float(monster.get("frame_elapsed", 0.0)) + delta
	var frame := int(monster.get("frame", 0))
	var frame_count := _frame_count_for_monster_type(type_id)
	while frame_elapsed >= MONSTER_FRAME_SECONDS:
		frame = (frame + 1) % frame_count
		frame_elapsed -= MONSTER_FRAME_SECONDS
	monster["frame"] = frame
	monster["frame_elapsed"] = frame_elapsed

	var position: Vector2 = monster.get("position", Vector2.ZERO)
	var speed := float(monster.get("speed", MONSTER_DEFAULT_SPEED))
	var tick_scale := ORIGINAL_ENEMY_UPDATE_HZ * delta
	var distance := speed * tick_scale
	var angle := float(monster.get("angle", 0.0))
	match monster_motion_mode_for_type(type_id):
		MONSTER_MOTION_PADDLE_FOLLOW:
			if distance > 0.0:
				var horizontal_limit := MONSTER_TYPE3_RIGHT_LIMIT + speed
				if position.x <= MONSTER_TYPE3_RIGHT_LIMIT:
					position.x = minf(position.x + distance, horizontal_limit)

				var jitter := float(_monster_rng.next_mod(MONSTER_TYPE3_VERTICAL_JITTER_RANGE))
				var probe_y := position.y + MONSTER_SIZE.y * 0.5 + MONSTER_TYPE3_VERTICAL_JITTER_BASE + jitter
				if racket_rect().get_center().y > probe_y:
					position.y += distance
					angle = 270.0
				else:
					position.y -= distance
					angle = 90.0
			else:
				position += _monster_motion_vector(angle, distance)
		MONSTER_MOTION_BALL_TRACK:
			angle = _tracking_angle_for_monster(monster, angle, tick_scale)
			position += _monster_motion_vector(angle, distance)
		_:
			position += _monster_motion_vector(angle, distance)

	monster["position"] = position
	monster["angle"] = angle
	_collide_monster_with_boundaries(monster)


func _collide_monster_with_boundaries(monster: Dictionary) -> bool:
	var position: Vector2 = monster.get("position", Vector2.ZERO)
	var type_id := int(monster.get("type_id", 0))
	var rect := Rect2(position, MONSTER_SIZE)
	var hit_horizontal := false
	var hit_vertical := false

	if rect.position.x < PlayfieldSpecScript.WALL_INNER_LEFT_X:
		position.x = PlayfieldSpecScript.WALL_INNER_LEFT_X
		hit_horizontal = true
	elif rect.end.x > PlayfieldSpecScript.WALL_INNER_RIGHT_X:
		position.x = PlayfieldSpecScript.WALL_INNER_RIGHT_X - MONSTER_SIZE.x
		hit_horizontal = true

	if rect.position.y < PlayfieldSpecScript.WALL_INNER_TOP_Y:
		position.y = PlayfieldSpecScript.WALL_INNER_TOP_Y
		hit_vertical = true
	elif rect.end.y > PlayfieldSpecScript.WALL_INNER_BOTTOM_Y:
		position.y = PlayfieldSpecScript.WALL_INNER_BOTTOM_Y - MONSTER_SIZE.y
		hit_vertical = true

	if not hit_horizontal and not hit_vertical:
		return false

	monster["position"] = position
	if type_id != 10:
		var angle := float(monster.get("angle", 0.0))
		if hit_horizontal:
			angle = fposmod(180.0 - angle, 360.0)
		if hit_vertical:
			angle = fposmod(360.0 - angle, 360.0)
		monster["angle"] = angle
	return true


func _frame_count_for_monster_type(type_id: int) -> int:
	return monster_frame_count_for_type(type_id)


func _tracking_angle_for_monster(monster: Dictionary, current_angle: float, tick_scale: float) -> float:
	var monster_center := Vector2(monster.get("position", Vector2.ZERO)) + MONSTER_SIZE * 0.5
	var target_position := _nearest_trackable_ball_center(monster_center)
	if target_position == Vector2.INF:
		return current_angle

	var target_delta := target_position - monster_center
	if target_delta.is_zero_approx():
		return current_angle

	var target_angle := fposmod(rad_to_deg(atan2(-target_delta.y, target_delta.x)), 360.0)
	var difference := fposmod(target_angle - current_angle + 540.0, 360.0) - 180.0
	var turn_step := MONSTER_TRACKING_TURN_STEP_DEGREES * tick_scale
	if difference > 0:
		current_angle += minf(turn_step, difference)
	elif difference < 0:
		current_angle -= minf(turn_step, -difference)
	return fposmod(current_angle, 360.0)


func _nearest_trackable_ball_center(monster_center: Vector2) -> Vector2:
	var nearest_position := Vector2.INF
	var nearest_distance := INF
	for ball: Dictionary in balls:
		if not bool(ball.get("active", false)):
			continue
		if _ball_type(ball) == BALL_TYPE_NON_STRICKED:
			continue
		var ball_center := ball_rect(ball).get_center()
		var distance := monster_center.distance_to(ball_center)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_position = ball_center
	return nearest_position


func _monster_motion_vector(angle: float, speed: float) -> Vector2:
	var radians := deg_to_rad(fposmod(angle, 360.0))
	return Vector2(cos(radians) * speed, -sin(radians) * speed)


func _collide_ball_with_monsters(ball: Dictionary) -> bool:
	for index in range(monsters.size()):
		var monster: Dictionary = monsters[index]
		if not bool(monster.get("active", false)):
			continue
		if _ball_intersects_enemy_circle(ball, monster.get("position", Vector2.ZERO), MONSTER_BALL_COLLISION_RADIUS):
			var type_id := int(monster.get("type_id", 0))
			var score_value := _score_for_monster_ball_contact(monster)
			if _monster_survives_ball_contact(monster):
				_award_score_with_popup(score_value, monster.get("position", Vector2.ZERO))
			else:
				_kill_monster_at_index(index, score_value)
			_apply_ball_enemy_response(ball, type_id)
			return true
	return false


func _collide_ball_with_bees(ball: Dictionary) -> bool:
	for index in range(bees.size()):
		var bee: Dictionary = bees[index]
		if not bool(bee.get("active", false)):
			continue
		if _ball_intersects_enemy_circle(ball, bee.get("position", Vector2.ZERO), BEE_BALL_COLLISION_RADIUS):
			_kill_bee_at_index(index, BEE_BALL_HIT_SCORE)
			_apply_ball_enemy_response(ball, -1)
			return true
	return false


func _ball_intersects_enemy_circle(ball: Dictionary, enemy_position: Vector2, enemy_radius: float) -> bool:
	var ball_position: Vector2 = ball.get("position", Vector2.ZERO)
	var ball_radius := float(ball.get("size", BALL_SIZE)) * 0.5
	return ball_position.distance_to(enemy_position) < ball_radius + enemy_radius


func _collide_projectile_with_monsters(projectile: Dictionary) -> bool:
	var rect := projectile_rect(projectile)
	for index in range(monsters.size()):
		var monster: Dictionary = monsters[index]
		if not bool(monster.get("active", false)):
			continue
		if rect.intersects(monster_rect(monster)):
			_kill_monster_at_index(index, _score_for_monster_paddle_contact(monster))
			_queue_audio_event_at_x(SFX_EVENT_PROJECTILE_HIT, projectile_rect(projectile).position.x)
			return true
	return false


func _collide_monster_with_racket(index: int, monster: Dictionary) -> bool:
	if not monster_rect(monster).intersects(racket_rect()):
		return false

	_kill_monster_at_index(index, _score_for_monster_paddle_contact(monster))
	if monster_stuns_racket(int(monster.get("type_id", 0))):
		_apply_racket_stun()
	return true


func _kill_monster_at_index(index: int, score_value: int = -1) -> void:
	if index < 0 or index >= monsters.size():
		return
	var monster := monsters[index]
	monster["active"] = false
	monsters[index] = monster
	var final_score := score_value if score_value >= 0 else _score_for_monster_paddle_contact(monster)
	_award_score_with_popup(final_score, monster.get("position", Vector2.ZERO))
	_spawn_impact_effect(monster.get("position", Vector2.ZERO), IMPACT_EFFECT_KIND_MONSTER_HIT)
	var hit_position: Vector2 = monster.get("position", Vector2.ZERO)
	_queue_audio_event_at_x(SFX_EVENT_MONSTER_HIT, hit_position.x)


func _score_for_monster_paddle_contact(monster: Dictionary) -> int:
	match _monster_score_mode_for_type(int(monster.get("type_id", 0)), "paddle_score_mode"):
		MONSTER_SCORE_MODE_RANDOM_TYPE6:
			return MONSTER_TYPE6_SCORE_STEP * (_monster_rng.next_mod(MONSTER_TYPE6_SCORE_VARIANTS) + 1)
		MONSTER_SCORE_MODE_STUN_TYPE9:
			return MONSTER_TYPE9_STUN_SCORE
		_:
			return MONSTER_SCORE


func _score_for_monster_ball_contact(monster: Dictionary) -> int:
	match _monster_score_mode_for_type(int(monster.get("type_id", 0)), "ball_score_mode"):
		MONSTER_SCORE_MODE_RANDOM_TYPE6:
			return MONSTER_TYPE6_SCORE_STEP * (_collision_rng.next_mod(MONSTER_TYPE6_SCORE_VARIANTS) + 1)
		_:
			return MONSTER_BALL_HIT_SCORE


func _monster_survives_ball_contact(monster: Dictionary) -> bool:
	return int(monster.get("type_id", 0)) == 1


func _apply_ball_enemy_response(ball: Dictionary, enemy_type_id: int) -> void:
	if enemy_type_id == 1:
		_rotate_ball_from_enemy_contact(ball, MONSTER_TYPE1_BALL_ROTATION_DEGREES, 0)
	elif _ball_type(ball) == BALL_TYPE_STANDARD:
		_rotate_ball_from_enemy_contact(ball)


func _rotate_ball_from_enemy_contact(
	ball: Dictionary,
	minimum_degrees: int = MONSTER_BALL_HIT_MIN_ROTATION_DEGREES,
	random_degrees: int = MONSTER_BALL_HIT_RANDOM_ROTATION_DEGREES
) -> void:
	var velocity: Vector2 = ball.get("velocity", Vector2.ZERO)
	var speed := _target_speed_for_ball(ball)

	var current_angle := 0
	if not velocity.is_zero_approx():
		current_angle = posmod(int(roundi(rad_to_deg(atan2(-velocity.y, velocity.x)))), 360)
	var rotation_degrees := minimum_degrees
	if random_degrees > 0:
		rotation_degrees += _collision_rng.next_mod(random_degrees)
	var next_angle := posmod(current_angle + rotation_degrees, 360)
	ball["velocity"] = _monster_motion_vector(next_angle, speed)
	ball["target_speed"] = speed


func _compact_monsters() -> void:
	var compacted: Array[Dictionary] = []
	for monster: Dictionary in monsters:
		if bool(monster.get("active", false)):
			compacted.append(monster)
	monsters = compacted


func _update_bees(delta: float) -> void:
	for index in range(bees.size()):
		var bee := bees[index]
		if not bool(bee.get("active", false)):
			continue
		_advance_bee(bee, delta)
		if bool(bee.get("active", false)) and bee_rect(bee).intersects(racket_rect()):
			_resolve_bee_racket_hit(index, bee)
			continue
		bees[index] = bee

	_compact_bees()

	if _bee_spawn_delay_remaining > 0.0:
		_bee_spawn_delay_remaining = maxf(0.0, _bee_spawn_delay_remaining - delta)
	if _bee_spawn_delay_remaining > 0.0 or not bees.is_empty():
		return

	if _spawn_next_bee():
		_reset_bee_spawn_delay()


func _spawn_next_bee() -> bool:
	if not bees.is_empty():
		return false

	bees.append(_new_bee(_bee_spawn_position()))
	_queue_audio_event_with_pan100(SFX_EVENT_BEE_SPAWN, SFX_BEE_SPAWN_PAN100)
	return true


func _new_bee(position: Vector2, frame: int = 0) -> Dictionary:
	return {
		"active": true,
		"position": position,
		"frame": posmod(frame, BEE_FRAME_COUNT),
		"frame_elapsed": 0.0,
	}


func _bee_spawn_position() -> Vector2:
	var y := racket_y + floorf((RACKET_SEGMENT_PIXEL_STEP * float(racket_segment_count) - 24.0) * 0.5)
	return Vector2(BEE_SPAWN_X, y)


func _advance_bee(bee: Dictionary, delta: float) -> void:
	var position: Vector2 = bee.get("position", Vector2.ZERO)
	position.x += BEE_STEP_X * ORIGINAL_ENEMY_UPDATE_HZ * delta
	bee["position"] = position
	if position.x >= BEE_EXPIRE_X:
		bee["active"] = false
		_queue_audio_event(SFX_EVENT_BEE_STOP)
		return

	var frame_elapsed := float(bee.get("frame_elapsed", 0.0)) + delta
	var frame := int(bee.get("frame", 0))
	while frame_elapsed >= BEE_FRAME_SECONDS:
		frame = (frame + 1) % BEE_FRAME_COUNT
		frame_elapsed -= BEE_FRAME_SECONDS
	bee["frame"] = frame
	bee["frame_elapsed"] = frame_elapsed


func _resolve_bee_racket_hit(index: int, bee: Dictionary) -> void:
	_kill_bee_at_index(index, BEE_STUN_SCORE)
	_apply_racket_stun()


func _kill_bee_at_index(index: int, score_value: int) -> void:
	if index < 0 or index >= bees.size():
		return
	var bee := bees[index]
	bee["active"] = false
	bees[index] = bee
	_award_score_with_popup(score_value, bee.get("position", Vector2.ZERO))
	_spawn_impact_effect(bee.get("position", Vector2.ZERO), IMPACT_EFFECT_KIND_MONSTER_HIT)
	_queue_audio_event(SFX_EVENT_BEE_STOP)
	var hit_position: Vector2 = bee.get("position", Vector2.ZERO)
	_queue_audio_event_at_x(SFX_EVENT_MONSTER_HIT, hit_position.x)


func _apply_racket_stun() -> void:
	_racket_stun_time_remaining += RACKET_STUN_DURATION_SECONDS


func _reset_bee_spawn_delay() -> void:
	_bee_spawn_delay_remaining = BEE_SPAWN_DELAY_MAX_SECONDS - float(_collision_rng.next_mod(10))


func _update_impact_effects(delta: float) -> void:
	for index in range(impact_effects.size()):
		var effect := impact_effects[index]
		if not bool(effect.get("active", false)):
			continue

		var age := float(effect.get("age", 0.0)) + delta
		var frame_elapsed := float(effect.get("frame_elapsed", 0.0)) + delta
		var frame := int(effect.get("frame", 0))
		while frame_elapsed >= IMPACT_EFFECT_FRAME_SECONDS:
			frame = mini(frame + 1, IMPACT_EFFECT_FRAME_COUNT - 1)
			frame_elapsed -= IMPACT_EFFECT_FRAME_SECONDS
		effect["age"] = age
		effect["frame"] = frame
		effect["frame_elapsed"] = frame_elapsed
		if age >= IMPACT_EFFECT_DURATION_SECONDS:
			effect["active"] = false
		impact_effects[index] = effect

	_compact_impact_effects()


func _update_score_popups(delta: float) -> void:
	for index in range(score_popups.size()):
		var popup := score_popups[index]
		if not bool(popup.get("active", false)):
			continue

		var position: Vector2 = popup.get("position", Vector2.ZERO)
		var step_elapsed := float(popup.get("step_elapsed", 0.0)) + delta
		while step_elapsed >= SCORE_POPUP_STEP_SECONDS:
			step_elapsed -= SCORE_POPUP_STEP_SECONDS
			position.y -= SCORE_POPUP_STEP_PIXELS

		var frame_elapsed := float(popup.get("frame_elapsed", 0.0)) + delta
		var frame := int(popup.get("frame", 0))
		while frame_elapsed >= SCORE_POPUP_FRAME_SECONDS and bool(popup.get("active", false)):
			frame_elapsed -= SCORE_POPUP_FRAME_SECONDS
			frame += 1
			if frame >= SCORE_POPUP_FRAME_COUNT:
				popup["active"] = false
				frame = SCORE_POPUP_FRAME_COUNT - 1
				frame_elapsed = 0.0

		if position.y < SCORE_POPUP_MIN_Y:
			popup["active"] = false

		popup["position"] = position
		popup["step_elapsed"] = step_elapsed
		popup["frame"] = frame
		popup["frame_elapsed"] = frame_elapsed
		score_popups[index] = popup

	_compact_score_popups()


func _spawn_impact_effect(position: Vector2, kind: int) -> bool:
	_compact_impact_effects()
	if impact_effects.size() >= MAX_IMPACT_EFFECTS:
		return false
	impact_effects.append({
		"active": true,
		"position": position,
		"kind": kind,
		"frame": 0,
		"frame_elapsed": 0.0,
		"age": 0.0,
	})
	return true


func _spawn_score_popup(position: Vector2, value: int) -> bool:
	if value <= 0:
		return false

	_compact_score_popups()
	if score_popups.size() >= MAX_SCORE_POPUPS:
		return false

	score_popups.append({
		"active": true,
		"position": position,
		"value": value,
		"frame": 0,
		"frame_elapsed": 0.0,
		"step_elapsed": 0.0,
	})
	return true


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


func _compact_bees() -> void:
	var compacted: Array[Dictionary] = []
	for bee: Dictionary in bees:
		if bool(bee.get("active", false)):
			compacted.append(bee)
	bees = compacted


func _has_active_bee() -> bool:
	for bee: Dictionary in bees:
		if bool(bee.get("active", false)):
			return true
	return false


func _compact_impact_effects() -> void:
	var compacted: Array[Dictionary] = []
	for effect: Dictionary in impact_effects:
		if bool(effect.get("active", false)):
			compacted.append(effect)
	impact_effects = compacted


func _compact_score_popups() -> void:
	var compacted: Array[Dictionary] = []
	for popup: Dictionary in score_popups:
		if bool(popup.get("active", false)):
			compacted.append(popup)
	score_popups = compacted


func _clear_score_popups() -> void:
	score_popups.clear()


func _compact_projectiles() -> void:
	var compacted: Array[Dictionary] = []
	for projectile: Dictionary in projectiles:
		if bool(projectile.get("active", false)):
			compacted.append(projectile)
	projectiles = compacted


func _compact_falling_bonuses() -> void:
	var compacted: Array[Dictionary] = []
	for bonus: Dictionary in falling_bonuses:
		if bool(bonus.get("active", false)):
			compacted.append(bonus)
	falling_bonuses = compacted


func bonus_rect(bonus: Dictionary) -> Rect2:
	return Rect2(bonus.get("position", Vector2.ZERO), Vector2(BONUS_SIZE, BONUS_SIZE))


func _push_bonus_stack(type_id: int) -> bool:
	if bonus_stack.size() >= MAX_STACKED_BONUSES:
		return false

	bonus_stack.append({
		"type_id": clampi(type_id, 0, BONUS_TYPE_COUNT - 1),
		"frame": 0,
		"frame_elapsed": 0.0,
	})
	return true


func _consume_next_bonus() -> void:
	if bonus_stack.is_empty():
		return
	bonus_stack.remove_at(0)


func _update_bonus_stack(delta: float) -> void:
	if bonus_stack.is_empty():
		bonus_pointer_frame = 0
		_bonus_pointer_elapsed = 0.0
		return

	_bonus_pointer_elapsed += delta
	while _bonus_pointer_elapsed >= BONUS_POINTER_FRAME_SECONDS:
		bonus_pointer_frame = (bonus_pointer_frame + 1) % BONUS_ANIMATION_FRAME_COUNT
		_bonus_pointer_elapsed -= BONUS_POINTER_FRAME_SECONDS

	for index in range(bonus_stack.size()):
		var entry := bonus_stack[index]
		var frame_elapsed := float(entry.get("frame_elapsed", 0.0)) + delta
		var frame := int(entry.get("frame", 0))
		while frame_elapsed >= BONUS_STACK_FRAME_SECONDS:
			frame = (frame + 1) % BONUS_ANIMATION_FRAME_COUNT
			frame_elapsed -= BONUS_STACK_FRAME_SECONDS
		entry["frame"] = frame
		entry["frame_elapsed"] = frame_elapsed
		bonus_stack[index] = entry


func _visible_bonus_type_for_stock_id(stock_id: int) -> int:
	if BONUS_DISPLAY_INCREMENT_IDS.has(stock_id):
		return (stock_id + 1) % BONUS_TYPE_COUNT
	return stock_id


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
	if delta_segments < 0:
		if racket_segment_count > RACKET_SHRINK_LIMIT_SEGMENTS:
			racket_segment_count += delta_segments
	elif delta_segments > 0:
		if racket_segment_count < RACKET_EXPAND_LIMIT_SEGMENTS:
			racket_segment_count += delta_segments
	racket_y = clampf(racket_y, RACKET_MIN_Y, RACKET_MAX_BOTTOM - current_racket_height())
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
	_double_paddle_active = true
	return {
		"effect": "double_paddle",
		"active": true,
		"racket_count": racket_rects().size(),
	}


func _activate_magnet_paddle() -> Dictionary:
	_clear_paddle_mode_state()
	_magnet_paddle_active = true
	_set_racket_visual_target(RACKET_VISUAL_MODE_MAGNET)
	return {
		"effect": "magnet_paddle",
		"active": true,
	}


func _activate_drunk_paddle() -> Dictionary:
	_drunk_paddle_time_remaining += DRUNK_PADDLE_DURATION_SECONDS
	return {
		"effect": "drunk_paddle",
		"seconds_remaining": _drunk_paddle_time_remaining,
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
		selected_type_id = _bonus_rng.next_mod(BONUS_TYPE_COUNT)

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
	_shooting_paddle_mode = PROJECTILE_MODE_DISABLED
	_single_shot_projectile_armed = true
	_set_racket_visual_target(RACKET_VISUAL_MODE_SHOOTING_ONE_SHOT)
	return {
		"effect": "shooting_paddle_one_shot",
		"armed": true,
	}


func _activate_shooting_paddle_continuous() -> Dictionary:
	_clear_paddle_mode_state()
	_shooting_paddle_mode = PROJECTILE_MODE_CONTINUOUS
	_single_shot_projectile_armed = false
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
			if index < _ball_track_spawn_elapsed.size():
				_ball_track_spawn_elapsed.remove_at(index)
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
		balls.clear()
		_clear_ball_tracks()
		falling_bonuses.clear()
		_clear_level_ready_sequence()
		_clear_timed_bonus_state()
		_clear_monster_state()
		_queue_audio_event(SFX_EVENT_GAME_OVER)
		return

	_queue_audio_event_at_x(SFX_EVENT_LIFE_LOST, BALL_LOST_X)
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
	_queue_audio_event_payload({"event": event_name})


func _queue_audio_event_at_x(event_name: String, source_x: float) -> void:
	_queue_audio_event_payload({
		"event": event_name,
		"source_x": source_x,
		"pan100": sfx_pan100_for_source_x(source_x),
	})


func _queue_audio_event_with_pan100(event_name: String, pan100: float) -> void:
	_queue_audio_event_payload({
		"event": event_name,
		"pan100": pan100,
	})


func _queue_audio_event_payload(event_payload: Dictionary) -> void:
	var event_name := String(event_payload.get("event", ""))
	if event_name.is_empty():
		return
	var normalized_payload := event_payload.duplicate(true)
	normalized_payload["event"] = event_name
	if normalized_payload.has("source_x") and not normalized_payload.has("pan100"):
		normalized_payload["pan100"] = sfx_pan100_for_source_x(float(normalized_payload["source_x"]))
	elif normalized_payload.has("pan100"):
		normalized_payload["pan100"] = clampf(float(normalized_payload["pan100"]), SFX_PAN_MIN, SFX_PAN_MAX)
	_audio_events.append(normalized_payload)
