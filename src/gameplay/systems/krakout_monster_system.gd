extends RefCounted
class_name KrakoutMonsterSystem

const GameplayStateScript := preload("res://src/gameplay/krakout_gameplay_state.gd")
const PlayfieldSpecScript := preload("res://src/playfield/krakout_playfield_spec.gd")
const BallRulesScript := preload("res://src/gameplay/rules/krakout_ball_rules.gd")
const EnemyRulesScript := preload("res://src/gameplay/rules/krakout_enemy_rules.gd")
const GameplayEventsScript := preload("res://src/gameplay/rules/krakout_gameplay_events.gd")

const BALL_SIZE := BallRulesScript.BALL_SIZE
const BALL_TYPE_STANDARD := BallRulesScript.BALL_TYPE_STANDARD
const BALL_TYPE_NON_STRICKED := BallRulesScript.BALL_TYPE_NON_STRICKED
const ORIGINAL_ENEMY_UPDATE_HZ := EnemyRulesScript.ORIGINAL_ENEMY_UPDATE_HZ
const MAX_MONSTERS := EnemyRulesScript.MAX_MONSTERS
const MONSTER_TYPE_COUNT := EnemyRulesScript.MONSTER_TYPE_COUNT
const MONSTER_SIZE := EnemyRulesScript.MONSTER_SIZE
const MONSTER_COLLISION_SIZE := EnemyRulesScript.MONSTER_COLLISION_SIZE
const MONSTER_COLLISION_OFFSET := EnemyRulesScript.MONSTER_COLLISION_OFFSET
const MONSTER_TYPE9_COLLISION_SIZE := EnemyRulesScript.MONSTER_TYPE9_COLLISION_SIZE
const MONSTER_TYPE9_COLLISION_OFFSET := EnemyRulesScript.MONSTER_TYPE9_COLLISION_OFFSET
const MONSTER_BALL_COLLISION_RADIUS := EnemyRulesScript.MONSTER_BALL_COLLISION_RADIUS
const MONSTER_LIFETIME_SECONDS := EnemyRulesScript.MONSTER_LIFETIME_SECONDS
const MONSTER_SPAWN_INTERVAL_SECONDS := EnemyRulesScript.MONSTER_SPAWN_INTERVAL_SECONDS
const MONSTER_FRAME_SECONDS := EnemyRulesScript.MONSTER_FRAME_SECONDS
const MONSTER_DEFAULT_SPEED := EnemyRulesScript.MONSTER_DEFAULT_SPEED
const MONSTER_TYPE3_RIGHT_LIMIT := EnemyRulesScript.MONSTER_TYPE3_RIGHT_LIMIT
const MONSTER_TYPE3_VERTICAL_JITTER_BASE := EnemyRulesScript.MONSTER_TYPE3_VERTICAL_JITTER_BASE
const MONSTER_TYPE3_VERTICAL_JITTER_RANGE := EnemyRulesScript.MONSTER_TYPE3_VERTICAL_JITTER_RANGE
const MONSTER_TRACKING_TURN_STEP_DEGREES := EnemyRulesScript.MONSTER_TRACKING_TURN_STEP_DEGREES
const MONSTER_SCORE := EnemyRulesScript.MONSTER_SCORE
const MONSTER_BALL_HIT_SCORE := EnemyRulesScript.MONSTER_BALL_HIT_SCORE
const MONSTER_TYPE6_SCORE_STEP := EnemyRulesScript.MONSTER_TYPE6_SCORE_STEP
const MONSTER_TYPE6_SCORE_VARIANTS := EnemyRulesScript.MONSTER_TYPE6_SCORE_VARIANTS
const MONSTER_TYPE9_STUN_SCORE := EnemyRulesScript.MONSTER_TYPE9_STUN_SCORE
const MONSTER_BALL_HIT_MIN_ROTATION_DEGREES := EnemyRulesScript.MONSTER_BALL_HIT_MIN_ROTATION_DEGREES
const MONSTER_BALL_HIT_RANDOM_ROTATION_DEGREES := EnemyRulesScript.MONSTER_BALL_HIT_RANDOM_ROTATION_DEGREES
const MONSTER_TYPE1_BALL_ROTATION_DEGREES := EnemyRulesScript.MONSTER_TYPE1_BALL_ROTATION_DEGREES
const MONSTER_MOTION_ANGLE := EnemyRulesScript.MONSTER_MOTION_ANGLE
const MONSTER_MOTION_PADDLE_FOLLOW := EnemyRulesScript.MONSTER_MOTION_PADDLE_FOLLOW
const MONSTER_MOTION_BALL_TRACK := EnemyRulesScript.MONSTER_MOTION_BALL_TRACK
const MONSTER_SCORE_MODE_DEFAULT := EnemyRulesScript.MONSTER_SCORE_MODE_DEFAULT
const MONSTER_SCORE_MODE_RANDOM_TYPE6 := EnemyRulesScript.MONSTER_SCORE_MODE_RANDOM_TYPE6
const MONSTER_SCORE_MODE_STUN_TYPE9 := EnemyRulesScript.MONSTER_SCORE_MODE_STUN_TYPE9
const MONSTER_DEFAULT_TRAIT := EnemyRulesScript.MONSTER_DEFAULT_TRAIT
const MONSTER_TRAITS := EnemyRulesScript.MONSTER_TRAITS

