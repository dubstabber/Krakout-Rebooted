extends RefCounted
class_name KrakoutBallSystem

const GameplayStateScript := preload("res://src/gameplay/krakout_gameplay_state.gd")
const BallRulesScript := preload("res://src/gameplay/rules/krakout_ball_rules.gd")

var balls: Array[Dictionary]
var animation_rng


func _init(shared_balls = [], animation_rng_source = null) -> void:
	if shared_balls is GameplayStateScript:
		var state = shared_balls
		balls = state.balls
		animation_rng = state.ball_animation_rng
	else:
		balls = shared_balls
		animation_rng = animation_rng_source


func clear() -> void:
	balls.clear()


func visible_balls() -> Array[Dictionary]:
	var visible: Array[Dictionary] = []
	for ball: Dictionary in balls:
		if bool(ball.get("active", false)):
			visible.append(ball)
	return visible


func active_count() -> int:
	return visible_balls().size()


func active_non_stricked_count() -> int:
	var count := 0
	for ball: Dictionary in balls:
		if bool(ball.get("active", false)) and is_non_stricked_ball(ball):
			count += 1
	return count


func ball_rect(ball: Dictionary) -> Rect2:
	return BallRulesScript.ball_rect(ball)


func ball_type(ball: Dictionary) -> int:
	return int(ball.get("type_id", BallRulesScript.BALL_TYPE_STANDARD))


func is_non_stricked_ball(ball: Dictionary) -> bool:
	return ball_type(ball) == BallRulesScript.BALL_TYPE_NON_STRICKED \
		and float(ball.get("non_stricked_time_remaining", 0.0)) > 0.0


func force_ball(
	position: Vector2,
	velocity: Vector2,
	size: float,
	type_id: int,
	ball_speed_scale: float,
	target_speed: float
) -> void:
	balls.clear()
	balls.append(new_ball(position, velocity, true, size, type_id, ball_speed_scale, target_speed, 0))


func add_ball(
	position: Vector2,
	velocity: Vector2,
	active: bool,
	size: float,
	type_id: int,
	ball_speed_scale: float,
	target_speed: float
) -> bool:
	if balls.size() >= BallRulesScript.MAX_BALLS:
		return false
	balls.append(new_ball(position, velocity, active, size, type_id, ball_speed_scale, target_speed, _next_frame()))
	return true


func update_animation(delta: float) -> void:
	for index in range(balls.size()):
		var ball := balls[index]
		if not bool(ball.get("active", false)):
			continue

		var frame_elapsed := float(ball.get("frame_elapsed", 0.0)) + delta
		var frame := int(ball.get("frame", 0))
		while frame_elapsed >= BallRulesScript.BALL_FRAME_SECONDS:
			frame = (frame + 1) % BallRulesScript.BALL_FRAME_COUNT
			frame_elapsed -= BallRulesScript.BALL_FRAME_SECONDS
		ball["frame"] = frame
		ball["frame_elapsed"] = frame_elapsed
		balls[index] = ball


func new_ball(
	position: Vector2,
	velocity: Vector2,
	active: bool,
	size: float,
	type_id: int,
	ball_speed_scale: float,
	target_speed: float,
	frame: int
) -> Dictionary:
	return {
		"active": active,
		"position": position,
		"velocity": velocity,
		"size": size,
		"type_id": type_id,
		"previous_type_id": BallRulesScript.BALL_TYPE_STANDARD,
		"non_stricked_time_remaining": 0.0,
		"frame": frame,
		"frame_elapsed": 0.0,
		"speed_scale": ball_speed_scale,
		"target_speed": target_speed,
		"speed_hit_count": 0,
		"magnet_attached": false,
	}


func _next_frame() -> int:
	if animation_rng != null and animation_rng.has_method("next_mod"):
		return int(animation_rng.call("next_mod", BallRulesScript.BALL_FRAME_COUNT))
	return 0
