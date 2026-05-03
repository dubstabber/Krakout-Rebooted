extends Node2D
class_name KrakoutBeeRenderer

const SOURCE_SIZE := Vector2(48, 40)
const FRAME_COUNT := 6

var session
var bee_texture: Texture2D


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if bee_texture == null:
		bee_texture = _load_asset_texture("Bee")


func set_session(value) -> void:
	session = value
	queue_redraw()


func source_rect_for_bee(frame: int = 0) -> Rect2:
	return Rect2(Vector2(0, posmod(frame, FRAME_COUNT) * SOURCE_SIZE.y), SOURCE_SIZE)


func _draw() -> void:
	if session == null or bee_texture == null or not session.has_method("visible_bees"):
		return

	for bee: Dictionary in session.visible_bees():
		draw_texture_rect_region(
			bee_texture,
			Rect2(bee.get("position", Vector2.ZERO), SOURCE_SIZE),
			source_rect_for_bee(int(bee.get("frame", 0)))
		)


func _load_asset_texture(texture_name: String) -> Texture2D:
	var assets := get_node_or_null("/root/KrakoutAssets")
	if assets == null or not assets.has_method("load_texture"):
		return null

	return assets.call("load_texture", texture_name) as Texture2D
