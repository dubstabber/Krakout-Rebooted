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
const BRICK_SCORE := 15
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
const BALL_SIZE := 18.0
const BALL_MIN_SIZE := 10.0
const BALL_MAX_SIZE := 42.0
const BALL_SIZE_STEP := 8.0
const BALL_FRAME_COUNT := 10
const BALL_DEFAULT_SPEED_SCALE := 2.0
const BALL_MIN_SPEED_SCALE := 2.0
const BALL_MAX_SPEED_SCALE := 6.0
const BALL_SPEED_STEP := 1.0
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
const ORIGINAL_BALL_STEPS_PER_UPDATE := 3.0
# sub_40DAF0 invokes the original enemy updater three times per gameplay step.
const ORIGINAL_ENEMY_STEPS_PER_UPDATE := 3.0
const ORIGINAL_ENEMY_UPDATE_HZ := ORIGINAL_UPDATE_HZ * ORIGINAL_ENEMY_STEPS_PER_UPDATE
const ORIGINAL_DEFAULT_BALL_SPEED_PER_TICK := 2.5
const ORIGINAL_BALL_SPEEDUP_HIT_LIMIT := 100
const ORIGINAL_BALL_SPEEDUP_PER_TICK := 0.3
const ORIGINAL_BALL_MAX_SPEED_PER_TICK := 6.0
const DEFAULT_BALL_VELOCITY := Vector2(
	-ORIGINAL_DEFAULT_BALL_SPEED_PER_TICK * ORIGINAL_BALL_STEPS_PER_UPDATE * ORIGINAL_UPDATE_HZ,
	0.0
)
const RACKET_BOUNCE_MAX_Y_SPEED := 180.0
const BONUS_TYPE_COUNT := 22
const BONUS_SELECTOR_COUNT := 23
const MAX_FALLING_BONUSES := 20
const MAX_STACKED_BONUSES := 16
const BONUS_DROP_GATE_SECONDS := 3.0
const BONUS_SIZE := 32.0
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
const LEVEL_READY_ANIMATION_SECONDS := 1.5
const LEVEL_READY_STATUS_ICON_INDEX := 2
const MAX_PROJECTILES := 10
const PROJECTILE_FIRE_COOLDOWN_SECONDS := 0.25
const PROJECTILE_STEP_X := 7.0
const PROJECTILE_EXPIRE_X := 27.0
const PROJECTILE_SIZE := Vector2(30, 13)
const PROJECTILE_TRAIL_SIZE := Vector2(17, 13)
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
const RACKET_VISUAL_FRAME_SECONDS := 0.05
const RACKET_VISUAL_MAX_FRAME := 4
const MAX_MONSTERS := 5
const MONSTER_TYPE_CYCLE := [3, 6, 10]
const MONSTER_SIZE := Vector2(32, 32)
const MONSTER_COLLISION_SIZE := Vector2(26, 26)
const MONSTER_COLLISION_OFFSET := Vector2(3, 3)
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
const MONSTER_BALL_HIT_MIN_ROTATION_DEGREES := 90
const MONSTER_BALL_HIT_RANDOM_ROTATION_DEGREES := 90
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
const BEE_STUN_SCORE := 30
const RACKET_STUN_DURATION_SECONDS := 3.0
const MAX_IMPACT_EFFECTS := 100
const IMPACT_EFFECT_KIND_MONSTER_SPAWN := 0
const IMPACT_EFFECT_KIND_MONSTER_TIMEOUT := 1
const IMPACT_EFFECT_KIND_MONSTER_HIT := 2
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
	BONUS_DECREASE_BALL_SIZE: true,
	BONUS_INCREASE_BALL_SIZE: true,
	BONUS_INCREASE_BALL_SPEED: true,
	BONUS_DECREASE_BALL_SPEED: true,
	BONUS_SHOOTING_PADDLE_TIMED: true,
	BONUS_SHOOTING_PADDLE_CONTINUOUS: true,
	BONUS_SHRINK_PADDLE: true,
	BONUS_EXPAND_PADDLE: true,
	BONUS_BACK_WALL: true,
	BONUS_EXTRA_LIFE: true,
	BONUS_DESTROY_ONE_BALL: true,
	BONUS_JUMP_TO_NEXT_LEVEL: true,
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
const SFX_EVENT_CHAIN_EXPLOSION := "chain_explosion"
const SFX_EVENT_BONUS_SPAWN := "bonus_spawn"
const SFX_EVENT_BONUS_COLLECT := "bonus_collect"
const SFX_EVENT_BONUS_APPLY := "bonus_apply"
const SFX_EVENT_PROJECTILE_FIRE := "projectile_fire"
const SFX_EVENT_PROJECTILE_HIT := "projectile_hit"
const SFX_EVENT_MONSTER_SPAWN := "monster_spawn"
const SFX_EVENT_MONSTER_EXPIRE := "monster_expire"
const SFX_EVENT_MONSTER_HIT := "monster_hit"
const SFX_EVENT_BEE_SPAWN := "bee_spawn"
const SFX_EVENT_LIFE_LOST := "life_lost"
const SFX_EVENT_LEVEL_READY := "level_ready"
const SFX_EVENT_LEVEL_COMPLETE := "level_complete"
const SFX_EVENT_GAME_OVER := "game_over"

