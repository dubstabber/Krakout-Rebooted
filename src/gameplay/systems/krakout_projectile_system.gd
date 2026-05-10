extends RefCounted
class_name KrakoutProjectileSystem

const MAX_PROJECTILES := 10
const PROJECTILE_FIRE_COOLDOWN_SECONDS := 0.25
const PROJECTILE_STEP_X := 7.0
const PROJECTILE_EXPIRE_X := 27.0
const PROJECTILE_SIZE := Vector2(30, 13)
const PROJECTILE_TRAIL_OFFSET := Vector2(26, 0)
const PROJECTILE_HEAD_FRAME_COUNT := 5
const PROJECTILE_TRAIL_FRAME_COUNT := 10
const PROJECTILE_HEAD_FRAME_SECONDS := 0.05
const PROJECTILE_TRAIL_FRAME_SECONDS := 0.01
const PROJECTILE_TYPE_STRONG := 0
const PROJECTILE_TYPE_CONTINUOUS := 1

var projectiles: Array[Dictionary] = []
var _fire_cooldown := 0.0


func _init(projectile_store: Array[Dictionary] = []) -> void:
	projectiles = projectile_store


func reset() -> void:
	clear()
	_fire_cooldown = 0.0


func clear() -> void:
	projectiles.clear()


func active_count() -> int:
	return visible_projectiles().size()


func visible_projectiles() -> Array[Dictionary]:
	var visible: Array[Dictionary] = []
	for projectile: Dictionary in projectiles:
		if bool(projectile.get("active", false)):
			visible.append(projectile.duplicate())
	return visible


func replace_projectiles_for_test(next_projectiles: Array) -> void:
	projectiles.clear()
	for projectile in next_projectiles:
		if projectile is Dictionary:
			projectiles.append((projectile as Dictionary).duplicate())


func set_fire_cooldown_for_test(seconds: float) -> void:
	_fire_cooldown = maxf(0.0, seconds)


func fire_cooldown_remaining() -> float:
	return _fire_cooldown


func start_fire_cooldown() -> void:
	_fire_cooldown = PROJECTILE_FIRE_COOLDOWN_SECONDS


func update_fire_cooldown(delta: float) -> void:
	if _fire_cooldown <= 0.0:
		return
	_fire_cooldown = maxf(0.0, _fire_cooldown - delta)
	if is_zero_approx(_fire_cooldown):
		_fire_cooldown = 0.0


func spawn_projectile(projectile_type: int, position: Vector2) -> bool:
	compact()
	if projectiles.size() >= MAX_PROJECTILES:
		return false

	projectiles.append({
		"active": true,
		"type": projectile_type,
		"position": position,
		"head_frame": 0,
		"head_frame_elapsed": 0.0,
		"trail_frame": 0,
		"trail_frame_elapsed": 0.0,
	})
	return true


func update(delta: float, collision_resolver: Callable = Callable()) -> void:
	for index in range(projectiles.size()):
		var projectile := projectiles[index]
		if not bool(projectile.get("active", false)):
			continue

		advance_projectile(projectile, delta)
		if bool(projectile.get("active", false)) \
				and collision_resolver.is_valid() \
				and bool(collision_resolver.call(projectile)):
			projectile["active"] = false
		projectiles[index] = projectile

	compact()


func advance_projectile(projectile: Dictionary, delta: float) -> void:
	var position: Vector2 = projectile.get("position", Vector2.ZERO)
	position.x -= PROJECTILE_STEP_X
	projectile["position"] = position
	if position.x <= PROJECTILE_EXPIRE_X:
		projectile["active"] = false

	var head_elapsed := float(projectile.get("head_frame_elapsed", 0.0)) + delta
	var head_frame := int(projectile.get("head_frame", 0))
	while head_elapsed >= PROJECTILE_HEAD_FRAME_SECONDS:
		head_frame = (head_frame + 1) % PROJECTILE_HEAD_FRAME_COUNT
		head_elapsed -= PROJECTILE_HEAD_FRAME_SECONDS
	projectile["head_frame"] = head_frame
	projectile["head_frame_elapsed"] = head_elapsed

	var trail_elapsed := float(projectile.get("trail_frame_elapsed", 0.0)) + delta
	var trail_frame := int(projectile.get("trail_frame", 0))
	while trail_elapsed >= PROJECTILE_TRAIL_FRAME_SECONDS:
		trail_frame = (trail_frame + 1) % PROJECTILE_TRAIL_FRAME_COUNT
		trail_elapsed -= PROJECTILE_TRAIL_FRAME_SECONDS
	projectile["trail_frame"] = trail_frame
	projectile["trail_frame_elapsed"] = trail_elapsed


func projectile_rect(projectile: Dictionary) -> Rect2:
	return Rect2(projectile.get("position", Vector2.ZERO), PROJECTILE_SIZE)


func compact() -> void:
	var compacted: Array[Dictionary] = []
	for projectile: Dictionary in projectiles:
		if bool(projectile.get("active", false)):
			compacted.append(projectile)
	projectiles.clear()
	projectiles.append_array(compacted)
