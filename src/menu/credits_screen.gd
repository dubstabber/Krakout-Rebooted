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
		"names": ["Andrey A. Ugolnik"],
	},
	{
		"role": "Levels Designers",
		"names": ["Andrey A. Ugolnik", "Eugene P. Janushkevich", "Ludmila N. Ugolnik"],
	},
	{
		"role": "Beta Testers",
		"names": ["Ilya A. Ugolnik", "Alex J. Khriakov", "Alex Shabluk"],
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

const TITLE_POSITION := Vector2(0, 42)
const TITLE_SIZE := Vector2(640, 34)
const VIEW_POSITION := Vector2(54, 92)
const VIEW_SIZE := Vector2(532, 250)
const BACK_POSITION := Vector2(270, 358)
const ROLE_LABEL_SIZE := Vector2(532, 28)
const NAME_LABEL_SIZE := Vector2(532, 28)
const FOOTER_LABEL_SIZE := Vector2(532, 28)
const LINE_STEP := 27.0
const SECTION_GAP := 8.0
const FOOTER_GAP := 12.0
const SCROLL_LINE_PIXELS := 28.0
const PAGE_SCROLL_PIXELS := 196.0

var _scroll_view: Control
var _scroll_content: Control
var _content_height := 0.0
var _scroll_offset := 0.0


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
	return _scroll_offset


func max_scroll_offset() -> float:
	return maxf(0.0, _content_height - VIEW_SIZE.y)


func scroll_by(delta_pixels: float) -> void:
	_set_scroll_offset(_scroll_offset + delta_pixels)


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
	_title_label.text = ORIGINAL_TITLE
	add_child(_title_label)

	_scroll_view = Control.new()
	_scroll_view.name = "CreditsScrollView"
	_scroll_view.position = VIEW_POSITION
	_scroll_view.size = VIEW_SIZE
	_scroll_view.clip_contents = true
	_scroll_view.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_scroll_view)

	_scroll_content = Control.new()
	_scroll_content.name = "CreditsScrollContent"
	_scroll_content.position = Vector2.ZERO
	_scroll_content.size = VIEW_SIZE
	_scroll_content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_scroll_view.add_child(_scroll_content)

	_build_credits_content()

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
					scroll_by(-SCROLL_LINE_PIXELS)
					get_viewport().set_input_as_handled()
					return
				KEY_DOWN:
					scroll_by(SCROLL_LINE_PIXELS)
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


func _build_credits_content() -> void:
	var y := 0.0
	for section: Dictionary in ORIGINAL_CREDIT_SECTIONS:
		_body_label = _add_text_label(
			"BodyLabel" if _body_label == null else "CreditRoleLabel",
			String(section["role"]),
			Vector2(0, y),
			ROLE_LABEL_SIZE,
			HORIZONTAL_ALIGNMENT_CENTER
		)
		y += LINE_STEP
		for credit_name: String in section["names"]:
			_add_text_label(
				"CreditNameLabel",
				credit_name,
				Vector2(0, y),
				NAME_LABEL_SIZE,
				HORIZONTAL_ALIGNMENT_CENTER
			)
			y += LINE_STEP
		y += SECTION_GAP

	y += FOOTER_GAP
	for footer_line: String in ORIGINAL_FOOTER_LINES:
		_add_text_label(
			"CreditFooterLabel",
			footer_line,
			Vector2(0, y),
			FOOTER_LABEL_SIZE,
			HORIZONTAL_ALIGNMENT_CENTER
		)
		y += LINE_STEP

	_content_height = y
	_scroll_content.size = Vector2(VIEW_SIZE.x, _content_height)
	_set_scroll_offset(_scroll_offset)


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
	_scroll_content.add_child(label)
	return label


func _set_scroll_offset(value: float) -> void:
	_scroll_offset = clampf(value, 0.0, max_scroll_offset())
	if _scroll_content != null:
		_scroll_content.position = Vector2(0, -_scroll_offset)