const IMPACT_EFFECT_KIND_MONSTER_SPAWN := 0
const IMPACT_EFFECT_KIND_MONSTER_TIMEOUT := 1
const IMPACT_EFFECT_KIND_EXPLOSION := 2
const IMPACT_EFFECT_KIND_MONSTER_HIT := IMPACT_EFFECT_KIND_EXPLOSION
const SFX_EVENT_PROJECTILE_HIT := GameplayEventsScript.SFX_EVENT_PROJECTILE_HIT
const SFX_EVENT_MONSTER_SPAWN := GameplayEventsScript.SFX_EVENT_MONSTER_SPAWN
const SFX_EVENT_MONSTER_EXPIRE := GameplayEventsScript.SFX_EVENT_MONSTER_EXPIRE
const SFX_EVENT_MONSTER_HIT := GameplayEventsScript.SFX_EVENT_MONSTER_HIT

var monsters: Array[Dictionary]
var monster_rng
var collision_rng
var monster_spawn_cooldown := MONSTER_SPAWN_INTERVAL_SECONDS


func _init(shared_monsters = [], monster_rng_source = null, collision_rng_source = null) -> void:
	if shared_monsters is GameplayStateScript:
		var state = shared_monsters
		monsters = state.monsters
		monster_rng = state.monster_rng
		collision_rng = state.collision_rng
	else:
		monsters = shared_monsters
		monster_rng = monster_rng_source
		collision_rng = collision_rng_source


static func monster_trait_for_type(type_id: int) -> Dictionary:
	return EnemyRulesScript.monster_trait_for_type(type_id)


static func monster_spawn_pool() -> Array[int]:
	return EnemyRulesScript.monster_spawn_pool()


static func monster_frame_count_for_type(type_id: int) -> int:
	return EnemyRulesScript.monster_frame_count_for_type(type_id)


static func monster_motion_mode_for_type(type_id: int) -> String:
	return EnemyRulesScript.monster_motion_mode_for_type(type_id)


static func monster_collision_offset_for_type(type_id: int) -> Vector2:
	return EnemyRulesScript.monster_collision_offset_for_type(type_id)


static func monster_collision_size_for_type(type_id: int) -> Vector2:
	return EnemyRulesScript.monster_collision_size_for_type(type_id)


static func monster_stuns_racket(type_id: int) -> bool:
	return EnemyRulesScript.monster_stuns_racket(type_id)


static func monster_type_is_original_spawned(type_id: int) -> bool:
	return EnemyRulesScript.monster_type_is_original_spawned(type_id)