var board_state
var state := STATE_READY
var balls: Array[Dictionary] = []
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
var impact_effects: Array[Dictionary] = []
var back_wall_time_remaining := 0.0
var level_ready_time_remaining := 0.0
var _bonus_rng = RandomScript.new()
var _ball_animation_rng = RandomScript.new(31415)
var _bonus_animation_rng = RandomScript.new(31415)
var _monster_rng = RandomScript.new(31415)
var _collision_rng = RandomScript.new(31415)
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
var _monster_spawn_cooldown := MONSTER_SPAWN_INTERVAL_SECONDS
var _monster_type_cycle_index := 0
var _level_ready_animation_time_remaining := 0.0
var _audio_events: Array[String] = []


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
	falling_bonuses.clear()
	_clear_monster_state()
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


func visible_lives() -> int:
	return max(0, lives_remaining)


func _load_board_for_level(level: KrakoutLevelData) -> void:
	board_state = BoardStateScript.new() if level != null else null
	if board_state != null:
		board_state.load_level(level)
	_load_bonus_stock_from_level(level)


func move_racket_to(mouse_y: float) -> void:
	if is_racket_stunned():
		return
	var current_height := current_racket_height()
	racket_y = clampf(mouse_y - current_height * 0.5, RACKET_MIN_Y, RACKET_MAX_BOTTOM - current_height)
	if state == STATE_READY or state == STATE_BALL_LOST:
		_attach_ready_balls()


func launch_ready_ball() -> bool:
	if state != STATE_READY and state != STATE_BALL_LOST:
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
	_update_level_ready_sequence(delta)
	_update_bonus_timers(delta)
	_update_impact_effects(delta)
	_update_racket_visual(delta)
	_update_bonus_stack(delta)

	if board_state != null:
		var chain_cleared_count: int = board_state.process_chain_explosions(delta)
		if chain_cleared_count > 0:
			board_changed = true
			award_score(chain_cleared_count * BRICK_SCORE)
			_queue_audio_event(SFX_EVENT_CHAIN_EXPLOSION)

	if board_state != null and board_state.is_complete():
		_mark_level_complete()
		return

	if state == STATE_GAME_OVER:
		return

	_update_monsters(delta)
	_update_bees(delta)

	if state != STATE_PLAYING:
		_attach_ready_balls()
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


func active_bonus_indicators() -> Array[Dictionary]:
	var indicators: Array[Dictionary] = []
	if is_level_ready_sequence_active():
		indicators.append({
			"icon_index": LEVEL_READY_STATUS_ICON_INDEX,
			"value": ceili(level_ready_time_remaining),
		})
	if is_back_wall_active():
		indicators.append({
			"icon_index": BACK_WALL_STATUS_ICON_INDEX,
			"value": ceili(back_wall_time_remaining),
		})
	return indicators


func start_level_ready_sequence(queue_audio := true) -> void:
	level_ready_time_remaining = LEVEL_READY_SEQUENCE_SECONDS
	_level_ready_animation_time_remaining = LEVEL_READY_ANIMATION_SECONDS
	if queue_audio:
		_queue_audio_event(SFX_EVENT_LEVEL_READY)


func is_level_ready_sequence_active() -> bool:
	return level_ready_time_remaining > 0.0


