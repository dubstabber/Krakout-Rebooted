extends RefCounted
class_name KrakoutBonusSystem

const BonusCatalogScript := preload("res://src/gameplay/rules/krakout_bonus_catalog.gd")

var falling_bonuses: Array[Dictionary]
var bonus_stack: Array[Dictionary]


func _init(shared_falling_bonuses: Array[Dictionary] = [], shared_bonus_stack: Array[Dictionary] = []) -> void:
	falling_bonuses = shared_falling_bonuses
	bonus_stack = shared_bonus_stack


func clear_falling() -> void:
	falling_bonuses.clear()


func clear_stack() -> int:
	var removed_count := bonus_stack.size()
	bonus_stack.clear()
	return removed_count


func stack_entries() -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	for entry: Dictionary in bonus_stack:
		entries.append(entry.duplicate())
	return entries


func push_stack(type_id: int) -> bool:
	if bonus_stack.size() >= BonusCatalogScript.MAX_STACKED_BONUSES:
		return false
	bonus_stack.append({
		"type_id": type_id,
		"frame": 0,
		"frame_elapsed": 0.0,
	})
	return true


func consume_next_stack_entry() -> void:
	if not bonus_stack.is_empty():
		bonus_stack.remove_at(0)


func remove_stack_entry(index: int) -> Dictionary:
	if index < 0 or index >= bonus_stack.size():
		return {}
	var removed_entry: Dictionary = bonus_stack[index].duplicate()
	bonus_stack.remove_at(index)
	return removed_entry


func stack_count() -> int:
	return bonus_stack.size()
