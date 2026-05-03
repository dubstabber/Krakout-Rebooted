extends RefCounted
class_name KrakoutBrickSemantics

const FIRST_INACTIVE_TILE_ID := 162
const NON_REQUIRED_TILE_IDS := {
	8: true,
	39: true,
	40: true,
	69: true,
}
const CHAIN_EXPLOSION_TILE_IDS := {
	43: true,
	68: true,
}
const HIT_KIND_INACTIVE := "inactive"
const HIT_KIND_NORMAL := "normal"
const HIT_KIND_FORCE_BREAK_ONLY := "force_break_only"
const HIT_KIND_DOWNGRADE := "downgrade"
const HIT_KIND_CHAIN_EXPLOSION := "chain_explosion"
const BEHAVIOR_CASE_BY_TILE_ID := [
	0, 0, 0, 0, 0, 0, 0, 1, 0, 0,
	0, 0, 0, 0, 2, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 1, 1,
	0, 3, 4, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 4, 1, 5,
	6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
	16, 17, 18, 19, 20, 21, 22, 23, 24, 25,
	26, 27, 28, 0, 0, 0, 0, 0, 0, 0,
	29, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 30, 0, 0, 0, 31, 0, 32, 0,
	33, 0, 34, 0, 35, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0,
]
const DOWNGRADE_TILE_ID_BY_BEHAVIOR_CASE := {
	2: 14,
	3: 44,
	5: 90,
	6: 82,
	7: 83,
	8: 84,
	9: 85,
	10: 86,
	11: 87,
	12: 88,
	13: 89,
	14: 91,
	15: 92,
	16: 93,
	17: 16,
	18: 17,
	19: 18,
	20: 19,
	21: 20,
	22: 21,
	23: 22,
	24: 23,
	25: 24,
	26: 25,
	27: 26,
	28: 27,
	29: 114,
	30: 132,
	31: 136,
	32: 138,
	33: 140,
	34: 142,
	35: 144,
}


static func is_active_tile(tile_id: int) -> bool:
	return tile_id > 0 and tile_id < FIRST_INACTIVE_TILE_ID


static func is_required_tile(tile_id: int) -> bool:
	return is_active_tile(tile_id) and not NON_REQUIRED_TILE_IDS.has(tile_id)


static func is_chain_explosion_tile(tile_id: int) -> bool:
	return CHAIN_EXPLOSION_TILE_IDS.has(tile_id)


static func is_force_break_only_tile(tile_id: int) -> bool:
	return behavior_case(tile_id) == 1


static func is_downgrade_tile(tile_id: int) -> bool:
	return DOWNGRADE_TILE_ID_BY_BEHAVIOR_CASE.has(behavior_case(tile_id))


static func behavior_case(tile_id: int) -> int:
	if tile_id < FIRST_INACTIVE_TILE_ID and tile_id > 0:
		return int(BEHAVIOR_CASE_BY_TILE_ID[tile_id - 1])
	return -1


static func hit_kind(tile_id: int) -> String:
	if not is_active_tile(tile_id):
		return HIT_KIND_INACTIVE
	if is_chain_explosion_tile(tile_id):
		return HIT_KIND_CHAIN_EXPLOSION
	if is_force_break_only_tile(tile_id):
		return HIT_KIND_FORCE_BREAK_ONLY
	if is_downgrade_tile(tile_id):
		return HIT_KIND_DOWNGRADE
	return HIT_KIND_NORMAL


static func downgraded_tile_id(tile_id: int) -> int:
	return int(DOWNGRADE_TILE_ID_BY_BEHAVIOR_CASE.get(behavior_case(tile_id), 0))


static func can_spawn_bonus(tile_id: int) -> bool:
	return is_active_tile(tile_id) and behavior_case(tile_id) == 0
