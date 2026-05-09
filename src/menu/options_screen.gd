extends Control
class_name OptionsScreen

signal back_requested

const PlayfieldSpecScript := preload("res://src/playfield/krakout_playfield_spec.gd")
const PlayfieldRendererScript := preload("res://src/playfield/playfield_renderer.gd")
const OptionsVxEffectsScript := preload("res://src/menu/options_vx_effects.gd")
const MenuBitmapLabelScript := preload("res://src/menu/krakout_menu_bitmap_label.gd")
const AudioCueCatalogScript := preload("res://src/audio/krakout_audio_cue_catalog.gd")

const PAGE_AUDIO := 0
const PAGE_PRESENTATION := 1
const PAGE_UTILITY := 2
const PAGE_COUNT := 3

const CONTROL_MUSIC_SLIDER := "music_slider"
const CONTROL_SFX_SLIDER := "sfx_slider"
const CONTROL_MUSIC_TOGGLE := "music_toggle"
const CONTROL_SFX_TOGGLE := "sfx_toggle"
const CONTROL_FULLSCREEN_TOGGLE := "fullscreen_toggle"
const CONTROL_FPS_TOGGLE := "fps_toggle"
const CONTROL_BACKGROUND_MOVABLE_TOGGLE := "background_movable_toggle"
const CONTROL_BACKGROUND_TYPE_SLIDER := "background_type_slider"
const CONTROL_BONUS_STACK_TOGGLE := "bonus_stack_toggle"
const CONTROL_BALL_TRACKS_TOGGLE := "ball_tracks_toggle"
const CONTROL_PAGE_UP := "page_up"
const CONTROL_PAGE_DOWN := "page_down"
const CONTROL_BACKWARD := "backward"

const AUDIO_SELECTION_ORDER := [
	CONTROL_MUSIC_SLIDER,
	CONTROL_SFX_SLIDER,
	CONTROL_MUSIC_TOGGLE,
	CONTROL_SFX_TOGGLE,
	CONTROL_PAGE_DOWN,
	CONTROL_BACKWARD,
]
const PRESENTATION_SELECTION_ORDER := [
	CONTROL_FULLSCREEN_TOGGLE,
	CONTROL_FPS_TOGGLE,
	CONTROL_BACKGROUND_MOVABLE_TOGGLE,
	CONTROL_BACKGROUND_TYPE_SLIDER,
	CONTROL_PAGE_UP,
	CONTROL_PAGE_DOWN,
	CONTROL_BACKWARD,
]
const UTILITY_SELECTION_ORDER := [
	CONTROL_BONUS_STACK_TOGGLE,
	CONTROL_BALL_TRACKS_TOGGLE,
	CONTROL_PAGE_UP,
	CONTROL_BACKWARD,
]

const MUSIC_TRACK_POSITION := Vector2(350, 244)
const SFX_TRACK_POSITION := Vector2(350, 304)
const BACKGROUND_TYPE_TRACK_POSITION := Vector2(350, 304)
const MUSIC_SLIDER_HIT_RECT := Rect2(Vector2(370, 233), Vector2(167, 38))
const SFX_SLIDER_HIT_RECT := Rect2(Vector2(370, 293), Vector2(167, 38))
const BACKGROUND_TYPE_SLIDER_HIT_RECT := Rect2(Vector2(370, 293), Vector2(167, 38))
const MUSIC_TOGGLE_HIT_RECT := Rect2(Vector2(560, 237), Vector2(30, 30))
const SFX_TOGGLE_HIT_RECT := Rect2(Vector2(560, 297), Vector2(30, 30))
const SLIDER_TRACK_SIZE := Vector2(198, 16)
const SLIDER_HANDLE_SIZE := Vector2(16, 38)
const SLIDER_TRACK_SOURCE_RECT := Rect2(Vector2.ZERO, SLIDER_TRACK_SIZE)
const SLIDER_HANDLE_SOURCE_RECT := Rect2(Vector2(198, 0), SLIDER_HANDLE_SIZE)
const ORIGINAL_AUDIO_SLIDER_POSITION_OFFSET := 8.0
const ORIGINAL_AUDIO_SLIDER_PIXELS_PER_VALUE := 1.590000033378601
const ORIGINAL_AUDIO_MOUSE_X_TO_VALUE := 0.628929853439331
const GENERIC_SLIDER_LEFT_X := 362.0
const GENERIC_SLIDER_RIGHT_X := 521.0
const GENERIC_SLIDER_SPAN_X := GENERIC_SLIDER_RIGHT_X - GENERIC_SLIDER_LEFT_X
const MUSIC_VX_BASE_Y := 222.0
const SFX_VX_BASE_Y := 282.0

const PRESENTATION_ROW_SPECS := [
	{
		"id": CONTROL_FULLSCREEN_TOGGLE,
		"label": "Fullscreen",
		"base_y": 95.0,
		"label_y": 108.0,
	},
	{
		"id": CONTROL_FPS_TOGGLE,
		"label": "FPS Counter",
		"base_y": 140.0,
		"label_y": 153.0,
	},
	{
		"id": CONTROL_BACKGROUND_MOVABLE_TOGGLE,
		"label": "Moving Background",
		"base_y": 185.0,
		"label_y": 198.0,
	},
]
const UTILITY_ROW_SPECS := [
	{
		"id": CONTROL_BONUS_STACK_TOGGLE,
		"label": "Bonus Stack",
		"base_y": 140.0,
		"label_y": 153.0,
	},
	{
		"id": CONTROL_BALL_TRACKS_TOGGLE,
		"label": "Ball Tracks",
		"base_y": 185.0,
		"label_y": 198.0,
	},
]

