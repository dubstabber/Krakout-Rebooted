extends Control
class_name KrakoutGameHud

const PlayfieldSpecScript := preload("res://src/playfield/krakout_playfield_spec.gd")

const GAME_OVER_STATE := "game_over"

var session
var _score_label: Label
var _lives_label: Label
var _level_label: Label
var _best_score_label: Label
var _game_over_title: Label
var _game_over_summary: Label
var _game_over_hint: Label


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
			"score": 0,
			"lives": 0,
			"level": 1,
			"best_score": 0,
		}

	return {
		"score": int(session.displayed_score),
		"lives": int(session.visible_lives() if session.has_method("visible_lives") else max(0, session.lives_remaining)),
		"level": int(session.display_level_number),
		"best_score": int(session.best_score),
	}


func _ensure_nodes() -> void:
	if _score_label != null:
		return

	_score_label = _make_label("ScoreValue", Vector2(80, 4), Vector2(80, 28), HORIZONTAL_ALIGNMENT_RIGHT)
	_lives_label = _make_label("LivesValue", Vector2(260, 4), Vector2(55, 28), HORIZONTAL_ALIGNMENT_CENTER)
	_level_label = _make_label("LevelValue", Vector2(400, 4), Vector2(70, 28), HORIZONTAL_ALIGNMENT_CENTER)
	_best_score_label = _make_label("BestScoreValue", Vector2(560, 4), Vector2(72, 28), HORIZONTAL_ALIGNMENT_RIGHT)

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
	_score_label.text = str(score_value)
	_lives_label.text = str(lives_value)
	_level_label.text = str(level_value)
	_best_score_label.text = str(best_score_value)


func _set_game_over_visible(is_visible: bool) -> void:
	_game_over_title.visible = is_visible
	_game_over_summary.visible = is_visible
	_game_over_hint.visible = is_visible
