extends Control
class_name KrakoutGameHud

const PlayfieldSpecScript := preload("res://src/playfield/krakout_playfield_spec.gd")
const BitmapTextScript := preload("res://src/render/krakout_bitmap_text.gd")

const READY_STATE := "ready"
const BALL_LOST_STATE := "ball_lost"
const GAME_OVER_STATE := "game_over"
const CAPTION_TEXTS := ["Your Score", "Balls Left", "Level", "High Score"]
const STATISTIC_SOURCE := Rect2(Vector2.ZERO, Vector2(640, 39))
const SCORE_VALUE_RIGHT := Vector2(137, 18)
const LIVES_VALUE_CENTER := Vector2(278, 18)
const LEVEL_VALUE_CENTER := Vector2(420, 18)
const BEST_SCORE_VALUE_RIGHT := Vector2(615, 18)
const STATUS_ICON_POSITION := Vector2(543, 69)
const STATUS_VALUE_POSITION := Vector2(576, 73)
const STATUS_ROW_STEP := 30.0
const STATUS_ICON_SIZE := Vector2(28, 28)
const STATUS_ICON_COUNT := 6
const READY_LEVEL_POSITION := Vector2(320, 215)
const READY_TEXT_POSITION := Vector2(320, 240)
const READY_HINT_POSITION := Vector2(320, 428)
const READY_TEXT := "Get Ready!"
const READY_HINT_TEXT := "(Press Mouse Button when ready)"
const OVERLAY_TITLE_POSITION := Vector2(320, 215)
const OVERLAY_SUMMARY_POSITION := Vector2(320, 240)
const OVERLAY_HINT_POSITION := Vector2(320, 428)
const EXIT_CONFIRMATION_TITLE_TEXT := "Are You sure to leave"
const EXIT_CONFIRMATION_SUMMARY_TEXT := "this board (Y / N)"
const GAME_OVER_TITLE_TEXT := "Game Over!"
const GAME_OVER_HINT_TEXT := "(Press Mouse Button to enter Menu)"

var session
var _exit_confirmation_visible := false
var _score_value := 0
var _lives_value := 0
var _level_value := 1
var _best_score_value := 0
var _statistic_texture: Texture2D
var _digit_texture: Texture2D
var _font_texture: Texture2D
var _info_icons_texture: Texture2D
var _digit_text
var _font_text


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(PlayfieldSpecScript.VIEWPORT_SIZE)
	_ensure_nodes()
	refresh()


func set_session(value) -> void:
	session = value
	refresh()


func set_exit_confirmation_visible(is_visible: bool) -> void:
	if _exit_confirmation_visible == is_visible:
		return
	_exit_confirmation_visible = is_visible
	queue_redraw()


func refresh() -> void:
	_ensure_nodes()
	if session == null:
		_set_status_values(0, 0, 1, 0)
		return

	_set_status_values(
		int(session.displayed_score),
		int(session.visible_lives() if session.has_method("visible_lives") else max(0, session.lives_remaining)),
		int(session.display_level_number),
		int(session.best_score)
	)


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
	return [
		Vector2(24, 0),
		Vector2(190, 0),
		Vector2(370, 0),
		Vector2(500, 0),
	]


func statistic_source_rect() -> Rect2:
	return STATISTIC_SOURCE


func value_anchor_positions() -> Dictionary:
	return {
		"score_right": SCORE_VALUE_RIGHT,
		"lives_center": LIVES_VALUE_CENTER,
		"level_center": LEVEL_VALUE_CENTER,
		"best_score_right": BEST_SCORE_VALUE_RIGHT,
	}


func status_indicator_layout(index: int) -> Dictionary:
	var row_offset := Vector2(0, STATUS_ROW_STEP * max(0, index))
	return {
		"icon_position": STATUS_ICON_POSITION + row_offset,
		"value_position": STATUS_VALUE_POSITION + row_offset,
		"icon_size": STATUS_ICON_SIZE,
	}


func status_indicator_slots() -> int:
	return STATUS_ICON_COUNT


func ready_prompt_layout() -> Dictionary:
	if session == null:
		return {"visible": false}

	var session_state := String(session.state)
	if session_state != READY_STATE and session_state != BALL_LOST_STATE:
		return {"visible": false}
	if session.has_method("is_level_ready_prompt_visible") and not bool(session.call("is_level_ready_prompt_visible")):
		return {"visible": false}

	return {
		"visible": true,
		"level_text": "Level #%d" % int(session.display_level_number),
		"ready_text": READY_TEXT,
		"hint_text": READY_HINT_TEXT,
		"level_position": READY_LEVEL_POSITION,
		"ready_position": READY_TEXT_POSITION,
		"hint_position": READY_HINT_POSITION,
	}