const TITLE_POSITION := Vector2(0, 48)
const TITLE_SIZE := Vector2(640, 36)
const MUSIC_LABEL_POSITION := Vector2(50, 240)
const SFX_LABEL_POSITION := Vector2(50, 300)
const PAGE_LABEL_POSITION_X := 50.0
const PAGE_LABEL_SIZE := Vector2(300, 28)
const BACKGROUND_TYPE_LABEL_POSITION := Vector2(50, 300)
const BACKGROUND_TYPE_VALUE_POSITION := Vector2(560, 300)
const BACKGROUND_TYPE_VALUE_SIZE := Vector2(48, 28)
const AUDIO_HELP_MUSIC_POSITION := Vector2(35, 420)
const AUDIO_HELP_SFX_POSITION := Vector2(35, 445)
const PAGE_HELP_POSITION := Vector2(0, 445)
const PAGE_HELP_SIZE := Vector2(640, 28)
const BACKWARD_POSITION := Vector2(270, 350)
const BACKWARD_SIZE := Vector2(100, 100)
const BACKWARD_FRAME_COUNT := 20
const BACKWARD_SELECTED_FRAME_GATE_SECONDS := 0.02
const BACKWARD_RETURN_FRAME_GATE_SECONDS := 0.005
const PAGE_ARROW_FRAME_COUNT := 10
const PAGE_ARROW_FRAME_SECONDS := 0.03
const PAGE_ARROW_SIZE := Vector2(45, 45)
const PAGE_UP_POSITION := Vector2(590, 100)
const PAGE_DOWN_POSITION := Vector2(590, 350)

var _background_texture: Texture2D
var _title_label
var _music_label
var _sfx_label
var _music_help_label
var _sfx_help_label
var _background_type_label
var _background_type_value_label
var _presentation_help_label
var _utility_help_label
var _presentation_row_labels: Dictionary = {}
var _utility_row_labels: Dictionary = {}
var _audio_labels: Array = []
var _presentation_labels: Array = []
var _utility_labels: Array = []

var _sound_slider_texture: Texture2D
var _backward_texture: Texture2D
var _arrow_up_texture: Texture2D
var _arrow_down_texture: Texture2D

var _page_one_vx_effects
var _page_two_vx_effects
var _page_three_vx_effects
var _presentation_row_indices: Dictionary = {}
var _utility_row_indices: Dictionary = {}

var _current_page := PAGE_AUDIO
var _selected_control_id := CONTROL_MUSIC_SLIDER
var _dragging_control_id := ""
var _arrow_animation_time := 0.0
var _backward_frame := 0
var _backward_selected_elapsed := 0.0
var _backward_return_elapsed := 0.0

var _music_enabled := true
var _sfx_enabled := true
var _fullscreen_enabled := false
var _music_volume := 80
var _sfx_volume := 85
var _bonus_stack_visible := true
var _ball_tracks_visible := true
var _fps_visible := false
var _background_movable := true
var _background_type := 2


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	custom_minimum_size = Vector2(PlayfieldSpecScript.VIEWPORT_SIZE)
	_build_scene()
	_load_settings()


func _process(delta: float) -> void:
	_arrow_animation_time += delta
	_advance_backward_animation(delta)
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_play_frontend_activate_sfx()
		back_requested.emit()
		get_viewport().set_input_as_handled()
		return

	var key_event := event as InputEventKey
	if key_event == null or not key_event.pressed or key_event.echo:
		return

	if _handle_volume_shortcut(key_event):
		get_viewport().set_input_as_handled()
		return

	match key_event.keycode:
		KEY_PAGEUP:
			_activate_page_change(_current_page - 1)
			get_viewport().set_input_as_handled()
		KEY_PAGEDOWN:
			_activate_page_change(_current_page + 1)
			get_viewport().set_input_as_handled()
		KEY_UP:
			_select_relative(-1)
			get_viewport().set_input_as_handled()
		KEY_DOWN:
			_select_relative(1)
			get_viewport().set_input_as_handled()
		KEY_LEFT:
			_adjust_selected_control(-1)
			get_viewport().set_input_as_handled()
		KEY_RIGHT:
			_adjust_selected_control(1)
			get_viewport().set_input_as_handled()
		KEY_ENTER, KEY_KP_ENTER, KEY_SPACE:
			_activate_control(_selected_control_id)
			get_viewport().set_input_as_handled()


func _gui_input(event: InputEvent) -> void:
	var mouse_motion := event as InputEventMouseMotion
	if mouse_motion != null:
		if not _dragging_control_id.is_empty():
			_update_slider_from_mouse(_dragging_control_id, mouse_motion.position.x)
			get_viewport().set_input_as_handled()
			return

		var hovered_control_id := _control_at_position(mouse_motion.position)
		if not hovered_control_id.is_empty():
			select_control(hovered_control_id)
		return

	var mouse_button := event as InputEventMouseButton
	if mouse_button == null or mouse_button.button_index != MOUSE_BUTTON_LEFT:
		return

	if mouse_button.pressed:
		var control_id := _control_at_position(mouse_button.position)
		if control_id.is_empty():
			return
		select_control(control_id)
		if _is_slider_control(control_id):
			_dragging_control_id = control_id
			_update_slider_from_mouse(control_id, mouse_button.position.x)
		else:
			_activate_control(control_id)
		get_viewport().set_input_as_handled()
	else:
		_dragging_control_id = ""


func settings_snapshot() -> Dictionary:
	return {
		"music_enabled": _music_enabled,
		"sfx_enabled": _sfx_enabled,
		"fullscreen_enabled": _fullscreen_enabled,
		"music_volume": _music_volume,
		"sfx_volume": _sfx_volume,
		"bonus_stack_visible": _bonus_stack_visible,
		"ball_tracks_visible": _ball_tracks_visible,
		"fps_visible": _fps_visible,
		"background_movable": _background_movable,
		"background_type": _background_type,
	}


func current_page() -> int:
	return _current_page


func page_count() -> int:
	return PAGE_COUNT


func visible_control_ids() -> Array:
	return _selection_order_for_page(_current_page).duplicate()


func selected_control_id() -> String:
	return _selected_control_id


