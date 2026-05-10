extends RefCounted
class_name KrakoutRacketRules

const PlayfieldSpecScript := preload("res://src/playfield/krakout_playfield_spec.gd")

const RACKET_X := 570.0
const RACKET_WIDTH := 16.0
const RACKET_SEGMENT_PIXEL_STEP := 5.0
const RACKET_SEGMENT_MARGIN := 24.0
const RACKET_DEFAULT_SEGMENTS := 10
const RACKET_HEIGHT := RACKET_SEGMENT_PIXEL_STEP * RACKET_DEFAULT_SEGMENTS + RACKET_SEGMENT_MARGIN
const RACKET_MIN_SEGMENTS := 1
const RACKET_SHRINK_LIMIT_SEGMENTS := 3
const RACKET_EXPAND_LIMIT_SEGMENTS := 36
const RACKET_MAX_SEGMENTS := 37
const RACKET_BONUS_STEP_SEGMENTS := 3
const RACKET_MIN_Y := PlayfieldSpecScript.WALL_INNER_TOP_Y
const RACKET_MAX_BOTTOM := PlayfieldSpecScript.WALL_INNER_BOTTOM_Y
const RACKET_READY_CENTER_Y := (PlayfieldSpecScript.WALL_INNER_TOP_Y + PlayfieldSpecScript.WALL_INNER_BOTTOM_Y) * 0.5
const RACKET_READY_DEFAULT_Y := RACKET_READY_CENTER_Y - RACKET_HEIGHT * 0.5
const RACKET_HIT_RECOIL_PIXELS := 5.0
const RACKET_HIT_RECOIL_STEP_SECONDS := 0.015
const RACKET_HIT_RECOIL_STEP_PIXELS := 1.0
const RACKET_BOUNCE_MAX_Y_SPEED := 180.0
const RACKET_VISUAL_MODE_NORMAL := 0
const RACKET_VISUAL_MODE_SHOOTING_CONTINUOUS := 1
const RACKET_VISUAL_MODE_SHOOTING_ONE_SHOT := 2
const RACKET_VISUAL_MODE_MAGNET := 3
const RACKET_VISUAL_FRAME_SECONDS := 0.05
const RACKET_VISUAL_MAX_FRAME := 4
const RACKET_MAGNET_VISUAL_FRAME_COUNT := 20
const MAGNET_ATTACHED_Y_STEP_PER_UPDATE := 1.0
const MAGNET_ATTACHED_X_PULL_LEFT_STEP_PER_UPDATE := 2.0
const MAGNET_ATTACHED_X_PULL_RIGHT_STEP_PER_UPDATE := 1.0
const DOUBLE_PADDLE_OFFSET_X := -20.0
const DOUBLE_PADDLE_MIN_X := 77.0
const DOUBLE_PADDLE_MOUSE_X_MULTIPLIER := 2.0
const DRUNK_PADDLE_DURATION_SECONDS := 30.0


static func height_for_segments(segment_count: int) -> float:
	return RACKET_SEGMENT_PIXEL_STEP * float(segment_count) + RACKET_SEGMENT_MARGIN


static func clamped_top_y(racket_y: float, segment_count: int) -> float:
	return clampf(racket_y, RACKET_MIN_Y, RACKET_MAX_BOTTOM - height_for_segments(segment_count))


static func ready_top_y(segment_count: int = RACKET_DEFAULT_SEGMENTS) -> float:
	return clamped_top_y(RACKET_READY_CENTER_Y - height_for_segments(segment_count) * 0.5, segment_count)


static func bounce_velocity(ball_hit_rect: Rect2, racket_hit_rect: Rect2, speed: float) -> Vector2:
	var racket_height := racket_hit_rect.size.y
	var racket_center := racket_hit_rect.get_center().y
	var ball_center := ball_hit_rect.get_center().y
	var normalized_hit := clampf((ball_center - racket_center) / (racket_height * 0.5), -1.0, 1.0)
	var max_y_speed := minf(RACKET_BOUNCE_MAX_Y_SPEED, speed * 0.95)
	var velocity_y := normalized_hit * max_y_speed
	var velocity_x := -sqrt(maxf(0.0, speed * speed - velocity_y * velocity_y))
	return Vector2(velocity_x, velocity_y)
