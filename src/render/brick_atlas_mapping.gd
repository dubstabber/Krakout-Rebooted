extends Resource
class_name BrickAtlasMapping

const FIRST_TILE_ID := 1
const FIRST_SKIPPED_TILE_ID := 162
const ANIMATED_RANGE_A := Vector2i(28, 38)
const ANIMATED_RANGE_B := Vector2i(127, 135)
const ANIMATED_RANGE_C := Vector2i(159, 161)

@export var frame_size := Vector2i(20, 30)
@export var max_animation_frame := 3


func is_empty_tile(tile_id: int) -> bool:
	return tile_id == 0 or tile_id >= FIRST_SKIPPED_TILE_ID


func is_animated_tile(tile_id: int) -> bool:
	return _is_in_range(tile_id, ANIMATED_RANGE_A) \
		or tile_id == 42 \
		or tile_id == 43 \
		or tile_id == 44 \
		or tile_id == 68 \
		or tile_id == 69 \
		or tile_id == 120 \
		or _is_in_range(tile_id, ANIMATED_RANGE_B) \
		or _is_in_range(tile_id, ANIMATED_RANGE_C)


func visual_frame_for_tile(tile_id: int, animation_frame: int) -> int:
	if not is_animated_tile(tile_id):
		return 0
	return clampi(animation_frame, 0, max_animation_frame)


func source_rect_for_tile(tile_id: int, animation_frame: int = 0) -> Rect2:
	var source_column := visual_frame_for_tile(tile_id, animation_frame)
	var source_row: int = max(tile_id - FIRST_TILE_ID, 0)
	return Rect2(
		Vector2(source_column * frame_size.x, source_row * frame_size.y),
		Vector2(frame_size)
	)


func _is_in_range(value: int, bounds: Vector2i) -> bool:
	return value >= bounds.x and value <= bounds.y