func control_hit_rect(control_id: String) -> Rect2:
	match control_id:
		CONTROL_MUSIC_SLIDER:
			return MUSIC_SLIDER_HIT_RECT
		CONTROL_SFX_SLIDER:
			return SFX_SLIDER_HIT_RECT
		CONTROL_BACKGROUND_TYPE_SLIDER:
			return BACKGROUND_TYPE_SLIDER_HIT_RECT
		CONTROL_MUSIC_TOGGLE:
			return MUSIC_TOGGLE_HIT_RECT
		CONTROL_SFX_TOGGLE:
			return SFX_TOGGLE_HIT_RECT
		CONTROL_FULLSCREEN_TOGGLE:
			return _presentation_toggle_rect(CONTROL_FULLSCREEN_TOGGLE)
		CONTROL_FPS_TOGGLE:
			return _presentation_toggle_rect(CONTROL_FPS_TOGGLE)
		CONTROL_BACKGROUND_MOVABLE_TOGGLE:
			return _presentation_toggle_rect(CONTROL_BACKGROUND_MOVABLE_TOGGLE)
		CONTROL_BONUS_STACK_TOGGLE:
			return _utility_toggle_rect(CONTROL_BONUS_STACK_TOGGLE)
		CONTROL_BALL_TRACKS_TOGGLE:
			return _utility_toggle_rect(CONTROL_BALL_TRACKS_TOGGLE)
		CONTROL_PAGE_UP:
			return Rect2(PAGE_UP_POSITION, PAGE_ARROW_SIZE)
		CONTROL_PAGE_DOWN:
			return Rect2(PAGE_DOWN_POSITION, PAGE_ARROW_SIZE)
		CONTROL_BACKWARD:
			return Rect2(BACKWARD_POSITION, BACKWARD_SIZE)
		_:
			return Rect2(Vector2.ZERO, Vector2.ZERO)


func slider_handle_rect(control_id: String) -> Rect2:
	match control_id:
		CONTROL_MUSIC_SLIDER:
			return Rect2(
				Vector2(
					float(original_audio_slider_handle_x_for_volume(_music_volume)),
					MUSIC_SLIDER_HIT_RECT.position.y
				),
				SLIDER_HANDLE_SIZE
			)
		CONTROL_SFX_SLIDER:
			return Rect2(
				Vector2(
					float(original_audio_slider_handle_x_for_volume(_sfx_volume)),
					SFX_SLIDER_HIT_RECT.position.y
				),
				SLIDER_HANDLE_SIZE
			)
		CONTROL_BACKGROUND_TYPE_SLIDER:
			return Rect2(
				Vector2(
					float(
						generic_slider_handle_x_for_value(
							_background_type,
							PlayfieldRendererScript.BACKGROUND_TYPE_COUNT - 1
						)
					),
					BACKGROUND_TYPE_SLIDER_HIT_RECT.position.y
				),
				SLIDER_HANDLE_SIZE
			)
		_:
			return Rect2(Vector2.ZERO, Vector2.ZERO)


func backward_frame() -> int:
	return _backward_frame


func page_arrow_frame() -> int:
	return int(_arrow_animation_time / PAGE_ARROW_FRAME_SECONDS) % PAGE_ARROW_FRAME_COUNT


func vx_effects():
	return _page_one_vx_effects


func page_two_vx_effects():
	return _page_two_vx_effects


func page_three_vx_effects():
	return _page_three_vx_effects


func go_to_page(page_index: int) -> bool:
	var clamped_page := clampi(page_index, 0, PAGE_COUNT - 1)
	if clamped_page == _current_page:
		return false

	_current_page = clamped_page
	_dragging_control_id = ""
	_selected_control_id = _default_selection_for_page(_current_page)
	_sync_page_visibility()
	queue_redraw()
	return true


func select_control(control_id: String) -> bool:
	if not _selection_order_for_page(_current_page).has(control_id):
		return false
	if _selected_control_id == control_id:
		return false
	_selected_control_id = control_id
	_update_label_highlights()
	_play_frontend_select_sfx()
	return true


func set_music_enabled(is_enabled: bool) -> void:
	_on_music_toggled(bool(is_enabled))


func set_sfx_enabled(is_enabled: bool) -> void:
	_on_sfx_toggled(bool(is_enabled))


func set_fullscreen_enabled(is_enabled: bool) -> void:
	_on_fullscreen_toggled(bool(is_enabled))


func set_music_volume(volume: int) -> void:
	_on_music_volume_changed(clampi(volume, 0, 100))


func set_sfx_volume(volume: int) -> void:
	_on_sfx_volume_changed(clampi(volume, 0, 100))


func set_bonus_stack_visible(is_visible: bool) -> void:
	_on_bonus_stack_toggled(bool(is_visible))


func set_ball_tracks_visible(is_visible: bool) -> void:
	_on_ball_tracks_toggled(bool(is_visible))


func set_fps_visible(is_visible: bool) -> void:
	_on_fps_toggled(bool(is_visible))


func set_background_movable(is_movable: bool) -> void:
	_on_background_movable_toggled(bool(is_movable))


func set_background_type(type_id: int) -> void:
	_on_background_type_changed(PlayfieldRendererScript.normalize_background_type(type_id))


static func sound_slider_track_source_rect() -> Rect2:
	return SLIDER_TRACK_SOURCE_RECT


static func sound_slider_handle_source_rect() -> Rect2:
	return SLIDER_HANDLE_SOURCE_RECT


static func original_audio_slider_handle_x_for_volume(volume: int) -> int:
	var clamped_volume := clampi(volume, 0, 100)
	return int(
		370.0
		- (
			ORIGINAL_AUDIO_SLIDER_POSITION_OFFSET
			- float(clamped_volume) * ORIGINAL_AUDIO_SLIDER_PIXELS_PER_VALUE
		)
	)


static func original_audio_volume_for_mouse_x(mouse_x: float) -> int:
	return clampi(int((mouse_x - 370.0) * ORIGINAL_AUDIO_MOUSE_X_TO_VALUE), 0, 100)


