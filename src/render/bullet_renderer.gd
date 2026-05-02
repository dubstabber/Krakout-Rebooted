extends Node2D
class_name KrakoutBulletRenderer

const HEAD_SOURCE_SIZE := Vector2(35, 15)
const TRAIL_SOURCE_SIZE := Vector2(20, 15)
const TRAIL_TARGET_OFFSET := Vector2(30, 0)
const CONTINUOUS_HEAD_SOURCE_Y := 0.0
const STRONG_HEAD_SOURCE_Y := 15.0
const TRAIL_SOURCE_Y := 30.0
const HEAD_FRAME_COUNT := 5
const TRAIL_FRAME_COUNT := 10
const CONTINUOUS_PROJECTILE_TYPE := 1

var session
var bullet_texture: Texture2D


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if bullet_texture == null:
		bullet_texture = _load_asset_texture("Bullets")


func set_session(value) -> void:
	session = value
	queue_redraw()


func _draw() -> void:
	if session == null or bullet_texture == null or not session.has_method("visible_projectiles"):
		return

	for projectile: Dictionary in session.visible_projectiles():
		_draw_projectile(projectile)


func _draw_projectile(projectile: Dictionary) -> void:
	var position: Vector2 = projectile.get("position", Vector2.ZERO)
	var projectile_type := int(projectile.get("type", 0))
	var head_source_y := CONTINUOUS_HEAD_SOURCE_Y if projectile_type == CONTINUOUS_PROJECTILE_TYPE else STRONG_HEAD_SOURCE_Y
	var head_frame := int(projectile.get("head_frame", 0)) % HEAD_FRAME_COUNT
	var trail_frame := int(projectile.get("trail_frame", 0)) % TRAIL_FRAME_COUNT

	draw_texture_rect_region(
		bullet_texture,
		Rect2(position, HEAD_SOURCE_SIZE),
		Rect2(Vector2(head_frame * HEAD_SOURCE_SIZE.x, head_source_y), HEAD_SOURCE_SIZE)
	)
	draw_texture_rect_region(
		bullet_texture,
		Rect2(position + TRAIL_TARGET_OFFSET, TRAIL_SOURCE_SIZE),
		Rect2(Vector2(trail_frame * TRAIL_SOURCE_SIZE.x, TRAIL_SOURCE_Y), TRAIL_SOURCE_SIZE)
	)


func _load_asset_texture(texture_name: String) -> Texture2D:
	var assets := get_node_or_null("/root/KrakoutAssets")
	if assets == null or not assets.has_method("load_texture"):
		return null

	return assets.call("load_texture", texture_name) as Texture2D
