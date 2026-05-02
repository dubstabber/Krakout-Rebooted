extends Control
class_name KrakoutGameHud

const PlayfieldSpecScript := preload("res://src/playfield/krakout_playfield_spec.gd")

const GAME_OVER_STATE := "game_over"
const CAPTION_TEXTS := ["Your Score", "Balls Left", "Level", "High Score"]
const CAPTION_POSITIONS := [
	Vector2(24, 0),
	Vector2(190, 0),
	Vector2(370, 0),
	Vector2(500, 0),
]
const SCORE_VALUE_RIGHT := Vector2(137, 18)
const LIVES_VALUE_CENTER := Vector2(278, 18)
const LEVEL_VALUE_CENTER := Vector2(420, 18)
const BEST_SCORE_VALUE_RIGHT := Vector2(615, 18)
const FONT_GLYPH_SIZE := Vector2(32, 24)
const FONT_SPACE_ADVANCE := 8
const FONT_GLYPH_GAP := 2
const DIGIT_SIZE := Vector2(16, 20)

var session
var _game_over_title: Label
var _game_over_summary: Label
var _game_over_hint: Label
var _score_value := 0
var _lives_value := 0
var _level_value := 1
var _best_score_value := 0
var _font_texture: Texture2D
var _font_image: Image
var _digit_texture: Texture2D
var _glyph_metrics := {}


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(PlayfieldSpecScript.VIEWPORT_SIZE)
	_ensure_nodes()
	refresh()


func set_session(value) -> void:
	session = value
	refresh()


func refresh() -> void:
	_ensure_nodes()
	if session == null:
		_set_status_values(0, 0, 1, 0)
		_set_game_over_visible(false)
		return

	_set_status_values(
		int(session.displayed_score),
		int(session.visible_lives() if session.has_method("visible_lives") else max(0, session.lives_remaining)),
		int(session.display_level_number),
		int(session.best_score)
	)

	var is_game_over := String(session.state) == GAME_OVER_STATE
	_set_game_over_visible(is_game_over)
	if is_game_over:
		_game_over_summary.text = "Your Level #%d, and Score %d" % [
			int(session.display_level_number),
			int(session.score),
		]


func status_values() -> Dictionary:
	if session == null:
		return {
			"score": _score_value,
			"lives": _lives_value,
			"level": _level_value,
			"best_score": _best_score_value,
		}

	return {
		"score": int(session.displayed_score),
		"lives": int(session.visible_lives() if session.has_method("visible_lives") else max(0, session.lives_remaining)),
		"level": int(session.display_level_number),
		"best_score": int(session.best_score),
	}


func caption_texts() -> Array:
	return CAPTION_TEXTS.duplicate()


func caption_positions() -> Array:
	return CAPTION_POSITIONS.duplicate()


func value_anchor_positions() -> Dictionary:
	return {
		"score_right": SCORE_VALUE_RIGHT,
		"lives_center": LIVES_VALUE_CENTER,
		"level_center": LEVEL_VALUE_CENTER,
		"best_score_right": BEST_SCORE_VALUE_RIGHT,
	}


func _ensure_nodes() -> void:
	_load_hud_textures()

	if _game_over_title != null:
		return

	_game_over_title = _make_label("GameOverTitle", Vector2(0, 205), Vector2(640, 30), HORIZONTAL_ALIGNMENT_CENTER)
	_game_over_title.text = "Game Over!"
	_game_over_title.add_theme_font_size_override("font_size", 20)
	_game_over_summary = _make_label("GameOverSummary", Vector2(0, 235), Vector2(640, 30), HORIZONTAL_ALIGNMENT_CENTER)
	_game_over_hint = _make_label("GameOverHint", Vector2(0, 420), Vector2(640, 30), HORIZONTAL_ALIGNMENT_CENTER)
	_game_over_hint.text = "(Press Mouse Button to enter Menu)"


func _make_label(label_name: String, label_position: Vector2, label_size: Vector2, alignment: HorizontalAlignment) -> Label:
	var label := Label.new()
	label.name = label_name
	label.position = label_position
	label.size = label_size
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_font_size_override("font_size", 16)
	add_child(label)
	return label


func _set_status_values(score_value: int, lives_value: int, level_value: int, best_score_value: int) -> void:
	_score_value = score_value
	_lives_value = lives_value
	_level_value = level_value
	_best_score_value = best_score_value
	queue_redraw()


func _set_game_over_visible(is_visible: bool) -> void:
	_game_over_title.visible = is_visible
	_game_over_summary.visible = is_visible
	_game_over_hint.visible = is_visible


func _draw() -> void:
	_draw_status_hud()


