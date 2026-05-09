extends Control
class_name EpisodeSelectScreen

signal episode_selected(episode_slug: String, level_number: int)
signal back_requested

const PlayfieldSpecScript := preload("res://src/playfield/krakout_playfield_spec.gd")
const MenuBitmapLabelScript := preload("res://src/menu/krakout_menu_bitmap_label.gd")
const WaveBitmapLabelScript := preload("res://src/menu/krakout_wave_bitmap_label.gd")
const AudioCueCatalogScript := preload("res://src/audio/krakout_audio_cue_catalog.gd")

const PAGE_SIZE := 10
const TITLE_Y := 13
const ROW_START_Y := 100
const ROW_HEIGHT := 30
const HEADER_Y := 60
const PAGE_STATUS_Y := 425
const PAGE_HELP_Y := 450
const ROW_HIT_X := 5
const ROW_HIT_RIGHT_X := 585
const ROW_HIT_WIDTH := ROW_HIT_RIGHT_X - ROW_HIT_X
const ROW_HIT_BOTTOM_Y := 430
const INDEX_X := 5
const TITLE_X := 55
const LEVEL_RIGHT_X := 585
const LEVEL_WIDTH := 50
const LEVEL_X := LEVEL_RIGHT_X - LEVEL_WIDTH
const ROW_WIDTH := 640
const ARROW_FRAME_COUNT := 10
const ARROW_SELECTED_FRAME_GATE_SECONDS := 0.03
const ARROW_RETURN_FRAME_GATE_SECONDS := 0.01
const ARROW_BUTTON_SIZE := Vector2(45, 45)
const UP_ARROW_POSITION := Vector2(590, 100)
const DOWN_ARROW_POSITION := Vector2(590, 350)
const BG_TILE_SIZE := Vector2(48, 48)
const BACKGROUND_SCROLL_STEP_SECONDS := 0.03
const BACKGROUND_PRIMARY_STEP := 1
const BACKGROUND_SECONDARY_STEP := 3
const BACKGROUND_REPEAT_WIDTH := 720
const BACKGROUND_REPEAT_HEIGHT := 528
const SELECTED_TITLE_WAVE_STEP_SECONDS := 0.04
const SELECTED_TITLE_WAVE_STEP_DEGREES := 20.0
const SELECTED_TITLE_WAVE_AMPLITUDE := 5.0

@onready var _header: Control = $Header
@onready var _rows: Control = $Rows
@onready var _up_button: TextureButton = $UpButton
@onready var _down_button: TextureButton = $DownButton
@onready var _page_status = $PageStatus
@onready var _page_help = $PageHelp

var _episodes: Array[Dictionary] = []
var _page_index := 0
var _selected_index := -1
var _background_texture: Texture2D
var _arrow_up_texture: Texture2D
var _arrow_down_texture: Texture2D
var _animation_time := 0.0
var _background_offset_primary := 0
var _background_offset_secondary := 0
var _background_tick := 0.0
var _row_buttons: Array[Button] = []
var _row_labels: Array[Dictionary] = []
var _arrow_texture_cache: Dictionary = {}
var _up_arrow_frame := 0
var _down_arrow_frame := 0
var _up_arrow_hovered := false
var _down_arrow_hovered := false
var _up_arrow_selected_elapsed := 0.0
var _up_arrow_return_elapsed := 0.0
var _down_arrow_selected_elapsed := 0.0
var _down_arrow_return_elapsed := 0.0
var _selected_title_wave_label
var _selected_title_wave_elapsed := 0.0
var _selected_title_wave_phase_degrees := 0.0


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_fit_to_baseline_viewport()
	_load_assets()
	_configure_static_nodes()
	_load_episodes()
	_rebuild_rows()
	_update_selection_for_page()
	_update_page_controls()
	_update_arrow_frames()
	call_deferred("_focus_selected_row")


func _process(delta: float) -> void:
	_animation_time += delta
	advance_background_animation(delta)
	_advance_arrow_animation(delta)
	_update_arrow_frames()
	_advance_selected_title_wave(delta)


func _draw() -> void:
	if _background_texture == null:
		return

	_draw_background_layer(primary_background_source_rect(), _background_offset_primary)
	_draw_background_layer(secondary_background_source_rect(), _background_offset_secondary)


