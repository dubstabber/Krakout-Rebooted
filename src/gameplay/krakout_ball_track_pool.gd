extends RefCounted
class_name KrakoutBallTrackPool

const GameplayStateScript := preload("res://src/gameplay/krakout_gameplay_state.gd")

const BALL_TRACK_SLOT_COUNT := 50
const BALL_TRACK_FRAME_COUNT := 12
const BALL_TRACK_SPAWN_SECONDS := 0.03
const BALL_TRACK_FRAME_SECONDS := 0.03
const BALL_TYPE_STANDARD := 0
const BALL_TYPE_NON_STRICKED := 2

var tracks: Array
var spawn_elapsed: Array
var rng
var enabled := true


func _init(shared_tracks, shared_spawn_elapsed = null, rng_source = null) -> void:
	if shared_tracks is GameplayStateScript:
		var state = shared_tracks
		tracks = state.ball_tracks
		spawn_elapsed = state.ball_track_spawn_elapsed
		rng = state.ball_track_rng
		enabled = state.ball_tracks_enabled
	else:
		tracks = shared_tracks
		spawn_elapsed = shared_spawn_elapsed
		rng = rng_source


func set_enabled(is_enabled: bool) -> void:
	enabled = is_enabled
	if not enabled:
		clear()


func is_enabled() -> bool:
	return enabled


func update(delta: float, balls: Array, fallback_ball_size: float) -> void:
	if not enabled:
		return

	ensure_slots(balls.size())
	for index in range(balls.size()):
		_ensure_min_slots(index + 1)
		var ball: Dictionary = balls[index]
		if not bool(ball.get("active", false)):
			clear_slots(index)
			continue

		advance_slots(index, delta)
		if _ball_type(ball) == BALL_TYPE_NON_STRICKED:
			clear_slots(index)
			continue

		spawn_elapsed[index] = float(spawn_elapsed[index]) + delta
		while float(spawn_elapsed[index]) > BALL_TRACK_SPAWN_SECONDS:
			spawn_elapsed[index] = float(spawn_elapsed[index]) - BALL_TRACK_SPAWN_SECONDS
			spawn_track(index, ball, fallback_ball_size)


func visible_tracks() -> Array[Dictionary]:
	var visible: Array[Dictionary] = []
	if not enabled:
		return visible

	for slots in tracks:
		for track: Dictionary in slots:
			if bool(track.get("active", false)):
				visible.append(track.duplicate())
	return visible


func ensure_slots(ball_count: int) -> void:
	while tracks.size() > ball_count:
		tracks.pop_back()
	while spawn_elapsed.size() > ball_count:
		spawn_elapsed.pop_back()
	_ensure_min_slots(ball_count)


func _ensure_min_slots(ball_count: int) -> void:
	while tracks.size() < ball_count:
		tracks.append(new_track_slots())
	while spawn_elapsed.size() < ball_count:
		spawn_elapsed.append(0.0)


func new_track_slots() -> Array[Dictionary]:
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


func clear() -> void:
	tracks.clear()
	spawn_elapsed.clear()


func clear_slots(ball_index: int) -> void:
	if ball_index < 0 or ball_index >= tracks.size():
		return
	for track_index in range(tracks[ball_index].size()):
		var track: Dictionary = tracks[ball_index][track_index]
		track["active"] = false
		track["frame_elapsed"] = 0.0
		tracks[ball_index][track_index] = track
	if ball_index < spawn_elapsed.size():
		spawn_elapsed[ball_index] = 0.0


func advance_slots(ball_index: int, delta: float) -> void:
	if ball_index < 0 or ball_index >= tracks.size():
		return
	for track_index in range(tracks[ball_index].size()):
		var track: Dictionary = tracks[ball_index][track_index]
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
		tracks[ball_index][track_index] = track


func spawn_track(ball_index: int, ball: Dictionary, fallback_ball_size: float) -> bool:
	if ball_index < 0:
		return false
	_ensure_min_slots(ball_index + 1)
	if ball_index >= tracks.size():
		return false

	for track_index in range(tracks[ball_index].size()):
		var track: Dictionary = tracks[ball_index][track_index]
		if bool(track.get("active", false)):
			continue

		track["active"] = true
		track["position"] = track_position(ball, fallback_ball_size)
		track["frame"] = 0
		track["frame_elapsed"] = 0.0
		track["type_id"] = _ball_type(ball)
		tracks[ball_index][track_index] = track
		return true
	return false


func track_position(ball: Dictionary, fallback_ball_size: float) -> Vector2:
	var position: Vector2 = ball.get("position", Vector2.ZERO)
	var ball_pixel_size: int = max(1, int(float(ball.get("size", fallback_ball_size))))
	var half_size: int = max(1, int(float(ball_pixel_size) / 2.0))
	var random_span: int = max(1, 2 * half_size - 8)
	var center_x: int = int(position.x) + half_size
	var center_y: int = int(position.y) + half_size
	var track_x: int = center_x - _next_mod(random_span) + half_size - 10
	var track_y: int = center_y - _next_mod(random_span) + half_size - 10
	return Vector2(float(track_x), float(track_y))


func _ball_type(ball: Dictionary) -> int:
	return int(ball.get("type_id", BALL_TYPE_STANDARD))


func _next_mod(modulus: int) -> int:
	if rng != null and rng.has_method("next_mod"):
		return int(rng.call("next_mod", modulus))
	return 0
