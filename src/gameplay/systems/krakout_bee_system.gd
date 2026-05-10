extends RefCounted
class_name KrakoutBeeSystem

const GameplayStateScript := preload("res://src/gameplay/krakout_gameplay_state.gd")
const BallRulesScript := preload("res://src/gameplay/rules/krakout_ball_rules.gd")
const RacketRulesScript := preload("res://src/gameplay/rules/krakout_racket_rules.gd")
const EnemyRulesScript := preload("res://src/gameplay/rules/krakout_enemy_rules.gd")
const GameplayEventsScript := preload("res://src/gameplay/rules/krakout_gameplay_events.gd")

const BALL_SIZE := BallRulesScript.BALL_SIZE
const BALL_TYPE_STANDARD := BallRulesScript.BALL_TYPE_STANDARD
const ORIGINAL_ENEMY_UPDATE_HZ := EnemyRulesScript.ORIGINAL_ENEMY_UPDATE_HZ
const RACKET_SEGMENT_PIXEL_STEP := RacketRulesScript.RACKET_SEGMENT_PIXEL_STEP
const BEE_FRAME_COUNT := EnemyRulesScript.BEE_FRAME_COUNT
const BEE_FRAME_SECONDS := EnemyRulesScript.BEE_FRAME_SECONDS
const BEE_STEP_X := EnemyRulesScript.BEE_STEP_X
const BEE_SPAWN_X := EnemyRulesScript.BEE_SPAWN_X
const BEE_EXPIRE_X := EnemyRulesScript.BEE_EXPIRE_X
const BEE_SPAWN_DELAY_MAX_SECONDS := EnemyRulesScript.BEE_SPAWN_DELAY_MAX_SECONDS
const BEE_BALL_HIT_SCORE := EnemyRulesScript.BEE_BALL_HIT_SCORE
const BEE_STUN_SCORE := EnemyRulesScript.BEE_STUN_SCORE
const BEE_BALL_COLLISION_RADIUS := EnemyRulesScript.BEE_BALL_COLLISION_RADIUS
const MONSTER_BALL_HIT_MIN_ROTATION_DEGREES := EnemyRulesScript.MONSTER_BALL_HIT_MIN_ROTATION_DEGREES
const MONSTER_BALL_HIT_RANDOM_ROTATION_DEGREES := EnemyRulesScript.MONSTER_BALL_HIT_RANDOM_ROTATION_DEGREES

const IMPACT_EFFECT_KIND_EXPLOSION := 2
const IMPACT_EFFECT_KIND_MONSTER_HIT := IMPACT_EFFECT_KIND_EXPLOSION
const SFX_EVENT_MONSTER_HIT := GameplayEventsScript.SFX_EVENT_MONSTER_HIT
const SFX_EVENT_BEE_SPAWN := GameplayEventsScript.SFX_EVENT_BEE_SPAWN
const SFX_EVENT_BEE_STOP := GameplayEventsScript.SFX_EVENT_BEE_STOP
const SFX_BEE_SPAWN_PAN100 := GameplayEventsScript.SFX_BEE_SPAWN_PAN100

var bees: Array[Dictionary]
var collision_rng
var bee_spawn_delay_remaining := BEE_SPAWN_DELAY_MAX_SECONDS


func _init(shared_bees = [], collision_rng_source = null) -> void:
	if shared_bees is GameplayStateScript:
		var state = shared_bees
		bees = state.bees
		collision_rng = state.collision_rng
	else:
		bees = shared_bees
		collision_rng = collision_rng_source


static func bee_rect(bee: Dictionary) -> Rect2:
	return EnemyRulesScript.bee_rect(bee)


func set_collision_rng_seed(seed_value: int) -> void:
	if collision_rng != null and collision_rng.has_method("set_seed"):
		collision_rng.call("set_seed", seed_value)


func clear(queue_audio_event: Callable = Callable()) -> void:
	if has_active_bee() and queue_audio_event.is_valid():
		queue_audio_event.call(SFX_EVENT_BEE_STOP)
	bees.clear()
	bee_spawn_delay_remaining = BEE_SPAWN_DELAY_MAX_SECONDS


func visible_bees() -> Array[Dictionary]:
	var visible: Array[Dictionary] = []
	for bee: Dictionary in bees:
		if bool(bee.get("active", false)):
			visible.append(bee.duplicate())
	return visible


func active_count() -> int:
	return visible_bees().size()