static func monster_motion_vector(angle: float, speed: float) -> Vector2:
	return EnemyRulesScript.monster_motion_vector(angle, speed)


static func monster_rect(monster: Dictionary) -> Rect2:
	return EnemyRulesScript.monster_rect(monster)


static func monster_score_mode_for_type(type_id: int, contact_key: String) -> String:
	return EnemyRulesScript.monster_score_mode_for_type(type_id, contact_key)


static func monster_trait_value(type_id: int, key: String, default_value):
	if MONSTER_TRAITS.has(type_id):
		var monster_trait: Dictionary = MONSTER_TRAITS[type_id]
		if monster_trait.has(key):
			return monster_trait[key]
	if MONSTER_DEFAULT_TRAIT.has(key):
		return MONSTER_DEFAULT_TRAIT[key]
	return default_value


func set_monster_rng_seed(seed_value: int) -> void:
	if monster_rng != null and monster_rng.has_method("set_seed"):
		monster_rng.call("set_seed", seed_value)


func set_collision_rng_seed(seed_value: int) -> void:
	if collision_rng != null and collision_rng.has_method("set_seed"):
		collision_rng.call("set_seed", seed_value)


func clear() -> void:
	monsters.clear()
	monster_spawn_cooldown = MONSTER_SPAWN_INTERVAL_SECONDS


func visible_monsters() -> Array[Dictionary]:
	var visible: Array[Dictionary] = []
	for monster: Dictionary in monsters:
		if bool(monster.get("active", false)):
			visible.append(monster.duplicate())
	return visible


func active_count() -> int:
	return visible_monsters().size()


func force_spawn_ready() -> void:
	monster_spawn_cooldown = 0.0


func set_spawn_cooldown_for_test(seconds: float) -> void:
	monster_spawn_cooldown = maxf(0.0, seconds)


func set_monster_age_for_test(index: int, age: float) -> bool:
	if index < 0 or index >= monsters.size():
		return false
	var monster := monsters[index]
	monster["age"] = maxf(0.0, age)
	monsters[index] = monster
	return true


func force_monster(position: Vector2, type_id: int = 3, angle: int = 0) -> bool:
	if monsters.size() >= MAX_MONSTERS:
		return false
	monsters.append(new_monster(position, type_id, angle))
	return true


func update_monsters(delta: float, balls: Array, ports: Dictionary, stun_racket: Callable = Callable()) -> void:
	for index in range(monsters.size()):
		var monster := monsters[index]
		if not bool(monster.get("active", false)):
			continue
		advance_monster(monster, delta, balls, ports)
		if bool(monster.get("active", false)) and collide_monster_with_racket(index, monster, ports, stun_racket):
			continue
		monsters[index] = monster

	compact_monsters()

	monster_spawn_cooldown = maxf(0.0, monster_spawn_cooldown - delta)
	if monster_spawn_cooldown > 0.0:
		return

	spawn_next_monster(ports)
	monster_spawn_cooldown = MONSTER_SPAWN_INTERVAL_SECONDS


func spawn_next_monster(ports: Dictionary) -> bool:
	if monsters.size() >= MAX_MONSTERS:
		return false

	var type_id := next_monster_type()
	var position := Vector2(
		260.0 + float(_rng_next_mod(monster_rng, 200)),
		100.0 + float(_rng_next_mod(monster_rng, 320))
	)
	var angle_seed := _rng_next_mod(monster_rng, 4)
	var angle := 0
	if angle_seed >= 2:
		angle = 330 + _rng_next_mod(monster_rng, 60)
	else:
		angle = 150 + _rng_next_mod(monster_rng, 60)

	monsters.append(new_monster(position, type_id, angle))
	_spawn_impact_effect(ports, position, IMPACT_EFFECT_KIND_MONSTER_SPAWN)
	_queue_audio_event_at_x(ports, SFX_EVENT_MONSTER_SPAWN, position.x)
	return true


