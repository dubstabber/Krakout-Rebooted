extends Control
class_name OptionsScreen

signal back_requested

const PlayfieldSpecScript := preload("res://src/playfield/krakout_playfield_spec.gd")
const OptionsVxEffectsScript := preload("res://src/menu/options_vx_effects.gd")

const ROW_X := 100.0
const CONTROL_X := 360.0
const FIRST_ROW_Y := 108.0
const ROW_STEP := 38.0

var _background: TextureRect
var _sound_slider_art: TextureRect
var _music_toggle: CheckButton
var _sfx_toggle: CheckButton
var _music_slider: HSlider
var _sfx_slider: HSlider
var _bonus_stack_toggle: CheckButton
var _ball_tracks_toggle: CheckButton
var _fps_toggle: CheckButton
var _background_movable_toggle: CheckButton
var _background_type_slider: HSlider
var _vx_effects


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	custom_minimum_size = Vector2(PlayfieldSpecScript.VIEWPORT_SIZE)
	_build_scene()
	_load_settings()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		back_requested.emit()
		get_viewport().set_input_as_handled()


func settings_snapshot() -> Dictionary:
	return {
		"music_enabled": _music_toggle.button_pressed,
		"sfx_enabled": _sfx_toggle.button_pressed,
		"music_volume": int(round(_music_slider.value)),
		"sfx_volume": int(round(_sfx_slider.value)),
		"bonus_stack_visible": _bonus_stack_toggle.button_pressed,
		"ball_tracks_visible": _ball_tracks_toggle.button_pressed,
		"fps_visible": _fps_toggle.button_pressed,
		"background_movable": _background_movable_toggle.button_pressed,
		"background_type": int(round(_background_type_slider.value)),
	}


func set_music_enabled(is_enabled: bool) -> void:
	_music_toggle.button_pressed = is_enabled
	_on_music_toggled(is_enabled)


func set_sfx_enabled(is_enabled: bool) -> void:
	_sfx_toggle.button_pressed = is_enabled
	_on_sfx_toggled(is_enabled)


func set_music_volume(volume: int) -> void:
	_music_slider.value = clampi(volume, 0, 100)
	_on_music_volume_changed(_music_slider.value)


func set_sfx_volume(volume: int) -> void:
	_sfx_slider.value = clampi(volume, 0, 100)
	_on_sfx_volume_changed(_sfx_slider.value)


func set_bonus_stack_visible(is_visible: bool) -> void:
	_bonus_stack_toggle.button_pressed = is_visible
	_on_bonus_stack_toggled(is_visible)


func set_ball_tracks_visible(is_visible: bool) -> void:
	_ball_tracks_toggle.button_pressed = is_visible
	_on_ball_tracks_toggled(is_visible)


func set_fps_visible(is_visible: bool) -> void:
	_fps_toggle.button_pressed = is_visible
	_on_fps_toggled(is_visible)


func set_background_movable(is_movable: bool) -> void:
	_background_movable_toggle.button_pressed = is_movable
	_on_background_movable_toggled(is_movable)


func set_background_type(type_id: int) -> void:
	_background_type_slider.value = clampi(type_id, 0, 2)
	_on_background_type_changed(_background_type_slider.value)


func preview_sfx() -> bool:
	var audio := _audio_service()
	if audio == null or not audio.has_method("play_sfx"):
		return false
	return bool(audio.call("play_sfx", "eff01"))


