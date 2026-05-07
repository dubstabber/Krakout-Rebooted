extends "res://src/menu/static_menu_screen.gd"
class_name HighScoreScreen

const ProfileScript := preload("res://src/autoloads/krakout_profile.gd")

const TABLE_SUBTITLE_Y := 104.0
const TABLE_HEADER_Y := 136.0
const TABLE_ROW_START_Y := 160.0
const TABLE_ROW_HEIGHT := 24.0
const INDEX_COLUMN_X := 76.0
const INDEX_COLUMN_WIDTH := 30.0
const NAME_COLUMN_X := 120.0
const NAME_COLUMN_WIDTH := 250.0
const LEVEL_COLUMN_X := 455.0
const LEVEL_COLUMN_WIDTH := 45.0
const SCORE_COLUMN_X := 515.0
const SCORE_COLUMN_WIDTH := 70.0

var _best_score := 0
var _entries: Array[Dictionary] = []
var _table_root: Control
var _empty_label


func _ready() -> void:
	refresh_from_profile()
	super()


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


func refresh_from_profile() -> void:
	_best_score = _profile_best_score()
	_entries = _profile_high_score_entries()
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

	_table_root = Control.new()
	_table_root.name = "HighScoreTable"
	_table_root.position = Vector2.ZERO
	_table_root.size = Vector2(640, 480)
	_table_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_table_root)

	var subtitle = _create_bitmap_label(
		"BestPlayersTitle",
		Vector2(0, TABLE_SUBTITLE_Y),
		Vector2(640, TABLE_ROW_HEIGHT),
		HORIZONTAL_ALIGNMENT_CENTER,
		VERTICAL_ALIGNMENT_CENTER
	)
	subtitle.text = "Best Players Table"
	_table_root.add_child(subtitle)

	_table_root.add_child(_table_label("HeaderRank", "#", INDEX_COLUMN_X, INDEX_COLUMN_WIDTH, TABLE_HEADER_Y, HORIZONTAL_ALIGNMENT_LEFT))
	_table_root.add_child(_table_label("HeaderName", "Players Name", NAME_COLUMN_X, NAME_COLUMN_WIDTH, TABLE_HEADER_Y, HORIZONTAL_ALIGNMENT_LEFT))
	_table_root.add_child(_table_label("HeaderLevel", "Lev", LEVEL_COLUMN_X, LEVEL_COLUMN_WIDTH, TABLE_HEADER_Y, HORIZONTAL_ALIGNMENT_RIGHT))
	_table_root.add_child(_table_label("HeaderScore", "Score", SCORE_COLUMN_X, SCORE_COLUMN_WIDTH, TABLE_HEADER_Y, HORIZONTAL_ALIGNMENT_RIGHT))

	_empty_label = _create_bitmap_label(
		"EmptyStateLabel",
		Vector2(0, TABLE_ROW_START_Y + TABLE_ROW_HEIGHT),
		Vector2(640, TABLE_ROW_HEIGHT),
		HORIZONTAL_ALIGNMENT_CENTER,
		VERTICAL_ALIGNMENT_CENTER
	)
	_empty_label.text = "No saved scores"
	_table_root.add_child(_empty_label)

	for index in range(ProfileScript.HIGH_SCORE_TABLE_LIMIT):
		var y := TABLE_ROW_START_Y + index * TABLE_ROW_HEIGHT
		_table_root.add_child(_table_label("EntryRank%d" % (index + 1), "", INDEX_COLUMN_X, INDEX_COLUMN_WIDTH, y, HORIZONTAL_ALIGNMENT_LEFT))
		_table_root.add_child(_table_label("EntryName%d" % (index + 1), "", NAME_COLUMN_X, NAME_COLUMN_WIDTH, y, HORIZONTAL_ALIGNMENT_LEFT))
		_table_root.add_child(_table_label("EntryLevel%d" % (index + 1), "", LEVEL_COLUMN_X, LEVEL_COLUMN_WIDTH, y, HORIZONTAL_ALIGNMENT_RIGHT))
		_table_root.add_child(_table_label("EntryScore%d" % (index + 1), "", SCORE_COLUMN_X, SCORE_COLUMN_WIDTH, y, HORIZONTAL_ALIGNMENT_RIGHT))

	_refresh_table_rows()


func _refresh_table_rows() -> void:
	if _table_root == null:
		return

	var has_entries := not _entries.is_empty()
	if _empty_label != null:
		_empty_label.visible = not has_entries

	for index in range(ProfileScript.HIGH_SCORE_TABLE_LIMIT):
		var rank_label = _table_root.get_node_or_null("EntryRank%d" % (index + 1))
		var name_label = _table_root.get_node_or_null("EntryName%d" % (index + 1))
		var level_label = _table_root.get_node_or_null("EntryLevel%d" % (index + 1))
		var score_label = _table_root.get_node_or_null("EntryScore%d" % (index + 1))
		if rank_label == null or name_label == null or level_label == null or score_label == null:
			continue

		var row_visible := index < _entries.size()
		rank_label.visible = row_visible
		name_label.visible = row_visible
		level_label.visible = row_visible
		score_label.visible = row_visible
		if not row_visible:
			continue

		var entry := _entries[index]
		rank_label.text = str(index + 1)
		name_label.text = String(entry.get("name", ProfileScript.DEFAULT_PLAYER_NAME)).substr(0, ProfileScript.MAX_PLAYER_NAME_LENGTH)
		level_label.text = str(int(entry.get("level", 1)))
		score_label.text = str(int(entry.get("score", 0)))


func _table_label(label_name: String, text_value: String, x: float, width: float, y: float, alignment: HorizontalAlignment):
	var label = _create_bitmap_label(
		label_name,
		Vector2(x, y),
		Vector2(width, TABLE_ROW_HEIGHT),
		alignment,
		VERTICAL_ALIGNMENT_CENTER
	)
	label.text = text_value
	return label


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
