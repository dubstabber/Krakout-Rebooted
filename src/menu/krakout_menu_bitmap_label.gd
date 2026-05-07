extends Control
class_name KrakoutMenuBitmapLabel

const BitmapTextScript := preload("res://src/render/krakout_bitmap_text.gd")
const FONT_FALLBACK_PATH := "res://assets/krakout/textures/Font.png"

@export_multiline var text := "":
	set(value):
		if text == value:
			return
		text = value
		queue_redraw()

@export var horizontal_alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT:
	set(value):
		if horizontal_alignment == value:
			return
		horizontal_alignment = value
		queue_redraw()

@export var vertical_alignment: VerticalAlignment = VERTICAL_ALIGNMENT_TOP:
	set(value):
		if vertical_alignment == value:
			return
		vertical_alignment = value
		queue_redraw()

@export var line_spacing := 0:
	set(value):
		var clamped_value := maxi(0, value)
		if line_spacing == clamped_value:
			return
		line_spacing = clamped_value
		queue_redraw()

@export var wrap_enabled := false:
	set(value):
		if wrap_enabled == value:
			return
		wrap_enabled = value
		queue_redraw()

var _font_texture: Texture2D
var _bitmap_text: KrakoutBitmapText


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_ensure_bitmap_text()


func _draw() -> void:
	_ensure_bitmap_text()
	if _bitmap_text == null:
		return

	var lines := rendered_lines()
	if lines.is_empty():
		return

	var content_dimensions := content_size()
	var line_height := _line_height()
	var draw_y := 0.0
	match vertical_alignment:
		VERTICAL_ALIGNMENT_CENTER:
			draw_y = floor((size.y - content_dimensions.y) * 0.5)
		VERTICAL_ALIGNMENT_BOTTOM:
			draw_y = floor(size.y - content_dimensions.y)
		_:
			draw_y = 0.0

	for line: String in lines:
		var anchor_x := 0.0
		match horizontal_alignment:
			HORIZONTAL_ALIGNMENT_CENTER:
				anchor_x = floor(size.x * 0.5)
			HORIZONTAL_ALIGNMENT_RIGHT:
				anchor_x = floor(size.x)
			_:
				anchor_x = 0.0
		_bitmap_text.draw_text(self, line, Vector2(anchor_x, draw_y), horizontal_alignment)
		draw_y += line_height


func rendered_lines() -> Array[String]:
	_ensure_bitmap_text()
	if text.is_empty():
		return [""]

	var lines: Array[String] = []
	for raw_line in text.split("\n", true):
		if not wrap_enabled or _bitmap_text == null or size.x <= 0.0:
			lines.append(raw_line)
			continue

		lines.append_array(_wrap_line(raw_line))

	return lines


func content_size() -> Vector2:
	_ensure_bitmap_text()
	if _bitmap_text == null:
		return Vector2.ZERO

	var lines := rendered_lines()
	var width := 0.0
	for line: String in lines:
		width = maxf(width, float(_bitmap_text.measure_text(line)))

	return Vector2(width, _content_height(lines.size()))


func font_texture() -> Texture2D:
	_ensure_bitmap_text()
	return _font_texture


func _wrap_line(raw_line: String) -> Array[String]:
	if raw_line.is_empty():
		return [""]

	var max_width := int(size.x)
	if max_width <= 0:
		return [raw_line]

	var words := raw_line.split(" ", false)
	if words.is_empty():
		return [raw_line]

	var wrapped: Array[String] = []
	var current_line := ""
	for word: String in words:
		var candidate := word if current_line.is_empty() else "%s %s" % [current_line, word]
		if _bitmap_text.measure_text(candidate) <= max_width:
			current_line = candidate
			continue

		if not current_line.is_empty():
			wrapped.append(current_line)
			current_line = ""

		if _bitmap_text.measure_text(word) <= max_width:
			current_line = word
			continue

		for fragment: String in _wrap_word(word, max_width):
			if _bitmap_text.measure_text(fragment) <= max_width:
				if current_line.is_empty():
					current_line = fragment
				else:
					wrapped.append(current_line)
					current_line = fragment
			else:
				wrapped.append(fragment)

	if not current_line.is_empty():
		wrapped.append(current_line)
	return wrapped


func _wrap_word(word: String, max_width: int) -> Array[String]:
	var fragments: Array[String] = []
	var current_fragment := ""
	for character_index in range(word.length()):
		var character := word.substr(character_index, 1)
		var candidate := current_fragment + character
		if current_fragment.is_empty() or _bitmap_text.measure_text(candidate) <= max_width:
			current_fragment = candidate
			continue

		fragments.append(current_fragment)
		current_fragment = character

	if not current_fragment.is_empty():
		fragments.append(current_fragment)
	return fragments


func _content_height(line_count: int) -> float:
	if line_count <= 0:
		return 0.0
	return float(line_count * _bitmap_text.cell_size.y + maxi(0, line_count - 1) * line_spacing)


func _line_height() -> float:
	if _bitmap_text == null:
		return 0.0
	return _bitmap_text.cell_size.y + line_spacing


func _ensure_bitmap_text() -> void:
	if _font_texture == null:
		_font_texture = _load_font_texture()
	if _font_texture == null:
		return
	if _bitmap_text != null and _bitmap_text.texture == _font_texture:
		return

	_bitmap_text = BitmapTextScript.new()
	_bitmap_text.configure(
		_font_texture,
		BitmapTextScript.FONT_CHARSET,
		BitmapTextScript.FONT_CELL_SIZE,
		BitmapTextScript.FONT_ADVANCES,
		BitmapTextScript.FONT_SPACE_ADVANCE
	)


func _load_font_texture() -> Texture2D:
	var assets := get_node_or_null("/root/KrakoutAssets")
	if assets != null and assets.has_method("load_texture"):
		return assets.call("load_texture", "Font") as Texture2D
	return load(FONT_FALLBACK_PATH) as Texture2D
