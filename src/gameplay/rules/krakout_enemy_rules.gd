extends RefCounted
class_name KrakoutEnemyRules

const PlayfieldSpecScript := preload("res://src/playfield/krakout_playfield_spec.gd")
const BallRulesScript := preload("res://src/gameplay/rules/krakout_ball_rules.gd")

const ORIGINAL_ENEMY_STEPS_PER_UPDATE := 3.0
const ORIGINAL_ENEMY_UPDATE_HZ := BallRulesScript.ORIGINAL_UPDATE_HZ * ORIGINAL_ENEMY_STEPS_PER_UPDATE
const MAX_MONSTERS := 5
const MONSTER_TYPE_COUNT := 11
const MONSTER_SIZE := Vector2(32, 32)
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


static func monster_score_mode_for_type(type_id: int, contact_key: String) -> String:
	return String(_monster_trait_value(type_id, contact_key, MONSTER_SCORE_MODE_DEFAULT))


static func _monster_trait_value(type_id: int, key: String, default_value):
	if MONSTER_TRAITS.has(type_id):
		var monster_trait: Dictionary = MONSTER_TRAITS[type_id]
		if monster_trait.has(key):
			return monster_trait[key]
	if MONSTER_DEFAULT_TRAIT.has(key):
		return MONSTER_DEFAULT_TRAIT[key]
	return default_value
