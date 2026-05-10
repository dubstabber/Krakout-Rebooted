extends RefCounted
class_name KrakoutGameplayEvents

const SFX_EVENT_BALL_LAUNCH := "ball_launch"
const SFX_EVENT_RACKET_BOUNCE := "racket_bounce"
const SFX_EVENT_BACK_WALL_BOUNCE := "back_wall_bounce"
const SFX_EVENT_BRICK_CLEAR := "brick_clear"
const SFX_EVENT_HARD_BRICK_HIT := "hard_brick_hit"
const SFX_EVENT_CHAIN_EXPLOSION := "chain_explosion"
const SFX_EVENT_BONUS_SPAWN := "bonus_spawn"
const SFX_EVENT_BONUS_EXPIRE := "bonus_expire"
const SFX_EVENT_BONUS_COLLECT := "bonus_collect"
const SFX_EVENT_BONUS_APPLY := "bonus_apply"
const SFX_EVENT_BONUS_ADD_BALL_APPLY := "bonus_add_ball_apply"
const SFX_EVENT_BONUS_DESTROY_BALL_APPLY := "bonus_destroy_ball_apply"
const SFX_EVENT_BONUS_JUMP_LEVEL_APPLY := "bonus_jump_level_apply"
const SFX_EVENT_PROJECTILE_FIRE := "projectile_fire"
const SFX_EVENT_PROJECTILE_HIT := "projectile_hit"
const SFX_EVENT_MONSTER_SPAWN := "monster_spawn"
const SFX_EVENT_MONSTER_EXPIRE := "monster_expire"
const SFX_EVENT_MONSTER_HIT := "monster_hit"
const SFX_EVENT_BEE_SPAWN := "bee_spawn"
const SFX_EVENT_BEE_STOP := "bee_stop"
const SFX_EVENT_LIFE_LOST := "life_lost"
const SFX_EVENT_LEVEL_READY := "level_ready"
const SFX_EVENT_LEVEL_COMPLETE := "level_complete"
const SFX_EVENT_GAME_OVER := "game_over"
const SFX_PAN_SOURCE_SCALE := 0.3125
const SFX_PAN_SOURCE_OFFSET := -100.0
const SFX_PAN_MIN := -100.0
const SFX_PAN_MAX := 100.0
const SFX_BEE_SPAWN_PAN100 := -100.0


static func pan100_for_source_x(source_x: float) -> float:
	return clampf(source_x * SFX_PAN_SOURCE_SCALE + SFX_PAN_SOURCE_OFFSET, SFX_PAN_MIN, SFX_PAN_MAX)
