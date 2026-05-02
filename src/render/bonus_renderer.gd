extends Node2D
class_name KrakoutBonusRenderer

const FALLING_SOURCE_SIZE := Vector2(32, 32)
const STACK_SOURCE_SIZE := Vector2(32, 32)
const STACK_TARGET_SIZE := Vector2(32, 32)
const STACK_ORIGIN := Vector2(571, 411)
const STACK_STEP_X := 34.0
const POINTER_SOURCE_SIZE := Vector2(32, 20)
const POINTER_POSITION := Vector2(571, 389)

var session
var falling_bonus_texture: Texture2D
var stacked_bonus_texture: Texture2D
var pointer_texture: Texture2D


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if falling_bonus_texture == null:
		falling_bonus_texture = _load_asset_texture("Bonuses_a")
	if stacked_bonus_texture == null:
		stacked_bonus_texture = _load_asset_texture("Bonuses_aa")
	if pointer_texture == null:
		pointer_texture = _load_asset_texture("PointToBonusInStack")


func set_session(value) -> void:
	session = value
	queue_redraw()


func _draw() -> void:
	if session == null:
		return

	_draw_falling_bonuses()
	_draw_bonus_stack()


func _draw_falling_bonuses() -> void:
	if falling_bonus_texture == null or not session.has_method("visible_falling_bonuses"):
		return

	for bonus: Dictionary in session.visible_falling_bonuses():
		var frame := int(bonus.get("frame", 0))
		var type_id := int(bonus.get("type_id", 0))
		draw_texture_rect_region(
			falling_bonus_texture,
			Rect2(bonus.get("position", Vector2.ZERO), FALLING_SOURCE_SIZE),
			Rect2(Vector2(type_id * FALLING_SOURCE_SIZE.x, frame * FALLING_SOURCE_SIZE.y), FALLING_SOURCE_SIZE)
		)


func _draw_bonus_stack() -> void:
	if stacked_bonus_texture == null or not session.has_method("bonus_stack_entries"):
		return

	var entries: Array = session.bonus_stack_entries()
	if entries.is_empty():
		return

	if pointer_texture != null:
		var pointer_frame := int(session.get("bonus_pointer_frame"))
		draw_texture_rect_region(
			pointer_texture,
			Rect2(POINTER_POSITION, POINTER_SOURCE_SIZE),
			Rect2(Vector2(0, pointer_frame * POINTER_SOURCE_SIZE.y), POINTER_SOURCE_SIZE)
		)

	for index in range(entries.size()):
		var entry: Dictionary = entries[index]
		var type_id := int(entry.get("type_id", 0))
		var frame := int(entry.get("frame", 0))
		draw_texture_rect_region(
			stacked_bonus_texture,
			Rect2(STACK_ORIGIN - Vector2(index * STACK_STEP_X, 0), STACK_TARGET_SIZE),
			Rect2(Vector2(type_id * STACK_SOURCE_SIZE.x, frame * STACK_SOURCE_SIZE.y), STACK_SOURCE_SIZE)
		)


func _load_asset_texture(texture_name: String) -> Texture2D:
	var assets := get_node_or_null("/root/KrakoutAssets")
	if assets == null or not assets.has_method("load_texture"):
		return null

	return assets.call("load_texture", texture_name) as Texture2D
