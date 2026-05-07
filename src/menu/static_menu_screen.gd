extends Control
class_name StaticMenuScreen

signal back_requested

const PlayfieldSpecScript := preload("res://src/playfield/krakout_playfield_spec.gd")
const MenuBitmapLabelScript := preload("res://src/menu/krakout_menu_bitmap_label.gd")

var _background: TextureRect
var _title_label
var _body_label
var _back_button: Button
var _back_button_label


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	custom_minimum_size = Vector2(PlayfieldSpecScript.VIEWPORT_SIZE)
	_build_scene()
	refresh_content()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		back_requested.emit()
		get_viewport().set_input_as_handled()


func refresh_content() -> void:
	if _title_label != null:
		_title_label.text = screen_title()
	if _body_label != null:
		_body_label.text = "\n".join(body_lines())


func screen_title() -> String:
	return ""


func body_lines() -> Array[String]:
	return []


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
		Vector2(0, 56),
		Vector2(640, 42),
		HORIZONTAL_ALIGNMENT_CENTER,
		VERTICAL_ALIGNMENT_CENTER
	)
	add_child(_title_label)

	_body_label = _create_bitmap_label(
		"BodyLabel",
		Vector2(80, 126),
		Vector2(480, 250),
		HORIZONTAL_ALIGNMENT_CENTER,
		VERTICAL_ALIGNMENT_CENTER
	)
	add_child(_body_label)

	_back_button = Button.new()
	_back_button.name = "BackButton"
	_back_button.text = ""
	_back_button.position = Vector2(260, 405)
	_back_button.size = Vector2(120, 34)
	_back_button.focus_mode = Control.FOCUS_ALL
	_back_button.pressed.connect(func() -> void: back_requested.emit())
	add_child(_back_button)

	_back_button_label = _create_bitmap_label(
		"BackButtonLabel",
		Vector2.ZERO,
		_back_button.size,
		HORIZONTAL_ALIGNMENT_CENTER,
		VERTICAL_ALIGNMENT_CENTER
	)
	_back_button_label.text = "Back"
	_back_button.add_child(_back_button_label)


func _create_bitmap_label(
	label_name: String,
	label_position: Vector2,
	label_size: Vector2,
	alignment: HorizontalAlignment,
	vertical: VerticalAlignment = VERTICAL_ALIGNMENT_TOP,
	line_spacing: int = 0,
	wrap_enabled: bool = false
):
	var label = MenuBitmapLabelScript.new()
	label.name = label_name
	label.position = label_position
	label.size = label_size
	label.horizontal_alignment = alignment
	label.vertical_alignment = vertical
	label.line_spacing = line_spacing
	label.wrap_enabled = wrap_enabled
	return label


func _load_asset_texture(texture_name: String) -> Texture2D:
	var assets := get_node_or_null("/root/KrakoutAssets")
	if assets == null or not assets.has_method("load_texture"):
		return null
	return assets.call("load_texture", texture_name) as Texture2D
