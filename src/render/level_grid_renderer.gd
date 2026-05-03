extends Node2D
class_name LevelGridRenderer

const BrickAtlasMappingScript := preload("res://src/render/brick_atlas_mapping.gd")
const PlayfieldSpecScript := preload("res://src/playfield/krakout_playfield_spec.gd")

const ANIMATION_STEP_SECONDS := 0.1

@export var origin := PlayfieldSpecScript.GRID_ORIGIN
@export var tile_size := PlayfieldSpecScript.BRICK_SIZE
@export var default_episode := PlayfieldSpecScript.DEFAULT_EPISODE
@export var default_level_number := PlayfieldSpecScript.DEFAULT_LEVEL_NUMBER

var level_data: KrakoutLevelData
var board_state
var brick_texture: Texture2D
var atlas_mapping: BrickAtlasMapping = BrickAtlasMappingScript.new()
var _animation_frame := 0
var _animation_direction := 1
var _animation_elapsed := 0.0
var _has_animated_tiles := false
var _reveal_offset_pixels := -1.0


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	if brick_texture == null:
		brick_texture = _load_asset_texture("Bricks")

	if level_data == null and board_state == null:
		set_level(_load_default_level())


func set_level(data: KrakoutLevelData) -> void:
	level_data = data
	board_state = null
	_has_animated_tiles = _source_has_animated_tiles(data)
	queue_redraw()


func set_board_state(state) -> void:
	board_state = state
	level_data = state.source_level if state != null else null
	_has_animated_tiles = _source_has_animated_tiles(state)
	queue_redraw()


func set_reveal_offset_pixels(value: float) -> void:
	var next_offset := -1.0
	if value >= 0.0:
		next_offset = clampf(value, 0.0, PlayfieldSpecScript.GRID_SIZE.x - PlayfieldSpecScript.BRICK_SIZE.x)
	if is_equal_approx(_reveal_offset_pixels, next_offset):
		return
	_reveal_offset_pixels = next_offset
	queue_redraw()


func current_reveal_offset_pixels() -> float:
	return _reveal_offset_pixels


func is_column_revealed(column: int) -> bool:
	if _reveal_offset_pixels < 0.0:
		return true
	return float(max(0, column)) * tile_size.x <= _reveal_offset_pixels


func _process(delta: float) -> void:
	if not _has_animated_tiles:
		return

	_animation_elapsed += delta
	if _animation_elapsed < ANIMATION_STEP_SECONDS:
		return

	_animation_elapsed = 0.0
	_animation_frame += _animation_direction
	if _animation_frame >= atlas_mapping.max_animation_frame:
		_animation_frame = atlas_mapping.max_animation_frame
		_animation_direction = -1
	elif _animation_frame <= 0:
		_animation_frame = 0
		_animation_direction = 1
	queue_redraw()


func _draw() -> void:
	var draw_source = _current_draw_source()
	if draw_source == null or brick_texture == null:
		return

	for row in range(int(draw_source.rows_count)):
		for column in range(int(draw_source.columns)):
			if not is_column_revealed(column):
				continue

			var tile_id := int(draw_source.tile_at(column, row))
			if atlas_mapping.is_empty_tile(tile_id):
				continue

			var target := Rect2(
				origin + Vector2(column * tile_size.x, row * tile_size.y),
				tile_size
			)
			draw_texture_rect_region(
				brick_texture,
				target,
				atlas_mapping.source_rect_for_tile(tile_id, _animation_frame)
			)


func _load_asset_texture(texture_name: String) -> Texture2D:
	var assets := get_node_or_null("/root/KrakoutAssets")
	if assets == null or not assets.has_method("load_texture"):
		return null

	return assets.call("load_texture", texture_name) as Texture2D


func _load_default_level():
	var levels := get_node_or_null("/root/KrakoutLevels")
	if levels == null or not levels.has_method("load_level"):
		return null

	return levels.call("load_level", default_episode, default_level_number)


func _current_draw_source() -> Variant:
	if board_state != null:
		return board_state
	return level_data


func _source_has_animated_tiles(source: Variant) -> bool:
	if source == null:
		return false

	for row: Array in source.tile_ids:
		for value: Variant in row:
			if atlas_mapping.is_animated_tile(int(value)):
				return true
	return false
