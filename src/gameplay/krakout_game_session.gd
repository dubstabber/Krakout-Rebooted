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
const RACKET_HEIGHT := 164.0
const RACKET_MIN_Y := 63.0
const RACKET_MAX_BOTTOM := 453.0
const BALL_SIZE := 16.0
const BALL_TOP_Y := 41.0
const BALL_BOTTOM_Y := 453.0
const BALL_LEFT_X := 5.0
const BALL_LOST_X := 575.0
const READY_BALL_GAP := 10.0
const DEFAULT_BALL_VELOCITY := Vector2(-260.0, -90.0)
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

var board_state
var state := STATE_READY
var balls: Array[Dictionary] = []
var racket_y := RACKET_MIN_Y
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
var _bonus_rng = RandomScript.new()
var _bonus_animation_rng = RandomScript.new(31415)
var _bonus_drop_cooldown := BONUS_DROP_GATE_SECONDS
var _bonus_pointer_elapsed := 0.0


func _init() -> void:
	_bonus_rng.set_seed(Time.get_ticks_msec())


func load_level(level: KrakoutLevelData) -> void:
	var next_display_level := 1
	if level != null and level.level_number > 0:
		next_display_level = level.level_number
	start_run(level, next_display_level)


func start_run(level: KrakoutLevelData, selected_display_level_number: int = 1, starting_best_score: int = 0) -> void:
	score = 0
	displayed_score = 0
	best_score = max(0, starting_best_score)
	lives_remaining = INITIAL_LIVES
	points_to_next_extra_life = EXTRA_LIFE_SCORE_STEP
	display_level_number = max(1, selected_display_level_number)
	_clear_bonus_run_state()
	_load_board_for_level(level)
	reset_round()


func advance_to_level(level: KrakoutLevelData, next_display_level_number: int) -> void:
	display_level_number = max(1, next_display_level_number)
	falling_bonuses.clear()
	_reset_bonus_drop_gate()
	_load_board_for_level(level)
	reset_round()


func set_board_state(state_value) -> void:
	board_state = state_value
	_load_bonus_stock_from_level(board_state.source_level if board_state != null else null)
	falling_bonuses.clear()
	_reset_bonus_drop_gate()
	reset_round()


func reset_round() -> void:
	state = STATE_READY
	board_changed = false
	balls.clear()
	falling_bonuses.clear()
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
	racket_y = clampf(mouse_y - RACKET_HEIGHT * 0.5, RACKET_MIN_Y, RACKET_MAX_BOTTOM - RACKET_HEIGHT)
	if state == STATE_READY or state == STATE_BALL_LOST:
		_attach_ready_balls()


func launch_ready_ball() -> bool:
	if state != STATE_READY and state != STATE_BALL_LOST:
		return false

	if balls.is_empty():
		_add_ready_ball()

	var ball := balls[0]
	ball["active"] = true
	ball["velocity"] = DEFAULT_BALL_VELOCITY
	balls[0] = ball
	state = STATE_PLAYING
	return true


func update(delta: float) -> void:
	board_changed = false
	_update_displayed_score()
	_update_bonus_timers(delta)
	_update_bonus_stack(delta)

	if board_state != null:
		var chain_cleared_count: int = board_state.process_chain_explosions(delta)
		if chain_cleared_count > 0:
			board_changed = true
			award_score(chain_cleared_count * BRICK_SCORE)

	if board_state != null and board_state.is_complete():
		state = STATE_LEVEL_COMPLETE
		return

	if state == STATE_GAME_OVER:
		return

	if state != STATE_PLAYING:
		_attach_ready_balls()
		return

	_update_falling_bonuses(delta)

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
		state = STATE_LEVEL_COMPLETE
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


func bonus_stack_entries() -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	for entry: Dictionary in bonus_stack:
		entries.append(entry.duplicate())
	return entries


func set_bonus_rng_seed(seed_value: int) -> void:
	_bonus_rng.set_seed(seed_value)


func force_bonus_drop_ready() -> void:
	_bonus_drop_cooldown = 0.0


func active_ball_count() -> int:
	return visible_balls().size()


func racket_rect() -> Rect2:
	return Rect2(Vector2(RACKET_X, racket_y), Vector2(RACKET_WIDTH, RACKET_HEIGHT))


func ball_rect(ball: Dictionary) -> Rect2:
	var size := float(ball.get("size", BALL_SIZE))
	return Rect2(ball.get("position", Vector2.ZERO), Vector2(size, size))


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
	}]
	state = STATE_PLAYING