func force_spawn_ready() -> void:
	bee_spawn_delay_remaining = 0.0


func set_spawn_delay_for_test(seconds: float) -> void:
	bee_spawn_delay_remaining = maxf(0.0, seconds)


func force_bee(position: Vector2, frame: int = 0) -> bool:
	if bees.size() >= 1:
		return false
	bees.append(new_bee(position, frame))
	return true


func update_bees(delta: float, ports: Dictionary, stun_racket: Callable = Callable()) -> void:
	for index in range(bees.size()):
		var bee := bees[index]
		if not bool(bee.get("active", false)):
			continue
		advance_bee(bee, delta, ports)
		if bool(bee.get("active", false)) and bee_rect(bee).intersects(_racket_rect(ports)):
			resolve_bee_racket_hit(index, bee, ports, stun_racket)
			continue
		bees[index] = bee

	compact_bees()

	if bee_spawn_delay_remaining > 0.0:
		bee_spawn_delay_remaining = maxf(0.0, bee_spawn_delay_remaining - delta)
	if bee_spawn_delay_remaining > 0.0 or not bees.is_empty():
		return

	if spawn_next_bee(ports):
		reset_bee_spawn_delay()


func spawn_next_bee(ports: Dictionary) -> bool:
	if not bees.is_empty():
		return false

	bees.append(new_bee(_bee_spawn_position(ports)))
	_queue_audio_event_with_pan100(ports, SFX_EVENT_BEE_SPAWN, SFX_BEE_SPAWN_PAN100)
	return true


func new_bee(position: Vector2, frame: int = 0) -> Dictionary:
	return {
		"active": true,
		"position": position,
		"frame": posmod(frame, BEE_FRAME_COUNT),
		"frame_elapsed": 0.0,
	}


func advance_bee(bee: Dictionary, delta: float, ports: Dictionary) -> void:
	var position: Vector2 = bee.get("position", Vector2.ZERO)
	position.x += BEE_STEP_X * ORIGINAL_ENEMY_UPDATE_HZ * delta
	bee["position"] = position
	if position.x >= BEE_EXPIRE_X:
		bee["active"] = false
		_queue_audio_event(ports, SFX_EVENT_BEE_STOP)
		return

	var frame_elapsed := float(bee.get("frame_elapsed", 0.0)) + delta
	var frame := int(bee.get("frame", 0))
	while frame_elapsed >= BEE_FRAME_SECONDS:
		frame = (frame + 1) % BEE_FRAME_COUNT
		frame_elapsed -= BEE_FRAME_SECONDS
	bee["frame"] = frame
	bee["frame_elapsed"] = frame_elapsed


func resolve_bee_racket_hit(index: int, bee: Dictionary, ports: Dictionary, stun_racket: Callable = Callable()) -> void:
	kill_bee_at_index(index, BEE_STUN_SCORE, ports)
	if stun_racket.is_valid():
		stun_racket.call()


func kill_bee_at_index(index: int, score_value: int, ports: Dictionary) -> void:
	if index < 0 or index >= bees.size():
		return
	var bee := bees[index]
	bee["active"] = false
	bees[index] = bee
	_award_score_with_popup(ports, score_value, bee.get("position", Vector2.ZERO))
	_spawn_impact_effect(ports, bee.get("position", Vector2.ZERO), IMPACT_EFFECT_KIND_MONSTER_HIT)
	_queue_audio_event(ports, SFX_EVENT_BEE_STOP)
	var hit_position: Vector2 = bee.get("position", Vector2.ZERO)
	_queue_audio_event_at_x(ports, SFX_EVENT_MONSTER_HIT, hit_position.x)


func collide_ball_with_bees(ball: Dictionary, ports: Dictionary) -> bool:
	for index in range(bees.size()):
		var bee: Dictionary = bees[index]
		if not bool(bee.get("active", false)):
			continue
		if ball_intersects_enemy_circle(ball, bee.get("position", Vector2.ZERO), BEE_BALL_COLLISION_RADIUS):
			kill_bee_at_index(index, BEE_BALL_HIT_SCORE, ports)
			apply_ball_enemy_response(ball, ports)
			return true
	return false


func ball_intersects_enemy_circle(ball: Dictionary, enemy_position: Vector2, enemy_radius: float) -> bool:
	var ball_position: Vector2 = ball.get("position", Vector2.ZERO)
	var ball_radius := float(ball.get("size", BALL_SIZE)) * 0.5
	return ball_position.distance_to(enemy_position) < ball_radius + enemy_radius


