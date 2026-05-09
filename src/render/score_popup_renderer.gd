extends Node2D
class_name KrakoutScorePopupRenderer

const DIGIT_SIZE := Vector2(8, 12)
const DIGIT_COUNT := 10
const FRAME_COUNT := 15

var session
var digits_texture: Texture2D


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if digits_texture == null:
		digits_texture = _load_asset_texture("DigitsSmall")


func set_session(value) -> void:
	session = value
	queue_redraw()


static func digit_source_rect(digit: int, frame: int = 0) -> Rect2:
	return Rect2(
		Vector2(
			clampi(digit, 0, DIGIT_COUNT - 1) * DIGIT_SIZE.x,
			clampi(frame, 0, FRAME_COUNT - 1) * DIGIT_SIZE.y
		),
		DIGIT_SIZE
	)


static func digit_target_rect(position: Vector2, digit_index: int) -> Rect2:
	return Rect2(position + Vector2(maxi(0, digit_index) * DIGIT_SIZE.x, 0), DIGIT_SIZE)


func popup_digit_rects(popup: Dictionary) -> Array[Dictionary]:
	var value_text := str(maxi(0, int(popup.get("value", 0))))
	var frame := int(popup.get("frame", 0))
	var position: Vector2 = popup.get("position", Vector2.ZERO)
	var rects: Array[Dictionary] = []
	for index in range(value_text.length()):
		var digit := int(value_text.substr(index, 1))
		rects.append({
			"source": digit_source_rect(digit, frame),
			"destination": digit_target_rect(position, index),
		})
	return rects


func _draw() -> void:
	if session == null or digits_texture == null or not session.has_method("visible_score_popups"):
		return

	for popup: Dictionary in session.visible_score_popups():
		for rects: Dictionary in popup_digit_rects(popup):
			draw_texture_rect_region(digits_texture, rects["destination"], rects["source"])


func _load_asset_texture(texture_name: String) -> Texture2D:
	var assets := get_node_or_null("/root/KrakoutAssets")
	if assets == null or not assets.has_method("load_texture"):
		return null

	return assets.call("load_texture", texture_name) as Texture2D
