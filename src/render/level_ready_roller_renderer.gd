extends Node2D
class_name KrakoutLevelReadyRollerRenderer

var session
var roller_texture: Texture2D


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if roller_texture == null:
		roller_texture = _load_asset_texture("Roller")


func set_session(value) -> void:
	session = value
	queue_redraw()


func _draw() -> void:
	if session == null or roller_texture == null or not session.has_method("level_ready_roller_layout"):
		return

	var layout: Dictionary = session.call("level_ready_roller_layout")
	if not bool(layout.get("visible", false)):
		return

	var destination: Rect2 = layout["destination"]
	var source: Rect2 = layout["source"]
	draw_texture_rect_region(
		roller_texture,
		destination,
		source
	)


func _load_asset_texture(texture_name: String) -> Texture2D:
	var assets := get_node_or_null("/root/KrakoutAssets")
	if assets == null or not assets.has_method("load_texture"):
		return null

	return assets.call("load_texture", texture_name) as Texture2D
