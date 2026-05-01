extends Control
class_name MainMenuScreen

signal start_game_requested
signal rules_requested
signal high_score_requested
signal options_requested
signal credits_requested
signal quit_requested

const PlayfieldSpecScript := preload("res://src/playfield/krakout_playfield_spec.gd")
const ICON_SIZE := Vector2i(100, 100)
const ICON_FRAME_COUNT := 20
const ICON_FRAME_SECONDS := 0.02
const MENU_ITEM_SPECS: Array[Dictionary] = [
	{
		"id": "rules",
		"name": "RulesButton",
		"caption": "Game Rules",
		"source_x": 400,
		"position": Vector2(30, 190),
	},
	{
		"id": "start",
		"name": "StartGameButton",
		"caption": "Start New Game",
		"source_x": 0,
		"position": Vector2(270, 190),
	},
	{
		"id": "high_score",
		"name": "HighScoreButton",
		"caption": "High Score",
		"source_x": 200,
		"position": Vector2(510, 190),
	},
	{
		"id": "options",
		"name": "OptionsButton",
		"caption": "Options",
		"source_x": 500,
		"position": Vector2(150, 270),
	},
	{
		"id": "credits",
		"name": "CreditsButton",
		"caption": "Credits",
		"source_x": 100,
		"position": Vector2(390, 270),
	},
	{
		"id": "exit",
		"name": "ExitButton",
		"caption": "Exit from Game",
		"source_x": 300,
		"position": Vector2(270, 350),
	},
]

@onready var _background: TextureRect = $Background
@onready var _title: TextureRect = $Title
@onready var _selected_caption: Label = $SelectedCaption
@onready var _menu_items: Control = $MenuItems

var _icons_texture: Texture2D
var _selected_item_id := "start"
var _animation_time := 0.0
var _atlas_cache: Dictionary = {}
var _buttons_by_id: Dictionary = {}
var _captions_by_id: Dictionary = {}

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_fit_to_baseline_viewport()
	_configure_scene()
	call_deferred("_focus_start_button")


func _process(delta: float) -> void:
	_animation_time += delta
	_update_menu_button_frames()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		quit_requested.emit()
		get_viewport().set_input_as_handled()


func _fit_to_baseline_viewport() -> void:
	custom_minimum_size = Vector2(PlayfieldSpecScript.VIEWPORT_SIZE)


func _configure_scene() -> void:
	_background.texture = _load_asset_texture("Background")
	_title.texture = _load_asset_texture("Title")
	_icons_texture = _load_asset_texture("MainMenuIcons")
	_build_menu_items()
	_update_selected_caption()
	_update_menu_button_frames()


func _focus_start_button() -> void:
	var start_button := _buttons_by_id.get("start") as TextureButton
	if start_button != null:
		start_button.grab_focus()


func _build_menu_items() -> void:
	for child in _menu_items.get_children():
		child.queue_free()
	_buttons_by_id.clear()
	_captions_by_id.clear()
	_atlas_cache.clear()

	for spec: Dictionary in MENU_ITEM_SPECS:
		var item_id := String(spec["id"])
		var button := TextureButton.new()
		button.name = String(spec["name"])
		button.position = spec["position"]
		button.size = Vector2(ICON_SIZE)
		button.custom_minimum_size = Vector2(ICON_SIZE)
		button.focus_mode = Control.FOCUS_ALL
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		button.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		button.ignore_texture_size = false
		button.stretch_mode = TextureButton.STRETCH_KEEP
		button.mouse_entered.connect(_select_menu_item.bind(item_id))
		button.focus_entered.connect(_select_menu_item.bind(item_id))
		button.pressed.connect(_activate_menu_item.bind(item_id))
		_menu_items.add_child(button)

		_buttons_by_id[item_id] = button
		_captions_by_id[item_id] = String(spec["caption"])


func _select_menu_item(item_id: String) -> void:
	_selected_item_id = item_id
	_update_selected_caption()
	_update_menu_button_frames()


func _activate_menu_item(item_id: String) -> void:
	match item_id:
		"rules":
			rules_requested.emit()
		"start":
			start_game_requested.emit()
		"high_score":
			high_score_requested.emit()
		"options":
			options_requested.emit()
		"credits":
			credits_requested.emit()
		"exit":
			quit_requested.emit()


func _update_menu_button_frames() -> void:
	if _icons_texture == null:
		return

	var selected_frame := int(_animation_time / ICON_FRAME_SECONDS) % ICON_FRAME_COUNT
	for spec: Dictionary in MENU_ITEM_SPECS:
		var item_id := String(spec["id"])
		var button := _buttons_by_id.get(item_id) as TextureButton
		if button == null:
			continue

		var frame := selected_frame if item_id == _selected_item_id else 0
		var texture := _icon_frame_texture(int(spec["source_x"]), frame)
		button.texture_normal = texture
		button.texture_hover = texture
		button.texture_pressed = texture
		button.texture_focused = texture


func _update_selected_caption() -> void:
	_selected_caption.text = selected_caption()


func _icon_frame_texture(source_x: int, frame: int) -> AtlasTexture:
	var cache_key := "%d:%d" % [source_x, frame]
	if _atlas_cache.has(cache_key):
		return _atlas_cache[cache_key] as AtlasTexture

	var texture := AtlasTexture.new()
	texture.atlas = _icons_texture
	texture.region = Rect2(Vector2(source_x, frame * ICON_SIZE.y), Vector2(ICON_SIZE))
	_atlas_cache[cache_key] = texture
	return texture


func selected_caption() -> String:
	return String(_captions_by_id.get(_selected_item_id, ""))


func _load_asset_texture(texture_name: String) -> Texture2D:
	var assets := get_node_or_null("/root/KrakoutAssets")
	if assets == null or not assets.has_method("load_texture"):
		return null

	return assets.call("load_texture", texture_name) as Texture2D