func _draw_background_layer(source_rect: Rect2, offset: int) -> void:
	for tile_x in range(0, BACKGROUND_REPEAT_WIDTH, int(BG_TILE_SIZE.x)):
		for tile_y in range(0, BACKGROUND_REPEAT_HEIGHT, int(BG_TILE_SIZE.y)):
			var tile_origin := Vector2(tile_x, tile_y)
			draw_texture_rect_region(_background_texture, background_target_rect(tile_origin, offset), source_rect)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		back_requested.emit()
		get_viewport().set_input_as_handled()
		return

	var key_event := event as InputEventKey
	if key_event == null or not key_event.pressed or key_event.echo:
		return

	match key_event.keycode:
		KEY_PAGEUP:
			_change_page(_page_index - 1, true)
			get_viewport().set_input_as_handled()
		KEY_PAGEDOWN:
			_change_page(_page_index + 1, true)
			get_viewport().set_input_as_handled()
		KEY_UP:
			_select_relative(-1)
			get_viewport().set_input_as_handled()
		KEY_DOWN:
			_select_relative(1)
			get_viewport().set_input_as_handled()
		KEY_ENTER, KEY_KP_ENTER, KEY_SPACE:
			_activate_selected_episode()
			get_viewport().set_input_as_handled()
		KEY_ESCAPE:
			back_requested.emit()
			get_viewport().set_input_as_handled()


func episode_count() -> int:
	return _episodes.size()


func current_page() -> int:
	return _page_index


func page_count() -> int:
	if _episodes.is_empty():
		return 1
	return int(ceil(float(_episodes.size()) / float(PAGE_SIZE)))


func visible_row_count() -> int:
	return _row_buttons.size()


func selected_episode_summary() -> Dictionary:
	if _selected_index < 0 or _selected_index >= _episodes.size():
		return {}
	return _episodes[_selected_index].duplicate()


func selected_title_wave_phase_degrees() -> float:
	return _selected_title_wave_phase_degrees


func reset_selected_title_wave_for_test() -> void:
	_selected_title_wave_elapsed = 0.0
	_selected_title_wave_phase_degrees = 0.0
	_sync_selected_title_wave()


func background_offsets() -> Dictionary:
	return {
		"primary": _background_offset_primary,
		"secondary": _background_offset_secondary,
	}


func reset_background_animation_for_test() -> void:
	_background_offset_primary = 0
	_background_offset_secondary = 0
	_background_tick = 0.0
	queue_redraw()


func advance_background_animation(delta: float) -> void:
	if delta <= 0.0:
		return

	_background_tick += delta
	if _background_tick > BACKGROUND_SCROLL_STEP_SECONDS:
		_background_tick = 0.0
		_background_offset_primary = (_background_offset_primary + BACKGROUND_PRIMARY_STEP) % int(BG_TILE_SIZE.x)
		_background_offset_secondary = (_background_offset_secondary + BACKGROUND_SECONDARY_STEP) % int(BG_TILE_SIZE.x)
		queue_redraw()


static func primary_background_target_rect(tile_origin: Vector2, offset: int) -> Rect2:
	return background_target_rect(tile_origin, offset)


static func secondary_background_target_rect(tile_origin: Vector2, offset: int) -> Rect2:
	return background_target_rect(tile_origin, offset)


static func background_target_rect(tile_origin: Vector2, offset: int) -> Rect2:
	var shifted_offset := float(offset - int(BG_TILE_SIZE.x))
	return Rect2(tile_origin + Vector2(shifted_offset, shifted_offset), BG_TILE_SIZE)


static func primary_background_source_rect() -> Rect2:
	return Rect2(Vector2.ZERO, BG_TILE_SIZE)


static func secondary_background_source_rect() -> Rect2:
	return Rect2(Vector2(BG_TILE_SIZE.x, 0), BG_TILE_SIZE)


func _fit_to_baseline_viewport() -> void:
	custom_minimum_size = Vector2(PlayfieldSpecScript.VIEWPORT_SIZE)


