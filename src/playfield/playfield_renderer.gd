extends Node2D
class_name PlayfieldRenderer

const LevelGridRendererScript := preload("res://src/render/level_grid_renderer.gd")
const PlayfieldSpecScript := preload("res://src/playfield/krakout_playfield_spec.gd")

@export var default_episode := PlayfieldSpecScript.DEFAULT_EPISODE
@export var default_level_number := PlayfieldSpecScript.DEFAULT_LEVEL_NUMBER
@export var background_texture_name := "Background"

var level_data: KrakoutLevelData
var grid_renderer: LevelGridRenderer


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_build_scene()

	if level_data == null:
		set_level(_load_default_level())
	else:
		_apply_level()


func set_level(data: KrakoutLevelData) -> void:
	level_data = data
	_apply_level()


func _build_scene() -> void:
	if grid_renderer != null:
		return

	var background_texture := _load_asset_texture(background_texture_name)
	if background_texture != null:
		var background := Sprite2D.new()
		background.name = "Background"
		background.centered = false
		background.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		background.texture = background_texture
		add_child(background)

	grid_renderer = LevelGridRendererScript.new()
	grid_renderer.name = "LevelGridRenderer"
	grid_renderer.origin = PlayfieldSpecScript.GRID_ORIGIN
	grid_renderer.tile_size = PlayfieldSpecScript.BRICK_SIZE
	grid_renderer.default_episode = default_episode
	grid_renderer.default_level_number = default_level_number
	add_child(grid_renderer)


func _apply_level() -> void:
	if grid_renderer == null or level_data == null:
		return

	grid_renderer.set_level(level_data)


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