func level_ready_animation_progress() -> float:
	if LEVEL_READY_ANIMATION_SECONDS <= 0.0:
		return 1.0
	return 1.0 - clampf(_level_ready_animation_time_remaining / LEVEL_READY_ANIMATION_SECONDS, 0.0, 1.0)


func is_back_wall_active() -> bool:
	return back_wall_time_remaining > 0.0


func is_shooting_paddle_active() -> bool:
	return _shooting_paddle_mode == PROJECTILE_MODE_CONTINUOUS


func is_single_shot_paddle_armed() -> bool:
	return _single_shot_projectile_armed


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


func pop_audio_events() -> Array[String]:
	var events: Array[String] = []
	for event_name: String in _audio_events:
		events.append(event_name)
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

	var result := _apply_bonus_effect(type_id)
	_consume_next_bonus()
	result["status"] = "applied"
	result["type_id"] = type_id
	result["name"] = bonus_type_name(type_id)
	_queue_audio_event(SFX_EVENT_BONUS_APPLY)
	return result


static func bonus_type_name(type_id: int) -> String:
	if type_id >= 0 and type_id < BONUS_TYPE_NAMES.size():
		return String(BONUS_TYPE_NAMES[type_id])
	return "Unknown Bonus"


func set_bonus_rng_seed(seed_value: int) -> void:
	_bonus_rng.set_seed(seed_value)


func set_monster_rng_seed(seed_value: int) -> void:
	_monster_rng.set_seed(seed_value)


func set_collision_rng_seed(seed_value: int) -> void:
	_collision_rng.set_seed(seed_value)


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


func current_racket_height() -> float:
	return RACKET_SEGMENT_PIXEL_STEP * float(racket_segment_count) + RACKET_SEGMENT_MARGIN


func racket_rect() -> Rect2:
	return Rect2(Vector2(RACKET_X, racket_y), Vector2(RACKET_WIDTH, current_racket_height()))


func ball_rect(ball: Dictionary) -> Rect2:
	var size := float(ball.get("size", BALL_SIZE))
	return Rect2(ball.get("position", Vector2.ZERO), Vector2(size, size))


func projectile_rect(projectile: Dictionary) -> Rect2:
	return Rect2(projectile.get("position", Vector2.ZERO), PROJECTILE_SIZE)


func monster_rect(monster: Dictionary) -> Rect2:
	return Rect2(monster.get("position", Vector2.ZERO) + MONSTER_COLLISION_OFFSET, MONSTER_COLLISION_SIZE)


func bee_rect(bee: Dictionary) -> Rect2:
	return Rect2(bee.get("position", Vector2.ZERO) + BEE_COLLISION_OFFSET, BEE_COLLISION_SIZE)


func first_ball_position() -> Vector2:
	if balls.is_empty():
		return Vector2.ZERO
	return balls[0].get("position", Vector2.ZERO)


func first_ball_velocity() -> Vector2:
	if balls.is_empty():
		return Vector2.ZERO
	return balls[0].get("velocity", Vector2.ZERO)


func force_ball(position: Vector2, velocity: Vector2, size: float = BALL_SIZE) -> void:
	balls = [{
		"active": true,
		"position": position,
		"velocity": velocity,
		"size": size,
		"frame": 0,
		"frame_elapsed": 0.0,
		"speed_scale": ball_speed_scale,
		"target_speed": _target_speed_for_new_ball(velocity),
		"speed_hit_count": 0,
	}]
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


func _add_ready_ball() -> void:
	_add_ball(_ready_ball_position(), Vector2.ZERO, true)


func _add_ball(position: Vector2, velocity: Vector2, active := true) -> bool:
	if balls.size() >= MAX_BALLS:
		return false
	balls.append({
		"active": active,
		"position": position,
		"velocity": velocity,
		"size": ball_size,
		"frame": _ball_animation_rng.next_mod(BALL_FRAME_COUNT),
		"frame_elapsed": 0.0,
		"speed_scale": ball_speed_scale,
		"target_speed": _target_speed_for_new_ball(velocity),
		"speed_hit_count": 0,
	})
	return true


func _add_active_standard_ball() -> bool:
	return _add_ball(_ready_ball_position(), _velocity_for_current_speed(DEFAULT_BALL_VELOCITY), true)


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
		balls[index] = ball


func _ready_ball_position() -> Vector2:
	return Vector2(
		RACKET_X - ball_size - READY_BALL_GAP,
		racket_y + current_racket_height() * 0.5 - ball_size * 0.5
	)


