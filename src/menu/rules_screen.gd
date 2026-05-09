extends "res://src/menu/static_menu_screen.gd"
class_name RulesScreen

const GameSessionScript := preload("res://src/gameplay/krakout_game_session.gd")

const ORIGINAL_TITLE := "Game Rules"
const ORIGINAL_RULES_HEADING := "--==| | Game Rules and Keys | |==--"
const ORIGINAL_SCROLL_HINT := "Use Up/Down/PgUp/PgDn to scroll."
const ORIGINAL_OVERVIEW_HEADING := "-=| Game Overview |=-"
const ORIGINAL_KEY_HEADING := "-=| Keys used in Game |=-"
const ORIGINAL_BONUS_HEADING := "-=| Bonuses |=-"
const ORIGINAL_OVERVIEW_LINES := [
	"Control Racket with Mouse and let",
	"ball(s) to destroy all bricks.",
	"Catch bonuses to get special",
	"abilities. Eliminate enemy and",
	"get additional scores.",
]
const ORIGINAL_KEY_LINES := [
	"<Tab> - Show/Hide Bonuses.",
	"<Ctrl> + <T> - Show/Hide Balls Tracks.",
	"<Space> - Use Bonus.",
	"<P> - Pause Game.",
	"<Esc> - Terminate Game.",
	"<G> - Change/Hide Backround Type.",
	"<Shift> + <G> - Stop/Start Backround.",
	"<F5> - Show/Hide FPS.",
	"<F7> - On/Off Music.",
	"<F8> - On/Off Sfx.",
	"<Alt> + <Enter> - Switch Screen mode.",
	"<Ctrl> + <U> - Release cursor.",
	"<+/-> - Music volume.",
	"<Shift> + <+/-> - SFX volume.",
]

const TITLE_POSITION := Vector2(0, 20)
const TITLE_SIZE := Vector2(640, 24)
const HINT_POSITION := Vector2(0, 445)
const HINT_SIZE := Vector2(640, 24)
const VIEW_POSITION := Vector2(0, 50)
const VIEW_SIZE := Vector2(640, 385)
const BACK_POSITION := Vector2(539, 379)
const SECTION_LABEL_SIZE := Vector2(640, 24)
const BODY_LABEL_SIZE := Vector2(640, 24)
const KEY_LABEL_SIZE := Vector2(640, 24)
const BONUS_LABEL_SIZE := Vector2(560, 24)
const BONUS_ICON_SIZE := Vector2(32, 32)
const LINE_STEP := 25.0
const SECTION_GAP := 80.0
const BONUS_ROW_HEIGHT := 36.0
const BONUS_ICON_X := 30.0
const BONUS_LABEL_X := 50.0
const SCROLL_LINE_PIXELS := 3.0
const PAGE_SCROLL_PIXELS := 400.0
const ORIGINAL_SCROLL_TOP_Y := 50.0
const ORIGINAL_SCROLL_BOTTOM_Y := -1090.0
const BONUS_ICON_FRAME_COUNT := 10
const BONUS_ICON_FRAME_SECONDS := 0.05

var _scroll_view: Control
var _scroll_content: Control
var _bonus_texture: Texture2D
var _content_height := 0.0
var _scroll_offset := 0.0
var _bonus_icons: Array[TextureRect] = []
var _bonus_icon_frames: Array[int] = []
var _bonus_icon_elapsed: Array[float] = []


func screen_title() -> String:
	return ORIGINAL_TITLE


func refresh_content() -> void:
	pass


func body_lines() -> Array[String]:
	var lines: Array[String] = [ORIGINAL_RULES_HEADING, ORIGINAL_SCROLL_HINT, "", ORIGINAL_OVERVIEW_HEADING]
	for line: String in ORIGINAL_OVERVIEW_LINES:
		lines.append(line)
	lines.append("")
	lines.append(ORIGINAL_KEY_HEADING)
	for line: String in ORIGINAL_KEY_LINES:
		lines.append(line)
	lines.append("")
	lines.append(ORIGINAL_BONUS_HEADING)
	for name: String in bonus_names():
		lines.append(name)
	return lines


func overview_lines() -> Array[String]:
	var lines: Array[String] = []
	for line: String in ORIGINAL_OVERVIEW_LINES:
		lines.append(line)
	return lines


