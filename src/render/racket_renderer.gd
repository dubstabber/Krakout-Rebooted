extends Node2D
class_name KrakoutRacketRenderer

const SOURCE_RECT := Rect2(Vector2(0, 0), Vector2(16, 198))

var session
var racket_texture: Texture2D


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if racket_texture == null:
		racket_texture = _load_asset_texture("Racket")


func set_session(value) -> void:
	session = value
	queue_redraw()


func _draw() -> void:
	if session == null or racket_texture == null:
		return

	draw_texture_rect_region(
		racket_texture,
		session.racket_rect(),
		SOURCE_RECT
	)


func _load_asset_texture(texture_name: String) -> Texture2D:
	var assets := get_node_or_null("/root/KrakoutAssets")
	if assets == null or not assets.has_method("load_texture"):
		return null

	return assets.call("load_texture", texture_name) as Texture2D
