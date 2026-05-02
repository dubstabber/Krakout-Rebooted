extends Node2D
class_name KrakoutMonsterRenderer

const SOURCE_SIZE := Vector2(32, 32)

var session
var monster_texture: Texture2D


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if monster_texture == null:
		monster_texture = _load_asset_texture("Monsters")


func set_session(value) -> void:
	session = value
	queue_redraw()


func source_rect_for_monster(type_id: int, frame: int = 0) -> Rect2:
	return Rect2(Vector2(maxi(0, type_id) * SOURCE_SIZE.x, maxi(0, frame) * SOURCE_SIZE.y), SOURCE_SIZE)


func _draw() -> void:
	if session == null or monster_texture == null or not session.has_method("visible_monsters"):
		return

	for monster: Dictionary in session.visible_monsters():
		draw_texture_rect_region(
			monster_texture,
			Rect2(monster.get("position", Vector2.ZERO), SOURCE_SIZE),
			source_rect_for_monster(int(monster.get("type_id", 0)), int(monster.get("frame", 0)))
		)


func _load_asset_texture(texture_name: String) -> Texture2D:
	var assets := get_node_or_null("/root/KrakoutAssets")
	if assets == null or not assets.has_method("load_texture"):
		return null

	return assets.call("load_texture", texture_name) as Texture2D
