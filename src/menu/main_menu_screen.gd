extends Control
class_name MainMenuScreen

signal start_game_requested
signal rules_requested
signal high_score_requested
signal options_requested
signal credits_requested
signal quit_requested

const PlayfieldSpecScript := preload("res://src/playfield/krakout_playfield_spec.gd")
const MenuAmbientEffectsScript := preload("res://src/menu/krakout_menu_ambient_effects.gd")
const AudioCueCatalogScript := preload("res://src/audio/krakout_audio_cue_catalog.gd")
const ICON_SIZE := Vector2i(100, 100)
const ICON_FRAME_COUNT := 20
const ICON_SELECTED_FRAME_GATE_SECONDS := 0.02
const ICON_RETURN_FRAME_GATE_SECONDS := 0.005
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
@onready var _selected_caption = $SelectedCaption
@onready var _menu_items: Control = $MenuItems

var _icons_texture: Texture2D
var _selected_item_id := "start"
var _hovered_item_id := ""
var _icon_frames: Dictionary = {}
var _selected_icon_frame_elapsed := 0.0
var _return_icon_frame_elapsed := 0.0
var _atlas_cache: Dictionary = {}
var _buttons_by_id: Dictionary = {}
var _captions_by_id: Dictionary = {}
var _ambient_effects

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_fit_to_baseline_viewport()
	_configure_scene()
	call_deferred("_focus_start_button")


func _process(delta: float) -> void:
	_advance_menu_button_animation(delta)
	_update_menu_button_frames()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		quit_requested.emit()
		get_viewport().set_input_as_handled()


func _fit_to_baseline_viewport() -> void:
	custom_minimum_size = Vector2(PlayfieldSpecScript.VIEWPORT_SIZE)


func _configure_scene() -> void:
	_background.texture = _load_asset_texture("Background")
	_title.visible = false
	_icons_texture = _load_asset_texture("MainMenuIcons")
	_build_menu_items()
	_ensure_ambient_effects()
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
	_icon_frames.clear()
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
		button.mouse_entered.connect(_set_hovered_menu_item.bind(item_id, true))
		button.mouse_exited.connect(_set_hovered_menu_item.bind(item_id, false))
		button.focus_entered.connect(_select_menu_item.bind(item_id))
		button.pressed.connect(_activate_menu_item.bind(item_id))
		_menu_items.add_child(button)

		_buttons_by_id[item_id] = button
		_captions_by_id[item_id] = String(spec["caption"])
		_icon_frames[item_id] = 0


func _select_menu_item(item_id: String) -> void:
	if not _buttons_by_id.has(item_id):
		return
	if _selected_item_id == item_id:
		return
	_selected_item_id = item_id
	_play_sfx_event(AudioCueCatalogScript.SFX_EVENT_MAIN_MENU_SELECT)
	_update_selected_caption()
	_update_menu_button_frames()


func _set_hovered_menu_item(item_id: String, is_hovered: bool) -> void:
	if not _buttons_by_id.has(item_id):
		return
	if is_hovered:
		_hovered_item_id = item_id
		_selected_icon_frame_elapsed = 0.0
		_select_menu_item(item_id)
	else:
		if _hovered_item_id != item_id:
			return
		_hovered_item_id = ""
		_selected_icon_frame_elapsed = 0.0
	_update_selected_caption()
	_update_menu_button_frames()


func _activate_menu_item(item_id: String) -> void:
	if not _buttons_by_id.has(item_id):
		return
	_play_sfx_event(AudioCueCatalogScript.SFX_EVENT_MAIN_MENU_ACTIVATE)
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

	for spec: Dictionary in MENU_ITEM_SPECS:
		var item_id := String(spec["id"])
		var button := _buttons_by_id.get(item_id) as TextureButton
		if button == null:
			continue

		var frame: int = int(_icon_frames.get(item_id, 0))
		var texture := _icon_frame_texture(int(spec["source_x"]), frame)
		button.texture_normal = texture
		button.texture_hover = texture
		button.texture_pressed = texture
		button.texture_focused = texture


func _advance_menu_button_animation(delta: float) -> void:
	if delta <= 0.0:
		return

	if not _hovered_item_id.is_empty() and _icon_frames.has(_hovered_item_id):
		_selected_icon_frame_elapsed += delta
		if _selected_icon_frame_elapsed > ICON_SELECTED_FRAME_GATE_SECONDS:
			_icon_frames[_hovered_item_id] = int(_icon_frames.get(_hovered_item_id, 0)) + 1
			_selected_icon_frame_elapsed = 0.0
	else:
		_selected_icon_frame_elapsed = 0.0

	_return_icon_frame_elapsed += delta
	if _return_icon_frame_elapsed > ICON_RETURN_FRAME_GATE_SECONDS:
		for item_id: String in _icon_frames.keys():
			if item_id == _hovered_item_id:
				continue

			var return_frame: int = int(_icon_frames[item_id])
			if return_frame > 0:
				return_frame += 1
				_icon_frames[item_id] = 0 if return_frame >= ICON_FRAME_COUNT else return_frame
		_return_icon_frame_elapsed = 0.0

	for item_id: String in _icon_frames.keys():
		if int(_icon_frames[item_id]) >= ICON_FRAME_COUNT:
			_icon_frames[item_id] = 0


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
	return String(_captions_by_id.get(_hovered_item_id, ""))


func menu_item_frame(item_id: String) -> int:
	return int(_icon_frames.get(item_id, 0))


func reset_menu_button_animation() -> void:
	_selected_icon_frame_elapsed = 0.0
	_return_icon_frame_elapsed = 0.0
	_hovered_item_id = ""
	for spec: Dictionary in MENU_ITEM_SPECS:
		_icon_frames[String(spec["id"])] = 0
	_update_selected_caption()
	_update_menu_button_frames()


func ambient_effects():
	return _ambient_effects


func _ensure_ambient_effects() -> void:
	if _ambient_effects != null:
		return

	_ambient_effects = MenuAmbientEffectsScript.new()
	_ambient_effects.name = "MenuAmbientEffects"
	_ambient_effects.position = Vector2.ZERO
	_ambient_effects.size = Vector2(PlayfieldSpecScript.VIEWPORT_SIZE)
	add_child(_ambient_effects)
	move_child(_selected_caption, get_child_count() - 1)


func _load_asset_texture(texture_name: String) -> Texture2D:
	var assets := get_node_or_null("/root/KrakoutAssets")
	if assets == null or not assets.has_method("load_texture"):
		return null

	return assets.call("load_texture", texture_name) as Texture2D


func _play_sfx_event(event_name: String) -> void:
	var audio := get_node_or_null("/root/KrakoutAudio")
	if audio == null or not audio.has_method("play_sfx_event"):
		return
	audio.call("play_sfx_event", event_name)
