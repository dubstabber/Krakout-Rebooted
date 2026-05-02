extends RefCounted
class_name KrakoutGameSession

const BoardStateScript := preload("res://src/gameplay/krakout_board_state.gd")
const BrickSemanticsScript := preload("res://src/gameplay/krakout_brick_semantics.gd")
const PlayfieldSpecScript := preload("res://src/playfield/krakout_playfield_spec.gd")

const STATE_READY := "ready"
const STATE_PLAYING := "playing"
const STATE_BALL_LOST := "ball_lost"
const STATE_LEVEL_COMPLETE := "level_complete"

const MAX_BALLS := 5
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

var board_state
var state := STATE_READY
var balls: Array[Dictionary] = []
var racket_y := RACKET_MIN_Y
var board_changed := false


func load_level(level: KrakoutLevelData) -> void:
	board_state = BoardStateScript.new() if level != null else null
	if board_state != null:
		board_state.load_level(level)
	reset_round()


func set_board_state(state_value) -> void:
	board_state = state_value
	reset_round()


func reset_round() -> void:
	state = STATE_READY
	board_changed = false
	balls.clear()
	_add_ready_ball()


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

	if board_state != null and board_state.process_chain_explosions(delta) > 0:
		board_changed = true

	if board_state != null and board_state.is_complete():
		state = STATE_LEVEL_COMPLETE
		return

	if state != STATE_PLAYING:
		_attach_ready_balls()
		return

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
		state = STATE_BALL_LOST


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
	var changed := false
	if BrickSemanticsScript.is_chain_explosion_tile(tile_id):
		changed = board_state.explode_at(column, row) > 0
	else:
		changed = board_state.clear_tile(column, row)

	if changed:
		board_changed = true

	_reflect_from_tile(ball, previous_position, PlayfieldSpecScript.brick_rect(column, row))
	return true


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