func next_monster_type() -> int:
	return int(_rng_next_mod(monster_rng, MONSTER_TYPE_COUNT))


func new_monster(position: Vector2, type_id: int, angle: int) -> Dictionary:
	return {
		"active": true,
		"type_id": type_id,
		"position": position,
		"frame": 0,
		"frame_elapsed": 0.0,
		"angle": float(posmod(angle, 360)),
		"speed": MONSTER_DEFAULT_SPEED,
		"age": 0.0,
	}


func advance_monster(monster: Dictionary, delta: float, balls: Array, ports: Dictionary) -> void:
	var age := float(monster.get("age", 0.0)) + delta
	monster["age"] = age
	if age >= MONSTER_LIFETIME_SECONDS:
		var expire_position: Vector2 = monster.get("position", Vector2.ZERO)
		monster["active"] = false
		_spawn_impact_effect(ports, monster.get("position", Vector2.ZERO), IMPACT_EFFECT_KIND_MONSTER_TIMEOUT)
		_queue_audio_event_at_x(ports, SFX_EVENT_MONSTER_EXPIRE, expire_position.x)
		return

	var type_id := int(monster.get("type_id", 0))
	var frame_elapsed := float(monster.get("frame_elapsed", 0.0)) + delta
	var frame := int(monster.get("frame", 0))
	var frame_count := monster_frame_count_for_type(type_id)
	while frame_elapsed >= MONSTER_FRAME_SECONDS:
		frame = (frame + 1) % frame_count
		frame_elapsed -= MONSTER_FRAME_SECONDS
	monster["frame"] = frame
	monster["frame_elapsed"] = frame_elapsed

	var position: Vector2 = monster.get("position", Vector2.ZERO)
	var speed := float(monster.get("speed", MONSTER_DEFAULT_SPEED))
	var tick_scale := ORIGINAL_ENEMY_UPDATE_HZ * delta
	var distance := speed * tick_scale
	var angle := float(monster.get("angle", 0.0))
	match monster_motion_mode_for_type(type_id):
		MONSTER_MOTION_PADDLE_FOLLOW:
			if distance > 0.0:
				var horizontal_limit := MONSTER_TYPE3_RIGHT_LIMIT + speed
				if position.x <= MONSTER_TYPE3_RIGHT_LIMIT:
					position.x = minf(position.x + distance, horizontal_limit)

				var jitter := float(_rng_next_mod(monster_rng, MONSTER_TYPE3_VERTICAL_JITTER_RANGE))
				var probe_y := position.y + MONSTER_SIZE.y * 0.5 + MONSTER_TYPE3_VERTICAL_JITTER_BASE + jitter
				if _racket_rect(ports).get_center().y > probe_y:
					position.y += distance
					angle = 270.0
				else:
					position.y -= distance
					angle = 90.0
			else:
				position += monster_motion_vector(angle, distance)
		MONSTER_MOTION_BALL_TRACK:
			angle = tracking_angle_for_monster(monster, angle, tick_scale, balls, ports)
			position += monster_motion_vector(angle, distance)
		_:
			position += monster_motion_vector(angle, distance)

	monster["position"] = position
	monster["angle"] = angle
	collide_monster_with_boundaries(monster)


