extends "res://src/menu/static_menu_screen.gd"
class_name HighScoreScreen

const ProfileScript := preload("res://src/autoloads/krakout_profile.gd")
const WaveBitmapLabelScript := preload("res://src/menu/krakout_wave_bitmap_label.gd")

const ORIGINAL_TITLE_Y := 20.0
const TABLE_HEADER_Y := 80.0
const TABLE_ROW_START_Y := 125.0
const TABLE_ROW_HEIGHT := 25.0
const FOOTER_Y := 450.0
const INDEX_COLUMN_X := 5.0
const INDEX_COLUMN_WIDTH := 40.0
const NAME_COLUMN_X := 50.0
const NAME_COLUMN_WIDTH := 390.0
const SCORE_RIGHT_X := 555.0
const SCORE_COLUMN_WIDTH := 90.0
const LEVEL_RIGHT_X := 635.0
const LEVEL_COLUMN_WIDTH := 65.0
const ROW_WAVE_STEP_SECONDS := 0.04
const ROW_WAVE_STEP_DEGREES := 20.0
const ROW_WAVE_AMPLITUDE := 5.0
const HOVER_EPISODE_Y_OFFSET := -25.0
const HOVER_EPISODE_LABEL_SIZE := Vector2(320, 24)

var _best_score := 0
var _entries: Array[Dictionary] = []
var _table_root: Control
var _empty_label
var _entry_label_rows: Array[Dictionary] = []
var _wave_root: Control
var _wave_labels: Dictionary = {}
var _hovered_episode_label
var _highlight_entry_request: Dictionary = {}
var _highlighted_row_index := -1
var _wave_phase_elapsed := 0.0
var _wave_phase_degrees := 0.0
var _has_hover_probe_override := false
var _hover_probe_override := Vector2.ZERO


func _ready() -> void:
	refresh_from_profile()
	super()


func _process(delta: float) -> void:
	advance_high_score_vfx(delta)
	_refresh_hovered_episode_label()


func screen_title() -> String:
	return "High Score"


func body_lines() -> Array[String]:
	return []


func best_score() -> int:
	return _best_score


func high_score_entries() -> Array[Dictionary]:
	var duplicates: Array[Dictionary] = []
	for entry: Dictionary in _entries:
		duplicates.append(entry.duplicate())
	return duplicates


func configure_highlight_entry(entry: Dictionary) -> void:
	_highlight_entry_request = _normalized_entry_request(entry)
	_resolve_highlighted_row()
	_refresh_table_rows()


func highlighted_row_index() -> int:
	return _highlighted_row_index


func row_wave_phase_degrees() -> float:
	return _wave_phase_degrees


func advance_high_score_vfx(delta: float) -> void:
	if delta <= 0.0:
		return

	_wave_phase_elapsed += delta
	if _wave_phase_elapsed > ROW_WAVE_STEP_SECONDS:
		_wave_phase_elapsed = 0.0
		_wave_phase_degrees = fposmod(_wave_phase_degrees + ROW_WAVE_STEP_DEGREES, 360.0)
		_sync_wave_labels()


func set_highlighted_row_for_test(row_index: int) -> void:
	_highlight_entry_request.clear()
	_highlighted_row_index = row_index
	_refresh_table_rows()


func reset_high_score_vfx_for_test() -> void:
	_wave_phase_elapsed = 0.0
	_wave_phase_degrees = 0.0
	_sync_wave_labels()


func set_hover_probe_for_test(local_position: Vector2) -> void:
	_has_hover_probe_override = true
	_hover_probe_override = local_position
	_refresh_hovered_episode_label()


func hovered_episode_text() -> String:
	if _hovered_episode_label == null or not _hovered_episode_label.visible:
		return ""
	return String(_hovered_episode_label.text)


func refresh_from_profile() -> void:
	_best_score = _profile_best_score()
	_entries = _profile_high_score_entries()
	_resolve_highlighted_row()
	refresh_content()


func refresh_content() -> void:
	super()
	_refresh_table_rows()