func _load_assets() -> void:
	_background_texture = _load_asset_texture("BgEpisode")
	_arrow_up_texture = _load_asset_texture("Arrowup")
	_arrow_down_texture = _load_asset_texture("Arrowdown")


func _configure_static_nodes() -> void:
	_configure_label(_label("BrowserTitle", "Episode Browser. Select Episode.", Vector2(0, TITLE_Y), Vector2(640, ROW_HEIGHT), HORIZONTAL_ALIGNMENT_CENTER))
	_configure_label(_label("IndexHeader", "#", Vector2(INDEX_X, HEADER_Y), Vector2(40, ROW_HEIGHT), HORIZONTAL_ALIGNMENT_LEFT))
	_configure_label(_label("TitleHeader", "Episode name", Vector2(TITLE_X, HEADER_Y), Vector2(420, ROW_HEIGHT), HORIZONTAL_ALIGNMENT_LEFT))
	_configure_label(_label("LevelHeader", "Lev", Vector2(LEVEL_X, HEADER_Y), Vector2(50, ROW_HEIGHT), HORIZONTAL_ALIGNMENT_RIGHT))

	_up_button.position = UP_ARROW_POSITION
	_up_button.size = ARROW_BUTTON_SIZE
	_up_button.custom_minimum_size = ARROW_BUTTON_SIZE
	_up_button.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_up_button.ignore_texture_size = false
	_up_button.stretch_mode = TextureButton.STRETCH_KEEP
	_disable_native_button_chrome(_up_button)
	_up_button.mouse_entered.connect(_set_up_arrow_hovered.bind(true))
	_up_button.mouse_exited.connect(_set_up_arrow_hovered.bind(false))
	_up_button.pressed.connect(_on_up_button_pressed)

	_down_button.position = DOWN_ARROW_POSITION
	_down_button.size = ARROW_BUTTON_SIZE
	_down_button.custom_minimum_size = ARROW_BUTTON_SIZE
	_down_button.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_down_button.ignore_texture_size = false
	_down_button.stretch_mode = TextureButton.STRETCH_KEEP
	_disable_native_button_chrome(_down_button)
	_down_button.mouse_entered.connect(_set_down_arrow_hovered.bind(true))
	_down_button.mouse_exited.connect(_set_down_arrow_hovered.bind(false))
	_down_button.pressed.connect(_on_down_button_pressed)

	_configure_label(_page_status)
	_page_status.position = Vector2(0, PAGE_STATUS_Y)
	_page_status.size = Vector2(640, ROW_HEIGHT)
	_page_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	_configure_label(_page_help)
	_page_help.position = Vector2(0, PAGE_HELP_Y)
	_page_help.size = Vector2(640, ROW_HEIGHT)
	_page_help.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_page_help.text = "Use PgUp / PgDn."

	_build_selected_title_wave_overlay()


func _label(label_name: String, text: String, label_position: Vector2, label_size: Vector2, alignment: HorizontalAlignment):
	var label = _header.get_node_or_null(label_name)
	if label == null:
		label = MenuBitmapLabelScript.new()
		label.name = label_name
		_header.add_child(label)
	label.text = text
	label.position = label_position
	label.size = label_size
	label.horizontal_alignment = alignment
	return label


func _configure_label(label) -> void:
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER


func _disable_native_button_chrome(button: BaseButton) -> void:
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	if button is Button:
		var empty_style := StyleBoxEmpty.new()
		for style_name: String in ["normal", "hover", "pressed", "disabled", "focus"]:
			button.add_theme_stylebox_override(style_name, empty_style)


func _load_episodes() -> void:
	_episodes.clear()
	var levels := get_node_or_null("/root/KrakoutLevels")
	if levels == null or not levels.has_method("episode_summaries"):
		return

	for summary: Dictionary in levels.call("episode_summaries"):
		_episodes.append(summary.duplicate())


