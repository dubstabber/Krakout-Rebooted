extends Node2D
class_name KrakoutImpactEffectRenderer

const CELL_SIZE := Vector2(32, 32)
const NARROW_CELL_SIZE := Vector2(20, 32)
const NARROW_EFFECT_MIN_KIND := 3
const NARROW_EFFECT_MAX_KIND := 5

var session
var effect_texture: Texture2D


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if effect_texture == null:
		effect_texture = _load_asset_texture("Exploision")


func set_session(value) -> void:
	session = value
	queue_redraw()


func source_rect_for_effect(kind: int, frame: int = 0) -> Rect2:
	return Rect2(
		Vector2(maxi(0, kind) * CELL_SIZE.x, maxi(0, frame) * CELL_SIZE.y),
		size_for_effect(kind)
	)


func target_rect_for_effect(position: Vector2, kind: int) -> Rect2:
	return Rect2(position, size_for_effect(kind))


static func size_for_effect(kind: int) -> Vector2:
	if kind >= NARROW_EFFECT_MIN_KIND and kind <= NARROW_EFFECT_MAX_KIND:
		return NARROW_CELL_SIZE
	return CELL_SIZE


func _draw() -> void:
	if session == null or effect_texture == null or not session.has_method("visible_impact_effects"):
		return

	for effect: Dictionary in session.visible_impact_effects():
		var kind := int(effect.get("kind", 0))
		draw_texture_rect_region(
			effect_texture,
			target_rect_for_effect(effect.get("position", Vector2.ZERO), kind),
			source_rect_for_effect(kind, int(effect.get("frame", 0)))
		)


func _load_asset_texture(texture_name: String) -> Texture2D:
	var assets := get_node_or_null("/root/KrakoutAssets")
	if assets == null or not assets.has_method("load_texture"):
		return null

	return assets.call("load_texture", texture_name) as Texture2D