func _build_scene() -> void:
	super()
	if _table_root != null:
		return

	if _body_label != null:
		_body_label.visible = false
	if _title_label != null:
		_title_label.visible = false
	if _back_button != null:
		_back_button.position = Vector2(539, 379)

	_table_root = Control.new()
	_table_root.name = "HighScoreTable"
	_table_root.position = Vector2.ZERO
	_table_root.size = Vector2(640, 480)
	_table_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_table_root)

	var subtitle = _create_bitmap_label(
		"BestPlayersTitle",
		Vector2(0, ORIGINAL_TITLE_Y),
		Vector2(640, 24),
		HORIZONTAL_ALIGNMENT_CENTER,
		VERTICAL_ALIGNMENT_CENTER
	)
	subtitle.text = "Best Players Table"
	_table_root.add_child(subtitle)

	_table_root.add_child(_table_label("HeaderRank", "#", INDEX_COLUMN_X, INDEX_COLUMN_WIDTH, TABLE_HEADER_Y, HORIZONTAL_ALIGNMENT_LEFT))
	_table_root.add_child(_table_label("HeaderName", "Players Name", NAME_COLUMN_X, NAME_COLUMN_WIDTH, TABLE_HEADER_Y, HORIZONTAL_ALIGNMENT_LEFT))
	_table_root.add_child(_right_table_label("HeaderScore", "Score", SCORE_RIGHT_X, SCORE_COLUMN_WIDTH, TABLE_HEADER_Y))
	_table_root.add_child(_right_table_label("HeaderLevel", "Lev", LEVEL_RIGHT_X, LEVEL_COLUMN_WIDTH, TABLE_HEADER_Y))

	var footer = _create_bitmap_label(
		"EpisodeHoverHint",
		Vector2(0, FOOTER_Y),
		Vector2(640, 24),
		HORIZONTAL_ALIGNMENT_CENTER,
		VERTICAL_ALIGNMENT_CENTER
	)
	footer.text = "Use cursor to view episode name."
	_table_root.add_child(footer)

	_empty_label = _create_bitmap_label(
		"EmptyStateLabel",
		Vector2(0, TABLE_ROW_START_Y + TABLE_ROW_HEIGHT),
		Vector2(640, 24),
		HORIZONTAL_ALIGNMENT_CENTER,
		VERTICAL_ALIGNMENT_CENTER
	)
	_empty_label.text = "No saved scores"
	_table_root.add_child(_empty_label)

	_entry_label_rows.clear()
	for index in range(ProfileScript.HIGH_SCORE_TABLE_LIMIT):
		var y := TABLE_ROW_START_Y + index * TABLE_ROW_HEIGHT
		var row_labels := {
			"rank": _table_label("EntryRank%d" % (index + 1), "", INDEX_COLUMN_X, INDEX_COLUMN_WIDTH, y, HORIZONTAL_ALIGNMENT_LEFT),
			"name": _table_label("EntryName%d" % (index + 1), "", NAME_COLUMN_X, NAME_COLUMN_WIDTH, y, HORIZONTAL_ALIGNMENT_LEFT),
			"score": _right_table_label("EntryScore%d" % (index + 1), "", SCORE_RIGHT_X, SCORE_COLUMN_WIDTH, y),
			"level": _right_table_label("EntryLevel%d" % (index + 1), "", LEVEL_RIGHT_X, LEVEL_COLUMN_WIDTH, y),
		}
		for label in row_labels.values():
			_table_root.add_child(label)
		_entry_label_rows.append(row_labels)

	_build_wave_overlay()

	_refresh_table_rows()


func _refresh_table_rows() -> void:
	if _table_root == null:
		return

	var has_entries := not _entries.is_empty()
	if _empty_label != null:
		_empty_label.visible = not has_entries

	for index in range(ProfileScript.HIGH_SCORE_TABLE_LIMIT):
		if index >= _entry_label_rows.size():
			continue
		var row_labels := _entry_label_rows[index]
		var rank_label = row_labels.get("rank")
		var name_label = row_labels.get("name")
		var level_label = row_labels.get("level")
		var score_label = row_labels.get("score")

		var row_visible := index < _entries.size()
		var normal_visible := row_visible and index != _highlighted_row_index
		rank_label.visible = normal_visible
		name_label.visible = normal_visible
		level_label.visible = normal_visible
		score_label.visible = normal_visible
		if not row_visible:
			continue

		var entry := _entries[index]
		rank_label.text = str(index + 1)
		name_label.text = String(entry.get("name", ProfileScript.DEFAULT_PLAYER_NAME)).substr(0, ProfileScript.MAX_PLAYER_NAME_LENGTH)
		level_label.text = str(int(entry.get("level", 1)))
		score_label.text = str(int(entry.get("score", 0)))

	_sync_wave_labels()
	_refresh_hovered_episode_label()