static func generic_slider_handle_x_for_value(value: int, max_value: int) -> int:
	var clamped_max := maxi(1, max_value)
	var clamped_value := clampi(value, 0, clamped_max)
	var ratio := float(clamped_value) / float(clamped_max)
	return int(floor(GENERIC_SLIDER_LEFT_X + ratio * GENERIC_SLIDER_SPAN_X))


static func backward_source_rect_for_frame(frame: int) -> Rect2:
	var clamped_frame := posmod(frame, BACKWARD_FRAME_COUNT)
	return Rect2(Vector2(0, clamped_frame * BACKWARD_SIZE.y), BACKWARD_SIZE)


static func page_arrow_source_rect_for_frame(frame: int) -> Rect2:
	var clamped_frame := posmod(frame, PAGE_ARROW_FRAME_COUNT)
	return Rect2(Vector2(clamped_frame * PAGE_ARROW_SIZE.x, 0), PAGE_ARROW_SIZE)


func _draw() -> void:
	if _background_texture != null:
		draw_texture_rect(
			_background_texture,
			Rect2(Vector2.ZERO, Vector2(PlayfieldSpecScript.VIEWPORT_SIZE)),
			false
		)

	match _current_page:
		PAGE_AUDIO:
			_draw_audio_page()
		PAGE_PRESENTATION:
			_draw_presentation_page()

	_draw_backward_button()
	_draw_visible_page_arrows()


func _draw_audio_page() -> void:
	if _sound_slider_texture == null:
		return
	draw_texture_rect_region(
		_sound_slider_texture,
		Rect2(MUSIC_TRACK_POSITION, SLIDER_TRACK_SIZE),
		sound_slider_track_source_rect()
	)
	draw_texture_rect_region(
		_sound_slider_texture,
		Rect2(SFX_TRACK_POSITION, SLIDER_TRACK_SIZE),
		sound_slider_track_source_rect()
	)
	draw_texture_rect_region(
		_sound_slider_texture,
		slider_handle_rect(CONTROL_MUSIC_SLIDER),
		sound_slider_handle_source_rect()
	)
	draw_texture_rect_region(
		_sound_slider_texture,
		slider_handle_rect(CONTROL_SFX_SLIDER),
		sound_slider_handle_source_rect()
	)


func _draw_presentation_page() -> void:
	if _sound_slider_texture == null:
		return
	draw_texture_rect_region(
		_sound_slider_texture,
		Rect2(BACKGROUND_TYPE_TRACK_POSITION, SLIDER_TRACK_SIZE),
		sound_slider_track_source_rect()
	)
	draw_texture_rect_region(
		_sound_slider_texture,
		slider_handle_rect(CONTROL_BACKGROUND_TYPE_SLIDER),
		sound_slider_handle_source_rect()
	)


func _draw_backward_button() -> void:
	if _backward_texture == null:
		return
	draw_texture_rect_region(
		_backward_texture,
		Rect2(BACKWARD_POSITION, BACKWARD_SIZE),
		backward_source_rect_for_frame(_backward_frame)
	)


func _draw_visible_page_arrows() -> void:
	var frame := page_arrow_frame()
	match _current_page:
		PAGE_AUDIO:
			_draw_page_arrow(_arrow_down_texture, PAGE_DOWN_POSITION, frame)
		PAGE_PRESENTATION:
			_draw_page_arrow(_arrow_up_texture, PAGE_UP_POSITION, frame)
			_draw_page_arrow(_arrow_down_texture, PAGE_DOWN_POSITION, frame)
		PAGE_UTILITY:
			_draw_page_arrow(_arrow_up_texture, PAGE_UP_POSITION, frame)


func _draw_page_arrow(texture: Texture2D, position: Vector2, frame: int) -> void:
	if texture == null:
		return
	draw_texture_rect_region(
		texture,
		Rect2(position, PAGE_ARROW_SIZE),
		page_arrow_source_rect_for_frame(frame)
	)


