extends RefCounted
class_name KrakoutLevelData

const COLUMNS := 20
const ROWS := 13
const LEVEL_TAIL_SIZE := 50

var source_path := ""
var source_episode := ""
var episode_title := ""
var episode_author := ""
var source_level_index := -1
var level_number := 0
var columns := COLUMNS
var rows_count := ROWS
var tile_ids: Array = []
var level_tail_bytes: Array[int] = []
var unique_tile_values: Array[int] = []
var tail_unique_values: Array[int] = []
var tile_semantics := "unmapped"


static func from_dictionary(data: Dictionary, path: String = ""):
	var level := KrakoutLevelData.new()
	level.source_path = path
	level.source_episode = String(data.get("source_episode", ""))
	level.episode_title = String(data.get("episode_title", ""))
	level.episode_author = String(data.get("episode_author", ""))
	level.source_level_index = int(data.get("source_level_index", -1))
	level.level_number = int(data.get("level_number", 0))
	level.columns = int(data.get("columns", COLUMNS))
	level.rows_count = int(data.get("rows_count", ROWS))
	level.tile_semantics = String(data.get("tile_semantics", "unmapped"))

	var source_rows: Array = data.get("tile_ids", [])
	if level.columns != COLUMNS or level.rows_count != ROWS:
		push_error("Unexpected Krakout level dimensions in %s: %dx%d" % [path, level.columns, level.rows_count])
		return null

	if source_rows.size() != ROWS:
		push_error("Unexpected Krakout row count in %s: %d" % [path, source_rows.size()])
		return null

	for row_index in range(ROWS):
		var source_row: Array = source_rows[row_index]
		if source_row.size() != COLUMNS:
			push_error("Unexpected Krakout column count in %s row %d: %d" % [path, row_index, source_row.size()])
			return null

		var row: Array[int] = []
		for value: Variant in source_row:
			row.append(int(value))
		level.tile_ids.append(row)

	var unique_values: Array = data.get("unique_tile_values", [])
	for value: Variant in unique_values:
		level.unique_tile_values.append(int(value))

	var tail_bytes: Array = data.get("level_tail_bytes", [])
	if tail_bytes.size() != LEVEL_TAIL_SIZE:
		push_error("Unexpected Krakout level tail size in %s: %d" % [path, tail_bytes.size()])
		return null

	for value: Variant in tail_bytes:
		level.level_tail_bytes.append(int(value))

	var tail_values: Array = data.get("tail_unique_values", [])
	for value: Variant in tail_values:
		level.tail_unique_values.append(int(value))

	return level


func tile_at(column: int, row: int) -> int:
	if row < 0 or row >= rows_count or column < 0 or column >= columns:
		return 0
	return int(tile_ids[row][column])


func populated_tile_count() -> int:
	var count := 0
	for row in tile_ids:
		for tile_id: int in row:
			if tile_id != 0:
				count += 1
	return count
