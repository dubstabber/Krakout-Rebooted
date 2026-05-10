extends RefCounted
class_name KrakoutEnemyHazardSystem

const PlayfieldSpecScript := preload("res://src/playfield/krakout_playfield_spec.gd")

const BALL_SIZE := 18.0
const BALL_TYPE_STANDARD := 0
const BALL_TYPE_FIREBALL := 1
const BALL_TYPE_NON_STRICKED := 2
const ORIGINAL_UPDATE_HZ := 50.0
const ORIGINAL_ENEMY_STEPS_PER_UPDATE := 3.0
const ORIGINAL_ENEMY_UPDATE_HZ := ORIGINAL_UPDATE_HZ * ORIGINAL_ENEMY_STEPS_PER_UPDATE

const RACKET_SEGMENT_PIXEL_STEP := 5.0
const MONSTER_SIZE := Vector2(32, 32)
const MAX_MONSTERS := 5
const MONSTER_TYPE_COUNT := 11
const MONSTER_COLLISION_SIZE := Vector2(26, 26)
const MONSTER_COLLISION_OFFSET := Vector2(3, 3)
const MONSTER_TYPE9_COLLISION_SIZE := Vector2(32, 32)
const MONSTER_TYPE9_COLLISION_OFFSET := Vector2.ZERO
const MONSTER_BALL_COLLISION_RADIUS := 16.0
const MONSTER_LIFETIME_SECONDS := 6.5
const MONSTER_SPAWN_INTERVAL_SECONDS := 4.5
const MONSTER_FRAME_SECONDS := 0.07
const MONSTER_DEFAULT_SPEED := 1.0
const MONSTER_TYPE3_RIGHT_LIMIT := 510.0
const MONSTER_TYPE3_VERTICAL_JITTER_BASE := -5.0
const MONSTER_TYPE3_VERTICAL_JITTER_RANGE := 10
const MONSTER_TRACKING_TURN_STEP_DEGREES := 2.0
const MONSTER_SCORE := 15
const MONSTER_BALL_HIT_SCORE := 25
const MONSTER_TYPE6_SCORE_STEP := 10
const MONSTER_TYPE6_SCORE_VARIANTS := 6
const MONSTER_TYPE9_STUN_SCORE := 30
const MONSTER_BALL_HIT_MIN_ROTATION_DEGREES := 90
const MONSTER_BALL_HIT_RANDOM_ROTATION_DEGREES := 90
const MONSTER_TYPE1_BALL_ROTATION_DEGREES := 18
const MONSTER_MOTION_ANGLE := "angle"
const MONSTER_MOTION_PADDLE_FOLLOW := "paddle_follow"
const MONSTER_MOTION_BALL_TRACK := "ball_track"
const MONSTER_SCORE_MODE_DEFAULT := "default"
const MONSTER_SCORE_MODE_RANDOM_TYPE6 := "random_type6"
const MONSTER_SCORE_MODE_STUN_TYPE9 := "stun_type9"
const MONSTER_DEFAULT_TRAIT := {
	"frame_count": 11,
	"motion_mode": MONSTER_MOTION_ANGLE,
	"paddle_score_mode": MONSTER_SCORE_MODE_DEFAULT,
	"ball_score_mode": MONSTER_SCORE_MODE_DEFAULT,
	"collision_offset": MONSTER_COLLISION_OFFSET,
	"collision_size": MONSTER_COLLISION_SIZE,
	"stuns_racket": false,
	"natural_spawn": false,
}
const MONSTER_TRAITS := {
	0: {"frame_count": 20, "natural_spawn": true},
	1: {"frame_count": 20, "natural_spawn": true},
	2: {"frame_count": 20, "natural_spawn": true},
	3: {
		"frame_count": 20,
		"motion_mode": MONSTER_MOTION_PADDLE_FOLLOW,
		"natural_spawn": true,
	},
	4: {"frame_count": 20, "natural_spawn": true},
	5: {"frame_count": 20, "natural_spawn": true},
	6: {
		"frame_count": 20,
		"paddle_score_mode": MONSTER_SCORE_MODE_RANDOM_TYPE6,
		"ball_score_mode": MONSTER_SCORE_MODE_RANDOM_TYPE6,
		"natural_spawn": true,
	},
	7: {"frame_count": 11, "natural_spawn": true},
	8: {"frame_count": 10, "natural_spawn": true},
	9: {
		"frame_count": 20,
		"paddle_score_mode": MONSTER_SCORE_MODE_STUN_TYPE9,
		"collision_offset": MONSTER_TYPE9_COLLISION_OFFSET,
		"collision_size": MONSTER_TYPE9_COLLISION_SIZE,
		"stuns_racket": true,
		"natural_spawn": true,
	},
	10: {
		"frame_count": 11,
		"motion_mode": MONSTER_MOTION_BALL_TRACK,
		"natural_spawn": true,
	},
}

