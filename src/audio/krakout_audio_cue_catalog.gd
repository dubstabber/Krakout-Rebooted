extends RefCounted
class_name KrakoutAudioCueCatalog

const CONTEXT_MAIN_MENU := "main_menu"
const CONTEXT_RULES := "rules"
const CONTEXT_HIGH_SCORE := "high_score"
const CONTEXT_OPTIONS := "options"
const CONTEXT_CREDITS := "credits"
const CONTEXT_EPISODE_SELECT := "episode_select"
const CONTEXT_GAMEPLAY := "gameplay"
const CONTEXT_NAME_ENTRY := "name_entry"
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

const MUSIC_CONTEXTS := {
	CONTEXT_MAIN_MENU: "Abnormal",
	CONTEXT_RULES: "Abnormal",
	CONTEXT_HIGH_SCORE: "theme2",
	CONTEXT_OPTIONS: "Abnormal",
	CONTEXT_CREDITS: "theme5",
	CONTEXT_EPISODE_SELECT: "theme1",
	CONTEXT_GAMEPLAY: "theme4",
	CONTEXT_NAME_ENTRY: "theme3",
}
const KNOWN_SFX_EVENTS := [
	SFX_EVENT_BALL_LAUNCH,
	SFX_EVENT_RACKET_BOUNCE,
	SFX_EVENT_BACK_WALL_BOUNCE,
	SFX_EVENT_BRICK_CLEAR,
	SFX_EVENT_HARD_BRICK_HIT,
	SFX_EVENT_CHAIN_EXPLOSION,
	SFX_EVENT_BONUS_SPAWN,
	SFX_EVENT_BONUS_EXPIRE,
	SFX_EVENT_BONUS_COLLECT,
	SFX_EVENT_BONUS_APPLY,
	SFX_EVENT_PROJECTILE_FIRE,
	SFX_EVENT_PROJECTILE_HIT,
	SFX_EVENT_MONSTER_SPAWN,
	SFX_EVENT_MONSTER_EXPIRE,
	SFX_EVENT_MONSTER_HIT,
	SFX_EVENT_BEE_SPAWN,
	SFX_EVENT_BEE_STOP,
	SFX_EVENT_LIFE_LOST,
	SFX_EVENT_LEVEL_READY,
	SFX_EVENT_LEVEL_COMPLETE,
	SFX_EVENT_GAME_OVER,
]
const SFX_EVENT_NAMES := {
	SFX_EVENT_RACKET_BOUNCE: "eff07",
	SFX_EVENT_BRICK_CLEAR: "eff23",
	SFX_EVENT_HARD_BRICK_HIT: "eff22",
	SFX_EVENT_CHAIN_EXPLOSION: "eff10",
	SFX_EVENT_BONUS_SPAWN: "eff11",
	SFX_EVENT_BONUS_EXPIRE: "eff12",
	SFX_EVENT_BONUS_COLLECT: "eff15",
	SFX_EVENT_PROJECTILE_FIRE: "eff08",
	SFX_EVENT_MONSTER_SPAWN: "eff13",
	SFX_EVENT_MONSTER_EXPIRE: "eff14",
	SFX_EVENT_MONSTER_HIT: "eff09",
	SFX_EVENT_BEE_SPAWN: "EffBee",
	SFX_EVENT_LIFE_LOST: "eff16",
	SFX_EVENT_LEVEL_READY: "eff05",
	SFX_EVENT_LEVEL_COMPLETE: "eff19",
	SFX_EVENT_GAME_OVER: "eff18",
}
const SFX_STOP_EVENT_NAMES := {
	SFX_EVENT_BEE_STOP: "EffBee",
}


static func music_name_for_context(context_name: String) -> String:
	return String(MUSIC_CONTEXTS.get(context_name, ""))


static func has_music_context(context_name: String) -> bool:
	return MUSIC_CONTEXTS.has(context_name)


static func known_contexts() -> Array[String]:
	var contexts: Array[String] = []
	for context_name: String in MUSIC_CONTEXTS.keys():
		contexts.append(context_name)
	contexts.sort()
	return contexts


static func sfx_name_for_event(event_name: String) -> String:
	return String(SFX_EVENT_NAMES.get(event_name, ""))


static func sfx_stop_name_for_event(event_name: String) -> String:
	return String(SFX_STOP_EVENT_NAMES.get(event_name, ""))


static func is_sfx_stop_event(event_name: String) -> bool:
	return SFX_STOP_EVENT_NAMES.has(event_name)


static func has_sfx_event(event_name: String) -> bool:
	return KNOWN_SFX_EVENTS.has(event_name)


static func known_sfx_events() -> Array[String]:
	var event_names: Array[String] = []
	for event_name: String in KNOWN_SFX_EVENTS:
		event_names.append(event_name)
	event_names.sort()
	return event_names
