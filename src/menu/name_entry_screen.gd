extends Control
class_name NameEntryScreen

signal score_submitted(player_name: String, score: int, level_number: int, episode_slug: String)
signal cancel_requested

const PlayfieldSpecScript := preload("res://src/playfield/krakout_playfield_spec.gd")
const ProfileScript := preload("res://src/autoloads/krakout_profile.gd")
const MenuBitmapLabelScript := preload("res://src/menu/krakout_menu_bitmap_label.gd")

const BACKGROUND_TILE_SIZE := Vector2(48, 48)
const BACKGROUND_SCROLL_STEP_SECONDS := 0.03
const BACKGROUND_PRIMARY_STEP := 1
const BACKGROUND_SECONDARY_STEP := 3
const BACKGROUND_REPEAT_WIDTH := 720
const BACKGROUND_REPEAT_HEIGHT := 528
const NAME_CURSOR_BLINK_SECONDS := 0.4
const PROMPT_TEXT := "Enter your name, please:"
const BACKSPACE_HINT_TEXT := "Use 'Backspace' key for edit."
const ENTER_HINT_TEXT := "Use 'Enter' key for confirm."
const PROMPT_POSITION := Vector2(0, 5)
const NAME_POSITION := Vector2(5, 215)
const BACKSPACE_HINT_POSITION := Vector2(0, 430)
const ENTER_HINT_POSITION := Vector2(0, 455)
const FULL_WIDTH_LABEL_SIZE := Vector2(640, 28)
const NAME_LABEL_SIZE := Vector2(630, 28)
const NAME_MAX_LENGTH := ProfileScript.MAX_PLAYER_NAME_LENGTH

var score := 0
var level_number := 1
var episode_slug := ""
var episode_title := ""

var _player_name := ""
var _background_texture: Texture2D
var _prompt_label
var _name_label
var _backspace_hint_label
var _enter_hint_label
var _background_primary_offset := 0
var _background_secondary_offset := 0
var _background_elapsed := 0.0
var _name_cursor_elapsed := 0.0
var _name_cursor_visible := true


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	custom_minimum_size = Vector2(PlayfieldSpecScript.VIEWPORT_SIZE)
	_background_texture = _load_asset_texture("BgGetName")
	_build_scene()
	refresh_content()


func _process(delta: float) -> void:
	advance(delta)


func _draw() -> void:
	if _background_texture == null:
		return

	_draw_primary_background_layer()
	_draw_secondary_background_layer()


func _draw_primary_background_layer() -> void:
	for tile_x in range(0, BACKGROUND_REPEAT_WIDTH, int(BACKGROUND_TILE_SIZE.x)):
		for tile_y in range(0, BACKGROUND_REPEAT_HEIGHT, int(BACKGROUND_TILE_SIZE.y)):
			var tile_origin := Vector2(tile_x, tile_y)
			draw_texture_rect_region(
				_background_texture,
				primary_background_target_rect(tile_origin, _background_primary_offset),
				primary_background_source_rect()
			)


func _draw_secondary_background_layer() -> void:
	for tile_x in range(0, BACKGROUND_REPEAT_WIDTH, int(BACKGROUND_TILE_SIZE.x)):
		for tile_y in range(0, BACKGROUND_REPEAT_HEIGHT, int(BACKGROUND_TILE_SIZE.y)):
			var tile_origin := Vector2(tile_x, tile_y)
			draw_texture_rect_region(
				_background_texture,
				secondary_background_target_rect(tile_origin, _background_secondary_offset),
				secondary_background_source_rect()
			)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		cancel_requested.emit()
		get_viewport().set_input_as_handled()
		return

	var key_event := event as InputEventKey
	if key_event == null or not key_event.pressed or key_event.echo:
		return

	match key_event.keycode:
		KEY_ENTER, KEY_KP_ENTER:
			submit_name()
			get_viewport().set_input_as_handled()
		KEY_BACKSPACE:
			backspace_name()
			get_viewport().set_input_as_handled()
		_:
			if key_event.unicode >= 32 and key_event.unicode != 127:
				append_character(String.chr(key_event.unicode))
				get_viewport().set_input_as_handled()


func configure(score_value: int, reached_level: int, selected_episode_slug: String, selected_episode_title := "") -> void:
	score = maxi(0, score_value)
	level_number = maxi(1, reached_level)
	episode_slug = selected_episode_slug
	episode_title = selected_episode_title
	refresh_content()


func set_player_name(value: String) -> void:
	_player_name = value.strip_edges()
	if _player_name.length() > NAME_MAX_LENGTH:
		_player_name = _player_name.substr(0, NAME_MAX_LENGTH)
	refresh_content()


func current_player_name() -> String:
	return _player_name


func append_character(character: String) -> void:
	if character.is_empty() or _player_name.length() >= NAME_MAX_LENGTH:
		return
	_player_name += character.substr(0, 1)
	refresh_content()