const BEE_SIZE := Vector2(48, 40)
const BEE_COLLISION_SIZE := Vector2(36, 36)
const BEE_COLLISION_OFFSET := Vector2(6, 6)
const BEE_FRAME_COUNT := 6
const BEE_FRAME_SECONDS := 0.005
const BEE_STEP_X := 3.0
const BEE_SPAWN_X := 50.0
const BEE_EXPIRE_X := 640.0
const BEE_SPAWN_DELAY_MAX_SECONDS := 30.0
const BEE_BALL_HIT_SCORE := MONSTER_BALL_HIT_SCORE
const BEE_STUN_SCORE := MONSTER_TYPE9_STUN_SCORE
const BEE_BALL_COLLISION_RADIUS := 24.0
const RACKET_STUN_DURATION_SECONDS := 3.0

const MAX_SNAKE_SEGMENTS := 100
const SNAKE_KIND_COUNT := 20
const SNAKE_SEGMENT_SIZE := Vector2(10, 10)
const SNAKE_UPDATE_SECONDS := 0.05
const SNAKE_STEP_PIXELS := 10.0
const SNAKE_KIND_UP := 0
const SNAKE_KIND_DOWN := 1
const SNAKE_KIND_LEFT := 2
const SNAKE_KIND_RIGHT := 3
const SNAKE_TERMINAL_UP := 16
const SNAKE_TERMINAL_DOWN := 17
const SNAKE_TERMINAL_LEFT := 18
const SNAKE_TERMINAL_RIGHT := 19

const IMPACT_EFFECT_KIND_MONSTER_SPAWN := 0
const IMPACT_EFFECT_KIND_MONSTER_TIMEOUT := 1
const IMPACT_EFFECT_KIND_SNAKE_HIT := IMPACT_EFFECT_KIND_MONSTER_TIMEOUT
const IMPACT_EFFECT_KIND_EXPLOSION := 2
const IMPACT_EFFECT_KIND_MONSTER_HIT := IMPACT_EFFECT_KIND_EXPLOSION
const SFX_EVENT_PROJECTILE_HIT := "projectile_hit"
const SFX_EVENT_MONSTER_SPAWN := "monster_spawn"
const SFX_EVENT_MONSTER_EXPIRE := "monster_expire"
const SFX_EVENT_MONSTER_HIT := "monster_hit"
const SFX_EVENT_BEE_SPAWN := "bee_spawn"
const SFX_EVENT_BEE_STOP := "bee_stop"
const SFX_BEE_SPAWN_PAN100 := -100.0

var monsters: Array[Dictionary]
var bees: Array[Dictionary]
var snake_segments: Array[Dictionary]
var monster_rng
var collision_rng
var monster_spawn_cooldown := MONSTER_SPAWN_INTERVAL_SECONDS
var bee_spawn_delay_remaining := BEE_SPAWN_DELAY_MAX_SECONDS
var racket_stun_time_remaining := 0.0
var _snake_update_elapsed := 0.0


func _init(
	shared_monsters: Array[Dictionary] = [],
	shared_bees: Array[Dictionary] = [],
	shared_snake_segments: Array[Dictionary] = [],
	monster_rng_source = null,
	collision_rng_source = null
) -> void:
	monsters = shared_monsters
	bees = shared_bees
	snake_segments = shared_snake_segments
	monster_rng = monster_rng_source
	collision_rng = collision_rng_source


