extends RefCounted
class_name KrakoutEnemyHazardSystem

const GameplayStateScript := preload("res://src/gameplay/krakout_gameplay_state.gd")
const PlayfieldSpecScript := preload("res://src/playfield/krakout_playfield_spec.gd")
const BallRulesScript := preload("res://src/gameplay/rules/krakout_ball_rules.gd")
const RacketRulesScript := preload("res://src/gameplay/rules/krakout_racket_rules.gd")
const EnemyRulesScript := preload("res://src/gameplay/rules/krakout_enemy_rules.gd")
const GameplayEventsScript := preload("res://src/gameplay/rules/krakout_gameplay_events.gd")
const MonsterSystemScript := preload("res://src/gameplay/systems/krakout_monster_system.gd")
const BeeSystemScript := preload("res://src/gameplay/systems/krakout_bee_system.gd")
const SnakeVfxSystemScript := preload("res://src/gameplay/systems/krakout_snake_vfx_system.gd")

const BALL_SIZE := BallRulesScript.BALL_SIZE
const BALL_TYPE_STANDARD := BallRulesScript.BALL_TYPE_STANDARD
const BALL_TYPE_FIREBALL := BallRulesScript.BALL_TYPE_FIREBALL
const BALL_TYPE_NON_STRICKED := BallRulesScript.BALL_TYPE_NON_STRICKED
const ORIGINAL_UPDATE_HZ := BallRulesScript.ORIGINAL_UPDATE_HZ
const ORIGINAL_ENEMY_STEPS_PER_UPDATE := EnemyRulesScript.ORIGINAL_ENEMY_STEPS_PER_UPDATE
const ORIGINAL_ENEMY_UPDATE_HZ := EnemyRulesScript.ORIGINAL_ENEMY_UPDATE_HZ

const RACKET_SEGMENT_PIXEL_STEP := RacketRulesScript.RACKET_SEGMENT_PIXEL_STEP
const MONSTER_SIZE := EnemyRulesScript.MONSTER_SIZE
const MAX_MONSTERS := EnemyRulesScript.MAX_MONSTERS
const MONSTER_TYPE_COUNT := EnemyRulesScript.MONSTER_TYPE_COUNT
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

const BEE_SIZE := EnemyRulesScript.BEE_SIZE
const BEE_COLLISION_SIZE := EnemyRulesScript.BEE_COLLISION_SIZE
const BEE_COLLISION_OFFSET := EnemyRulesScript.BEE_COLLISION_OFFSET
const BEE_FRAME_COUNT := EnemyRulesScript.BEE_FRAME_COUNT
const BEE_FRAME_SECONDS := EnemyRulesScript.BEE_FRAME_SECONDS
const BEE_STEP_X := EnemyRulesScript.BEE_STEP_X
const BEE_SPAWN_X := EnemyRulesScript.BEE_SPAWN_X
const BEE_EXPIRE_X := EnemyRulesScript.BEE_EXPIRE_X
const BEE_SPAWN_DELAY_MAX_SECONDS := EnemyRulesScript.BEE_SPAWN_DELAY_MAX_SECONDS
const BEE_BALL_HIT_SCORE := MONSTER_BALL_HIT_SCORE
const BEE_STUN_SCORE := MONSTER_TYPE9_STUN_SCORE
const BEE_BALL_COLLISION_RADIUS := EnemyRulesScript.BEE_BALL_COLLISION_RADIUS
const RACKET_STUN_DURATION_SECONDS := EnemyRulesScript.RACKET_STUN_DURATION_SECONDS