func _advance_ball(ball: Dictionary, delta: float) -> void:
	var previous_position: Vector2 = ball.get("position", Vector2.ZERO)
	var position := previous_position + Vector2(ball.get("velocity", Vector2.ZERO)) * delta
	var velocity: Vector2 = ball.get("velocity", Vector2.ZERO)
	var size := float(ball.get("size", BALL_SIZE))
	var wall_hit := false

	if position.y <= BALL_TOP_Y:
		position.y = BALL_TOP_Y
		velocity.y = absf(velocity.y)
		wall_hit = true
	elif position.y + size >= BALL_BOTTOM_Y:
		position.y = BALL_BOTTOM_Y - size
		velocity.y = -absf(velocity.y)
		wall_hit = true

	if position.x <= BALL_LEFT_X:
		position.x = BALL_LEFT_X
		velocity.x = absf(velocity.x)
		wall_hit = true

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
	elif position.x > BALL_LOST_X:
		ball["active"] = false
		return

	if _collide_ball_with_monsters(ball):
		return
	if _collide_ball_with_bees(ball):
		return
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


func _update_level_ready_sequence(delta: float) -> void:
	if level_ready_time_remaining > 0.0:
		level_ready_time_remaining = maxf(0.0, level_ready_time_remaining - delta)
	if _level_ready_animation_time_remaining > 0.0:
		_level_ready_animation_time_remaining = maxf(0.0, _level_ready_animation_time_remaining - delta)


func _clear_level_ready_sequence() -> void:
	level_ready_time_remaining = 0.0
	_level_ready_animation_time_remaining = 0.0


func _collide_with_racket(ball: Dictionary) -> bool:
	var rect := ball_rect(ball)
	if not rect.intersects(racket_rect()):
		return false

	var velocity: Vector2 = ball.get("velocity", Vector2.ZERO)
	if velocity.x <= 0.0:
		return false

	rect.position.x = RACKET_X - rect.size.x
	velocity.x = -absf(velocity.x)

	var racket_height := current_racket_height()
	var racket_center := racket_y + racket_height * 0.5
	var ball_center := rect.position.y + rect.size.y * 0.5
	var normalized_hit := clampf((ball_center - racket_center) / (racket_height * 0.5), -1.0, 1.0)
	var speed := _target_speed_for_ball(ball)
	var max_y_speed := minf(RACKET_BOUNCE_MAX_Y_SPEED, speed * 0.95)
	velocity.y = normalized_hit * max_y_speed
	velocity.x = -sqrt(maxf(0.0, speed * speed - velocity.y * velocity.y))

	ball["position"] = rect.position
	ball["velocity"] = velocity
	ball["target_speed"] = speed
	_register_ball_speed_hit(ball)
	_queue_audio_event(SFX_EVENT_RACKET_BOUNCE)
	return true


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
	_queue_audio_event(SFX_EVENT_BACK_WALL_BOUNCE)
	return true


func _collide_with_board(ball: Dictionary, previous_position: Vector2) -> bool:
	if board_state == null:
		return false

	var rect := ball_rect(ball)
	var hit := _first_board_hit(rect)
	if hit.is_empty():
		return false

	var column := int(hit["column"])
	var row := int(hit["row"])
	var tile_id := int(hit["tile_id"])
	var hit_result := _resolve_board_tile_hit(column, row, tile_id)
	_apply_board_hit_result(hit_result)

	_reflect_from_tile(ball, previous_position, PlayfieldSpecScript.brick_rect(column, row))
	_register_ball_speed_hit(ball)
	return true


func _resolve_board_tile_hit(column: int, row: int, tile_id: int) -> Dictionary:
	var cleared_count := 0
	var did_change_board := false
	var audio_event := ""
	if BrickSemanticsScript.is_chain_explosion_tile(tile_id):
		cleared_count = board_state.explode_at(column, row)
		did_change_board = cleared_count > 0
		if cleared_count > 0:
			audio_event = SFX_EVENT_CHAIN_EXPLOSION
	else:
		var regular_hit_result := _resolve_regular_brick_hit(column, row, tile_id)
		cleared_count = int(regular_hit_result.get("cleared_count", 0))
		did_change_board = bool(regular_hit_result.get("changed", false))
		audio_event = String(regular_hit_result.get("audio_event", ""))

	return {
		"changed": did_change_board,
		"cleared_count": cleared_count,
		"audio_event": audio_event,
	}


