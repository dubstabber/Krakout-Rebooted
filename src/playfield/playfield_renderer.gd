extends Node2D
class_name PlayfieldRenderer

const LevelGridRendererScript := preload("res://src/render/level_grid_renderer.gd")
const PlayfieldSpecScript := preload("res://src/playfield/krakout_playfield_spec.gd")
const BoardStateScript := preload("res://src/gameplay/krakout_board_state.gd")

const BACKGROUND_TILE_SIZE := Vector2(50, 50)
const DEFAULT_BACKGROUND_TYPE := 2
const BACKGROUND_TYPE_COLUMNS := 4
const BACKGROUND_TYPE_COUNT := 8
const GAMEPLAY_BACKGROUND_SOURCE := Rect2(Vector2(DEFAULT_BACKGROUND_TYPE * BACKGROUND_TILE_SIZE.x, 0), BACKGROUND_TILE_SIZE)
const BACKGROUND_SCROLL_GATE_SECONDS := 0.01
const BACKGROUND_SCROLL_STEP_PIXELS := 1.0
const BACKGROUND_SCROLL_WRAP_PIXELS := 50.0
const BACKGROUND_DRAW_WIDTH := 700
const BACKGROUND_DRAW_HEIGHT := 500
const WALL_REPEAT_STEP := 45.0
const WALL_SCROLL_STEP_PIXELS := 1.0
const WALL_SCROLL_WRAP_PIXELS := 45.0
const WALL_TOP_SOURCE := Rect2(Vector2(0, 45), Vector2(45, 25))
const WALL_SIDE_SOURCE := Rect2(Vector2(11, 0), Vector2(25, 45))
const WALL_TOP_LEFT_SOURCE := Rect2(Vector2(45, 0), Vector2(45, 45))
const WALL_TOP_RIGHT_SOURCE := Rect2(Vector2(90, 0), Vector2(45, 27))
const WALL_BOTTOM_LEFT_SOURCE := Rect2(Vector2(90, 27), Vector2(45, 45))
const WALL_BOTTOM_RIGHT_SOURCE := Rect2(Vector2(45, 45), Vector2(45, 27))
const WALL_REPEAT_CLIP_LEFT_X := 45.0
const WALL_REPEAT_CLIP_RIGHT_X := 595.0
const WALL_LEFT_X := 2
const WALL_RIGHT_X := 613
const WALL_TOP_Y := 36
const WALL_TOP_REPEAT_Y := 38
const WALL_BOTTOM_Y := 453
const WALL_SIDE_START_Y := 81
const WALL_SIDE_BASE_Y := 36.0
const WALL_LEFT_VISIBLE_BOTTOM_Y := 435.0

@export var default_episode := PlayfieldSpecScript.DEFAULT_EPISODE
@export var default_level_number := PlayfieldSpecScript.DEFAULT_LEVEL_NUMBER
@export var background_texture_name := "Backgr"
@export var walls_texture_name := "Walls"
@export var background_type := DEFAULT_BACKGROUND_TYPE
@export var background_movable := true

var level_data: KrakoutLevelData
var board_state
var grid_renderer: LevelGridRenderer
var background_texture: Texture2D
var walls_texture: Texture2D
var back_wall_active := false
var _background_scroll_offset := 0.0
var _background_scroll_elapsed := 0.0
var _wall_horizontal_scroll_offset := 0.0
var _wall_vertical_scroll_offset := 0.0


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_build_scene()

	if level_data == null:
		set_level(_load_default_level())
	else:
		_apply_level()


func _process(delta: float) -> void:
	advance_background(delta)
	advance_wall_animation()


func set_level(data: KrakoutLevelData) -> void:
	level_data = data
	board_state = BoardStateScript.new() if data != null else null
	if board_state != null:
		board_state.load_level(data)
	_apply_level()


func set_board_state(state) -> void:
	board_state = state
	level_data = state.source_level if state != null else null
	_apply_level()


func current_board_state():
	return board_state


func gameplay_background_source_rect() -> Rect2:
	return background_source_rect_for_type(background_type)


func background_source_rect_for_type(type_id: int) -> Rect2:
	var normalized_type := normalize_background_type(type_id)
	return Rect2(
		Vector2(
			float(normalized_type % BACKGROUND_TYPE_COLUMNS) * BACKGROUND_TILE_SIZE.x,
			float(floori(float(normalized_type) / float(BACKGROUND_TYPE_COLUMNS))) * BACKGROUND_TILE_SIZE.y
		),
		BACKGROUND_TILE_SIZE
	)


