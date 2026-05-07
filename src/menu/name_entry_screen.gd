extends Control
class_name NameEntryScreen

signal score_submitted(player_name: String, score: int, level_number: int, episode_slug: String)
signal cancel_requested

const PlayfieldSpecScript := preload("res://src/playfield/krakout_playfield_spec.gd")
const ProfileScript := preload("res://src/autoloads/krakout_profile.gd")
const MenuBitmapLabelScript := preload("res://src/menu/krakout_menu_bitmap_label.gd")

const BACKGROUND_TILE_SIZE := Vector2(96, 48)
const NAME_MAX_LENGTH := ProfileScript.MAX_PLAYER_NAME_LENGTH

var score := 0
var level_number := 1
var episode_slug := ""
var episode_title := ""

var _player_name := ""
var _background_texture: Texture2D
var _prompt_label
var _summary_label
var _name_label
var _hint_label
var _submit_button: Button
var _cancel_button: Button


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	custom_minimum_size = Vector2(PlayfieldSpecScript.VIEWPORT_SIZE)
	_background_texture = _load_asset_texture("BgGetName")
	_build_scene()
	refresh_content()


func _draw() -> void:
	if _background_texture == null:
		return

	var viewport_size := Vector2(PlayfieldSpecScript.VIEWPORT_SIZE)
	var source_rect := Rect2(Vector2.ZERO, BACKGROUND_TILE_SIZE)
	for y in range(0, int(viewport_size.y), int(BACKGROUND_TILE_SIZE.y)):
		for x in range(0, int(viewport_size.x), int(BACKGROUND_TILE_SIZE.x)):
			draw_texture_rect_region(_background_texture, Rect2(Vector2(x, y), BACKGROUND_TILE_SIZE), source_rect)


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


func refresh_content() -> void:
	if _prompt_label != null:
		_prompt_label.text = "Enter your name, please:"
	if _summary_label != null:
		_summary_label.text = "Your Level #%d, and Score %d" % [level_number, score]
	if _name_label != null:
		var visible_name := _player_name
		if visible_name.is_empty():
			visible_name = "_"
		else:
			visible_name += "_"
		_name_label.text = visible_name
	if _hint_label != null:
		_hint_label.text = "Use 'Enter' key for confirm.\nUse 'Backspace' key for edit."


func _build_scene() -> void:
	if _prompt_label != null:
		return

	_summary_label = _make_label("ScoreSummary", Vector2(0, 120), Vector2(640, 28), HORIZONTAL_ALIGNMENT_CENTER, 18)
	add_child(_summary_label)

	_prompt_label = _make_label("PromptLabel", Vector2(0, 160), Vector2(640, 28), HORIZONTAL_ALIGNMENT_CENTER, 18)
	add_child(_prompt_label)

	_name_label = _make_label("NameLabel", Vector2(170, 205), Vector2(300, 40), HORIZONTAL_ALIGNMENT_CENTER, 24)
	add_child(_name_label)

	_hint_label = _make_label("HintLabel", Vector2(0, 270), Vector2(640, 64), HORIZONTAL_ALIGNMENT_CENTER, 16)
	_hint_label.line_spacing = 0
	add_child(_hint_label)

	_submit_button = Button.new()
	_submit_button.name = "SubmitButton"
	_submit_button.text = ""
	_submit_button.position = Vector2(225, 390)
	_submit_button.size = Vector2(82, 34)
	_submit_button.focus_mode = Control.FOCUS_ALL
	_submit_button.pressed.connect(submit_name)
	add_child(_submit_button)
	_submit_button.add_child(_button_label("SubmitButtonLabel", _submit_button.size, "OK"))

	_cancel_button = Button.new()
	_cancel_button.name = "CancelButton"
	_cancel_button.text = ""
	_cancel_button.position = Vector2(333, 390)
	_cancel_button.size = Vector2(82, 34)
	_cancel_button.focus_mode = Control.FOCUS_ALL
	_cancel_button.pressed.connect(func() -> void: cancel_requested.emit())
	add_child(_cancel_button)
	_cancel_button.add_child(_button_label("CancelButtonLabel", _cancel_button.size, "Back"))


func _make_label(label_name: String, label_position: Vector2, label_size: Vector2, alignment: HorizontalAlignment, _font_size: int):
	var label = MenuBitmapLabelScript.new()
	label.name = label_name
	label.position = label_position
	label.size = label_size
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return label


func _button_label(label_name: String, label_size: Vector2, text_value: String):
	var label = MenuBitmapLabelScript.new()
	label.name = label_name
	label.position = Vector2.ZERO
	label.size = label_size
	label.text = text_value
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return label


func _load_asset_texture(texture_name: String) -> Texture2D:
	var assets := get_node_or_null("/root/KrakoutAssets")
	if assets == null or not assets.has_method("load_texture"):
		return null
	return assets.call("load_texture", texture_name) as Texture2D
