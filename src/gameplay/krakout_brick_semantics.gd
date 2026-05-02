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


static func is_active_tile(tile_id: int) -> bool:
	return tile_id > 0 and tile_id < FIRST_INACTIVE_TILE_ID


static func is_required_tile(tile_id: int) -> bool:
	return is_active_tile(tile_id) and not NON_REQUIRED_TILE_IDS.has(tile_id)


static func is_chain_explosion_tile(tile_id: int) -> bool:
	return CHAIN_EXPLOSION_TILE_IDS.has(tile_id)