func _build_scene() -> void:
	_background = TextureRect.new()
	_background.name = "Background"
	_background.position = Vector2.ZERO
	_background.size = Vector2(PlayfieldSpecScript.VIEWPORT_SIZE)
	_background.texture = _load_asset_texture("BackgroundB")
	_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_background.stretch_mode = TextureRect.STRETCH_KEEP
	add_child(_background)

	_sound_slider_art = TextureRect.new()
	_sound_slider_art.name = "SoundSliderArt"
	_sound_slider_art.position = Vector2(374, 146)
	_sound_slider_art.size = Vector2(160, 28)
	_sound_slider_art.texture = _load_asset_texture("SoundSlider")
	_sound_slider_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sound_slider_art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	add_child(_sound_slider_art)

	var title := _label("TitleLabel", "Options", Vector2(0, 48), Vector2(640, 40), HORIZONTAL_ALIGNMENT_CENTER, 24)
	add_child(title)

	_music_toggle = _toggle("MusicToggle", "Music", FIRST_ROW_Y)
	_sfx_toggle = _toggle("SfxToggle", "Sound FX", FIRST_ROW_Y + ROW_STEP)
	_music_slider = _slider("MusicVolumeSlider", FIRST_ROW_Y + ROW_STEP * 2.0, 0, 100)
	_sfx_slider = _slider("SfxVolumeSlider", FIRST_ROW_Y + ROW_STEP * 3.0, 0, 100)
	_bonus_stack_toggle = _toggle("BonusStackToggle", "Bonus Stack", FIRST_ROW_Y + ROW_STEP * 4.0)
	_ball_tracks_toggle = _toggle("BallTracksToggle", "Ball Tracks", FIRST_ROW_Y + ROW_STEP * 5.0)
	_fps_toggle = _toggle("FpsToggle", "FPS", FIRST_ROW_Y + ROW_STEP * 6.0)
	_background_movable_toggle = _toggle("BackgroundMovableToggle", "Moving Background", FIRST_ROW_Y + ROW_STEP * 7.0)
	_background_type_slider = _slider("BackgroundTypeSlider", FIRST_ROW_Y + ROW_STEP * 8.0, 0, 2)
	_background_type_slider.step = 1.0
	_vx_effects = OptionsVxEffectsScript.new()
	_vx_effects.name = "OptionsVxEffects"
	_vx_effects.set_row_base_y(OptionsVxEffectsScript.ROW_MUSIC, _music_slider.position.y - 22.0)
	_vx_effects.set_row_base_y(OptionsVxEffectsScript.ROW_SFX, _sfx_slider.position.y - 22.0)
	add_child(_vx_effects)

	add_child(_label("MusicVolumeLabel", "Music Volume", Vector2(ROW_X, FIRST_ROW_Y + ROW_STEP * 2.0), Vector2(220, 28), HORIZONTAL_ALIGNMENT_LEFT, 16))
	add_child(_label("SfxVolumeLabel", "SFX Volume", Vector2(ROW_X, FIRST_ROW_Y + ROW_STEP * 3.0), Vector2(220, 28), HORIZONTAL_ALIGNMENT_LEFT, 16))
	add_child(_label("BackgroundTypeLabel", "Background Type", Vector2(ROW_X, FIRST_ROW_Y + ROW_STEP * 8.0), Vector2(220, 28), HORIZONTAL_ALIGNMENT_LEFT, 16))

	var preview_button := Button.new()
	preview_button.name = "PreviewSfxButton"
	preview_button.text = "Preview SFX"
	preview_button.position = Vector2(105, 405)
	preview_button.size = Vector2(130, 34)
	preview_button.pressed.connect(preview_sfx)
	add_child(preview_button)

	var back_button := Button.new()
	back_button.name = "BackButton"
	back_button.text = "Back"
	back_button.position = Vector2(255, 405)
	back_button.size = Vector2(130, 34)
	back_button.pressed.connect(func() -> void: back_requested.emit())
	add_child(back_button)

	_music_toggle.toggled.connect(_on_music_toggled)
	_sfx_toggle.toggled.connect(_on_sfx_toggled)
	_music_slider.value_changed.connect(_on_music_volume_changed)
	_sfx_slider.value_changed.connect(_on_sfx_volume_changed)
	_bonus_stack_toggle.toggled.connect(_on_bonus_stack_toggled)
	_ball_tracks_toggle.toggled.connect(_on_ball_tracks_toggled)
	_fps_toggle.toggled.connect(_on_fps_toggled)
	_background_movable_toggle.toggled.connect(_on_background_movable_toggled)
	_background_type_slider.value_changed.connect(_on_background_type_changed)


func _toggle(node_name: String, label: String, y: float) -> CheckButton:
	var toggle := CheckButton.new()
	toggle.name = node_name
	toggle.text = label
	toggle.position = Vector2(ROW_X, y)
	toggle.size = Vector2(430, 30)
	toggle.add_theme_color_override("font_color", Color.WHITE)
	add_child(toggle)
	return toggle


func _slider(node_name: String, y: float, min_value: int, max_value: int) -> HSlider:
	var slider := HSlider.new()
	slider.name = node_name
	slider.position = Vector2(CONTROL_X, y)
	slider.size = Vector2(170, 28)
	slider.min_value = min_value
	slider.max_value = max_value
	slider.step = 1.0
	add_child(slider)
	return slider


func _label(node_name: String, text: String, label_position: Vector2, label_size: Vector2, alignment: HorizontalAlignment, font_size: int) -> Label:
	var label := Label.new()
	label.name = node_name
	label.text = text
	label.position = label_position
	label.size = label_size
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_font_size_override("font_size", font_size)
	return label


