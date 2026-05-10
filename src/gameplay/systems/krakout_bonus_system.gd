extends RefCounted
class_name KrakoutBonusSystem

const GameplayStateScript := preload("res://src/gameplay/krakout_gameplay_state.gd")
const BrickSemanticsScript := preload("res://src/gameplay/krakout_brick_semantics.gd")
const BonusCatalogScript := preload("res://src/gameplay/rules/krakout_bonus_catalog.gd")

var falling_bonuses: Array[Dictionary]
var bonus_stack: Array[Dictionary]
var bonus_stock_counts: Array[int] = []
var remaining_bonus_stock := 0
var bonus_drop_cooldown := BonusCatalogScript.BONUS_DROP_GATE_SECONDS
var bonus_pointer_frame := 0
var bonus_pointer_elapsed := 0.0
var bonus_rng
var bonus_animation_rng
var _state


func _init(
	shared_falling_bonuses = [],
	shared_bonus_stack: Array[Dictionary] = [],
	bonus_rng_source = null,
	bonus_animation_rng_source = null
) -> void:
	if shared_falling_bonuses is GameplayStateScript:
		var state = shared_falling_bonuses
		_state = state
		_bind_state()
	else:
		falling_bonuses = shared_falling_bonuses
		bonus_stack = shared_bonus_stack
		bonus_rng = bonus_rng_source
		bonus_animation_rng = bonus_animation_rng_source


func clear_falling() -> void:
	_bind_state()
	falling_bonuses.clear()
	_sync_to_state()


func clear_stack() -> int:
	_bind_state()
	var removed_count := bonus_stack.size()
	bonus_stack.clear()
	_sync_to_state()
	return removed_count


func stack_entries() -> Array[Dictionary]:
	_bind_state()
	var entries: Array[Dictionary] = []
	for entry: Dictionary in bonus_stack:
		entries.append(entry.duplicate())
	return entries


func visible_falling() -> Array[Dictionary]:
	_bind_state()
	var visible: Array[Dictionary] = []
	for bonus: Dictionary in falling_bonuses:
		if bool(bonus.get("active", false)):
			visible.append(bonus.duplicate())
	return visible


func push_stack(type_id: int) -> bool:
	_bind_state()
	if bonus_stack.size() >= BonusCatalogScript.MAX_STACKED_BONUSES:
		return false
	bonus_stack.append({
		"type_id": type_id,
		"frame": 0,
		"frame_elapsed": 0.0,
	})
	_sync_to_state()
	return true


func consume_next_stack_entry() -> void:
	_bind_state()
	if not bonus_stack.is_empty():
		bonus_stack.remove_at(0)
	_sync_to_state()


func remove_stack_entry(index: int) -> Dictionary:
	_bind_state()
	if index < 0 or index >= bonus_stack.size():
		return {}
	var removed_entry: Dictionary = bonus_stack[index].duplicate()
	bonus_stack.remove_at(index)
	_sync_to_state()
	return removed_entry


func stack_count() -> int:
	_bind_state()
	return bonus_stack.size()


func load_stock_from_level(level) -> void:
	_bind_state()
	bonus_stock_counts.clear()
	remaining_bonus_stock = 0
	if level == null or not level.has_method("bonus_stock_counts"):
		for index in range(BonusCatalogScript.BONUS_TYPE_COUNT):
			bonus_stock_counts.append(0)
		_sync_to_state()
		return

	var source_counts: Array = level.call("bonus_stock_counts")
	for index in range(BonusCatalogScript.BONUS_TYPE_COUNT):
		var count := 0
		if index < source_counts.size():
			count = max(0, int(source_counts[index]))
		bonus_stock_counts.append(count)
		remaining_bonus_stock += count
	_sync_to_state()


func reset_run_state() -> void:
	_bind_state()
	falling_bonuses.clear()
	bonus_stack.clear()
	bonus_pointer_frame = 0
	bonus_pointer_elapsed = 0.0
	reset_drop_gate()
	_sync_to_state()


func reset_drop_gate() -> void:
	bonus_drop_cooldown = BonusCatalogScript.BONUS_DROP_GATE_SECONDS
	_sync_to_state()


func force_drop_ready() -> void:
	bonus_drop_cooldown = 0.0
	_sync_to_state()


func update_drop_gate(delta: float) -> void:
	_bind_state()
	if bonus_drop_cooldown > 0.0:
		bonus_drop_cooldown = maxf(0.0, bonus_drop_cooldown - delta)
	_sync_to_state()


func remaining_stock() -> int:
	_bind_state()
	return remaining_bonus_stock