static func monster_trait_for_type(type_id: int) -> Dictionary:
	var monster_trait := MONSTER_DEFAULT_TRAIT.duplicate()
	if MONSTER_TRAITS.has(type_id):
		monster_trait.merge(MONSTER_TRAITS[type_id], true)
	return monster_trait


static func monster_spawn_pool() -> Array[int]:
	var spawn_pool: Array[int] = []
	for type_id in range(MONSTER_TYPE_COUNT):
		if monster_type_is_original_spawned(type_id):
			spawn_pool.append(type_id)
	return spawn_pool


static func monster_frame_count_for_type(type_id: int) -> int:
	return int(_monster_trait_value(type_id, "frame_count", MONSTER_DEFAULT_TRAIT["frame_count"]))


static func monster_motion_mode_for_type(type_id: int) -> String:
	return String(_monster_trait_value(type_id, "motion_mode", MONSTER_MOTION_ANGLE))


static func monster_collision_offset_for_type(type_id: int) -> Vector2:
	return _monster_trait_value(type_id, "collision_offset", MONSTER_COLLISION_OFFSET) as Vector2


static func monster_collision_size_for_type(type_id: int) -> Vector2:
	return _monster_trait_value(type_id, "collision_size", MONSTER_COLLISION_SIZE) as Vector2


static func monster_stuns_racket(type_id: int) -> bool:
	return bool(_monster_trait_value(type_id, "stuns_racket", false))


static func monster_type_is_original_spawned(type_id: int) -> bool:
	return bool(_monster_trait_value(type_id, "natural_spawn", false))


static func monster_motion_vector(angle: float, speed: float) -> Vector2:
	var radians := deg_to_rad(fposmod(angle, 360.0))
	return Vector2(cos(radians) * speed, -sin(radians) * speed)


static func monster_rect(monster: Dictionary) -> Rect2:
	var type_id := int(monster.get("type_id", 0))
	return Rect2(
		monster.get("position", Vector2.ZERO) + monster_collision_offset_for_type(type_id),
		monster_collision_size_for_type(type_id)
	)


static func bee_rect(bee: Dictionary) -> Rect2:
	return Rect2(bee.get("position", Vector2.ZERO) + BEE_COLLISION_OFFSET, BEE_COLLISION_SIZE)


static func snake_rect(segment: Dictionary) -> Rect2:
	return Rect2(segment.get("position", Vector2.ZERO), SNAKE_SEGMENT_SIZE)


static func _monster_score_mode_for_type(type_id: int, contact_key: String) -> String:
	return String(_monster_trait_value(type_id, contact_key, MONSTER_SCORE_MODE_DEFAULT))


static func _monster_trait_value(type_id: int, key: String, default_value):
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


func clear(queue_audio_event: Callable = Callable()) -> void:
	if has_active_bee() and queue_audio_event.is_valid():
		queue_audio_event.call(SFX_EVENT_BEE_STOP)
	monsters.clear()
	bees.clear()
	clear_snake_state()
	monster_spawn_cooldown = MONSTER_SPAWN_INTERVAL_SECONDS
	bee_spawn_delay_remaining = BEE_SPAWN_DELAY_MAX_SECONDS
	racket_stun_time_remaining = 0.0


func clear_snake_state() -> void:
	snake_segments.clear()
	_snake_update_elapsed = 0.0


func visible_monsters() -> Array[Dictionary]:
	var visible: Array[Dictionary] = []
	for monster: Dictionary in monsters:
		if bool(monster.get("active", false)):
			visible.append(monster.duplicate())
	return visible


func visible_bees() -> Array[Dictionary]:
	var visible: Array[Dictionary] = []
	for bee: Dictionary in bees:
		if bool(bee.get("active", false)):
			visible.append(bee.duplicate())
	return visible


func visible_snake_segments() -> Array[Dictionary]:
	var visible: Array[Dictionary] = []
	for segment: Dictionary in snake_segments:
		if bool(segment.get("active", false)):
			visible.append(segment.duplicate())
		else:
			break
	return visible


func active_monster_count() -> int:
	return visible_monsters().size()


