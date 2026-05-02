extends RefCounted
class_name KrakoutBitmapText

const FONT_CHARSET := "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!\"#$%&'()*+,-./0123456789:;<=>?@[\\]^_`{|}~"
const FONT_ADVANCES := [
	24, 19, 21, 20, 19, 18, 22, 20, 11, 18,
	21, 19, 27, 20, 21, 20, 21, 20, 17, 20,
	20, 24, 27, 24, 23, 20, 20, 20, 17, 20,
	17, 14, 16, 20, 10, 12, 21, 10, 25, 20,
	17, 20, 20, 15, 14, 15, 20, 21, 27, 22,
	20, 20, 11, 11, 22, 16, 21, 22, 7, 10,
	10, 11, 17, 11, 13, 11, 13, 18, 14, 19,
	19, 20, 18, 18, 19, 18, 18, 11, 11, 17,
	17, 17, 15, 24, 9, 13, 9, 18, 15, 10,
	11, 7, 11, 19,
]
const DIGIT_CHARSET := "0123456789"
const DIGIT_ADVANCES := [15, 13, 14, 15, 15, 15, 15, 15, 15, 15]

const FONT_CELL_SIZE := Vector2(32, 24)
const FONT_SPACE_ADVANCE := 15
const DIGIT_CELL_SIZE := Vector2(16, 20)
const DIGIT_SPACE_ADVANCE := 12

var texture: Texture2D
var charset := ""
var cell_size := Vector2.ZERO
var advances: Array = []
var space_advance := 0

var _indices_by_character := {}


func configure(source_texture: Texture2D, source_charset: String, source_cell_size: Vector2, source_advances: Array, source_space_advance: int) -> void:
	texture = source_texture
	charset = source_charset
	cell_size = source_cell_size
	advances = source_advances.duplicate()
	space_advance = source_space_advance
	_indices_by_character.clear()

	for index in range(charset.length()):
		_indices_by_character[charset.substr(index, 1)] = index


func measure_text(text: String) -> int:
	var width := 0
	for character_index in range(text.length()):
		width += advance_for_character(text.substr(character_index, 1))
	return width


func bounds_for_text(text: String, anchor: Vector2, alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT) -> Rect2:
	var draw_position := _aligned_position(text, anchor, alignment)
	return Rect2(draw_position, Vector2(measure_text(text), cell_size.y))


func draw_text(target: CanvasItem, text: String, anchor: Vector2, alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT) -> void:
	if texture == null:
		return

	var pen := _aligned_position(text, anchor, alignment)
	for character_index in range(text.length()):
		var character := text.substr(character_index, 1)
		var source := source_rect_for_character(character)
		if source != Rect2():
			target.draw_texture_rect_region(
				texture,
				Rect2(pen, source.size),
				source
			)
		pen.x += advance_for_character(character)


func advance_for_character(character: String) -> int:
	if character == " ":
		return space_advance

	if not _indices_by_character.has(character):
		return 0

	var index := int(_indices_by_character[character])
	if index < 0 or index >= advances.size():
		return 0
	return int(advances[index])


func source_rect_for_character(character: String) -> Rect2:
	if not _indices_by_character.has(character):
		return Rect2()

	var index := int(_indices_by_character[character])
	return Rect2(Vector2(0, index * cell_size.y), Vector2(advance_for_character(character), cell_size.y))


func _aligned_position(text: String, anchor: Vector2, alignment: HorizontalAlignment) -> Vector2:
	var draw_position := anchor
	var width := measure_text(text)
	if alignment == HORIZONTAL_ALIGNMENT_RIGHT:
		draw_position.x -= width
	elif alignment == HORIZONTAL_ALIGNMENT_CENTER:
		draw_position.x -= width * 0.5
	return draw_position