func resolve_drop_for_hit(column: int, row: int, tile_id: int, board_state) -> Dictionary:
	_bind_state()
	if not BrickSemanticsScript.can_spawn_bonus(tile_id):
		return {"action": "clear"}
	if bonus_drop_cooldown > 0.0:
		return {"action": "clear"}

	reset_drop_gate()
	if remaining_bonus_stock <= 0:
		return {"action": "clear"}
	if board_state == null or int(board_state.get("remaining_required_bricks")) <= 0:
		return {"action": "clear"}

	var chance_denominator: int = int((2 * int(board_state.get("remaining_required_bricks"))) / remaining_bonus_stock)
	if chance_denominator <= 0:
		return {"action": "clear"}
	if _rng_next_mod(chance_denominator) != 0:
		return {"action": "clear"}

	var selector: int = _rng_next_mod(BonusCatalogScript.BONUS_SELECTOR_COUNT)
	var attempts := BonusCatalogScript.BONUS_SELECTOR_COUNT
	while attempts > 0:
		if selector >= BonusCatalogScript.BONUS_TYPE_COUNT:
			var tile_selector: int = _rng_next_mod(BonusCatalogScript.CHAIN_SELECTOR_TILE_IDS.size())
			var chain_tile_id := int(BonusCatalogScript.CHAIN_SELECTOR_TILE_IDS[tile_selector])
			if board_state.has_method("convert_to_chain_explosion_tile") \
					and bool(board_state.call("convert_to_chain_explosion_tile", column, row, chain_tile_id)):
				_sync_to_state()
				return {"action": "chain"}
			_sync_to_state()
			return {"action": "clear"}

		if selector < bonus_stock_counts.size() and int(bonus_stock_counts[selector]) > 0:
			bonus_stock_counts[selector] = int(bonus_stock_counts[selector]) - 1
			remaining_bonus_stock -= 1
			_sync_to_state()
			return {
				"action": "spawn",
				"type_id": visible_bonus_type_for_stock_id(selector),
			}

		selector = (selector + 1) % BonusCatalogScript.BONUS_TYPE_COUNT
		attempts -= 1

	_sync_to_state()
	return {"action": "clear"}


func spawn_falling(type_id: int, position: Vector2) -> bool:
	_bind_state()
	compact_falling()
	if falling_bonuses.size() >= BonusCatalogScript.MAX_FALLING_BONUSES:
		return false

	falling_bonuses.append({
		"active": true,
		"type_id": clampi(type_id, 0, BonusCatalogScript.BONUS_TYPE_COUNT - 1),
		"position": position,
		"base_y": position.y,
		"angle": 0,
		"frame": _rng_next_mod_from(bonus_animation_rng, BonusCatalogScript.BONUS_ANIMATION_FRAME_COUNT),
		"frame_elapsed": 0.0,
		"substep_accumulator": 0.0,
	})
	_sync_to_state()
	return true


func update_falling(delta: float, collection_predicate: Callable = Callable()) -> Array[Dictionary]:
	_bind_state()
	var events: Array[Dictionary] = []
	for index in range(falling_bonuses.size()):
		var bonus := falling_bonuses[index]
		if not bool(bonus.get("active", false)):
			continue

		var advance_event := advance_falling_bonus(bonus, delta)
		if not advance_event.is_empty():
			events.append(advance_event)
		if bool(bonus.get("active", false)) \
				and collection_predicate.is_valid() \
				and bool(collection_predicate.call(bonus)) \
				and push_stack(int(bonus.get("type_id", 0))):
			var bonus_position: Vector2 = bonus.get("position", Vector2.ZERO)
			bonus["active"] = false
			events.append({
				"action": "collect",
				"source_x": bonus_position.x,
				"type_id": int(bonus.get("type_id", 0)),
			})

		falling_bonuses[index] = bonus

	compact_falling()
	_sync_to_state()
	return events


