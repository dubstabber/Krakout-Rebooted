extends RefCounted
class_name KrakoutRacketSystem

const GameplayStateScript := preload("res://src/gameplay/krakout_gameplay_state.gd")
const RacketRulesScript := preload("res://src/gameplay/rules/krakout_racket_rules.gd")

var y := RacketRulesScript.RACKET_READY_DEFAULT_Y
var segment_count := RacketRulesScript.RACKET_DEFAULT_SEGMENTS
var visual_mode := RacketRulesScript.RACKET_VISUAL_MODE_NORMAL
var visual_frame := 0
var visual_target_mode := RacketRulesScript.RACKET_VISUAL_MODE_NORMAL
var double_paddle_active := false
var double_paddle_x := RacketRulesScript.RACKET_X + RacketRulesScript.DOUBLE_PADDLE_OFFSET_X
var magnet_paddle_active := false
var drunk_time_remaining := 0.0
var last_input_y := RacketRulesScript.RACKET_READY_CENTER_Y
var last_input_x := RacketRulesScript.RACKET_X
var has_last_input := false
var has_last_x_input := false
var _visual_elapsed := 0.0
var _hit_recoil_offset_x := 0.0
var _hit_recoil_elapsed := 0.0


func _init(initial_state = null) -> void:
	if initial_state is GameplayStateScript:
		sync_from_state(initial_state)


func sync_from_state(state) -> void:
	if state == null:
		return
	y = float(state.racket_y)
	segment_count = int(state.racket_segment_count)
	visual_mode = int(state.racket_visual_mode)
	visual_frame = int(state.racket_visual_frame)
	visual_target_mode = int(state.racket_visual_target_mode)
	double_paddle_active = bool(state.double_paddle_active)
	double_paddle_x = float(state.double_paddle_x)
	magnet_paddle_active = bool(state.magnet_paddle_active)
	drunk_time_remaining = float(state.drunk_paddle_time_remaining)
	last_input_y = float(state.last_racket_input_y)
	last_input_x = float(state.last_racket_input_x)
	has_last_input = bool(state.has_last_racket_input)
	has_last_x_input = bool(state.has_last_racket_x_input)
	_visual_elapsed = float(state.racket_visual_elapsed)
	_hit_recoil_offset_x = float(state.racket_hit_recoil_offset_x)
	_hit_recoil_elapsed = float(state.racket_hit_recoil_elapsed)


func sync_to_state(state) -> void:
	if state == null:
		return
	state.racket_y = y
	state.racket_segment_count = segment_count
	state.racket_visual_mode = visual_mode
	state.racket_visual_frame = visual_frame
	state.racket_visual_target_mode = visual_target_mode
	state.double_paddle_active = double_paddle_active
	state.double_paddle_x = double_paddle_x
	state.magnet_paddle_active = magnet_paddle_active
	state.drunk_paddle_time_remaining = drunk_time_remaining
	state.last_racket_input_y = last_input_y
	state.last_racket_input_x = last_input_x
	state.has_last_racket_input = has_last_input
	state.has_last_racket_x_input = has_last_x_input
	state.racket_visual_elapsed = _visual_elapsed
	state.racket_hit_recoil_offset_x = _hit_recoil_offset_x
	state.racket_hit_recoil_elapsed = _hit_recoil_elapsed


func sync_from_facade(session) -> void:
	if session == null:
		return
	if session is GameplayStateScript:
		sync_from_state(session)
		return
	var state = session.get("gameplay_state")
	if state is GameplayStateScript:
		sync_from_state(state)
		return
	y = float(session.racket_y)
	segment_count = int(session.racket_segment_count)
	visual_mode = int(session.racket_visual_mode)
	visual_frame = int(session.racket_visual_frame)
	visual_target_mode = int(session._racket_visual_target_mode)
	double_paddle_active = bool(session._double_paddle_active)
	double_paddle_x = float(session._double_paddle_x)
	magnet_paddle_active = bool(session._magnet_paddle_active)
	drunk_time_remaining = float(session._drunk_paddle_time_remaining)
	last_input_y = float(session._last_racket_input_y)
	last_input_x = float(session._last_racket_input_x)
	has_last_input = bool(session._has_last_racket_input)
	has_last_x_input = bool(session._has_last_racket_x_input)
	_visual_elapsed = float(session._racket_visual_elapsed)
	_hit_recoil_offset_x = float(session._racket_hit_recoil_offset_x)
	_hit_recoil_elapsed = float(session._racket_hit_recoil_elapsed)


func sync_to_facade(session) -> void:
	if session == null:
		return
	if session is GameplayStateScript:
		sync_to_state(session)
		return
	var state = session.get("gameplay_state")
	if state is GameplayStateScript:
		sync_to_state(state)
		return
	session.racket_y = y
	session.racket_segment_count = segment_count
	session.racket_visual_mode = visual_mode
	session.racket_visual_frame = visual_frame
	session._racket_visual_target_mode = visual_target_mode
	session._double_paddle_active = double_paddle_active
	session._double_paddle_x = double_paddle_x
	session._magnet_paddle_active = magnet_paddle_active
	session._drunk_paddle_time_remaining = drunk_time_remaining
	session._last_racket_input_y = last_input_y
	session._last_racket_input_x = last_input_x
	session._has_last_racket_input = has_last_input
	session._has_last_racket_x_input = has_last_x_input
	session._racket_visual_elapsed = _visual_elapsed
	session._racket_hit_recoil_offset_x = _hit_recoil_offset_x
	session._racket_hit_recoil_elapsed = _hit_recoil_elapsed