func _build_scene() -> void:
	_background_texture = _load_asset_texture("BackgroundB")
	_sound_slider_texture = _load_asset_texture("SoundSlider")
	_backward_texture = _load_asset_texture("Backward")
	_arrow_up_texture = _load_asset_texture("Arrowup")
	_arrow_down_texture = _load_asset_texture("Arrowdown")

	_title_label = _label(
		"TitleLabel",
		"Options",
		TITLE_POSITION,
		TITLE_SIZE,
		HORIZONTAL_ALIGNMENT_CENTER,
		24
	)
	add_child(_title_label)

	_music_label = _label(
		"MusicVolumeLabel",
		"Music Volume",
		MUSIC_LABEL_POSITION,
		Vector2(220, 28),
		HORIZONTAL_ALIGNMENT_LEFT,
		18
	)
	_sfx_label = _label(
		"SfxVolumeLabel",
		"SFX Volume",
		SFX_LABEL_POSITION,
		Vector2(220, 28),
		HORIZONTAL_ALIGNMENT_LEFT,
		18
	)
	_music_help_label = _label(
		"MusicHelpLabel",
		"Use +/- to change Music volume,",
		AUDIO_HELP_MUSIC_POSITION,
		Vector2(360, 24),
		HORIZONTAL_ALIGNMENT_LEFT,
		16
	)
	_sfx_help_label = _label(
		"SfxHelpLabel",
		"Shift and +/- to change SFX volume.",
		AUDIO_HELP_SFX_POSITION,
		Vector2(420, 24),
		HORIZONTAL_ALIGNMENT_LEFT,
		16
	)
	_audio_labels = [_music_label, _sfx_label, _music_help_label, _sfx_help_label]
	for label in _audio_labels:
		add_child(label)

	for row_index in range(PRESENTATION_ROW_SPECS.size()):
		var spec: Dictionary = PRESENTATION_ROW_SPECS[row_index]
		var row_id := String(spec["id"])
		var row_label = _label(
			"%sLabel" % row_id.capitalize(),
			String(spec["label"]),
			Vector2(PAGE_LABEL_POSITION_X, float(spec["label_y"])),
			PAGE_LABEL_SIZE,
			HORIZONTAL_ALIGNMENT_LEFT,
			18
		)
		_presentation_row_labels[row_id] = row_label
		_presentation_row_indices[row_id] = row_index
		_presentation_labels.append(row_label)
		add_child(row_label)

	_background_type_label = _label(
		"BackgroundTypeLabel",
		"Background Type",
		BACKGROUND_TYPE_LABEL_POSITION,
		Vector2(260, 28),
		HORIZONTAL_ALIGNMENT_LEFT,
		18
	)
	_background_type_value_label = _label(
		"BackgroundTypeValueLabel",
		"0",
		BACKGROUND_TYPE_VALUE_POSITION,
		BACKGROUND_TYPE_VALUE_SIZE,
		HORIZONTAL_ALIGNMENT_RIGHT,
		18
	)
	_presentation_help_label = _label(
		"PresentationHelpLabel",
		"Page 2 / 3. Press PgUp / PgDn.",
		PAGE_HELP_POSITION,
		PAGE_HELP_SIZE,
		HORIZONTAL_ALIGNMENT_CENTER,
		16
	)
	_presentation_labels.append(_background_type_label)
	_presentation_labels.append(_background_type_value_label)
	_presentation_labels.append(_presentation_help_label)
	add_child(_background_type_label)
	add_child(_background_type_value_label)
	add_child(_presentation_help_label)

	for row_index in range(UTILITY_ROW_SPECS.size()):
		var spec: Dictionary = UTILITY_ROW_SPECS[row_index]
		var row_id := String(spec["id"])
		var row_label = _label(
			"%sLabel" % row_id.capitalize(),
			String(spec["label"]),
			Vector2(PAGE_LABEL_POSITION_X, float(spec["label_y"])),
			PAGE_LABEL_SIZE,
			HORIZONTAL_ALIGNMENT_LEFT,
			18
		)
		_utility_row_labels[row_id] = row_label
		_utility_row_indices[row_id] = row_index
		_utility_labels.append(row_label)
		add_child(row_label)

	_utility_help_label = _label(
		"UtilityHelpLabel",
		"Page 3 / 3. Press PgUp to return.",
		PAGE_HELP_POSITION,
		PAGE_HELP_SIZE,
		HORIZONTAL_ALIGNMENT_CENTER,
		16
	)
	_utility_labels.append(_utility_help_label)
	add_child(_utility_help_label)

	_page_one_vx_effects = OptionsVxEffectsScript.new()
	_page_one_vx_effects.name = "OptionsVxEffects"
	_page_one_vx_effects.set_row_base_y(OptionsVxEffectsScript.ROW_MUSIC, MUSIC_VX_BASE_Y)
	_page_one_vx_effects.set_row_base_y(OptionsVxEffectsScript.ROW_SFX, SFX_VX_BASE_Y)
	add_child(_page_one_vx_effects)

	_page_two_vx_effects = OptionsVxEffectsScript.new()
	_page_two_vx_effects.name = "OptionsPageTwoVxEffects"
	_page_two_vx_effects.configure_row_count(PRESENTATION_ROW_SPECS.size())
	for row_index in range(PRESENTATION_ROW_SPECS.size()):
		_page_two_vx_effects.set_row_base_y(
			row_index,
			float(PRESENTATION_ROW_SPECS[row_index]["base_y"])
		)
	add_child(_page_two_vx_effects)

	_page_three_vx_effects = OptionsVxEffectsScript.new()
	_page_three_vx_effects.name = "OptionsPageThreeVxEffects"
	_page_three_vx_effects.configure_row_count(UTILITY_ROW_SPECS.size())
	for row_index in range(UTILITY_ROW_SPECS.size()):
		_page_three_vx_effects.set_row_base_y(
			row_index,
			float(UTILITY_ROW_SPECS[row_index]["base_y"])
		)
	add_child(_page_three_vx_effects)

	_sync_page_visibility()


func _load_settings() -> void:
	var profile := _profile_service()
	_music_enabled = _profile_bool(profile, "music_enabled", true)
	_sfx_enabled = _profile_bool(profile, "sfx_enabled", true)
	_fullscreen_enabled = _profile_bool(profile, "fullscreen_enabled", false)
	_music_volume = _profile_int(profile, "music_volume", 80)
	_sfx_volume = _profile_int(profile, "sfx_volume", 85)
	_bonus_stack_visible = _profile_bool(profile, "bonus_stack_visible", true)
	_ball_tracks_visible = _profile_bool(profile, "ball_tracks_visible", true)
	_fps_visible = _profile_bool(profile, "fps_visible", false)
	_background_movable = _profile_bool(profile, "background_movable", true)
	_background_type = PlayfieldRendererScript.normalize_background_type(
		_profile_int(profile, "background_type", 2)
	)
	_sync_vx_effects(true)
	_sync_presentation_toggle_effects(true)
	_sync_utility_toggle_effects(true)
	_sync_dynamic_labels()
	_sync_audio_from_profile()
	_sync_page_visibility()
	queue_redraw()


func _profile_bool(profile: Node, method_name: String, default_value: bool) -> bool:
	if profile == null or not profile.has_method(method_name):
		return default_value
	return bool(profile.call(method_name))


func _profile_int(profile: Node, method_name: String, default_value: int) -> int:
	if profile == null or not profile.has_method(method_name):
		return default_value
	return int(profile.call(method_name))


func _sync_vx_effects(snap: bool = false) -> void:
	if _page_one_vx_effects == null:
		return
	_page_one_vx_effects.set_music_enabled(_music_enabled, snap)
	_page_one_vx_effects.set_sfx_enabled(_sfx_enabled, snap)