func _apply_board_hit_result(hit_result: Dictionary) -> void:
	var did_change_board := bool(hit_result.get("changed", false))
	var cleared_count := int(hit_result.get("cleared_count", 0))
	if did_change_board:
		board_changed = true
	if cleared_count > 0:
		award_score(cleared_count * BRICK_SCORE)
	var audio_event := String(hit_result.get("audio_event", ""))
	if not audio_event.is_empty():
		_queue_audio_event(audio_event)


func _resolve_regular_brick_hit(column: int, row: int, tile_id: int) -> Dictionary:
	var bonus_result := _try_resolve_bonus_drop(column, row, tile_id)
	var action := String(bonus_result.get("action", "clear"))
	if action == "chain":
		return {
			"changed": true,
			"cleared_count": 0,
		}

	var cleared_count := 0
	if board_state.clear_tile(column, row):
		cleared_count = 1

	if action == "spawn":
		if _spawn_falling_bonus(
			int(bonus_result.get("type_id", 0)),
			PlayfieldSpecScript.brick_rect(column, row).position
		):
			_queue_audio_event(SFX_EVENT_BONUS_SPAWN)

	return {
		"changed": cleared_count > 0,
		"cleared_count": cleared_count,
		"audio_event": SFX_EVENT_BRICK_CLEAR if cleared_count > 0 else "",
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
	racket_y = clampf(racket_y, RACKET_MIN_Y, RACKET_MAX_BOTTOM - current_racket_height())


func _reset_bonus_drop_gate() -> void:
	_bonus_drop_cooldown = BONUS_DROP_GATE_SECONDS


func _clear_timed_bonus_state() -> void:
	back_wall_time_remaining = 0.0
	projectiles.clear()
	_shooting_paddle_mode = PROJECTILE_MODE_DISABLED
	_single_shot_projectile_armed = false
	racket_visual_mode = RACKET_VISUAL_MODE_NORMAL
	racket_visual_frame = 0
	_racket_visual_target_mode = RACKET_VISUAL_MODE_NORMAL
	_racket_visual_elapsed = 0.0
	_projectile_fire_cooldown = 0.0


func _update_bonus_timers(delta: float) -> void:
	if _bonus_drop_cooldown > 0.0:
		_bonus_drop_cooldown = maxf(0.0, _bonus_drop_cooldown - delta)
	if back_wall_time_remaining > 0.0:
		back_wall_time_remaining = maxf(0.0, back_wall_time_remaining - delta)
	if _racket_stun_time_remaining > 0.0:
		_racket_stun_time_remaining = maxf(0.0, _racket_stun_time_remaining - delta)


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
		else:
			racket_visual_mode = _racket_visual_target_mode
			if racket_visual_frame < RACKET_VISUAL_MAX_FRAME:
				racket_visual_frame += 1


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
	})
	return true


func _update_falling_bonuses(delta: float) -> void:
	for index in range(falling_bonuses.size()):
		var bonus := falling_bonuses[index]
		if not bool(bonus.get("active", false)):
			continue

		_advance_falling_bonus(bonus, delta)
		if bonus_rect(bonus).intersects(racket_rect()) and _push_bonus_stack(int(bonus.get("type_id", 0))):
			bonus["active"] = false
			_queue_audio_event(SFX_EVENT_BONUS_COLLECT)

		falling_bonuses[index] = bonus

	_compact_falling_bonuses()


func _advance_falling_bonus(bonus: Dictionary, delta: float) -> void:
	var position: Vector2 = bonus.get("position", Vector2.ZERO)
	var next_x := position.x + BONUS_STEP_X
	var next_angle := (int(bonus.get("angle", 0)) + BONUS_ANGLE_STEP) % 360
	var base_y := float(bonus.get("base_y", position.y))
	var next_y := base_y + next_x * BONUS_WAVE_SCALE * cos(deg_to_rad(float(next_angle)))
	next_y = clampf(next_y, BONUS_MIN_Y, BONUS_MAX_Y)

	var frame_elapsed := float(bonus.get("frame_elapsed", 0.0)) + delta
	var frame := int(bonus.get("frame", 0))
	while frame_elapsed >= BONUS_FALLING_FRAME_SECONDS:
		frame = (frame + 1) % BONUS_ANIMATION_FRAME_COUNT
		frame_elapsed -= BONUS_FALLING_FRAME_SECONDS

	bonus["position"] = Vector2(next_x, next_y)
	bonus["angle"] = next_angle
	bonus["frame"] = frame
	bonus["frame_elapsed"] = frame_elapsed
	if next_x > BONUS_EXPIRE_X:
		bonus["active"] = false