func _rebuild_rows() -> void:
	for child in _rows.get_children():
		child.queue_free()
	_row_buttons.clear()
	_row_labels.clear()

	var first_index: int = _page_index * PAGE_SIZE
	var final_index: int = int(min(first_index + PAGE_SIZE, _episodes.size()))
	for episode_index in range(first_index, final_index):
		var row_offset := episode_index - first_index
		var row := Control.new()
		row.name = "EpisodeRow%d" % (row_offset + 1)
		row.position = Vector2(0, ROW_START_Y + row_offset * ROW_HEIGHT)
		row.size = Vector2(ROW_WIDTH, ROW_HEIGHT)
		_rows.add_child(row)

		var hit_area := Button.new()
		hit_area.name = "EpisodeRowButton%d" % (row_offset + 1)
		hit_area.position = Vector2(ROW_HIT_X, 0)
		hit_area.size = Vector2(ROW_HIT_WIDTH, ROW_HEIGHT)
		hit_area.flat = true
		_disable_native_button_chrome(hit_area)
		hit_area.mouse_entered.connect(_select_episode.bind(episode_index))
		hit_area.pressed.connect(_activate_episode.bind(episode_index))
		row.add_child(hit_area)
		_row_buttons.append(hit_area)

		var index_label = _row_label("Index", str(episode_index + 1), Vector2(INDEX_X, 0), Vector2(40, ROW_HEIGHT), HORIZONTAL_ALIGNMENT_LEFT)
		var title_label = _row_label("Title", String(_episodes[episode_index].get("title", "")), Vector2(TITLE_X, 0), Vector2(420, ROW_HEIGHT), HORIZONTAL_ALIGNMENT_LEFT)
		var level_label = _row_label("LevelCount", str(int(_episodes[episode_index].get("level_count", 0))), Vector2(LEVEL_X, 0), Vector2(LEVEL_WIDTH, ROW_HEIGHT), HORIZONTAL_ALIGNMENT_RIGHT)
		row.add_child(index_label)
		row.add_child(title_label)
		row.add_child(level_label)
		_row_labels.append({
			"episode_index": episode_index,
			"labels": [index_label, title_label, level_label],
		})


func _row_label(label_name: String, text: String, label_position: Vector2, label_size: Vector2, alignment: HorizontalAlignment):
	var label = MenuBitmapLabelScript.new()
	label.name = label_name
	label.text = text
	label.position = label_position
	label.size = label_size
	label.horizontal_alignment = alignment
	_configure_label(label)
	return label


func _update_selection_for_page() -> bool:
	if _episodes.is_empty():
		_selected_index = -1
		return false

	var first_index: int = _page_index * PAGE_SIZE
	var final_index: int = int(min(first_index + PAGE_SIZE, _episodes.size())) - 1
	var previous_index := _selected_index
	if _selected_index < first_index or _selected_index > final_index:
		_selected_index = first_index
	_update_row_styles()
	return previous_index != _selected_index


func _update_page_controls() -> void:
	var total_pages := page_count()
	_page_status.text = "Episodes: %d. Page %d from %d." % [_episodes.size(), _page_index + 1, total_pages]
	_page_help.visible = total_pages > 1
	_up_button.visible = _page_index > 0
	_up_button.disabled = _page_index <= 0
	_down_button.visible = _page_index < total_pages - 1
	_down_button.disabled = _page_index >= total_pages - 1
	if not _up_button.visible:
		_set_up_arrow_hovered(false)
		_up_arrow_frame = 0
	if not _down_button.visible:
		_set_down_arrow_hovered(false)
		_down_arrow_frame = 0


func _update_arrow_frames() -> void:
	_apply_arrow_texture(_up_button, _arrow_up_texture, _up_arrow_frame)
	_apply_arrow_texture(_down_button, _arrow_down_texture, _down_arrow_frame)


func _apply_arrow_texture(button: TextureButton, texture: Texture2D, frame: int) -> void:
	if button == null or texture == null:
		return

	var atlas_texture := _arrow_frame_texture(texture, frame)
	button.texture_normal = atlas_texture
	button.texture_hover = atlas_texture
	button.texture_pressed = atlas_texture
	button.texture_focused = atlas_texture


func _arrow_frame_texture(texture: Texture2D, frame: int) -> AtlasTexture:
	var cache_key := "%d:%d" % [texture.get_instance_id(), frame]
	if _arrow_texture_cache.has(cache_key):
		return _arrow_texture_cache[cache_key] as AtlasTexture

	var atlas_texture := AtlasTexture.new()
	atlas_texture.atlas = texture
	atlas_texture.region = Rect2(Vector2(frame * ARROW_BUTTON_SIZE.x, 0), ARROW_BUTTON_SIZE)
	_arrow_texture_cache[cache_key] = atlas_texture
	return atlas_texture


