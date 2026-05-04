extends RefCounted
class_name KrakoutBoardState

const BrickSemanticsScript := preload("res://src/gameplay/krakout_brick_semantics.gd")

const CHAIN_EXPLOSION_DELAY_SECONDS := 0.03

var source_level: KrakoutLevelData
var columns := KrakoutLevelData.COLUMNS
var rows_count := KrakoutLevelData.ROWS
var tile_ids: Array = []
var active_tile_count := 0
var remaining_required_bricks := 0

var _pending_chain_explosions: Array[Dictionary] = []


func load_level(level: KrakoutLevelData) -> void:
	source_level = level
	tile_ids.clear()
	_pending_chain_explosions.clear()
	active_tile_count = 0
	remaining_required_bricks = 0
	if level == null:
		return

	columns = level.columns
	rows_count = level.rows_count
	for row_index in range(level.rows_count):
		var source_row: Array = level.tile_ids[row_index]
		var row: Array[int] = []
		for value: Variant in source_row:
			row.append(int(value))
		tile_ids.append(row)
	_recount_tiles()


func tile_at(column: int, row: int) -> int:
	if not _is_in_bounds(column, row):
		return 0
	return int(tile_ids[row][column])


func set_tile(column: int, row: int, tile_id: int) -> bool:
	if not _is_in_bounds(column, row):
		return false

	var previous_tile_id := tile_at(column, row)
	if previous_tile_id == tile_id:
		return false

	_update_counts_for_change(previous_tile_id, tile_id)
	tile_ids[row][column] = tile_id
	return true


func clear_tile(column: int, row: int) -> bool:
	return set_tile(column, row, 0)


func is_complete() -> bool:
	return remaining_required_bricks <= 0


func explode_at(column: int, row: int) -> int:
	var result := explode_at_with_result(column, row)
	return int(result.get("cleared_count", 0))


func explode_at_with_result(column: int, row: int) -> Dictionary:
	var cleared_cells: Array[Vector2i] = []
	if not _is_in_bounds(column, row):
		return {
			"cleared_count": 0,
			"cleared_cells": cleared_cells,
		}

	if clear_tile(column, row):
		cleared_cells.append(Vector2i(column, row))

	for scan_row in range(row - 1, row + 2):
		for scan_column in range(column - 1, column + 2):
			if not _is_in_bounds(scan_column, scan_row):
				continue

			var tile_id := tile_at(scan_column, scan_row)
			if not BrickSemanticsScript.is_active_tile(tile_id):
				continue

			if BrickSemanticsScript.is_chain_explosion_tile(tile_id):
				_schedule_chain_explosion(scan_column, scan_row)
			elif clear_tile(scan_column, scan_row):
				cleared_cells.append(Vector2i(scan_column, scan_row))

	return {
		"cleared_count": cleared_cells.size(),
		"cleared_cells": cleared_cells,
	}


func weaken_all_for_one_strike() -> int:
	var changed_count := 0
	for row_index in range(rows_count):
		for column_index in range(columns):
			var tile_id := tile_at(column_index, row_index)
			if not BrickSemanticsScript.is_active_tile(tile_id):
				continue

			var next_tile_id: int = BrickSemanticsScript.one_strike_tile_id(tile_id)
			if next_tile_id != tile_id and set_tile(column_index, row_index, next_tile_id):
				changed_count += 1
	return changed_count


func expand_exploding_tiles() -> int:
	var snapshot: Array = []
	for row: Array in tile_ids:
		snapshot.append(row.duplicate())

	var changed_count := 0
	for row_index in range(rows_count):
		for column_index in range(columns):
			var tile_id := int(snapshot[row_index][column_index])
			if not BrickSemanticsScript.is_chain_explosion_tile(tile_id):
				continue

			for scan_row in range(row_index - 1, row_index + 2):
				for scan_column in range(column_index - 1, column_index + 2):
					if not _is_in_bounds(scan_column, scan_row):
						continue
					if set_tile(scan_column, scan_row, tile_id):
						changed_count += 1
	return changed_count


func schedule_all_chain_explosions() -> int:
	var scheduled_count := 0
	for row_index in range(rows_count):
		for column_index in range(columns):
			if BrickSemanticsScript.is_chain_explosion_tile(tile_at(column_index, row_index)):
				_schedule_chain_explosion(column_index, row_index)
				scheduled_count += 1
	return scheduled_count


func convert_to_chain_explosion_tile(column: int, row: int, tile_id: int) -> bool:
	if not _is_in_bounds(column, row):
		return false
	if not BrickSemanticsScript.is_chain_explosion_tile(tile_id):
		return false

	set_tile(column, row, tile_id)
	_schedule_chain_explosion(column, row)
	return true


func process_chain_explosions(delta: float) -> int:
	var result := process_chain_explosions_with_result(delta)
	return int(result.get("cleared_count", 0))


func process_chain_explosions_with_result(delta: float) -> Dictionary:
	var cleared_cells: Array[Vector2i] = []
	if _pending_chain_explosions.is_empty():
		return {
			"cleared_count": 0,
			"cleared_cells": cleared_cells,
		}

	var pending := _pending_chain_explosions
	_pending_chain_explosions = []
	for entry: Dictionary in pending:
		var remaining := float(entry.get("remaining", 0.0)) - delta
		if remaining > 0.0:
			entry["remaining"] = remaining
			_pending_chain_explosions.append(entry)
			continue

		var column := int(entry.get("column", -1))
		var row := int(entry.get("row", -1))
		if BrickSemanticsScript.is_chain_explosion_tile(tile_at(column, row)):
			var result: Dictionary = explode_at_with_result(column, row)
			var result_cells: Array = result.get("cleared_cells", [])
			for cell: Vector2i in result_cells:
				cleared_cells.append(cell)

	return {
		"cleared_count": cleared_cells.size(),
		"cleared_cells": cleared_cells,
	}


func pending_chain_explosion_count() -> int:
	return _pending_chain_explosions.size()


func _recount_tiles() -> void:
	active_tile_count = 0
	remaining_required_bricks = 0
	for row: Array in tile_ids:
		for value: Variant in row:
			var tile_id := int(value)
			if BrickSemanticsScript.is_active_tile(tile_id):
				active_tile_count += 1
			if BrickSemanticsScript.is_required_tile(tile_id):
				remaining_required_bricks += 1


func _update_counts_for_change(previous_tile_id: int, next_tile_id: int) -> void:
	if BrickSemanticsScript.is_active_tile(previous_tile_id):
		active_tile_count -= 1
	if BrickSemanticsScript.is_required_tile(previous_tile_id):
		remaining_required_bricks -= 1

	if BrickSemanticsScript.is_active_tile(next_tile_id):
		active_tile_count += 1
	if BrickSemanticsScript.is_required_tile(next_tile_id):
		remaining_required_bricks += 1


func _schedule_chain_explosion(column: int, row: int) -> void:
	for entry: Dictionary in _pending_chain_explosions:
		if int(entry.get("column", -1)) == column and int(entry.get("row", -1)) == row:
			entry["remaining"] = CHAIN_EXPLOSION_DELAY_SECONDS
			return

	_pending_chain_explosions.append({
		"column": column,
		"row": row,
		"remaining": CHAIN_EXPLOSION_DELAY_SECONDS,
	})


func _is_in_bounds(column: int, row: int) -> bool:
	return column >= 0 and column < columns and row >= 0 and row < rows_count
