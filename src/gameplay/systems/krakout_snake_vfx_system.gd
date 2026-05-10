extends RefCounted
class_name KrakoutSnakeVfxSystem

const GameplayStateScript := preload("res://src/gameplay/krakout_gameplay_state.gd")
const BallRulesScript := preload("res://src/gameplay/rules/krakout_ball_rules.gd")
const EnemyRulesScript := preload("res://src/gameplay/rules/krakout_enemy_rules.gd")

const BALL_SIZE := BallRulesScript.BALL_SIZE
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

const IMPACT_EFFECT_KIND_SNAKE_HIT := 1

var snake_segments: Array[Dictionary]
var _snake_update_elapsed := 0.0


func _init(shared_snake_segments = []) -> void:
	if shared_snake_segments is GameplayStateScript:
		snake_segments = shared_snake_segments.snake_segments
	else:
		snake_segments = shared_snake_segments


static func snake_rect(segment: Dictionary) -> Rect2:
	return EnemyRulesScript.snake_rect(segment)


func clear() -> void:
	snake_segments.clear()
	_snake_update_elapsed = 0.0


func visible_segments() -> Array[Dictionary]:
	var visible: Array[Dictionary] = []
	for segment: Dictionary in snake_segments:
		if bool(segment.get("active", false)):
			visible.append(segment.duplicate())
		else:
			break
	return visible


func active_count() -> int:
	return visible_segments().size()


func force_segments_for_test(segments: Array) -> int:
	clear()
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


func update(delta: float, ports: Dictionary) -> void:
	if delta <= 0.0 or not has_active_segments():
		return

	_snake_update_elapsed += delta
	while _snake_update_elapsed > SNAKE_UPDATE_SECONDS and has_active_segments():
		_snake_update_elapsed -= SNAKE_UPDATE_SECONDS
		step_segments()


func step_segments() -> void:
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


func collide_ball(ball: Dictionary, ports: Dictionary) -> bool:
	return truncate_at_rect(_ball_rect(ball), ports)


func collide_projectile(projectile: Dictionary, ports: Dictionary) -> bool:
	return truncate_at_rect(_projectile_rect(projectile, ports), ports)


func truncate_at_rect(hit_rect: Rect2, ports: Dictionary) -> bool:
	for index in range(snake_segments.size()):
		var segment: Dictionary = snake_segments[index]
		if not bool(segment.get("active", false)):
			break
		if snake_rect(segment).intersects(hit_rect):
			_spawn_impact_effect(ports, segment.get("position", Vector2.ZERO), IMPACT_EFFECT_KIND_SNAKE_HIT)
			truncate_at_index(index)
			return true
	return false


func truncate_at_index(hit_index: int) -> void:
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


func has_active_segments() -> bool:
	for segment: Dictionary in snake_segments:
		if bool(segment.get("active", false)):
			return true
		break
	return false


func _ball_rect(ball: Dictionary) -> Rect2:
	var size := float(ball.get("size", BALL_SIZE))
	return Rect2(ball.get("position", Vector2.ZERO), Vector2(size, size))


func _projectile_rect(projectile: Dictionary, ports: Dictionary) -> Rect2:
	var result = _call_port(ports, "projectile_rect", [projectile], Rect2())
	if result is Rect2:
		return result
	return Rect2()


func _spawn_impact_effect(ports: Dictionary, position: Vector2, kind: int) -> void:
	_call_port(ports, "spawn_impact_effect", [position, kind], null)


func _call_port(ports: Dictionary, key: String, args: Array = [], default_value = null):
	var callable: Callable = ports.get(key, Callable())
	if callable.is_valid():
		return callable.callv(args)
	return default_value