func exit_confirmation_layout() -> Dictionary:
	if not _exit_confirmation_visible:
		return {"visible": false}

	return {
		"visible": true,
		"title_text": EXIT_CONFIRMATION_TITLE_TEXT,
		"summary_text": EXIT_CONFIRMATION_SUMMARY_TEXT,
		"title_position": OVERLAY_TITLE_POSITION,
		"summary_position": OVERLAY_SUMMARY_POSITION,
	}


func game_over_layout() -> Dictionary:
	if session == null or String(session.state) != GAME_OVER_STATE:
		return {"visible": false}

	return {
		"visible": true,
		"title_text": GAME_OVER_TITLE_TEXT,
		"summary_text": "Your Level #%d, and Score %d" % [
			int(session.display_level_number),
			int(session.score),
		],
		"hint_text": GAME_OVER_HINT_TEXT,
		"title_position": OVERLAY_TITLE_POSITION,
		"summary_position": OVERLAY_SUMMARY_POSITION,
		"hint_position": OVERLAY_HINT_POSITION,
	}


func digit_text_bounds(value: int, anchor: Vector2, alignment: HorizontalAlignment) -> Rect2:
	return header_value_text_bounds(value, anchor, alignment)


func header_value_text_bounds(value: int, anchor: Vector2, alignment: HorizontalAlignment) -> Rect2:
	_ensure_font_text()
	if _font_text == null:
		return Rect2(anchor, Vector2.ZERO)
	return _font_text.bounds_for_text(str(max(0, value)), anchor, alignment)


func status_digit_text_bounds(value: int, anchor: Vector2, alignment: HorizontalAlignment) -> Rect2:
	_ensure_digit_text()
	if _digit_text == null:
		return Rect2(anchor, Vector2.ZERO)
	return _digit_text.bounds_for_text(str(max(0, value)), anchor, alignment)


func bitmap_text_status() -> Dictionary:
	_load_hud_textures()
	_ensure_bitmap_text()
	return {
		"statistic_texture": _statistic_texture != null,
		"digit_texture": _digit_texture != null,
		"font_texture": _font_texture != null,
		"info_icons_texture": _info_icons_texture != null,
		"digit_text": _digit_text != null and _digit_text.texture != null,
		"font_text": _font_text != null and _font_text.texture != null,
	}


func _ensure_nodes() -> void:
	_load_hud_textures()
	_ensure_bitmap_text()


func _set_status_values(score_value: int, lives_value: int, level_value: int, best_score_value: int) -> void:
	_score_value = score_value
	_lives_value = lives_value
	_level_value = level_value
	_best_score_value = best_score_value
	queue_redraw()


func _draw() -> void:
	_draw_status_hud()
	if _draw_exit_confirmation():
		return
	_draw_ready_prompt()
	_draw_game_over_prompt()


func _draw_status_hud() -> void:
	if _statistic_texture != null:
		draw_texture_rect_region(_statistic_texture, STATISTIC_SOURCE, STATISTIC_SOURCE)
	else:
		_draw_caption_fallback()
	_draw_header_value(_score_value, SCORE_VALUE_RIGHT, HORIZONTAL_ALIGNMENT_RIGHT)
	_draw_header_value(_lives_value, LIVES_VALUE_CENTER, HORIZONTAL_ALIGNMENT_CENTER)
	_draw_header_value(_level_value, LEVEL_VALUE_CENTER, HORIZONTAL_ALIGNMENT_CENTER)
	_draw_header_value(_best_score_value, BEST_SCORE_VALUE_RIGHT, HORIZONTAL_ALIGNMENT_RIGHT)
	_draw_active_bonus_indicators()


func _draw_caption_fallback() -> void:
	_ensure_font_text()
	if _font_text == null:
		return

	var positions := caption_positions()
	for index in range(min(CAPTION_TEXTS.size(), positions.size())):
		_font_text.draw_text(self, CAPTION_TEXTS[index], positions[index])


func _draw_header_value(value: int, anchor: Vector2, alignment: HorizontalAlignment) -> void:
	_ensure_font_text()
	if _font_text == null:
		return

	_font_text.draw_text(self, str(max(0, value)), anchor, alignment)


func _draw_digits(value: int, anchor: Vector2, alignment: HorizontalAlignment) -> void:
	_ensure_digit_text()
	if _digit_text == null:
		return

	_digit_text.draw_text(self, str(max(0, value)), anchor, alignment)


