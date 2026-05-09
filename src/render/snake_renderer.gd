extends Node2D
class_name KrakoutSnakeRenderer

const CELL_SIZE := Vector2(10, 10)
const KIND_COUNT := 20
const KIND_ROW_COUNT := 4

var session
var snake_texture: Texture2D


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if snake_texture == null:
		snake_texture = _load_asset_texture("Snake")


func set_session(value) -> void:
	session = value
	queue_redraw()


static func normalized_kind(kind: int) -> int:
	return clampi(kind, 0, KIND_COUNT - 1)


static func source_rect_for_kind(kind: int) -> Rect2:
	var safe_kind := normalized_kind(kind)
	return Rect2(Vector2(int(safe_kind / KIND_ROW_COUNT) * CELL_SIZE.x, (safe_kind % KIND_ROW_COUNT) * CELL_SIZE.y), CELL_SIZE)


func _draw() -> void:
	if session == null or snake_texture == null or not session.has_method("visible_snake_segments"):
		return

	for segment: Dictionary in session.visible_snake_segments():
		draw_texture_rect_region(
			snake_texture,
			Rect2(segment.get("position", Vector2.ZERO), CELL_SIZE),
			source_rect_for_kind(int(segment.get("kind", 0)))
		)


func _load_asset_texture(texture_name: String) -> Texture2D:
	var assets := get_node_or_null("/root/KrakoutAssets")
	if assets == null or not assets.has_method("load_texture"):
		return null

	return assets.call("load_texture", texture_name) as Texture2D