func apply_ball_enemy_response(ball: Dictionary, ports: Dictionary) -> void:
	if _ball_type(ball) == BALL_TYPE_STANDARD:
		rotate_ball_from_enemy_contact(ball, MONSTER_BALL_HIT_MIN_ROTATION_DEGREES, MONSTER_BALL_HIT_RANDOM_ROTATION_DEGREES, ports)


func rotate_ball_from_enemy_contact(
	ball: Dictionary,
	minimum_degrees: int,
	random_degrees: int,
	ports: Dictionary
) -> void:
	var velocity: Vector2 = ball.get("velocity", Vector2.ZERO)
	var speed := _target_speed_for_ball(ball, ports)

	var current_angle := 0
	if not velocity.is_zero_approx():
		current_angle = posmod(int(roundi(rad_to_deg(atan2(-velocity.y, velocity.x)))), 360)
	var rotation_degrees := minimum_degrees
	if random_degrees > 0:
		rotation_degrees += _rng_next_mod(collision_rng, random_degrees)
	var next_angle := posmod(current_angle + rotation_degrees, 360)
	ball["velocity"] = EnemyRulesScript.monster_motion_vector(next_angle, speed)
	ball["target_speed"] = speed


func reset_bee_spawn_delay() -> void:
	bee_spawn_delay_remaining = BEE_SPAWN_DELAY_MAX_SECONDS - float(_rng_next_mod(collision_rng, 10))


func compact_bees() -> void:
	var compacted: Array[Dictionary] = []
	for bee: Dictionary in bees:
		if bool(bee.get("active", false)):
			compacted.append(bee)
	bees.clear()
	bees.append_array(compacted)


func has_active_bee() -> bool:
	for bee: Dictionary in bees:
		if bool(bee.get("active", false)):
			return true
	return false


func _bee_spawn_position(ports: Dictionary) -> Vector2:
	var racket_top := _racket_rect(ports).position.y
	var racket_segments := int(_call_port(ports, "racket_segment_count", [], 10))
	var y := racket_top + floorf((RACKET_SEGMENT_PIXEL_STEP * float(racket_segments) - 24.0) * 0.5)
	return Vector2(BEE_SPAWN_X, y)


func _racket_rect(ports: Dictionary) -> Rect2:
	var result = _call_port(ports, "racket_rect", [], Rect2())
	if result is Rect2:
		return result
	return Rect2()


func _target_speed_for_ball(ball: Dictionary, ports: Dictionary) -> float:
	var result = _call_port(ports, "target_speed_for_ball", [ball], null)
	if result != null:
		return float(result)

	var target_speed := float(ball.get("target_speed", 0.0))
	if target_speed > 0.0:
		return target_speed
	var velocity: Vector2 = ball.get("velocity", Vector2.ZERO)
	if not velocity.is_zero_approx():
		return velocity.length()
	return 0.0


func _award_score_with_popup(ports: Dictionary, points: int, position: Vector2) -> void:
	_call_port(ports, "award_score_with_popup", [points, position], null)


func _spawn_impact_effect(ports: Dictionary, position: Vector2, kind: int) -> void:
	_call_port(ports, "spawn_impact_effect", [position, kind], null)


func _queue_audio_event(ports: Dictionary, event_name: String) -> void:
	_call_port(ports, "queue_audio_event", [event_name], null)


func _queue_audio_event_at_x(ports: Dictionary, event_name: String, source_x: float) -> void:
	_call_port(ports, "queue_audio_event_at_x", [event_name, source_x], null)


func _queue_audio_event_with_pan100(ports: Dictionary, event_name: String, pan100: float) -> void:
	_call_port(ports, "queue_audio_event_with_pan100", [event_name, pan100], null)


func _call_port(ports: Dictionary, key: String, args: Array = [], default_value = null):
	var callable: Callable = ports.get(key, Callable())
	if callable.is_valid():
		return callable.callv(args)
	return default_value


func _ball_type(ball: Dictionary) -> int:
	return int(ball.get("type_id", BALL_TYPE_STANDARD))


func _rng_next_mod(rng, modulus: int) -> int:
	if modulus <= 0:
		return 0
	if rng != null and rng.has_method("next_mod"):
		return int(rng.call("next_mod", modulus))
	return 0
