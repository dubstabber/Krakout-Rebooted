extends RefCounted
class_name KrakoutLevelReadySystem

const BallRulesScript := preload("res://src/gameplay/rules/krakout_ball_rules.gd")
const BonusCatalogScript := preload("res://src/gameplay/rules/krakout_bonus_catalog.gd")

const SEQUENCE_SECONDS := BonusCatalogScript.LEVEL_READY_SEQUENCE_SECONDS
const STATUS_ICON_INDEX := BonusCatalogScript.LEVEL_READY_STATUS_ICON_INDEX
const ROLLER_FRAME_COUNT := 10
const ROLLER_STEP_SECONDS := 1.0 / BallRulesScript.ORIGINAL_UPDATE_HZ
const ROLLER_STEP_EPSILON := 0.000001
const ROLLER_STEP_PIXELS := 4.0
const ROLLER_SOURCE_SIZE := Vector2(20, 390)
const ROLLER_POSITION := Vector2(47, 63)
const ROLLER_TRAVEL_PIXELS := 380.0
const ANIMATION_SECONDS := ROLLER_TRAVEL_PIXELS / ROLLER_STEP_PIXELS * ROLLER_STEP_SECONDS

var _state


func _init(initial_state = null) -> void:
	_state = initial_state


func bind_state(next_state) -> void:
	_state = next_state


func start() -> void:
	if _state == null:
		return
	_state.level_ready_time_remaining = SEQUENCE_SECONDS
	_state.level_ready_animation_time_remaining = ANIMATION_SECONDS
	_state.level_ready_roller_offset = 0.0
	_state.level_ready_roller_frame = 0
	_state.level_ready_roller_step_elapsed = 0.0
	_state.level_ready_auto_launch_pending = false


func update(delta: float) -> void:
	if _state == null:
		return
	if _state.level_ready_time_remaining > 0.0:
		_state.level_ready_time_remaining = maxf(0.0, _state.level_ready_time_remaining - delta)
		if _state.level_ready_time_remaining <= 0.0:
			_state.level_ready_auto_launch_pending = true
	if _state.level_ready_animation_time_remaining > 0.0:
		_state.level_ready_roller_step_elapsed += delta
		while _state.level_ready_roller_step_elapsed + ROLLER_STEP_EPSILON >= ROLLER_STEP_SECONDS and _state.level_ready_animation_time_remaining > 0.0:
			_state.level_ready_roller_step_elapsed -= ROLLER_STEP_SECONDS
			if _state.level_ready_roller_step_elapsed < 0.0:
				_state.level_ready_roller_step_elapsed = 0.0
			_state.level_ready_roller_offset = minf(ROLLER_TRAVEL_PIXELS, _state.level_ready_roller_offset + ROLLER_STEP_PIXELS)
			_state.level_ready_roller_frame = (_state.level_ready_roller_frame + 1) % ROLLER_FRAME_COUNT
			_state.level_ready_animation_time_remaining = maxf(0.0, _state.level_ready_animation_time_remaining - ROLLER_STEP_SECONDS)
		if _state.level_ready_roller_offset >= ROLLER_TRAVEL_PIXELS:
			_state.level_ready_animation_time_remaining = 0.0
			_state.level_ready_roller_step_elapsed = 0.0


func clear() -> void:
	if _state == null:
		return
	_state.level_ready_time_remaining = 0.0
	_state.level_ready_animation_time_remaining = 0.0
	_state.level_ready_roller_offset = 0.0
	_state.level_ready_roller_frame = 0
	_state.level_ready_roller_step_elapsed = 0.0
	_state.level_ready_auto_launch_pending = false


func skip_prompt() -> void:
	if _state == null:
		return
	_state.level_ready_animation_time_remaining = 0.0
	_state.level_ready_roller_offset = ROLLER_TRAVEL_PIXELS
	_state.level_ready_roller_step_elapsed = 0.0


func consume_auto_launch_pending() -> bool:
	if _state == null or not bool(_state.level_ready_auto_launch_pending):
		return false
	_state.level_ready_auto_launch_pending = false
	return true


func is_sequence_active() -> bool:
	if _state == null:
		return false
	return _state.level_ready_time_remaining > 0.0


func time_remaining() -> float:
	if _state == null:
		return 0.0
	return _state.level_ready_time_remaining


func is_prompt_visible() -> bool:
	if _state == null:
		return false
	return _state.level_ready_animation_time_remaining > 0.0


func are_gameplay_actors_visible() -> bool:
	return not is_prompt_visible()


func animation_progress() -> float:
	if _state == null:
		return 1.0
	if ROLLER_TRAVEL_PIXELS <= 0.0:
		return 1.0
	return clampf(_state.level_ready_roller_offset / ROLLER_TRAVEL_PIXELS, 0.0, 1.0)


func roller_layout() -> Dictionary:
	if not is_prompt_visible():
		return {"visible": false}

	var roller_position := ROLLER_POSITION + Vector2(_state.level_ready_roller_offset, 0.0)
	return {
		"visible": true,
		"position": roller_position,
		"destination": Rect2(roller_position, ROLLER_SOURCE_SIZE),
		"source": Rect2(Vector2(_state.level_ready_roller_frame * ROLLER_SOURCE_SIZE.x, 0), ROLLER_SOURCE_SIZE),
		"frame": _state.level_ready_roller_frame,
		"progress": animation_progress(),
	}