func _draw_active_bonus_indicators() -> void:
	if _info_icons_texture == null or session == null or not session.has_method("active_bonus_indicators"):
		return

	var indicators: Array = session.call("active_bonus_indicators")
	for index in range(min(indicators.size(), STATUS_ICON_COUNT)):
		var indicator: Dictionary = indicators[index]
		var icon_index := clampi(int(indicator.get("icon_index", 0)), 0, STATUS_ICON_COUNT - 1)
		var layout := status_indicator_layout(index)
		draw_texture_rect_region(
			_info_icons_texture,
			Rect2(layout["icon_position"], STATUS_ICON_SIZE),
			Rect2(Vector2(icon_index * STATUS_ICON_SIZE.x, 0), STATUS_ICON_SIZE)
		)
		if indicator.has("value"):
			_draw_digits(int(indicator["value"]), layout["value_position"], HORIZONTAL_ALIGNMENT_LEFT)


func _draw_ready_prompt() -> void:
	var layout := ready_prompt_layout()
	if not bool(layout.get("visible", false)):
		return

	_ensure_font_text()
	if _font_text == null:
		return

	_font_text.draw_text(self, String(layout["level_text"]), layout["level_position"], HORIZONTAL_ALIGNMENT_CENTER)
	_font_text.draw_text(self, String(layout["ready_text"]), layout["ready_position"], HORIZONTAL_ALIGNMENT_CENTER)
	_font_text.draw_text(self, String(layout["hint_text"]), layout["hint_position"], HORIZONTAL_ALIGNMENT_CENTER)


func _draw_exit_confirmation() -> bool:
	var layout := exit_confirmation_layout()
	if not bool(layout.get("visible", false)):
		return false

	_ensure_font_text()
	if _font_text == null:
		return true

	_font_text.draw_text(self, String(layout["title_text"]), layout["title_position"], HORIZONTAL_ALIGNMENT_CENTER)
	_font_text.draw_text(self, String(layout["summary_text"]), layout["summary_position"], HORIZONTAL_ALIGNMENT_CENTER)
	return true


func _draw_game_over_prompt() -> void:
	var layout := game_over_layout()
	if not bool(layout.get("visible", false)):
		return

	_ensure_font_text()
	if _font_text == null:
		return

	_font_text.draw_text(self, String(layout["title_text"]), layout["title_position"], HORIZONTAL_ALIGNMENT_CENTER)
	_font_text.draw_text(self, String(layout["summary_text"]), layout["summary_position"], HORIZONTAL_ALIGNMENT_CENTER)
	_font_text.draw_text(self, String(layout["hint_text"]), layout["hint_position"], HORIZONTAL_ALIGNMENT_CENTER)


func _load_hud_textures() -> void:
	if _statistic_texture == null:
		_statistic_texture = _load_asset_texture("Statistic")

	if _digit_texture == null:
		_digit_texture = _load_asset_texture("Digits")

	if _font_texture == null:
		_font_texture = _load_asset_texture("Font")

	if _info_icons_texture == null:
		_info_icons_texture = _load_asset_texture("InfoIcons")


func _ensure_bitmap_text() -> void:
	_ensure_digit_text()
	_ensure_font_text()


func _ensure_digit_text() -> void:
	if _digit_text != null and _digit_text.texture == _digit_texture:
		return
	_digit_text = BitmapTextScript.new()
	_digit_text.configure(
		_digit_texture,
		BitmapTextScript.DIGIT_CHARSET,
		BitmapTextScript.DIGIT_CELL_SIZE,
		BitmapTextScript.DIGIT_ADVANCES,
		BitmapTextScript.DIGIT_SPACE_ADVANCE
	)


func _ensure_font_text() -> void:
	if _font_text != null and _font_text.texture == _font_texture:
		return
	_font_text = BitmapTextScript.new()
	_font_text.configure(
		_font_texture,
		BitmapTextScript.FONT_CHARSET,
		BitmapTextScript.FONT_CELL_SIZE,
		BitmapTextScript.FONT_ADVANCES,
		BitmapTextScript.FONT_SPACE_ADVANCE
	)


func _load_asset_texture(texture_name: String) -> Texture2D:
	if not is_inside_tree():
		return null

	var assets := get_node_or_null("/root/KrakoutAssets")
	if assets == null or not assets.has_method("load_texture"):
		return null

	return assets.call("load_texture", texture_name) as Texture2D
