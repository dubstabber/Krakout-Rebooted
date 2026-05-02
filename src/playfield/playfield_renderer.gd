extends Node2D
class_name PlayfieldRenderer

const LevelGridRendererScript := preload("res://src/render/level_grid_renderer.gd")
const PlayfieldSpecScript := preload("res://src/playfield/krakout_playfield_spec.gd")
const BoardStateScript := preload("res://src/gameplay/krakout_board_state.gd")

const BACKGROUND_TILE_SIZE := Vector2(50, 50)
const WALL_REPEAT_STEP := 45
const WALL_TOP_SOURCE := Rect2(Vector2(0, 45), Vector2(45, 25))
const WALL_SIDE_SOURCE := Rect2(Vector2(11, 0), Vector2(25, 45))
const WALL_TOP_LEFT_SOURCE := Rect2(Vector2(45, 0), Vector2(45, 45))
const WALL_TOP_RIGHT_SOURCE := Rect2(Vector2(90, 0), Vector2(45, 27))
const WALL_BOTTOM_LEFT_SOURCE := Rect2(Vector2(90, 27), Vector2(45, 45))
const WALL_BOTTOM_RIGHT_SOURCE := Rect2(Vector2(45, 45), Vector2(45, 27))
const WALL_LEFT_X := 2
const WALL_RIGHT_X := 613
const WALL_TOP_Y := 36
const WALL_BOTTOM_Y := 453
const WALL_SIDE_START_Y := 81

@export var default_episode := PlayfieldSpecScript.DEFAULT_EPISODE
@export var default_level_number := PlayfieldSpecScript.DEFAULT_LEVEL_NUMBER
@export var background_texture_name := "Backgr"
@export var walls_texture_name := "Walls"

var level_data: KrakoutLevelData
var board_state
var grid_renderer: LevelGridRenderer
var background_texture: Texture2D
var walls_texture: Texture2D


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_build_scene()

	if level_data == null:
		set_level(_load_default_level())
	else:
		_apply_level()


func set_level(data: KrakoutLevelData) -> void:
	level_data = data
	board_state = BoardStateScript.new() if data != null else null
	if board_state != null:
		board_state.load_level(data)
	_apply_level()


func current_board_state():
	return board_state


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

	var source := Rect2(Vector2.ZERO, BACKGROUND_TILE_SIZE)
	for y in range(0, PlayfieldSpecScript.VIEWPORT_SIZE.y, int(BACKGROUND_TILE_SIZE.y)):
		for x in range(0, PlayfieldSpecScript.VIEWPORT_SIZE.x, int(BACKGROUND_TILE_SIZE.x)):
			draw_texture_rect_region(
				background_texture,
				Rect2(Vector2(x, y), BACKGROUND_TILE_SIZE),
				source
			)


func _draw_walls() -> void:
	if walls_texture == null:
		return

	for x in range(WALL_REPEAT_STEP, PlayfieldSpecScript.VIEWPORT_SIZE.x, WALL_REPEAT_STEP):
		draw_texture_rect_region(walls_texture, Rect2(Vector2(x, WALL_TOP_Y), WALL_TOP_SOURCE.size), WALL_TOP_SOURCE)
		draw_texture_rect_region(walls_texture, Rect2(Vector2(x, WALL_BOTTOM_Y), WALL_TOP_SOURCE.size), WALL_TOP_SOURCE)

	for y in range(WALL_SIDE_START_Y, WALL_BOTTOM_Y, WALL_REPEAT_STEP):
		draw_texture_rect_region(walls_texture, Rect2(Vector2(WALL_LEFT_X, y), WALL_SIDE_SOURCE.size), WALL_SIDE_SOURCE)
		draw_texture_rect_region(walls_texture, Rect2(Vector2(WALL_RIGHT_X, y), WALL_SIDE_SOURCE.size), WALL_SIDE_SOURCE)

	draw_texture_rect_region(walls_texture, Rect2(Vector2(0, WALL_TOP_Y), WALL_TOP_LEFT_SOURCE.size), WALL_TOP_LEFT_SOURCE)
	draw_texture_rect_region(walls_texture, Rect2(Vector2(595, WALL_TOP_Y), WALL_TOP_RIGHT_SOURCE.size), WALL_TOP_RIGHT_SOURCE)
	draw_texture_rect_region(walls_texture, Rect2(Vector2(0, 435), WALL_BOTTOM_LEFT_SOURCE.size), WALL_BOTTOM_LEFT_SOURCE)
	draw_texture_rect_region(walls_texture, Rect2(Vector2(595, WALL_BOTTOM_Y), WALL_BOTTOM_RIGHT_SOURCE.size), WALL_BOTTOM_RIGHT_SOURCE)


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