func up_arrow_frame() -> int:
	return _up_arrow_frame


func down_arrow_frame() -> int:
	return _down_arrow_frame


static func up_arrow_hit_rect() -> Rect2:
	return Rect2(UP_ARROW_POSITION, ARROW_BUTTON_SIZE)


static func down_arrow_hit_rect() -> Rect2:
	return Rect2(DOWN_ARROW_POSITION, ARROW_BUTTON_SIZE)


static func episode_row_hit_rect() -> Rect2:
	return Rect2(Vector2(ROW_HIT_X, ROW_START_Y), Vector2(ROW_HIT_WIDTH, ROW_HIT_BOTTOM_Y - ROW_START_Y))


func _set_up_arrow_hovered(is_hovered: bool) -> void:
	_up_arrow_hovered = is_hovered and _up_button.visible and not _up_button.disabled


func _set_down_arrow_hovered(is_hovered: bool) -> void:
	_down_arrow_hovered = is_hovered and _down_button.visible and not _down_button.disabled


func _advance_arrow_animation(delta: float) -> void:
	_advance_single_arrow(
		delta,
		_up_arrow_hovered,
		func() -> int:
			return _up_arrow_frame,
		func(frame: int) -> void:
			_up_arrow_frame = frame,
		func() -> float:
			return _up_arrow_selected_elapsed,
		func(value: float) -> void:
			_up_arrow_selected_elapsed = value,
		func() -> float:
			return _up_arrow_return_elapsed,
		func(value: float) -> void:
			_up_arrow_return_elapsed = value
	)
	_advance_single_arrow(
		delta,
		_down_arrow_hovered,
		func() -> int:
			return _down_arrow_frame,
		func(frame: int) -> void:
			_down_arrow_frame = frame,
		func() -> float:
			return _down_arrow_selected_elapsed,
		func(value: float) -> void:
			_down_arrow_selected_elapsed = value,
		func() -> float:
			return _down_arrow_return_elapsed,
		func(value: float) -> void:
			_down_arrow_return_elapsed = value
	)


func _advance_single_arrow(
	delta: float,
	is_hovered: bool,
	get_frame: Callable,
	set_frame: Callable,
	get_selected_elapsed: Callable,
	set_selected_elapsed: Callable,
	get_return_elapsed: Callable,
	set_return_elapsed: Callable
) -> void:
	if delta <= 0.0:
		return

	var frame: int = int(get_frame.call())
	if is_hovered:
		set_return_elapsed.call(0.0)
		var selected_elapsed := float(get_selected_elapsed.call()) + delta
		if selected_elapsed > ARROW_SELECTED_FRAME_GATE_SECONDS:
			selected_elapsed = 0.0
			frame = (frame + 1) % ARROW_FRAME_COUNT
			set_frame.call(frame)
		set_selected_elapsed.call(selected_elapsed)
		return

	set_selected_elapsed.call(0.0)
	if frame == 0:
		set_return_elapsed.call(0.0)
		return

	var return_elapsed := float(get_return_elapsed.call()) + delta
	if return_elapsed > ARROW_RETURN_FRAME_GATE_SECONDS:
		return_elapsed = 0.0
		frame = (frame + 1) % ARROW_FRAME_COUNT
		set_frame.call(frame)
	set_return_elapsed.call(return_elapsed)


func _advance_selected_title_wave(delta: float) -> void:
	if delta <= 0.0:
		return

	_selected_title_wave_elapsed += delta
	if _selected_title_wave_elapsed > SELECTED_TITLE_WAVE_STEP_SECONDS:
		_selected_title_wave_elapsed = 0.0
		_selected_title_wave_phase_degrees = fposmod(
			_selected_title_wave_phase_degrees + SELECTED_TITLE_WAVE_STEP_DEGREES,
			360.0
		)
		_sync_selected_title_wave()