func _add_ready_ball() -> void:
	if balls.size() >= MAX_BALLS:
		return

	balls.append({
		"active": true,
		"position": _ready_ball_position(),
		"velocity": Vector2.ZERO,
		"size": BALL_SIZE,
	})


func _attach_ready_balls() -> void:
	for index in range(balls.size()):
		var ball := balls[index]
		ball["active"] = true
		ball["position"] = _ready_ball_position()
		ball["velocity"] = Vector2.ZERO
		balls[index] = ball


func _ready_ball_position() -> Vector2:
	return Vector2(
		RACKET_X - BALL_SIZE - READY_BALL_GAP,
		racket_y + RACKET_HEIGHT * 0.5 - BALL_SIZE * 0.5
	)


func _advance_ball(ball: Dictionary, delta: float) -> void:
	var previous_position: Vector2 = ball.get("position", Vector2.ZERO)
	var position := previous_position + Vector2(ball.get("velocity", Vector2.ZERO)) * delta
	var velocity: Vector2 = ball.get("velocity", Vector2.ZERO)
	var size := float(ball.get("size", BALL_SIZE))

	if position.y <= BALL_TOP_Y:
		position.y = BALL_TOP_Y
		velocity.y = absf(velocity.y)
	elif position.y + size >= BALL_BOTTOM_Y:
		position.y = BALL_BOTTOM_Y - size
		velocity.y = -absf(velocity.y)

	if position.x <= BALL_LEFT_X:
		position.x = BALL_LEFT_X
		velocity.x = absf(velocity.x)

	ball["position"] = position
	ball["velocity"] = velocity

	if _collide_with_racket(ball):
		position = ball.get("position", position)
		velocity = ball.get("velocity", velocity)

	if position.x > BALL_LOST_X:
		ball["active"] = false
		return

	_collide_with_board(ball, previous_position)


func _collide_with_racket(ball: Dictionary) -> bool:
	var rect := ball_rect(ball)
	if not rect.intersects(racket_rect()):
		return false

	var velocity: Vector2 = ball.get("velocity", Vector2.ZERO)
	if velocity.x <= 0.0:
		return false

	rect.position.x = RACKET_X - rect.size.x
	velocity.x = -absf(velocity.x)

	var racket_center := racket_y + RACKET_HEIGHT * 0.5
	var ball_center := rect.position.y + rect.size.y * 0.5
	var normalized_hit := clampf((ball_center - racket_center) / (RACKET_HEIGHT * 0.5), -1.0, 1.0)
	velocity.y = normalized_hit * 180.0

	ball["position"] = rect.position
	ball["velocity"] = velocity
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
	var cleared_count := 0
	var did_change_board := false
	if BrickSemanticsScript.is_chain_explosion_tile(tile_id):
		cleared_count = board_state.explode_at(column, row)
		did_change_board = cleared_count > 0
	else:
		var regular_hit_result := _resolve_regular_brick_hit(column, row, tile_id)
		cleared_count = int(regular_hit_result.get("cleared_count", 0))
		did_change_board = bool(regular_hit_result.get("changed", false))

	if did_change_board:
		board_changed = true
	if cleared_count > 0:
		award_score(cleared_count * BRICK_SCORE)

	_reflect_from_tile(ball, previous_position, PlayfieldSpecScript.brick_rect(column, row))
	return true


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
		_spawn_falling_bonus(
			int(bonus_result.get("type_id", 0)),
			PlayfieldSpecScript.brick_rect(column, row).position
		)

	return {
		"changed": cleared_count > 0,
		"cleared_count": cleared_count,
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
	_reset_bonus_drop_gate()


func _reset_bonus_drop_gate() -> void:
	_bonus_drop_cooldown = BONUS_DROP_GATE_SECONDS


func _update_bonus_timers(delta: float) -> void:
	if _bonus_drop_cooldown > 0.0:
		_bonus_drop_cooldown = maxf(0.0, _bonus_drop_cooldown - delta)


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


func _handle_round_lost() -> void:
	lives_remaining -= 1
	if lives_remaining < 0:
		state = STATE_GAME_OVER
		balls.clear()
		falling_bonuses.clear()
		return

	reset_round()


func _update_displayed_score() -> void:
	if displayed_score + 10 < score:
		displayed_score += 10
	elif displayed_score < score:
		displayed_score += 1
