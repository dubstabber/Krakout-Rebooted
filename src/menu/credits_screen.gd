extends "res://src/menu/static_menu_screen.gd"
class_name CreditsScreen

const ORIGINAL_TITLE := "Credits"
const ORIGINAL_CREDIT_SECTIONS := [
	{
		"role": "Main Programmer",
		"names": ["Andrey A. Ugolnik"],
	},
	{
		"role": "Design & Graphics",
		"names": ["Andrey A. Ugolnik", "Eugene P. Janushkevich"],
	},
	{
		"role": "Levels Designers",
		"names": ["Andrey A. Ugolnik", "Eugene P. Janushkevich", "Ludmila N. Ugolnik"],
	},
	{
		"role": "Beta Testers",
		"names": ["Ludmila N. Ugolnik", "Ilya A. Ugolnik", "Alex J. Khriakov", "Alex Shabluk"],
	},
	{
		"role": "Original Music",
		"names": ["Konstantin Elgazin", "Oleg Romanovich"],
	},
]
const ORIGINAL_FOOTER_LINES := [
	"(c) 2001-2002 'WE' Group.",
	"All Rights Reserved.",
	"http://www.wegroup.org",
]
const ORIGINAL_CREDIT_ROWS := [
	{"text": "Main Programmer", "x": 80.0, "y": 0.0, "alignment": HORIZONTAL_ALIGNMENT_LEFT},
	{"text": "Andrey A. Ugolnik", "x": 560.0, "y": 35.0, "alignment": HORIZONTAL_ALIGNMENT_RIGHT},
	{"text": "Design & Graphics", "x": 80.0, "y": 105.0, "alignment": HORIZONTAL_ALIGNMENT_LEFT},
	{"text": "Andrey A. Ugolnik", "x": 560.0, "y": 140.0, "alignment": HORIZONTAL_ALIGNMENT_RIGHT},
	{"text": "Eugene P. Janushkevich", "x": 560.0, "y": 165.0, "alignment": HORIZONTAL_ALIGNMENT_RIGHT},
	{"text": "Levels Designers", "x": 80.0, "y": 235.0, "alignment": HORIZONTAL_ALIGNMENT_LEFT},
	{"text": "Andrey A. Ugolnik", "x": 560.0, "y": 270.0, "alignment": HORIZONTAL_ALIGNMENT_RIGHT},
	{"text": "Eugene P. Janushkevich", "x": 560.0, "y": 295.0, "alignment": HORIZONTAL_ALIGNMENT_RIGHT},
	{"text": "Ludmila N. Ugolnik", "x": 560.0, "y": 320.0, "alignment": HORIZONTAL_ALIGNMENT_RIGHT},
	{"text": "Beta Testers", "x": 80.0, "y": 390.0, "alignment": HORIZONTAL_ALIGNMENT_LEFT},
	{"text": "Ludmila N. Ugolnik", "x": 560.0, "y": 425.0, "alignment": HORIZONTAL_ALIGNMENT_RIGHT},
	{"text": "Ilya A. Ugolnik", "x": 560.0, "y": 450.0, "alignment": HORIZONTAL_ALIGNMENT_RIGHT},
	{"text": "Alex J. Khriakov", "x": 560.0, "y": 475.0, "alignment": HORIZONTAL_ALIGNMENT_RIGHT},
	{"text": "Alex Shabluk", "x": 560.0, "y": 500.0, "alignment": HORIZONTAL_ALIGNMENT_RIGHT},
	{"text": "Original Music", "x": 80.0, "y": 570.0, "alignment": HORIZONTAL_ALIGNMENT_LEFT},
	{"text": "Konstantin Elgazin", "x": 560.0, "y": 605.0, "alignment": HORIZONTAL_ALIGNMENT_RIGHT},
	{"text": "Oleg Romanovich", "x": 560.0, "y": 630.0, "alignment": HORIZONTAL_ALIGNMENT_RIGHT},
	{"text": "(c) 2001-2002 'WE' Group.", "x": 0.0, "y": 740.0, "alignment": HORIZONTAL_ALIGNMENT_CENTER},
	{"text": "All Rights Reserved.", "x": 0.0, "y": 765.0, "alignment": HORIZONTAL_ALIGNMENT_CENTER},
	{"text": "http://www.wegroup.org", "x": 0.0, "y": 790.0, "alignment": HORIZONTAL_ALIGNMENT_CENTER},
]

const VIEW_TOP_Y := 10.0
const VIEW_SIZE := Vector2(640, 460)
const BACK_POSITION := Vector2(539, 379)
const ROLE_LABEL_SIZE := Vector2(480, 28)
const NAME_LABEL_SIZE := Vector2(560, 28)
const FOOTER_LABEL_SIZE := Vector2(640, 28)
const ORIGINAL_CREDITS_ROLL_START_Y := 480.0
const ORIGINAL_CREDITS_ROLL_WRAP_Y := -1260.0
const ORIGINAL_CREDITS_ROLL_STEP_SECONDS := 1.0 / 50.0