func key_lines() -> Array[String]:
	var lines: Array[String] = []
	for line: String in ORIGINAL_KEY_LINES:
		lines.append(line)
	return lines


func bonus_names() -> Array[String]:
	var names: Array[String] = []
	for name: String in GameSessionScript.BONUS_TYPE_NAMES:
		names.append(name)
	return names


func scroll_offset() -> float:
	return _scroll_offset


func max_scroll_offset() -> float:
	return ORIGINAL_SCROLL_TOP_Y - ORIGINAL_SCROLL_BOTTOM_Y


func scroll_by(delta_pixels: float) -> void:
	_set_scroll_offset(_scroll_offset + delta_pixels)


func advance_scroll_key_state(up_pressed: bool, down_pressed: bool) -> void:
	if up_pressed:
		scroll_by(-SCROLL_LINE_PIXELS)
	if down_pressed:
		scroll_by(SCROLL_LINE_PIXELS)


func bonus_icon_frame(type_id: int) -> int:
	if type_id < 0 or type_id >= _bonus_icon_frames.size():
		return 0
	return _bonus_icon_frames[type_id]


static func bonus_icon_source_rect(type_id: int, frame: int) -> Rect2:
	return Rect2(
		Vector2(float(type_id) * BONUS_ICON_SIZE.x, float(posmod(frame, BONUS_ICON_FRAME_COUNT)) * BONUS_ICON_SIZE.y),
		BONUS_ICON_SIZE
	)


func advance_bonus_icon_animation(delta: float) -> void:
	if delta <= 0.0:
		return

	for type_id in range(_bonus_icons.size()):
		_bonus_icon_elapsed[type_id] += delta
		if _bonus_icon_elapsed[type_id] <= BONUS_ICON_FRAME_SECONDS:
			continue

		_bonus_icon_elapsed[type_id] = 0.0
		_bonus_icon_frames[type_id] = (_bonus_icon_frames[type_id] + 1) % BONUS_ICON_FRAME_COUNT
		var atlas := _bonus_icons[type_id].texture as AtlasTexture
		if atlas != null:
			atlas.region = bonus_icon_source_rect(type_id, _bonus_icon_frames[type_id])


func reset_bonus_icon_animation() -> void:
	for type_id in range(_bonus_icons.size()):
		_bonus_icon_elapsed[type_id] = 0.0
		_bonus_icon_frames[type_id] = 0
		var atlas := _bonus_icons[type_id].texture as AtlasTexture
		if atlas != null:
			atlas.region = bonus_icon_source_rect(type_id, 0)


func _process(delta: float) -> void:
	advance_bonus_icon_animation(delta)
	advance_scroll_key_state(Input.is_key_pressed(KEY_UP), Input.is_key_pressed(KEY_DOWN))


func _build_scene() -> void:
	if _background != null:
		return

	_background = TextureRect.new()
	_background.name = "Background"
	_background.position = Vector2.ZERO
	_background.size = Vector2(PlayfieldSpecScript.VIEWPORT_SIZE)
	_background.texture = _load_asset_texture("BackgroundB")
	_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_background.stretch_mode = TextureRect.STRETCH_KEEP
	add_child(_background)

	_title_label = _create_bitmap_label(
		"TitleLabel",
		TITLE_POSITION,
		TITLE_SIZE,
		HORIZONTAL_ALIGNMENT_CENTER,
		VERTICAL_ALIGNMENT_CENTER
	)
	_title_label.text = ORIGINAL_RULES_HEADING
	add_child(_title_label)

	var hint_label = _create_bitmap_label(
		"ScrollHintLabel",
		HINT_POSITION,
		HINT_SIZE,
		HORIZONTAL_ALIGNMENT_CENTER,
		VERTICAL_ALIGNMENT_CENTER
	)
	hint_label.text = ORIGINAL_SCROLL_HINT
	add_child(hint_label)

	_scroll_view = Control.new()
	_scroll_view.name = "RulesScrollView"
	_scroll_view.position = VIEW_POSITION
	_scroll_view.size = VIEW_SIZE
	_scroll_view.clip_contents = true
	_scroll_view.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_scroll_view)

	_scroll_content = Control.new()
	_scroll_content.name = "RulesScrollContent"
	_scroll_content.position = Vector2.ZERO
	_scroll_content.size = VIEW_SIZE
	_scroll_content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_scroll_view.add_child(_scroll_content)

	_bonus_texture = _load_asset_texture("Bonuses_a")
	_build_rules_content()

	_back_button = StaticMenuBackButtonScript.new()
	_back_button.name = "BackButton"
	_back_button.position = BACK_POSITION
	_back_button.activated.connect(_activate_back)
	add_child(_back_button)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		var key_event := event as InputEventKey
		if key_event.pressed and not key_event.echo:
			match key_event.keycode:
				KEY_UP:
					get_viewport().set_input_as_handled()
					return
				KEY_DOWN:
					get_viewport().set_input_as_handled()
					return
				KEY_PAGEUP:
					scroll_by(-PAGE_SCROLL_PIXELS)
					get_viewport().set_input_as_handled()
					return
				KEY_PAGEDOWN:
					scroll_by(PAGE_SCROLL_PIXELS)
					get_viewport().set_input_as_handled()
					return
	super._unhandled_input(event)


