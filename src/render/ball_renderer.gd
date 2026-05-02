extends Node2D
class_name KrakoutBallRenderer

const BALL_FRAME_COUNT := 10
const BALL_SOURCE_ROWS: Array[Dictionary] = [
	{"size": 10.0, "origin": Vector2(1, 1), "pitch": 12.0},
	{"size": 18.0, "origin": Vector2(1, 13), "pitch": 20.0},
	{"size": 26.0, "origin": Vector2(1, 33), "pitch": 28.0},
	{"size": 34.0, "origin": Vector2(1, 61), "pitch": 36.0},
	{"size": 42.0, "origin": Vector2(1, 97), "pitch": 44.0},
]

var session
var ball_texture: Texture2D
var tracks_visible := true


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if ball_texture == null:
		ball_texture = _load_asset_texture("Balls")


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


func _draw() -> void:
	if session == null or ball_texture == null:
		return

	for ball: Dictionary in session.visible_balls():
		var ball_size := float(ball.get("size", 18.0))
		draw_texture_rect_region(
			ball_texture,
			session.ball_rect(ball),
			source_rect_for_size(ball_size, _frame_for_ball(ball))
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
	var position: Vector2 = ball.get("position", Vector2.ZERO)
	return int(absf(position.x + position.y) / 8.0) % BALL_FRAME_COUNT


func _load_asset_texture(texture_name: String) -> Texture2D:
	var assets := get_node_or_null("/root/KrakoutAssets")
	if assets == null or not assets.has_method("load_texture"):
		return null

	return assets.call("load_texture", texture_name) as Texture2D