func _update_projectile_fire(delta: float) -> void:
	if _projectile_fire_cooldown > 0.0:
		_projectile_fire_cooldown = maxf(0.0, _projectile_fire_cooldown - delta)
		if is_zero_approx(_projectile_fire_cooldown):
			_projectile_fire_cooldown = 0.0


func _spawn_projectile(projectile_type: int) -> bool:
	_compact_projectiles()
	if projectiles.size() >= MAX_PROJECTILES:
		return false

	projectiles.append({
		"active": true,
		"type": projectile_type,
		"position": _projectile_spawn_position(),
		"head_frame": 0,
		"head_frame_elapsed": 0.0,
		"trail_frame": 0,
		"trail_frame_elapsed": 0.0,
	})
	_queue_audio_event(SFX_EVENT_PROJECTILE_FIRE)
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
		int(hit["tile_id"])
	)
	_apply_board_hit_result(hit_result)
	_queue_audio_event(SFX_EVENT_PROJECTILE_HIT)
	return true


func _clear_monster_state() -> void:
	monsters.clear()
	bees.clear()
	impact_effects.clear()
	_monster_spawn_cooldown = MONSTER_SPAWN_INTERVAL_SECONDS
	_monster_type_cycle_index = 0
	_bee_spawn_delay_remaining = BEE_SPAWN_DELAY_MAX_SECONDS
	_racket_stun_time_remaining = 0.0


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

	var type_id := int(MONSTER_TYPE_CYCLE[_monster_type_cycle_index % MONSTER_TYPE_CYCLE.size()])
	_monster_type_cycle_index += 1
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
	_queue_audio_event(SFX_EVENT_MONSTER_SPAWN)
	return true


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
		monster["active"] = false
		_spawn_impact_effect(monster.get("position", Vector2.ZERO), IMPACT_EFFECT_KIND_MONSTER_TIMEOUT)
		_queue_audio_event(SFX_EVENT_MONSTER_EXPIRE)
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
	if type_id == 3 and not bool(monster.get("boundary_reflected", false)):
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
	elif type_id == 10:
		angle = _tracking_angle_for_monster(monster, angle, tick_scale)
		position += _monster_motion_vector(angle, distance)
	else:
		position += _monster_motion_vector(angle, distance)

	monster["position"] = position
	monster["angle"] = angle
	_collide_monster_with_boundaries(monster)


func _collide_monster_with_boundaries(monster: Dictionary) -> bool:
	var position: Vector2 = monster.get("position", Vector2.ZERO)
	var rect := Rect2(position + MONSTER_COLLISION_OFFSET, MONSTER_COLLISION_SIZE)
	var hit_horizontal := false
	var hit_vertical := false

	if rect.position.x < PlayfieldSpecScript.WALL_INNER_LEFT_X:
		position.x = PlayfieldSpecScript.WALL_INNER_LEFT_X - MONSTER_COLLISION_OFFSET.x
		hit_horizontal = true
	elif rect.end.x > PlayfieldSpecScript.WALL_INNER_RIGHT_X:
		position.x = PlayfieldSpecScript.WALL_INNER_RIGHT_X - MONSTER_COLLISION_OFFSET.x - MONSTER_COLLISION_SIZE.x
		hit_horizontal = true

	if rect.position.y < PlayfieldSpecScript.WALL_INNER_TOP_Y:
		position.y = PlayfieldSpecScript.WALL_INNER_TOP_Y - MONSTER_COLLISION_OFFSET.y
		hit_vertical = true
	elif rect.end.y > PlayfieldSpecScript.WALL_INNER_BOTTOM_Y:
		position.y = PlayfieldSpecScript.WALL_INNER_BOTTOM_Y - MONSTER_COLLISION_OFFSET.y - MONSTER_COLLISION_SIZE.y
		hit_vertical = true

	if not hit_horizontal and not hit_vertical:
		return false

	var angle := float(monster.get("angle", 0.0))
	if hit_horizontal:
		angle = fposmod(180.0 - angle, 360.0)
	if hit_vertical:
		angle = fposmod(360.0 - angle, 360.0)
	monster["position"] = position
	monster["angle"] = angle
	monster["boundary_reflected"] = true
	return true


