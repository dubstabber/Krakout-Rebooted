extends Node2D
class_name LevelGridRenderer

const BrickAtlasMappingScript := preload("res://src/render/brick_atlas_mapping.gd")

@export var origin := Vector2(10, 82)
@export var tile_size := Vector2(20, 10)
@export var default_episode := "Default"
@export var default_level_number := 1

var level_data: KrakoutLevelData
var brick_texture: Texture2D
var atlas_mapping: BrickAtlasMapping = BrickAtlasMappingScript.new()


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	if brick_texture == null:
		brick_texture = KrakoutAssets.load_texture("Bricks")

	if level_data == null:
		set_level(KrakoutLevels.load_level(default_episode, default_level_number))


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