func active_bee_count() -> int:
	return visible_bees().size()


func active_snake_segment_count() -> int:
	return visible_snake_segments().size()


func is_racket_stunned() -> bool:
	return racket_stun_time_remaining > 0.0


func update_racket_stun(delta: float) -> void:
	if racket_stun_time_remaining > 0.0:
		racket_stun_time_remaining = maxf(0.0, racket_stun_time_remaining - delta)


func apply_racket_stun() -> void:
	racket_stun_time_remaining += RACKET_STUN_DURATION_SECONDS


func force_monster_spawn_ready() -> void:
	monster_spawn_cooldown = 0.0


func force_bee_spawn_ready() -> void:
	bee_spawn_delay_remaining = 0.0


func set_monster_spawn_cooldown_for_test(seconds: float) -> void:
	monster_spawn_cooldown = maxf(0.0, seconds)


func set_bee_spawn_delay_for_test(seconds: float) -> void:
	bee_spawn_delay_remaining = maxf(0.0, seconds)


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


func force_bee(position: Vector2, frame: int = 0) -> bool:
	if bees.size() >= 1:
		return false
	bees.append(new_bee(position, frame))
	return true


func force_snake_vfx_segments_for_test(segments: Array) -> int:
	clear_snake_state()
	for segment in segments:
		if snake_segments.size() >= MAX_SNAKE_SEGMENTS:
			break
		if typeof(segment) != TYPE_DICTIONARY:
			continue
		var entry: Dictionary = segment
		var position := Vector2.ZERO
		var raw_position = entry.get("position", Vector2.ZERO)
		if raw_position is Vector2:
			position = raw_position
		snake_segments.append({
			"active": bool(entry.get("active", true)),
			"position": position,
			"kind": clampi(int(entry.get("kind", 0)), 0, SNAKE_KIND_COUNT - 1),
		})
	return snake_segments.size()


func update_snake_segments(delta: float, ports: Dictionary) -> void:
	if delta <= 0.0 or not has_active_snake_segments():
		return

	_snake_update_elapsed += delta
	while _snake_update_elapsed > SNAKE_UPDATE_SECONDS and has_active_snake_segments():
		_snake_update_elapsed -= SNAKE_UPDATE_SECONDS
		step_snake_segments()


func step_snake_segments() -> void:
	for index in range(snake_segments.size()):
		var segment := snake_segments[index]
		if not bool(segment.get("active", false)):
			break
		var position: Vector2 = segment.get("position", Vector2.ZERO)
		segment["position"] = position + snake_direction_for_kind(int(segment.get("kind", 0))) * SNAKE_STEP_PIXELS
		snake_segments[index] = segment


func snake_direction_for_kind(kind: int) -> Vector2:
	match posmod(kind, 4):
		SNAKE_KIND_UP:
			return Vector2(0, -1)
		SNAKE_KIND_DOWN:
			return Vector2(0, 1)
		SNAKE_KIND_LEFT:
			return Vector2(-1, 0)
		SNAKE_KIND_RIGHT:
			return Vector2(1, 0)
	return Vector2.ZERO


func collide_ball_with_snake(ball: Dictionary, ports: Dictionary) -> bool:
	return truncate_snake_at_rect(_ball_rect(ball), ports)


func collide_projectile_with_snake(projectile: Dictionary, ports: Dictionary) -> bool:
	return truncate_snake_at_rect(_projectile_rect(projectile, ports), ports)


func truncate_snake_at_rect(hit_rect: Rect2, ports: Dictionary) -> bool:
	for index in range(snake_segments.size()):
		var segment: Dictionary = snake_segments[index]
		if not bool(segment.get("active", false)):
			break
		if snake_rect(segment).intersects(hit_rect):
			_spawn_impact_effect(ports, segment.get("position", Vector2.ZERO), IMPACT_EFFECT_KIND_SNAKE_HIT)
			truncate_snake_at_index(index)
			return true
	return false