func collide_monster_with_boundaries(monster: Dictionary) -> bool:
	var position: Vector2 = monster.get("position", Vector2.ZERO)
	var type_id := int(monster.get("type_id", 0))
	var rect := Rect2(position, MONSTER_SIZE)
	var hit_horizontal := false
	var hit_vertical := false

	if rect.position.x < PlayfieldSpecScript.WALL_INNER_LEFT_X:
		position.x = PlayfieldSpecScript.WALL_INNER_LEFT_X
		hit_horizontal = true
	elif rect.end.x > PlayfieldSpecScript.WALL_INNER_RIGHT_X:
		position.x = PlayfieldSpecScript.WALL_INNER_RIGHT_X - MONSTER_SIZE.x
		hit_horizontal = true

	if rect.position.y < PlayfieldSpecScript.WALL_INNER_TOP_Y:
		position.y = PlayfieldSpecScript.WALL_INNER_TOP_Y
		hit_vertical = true
	elif rect.end.y > PlayfieldSpecScript.WALL_INNER_BOTTOM_Y:
		position.y = PlayfieldSpecScript.WALL_INNER_BOTTOM_Y - MONSTER_SIZE.y
		hit_vertical = true

	if not hit_horizontal and not hit_vertical:
		return false

	monster["position"] = position
	if type_id != 10:
		var angle := float(monster.get("angle", 0.0))
		if hit_horizontal:
			angle = fposmod(180.0 - angle, 360.0)
		if hit_vertical:
			angle = fposmod(360.0 - angle, 360.0)
		monster["angle"] = angle
	return true


func tracking_angle_for_monster(monster: Dictionary, current_angle: float, tick_scale: float, balls: Array, ports: Dictionary) -> float:
	var monster_center := Vector2(monster.get("position", Vector2.ZERO)) + MONSTER_SIZE * 0.5
	var target_position := nearest_trackable_ball_center(monster_center, balls, ports)
	if target_position == Vector2.INF:
		return current_angle

	var target_delta := target_position - monster_center
	if target_delta.is_zero_approx():
		return current_angle

	var target_angle := fposmod(rad_to_deg(atan2(-target_delta.y, target_delta.x)), 360.0)
	var difference := fposmod(target_angle - current_angle + 540.0, 360.0) - 180.0
	var turn_step := MONSTER_TRACKING_TURN_STEP_DEGREES * tick_scale
	if difference > 0:
		current_angle += minf(turn_step, difference)
	elif difference < 0:
		current_angle -= minf(turn_step, -difference)
	return fposmod(current_angle, 360.0)


func nearest_trackable_ball_center(monster_center: Vector2, balls: Array, ports: Dictionary) -> Vector2:
	var nearest_position := Vector2.INF
	var nearest_distance := INF
	for ball: Dictionary in balls:
		if not bool(ball.get("active", false)):
			continue
		if _ball_type(ball) == BALL_TYPE_NON_STRICKED:
			continue
		var ball_center := _ball_rect(ball).get_center()
		var distance := monster_center.distance_to(ball_center)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_position = ball_center
	return nearest_position


func collide_ball_with_monsters(ball: Dictionary, balls: Array, ports: Dictionary) -> bool:
	for index in range(monsters.size()):
		var monster: Dictionary = monsters[index]
		if not bool(monster.get("active", false)):
			continue
		if ball_intersects_enemy_circle(ball, monster.get("position", Vector2.ZERO), MONSTER_BALL_COLLISION_RADIUS):
			var type_id := int(monster.get("type_id", 0))
			var score_value := score_for_monster_ball_contact(monster)
			if monster_survives_ball_contact(monster):
				_award_score_with_popup(ports, score_value, monster.get("position", Vector2.ZERO))
			else:
				kill_monster_at_index(index, score_value, ports)
			apply_ball_enemy_response(ball, type_id, ports)
			return true
	return false


func ball_intersects_enemy_circle(ball: Dictionary, enemy_position: Vector2, enemy_radius: float) -> bool:
	var ball_position: Vector2 = ball.get("position", Vector2.ZERO)
	var ball_radius := float(ball.get("size", BALL_SIZE)) * 0.5
	return ball_position.distance_to(enemy_position) < ball_radius + enemy_radius


func collide_projectile_with_monsters(projectile: Dictionary, ports: Dictionary) -> bool:
	var rect := _projectile_rect(projectile, ports)
	for index in range(monsters.size()):
		var monster: Dictionary = monsters[index]
		if not bool(monster.get("active", false)):
			continue
		if rect.intersects(monster_rect(monster)):
			kill_monster_at_index(index, score_for_monster_paddle_contact(monster), ports)
			_queue_audio_event_at_x(ports, SFX_EVENT_PROJECTILE_HIT, _projectile_rect(projectile, ports).position.x)
			return true
	return false


