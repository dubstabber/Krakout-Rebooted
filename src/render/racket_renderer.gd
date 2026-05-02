extends Node2D
class_name KrakoutRacketRenderer

const SOURCE_WIDTH := 16.0
const BODY_PIXEL_STEP := 5.0
const TOP_SOURCE_RECT := Rect2(Vector2(0, 0), Vector2(SOURCE_WIDTH, 11))
const BOTTOM_SOURCE_RECT := Rect2(Vector2(0, 186), Vector2(SOURCE_WIDTH, 12))
const VISUAL_MODE_NORMAL := 0
const VISUAL_MODE_SHOOTING_CONTINUOUS := 1
const VISUAL_MODE_SHOOTING_ONE_SHOT := 2
const NORMAL_INSERT_SOURCE_RECT := Rect2(Vector2(17, 0), Vector2(31, 36))
const SHOOTING_FRAME_SIZE := Vector2(38, 36)
const SHOOTING_SOURCE_X := 17.0
const SHOOTING_CONTINUOUS_SOURCE_Y := 37.0
const SHOOTING_ONE_SHOT_SOURCE_Y := 74.0
const NORMAL_INSERT_DEST_OFFSET_X := 1.0
const SHOOTING_DEST_OFFSET_X := -11.0
const INSERT_DEST_CENTER_OFFSET_Y := -7.0

var session
var racket_texture: Texture2D


static func draw_regions_for_rect(racket_rect: Rect2, segment_count: int, visual_mode: int = VISUAL_MODE_NORMAL, visual_frame: int = 0) -> Array[Dictionary]:
	var body_height := body_height_for_segments(segment_count)
	var top_dest := Rect2(racket_rect.position, TOP_SOURCE_RECT.size)
	var body_dest := Rect2(
		racket_rect.position + Vector2(0, TOP_SOURCE_RECT.size.y),
		Vector2(SOURCE_WIDTH, body_height)
	)
	var bottom_dest := Rect2(
		racket_rect.position + Vector2(0, TOP_SOURCE_RECT.size.y + body_height),
		BOTTOM_SOURCE_RECT.size
	)
	var regions: Array[Dictionary] = []
	regions.append({
		"dest": top_dest,
		"source": TOP_SOURCE_RECT,
	})
	regions.append({
		"dest": body_dest,
		"source": Rect2(Vector2(0, TOP_SOURCE_RECT.size.y), Vector2(SOURCE_WIDTH, body_height)),
	})
	regions.append({
		"dest": bottom_dest,
		"source": BOTTOM_SOURCE_RECT,
	})
	regions.append(overlay_region_for_rect(racket_rect, segment_count, visual_mode, visual_frame))
	return regions


static func body_height_for_segments(segment_count: int) -> float:
	return maxf(0.0, BODY_PIXEL_STEP * float(segment_count))


static func overlay_region_for_rect(racket_rect: Rect2, segment_count: int, visual_mode: int, visual_frame: int = 0) -> Dictionary:
	var body_height := body_height_for_segments(segment_count)
	var source := source_rect_for_visual_mode(visual_mode, visual_frame)
	var offset_x := NORMAL_INSERT_DEST_OFFSET_X
	if visual_mode == VISUAL_MODE_SHOOTING_CONTINUOUS or visual_mode == VISUAL_MODE_SHOOTING_ONE_SHOT:
		offset_x = SHOOTING_DEST_OFFSET_X
	return {
		"dest": Rect2(
			racket_rect.position + Vector2(offset_x, body_height * 0.5 + INSERT_DEST_CENTER_OFFSET_Y),
			source.size
		),
		"source": source,
	}


static func source_rect_for_visual_mode(visual_mode: int, visual_frame: int = 0) -> Rect2:
	if visual_mode == VISUAL_MODE_SHOOTING_CONTINUOUS:
		return _shooting_source_rect(SHOOTING_CONTINUOUS_SOURCE_Y, visual_frame)
	if visual_mode == VISUAL_MODE_SHOOTING_ONE_SHOT:
		return _shooting_source_rect(SHOOTING_ONE_SHOT_SOURCE_Y, visual_frame)
	return NORMAL_INSERT_SOURCE_RECT


static func _shooting_source_rect(source_y: float, visual_frame: int) -> Rect2:
	return Rect2(
		Vector2(SHOOTING_SOURCE_X + float(clampi(visual_frame, 0, 4)) * SHOOTING_FRAME_SIZE.x, source_y),
		SHOOTING_FRAME_SIZE
	)


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

	var visual_mode := VISUAL_MODE_NORMAL
	if session.has_method("current_racket_visual_mode"):
		visual_mode = int(session.call("current_racket_visual_mode"))
	var visual_frame := 0
	if session.has_method("current_racket_visual_frame"):
		visual_frame = int(session.call("current_racket_visual_frame"))

	for region: Dictionary in draw_regions_for_rect(session.racket_rect(), int(session.racket_segment_count), visual_mode, visual_frame):
		draw_texture_rect_region(racket_texture, region["dest"], region["source"])


func _load_asset_texture(texture_name: String) -> Texture2D:
	var assets := get_node_or_null("/root/KrakoutAssets")
	if assets == null or not assets.has_method("load_texture"):
		return null

	return assets.call("load_texture", texture_name) as Texture2D
