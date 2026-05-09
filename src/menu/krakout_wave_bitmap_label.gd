extends Control
class_name KrakoutWaveBitmapLabel

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

@export var phase_degrees := 0.0:
	set(value):
		var normalized_value := fposmod(value, 360.0)
		if is_equal_approx(phase_degrees, normalized_value):
			return
		phase_degrees = normalized_value
		queue_redraw()

@export var wave_amplitude := 5.0:
	set(value):
		var normalized_value := maxf(0.0, value)
		if is_equal_approx(wave_amplitude, normalized_value):
			return
		wave_amplitude = normalized_value
		queue_redraw()

var _font_texture: Texture2D
var _bitmap_text: KrakoutBitmapText


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_ensure_bitmap_text()


func _draw() -> void:
	_ensure_bitmap_text()
	if _bitmap_text == null or _bitmap_text.texture == null:
		return

	var pen := _aligned_position(text)
	var phase_offset := 0.0
	for character_index in range(text.length()):
		var character := text.substr(character_index, 1)
		var advance := _bitmap_text.advance_for_character(character)
		var source := _bitmap_text.source_rect_for_character(character)
		if source != Rect2():
			var y_offset := int(sin(deg_to_rad(phase_degrees + phase_offset)) * wave_amplitude)
			draw_texture_rect_region(
				_bitmap_text.texture,
				Rect2(Vector2(pen.x, pen.y + float(y_offset)), source.size),
				source
			)
		pen.x += float(advance)
		phase_offset += float(advance)


func measured_width() -> int:
	_ensure_bitmap_text()
	if _bitmap_text == null:
		return 0
	return _bitmap_text.measure_text(text)


func _aligned_position(value: String) -> Vector2:
	var draw_position := Vector2.ZERO
	var width := measured_width()
	if horizontal_alignment == HORIZONTAL_ALIGNMENT_RIGHT:
		draw_position.x = size.x - float(width)
	elif horizontal_alignment == HORIZONTAL_ALIGNMENT_CENTER:
		draw_position.x = floor((size.x - float(width)) * 0.5)
	draw_position.y = wave_amplitude
	return draw_position


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