var _roll_view: Control
var _roll_content: Control
var _credits_roll_y := ORIGINAL_CREDITS_ROLL_START_Y
var _credits_roll_elapsed := 0.0


func _process(delta: float) -> void:
	advance_credits_roll(delta)


func screen_title() -> String:
	return ORIGINAL_TITLE


func refresh_content() -> void:
	pass


func body_lines() -> Array[String]:
	var lines: Array[String] = []
	for section: Dictionary in ORIGINAL_CREDIT_SECTIONS:
		lines.append(String(section["role"]))
		for credit_name: String in section["names"]:
			lines.append(credit_name)
		lines.append("")
	for footer_line: String in ORIGINAL_FOOTER_LINES:
		lines.append(footer_line)
	return lines


func credit_sections() -> Array[Dictionary]:
	var sections: Array[Dictionary] = []
	for section: Dictionary in ORIGINAL_CREDIT_SECTIONS:
		sections.append({
			"role": String(section["role"]),
			"names": (section["names"] as Array).duplicate(),
		})
	return sections


func credit_footer_lines() -> Array[String]:
	var lines: Array[String] = []
	for footer_line: String in ORIGINAL_FOOTER_LINES:
		lines.append(footer_line)
	return lines


func scroll_offset() -> float:
	return credits_scroll_y()


func max_scroll_offset() -> float:
	return ORIGINAL_CREDITS_ROLL_START_Y - ORIGINAL_CREDITS_ROLL_WRAP_Y


func scroll_by(_delta_pixels: float) -> void:
	# The original credits screen is a self-running roll; keyboard scrolling is
	# intentionally ignored here.
	pass


func credits_scroll_y() -> float:
	return _credits_roll_y


func set_credits_scroll_y_for_test(value: float) -> void:
	_credits_roll_y = value
	_credits_roll_elapsed = 0.0
	_sync_credits_roll_position()


func advance_credits_roll(delta: float) -> void:
	if delta <= 0.0:
		return

	var did_move := false
	_credits_roll_elapsed += delta
	while _credits_roll_elapsed >= ORIGINAL_CREDITS_ROLL_STEP_SECONDS:
		_credits_roll_elapsed -= ORIGINAL_CREDITS_ROLL_STEP_SECONDS
		_credits_roll_y -= 1.0
		if _credits_roll_y < ORIGINAL_CREDITS_ROLL_WRAP_Y:
			_credits_roll_y = ORIGINAL_CREDITS_ROLL_START_Y
		did_move = true

	if did_move:
		_sync_credits_roll_position()


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

	_roll_view = Control.new()
	_roll_view.name = "CreditsRollView"
	_roll_view.position = Vector2(0, VIEW_TOP_Y)
	_roll_view.size = VIEW_SIZE
	_roll_view.clip_contents = true
	_roll_view.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_roll_view)

	_roll_content = Control.new()
	_roll_content.name = "CreditsRollContent"
	_roll_content.position = Vector2.ZERO
	_roll_content.size = Vector2(640, 820)
	_roll_content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_roll_view.add_child(_roll_content)

	_build_credits_content()
	_sync_credits_roll_position()

	_back_button = StaticMenuBackButtonScript.new()
	_back_button.name = "BackButton"
	_back_button.position = BACK_POSITION
	_back_button.activated.connect(_activate_back)
	add_child(_back_button)


func _build_credits_content() -> void:
	for row_index in range(ORIGINAL_CREDIT_ROWS.size()):
		var row: Dictionary = ORIGINAL_CREDIT_ROWS[row_index]
		var alignment := int(row["alignment"])
		var label_position := Vector2(float(row["x"]), float(row["y"]))
		var label_size := ROLE_LABEL_SIZE
		if alignment == HORIZONTAL_ALIGNMENT_RIGHT:
			label_position.x = 0.0
			label_size = NAME_LABEL_SIZE
		elif alignment == HORIZONTAL_ALIGNMENT_CENTER:
			label_position.x = 0.0
			label_size = FOOTER_LABEL_SIZE
		var row_label = _add_text_label(
			"BodyLabel" if row_index == 0 else "CreditRow%dLabel" % row_index,
			String(row["text"]),
			label_position,
			label_size,
			alignment
		)
		if row_index == 0:
			_body_label = row_label


func _add_text_label(
	label_name: String,
	label_text: String,
	label_position: Vector2,
	label_size: Vector2,
	alignment: HorizontalAlignment
):
	var label = _create_bitmap_label(
		label_name,
		label_position,
		label_size,
		alignment,
		VERTICAL_ALIGNMENT_TOP
	)
	label.text = label_text
	_roll_content.add_child(label)
	return label


func _sync_credits_roll_position() -> void:
	if _roll_content != null:
		_roll_content.position = Vector2(0, _credits_roll_y - VIEW_TOP_Y)