func advance_falling_bonus(bonus: Dictionary, delta: float) -> Dictionary:
	var position: Vector2 = bonus.get("position", Vector2.ZERO)
	var next_x := position.x
	var next_y := position.y
	var next_angle := int(bonus.get("angle", 0))
	var base_y := float(bonus.get("base_y", position.y))
	var substep_accumulator := float(bonus.get("substep_accumulator", 0.0)) \
		+ maxf(delta, 0.0) * BonusCatalogScript.ORIGINAL_BONUS_SUBSTEP_HZ
	var substep_count := int(floorf(substep_accumulator))
	substep_accumulator -= float(substep_count)
	var event: Dictionary = {}

	for _step in range(substep_count):
		next_x += BonusCatalogScript.BONUS_STEP_X
		next_angle = (next_angle + BonusCatalogScript.BONUS_ANGLE_STEP) % 360
		next_y = base_y + next_x * BonusCatalogScript.BONUS_WAVE_SCALE * cos(deg_to_rad(float(next_angle)))
		next_y = clampf(next_y, BonusCatalogScript.BONUS_MIN_Y, BonusCatalogScript.BONUS_MAX_Y)
		if next_x > BonusCatalogScript.BONUS_EXPIRE_X:
			bonus["active"] = false
			event = {
				"action": "expire",
				"source_x": next_x,
			}
			substep_accumulator = 0.0
			break

	var frame_elapsed := float(bonus.get("frame_elapsed", 0.0)) + delta
	var frame := int(bonus.get("frame", 0))
	while frame_elapsed >= BonusCatalogScript.BONUS_FALLING_FRAME_SECONDS:
		frame = (frame + 1) % BonusCatalogScript.BONUS_ANIMATION_FRAME_COUNT
		frame_elapsed -= BonusCatalogScript.BONUS_FALLING_FRAME_SECONDS

	bonus["position"] = Vector2(next_x, next_y)
	bonus["angle"] = next_angle
	bonus["frame"] = frame
	bonus["frame_elapsed"] = frame_elapsed
	bonus["substep_accumulator"] = substep_accumulator
	return event


func update_stack(delta: float) -> void:
	_bind_state()
	if bonus_stack.is_empty():
		bonus_pointer_frame = 0
		bonus_pointer_elapsed = 0.0
		_sync_to_state()
		return

	bonus_pointer_elapsed += delta
	while bonus_pointer_elapsed >= BonusCatalogScript.BONUS_POINTER_FRAME_SECONDS:
		bonus_pointer_frame = (bonus_pointer_frame + 1) % BonusCatalogScript.BONUS_ANIMATION_FRAME_COUNT
		bonus_pointer_elapsed -= BonusCatalogScript.BONUS_POINTER_FRAME_SECONDS

	for index in range(bonus_stack.size()):
		var entry := bonus_stack[index]
		var frame_elapsed := float(entry.get("frame_elapsed", 0.0)) + delta
		var frame := int(entry.get("frame", 0))
		while frame_elapsed >= BonusCatalogScript.BONUS_STACK_FRAME_SECONDS:
			frame = (frame + 1) % BonusCatalogScript.BONUS_ANIMATION_FRAME_COUNT
			frame_elapsed -= BonusCatalogScript.BONUS_STACK_FRAME_SECONDS
		entry["frame"] = frame
		entry["frame_elapsed"] = frame_elapsed
		bonus_stack[index] = entry

	_sync_to_state()


func compact_falling() -> void:
	_bind_state()
	var compacted: Array[Dictionary] = []
	for bonus: Dictionary in falling_bonuses:
		if bool(bonus.get("active", false)):
			compacted.append(bonus)
	falling_bonuses.clear()
	falling_bonuses.append_array(compacted)
	_sync_to_state()


func bonus_rect(bonus: Dictionary) -> Rect2:
	return Rect2(bonus.get("position", Vector2.ZERO), Vector2(BonusCatalogScript.BONUS_SIZE, BonusCatalogScript.BONUS_SIZE))


func visible_bonus_type_for_stock_id(stock_id: int) -> int:
	if BonusCatalogScript.BONUS_DISPLAY_INCREMENT_IDS.has(stock_id):
		return (stock_id + 1) % BonusCatalogScript.BONUS_TYPE_COUNT
	return stock_id


func _bind_state() -> void:
	if _state == null:
		return
	falling_bonuses = _state.falling_bonuses
	bonus_stack = _state.bonus_stack
	bonus_stock_counts = _state.bonus_stock_counts
	remaining_bonus_stock = int(_state.remaining_bonus_stock)
	bonus_drop_cooldown = float(_state.bonus_drop_cooldown)
	bonus_pointer_frame = int(_state.bonus_pointer_frame)
	bonus_pointer_elapsed = float(_state.bonus_pointer_elapsed)
	bonus_rng = _state.bonus_rng
	bonus_animation_rng = _state.bonus_animation_rng


func _sync_to_state() -> void:
	if _state == null:
		return
	_state.falling_bonuses = falling_bonuses
	_state.bonus_stack = bonus_stack
	_state.bonus_stock_counts = bonus_stock_counts
	_state.remaining_bonus_stock = remaining_bonus_stock
	_state.bonus_drop_cooldown = bonus_drop_cooldown
	_state.bonus_pointer_frame = bonus_pointer_frame
	_state.bonus_pointer_elapsed = bonus_pointer_elapsed


func _rng_next_mod(modulus: int) -> int:
	return _rng_next_mod_from(bonus_rng, modulus)


func _rng_next_mod_from(rng, modulus: int) -> int:
	if modulus <= 0:
		return 0
	if rng != null and rng.has_method("next_mod"):
		return int(rng.call("next_mod", modulus))
	return 0
