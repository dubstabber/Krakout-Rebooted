extends Node2D
class_name LevelGridRenderer

const BrickAtlasMappingScript := preload("res://src/render/brick_atlas_mapping.gd")
const PlayfieldSpecScript := preload("res://src/playfield/krakout_playfield_spec.gd")

@export var origin := PlayfieldSpecScript.GRID_ORIGIN
@export var tile_size := PlayfieldSpecScript.BRICK_SIZE
@export var default_episode := PlayfieldSpecScript.DEFAULT_EPISODE
@export var default_level_number := PlayfieldSpecScript.DEFAULT_LEVEL_NUMBER

var level_data: KrakoutLevelData
var brick_texture: Texture2D
var atlas_mapping: BrickAtlasMapping = BrickAtlasMappingScript.new()


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	if brick_texture == null:
		brick_texture = _load_asset_texture("Bricks")

	if level_data == null:
		set_level(_load_default_level())


func set_level(data: KrakoutLevelData) -> void:
	level_data = data
	queue_redraw()


func _draw() -> void:
	if level_data == null or brick_texture == null:
		return

	for row in range(level_data.rows_count):
		for column in range(level_data.columns):
			var tile_id := level_data.tile_at(column, row)
			if atlas_mapping.is_empty_tile(tile_id):
				continue

			var target := Rect2(
				origin + Vector2(column * tile_size.x, row * tile_size.y),
				tile_size
			)
			draw_texture_rect_region(
				brick_texture,
				target,
				atlas_mapping.source_rect_for_tile(tile_id)
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
