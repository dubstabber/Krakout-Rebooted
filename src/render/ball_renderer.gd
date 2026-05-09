extends Node2D
class_name KrakoutBallRenderer

const BALL_FRAME_COUNT := 10
const BALL_TYPE_STANDARD := 0
const BALL_TYPE_FIREBALL := 1
const BALL_TYPE_NON_STRICKED := 2
const FIREBALL_FRAME_COUNT := 6
const FIREBALL_FRAME_SIZE := Vector2(24, 24)
const BALL_TRACK_FRAME_COUNT := 12
const BALL_TRACK_FRAME_SIZE := Vector2(12, 12)
const BALL_TRACK_FIREBALL_SOURCE_X := 0.0
const BALL_TRACK_STANDARD_SOURCE_X := 12.0
const BALL_TRACKS_DRAW_OVER_BALLS := true
const FIREBALL_BALL_MODULATE := Color(1.0, 0.68, 0.24, 1.0)
const FIREBALL_EFFECT_MODULATE := Color.WHITE
const NON_STRICKED_BALL_MODULATE := Color(0.45, 0.85, 1.0, 1.0)
const BALL_SOURCE_ROWS: Array[Dictionary] = [
	{"size": 10.0, "origin": Vector2(1, 1), "pitch": 12.0},
	{"size": 18.0, "origin": Vector2(1, 13), "pitch": 20.0},
	{"size": 26.0, "origin": Vector2(1, 33), "pitch": 28.0},
	{"size": 34.0, "origin": Vector2(1, 61), "pitch": 36.0},
	{"size": 42.0, "origin": Vector2(1, 97), "pitch": 44.0},
]

var session
var ball_texture: Texture2D
var fireball_texture: Texture2D
var tracks_visible := true


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if ball_texture == null:
		ball_texture = _load_asset_texture("Balls")
	if fireball_texture == null:
		fireball_texture = _load_asset_texture("Fb")


func set_session(value) -> void:
	session = value
	queue_redraw()


func set_tracks_visible(is_visible: bool) -> void:
	if tracks_visible == is_visible:
		return
	tracks_visible = is_visible
	queue_redraw()


func are_tracks_visible() -> bool:
	return tracks_visible


func are_balls_visible_for_session() -> bool:
	if session == null:
		return false
	if session.has_method("are_balls_visible"):
		return bool(session.call("are_balls_visible"))
	if session.has_method("is_level_ready_prompt_visible"):
		return not bool(session.call("is_level_ready_prompt_visible"))
	return true


func _draw() -> void:
	if session == null or not are_balls_visible_for_session():
		return

	_draw_ball_sprites()
	if tracks_visible:
		_draw_ball_tracks()


func _draw_ball_sprites() -> void:
	if ball_texture == null:
		return
	for ball: Dictionary in session.visible_balls():
		var ball_size := float(ball.get("size", 18.0))
		var type_id := int(ball.get("type_id", BALL_TYPE_STANDARD))
		var frame := _frame_for_ball(ball)
		var ball_rect: Rect2 = session.ball_rect(ball)
		var visual_rect := visual_rect_for_ball_type(type_id, ball_rect)
		draw_texture_rect_region(
			ball_texture,
			visual_rect,
			source_rect_for_size(source_size_for_ball_type(type_id, ball_size), frame),
			modulate_for_ball_type(type_id)
		)
		if type_id == BALL_TYPE_FIREBALL and fireball_texture != null:
			draw_texture_rect_region(
				fireball_texture,
				visual_rect,
				fireball_source_rect(frame),
				FIREBALL_EFFECT_MODULATE
			)


func _draw_ball_tracks() -> void:
	if fireball_texture == null or not session.has_method("visible_ball_tracks"):
		return

	for track: Dictionary in session.call("visible_ball_tracks"):
		var position: Vector2 = track.get("position", Vector2.ZERO)
		draw_texture_rect_region(
			fireball_texture,
			Rect2(position, BALL_TRACK_FRAME_SIZE),
			ball_track_source_rect(
				int(track.get("type_id", BALL_TYPE_STANDARD)),
				int(track.get("frame", 0))
			),
			FIREBALL_EFFECT_MODULATE
		)


func source_rect_for_size(ball_size: float, frame: int = 0) -> Rect2:
	var source_row := _source_row_for_size(ball_size)
	var source_size := float(source_row["size"])
	var source_origin: Vector2 = source_row["origin"]
	var source_pitch := float(source_row["pitch"])
	var clamped_frame := posmod(frame, BALL_FRAME_COUNT)
	return Rect2(
		Vector2(source_origin.x + source_pitch * clamped_frame, source_origin.y),
		Vector2(source_size, source_size)
	)


static func fireball_source_rect(frame: int = 0) -> Rect2:
	return Rect2(
		Vector2(0, float(posmod(frame, FIREBALL_FRAME_COUNT)) * FIREBALL_FRAME_SIZE.y),
		FIREBALL_FRAME_SIZE
	)


static func ball_track_source_rect(type_id: int, frame: int = 0) -> Rect2:
	var source_x := BALL_TRACK_FIREBALL_SOURCE_X if type_id == BALL_TYPE_FIREBALL else BALL_TRACK_STANDARD_SOURCE_X
	return Rect2(
		Vector2(source_x, float(posmod(frame, BALL_TRACK_FRAME_COUNT)) * BALL_TRACK_FRAME_SIZE.y),
		BALL_TRACK_FRAME_SIZE
	)


static func modulate_for_ball_type(type_id: int) -> Color:
	if type_id == BALL_TYPE_FIREBALL:
		return FIREBALL_BALL_MODULATE
	if type_id == BALL_TYPE_NON_STRICKED:
		return NON_STRICKED_BALL_MODULATE
	return Color.WHITE


static func source_size_for_ball_type(type_id: int, ball_size: float) -> float:
	if type_id == BALL_TYPE_FIREBALL:
		return maxf(ball_size, FIREBALL_FRAME_SIZE.x)
	return ball_size


static func visual_rect_for_ball_type(type_id: int, ball_rect: Rect2) -> Rect2:
	if type_id != BALL_TYPE_FIREBALL:
		return ball_rect

	var visual_size := Vector2(
		maxf(ball_rect.size.x, FIREBALL_FRAME_SIZE.x),
		maxf(ball_rect.size.y, FIREBALL_FRAME_SIZE.y)
	)
	return Rect2(ball_rect.get_center() - visual_size * 0.5, visual_size)


func _source_row_for_size(ball_size: float) -> Dictionary:
	var best_row: Dictionary = BALL_SOURCE_ROWS[0]
	var best_distance := absf(ball_size - float(best_row["size"]))
	for row: Dictionary in BALL_SOURCE_ROWS:
		var distance := absf(ball_size - float(row["size"]))
		if distance < best_distance:
			best_row = row
			best_distance = distance
	return best_row


func _frame_for_ball(ball: Dictionary) -> int:
	return int(ball.get("frame", 0)) % BALL_FRAME_COUNT


func _load_asset_texture(texture_name: String) -> Texture2D:
	var assets := get_node_or_null("/root/KrakoutAssets")
	if assets == null or not assets.has_method("load_texture"):
		return null

	return assets.call("load_texture", texture_name) as Texture2D