func backspace_name() -> void:
	if _player_name.is_empty():
		return
	_player_name = _player_name.substr(0, _player_name.length() - 1)
	refresh_content()


func submitted_player_name() -> String:
	var normalized_name := _player_name.strip_edges()
	if normalized_name.is_empty():
		return ProfileScript.DEFAULT_PLAYER_NAME
	return normalized_name


func submit_name() -> void:
	score_submitted.emit(submitted_player_name(), score, level_number, episode_slug)


func advance(delta: float) -> void:
	if delta <= 0.0:
		return

	_background_elapsed += delta
	if _background_elapsed > BACKGROUND_SCROLL_STEP_SECONDS:
		_background_elapsed = 0.0
		_background_primary_offset = (_background_primary_offset + BACKGROUND_PRIMARY_STEP) % int(BACKGROUND_TILE_SIZE.x)
		_background_secondary_offset = (_background_secondary_offset + BACKGROUND_SECONDARY_STEP) % int(BACKGROUND_TILE_SIZE.x)
		queue_redraw()

	_name_cursor_elapsed += delta
	if _name_cursor_elapsed > NAME_CURSOR_BLINK_SECONDS:
		_name_cursor_elapsed = 0.0
		_name_cursor_visible = not _name_cursor_visible
		refresh_content()


func reset_original_state() -> void:
	_background_primary_offset = 0
	_background_secondary_offset = 0
	_background_elapsed = 0.0
	_name_cursor_elapsed = 0.0
	_name_cursor_visible = true
	refresh_content()
	queue_redraw()


func background_offsets() -> Dictionary:
	return {
		"primary": _background_primary_offset,
		"secondary": _background_secondary_offset,
	}


func name_cursor_visible() -> bool:
	return _name_cursor_visible


func name_display_text() -> String:
	if _name_label == null:
		return _visible_name_text()
	return String(_name_label.text)


static func primary_background_source_rect() -> Rect2:
	return Rect2(Vector2.ZERO, BACKGROUND_TILE_SIZE)


static func secondary_background_source_rect() -> Rect2:
	return Rect2(Vector2(BACKGROUND_TILE_SIZE.x, 0), BACKGROUND_TILE_SIZE)


static func primary_background_target_rect(tile_origin: Vector2, offset: int) -> Rect2:
	return Rect2(tile_origin + Vector2(0, float(offset - int(BACKGROUND_TILE_SIZE.y))), BACKGROUND_TILE_SIZE)


static func secondary_background_target_rect(tile_origin: Vector2, offset: int) -> Rect2:
	var shifted_offset := float(offset - int(BACKGROUND_TILE_SIZE.x))
	return Rect2(tile_origin + Vector2(shifted_offset, shifted_offset), BACKGROUND_TILE_SIZE)


func refresh_content() -> void:
	if _prompt_label != null:
		_prompt_label.text = PROMPT_TEXT
	if _name_label != null:
		_name_label.text = _visible_name_text()
	if _backspace_hint_label != null:
		_backspace_hint_label.text = BACKSPACE_HINT_TEXT
	if _enter_hint_label != null:
		_enter_hint_label.text = ENTER_HINT_TEXT


func _build_scene() -> void:
	if _prompt_label != null:
		return

	_prompt_label = _make_label("PromptLabel", PROMPT_POSITION, FULL_WIDTH_LABEL_SIZE, HORIZONTAL_ALIGNMENT_CENTER)
	add_child(_prompt_label)

	_name_label = _make_label("NameLabel", NAME_POSITION, NAME_LABEL_SIZE, HORIZONTAL_ALIGNMENT_CENTER)
	add_child(_name_label)

	_backspace_hint_label = _make_label("BackspaceHintLabel", BACKSPACE_HINT_POSITION, FULL_WIDTH_LABEL_SIZE, HORIZONTAL_ALIGNMENT_CENTER)
	add_child(_backspace_hint_label)

	_enter_hint_label = _make_label("EnterHintLabel", ENTER_HINT_POSITION, FULL_WIDTH_LABEL_SIZE, HORIZONTAL_ALIGNMENT_CENTER)
	add_child(_enter_hint_label)


func _make_label(label_name: String, label_position: Vector2, label_size: Vector2, alignment: HorizontalAlignment):
	var label = MenuBitmapLabelScript.new()
	label.name = label_name
	label.position = label_position
	label.size = label_size
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return label


func _visible_name_text() -> String:
	var suffix := "_" if _name_cursor_visible else " "
	return _player_name + suffix


func _load_asset_texture(texture_name: String) -> Texture2D:
	var assets := get_node_or_null("/root/KrakoutAssets")
	if assets == null or not assets.has_method("load_texture"):
		return null
	return assets.call("load_texture", texture_name) as Texture2D