static func normalize_background_type(type_id: int) -> int:
	if type_id < 0 or type_id >= BACKGROUND_TYPE_COUNT:
		return 0
	return type_id


func set_background_type(type_id: int) -> void:
	var normalized_type := normalize_background_type(type_id)
	if background_type == normalized_type:
		return
	background_type = normalized_type
	queue_redraw()


func cycle_background_type() -> int:
	set_background_type((background_type + 1) % BACKGROUND_TYPE_COUNT)
	return background_type


func set_background_movable(is_movable: bool) -> void:
	if background_movable == is_movable:
		return
	background_movable = is_movable


func is_background_movable() -> bool:
	return background_movable


func current_background_scroll_offset() -> float:
	return _background_scroll_offset


func background_tile_target_rect(base_position: Vector2) -> Rect2:
	return Rect2(
		base_position + Vector2(-_background_scroll_offset, _background_scroll_offset),
		BACKGROUND_TILE_SIZE
	)


func advance_background(delta: float) -> void:
	if not background_movable or delta <= 0.0:
		return

	_background_scroll_elapsed += delta
	if _background_scroll_elapsed <= BACKGROUND_SCROLL_GATE_SECONDS:
		return

	_background_scroll_elapsed = 0.0
	_background_scroll_offset = fposmod(
		_background_scroll_offset + BACKGROUND_SCROLL_STEP_PIXELS,
		BACKGROUND_SCROLL_WRAP_PIXELS
	)
	queue_redraw()


func current_wall_horizontal_scroll_offset() -> float:
	return _wall_horizontal_scroll_offset


func current_wall_vertical_scroll_offset() -> float:
	return _wall_vertical_scroll_offset


func top_wall_repeat_start_x() -> float:
	return WALL_REPEAT_STEP - _wall_horizontal_scroll_offset


func bottom_wall_repeat_start_x() -> float:
	return _wall_horizontal_scroll_offset


func left_wall_repeat_start_y() -> float:
	return WALL_SIDE_BASE_Y + _wall_vertical_scroll_offset


func back_wall_repeat_start_y() -> float:
	return PlayfieldSpecScript.WALL_INNER_TOP_Y - _wall_vertical_scroll_offset


func advance_wall_animation() -> void:
	_wall_horizontal_scroll_offset = fposmod(
		_wall_horizontal_scroll_offset + WALL_SCROLL_STEP_PIXELS,
		WALL_SCROLL_WRAP_PIXELS
	)
	_wall_vertical_scroll_offset = fposmod(
		_wall_vertical_scroll_offset + WALL_SCROLL_STEP_PIXELS,
		WALL_SCROLL_WRAP_PIXELS
	)
	queue_redraw()


func refresh_board() -> void:
	if grid_renderer != null:
		grid_renderer.queue_redraw()


func set_back_wall_active(is_active: bool) -> void:
	if back_wall_active == is_active:
		return
	back_wall_active = is_active
	queue_redraw()


func is_back_wall_active() -> bool:
	return back_wall_active


func set_level_reveal_offset_pixels(value: float) -> void:
	if grid_renderer != null and grid_renderer.has_method("set_reveal_offset_pixels"):
		grid_renderer.call("set_reveal_offset_pixels", value)


func current_level_reveal_offset_pixels() -> float:
	if grid_renderer != null and grid_renderer.has_method("current_reveal_offset_pixels"):
		return float(grid_renderer.call("current_reveal_offset_pixels"))
	return -1.0


func _build_scene() -> void:
	if grid_renderer != null:
		return

	background_texture = _load_asset_texture(background_texture_name)
	walls_texture = _load_asset_texture(walls_texture_name)

	grid_renderer = LevelGridRendererScript.new()
	grid_renderer.name = "LevelGridRenderer"
	grid_renderer.origin = PlayfieldSpecScript.GRID_ORIGIN
	grid_renderer.tile_size = PlayfieldSpecScript.BRICK_SIZE
	grid_renderer.default_episode = default_episode
	grid_renderer.default_level_number = default_level_number
	add_child(grid_renderer)
	queue_redraw()


func _draw() -> void:
	_draw_background_tiles()
	_draw_walls()