const MAX_SNAKE_SEGMENTS := EnemyRulesScript.MAX_SNAKE_SEGMENTS
const SNAKE_KIND_COUNT := EnemyRulesScript.SNAKE_KIND_COUNT
const SNAKE_SEGMENT_SIZE := EnemyRulesScript.SNAKE_SEGMENT_SIZE
const SNAKE_UPDATE_SECONDS := EnemyRulesScript.SNAKE_UPDATE_SECONDS
const SNAKE_STEP_PIXELS := EnemyRulesScript.SNAKE_STEP_PIXELS
const SNAKE_KIND_UP := EnemyRulesScript.SNAKE_KIND_UP
const SNAKE_KIND_DOWN := EnemyRulesScript.SNAKE_KIND_DOWN
const SNAKE_KIND_LEFT := EnemyRulesScript.SNAKE_KIND_LEFT
const SNAKE_KIND_RIGHT := EnemyRulesScript.SNAKE_KIND_RIGHT
const SNAKE_TERMINAL_UP := EnemyRulesScript.SNAKE_TERMINAL_UP
const SNAKE_TERMINAL_DOWN := EnemyRulesScript.SNAKE_TERMINAL_DOWN
const SNAKE_TERMINAL_LEFT := EnemyRulesScript.SNAKE_TERMINAL_LEFT
const SNAKE_TERMINAL_RIGHT := EnemyRulesScript.SNAKE_TERMINAL_RIGHT

const IMPACT_EFFECT_KIND_MONSTER_SPAWN := 0
const IMPACT_EFFECT_KIND_MONSTER_TIMEOUT := 1
const IMPACT_EFFECT_KIND_SNAKE_HIT := IMPACT_EFFECT_KIND_MONSTER_TIMEOUT
const IMPACT_EFFECT_KIND_EXPLOSION := 2
const IMPACT_EFFECT_KIND_MONSTER_HIT := IMPACT_EFFECT_KIND_EXPLOSION
const SFX_EVENT_PROJECTILE_HIT := GameplayEventsScript.SFX_EVENT_PROJECTILE_HIT
const SFX_EVENT_MONSTER_SPAWN := GameplayEventsScript.SFX_EVENT_MONSTER_SPAWN
const SFX_EVENT_MONSTER_EXPIRE := GameplayEventsScript.SFX_EVENT_MONSTER_EXPIRE
const SFX_EVENT_MONSTER_HIT := GameplayEventsScript.SFX_EVENT_MONSTER_HIT
const SFX_EVENT_BEE_SPAWN := GameplayEventsScript.SFX_EVENT_BEE_SPAWN
const SFX_EVENT_BEE_STOP := GameplayEventsScript.SFX_EVENT_BEE_STOP
const SFX_BEE_SPAWN_PAN100 := GameplayEventsScript.SFX_BEE_SPAWN_PAN100

var monsters: Array[Dictionary]
var bees: Array[Dictionary]
var snake_segments: Array[Dictionary]
var monster_rng
var collision_rng
var monster_system
var bee_system
var snake_vfx_system
var racket_stun_time_remaining := 0.0

var monster_spawn_cooldown: float:
	get:
		return monster_system.monster_spawn_cooldown if monster_system != null else MONSTER_SPAWN_INTERVAL_SECONDS
	set(value):
		if monster_system != null:
			monster_system.monster_spawn_cooldown = value

var bee_spawn_delay_remaining: float:
	get:
		return bee_system.bee_spawn_delay_remaining if bee_system != null else BEE_SPAWN_DELAY_MAX_SECONDS
	set(value):
		if bee_system != null:
			bee_system.bee_spawn_delay_remaining = value


func _init(
	shared_monsters = [],
	shared_bees: Array[Dictionary] = [],
	shared_snake_segments: Array[Dictionary] = [],
	monster_rng_source = null,
	collision_rng_source = null
) -> void:
	if shared_monsters is GameplayStateScript:
		var state = shared_monsters
		monsters = state.monsters
		bees = state.bees
		snake_segments = state.snake_segments
		monster_rng = state.monster_rng
		collision_rng = state.collision_rng
		monster_system = MonsterSystemScript.new(state)
		bee_system = BeeSystemScript.new(state)
		snake_vfx_system = SnakeVfxSystemScript.new(state)
	else:
		monsters = shared_monsters
		bees = shared_bees
		snake_segments = shared_snake_segments
		monster_rng = monster_rng_source
		collision_rng = collision_rng_source
		monster_system = MonsterSystemScript.new(monsters, monster_rng, collision_rng)
		bee_system = BeeSystemScript.new(bees, collision_rng)
		snake_vfx_system = SnakeVfxSystemScript.new(snake_segments)


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


static func bee_rect(bee: Dictionary) -> Rect2:
	return EnemyRulesScript.bee_rect(bee)