func _draw_status_hud() -> void:
	for caption_index in range(CAPTION_TEXTS.size()):
		_draw_font_text(String(CAPTION_TEXTS[caption_index]), CAPTION_POSITIONS[caption_index])

	_draw_digits(_score_value, SCORE_VALUE_RIGHT, HORIZONTAL_ALIGNMENT_RIGHT)
	_draw_digits(_lives_value, LIVES_VALUE_CENTER, HORIZONTAL_ALIGNMENT_CENTER)
	_draw_digits(_level_value, LEVEL_VALUE_CENTER, HORIZONTAL_ALIGNMENT_CENTER)
	_draw_digits(_best_score_value, BEST_SCORE_VALUE_RIGHT, HORIZONTAL_ALIGNMENT_RIGHT)


func _draw_font_text(text: String, draw_position: Vector2) -> void:
	if _font_texture == null:
		return

	var pen_x := draw_position.x
	for character_index in range(text.length()):
		var character := text.substr(character_index, 1)
		if character == " ":
			pen_x += FONT_SPACE_ADVANCE
			continue

		var metric := _glyph_metric_for(character)
		if metric.is_empty():
			continue

		var source: Rect2 = metric["source"]
		var offset: Vector2 = metric["offset"]
		draw_texture_rect_region(
			_font_texture,
			Rect2(Vector2(pen_x, draw_position.y + offset.y), source.size),
			source
		)
		pen_x += float(metric["advance"])


func _draw_digits(value: int, anchor: Vector2, alignment: HorizontalAlignment) -> void:
	if _digit_texture == null:
		return

	var text := str(max(0, value))
	var draw_width := text.length() * int(DIGIT_SIZE.x)
	var x := anchor.x
	if alignment == HORIZONTAL_ALIGNMENT_RIGHT:
		x -= draw_width
	elif alignment == HORIZONTAL_ALIGNMENT_CENTER:
		x -= draw_width * 0.5

	for digit_index in range(text.length()):
		var character := text.substr(digit_index, 1)
		var digit := character.unicode_at(0) - "0".unicode_at(0)
		if digit < 0 or digit > 9:
			continue

		draw_texture_rect_region(
			_digit_texture,
			Rect2(Vector2(x + digit_index * DIGIT_SIZE.x, anchor.y), DIGIT_SIZE),
			Rect2(Vector2(0, digit * DIGIT_SIZE.y), DIGIT_SIZE)
		)


func _glyph_metric_for(character: String) -> Dictionary:
	if _glyph_metrics.has(character):
		return _glyph_metrics[character]

	var source := _font_source_rect_for(character)
	if source == Rect2():
		_glyph_metrics[character] = {}
		return {}

	var bounds := _opaque_bounds(source)
	if bounds.size == Vector2.ZERO:
		_glyph_metrics[character] = {}
		return {}

	var metric := {
		"source": Rect2(source.position + bounds.position, bounds.size),
		"offset": bounds.position,
		"advance": bounds.size.x + FONT_GLYPH_GAP,
	}
	_glyph_metrics[character] = metric
	return metric


func _font_source_rect_for(character: String) -> Rect2:
	var code := character.unicode_at(0)
	var upper_a := "A".unicode_at(0)
	var upper_z := "Z".unicode_at(0)
	var lower_a := "a".unicode_at(0)
	var lower_z := "z".unicode_at(0)
	var glyph_index := -1

	if code >= upper_a and code <= upper_z:
		glyph_index = code - upper_a
	elif code >= lower_a and code <= lower_z:
		glyph_index = 26 + code - lower_a

	if glyph_index < 0:
		return Rect2()

	return Rect2(Vector2(0, glyph_index * FONT_GLYPH_SIZE.y), FONT_GLYPH_SIZE)


func _opaque_bounds(source: Rect2) -> Rect2:
	if _font_image == null:
		return Rect2(Vector2.ZERO, FONT_GLYPH_SIZE)

	var min_x := int(FONT_GLYPH_SIZE.x)
	var min_y := int(FONT_GLYPH_SIZE.y)
	var max_x := -1
	var max_y := -1

	for y in range(int(FONT_GLYPH_SIZE.y)):
		for x in range(int(FONT_GLYPH_SIZE.x)):
			var pixel := _font_image.get_pixel(int(source.position.x) + x, int(source.position.y) + y)
			if pixel.a <= 0.01:
				continue
			min_x = min(min_x, x)
			min_y = min(min_y, y)
			max_x = max(max_x, x)
			max_y = max(max_y, y)

	if max_x < min_x or max_y < min_y:
		return Rect2()

	return Rect2(Vector2(min_x, min_y), Vector2(max_x - min_x + 1, max_y - min_y + 1))


func _load_hud_textures() -> void:
	if _font_texture == null:
		_font_texture = _load_asset_texture("Font")
		if _font_texture != null:
			_font_image = _font_texture.get_image()

	if _digit_texture == null:
		_digit_texture = _load_asset_texture("Digits")


func _load_asset_texture(texture_name: String) -> Texture2D:
	if not is_inside_tree():
		return null

	var assets := get_node_or_null("/root/KrakoutAssets")
	if assets == null or not assets.has_method("load_texture"):
		return null

	return assets.call("load_texture", texture_name) as Texture2D
