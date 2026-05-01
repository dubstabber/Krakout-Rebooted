extends Resource
class_name BrickAtlasMapping

@export var frame_size := Vector2i(20, 10)
@export var atlas_columns := 5
@export var first_tile_id := 1


func is_empty_tile(tile_id: int) -> bool:
	return tile_id == 0


func source_rect_for_tile(tile_id: int) -> Rect2:
	var frame_index: int = max(tile_id - first_tile_id, 0)
	var source_column := frame_index % atlas_columns
	var source_row := int(frame_index / atlas_columns)
	return Rect2(
		Vector2(source_column * frame_size.x, source_row * frame_size.y),
		Vector2(frame_size)
	)
