extends RefCounted
class_name KrakoutPlayfieldSpec

const VIEWPORT_SIZE := Vector2i(640, 480)
const GRID_COLUMNS := 20
const GRID_ROWS := 13
const GRID_ORIGIN := Vector2(47, 63)
const BRICK_SIZE := Vector2(20, 30)
const GRID_SIZE := Vector2(400, 390)
const DEFAULT_EPISODE := "Default"
const DEFAULT_LEVEL_NUMBER := 1


static func grid_rect() -> Rect2:
	return Rect2(GRID_ORIGIN, GRID_SIZE)


static func brick_rect(column: int, row: int) -> Rect2:
	return Rect2(
		GRID_ORIGIN + Vector2(column * BRICK_SIZE.x, row * BRICK_SIZE.y),
		BRICK_SIZE
	)