func truncate_snake_at_index(hit_index: int) -> void:
	if hit_index < 0 or hit_index >= snake_segments.size():
		return

	if hit_index > 0:
		var terminal_source_index := maxi(0, hit_index - 2)
		var terminal_target_index := hit_index - 1
		var terminal_source: Dictionary = snake_segments[terminal_source_index]
		var terminal_target: Dictionary = snake_segments[terminal_target_index]
		terminal_target["kind"] = terminal_snake_kind_for_previous_kind(int(terminal_source.get("kind", 0)))
		snake_segments[terminal_target_index] = terminal_target

	for index in range(hit_index, snake_segments.size()):
		var segment := snake_segments[index]
		segment["active"] = false
		snake_segments[index] = segment


func terminal_snake_kind_for_previous_kind(kind: int) -> int:
	match clampi(kind, 0, SNAKE_KIND_COUNT - 1):
		4, 11, 14:
			return SNAKE_TERMINAL_UP
		5, 10, 15:
			return SNAKE_TERMINAL_DOWN
		6, 8, 13:
			return SNAKE_TERMINAL_LEFT
		7, 9, 12:
			return SNAKE_TERMINAL_RIGHT
	match posmod(kind, 4):
		SNAKE_KIND_UP:
			return SNAKE_TERMINAL_UP
		SNAKE_KIND_DOWN:
			return SNAKE_TERMINAL_DOWN
		SNAKE_KIND_LEFT:
			return SNAKE_TERMINAL_LEFT
		SNAKE_KIND_RIGHT:
			return SNAKE_TERMINAL_RIGHT
	return SNAKE_TERMINAL_LEFT


func has_active_snake_segments() -> bool:
	for segment: Dictionary in snake_segments:
		if bool(segment.get("active", false)):
			return true
		break
	return false


func update_monsters(delta: float, balls: Array, ports: Dictionary) -> void:
	for index in range(monsters.size()):
		var monster := monsters[index]
		if not bool(monster.get("active", false)):
			continue
		advance_monster(monster, delta, balls, ports)
		if bool(monster.get("active", false)) and collide_monster_with_racket(index, monster, ports):
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


func collide_ball_with_bees(ball: Dictionary, ports: Dictionary) -> bool:
	for index in range(bees.size()):
		var bee: Dictionary = bees[index]
		if not bool(bee.get("active", false)):
			continue
		if ball_intersects_enemy_circle(ball, bee.get("position", Vector2.ZERO), BEE_BALL_COLLISION_RADIUS):
			kill_bee_at_index(index, BEE_BALL_HIT_SCORE, ports)
			apply_ball_enemy_response(ball, -1, ports)
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


func collide_monster_with_racket(index: int, monster: Dictionary, ports: Dictionary) -> bool:
	if not monster_rect(monster).intersects(_racket_rect(ports)):
		return false

	kill_monster_at_index(index, score_for_monster_paddle_contact(monster), ports)
	if monster_stuns_racket(int(monster.get("type_id", 0))):
		apply_racket_stun()
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
	match _monster_score_mode_for_type(int(monster.get("type_id", 0)), "paddle_score_mode"):
		MONSTER_SCORE_MODE_RANDOM_TYPE6:
			return MONSTER_TYPE6_SCORE_STEP * (_rng_next_mod(monster_rng, MONSTER_TYPE6_SCORE_VARIANTS) + 1)
		MONSTER_SCORE_MODE_STUN_TYPE9:
			return MONSTER_TYPE9_STUN_SCORE
		_:
			return MONSTER_SCORE


func score_for_monster_ball_contact(monster: Dictionary) -> int:
	match _monster_score_mode_for_type(int(monster.get("type_id", 0)), "ball_score_mode"):
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


func update_bees(delta: float, ports: Dictionary) -> void:
	for index in range(bees.size()):
		var bee := bees[index]
		if not bool(bee.get("active", false)):
			continue
		advance_bee(bee, delta, ports)
		if bool(bee.get("active", false)) and bee_rect(bee).intersects(_racket_rect(ports)):
			resolve_bee_racket_hit(index, bee, ports)
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


func resolve_bee_racket_hit(index: int, bee: Dictionary, ports: Dictionary) -> void:
	kill_bee_at_index(index, BEE_STUN_SCORE, ports)
	apply_racket_stun()


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
