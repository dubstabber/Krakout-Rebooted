extends Node2D
class_name KrakoutBallRenderer

const SOURCE_RECT := Rect2(Vector2(0, 0), Vector2(16, 16))

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
		draw_texture_rect_region(
			ball_texture,
			session.ball_rect(ball),
			SOURCE_RECT
		)


func _load_asset_texture(texture_name: String) -> Texture2D:
	var assets := get_node_or_null("/root/KrakoutAssets")
	if assets == null or not assets.has_method("load_texture"):
		return null

	return assets.call("load_texture", texture_name) as Texture2D
