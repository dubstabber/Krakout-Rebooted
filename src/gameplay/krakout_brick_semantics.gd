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


static func is_active_tile(tile_id: int) -> bool:
	return tile_id > 0 and tile_id < FIRST_INACTIVE_TILE_ID


static func is_required_tile(tile_id: int) -> bool:
	return is_active_tile(tile_id) and not NON_REQUIRED_TILE_IDS.has(tile_id)


static func is_chain_explosion_tile(tile_id: int) -> bool:
	return CHAIN_EXPLOSION_TILE_IDS.has(tile_id)


static func behavior_case(tile_id: int) -> int:
	if tile_id < FIRST_INACTIVE_TILE_ID and tile_id > 0:
		return int(BEHAVIOR_CASE_BY_TILE_ID[tile_id - 1])
	return -1


static func can_spawn_bonus(tile_id: int) -> bool:
	return is_active_tile(tile_id) and behavior_case(tile_id) == 0
