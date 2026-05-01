extends Node2D

const PlayfieldRendererScript := preload("res://src/playfield/playfield_renderer.gd")


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.BLACK)
	_build_scene()


func _build_scene() -> void:
	var playfield := PlayfieldRendererScript.new()
	playfield.name = "PlayfieldRenderer"
	add_child(playfield)
