extends Control
class_name ExitConfirmScreen

signal exit_confirmed
signal back_requested

const PlayfieldSpecScript := preload("res://src/playfield/krakout_playfield_spec.gd")
const MenuAmbientEffectsScript := preload("res://src/menu/krakout_menu_ambient_effects.gd")
const StaticMenuBackButtonScript := preload("res://src/menu/static_menu_back_button.gd")
const AudioCueCatalogScript := preload("res://src/audio/krakout_audio_cue_catalog.gd")

const ICON_SIZE := Vector2i(100, 100)
const ICON_FRAME_COUNT := 20
const ICON_SELECTED_FRAME_GATE_SECONDS := 0.02
const ICON_RETURN_FRAME_GATE_SECONDS := 0.005
const EXIT_ICON_SOURCE_X := 300
const EXIT_BUTTON_POSITION := Vector2(270, 190)
const BACK_BUTTON_POSITION := Vector2(270, 350)

@onready var _background: TextureRect = $Background

var _icons_texture: Texture2D
var _exit_button: TextureButton
var _back_button
var _ambient_effects
var _exit_frame := 0
var _exit_selected_elapsed := 0.0
var _exit_return_elapsed := 0.0
var _exit_hovered := false
var _atlas_cache: Dictionary = {}


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	custom_minimum_size = Vector2(PlayfieldSpecScript.VIEWPORT_SIZE)
	_configure_scene()
	call_deferred("_focus_back_button")


func _process(delta: float) -> void:
	_advance_exit_button_animation(delta)
	_update_exit_button_frame()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_activate_back()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_accept"):
		if _exit_button != null and _exit_button.has_focus():
			_activate_exit()
		else:
			_activate_back()
		get_viewport().set_input_as_handled()


func reset_exit_button_animation() -> void:
	_exit_selected_elapsed = 0.0
	_exit_return_elapsed = 0.0
	_exit_hovered = false
	_exit_frame = 0
	_update_exit_button_frame()


func exit_button_frame() -> int:
	return _exit_frame


static func exit_icon_source_rect_for_frame(frame: int) -> Rect2:
	return Rect2(Vector2(EXIT_ICON_SOURCE_X, posmod(frame, ICON_FRAME_COUNT) * ICON_SIZE.y), Vector2(ICON_SIZE))


func _configure_scene() -> void:
	_background.texture = _load_asset_texture("BackgroundB")
	_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_background.stretch_mode = TextureRect.STRETCH_KEEP

	_icons_texture = _load_asset_texture("MainMenuIcons")
	_ensure_ambient_effects()
	_ensure_exit_button()
	_ensure_back_button()
	_update_exit_button_frame()


func _ensure_ambient_effects() -> void:
	if _ambient_effects != null:
		return

	_ambient_effects = MenuAmbientEffectsScript.new()
	_ambient_effects.name = "MenuAmbientEffects"
	_ambient_effects.position = Vector2.ZERO
	_ambient_effects.size = Vector2(PlayfieldSpecScript.VIEWPORT_SIZE)
	add_child(_ambient_effects)


func _ensure_exit_button() -> void:
	if _exit_button != null:
		return

	_exit_button = TextureButton.new()
	_exit_button.name = "ConfirmExitButton"
	_exit_button.position = EXIT_BUTTON_POSITION
	_exit_button.size = Vector2(ICON_SIZE)
	_exit_button.custom_minimum_size = Vector2(ICON_SIZE)
	_exit_button.focus_mode = Control.FOCUS_ALL
	_exit_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_exit_button.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_exit_button.ignore_texture_size = false
	_exit_button.stretch_mode = TextureButton.STRETCH_KEEP
	_exit_button.mouse_entered.connect(_set_exit_hovered.bind(true))
	_exit_button.mouse_exited.connect(_set_exit_hovered.bind(false))
	_exit_button.focus_entered.connect(_set_exit_hovered.bind(true))
	_exit_button.focus_exited.connect(_set_exit_hovered.bind(false))
	_exit_button.pressed.connect(_activate_exit)
	add_child(_exit_button)


func _ensure_back_button() -> void:
	if _back_button != null:
		return

	_back_button = StaticMenuBackButtonScript.new()
	_back_button.name = "BackButton"
	_back_button.position = BACK_BUTTON_POSITION
	_back_button.activated.connect(_activate_back)
	add_child(_back_button)


func _focus_back_button() -> void:
	if _back_button != null and _back_button.has_method("grab_focus"):
		_back_button.grab_focus()


func _set_exit_hovered(is_hovered: bool) -> void:
	_exit_hovered = is_hovered
	if is_hovered and _exit_button != null:
		_exit_button.grab_focus()
	_exit_selected_elapsed = 0.0
	_update_exit_button_frame()


func _activate_exit() -> void:
	_play_frontend_activate_sfx()
	exit_confirmed.emit()


func _activate_back() -> void:
	_play_frontend_activate_sfx()
	back_requested.emit()


func _advance_exit_button_animation(delta: float) -> void:
	if delta <= 0.0:
		return

	if _exit_hovered:
		_exit_return_elapsed = 0.0
		_exit_selected_elapsed += delta
		if _exit_selected_elapsed > ICON_SELECTED_FRAME_GATE_SECONDS:
			_exit_selected_elapsed = 0.0
			_exit_frame = (_exit_frame + 1) % ICON_FRAME_COUNT
		return

	_exit_selected_elapsed = 0.0
	if _exit_frame == 0:
		_exit_return_elapsed = 0.0
		return

	_exit_return_elapsed += delta
	if _exit_return_elapsed > ICON_RETURN_FRAME_GATE_SECONDS:
		_exit_return_elapsed = 0.0
		_exit_frame += 1
		if _exit_frame >= ICON_FRAME_COUNT:
			_exit_frame = 0


func _update_exit_button_frame() -> void:
	if _exit_button == null or _icons_texture == null:
		return

	var texture := _exit_icon_frame_texture(_exit_frame)
	_exit_button.texture_normal = texture
	_exit_button.texture_hover = texture
	_exit_button.texture_pressed = texture
	_exit_button.texture_focused = texture


func _exit_icon_frame_texture(frame: int) -> AtlasTexture:
	var cache_key := str(posmod(frame, ICON_FRAME_COUNT))
	if _atlas_cache.has(cache_key):
		return _atlas_cache[cache_key] as AtlasTexture

	var texture := AtlasTexture.new()
	texture.atlas = _icons_texture
	texture.region = exit_icon_source_rect_for_frame(frame)
	_atlas_cache[cache_key] = texture
	return texture


func _play_frontend_activate_sfx() -> void:
	var audio := get_node_or_null("/root/KrakoutAudio")
	if audio == null or not audio.has_method("play_sfx_event"):
		return
	audio.call("play_sfx_event", AudioCueCatalogScript.SFX_EVENT_FRONTEND_ACTIVATE)


func _load_asset_texture(texture_name: String) -> Texture2D:
	var assets := get_node_or_null("/root/KrakoutAssets")
	if assets == null or not assets.has_method("load_texture"):
		return null
	return assets.call("load_texture", texture_name) as Texture2D