func _table_label(label_name: String, text_value: String, x: float, width: float, y: float, alignment: HorizontalAlignment):
	var label = _create_bitmap_label(
		label_name,
		Vector2(x, y),
		Vector2(width, 24),
		alignment,
		VERTICAL_ALIGNMENT_CENTER
	)
	label.text = text_value
	return label


func _right_table_label(label_name: String, text_value: String, right_x: float, width: float, y: float):
	return _table_label(label_name, text_value, right_x - width, width, y, HORIZONTAL_ALIGNMENT_RIGHT)


func _build_wave_overlay() -> void:
	if _wave_root != null:
		return

	_wave_root = Control.new()
	_wave_root.name = "HighScoreWaveOverlay"
	_wave_root.position = Vector2.ZERO
	_wave_root.size = Vector2(640, 480)
	_wave_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_wave_root)

	_wave_labels = {
		"rank": _create_wave_label("WaveRank", INDEX_COLUMN_X, INDEX_COLUMN_WIDTH, HORIZONTAL_ALIGNMENT_LEFT),
		"name": _create_wave_label("WaveName", NAME_COLUMN_X, NAME_COLUMN_WIDTH, HORIZONTAL_ALIGNMENT_LEFT),
		"score": _create_wave_label("WaveScore", SCORE_RIGHT_X - SCORE_COLUMN_WIDTH, SCORE_COLUMN_WIDTH, HORIZONTAL_ALIGNMENT_RIGHT),
		"level": _create_wave_label("WaveLevel", LEVEL_RIGHT_X - LEVEL_COLUMN_WIDTH, LEVEL_COLUMN_WIDTH, HORIZONTAL_ALIGNMENT_RIGHT),
	}
	for label in _wave_labels.values():
		_wave_root.add_child(label)

	_hovered_episode_label = _create_bitmap_label(
		"HoveredEpisodeName",
		Vector2.ZERO,
		HOVER_EPISODE_LABEL_SIZE,
		HORIZONTAL_ALIGNMENT_LEFT,
		VERTICAL_ALIGNMENT_CENTER
	)
	_hovered_episode_label.visible = false
	_wave_root.add_child(_hovered_episode_label)
	if _back_button != null:
		move_child(_back_button, get_child_count() - 1)


func _create_wave_label(label_name: String, x: float, width: float, alignment: HorizontalAlignment):
	var label = WaveBitmapLabelScript.new()
	label.name = label_name
	label.position = Vector2(x, TABLE_ROW_START_Y - ROW_WAVE_AMPLITUDE)
	label.size = Vector2(width, 24 + ROW_WAVE_AMPLITUDE * 2.0)
	label.horizontal_alignment = alignment
	label.wave_amplitude = ROW_WAVE_AMPLITUDE
	label.visible = false
	return label


func _sync_wave_labels() -> void:
	if _wave_labels.is_empty():
		return
	var show_wave := _highlighted_row_index >= 0 and _highlighted_row_index < _entries.size()
	for label in _wave_labels.values():
		label.visible = show_wave
		label.phase_degrees = _wave_phase_degrees
	if not show_wave:
		return

	var entry := _entries[_highlighted_row_index]
	var y := TABLE_ROW_START_Y + float(_highlighted_row_index) * TABLE_ROW_HEIGHT - ROW_WAVE_AMPLITUDE
	_apply_wave_label("rank", str(_highlighted_row_index + 1), y)
	_apply_wave_label("name", String(entry.get("name", ProfileScript.DEFAULT_PLAYER_NAME)).substr(0, ProfileScript.MAX_PLAYER_NAME_LENGTH), y)
	_apply_wave_label("score", str(int(entry.get("score", 0))), y)
	_apply_wave_label("level", str(int(entry.get("level", 1))), y)