func _sync_presentation_toggle_effects(snap: bool = false) -> void:
	if _page_two_vx_effects == null:
		return
	_page_two_vx_effects.set_row_enabled(
		int(_presentation_row_indices[CONTROL_FULLSCREEN_TOGGLE]),
		_fullscreen_enabled,
		snap
	)
	_page_two_vx_effects.set_row_enabled(
		int(_presentation_row_indices[CONTROL_FPS_TOGGLE]),
		_fps_visible,
		snap
	)
	_page_two_vx_effects.set_row_enabled(
		int(_presentation_row_indices[CONTROL_BACKGROUND_MOVABLE_TOGGLE]),
		_background_movable,
		snap
	)


func _sync_utility_toggle_effects(snap: bool = false) -> void:
	if _page_three_vx_effects == null:
		return
	_page_three_vx_effects.set_row_enabled(
		int(_utility_row_indices[CONTROL_BONUS_STACK_TOGGLE]),
		_bonus_stack_visible,
		snap
	)
	_page_three_vx_effects.set_row_enabled(
		int(_utility_row_indices[CONTROL_BALL_TRACKS_TOGGLE]),
		_ball_tracks_visible,
		snap
	)


func _sync_dynamic_labels() -> void:
	if _background_type_value_label != null:
		_background_type_value_label.text = str(_background_type)


func _sync_audio_from_profile() -> void:
	var audio := _audio_service()
	if audio != null and audio.has_method("apply_profile_settings"):
		audio.call("apply_profile_settings")


func _sync_page_visibility() -> void:
	_set_labels_visible(_audio_labels, _current_page == PAGE_AUDIO)
	_set_labels_visible(_presentation_labels, _current_page == PAGE_PRESENTATION)
	_set_labels_visible(_utility_labels, _current_page == PAGE_UTILITY)
	if _page_one_vx_effects != null:
		_page_one_vx_effects.visible = _current_page == PAGE_AUDIO
	if _page_two_vx_effects != null:
		_page_two_vx_effects.visible = _current_page == PAGE_PRESENTATION
	if _page_three_vx_effects != null:
		_page_three_vx_effects.visible = _current_page == PAGE_UTILITY
	_update_label_highlights()


func _set_labels_visible(labels: Array, is_visible: bool) -> void:
	for label in labels:
		label.visible = is_visible


func _update_label_highlights() -> void:
	_set_label_highlight(
		_music_label,
		_selected_control_id == CONTROL_MUSIC_SLIDER
		or _selected_control_id == CONTROL_MUSIC_TOGGLE
	)
	_set_label_highlight(
		_sfx_label,
		_selected_control_id == CONTROL_SFX_SLIDER
		or _selected_control_id == CONTROL_SFX_TOGGLE
	)
	for spec: Dictionary in PRESENTATION_ROW_SPECS:
		var row_id := String(spec["id"])
		_set_label_highlight(
			_presentation_row_labels[row_id],
			_selected_control_id == row_id
		)
	for spec: Dictionary in UTILITY_ROW_SPECS:
		var row_id := String(spec["id"])
		_set_label_highlight(
			_utility_row_labels[row_id],
			_selected_control_id == row_id
		)
	_set_label_highlight(
		_background_type_label,
		_selected_control_id == CONTROL_BACKGROUND_TYPE_SLIDER
	)
	_set_label_highlight(
		_background_type_value_label,
		_selected_control_id == CONTROL_BACKGROUND_TYPE_SLIDER
	)


func _set_label_highlight(label, is_selected: bool) -> void:
	pass


func _on_music_toggled(is_enabled: bool) -> void:
	_music_enabled = is_enabled
	_sync_vx_effects(false)
	var profile := _profile_service()
	if profile != null and profile.has_method("set_music_enabled"):
		profile.call("set_music_enabled", is_enabled)
	var audio := _audio_service()
	if audio != null and audio.has_method("set_music_enabled"):
		audio.call("set_music_enabled", is_enabled)


func _on_sfx_toggled(is_enabled: bool) -> void:
	_sfx_enabled = is_enabled
	_sync_vx_effects(false)
	var profile := _profile_service()
	if profile != null and profile.has_method("set_sfx_enabled"):
		profile.call("set_sfx_enabled", is_enabled)
	var audio := _audio_service()
	if audio != null and audio.has_method("set_sfx_enabled"):
		audio.call("set_sfx_enabled", is_enabled)


func _on_fullscreen_toggled(is_enabled: bool) -> void:
	_fullscreen_enabled = is_enabled
	_sync_presentation_toggle_effects(false)
	var profile := _profile_service()
	if profile != null and profile.has_method("set_fullscreen_enabled"):
		profile.call("set_fullscreen_enabled", is_enabled)
	_apply_fullscreen_setting()


func _on_music_volume_changed(volume: int) -> void:
	_music_volume = clampi(volume, 0, 100)
	var profile := _profile_service()
	if profile != null and profile.has_method("set_music_volume"):
		profile.call("set_music_volume", _music_volume)
	var audio := _audio_service()
	if audio != null and audio.has_method("set_music_volume"):
		audio.call("set_music_volume", _music_volume)


func _on_sfx_volume_changed(volume: int) -> void:
	_sfx_volume = clampi(volume, 0, 100)
	var profile := _profile_service()
	if profile != null and profile.has_method("set_sfx_volume"):
		profile.call("set_sfx_volume", _sfx_volume)
	var audio := _audio_service()
	if audio != null and audio.has_method("set_sfx_volume"):
		audio.call("set_sfx_volume", _sfx_volume)


func _on_bonus_stack_toggled(is_visible: bool) -> void:
	_bonus_stack_visible = is_visible
	_sync_utility_toggle_effects(false)
	var profile := _profile_service()
	if profile != null and profile.has_method("set_bonus_stack_visible"):
		profile.call("set_bonus_stack_visible", is_visible)


func _on_ball_tracks_toggled(is_visible: bool) -> void:
	_ball_tracks_visible = is_visible
	_sync_utility_toggle_effects(false)
	var profile := _profile_service()
	if profile != null and profile.has_method("set_ball_tracks_visible"):
		profile.call("set_ball_tracks_visible", is_visible)


