extends Control
class_name MainMenuScreen

signal start_game_requested
signal quit_requested

const PlayfieldSpecScript := preload("res://src/playfield/krakout_playfield_spec.gd")

@onready var _background: TextureRect = $Background
@onready var _title: TextureRect = $Title
@onready var _start_button: Button = $MenuButtons/StartGameButton
@onready var _quit_button: Button = $MenuButtons/QuitButton


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_fit_to_baseline_viewport()
	_configure_scene()
	call_deferred("_focus_start_button")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		quit_requested.emit()
		get_viewport().set_input_as_handled()


func _fit_to_baseline_viewport() -> void:
	custom_minimum_size = Vector2(PlayfieldSpecScript.VIEWPORT_SIZE)


func _configure_scene() -> void:
	_background.texture = _load_asset_texture("BackgroundB")
	_title.texture = _load_asset_texture("Title")
	_start_button.pressed.connect(func() -> void: start_game_requested.emit())
	_quit_button.pressed.connect(func() -> void: quit_requested.emit())


func _focus_start_button() -> void:
	if _start_button != null:
		_start_button.grab_focus()


func _load_asset_texture(texture_name: String) -> Texture2D:
	var assets := get_node_or_null("/root/KrakoutAssets")
	if assets == null or not assets.has_method("load_texture"):
		return null

	return assets.call("load_texture", texture_name) as Texture2D