func _apply_wave_label(key: String, value: String, y: float) -> void:
	if not _wave_labels.has(key):
		return
	var label = _wave_labels[key]
	label.position.y = y
	label.text = value
	label.phase_degrees = _wave_phase_degrees


func _resolve_highlighted_row() -> void:
	_highlighted_row_index = -1
	if _highlight_entry_request.is_empty():
		return

	for index in range(_entries.size()):
		if _entry_matches_highlight(_entries[index], _highlight_entry_request):
			_highlighted_row_index = index
			return


func _entry_matches_highlight(entry: Dictionary, highlight: Dictionary) -> bool:
	return String(entry.get("name", "")) == String(highlight.get("name", "")) \
		and int(entry.get("score", 0)) == int(highlight.get("score", 0)) \
		and int(entry.get("level", 1)) == int(highlight.get("level", 1)) \
		and String(entry.get("episode", "")) == String(highlight.get("episode", ""))


func _normalized_entry_request(entry: Dictionary) -> Dictionary:
	if entry.is_empty():
		return {}
	return {
		"name": _normalized_player_name(String(entry.get("name", ProfileScript.DEFAULT_PLAYER_NAME))),
		"score": maxi(0, int(entry.get("score", 0))),
		"level": maxi(1, int(entry.get("level", 1))),
		"episode": String(entry.get("episode", "")),
	}


func _normalized_player_name(player_name: String) -> String:
	var normalized_name := player_name.strip_edges().replace("\n", " ").replace("\r", " ")
	while normalized_name.contains("  "):
		normalized_name = normalized_name.replace("  ", " ")
	if normalized_name.is_empty():
		normalized_name = ProfileScript.DEFAULT_PLAYER_NAME
	if normalized_name.length() > ProfileScript.MAX_PLAYER_NAME_LENGTH:
		normalized_name = normalized_name.substr(0, ProfileScript.MAX_PLAYER_NAME_LENGTH)
	return normalized_name


func _refresh_hovered_episode_label() -> void:
	if _hovered_episode_label == null:
		return

	var local_position := _hover_probe_override if _has_hover_probe_override else get_local_mouse_position()
	var row_index := _row_index_at_position(local_position)
	var episode_name := _episode_name_for_row(row_index)
	if episode_name.is_empty():
		_hovered_episode_label.visible = false
		_hovered_episode_label.text = ""
		return

	_hovered_episode_label.visible = true
	_hovered_episode_label.position = Vector2(local_position.x, local_position.y + HOVER_EPISODE_Y_OFFSET)
	_hovered_episode_label.text = episode_name


func _row_index_at_position(local_position: Vector2) -> int:
	if not (local_position.y > TABLE_ROW_START_Y and local_position.y < TABLE_ROW_START_Y + ProfileScript.HIGH_SCORE_TABLE_LIMIT * TABLE_ROW_HEIGHT):
		return -1
	var row_index := int((local_position.y - TABLE_ROW_START_Y) / TABLE_ROW_HEIGHT)
	if row_index < 0 or row_index >= _entries.size():
		return -1
	return row_index


func _episode_name_for_row(row_index: int) -> String:
	if row_index < 0 or row_index >= _entries.size():
		return ""
	var episode_slug := String(_entries[row_index].get("episode", ""))
	if episode_slug.is_empty():
		return ""
	return _episode_title_for_slug(episode_slug)


func _episode_title_for_slug(episode_slug: String) -> String:
	var levels := get_node_or_null("/root/KrakoutLevels")
	if levels != null and levels.has_method("episode_summaries"):
		for summary: Dictionary in levels.call("episode_summaries"):
			if String(summary.get("slug", "")) == episode_slug:
				return String(summary.get("title", episode_slug))
	return episode_slug


func _profile_best_score() -> int:
	var profile := get_node_or_null("/root/KrakoutProfile")
	if profile == null or not profile.has_method("best_score"):
		return 0
	return maxi(0, int(profile.call("best_score")))


func _profile_high_score_entries() -> Array[Dictionary]:
	var profile := get_node_or_null("/root/KrakoutProfile")
	if profile == null or not profile.has_method("high_score_entries"):
		return []

	var entries: Array[Dictionary] = []
	for entry: Dictionary in profile.call("high_score_entries"):
		entries.append(entry.duplicate())
	return entries