func _build_rules_content() -> void:
	_bonus_icons.clear()
	_bonus_icon_frames.clear()
	_bonus_icon_elapsed.clear()

	var y := 25.0
	_body_label = _add_text_label("BodyLabel", ORIGINAL_OVERVIEW_HEADING, Vector2(0, y), SECTION_LABEL_SIZE, HORIZONTAL_ALIGNMENT_CENTER)
	for line: String in ORIGINAL_OVERVIEW_LINES:
		y += LINE_STEP
		_add_text_label("OverviewLine", line, Vector2(0, y), BODY_LABEL_SIZE, HORIZONTAL_ALIGNMENT_CENTER)

	y += SECTION_GAP
	_add_text_label("KeysHeadingLabel", ORIGINAL_KEY_HEADING, Vector2(0, y), SECTION_LABEL_SIZE, HORIZONTAL_ALIGNMENT_CENTER)
	for line: String in ORIGINAL_KEY_LINES:
		y += LINE_STEP
		_add_text_label("KeyLine", line, Vector2(0, y), KEY_LABEL_SIZE, HORIZONTAL_ALIGNMENT_CENTER)

	y += SECTION_GAP
	_add_text_label("BonusesHeadingLabel", ORIGINAL_BONUS_HEADING, Vector2(0, y), SECTION_LABEL_SIZE, HORIZONTAL_ALIGNMENT_CENTER)
	var names := bonus_names()
	for type_id in range(names.size()):
		y += BONUS_ROW_HEIGHT
		_add_bonus_icon(type_id, Vector2(BONUS_ICON_X, y))
		_add_text_label(
			"BonusName%dLabel" % type_id,
			names[type_id],
			Vector2(BONUS_LABEL_X, y),
			BONUS_LABEL_SIZE,
			HORIZONTAL_ALIGNMENT_RIGHT
		)

	_content_height = y + BONUS_ICON_SIZE.y
	_scroll_content.size = Vector2(VIEW_SIZE.x, _content_height)
	_set_scroll_offset(_scroll_offset)


func _add_text_label(
	label_name: String,
	label_text: String,
	label_position: Vector2,
	label_size: Vector2,
	alignment: HorizontalAlignment,
	wrap_enabled := false
):
	var label = _create_bitmap_label(
		label_name,
		label_position,
		label_size,
		alignment,
		VERTICAL_ALIGNMENT_TOP,
		0,
		wrap_enabled
	)
	label.text = label_text
	_scroll_content.add_child(label)
	return label


func _add_bonus_icon(type_id: int, icon_position: Vector2) -> void:
	if _bonus_texture == null:
		return
	var atlas := AtlasTexture.new()
	atlas.atlas = _bonus_texture
	atlas.region = bonus_icon_source_rect(type_id, 0)

	var icon := TextureRect.new()
	icon.name = "BonusIcon%d" % type_id
	icon.position = icon_position
	icon.size = BONUS_ICON_SIZE
	icon.texture = atlas
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.stretch_mode = TextureRect.STRETCH_KEEP
	_scroll_content.add_child(icon)
	_bonus_icons.append(icon)
	_bonus_icon_frames.append(0)
	_bonus_icon_elapsed.append(0.0)


func _set_scroll_offset(value: float) -> void:
	_scroll_offset = clampf(value, 0.0, max_scroll_offset())
	if _scroll_content != null:
		_scroll_content.position = Vector2(0, ORIGINAL_SCROLL_TOP_Y - _scroll_offset - VIEW_POSITION.y)