func collide_monster_with_racket(index: int, monster: Dictionary, ports: Dictionary, stun_racket: Callable = Callable()) -> bool:
	if not monster_rect(monster).intersects(_racket_rect(ports)):
		return false

	kill_monster_at_index(index, score_for_monster_paddle_contact(monster), ports)
	if monster_stuns_racket(int(monster.get("type_id", 0))) and stun_racket.is_valid():
		stun_racket.call()
	return true


func kill_monster_at_index(index: int, score_value: int, ports: Dictionary) -> void:
	if index < 0 or index >= monsters.size():
		return
	var monster := monsters[index]
	monster["active"] = false
	monsters[index] = monster
	var final_score := score_value if score_value >= 0 else score_for_monster_paddle_contact(monster)
	_award_score_with_popup(ports, final_score, monster.get("position", Vector2.ZERO))
	_spawn_impact_effect(ports, monster.get("position", Vector2.ZERO), IMPACT_EFFECT_KIND_MONSTER_HIT)
	var hit_position: Vector2 = monster.get("position", Vector2.ZERO)
	_queue_audio_event_at_x(ports, SFX_EVENT_MONSTER_HIT, hit_position.x)


func score_for_monster_paddle_contact(monster: Dictionary) -> int:
	match monster_score_mode_for_type(int(monster.get("type_id", 0)), "paddle_score_mode"):
		MONSTER_SCORE_MODE_RANDOM_TYPE6:
			return MONSTER_TYPE6_SCORE_STEP * (_rng_next_mod(monster_rng, MONSTER_TYPE6_SCORE_VARIANTS) + 1)
		MONSTER_SCORE_MODE_STUN_TYPE9:
			return MONSTER_TYPE9_STUN_SCORE
		_:
			return MONSTER_SCORE


func score_for_monster_ball_contact(monster: Dictionary) -> int:
	match monster_score_mode_for_type(int(monster.get("type_id", 0)), "ball_score_mode"):
		MONSTER_SCORE_MODE_RANDOM_TYPE6:
			return MONSTER_TYPE6_SCORE_STEP * (_rng_next_mod(collision_rng, MONSTER_TYPE6_SCORE_VARIANTS) + 1)
		_:
			return MONSTER_BALL_HIT_SCORE


func monster_survives_ball_contact(monster: Dictionary) -> bool:
	return int(monster.get("type_id", 0)) == 1


func apply_ball_enemy_response(ball: Dictionary, enemy_type_id: int, ports: Dictionary) -> void:
	if enemy_type_id == 1:
		rotate_ball_from_enemy_contact(ball, MONSTER_TYPE1_BALL_ROTATION_DEGREES, 0, ports)
	elif _ball_type(ball) == BALL_TYPE_STANDARD:
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
	ball["velocity"] = monster_motion_vector(next_angle, speed)
	ball["target_speed"] = speed


func compact_monsters() -> void:
	var compacted: Array[Dictionary] = []
	for monster: Dictionary in monsters:
		if bool(monster.get("active", false)):
			compacted.append(monster)
	monsters.clear()
	monsters.append_array(compacted)


func _ball_rect(ball: Dictionary) -> Rect2:
	var size := float(ball.get("size", BALL_SIZE))
	return Rect2(ball.get("position", Vector2.ZERO), Vector2(size, size))


func _projectile_rect(projectile: Dictionary, ports: Dictionary) -> Rect2:
	var result = _call_port(ports, "projectile_rect", [projectile], Rect2())
	if result is Rect2:
		return result
	return Rect2()


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


func _queue_audio_event_at_x(ports: Dictionary, event_name: String, source_x: float) -> void:
	_call_port(ports, "queue_audio_event_at_x", [event_name, source_x], null)


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
