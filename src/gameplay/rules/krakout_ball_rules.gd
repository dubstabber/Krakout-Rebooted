extends RefCounted
class_name KrakoutBallRules

const PlayfieldSpecScript := preload("res://src/playfield/krakout_playfield_spec.gd")

const MAX_BALLS := 5
const BALL_SIZE := 18.0
const BALL_MIN_SIZE := 10.0
const BALL_MAX_SIZE := 42.0
const BALL_SIZE_STEP := 8.0
const BALL_FRAME_COUNT := 10
const BALL_TYPE_STANDARD := 0
const BALL_TYPE_FIREBALL := 1
const BALL_TYPE_NON_STRICKED := 2
const BALL_DEFAULT_SPEED_SCALE := 2.0
const BALL_MIN_SPEED_SCALE := 2.0
const BALL_MAX_SPEED_SCALE := 6.0
const BALL_SPEED_STEP := 1.0
const NON_STRICKED_DURATION_SECONDS := 8.0
const BALL_TOP_Y := PlayfieldSpecScript.WALL_INNER_TOP_Y
const BALL_BOTTOM_Y := PlayfieldSpecScript.WALL_INNER_BOTTOM_Y
const BALL_LEFT_X := PlayfieldSpecScript.WALL_INNER_LEFT_X
const BALL_LOST_X := 640.0
const BACK_WALL_BOUNCE_X := PlayfieldSpecScript.WALL_INNER_RIGHT_X
const READY_BALL_GAP := 2.0
const ORIGINAL_UPDATE_HZ := 50.0
const BALL_FRAME_SECONDS := 0.1
const BALL_TRACK_SLOT_COUNT := 50
const BALL_TRACK_FRAME_COUNT := 12
const BALL_TRACK_SPAWN_SECONDS := 0.03
const BALL_TRACK_FRAME_SECONDS := 0.03
const ORIGINAL_BALL_STEPS_PER_UPDATE := 3.0
const ORIGINAL_DEFAULT_BALL_SPEED_PER_TICK := 2.5
const DEFAULT_BALL_LAUNCH_TABLE_INDEX := 250
const DEFAULT_BALL_LAUNCH_DIRECTION := Vector2(-0.93969262, 0.34202015)
const ORIGINAL_BALL_SPEEDUP_HIT_LIMIT := 100
const ORIGINAL_BALL_SPEEDUP_PER_TICK := 0.3
const ORIGINAL_BALL_MAX_SPEED_PER_TICK := 6.0
const DEFAULT_BALL_VELOCITY := DEFAULT_BALL_LAUNCH_DIRECTION \
	* ORIGINAL_DEFAULT_BALL_SPEED_PER_TICK \
	* ORIGINAL_BALL_STEPS_PER_UPDATE \
	* ORIGINAL_UPDATE_HZ


static func ball_rect(ball: Dictionary, default_size := BALL_SIZE) -> Rect2:
	var size := float(ball.get("size", default_size))
	return Rect2(ball.get("position", Vector2.ZERO), Vector2(size, size))


static func velocity_for_speed(base_velocity: Vector2, target_speed: float) -> Vector2:
	if base_velocity.is_zero_approx():
		return Vector2.ZERO
	return base_velocity.normalized() * target_speed