static func snake_rect(segment: Dictionary) -> Rect2:
	return EnemyRulesScript.snake_rect(segment)


static func _monster_score_mode_for_type(type_id: int, contact_key: String) -> String:
	return EnemyRulesScript.monster_score_mode_for_type(type_id, contact_key)


static func _monster_trait_value(type_id: int, key: String, default_value):
	return MonsterSystemScript.monster_trait_value(type_id, key, default_value)


func set_monster_rng_seed(seed_value: int) -> void:
	monster_system.set_monster_rng_seed(seed_value)


func set_collision_rng_seed(seed_value: int) -> void:
	monster_system.set_collision_rng_seed(seed_value)
	bee_system.set_collision_rng_seed(seed_value)


func clear(queue_audio_event: Callable = Callable()) -> void:
	bee_system.clear(queue_audio_event)
	monster_system.clear()
	snake_vfx_system.clear()
	racket_stun_time_remaining = 0.0


func clear_snake_state() -> void:
	snake_vfx_system.clear()


func visible_monsters() -> Array[Dictionary]:
	return monster_system.visible_monsters()


func visible_bees() -> Array[Dictionary]:
	return bee_system.visible_bees()


func visible_snake_segments() -> Array[Dictionary]:
	return snake_vfx_system.visible_segments()


func active_monster_count() -> int:
	return monster_system.active_count()


func active_bee_count() -> int:
	return bee_system.active_count()


func active_snake_segment_count() -> int:
	return snake_vfx_system.active_count()


func is_racket_stunned() -> bool:
	return racket_stun_time_remaining > 0.0


func update_racket_stun(delta: float) -> void:
	if racket_stun_time_remaining > 0.0:
		racket_stun_time_remaining = maxf(0.0, racket_stun_time_remaining - delta)


func apply_racket_stun() -> void:
	racket_stun_time_remaining += RACKET_STUN_DURATION_SECONDS


func force_monster_spawn_ready() -> void:
	monster_system.force_spawn_ready()


func force_bee_spawn_ready() -> void:
	bee_system.force_spawn_ready()


func set_monster_spawn_cooldown_for_test(seconds: float) -> void:
	monster_system.set_spawn_cooldown_for_test(seconds)


func set_bee_spawn_delay_for_test(seconds: float) -> void:
	bee_system.set_spawn_delay_for_test(seconds)


func set_monster_age_for_test(index: int, age: float) -> bool:
	return monster_system.set_monster_age_for_test(index, age)


func force_monster(position: Vector2, type_id: int = 3, angle: int = 0) -> bool:
	return monster_system.force_monster(position, type_id, angle)


func force_bee(position: Vector2, frame: int = 0) -> bool:
	return bee_system.force_bee(position, frame)


func force_snake_vfx_segments_for_test(segments: Array) -> int:
	return snake_vfx_system.force_segments_for_test(segments)


func update_snake_segments(delta: float, ports: Dictionary) -> void:
	snake_vfx_system.update(delta, ports)


func step_snake_segments() -> void:
	snake_vfx_system.step_segments()


func snake_direction_for_kind(kind: int) -> Vector2:
	return snake_vfx_system.snake_direction_for_kind(kind)


func collide_ball_with_snake(ball: Dictionary, ports: Dictionary) -> bool:
	return snake_vfx_system.collide_ball(ball, ports)


func collide_projectile_with_snake(projectile: Dictionary, ports: Dictionary) -> bool:
	return snake_vfx_system.collide_projectile(projectile, ports)


func truncate_snake_at_rect(hit_rect: Rect2, ports: Dictionary) -> bool:
	return snake_vfx_system.truncate_at_rect(hit_rect, ports)


func truncate_snake_at_index(hit_index: int) -> void:
	snake_vfx_system.truncate_at_index(hit_index)


func terminal_snake_kind_for_previous_kind(kind: int) -> int:
	return snake_vfx_system.terminal_snake_kind_for_previous_kind(kind)


func has_active_snake_segments() -> bool:
	return snake_vfx_system.has_active_segments()


func update_monsters(delta: float, balls: Array, ports: Dictionary) -> void:
	monster_system.update_monsters(delta, balls, ports, Callable(self, "apply_racket_stun"))