func _on_fps_toggled(is_visible: bool) -> void:
	_fps_visible = is_visible
	_sync_presentation_toggle_effects(false)
	var profile := _profile_service()
	if profile != null and profile.has_method("set_fps_visible"):
		profile.call("set_fps_visible", is_visible)


func _on_background_movable_toggled(is_movable: bool) -> void:
	_background_movable = is_movable
	_sync_presentation_toggle_effects(false)
	var profile := _profile_service()
	if profile != null and profile.has_method("set_background_movable"):
		profile.call("set_background_movable", is_movable)


func _on_background_type_changed(type_id: int) -> void:
	_background_type = PlayfieldRendererScript.normalize_background_type(type_id)
	_sync_dynamic_labels()
	var profile := _profile_service()
	if profile != null and profile.has_method("set_background_type"):
		profile.call("set_background_type", _background_type)


func _apply_fullscreen_setting() -> void:
	var parent_node := get_parent()
	if parent_node != null and parent_node.has_method("apply_fullscreen_enabled"):
		parent_node.call("apply_fullscreen_enabled", _fullscreen_enabled)
		return

	if DisplayServer.get_name() == "headless":
		return

	var window := get_window()
	if window == null:
		return

	window.mode = Window.MODE_FULLSCREEN if _fullscreen_enabled else Window.MODE_WINDOWED


func _advance_backward_animation(delta: float) -> void:
	if delta <= 0.0:
		return

	if _selected_control_id == CONTROL_BACKWARD:
		_backward_return_elapsed = 0.0
		_backward_selected_elapsed += delta
		if _backward_selected_elapsed > BACKWARD_SELECTED_FRAME_GATE_SECONDS:
			_backward_selected_elapsed = 0.0
			_backward_frame = (_backward_frame + 1) % BACKWARD_FRAME_COUNT
	else:
		_backward_selected_elapsed = 0.0
		if _backward_frame == 0:
			_backward_return_elapsed = 0.0
			return
		_backward_return_elapsed += delta
		if _backward_return_elapsed > BACKWARD_RETURN_FRAME_GATE_SECONDS:
			_backward_return_elapsed = 0.0
			_backward_frame += 1
			if _backward_frame >= BACKWARD_FRAME_COUNT:
				_backward_frame = 0


func _selection_order_for_page(page_index: int) -> Array:
	match page_index:
		PAGE_AUDIO:
			return AUDIO_SELECTION_ORDER
		PAGE_PRESENTATION:
			return PRESENTATION_SELECTION_ORDER
		_:
			return UTILITY_SELECTION_ORDER


func _default_selection_for_page(page_index: int) -> String:
	match page_index:
		PAGE_AUDIO:
			return CONTROL_MUSIC_SLIDER
		PAGE_PRESENTATION:
			return CONTROL_FULLSCREEN_TOGGLE
		_:
			return CONTROL_BONUS_STACK_TOGGLE


func _select_relative(offset: int) -> void:
	var selection_order := _selection_order_for_page(_current_page)
	var current_index := selection_order.find(_selected_control_id)
	if current_index < 0:
		current_index = 0
	var next_index := int(clamp(current_index + offset, 0, selection_order.size() - 1))
	select_control(String(selection_order[next_index]))


func _adjust_selected_control(direction: int) -> bool:
	match _selected_control_id:
		CONTROL_MUSIC_SLIDER:
			set_music_volume(_music_volume + direction)
		CONTROL_SFX_SLIDER:
			set_sfx_volume(_sfx_volume + direction)
		CONTROL_BACKGROUND_TYPE_SLIDER:
			set_background_type(_background_type + direction)
		CONTROL_MUSIC_TOGGLE:
			var previous_music_enabled := _music_enabled
			if previous_music_enabled != (direction > 0):
				_play_frontend_activate_sfx()
			set_music_enabled(direction > 0)
			return previous_music_enabled != _music_enabled
		CONTROL_SFX_TOGGLE:
			var previous_sfx_enabled := _sfx_enabled
			if previous_sfx_enabled != (direction > 0):
				_play_frontend_activate_sfx()
			set_sfx_enabled(direction > 0)
			return previous_sfx_enabled != _sfx_enabled
		CONTROL_FULLSCREEN_TOGGLE:
			var previous_fullscreen_enabled := _fullscreen_enabled
			if previous_fullscreen_enabled != (direction > 0):
				_play_frontend_activate_sfx()
			set_fullscreen_enabled(direction > 0)
			return previous_fullscreen_enabled != _fullscreen_enabled
		CONTROL_FPS_TOGGLE:
			var previous_fps_visible := _fps_visible
			if previous_fps_visible != (direction > 0):
				_play_frontend_activate_sfx()
			set_fps_visible(direction > 0)
			return previous_fps_visible != _fps_visible
		CONTROL_BACKGROUND_MOVABLE_TOGGLE:
			var previous_background_movable := _background_movable
			if previous_background_movable != (direction > 0):
				_play_frontend_activate_sfx()
			set_background_movable(direction > 0)
			return previous_background_movable != _background_movable
		CONTROL_BONUS_STACK_TOGGLE:
			var previous_bonus_stack_visible := _bonus_stack_visible
			if previous_bonus_stack_visible != (direction > 0):
				_play_frontend_activate_sfx()
			set_bonus_stack_visible(direction > 0)
			return previous_bonus_stack_visible != _bonus_stack_visible
		CONTROL_BALL_TRACKS_TOGGLE:
			var previous_ball_tracks_visible := _ball_tracks_visible
			if previous_ball_tracks_visible != (direction > 0):
				_play_frontend_activate_sfx()
			set_ball_tracks_visible(direction > 0)
			return previous_ball_tracks_visible != _ball_tracks_visible
	return false