func _select_episode(episode_index: int) -> void:
	if episode_index < 0 or episode_index >= _episodes.size():
		return
	if _selected_index == episode_index:
		return
	_selected_index = episode_index
	_play_sfx_event(AudioCueCatalogScript.SFX_EVENT_EPISODE_SELECT)
	_update_row_styles()


func _select_relative(offset: int) -> void:
	if _episodes.is_empty():
		return

	var next_index: int = int(clamp(_selected_index + offset, 0, _episodes.size() - 1))
	if next_index == _selected_index:
		return

	_selected_index = next_index
	var next_page: int = int(_selected_index / PAGE_SIZE)
	if next_page != _page_index:
		_change_page(next_page, true)
	else:
		_play_sfx_event(AudioCueCatalogScript.SFX_EVENT_EPISODE_SELECT)
		_update_row_styles()
		_focus_selected_row()


func _change_page(next_page: int, play_select_sfx := false) -> void:
	var clamped_page: int = int(clamp(next_page, 0, page_count() - 1))
	if clamped_page == _page_index:
		return

	_page_index = clamped_page
	_rebuild_rows()
	var selection_changed := _update_selection_for_page()
	if play_select_sfx and selection_changed:
		_play_sfx_event(AudioCueCatalogScript.SFX_EVENT_EPISODE_SELECT)
	_update_page_controls()
	_update_arrow_frames()
	call_deferred("_focus_selected_row")


func _on_up_button_pressed() -> void:
	_change_page(_page_index - 1, true)


func _on_down_button_pressed() -> void:
	_change_page(_page_index + 1, true)


func _focus_selected_row() -> void:
	var row_offset := _selected_index - _page_index * PAGE_SIZE
	if row_offset < 0 or row_offset >= _row_buttons.size():
		return
	if _row_buttons[row_offset].focus_mode == Control.FOCUS_NONE:
		return
	_row_buttons[row_offset].grab_focus()


func _update_row_styles() -> void:
	_sync_selected_title_wave()


func _build_selected_title_wave_overlay() -> void:
	if _selected_title_wave_label != null:
		return

	_selected_title_wave_label = WaveBitmapLabelScript.new()
	_selected_title_wave_label.name = "SelectedEpisodeTitleWave"
	_selected_title_wave_label.position = Vector2(TITLE_X, ROW_START_Y - SELECTED_TITLE_WAVE_AMPLITUDE)
	_selected_title_wave_label.size = Vector2(420, ROW_HEIGHT + SELECTED_TITLE_WAVE_AMPLITUDE * 2.0)
	_selected_title_wave_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_selected_title_wave_label.wave_amplitude = SELECTED_TITLE_WAVE_AMPLITUDE
	_selected_title_wave_label.visible = false
	_selected_title_wave_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_selected_title_wave_label)


func _sync_selected_title_wave() -> void:
	if _selected_title_wave_label == null:
		return

	var selected_row_offset := _selected_index - _page_index * PAGE_SIZE
	var show_wave := selected_row_offset >= 0 and selected_row_offset < _row_labels.size()
	for row_data: Dictionary in _row_labels:
		var labels: Array = row_data.get("labels", [])
		if labels.size() < 2:
			continue
		var title_label = labels[1]
		if title_label != null:
			title_label.visible = not show_wave or int(row_data.get("episode_index", -1)) != _selected_index

	_selected_title_wave_label.visible = show_wave
	if not show_wave:
		return

	var selected_summary := _episodes[_selected_index]
	_selected_title_wave_label.text = String(selected_summary.get("title", ""))
	_selected_title_wave_label.position = Vector2(
		TITLE_X,
		ROW_START_Y + selected_row_offset * ROW_HEIGHT - SELECTED_TITLE_WAVE_AMPLITUDE
	)
	_selected_title_wave_label.phase_degrees = _selected_title_wave_phase_degrees


func _activate_selected_episode() -> void:
	_activate_episode(_selected_index)


func _activate_episode(episode_index: int) -> void:
	if episode_index < 0 or episode_index >= _episodes.size():
		return

	var summary: Dictionary = _episodes[episode_index]
	_play_sfx_event(AudioCueCatalogScript.SFX_EVENT_EPISODE_ACTIVATE)
	episode_selected.emit(
		String(summary.get("slug", "")),
		int(summary.get("first_level_number", 1))
	)


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