func spawn_next_monster(ports: Dictionary) -> bool:
	return monster_system.spawn_next_monster(ports)


func next_monster_type() -> int:
	return monster_system.next_monster_type()


func new_monster(position: Vector2, type_id: int, angle: int) -> Dictionary:
	return monster_system.new_monster(position, type_id, angle)


func advance_monster(monster: Dictionary, delta: float, balls: Array, ports: Dictionary) -> void:
	monster_system.advance_monster(monster, delta, balls, ports)


func collide_monster_with_boundaries(monster: Dictionary) -> bool:
	return monster_system.collide_monster_with_boundaries(monster)


func tracking_angle_for_monster(monster: Dictionary, current_angle: float, tick_scale: float, balls: Array, ports: Dictionary) -> float:
	return monster_system.tracking_angle_for_monster(monster, current_angle, tick_scale, balls, ports)


func nearest_trackable_ball_center(monster_center: Vector2, balls: Array, ports: Dictionary) -> Vector2:
	return monster_system.nearest_trackable_ball_center(monster_center, balls, ports)


func collide_ball_with_monsters(ball: Dictionary, balls: Array, ports: Dictionary) -> bool:
	return monster_system.collide_ball_with_monsters(ball, balls, ports)


func collide_ball_with_bees(ball: Dictionary, ports: Dictionary) -> bool:
	return bee_system.collide_ball_with_bees(ball, ports)


func ball_intersects_enemy_circle(ball: Dictionary, enemy_position: Vector2, enemy_radius: float) -> bool:
	return monster_system.ball_intersects_enemy_circle(ball, enemy_position, enemy_radius)


func collide_projectile_with_monsters(projectile: Dictionary, ports: Dictionary) -> bool:
	return monster_system.collide_projectile_with_monsters(projectile, ports)


func collide_monster_with_racket(index: int, monster: Dictionary, ports: Dictionary) -> bool:
	return monster_system.collide_monster_with_racket(index, monster, ports, Callable(self, "apply_racket_stun"))


func kill_monster_at_index(index: int, score_value: int, ports: Dictionary) -> void:
	monster_system.kill_monster_at_index(index, score_value, ports)


func score_for_monster_paddle_contact(monster: Dictionary) -> int:
	return monster_system.score_for_monster_paddle_contact(monster)


func score_for_monster_ball_contact(monster: Dictionary) -> int:
	return monster_system.score_for_monster_ball_contact(monster)


func monster_survives_ball_contact(monster: Dictionary) -> bool:
	return monster_system.monster_survives_ball_contact(monster)


func apply_ball_enemy_response(ball: Dictionary, enemy_type_id: int, ports: Dictionary) -> void:
	monster_system.apply_ball_enemy_response(ball, enemy_type_id, ports)


func rotate_ball_from_enemy_contact(
	ball: Dictionary,
	minimum_degrees: int,
	random_degrees: int,
	ports: Dictionary
) -> void:
	monster_system.rotate_ball_from_enemy_contact(ball, minimum_degrees, random_degrees, ports)


func compact_monsters() -> void:
	monster_system.compact_monsters()


func update_bees(delta: float, ports: Dictionary) -> void:
	bee_system.update_bees(delta, ports, Callable(self, "apply_racket_stun"))


func spawn_next_bee(ports: Dictionary) -> bool:
	return bee_system.spawn_next_bee(ports)


func new_bee(position: Vector2, frame: int = 0) -> Dictionary:
	return bee_system.new_bee(position, frame)


func advance_bee(bee: Dictionary, delta: float, ports: Dictionary) -> void:
	bee_system.advance_bee(bee, delta, ports)


func resolve_bee_racket_hit(index: int, bee: Dictionary, ports: Dictionary) -> void:
	bee_system.resolve_bee_racket_hit(index, bee, ports, Callable(self, "apply_racket_stun"))


func kill_bee_at_index(index: int, score_value: int, ports: Dictionary) -> void:
	bee_system.kill_bee_at_index(index, score_value, ports)


func reset_bee_spawn_delay() -> void:
	bee_system.reset_bee_spawn_delay()


func compact_bees() -> void:
	bee_system.compact_bees()


func has_active_bee() -> bool:
	return bee_system.has_active_bee()