func _activate_control(control_id: String) -> bool:
	if not _selection_order_for_page(_current_page).has(control_id):
		return false
	match control_id:
		CONTROL_MUSIC_TOGGLE:
			_play_frontend_activate_sfx()
			set_music_enabled(not _music_enabled)
			return true
		CONTROL_SFX_TOGGLE:
			_play_frontend_activate_sfx()
			set_sfx_enabled(not _sfx_enabled)
			return true
		CONTROL_FULLSCREEN_TOGGLE:
			_play_frontend_activate_sfx()
			set_fullscreen_enabled(not _fullscreen_enabled)
			return true
		CONTROL_FPS_TOGGLE:
			_play_frontend_activate_sfx()
			set_fps_visible(not _fps_visible)
			return true
		CONTROL_BACKGROUND_MOVABLE_TOGGLE:
			_play_frontend_activate_sfx()
			set_background_movable(not _background_movable)
			return true
		CONTROL_BONUS_STACK_TOGGLE:
			_play_frontend_activate_sfx()
			set_bonus_stack_visible(not _bonus_stack_visible)
			return true
		CONTROL_BALL_TRACKS_TOGGLE:
			_play_frontend_activate_sfx()
			set_ball_tracks_visible(not _ball_tracks_visible)
			return true
		CONTROL_PAGE_UP:
			return _activate_page_change(_current_page - 1)
		CONTROL_PAGE_DOWN:
			return _activate_page_change(_current_page + 1)
		CONTROL_BACKWARD:
			_play_frontend_activate_sfx()
			back_requested.emit()
			return true
	return false


func _activate_page_change(page_index: int) -> bool:
	if not go_to_page(page_index):
		return false
	_play_frontend_activate_sfx()
	return true


func _play_frontend_select_sfx() -> void:
	_play_sfx_event(AudioCueCatalogScript.SFX_EVENT_FRONTEND_SELECT)


func _play_frontend_activate_sfx() -> void:
	_play_sfx_event(AudioCueCatalogScript.SFX_EVENT_FRONTEND_ACTIVATE)


func _play_sfx_event(event_name: String) -> void:
	var audio := _audio_service()
	if audio == null or not audio.has_method("play_sfx_event"):
		return
	audio.call("play_sfx_event", event_name)


func _handle_volume_shortcut(key_event: InputEventKey) -> bool:
	var is_increase := false
	var is_decrease := false
	match key_event.keycode:
		KEY_KP_ADD:
			is_increase = true
		KEY_KP_SUBTRACT:
			is_decrease = true
		KEY_EQUAL:
			is_increase = key_event.shift_pressed
		KEY_MINUS:
			is_decrease = true
		_:
			return false

	if _current_page != PAGE_AUDIO:
		return false

	if key_event.shift_pressed:
		if is_increase:
			set_sfx_volume(_sfx_volume + 1)
		elif is_decrease:
			set_sfx_volume(_sfx_volume - 1)
	else:
		if is_increase:
			set_music_volume(_music_volume + 1)
		elif is_decrease:
			set_music_volume(_music_volume - 1)
	return true


func _control_at_position(position: Vector2) -> String:
	for control_id in _selection_order_for_page(_current_page):
		if control_hit_rect(String(control_id)).has_point(position):
			return String(control_id)
	return ""


func _is_slider_control(control_id: String) -> bool:
	return (
		control_id == CONTROL_MUSIC_SLIDER
		or control_id == CONTROL_SFX_SLIDER
		or control_id == CONTROL_BACKGROUND_TYPE_SLIDER
	)


func _update_slider_from_mouse(control_id: String, mouse_x: float) -> void:
	match control_id:
		CONTROL_MUSIC_SLIDER:
			set_music_volume(original_audio_volume_for_mouse_x(mouse_x))
		CONTROL_SFX_SLIDER:
			set_sfx_volume(original_audio_volume_for_mouse_x(mouse_x))
		CONTROL_BACKGROUND_TYPE_SLIDER:
			var max_value := PlayfieldRendererScript.BACKGROUND_TYPE_COUNT - 1
			var ratio := clampf(
				(mouse_x - GENERIC_SLIDER_LEFT_X) / GENERIC_SLIDER_SPAN_X,
				0.0,
				1.0
			)
			set_background_type(int(round(ratio * max_value)))


func _presentation_toggle_rect(control_id: String) -> Rect2:
	if not _presentation_row_indices.has(control_id):
		return Rect2(Vector2.ZERO, Vector2.ZERO)
	var row_index := int(_presentation_row_indices[control_id])
	var base_y := float(PRESENTATION_ROW_SPECS[row_index]["base_y"])
	return Rect2(
		Vector2(560, base_y + OptionsVxEffectsScript.STATIC_INDICATOR_Y_OFFSET),
		Vector2(30, 30)
	)


func _utility_toggle_rect(control_id: String) -> Rect2:
	if not _utility_row_indices.has(control_id):
		return Rect2(Vector2.ZERO, Vector2.ZERO)
	var row_index := int(_utility_row_indices[control_id])
	var base_y := float(UTILITY_ROW_SPECS[row_index]["base_y"])
	return Rect2(
		Vector2(560, base_y + OptionsVxEffectsScript.STATIC_INDICATOR_Y_OFFSET),
		Vector2(30, 30)
	)


func _profile_service() -> Node:
	return get_node_or_null("/root/KrakoutProfile")


func _audio_service() -> Node:
	return get_node_or_null("/root/KrakoutAudio")


func _label(
	node_name: String,
	text: String,
	position: Vector2,
	size: Vector2,
	alignment: HorizontalAlignment,
	_font_size: int
):
	var label = MenuBitmapLabelScript.new()
	label.name = node_name
	label.text = text
	label.position = position
	label.size = size
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return label


func _load_asset_texture(texture_name: String) -> Texture2D:
	var assets := get_node_or_null("/root/KrakoutAssets")
	if assets == null or not assets.has_method("load_texture"):
		return null
	return assets.call("load_texture", texture_name) as Texture2D