func _draw_background_tiles() -> void:
	if background_texture == null:
		return

	var source_rect := gameplay_background_source_rect()
	for x in range(0, BACKGROUND_DRAW_WIDTH, int(BACKGROUND_TILE_SIZE.x)):
		for y in range(0, BACKGROUND_DRAW_HEIGHT, int(BACKGROUND_TILE_SIZE.y)):
			draw_texture_rect_region(
				background_texture,
				background_tile_target_rect(Vector2(x, y)),
				source_rect
			)


func _draw_walls() -> void:
	if walls_texture == null:
		return

	var horizontal_clip := Rect2(
		Vector2(WALL_REPEAT_CLIP_LEFT_X, WALL_TOP_Y),
		Vector2(WALL_REPEAT_CLIP_RIGHT_X - WALL_REPEAT_CLIP_LEFT_X, PlayfieldSpecScript.VIEWPORT_SIZE.y - WALL_TOP_Y)
	)
	for x in _wall_repeat_positions(top_wall_repeat_start_x(), PlayfieldSpecScript.VIEWPORT_SIZE.x):
		_draw_wall_region_clipped(Vector2(x, WALL_TOP_REPEAT_Y), WALL_TOP_SOURCE, horizontal_clip)

	for x in _wall_repeat_positions(bottom_wall_repeat_start_x(), PlayfieldSpecScript.VIEWPORT_SIZE.x):
		_draw_wall_region_clipped(Vector2(x, WALL_BOTTOM_Y), WALL_TOP_SOURCE, horizontal_clip)

	var left_wall_clip := Rect2(
		Vector2(0, WALL_SIDE_START_Y),
		Vector2(PlayfieldSpecScript.VIEWPORT_SIZE.x, WALL_LEFT_VISIBLE_BOTTOM_Y - WALL_SIDE_START_Y)
	)
	for y in _wall_repeat_positions(left_wall_repeat_start_y(), PlayfieldSpecScript.VIEWPORT_SIZE.y):
		_draw_wall_region_clipped(Vector2(WALL_LEFT_X, y), WALL_SIDE_SOURCE, left_wall_clip)

	if back_wall_active:
		var back_wall_clip := Rect2(
			Vector2(0, PlayfieldSpecScript.WALL_INNER_TOP_Y),
			Vector2(PlayfieldSpecScript.VIEWPORT_SIZE.x, WALL_BOTTOM_Y - PlayfieldSpecScript.WALL_INNER_TOP_Y)
		)
		for y in _wall_repeat_positions(back_wall_repeat_start_y(), PlayfieldSpecScript.VIEWPORT_SIZE.y):
			_draw_wall_region_clipped(Vector2(WALL_RIGHT_X, y), WALL_SIDE_SOURCE, back_wall_clip)

	draw_texture_rect_region(walls_texture, Rect2(Vector2(0, WALL_TOP_Y), WALL_TOP_LEFT_SOURCE.size), WALL_TOP_LEFT_SOURCE)
	draw_texture_rect_region(walls_texture, Rect2(Vector2(595, WALL_TOP_Y), WALL_TOP_RIGHT_SOURCE.size), WALL_TOP_RIGHT_SOURCE)
	draw_texture_rect_region(walls_texture, Rect2(Vector2(0, 435), WALL_BOTTOM_LEFT_SOURCE.size), WALL_BOTTOM_LEFT_SOURCE)
	draw_texture_rect_region(walls_texture, Rect2(Vector2(595, WALL_BOTTOM_Y), WALL_BOTTOM_RIGHT_SOURCE.size), WALL_BOTTOM_RIGHT_SOURCE)


func _wall_repeat_positions(start: float, limit: int) -> Array[float]:
	var positions: Array[float] = []
	var cursor := start
	while cursor < float(limit):
		positions.append(cursor)
		cursor += WALL_REPEAT_STEP
	return positions


func _draw_wall_region_clipped(position: Vector2, source_rect: Rect2, clip_rect: Rect2) -> void:
	var destination_rect := Rect2(position, source_rect.size)
	var clipped_destination := destination_rect.intersection(clip_rect)
	if clipped_destination.size.x <= 0.0 or clipped_destination.size.y <= 0.0:
		return

	var source_offset := clipped_destination.position - destination_rect.position
	var clipped_source := Rect2(source_rect.position + source_offset, clipped_destination.size)
	draw_texture_rect_region(walls_texture, clipped_destination, clipped_source)


func _apply_level() -> void:
	if grid_renderer == null or board_state == null:
		return

	grid_renderer.set_board_state(board_state)


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