func _frame_count_for_monster_type(type_id: int) -> int:
	if type_id <= 6 or type_id == 9:
		return 20
	if type_id == 8:
		return 10
	return 11


func _tracking_angle_for_monster(monster: Dictionary, current_angle: float, tick_scale: float) -> float:
	var target_position := _first_active_ball_center()
	if target_position == Vector2.INF:
		return current_angle

	var monster_center := Vector2(monster.get("position", Vector2.ZERO)) + MONSTER_SIZE * 0.5
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


func _first_active_ball_center() -> Vector2:
	for ball: Dictionary in balls:
		if bool(ball.get("active", false)):
			return ball_rect(ball).get_center()
	return Vector2.INF


func _monster_motion_vector(angle: float, speed: float) -> Vector2:
	var radians := deg_to_rad(fposmod(angle, 360.0))
	return Vector2(cos(radians) * speed, -sin(radians) * speed)


func _collide_ball_with_monsters(ball: Dictionary) -> bool:
	var rect := ball_rect(ball)
	for index in range(monsters.size()):
		var monster: Dictionary = monsters[index]
		if not bool(monster.get("active", false)):
			continue
		if rect.intersects(monster_rect(monster)):
			_rotate_ball_from_enemy_contact(ball)
			_kill_monster_at_index(index, _score_for_monster_ball_contact(monster))
			return true
	return false


func _collide_ball_with_bees(ball: Dictionary) -> bool:
	var rect := ball_rect(ball)
	for index in range(bees.size()):
		var bee: Dictionary = bees[index]
		if not bool(bee.get("active", false)):
			continue
		if rect.intersects(bee_rect(bee)):
			_rotate_ball_from_enemy_contact(ball)
			_kill_bee_at_index(index, BEE_BALL_HIT_SCORE)
			return true
	return false


func _collide_projectile_with_monsters(projectile: Dictionary) -> bool:
	var rect := projectile_rect(projectile)
	for index in range(monsters.size()):
		var monster: Dictionary = monsters[index]
		if not bool(monster.get("active", false)):
			continue
		if rect.intersects(monster_rect(monster)):
			_kill_monster_at_index(index, _score_for_monster_paddle_contact(monster))
			_queue_audio_event(SFX_EVENT_PROJECTILE_HIT)
			return true
	return false


func _collide_monster_with_racket(index: int, monster: Dictionary) -> bool:
	if not monster_rect(monster).intersects(racket_rect()):
		return false

	_kill_monster_at_index(index, _score_for_monster_paddle_contact(monster))
	if int(monster.get("type_id", 0)) == 9:
		_apply_racket_stun()
	return true


func _kill_monster_at_index(index: int, score_value: int = -1) -> void:
	if index < 0 or index >= monsters.size():
		return
	var monster := monsters[index]
	monster["active"] = false
	monsters[index] = monster
	award_score(score_value if score_value >= 0 else _score_for_monster_paddle_contact(monster))
	_spawn_impact_effect(monster.get("position", Vector2.ZERO), IMPACT_EFFECT_KIND_MONSTER_HIT)
	_queue_audio_event(SFX_EVENT_MONSTER_HIT)


func _score_for_monster_paddle_contact(monster: Dictionary) -> int:
	if int(monster.get("type_id", 0)) == 6:
		return MONSTER_TYPE6_SCORE_STEP * (_monster_rng.next_mod(MONSTER_TYPE6_SCORE_VARIANTS) + 1)
	return MONSTER_SCORE


func _score_for_monster_ball_contact(monster: Dictionary) -> int:
	if int(monster.get("type_id", 0)) == 6:
		return MONSTER_TYPE6_SCORE_STEP * (_collision_rng.next_mod(MONSTER_TYPE6_SCORE_VARIANTS) + 1)
	return MONSTER_BALL_HIT_SCORE


