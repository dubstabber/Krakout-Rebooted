extends Control
class_name StaticMenuScreen

signal back_requested

const PlayfieldSpecScript := preload("res://src/playfield/krakout_playfield_spec.gd")

var _background: TextureRect
var _title_label: Label
var _body_label: Label
var _back_button: Button


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

	_title_label = Label.new()
	_title_label.name = "TitleLabel"
	_title_label.position = Vector2(0, 56)
	_title_label.size = Vector2(640, 42)
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_title_label.add_theme_color_override("font_color", Color.WHITE)
	_title_label.add_theme_font_size_override("font_size", 24)
	add_child(_title_label)

	_body_label = Label.new()
	_body_label.name = "BodyLabel"
	_body_label.position = Vector2(80, 126)
	_body_label.size = Vector2(480, 250)
	_body_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_body_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_body_label.add_theme_color_override("font_color", Color.WHITE)
	_body_label.add_theme_font_size_override("font_size", 16)
	add_child(_body_label)

	_back_button = Button.new()
	_back_button.name = "BackButton"
	_back_button.text = "Back"
	_back_button.position = Vector2(260, 405)
	_back_button.size = Vector2(120, 34)
	_back_button.focus_mode = Control.FOCUS_ALL
	_back_button.pressed.connect(func() -> void: back_requested.emit())
	add_child(_back_button)


func _load_asset_texture(texture_name: String) -> Texture2D:
	var assets := get_node_or_null("/root/KrakoutAssets")
	if assets == null or not assets.has_method("load_texture"):
		return null
	return assets.call("load_texture", texture_name) as Texture2D