func _load_settings() -> void:
	var profile := _profile_service()
	_music_toggle.button_pressed = _profile_bool(profile, "music_enabled", true)
	_sfx_toggle.button_pressed = _profile_bool(profile, "sfx_enabled", true)
	_music_slider.value = _profile_int(profile, "music_volume", 80)
	_sfx_slider.value = _profile_int(profile, "sfx_volume", 85)
	_bonus_stack_toggle.button_pressed = _profile_bool(profile, "bonus_stack_visible", true)
	_ball_tracks_toggle.button_pressed = _profile_bool(profile, "ball_tracks_visible", true)
	_fps_toggle.button_pressed = _profile_bool(profile, "fps_visible", false)
	_background_movable_toggle.button_pressed = _profile_bool(profile, "background_movable", true)
	_background_type_slider.value = clampi(_profile_int(profile, "background_type", 2), 0, 2)
	_sync_vx_effects(true)
	_sync_audio_from_profile()


func _profile_bool(profile: Node, method_name: String, default_value: bool) -> bool:
	if profile == null or not profile.has_method(method_name):
		return default_value
	return bool(profile.call(method_name))


func _profile_int(profile: Node, method_name: String, default_value: int) -> int:
	if profile == null or not profile.has_method(method_name):
		return default_value
	return int(profile.call(method_name))


func _on_music_toggled(is_enabled: bool) -> void:
	_sync_vx_effects(false)
	var profile := _profile_service()
	if profile != null and profile.has_method("set_music_enabled"):
		profile.call("set_music_enabled", is_enabled)
	var audio := _audio_service()
	if audio != null and audio.has_method("set_music_enabled"):
		audio.call("set_music_enabled", is_enabled)


func _on_sfx_toggled(is_enabled: bool) -> void:
	_sync_vx_effects(false)
	var profile := _profile_service()
	if profile != null and profile.has_method("set_sfx_enabled"):
		profile.call("set_sfx_enabled", is_enabled)
	var audio := _audio_service()
	if audio != null and audio.has_method("set_sfx_enabled"):
		audio.call("set_sfx_enabled", is_enabled)


func _on_music_volume_changed(value: float) -> void:
	var volume := int(round(value))
	var profile := _profile_service()
	if profile != null and profile.has_method("set_music_volume"):
		profile.call("set_music_volume", volume)
	var audio := _audio_service()
	if audio != null and audio.has_method("set_music_volume"):
		audio.call("set_music_volume", volume)


func _on_sfx_volume_changed(value: float) -> void:
	var volume := int(round(value))
	var profile := _profile_service()
	if profile != null and profile.has_method("set_sfx_volume"):
		profile.call("set_sfx_volume", volume)
	var audio := _audio_service()
	if audio != null and audio.has_method("set_sfx_volume"):
		audio.call("set_sfx_volume", volume)


func _on_bonus_stack_toggled(is_visible: bool) -> void:
	var profile := _profile_service()
	if profile != null and profile.has_method("set_bonus_stack_visible"):
		profile.call("set_bonus_stack_visible", is_visible)


func _on_ball_tracks_toggled(is_visible: bool) -> void:
	var profile := _profile_service()
	if profile != null and profile.has_method("set_ball_tracks_visible"):
		profile.call("set_ball_tracks_visible", is_visible)


func _on_fps_toggled(is_visible: bool) -> void:
	var profile := _profile_service()
	if profile != null and profile.has_method("set_fps_visible"):
		profile.call("set_fps_visible", is_visible)


func _on_background_movable_toggled(is_movable: bool) -> void:
	var profile := _profile_service()
	if profile != null and profile.has_method("set_background_movable"):
		profile.call("set_background_movable", is_movable)


func _on_background_type_changed(value: float) -> void:
	var profile := _profile_service()
	if profile != null and profile.has_method("set_background_type"):
		profile.call("set_background_type", int(round(value)))


func _sync_audio_from_profile() -> void:
	var audio := _audio_service()
	if audio != null and audio.has_method("apply_profile_settings"):
		audio.call("apply_profile_settings")


func vx_effects():
	return _vx_effects


func _sync_vx_effects(snap: bool = false) -> void:
	if _vx_effects == null:
		return
	_vx_effects.set_music_enabled(_music_toggle.button_pressed, snap)
	_vx_effects.set_sfx_enabled(_sfx_toggle.button_pressed, snap)


func _profile_service() -> Node:
	return get_node_or_null("/root/KrakoutProfile")


func _audio_service() -> Node:
	return get_node_or_null("/root/KrakoutAudio")


func _load_asset_texture(texture_name: String) -> Texture2D:
	var assets := get_node_or_null("/root/KrakoutAssets")
	if assets == null or not assets.has_method("load_texture"):
		return null
	return assets.call("load_texture", texture_name) as Texture2D
