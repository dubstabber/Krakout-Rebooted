extends Node2D

const LevelGridRendererScript := preload("res://src/render/level_grid_renderer.gd")


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.BLACK)
	_build_scene()


func _build_scene() -> void:
	var background_texture := KrakoutAssets.load_texture("Background")
	if background_texture != null:
		var background := Sprite2D.new()
		background.name = "Background"
		background.centered = false
		background.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		background.texture = background_texture
		add_child(background)

	var grid: LevelGridRenderer = LevelGridRendererScript.new()
	grid.name = "LevelGridRenderer"
	add_child(grid)