func current_height() -> float:
	return RacketRulesScript.height_for_segments(segment_count)


func current_x() -> float:
	return RacketRulesScript.RACKET_X + _hit_recoil_offset_x


func primary_rect() -> Rect2:
	return Rect2(
		Vector2(current_x(), y),
		Vector2(RacketRulesScript.RACKET_WIDTH, current_height())
	)


func rects() -> Array[Rect2]:
	var results: Array[Rect2] = [primary_rect()]
	if double_paddle_active:
		results.append(Rect2(
			Vector2(double_paddle_x, y),
			Vector2(RacketRulesScript.RACKET_WIDTH, current_height())
		))
	return results


func reset_to_ready_center() -> void:
	clear_hit_recoil()
	y = RacketRulesScript.ready_top_y(segment_count)


func remember_input(mouse_y: float, mouse_x = null) -> void:
	last_input_y = mouse_y
	has_last_input = true
	if mouse_x != null:
		last_input_x = float(mouse_x)
		has_last_x_input = true


func mouse_delta_x(mouse_x) -> float:
	if mouse_x == null:
		return 0.0
	var next_mouse_x := float(mouse_x)
	if not has_last_x_input:
		return 0.0
	return next_mouse_x - last_input_x


func update_double_paddle_x(mouse_delta_x_value: float) -> void:
	if not double_paddle_active or is_zero_approx(mouse_delta_x_value):
		return
	double_paddle_x = clampf(
		double_paddle_x + mouse_delta_x_value * RacketRulesScript.DOUBLE_PADDLE_MOUSE_X_MULTIPLIER,
		RacketRulesScript.DOUBLE_PADDLE_MIN_X,
		RacketRulesScript.RACKET_X + RacketRulesScript.DOUBLE_PADDLE_OFFSET_X
	)


func adjust_segments(delta_segments: int) -> void:
	if delta_segments < 0:
		if segment_count > RacketRulesScript.RACKET_SHRINK_LIMIT_SEGMENTS:
			segment_count += delta_segments
	elif delta_segments > 0:
		if segment_count < RacketRulesScript.RACKET_EXPAND_LIMIT_SEGMENTS:
			segment_count += delta_segments
	y = RacketRulesScript.clamped_top_y(y, segment_count)


func set_visual_target(next_visual_mode: int) -> void:
	visual_target_mode = next_visual_mode
	if next_visual_mode != RacketRulesScript.RACKET_VISUAL_MODE_NORMAL:
		visual_mode = next_visual_mode
	elif visual_frame <= 0:
		visual_mode = RacketRulesScript.RACKET_VISUAL_MODE_NORMAL


func update_visual(delta: float) -> void:
	_visual_elapsed += delta
	while _visual_elapsed >= RacketRulesScript.RACKET_VISUAL_FRAME_SECONDS:
		_visual_elapsed -= RacketRulesScript.RACKET_VISUAL_FRAME_SECONDS
		if visual_target_mode == RacketRulesScript.RACKET_VISUAL_MODE_NORMAL:
			if visual_frame > 0:
				visual_frame -= 1
			if visual_frame <= 0:
				visual_frame = 0
				visual_mode = RacketRulesScript.RACKET_VISUAL_MODE_NORMAL
		elif visual_target_mode == RacketRulesScript.RACKET_VISUAL_MODE_MAGNET:
			visual_mode = RacketRulesScript.RACKET_VISUAL_MODE_MAGNET
			visual_frame = (visual_frame + 1) % RacketRulesScript.RACKET_MAGNET_VISUAL_FRAME_COUNT
		else:
			visual_mode = visual_target_mode
			if visual_frame < RacketRulesScript.RACKET_VISUAL_MAX_FRAME:
				visual_frame += 1


func start_hit_recoil() -> void:
	_hit_recoil_offset_x = RacketRulesScript.RACKET_HIT_RECOIL_PIXELS
	_hit_recoil_elapsed = 0.0


func clear_hit_recoil() -> void:
	_hit_recoil_offset_x = 0.0
	_hit_recoil_elapsed = 0.0


func update_hit_recoil(delta: float) -> void:
	if _hit_recoil_offset_x <= 0.0:
		clear_hit_recoil()
		return

	_hit_recoil_elapsed += delta
	while _hit_recoil_elapsed > RacketRulesScript.RACKET_HIT_RECOIL_STEP_SECONDS and _hit_recoil_offset_x > 0.0:
		_hit_recoil_elapsed -= RacketRulesScript.RACKET_HIT_RECOIL_STEP_SECONDS
		_hit_recoil_offset_x = maxf(0.0, _hit_recoil_offset_x - RacketRulesScript.RACKET_HIT_RECOIL_STEP_PIXELS)
	if _hit_recoil_offset_x <= 0.0:
		clear_hit_recoil()


func clear_paddle_mode_state() -> void:
	double_paddle_active = false
	double_paddle_x = RacketRulesScript.RACKET_X + RacketRulesScript.DOUBLE_PADDLE_OFFSET_X
	magnet_paddle_active = false
	visual_mode = RacketRulesScript.RACKET_VISUAL_MODE_NORMAL
	visual_frame = 0
	visual_target_mode = RacketRulesScript.RACKET_VISUAL_MODE_NORMAL
	_visual_elapsed = 0.0