func _rotate_ball_from_enemy_contact(ball: Dictionary) -> void:
	var velocity: Vector2 = ball.get("velocity", Vector2.ZERO)
	var speed := _target_speed_for_ball(ball)

	var current_angle := 0
	if not velocity.is_zero_approx():
		current_angle = posmod(int(roundi(rad_to_deg(atan2(-velocity.y, velocity.x)))), 360)
	var next_angle := posmod(
		current_angle + MONSTER_BALL_HIT_MIN_ROTATION_DEGREES + _collision_rng.next_mod(MONSTER_BALL_HIT_RANDOM_ROTATION_DEGREES),
		360
	)
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
	_queue_audio_event(SFX_EVENT_BEE_SPAWN)
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
	award_score(score_value)
	_spawn_impact_effect(bee.get("position", Vector2.ZERO), IMPACT_EFFECT_KIND_MONSTER_HIT)
	_queue_audio_event(SFX_EVENT_MONSTER_HIT)


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


func _compact_bees() -> void:
	var compacted: Array[Dictionary] = []
	for bee: Dictionary in bees:
		if bool(bee.get("active", false)):
			compacted.append(bee)
	bees = compacted


func _compact_impact_effects() -> void:
	var compacted: Array[Dictionary] = []
	for effect: Dictionary in impact_effects:
		if bool(effect.get("active", false)):
			compacted.append(effect)
	impact_effects = compacted


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
			return {"effect": "add_standard_ball", "applied": _add_active_standard_ball()}
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
		BONUS_BACK_WALL:
			return _activate_back_wall()
		BONUS_EXTRA_LIFE:
			lives_remaining += 1
			return {"effect": "extra_life", "lives_remaining": lives_remaining}
		BONUS_DESTROY_ONE_BALL:
			return {"effect": "destroy_one_ball", "applied": _destroy_one_active_ball()}
		BONUS_JUMP_TO_NEXT_LEVEL:
			_mark_level_complete()
			return {"effect": "jump_to_next_level"}
	return {"effect": "unsupported"}


func _adjust_ball_size(delta_size: float) -> Dictionary:
	ball_size = clampf(ball_size + delta_size, BALL_MIN_SIZE, BALL_MAX_SIZE)
	for index in range(balls.size()):
		var ball := balls[index]
		ball["size"] = ball_size
		balls[index] = ball
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


func _adjust_racket_segments(delta_segments: int) -> Dictionary:
	if delta_segments < 0:
		if racket_segment_count > RACKET_SHRINK_LIMIT_SEGMENTS:
			racket_segment_count += delta_segments
	elif delta_segments > 0:
		if racket_segment_count < RACKET_EXPAND_LIMIT_SEGMENTS:
			racket_segment_count += delta_segments
	racket_y = clampf(racket_y, RACKET_MIN_Y, RACKET_MAX_BOTTOM - current_racket_height())
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


func _activate_shooting_paddle_one_shot() -> Dictionary:
	_shooting_paddle_mode = PROJECTILE_MODE_DISABLED
	_single_shot_projectile_armed = true
	_set_racket_visual_target(RACKET_VISUAL_MODE_SHOOTING_ONE_SHOT)
	return {
		"effect": "shooting_paddle_one_shot",
		"armed": true,
	}


func _activate_shooting_paddle_continuous() -> Dictionary:
	_shooting_paddle_mode = PROJECTILE_MODE_CONTINUOUS
	_single_shot_projectile_armed = false
	_set_racket_visual_target(RACKET_VISUAL_MODE_SHOOTING_CONTINUOUS)
	return {
		"effect": "shooting_paddle_continuous",
		"armed": true,
	}


func _destroy_one_active_ball() -> bool:
	for index in range(balls.size()):
		var ball := balls[index]
		if bool(ball.get("active", false)):
			balls.remove_at(index)
			return true
	return false


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
		falling_bonuses.clear()
		_clear_timed_bonus_state()
		_clear_monster_state()
		_queue_audio_event(SFX_EVENT_GAME_OVER)
		return

	_queue_audio_event(SFX_EVENT_LIFE_LOST)
	reset_round()


func _update_displayed_score() -> void:
	if displayed_score + 10 < score:
		displayed_score += 10
	elif displayed_score < score:
		displayed_score += 1


func _mark_level_complete() -> void:
	if state == STATE_LEVEL_COMPLETE:
		return
	state = STATE_LEVEL_COMPLETE
	_queue_audio_event(SFX_EVENT_LEVEL_COMPLETE)


func _queue_audio_event(event_name: String) -> void:
	if event_name.is_empty():
		return
	_audio_events.append(event_name)
