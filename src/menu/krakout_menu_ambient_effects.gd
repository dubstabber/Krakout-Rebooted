extends Control
class_name KrakoutMenuAmbientEffects

const RandomScript := preload("res://src/gameplay/krakout_random.gd")
const PlayfieldSpecScript := preload("res://src/playfield/krakout_playfield_spec.gd")

const STAR_COUNT := 70
const STAR_FRAME_SIZE := Vector2(30, 30)
const STAR_FRAME_COUNT := 20
const STAR_INITIAL_FRAME_COUNT := 10
const STAR_MIN_DELAY_MS := 70
const STAR_DELAY_RANGE_MS := 30
const STAR_SPEED_SCALE := 50.0
const STAR_MOVE_SCALE := 0.1
const STAR_STEP_SECONDS := 1.0 / 50.0
const STAR_DIRECTION_SECONDS := 10.0
const STAR_LEFT_WRAP := -30.0
const STAR_TOP_WRAP := -30.0
const STAR_RIGHT_WRAP := 640.0
const STAR_BOTTOM_WRAP := 480.0

const TITLE_POSITION := Vector2(122, 70)
const TITLE_SIZE := Vector2(396, 75)
const TITLE_PHASE_STEP_DEGREES := 11.0
const TITLE_PHASE_STEP_SECONDS := 0.02
const TITLE_ROW_PHASE_STEP_DEGREES := 4.0
const TITLE_WAVE_AMPLITUDE := 5.0

var stars_texture: Texture2D
var title_texture: Texture2D
var _stars: Array[Dictionary] = []
var _star_step_elapsed := 0.0
var _direction_elapsed := 0.0
var _direction_index := 0
var _title_phase_elapsed := 0.0
var _title_phase_degrees := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	custom_minimum_size = Vector2(PlayfieldSpecScript.VIEWPORT_SIZE)
	size = Vector2(PlayfieldSpecScript.VIEWPORT_SIZE)
	if stars_texture == null:
		stars_texture = _load_asset_texture("Stars")
	if title_texture == null:
		title_texture = _load_asset_texture("Title")
	if _stars.is_empty():
		reset_original_state()


func _process(delta: float) -> void:
	advance(delta)


func reset_original_state(seed_value: int = 31415) -> void:
	_stars = generate_original_stars(seed_value)
	_star_step_elapsed = 0.0
	_direction_elapsed = 0.0
	_direction_index = 0
	_title_phase_elapsed = 0.0
	_title_phase_degrees = 0.0
	queue_redraw()


func advance(delta: float) -> void:
	if delta <= 0.0:
		return

	_update_star_frames(delta)
	_star_step_elapsed += delta
	while _star_step_elapsed >= STAR_STEP_SECONDS:
		_star_step_elapsed -= STAR_STEP_SECONDS
		_step_stars()

	_direction_elapsed += delta
	while _direction_elapsed >= STAR_DIRECTION_SECONDS:
		_direction_elapsed -= STAR_DIRECTION_SECONDS
		_direction_index = (_direction_index + 1) % 4

	_title_phase_elapsed += delta
	if _title_phase_elapsed > TITLE_PHASE_STEP_SECONDS:
		_title_phase_elapsed = 0.0
		_title_phase_degrees = fposmod(_title_phase_degrees + TITLE_PHASE_STEP_DEGREES, 360.0)

	queue_redraw()


func stars_snapshot() -> Array[Dictionary]:
	var snapshot: Array[Dictionary] = []
	for star: Dictionary in _stars:
		snapshot.append(star.duplicate())
	return snapshot


func set_stars_for_test(stars: Array[Dictionary]) -> void:
	_stars.clear()
	for star: Dictionary in stars:
		_stars.append(star.duplicate())
	queue_redraw()


func direction_index() -> int:
	return _direction_index


func title_phase_degrees() -> float:
	return _title_phase_degrees


func title_target_rect() -> Rect2:
	return Rect2(TITLE_POSITION, TITLE_SIZE)


static func generate_original_stars(seed_value: int = 31415) -> Array[Dictionary]:
	var rng = RandomScript.new(seed_value)
	var generated: Array[Dictionary] = []
	for _index in range(STAR_COUNT):
		var position := Vector2(
			float(rng.next_mod(int(PlayfieldSpecScript.VIEWPORT_SIZE.x))),
			float(rng.next_mod(int(PlayfieldSpecScript.VIEWPORT_SIZE.y)))
		)
		var speed := Vector2(
			float(rng.next_state()) / float(RandomScript.MODULUS - 1) * STAR_SPEED_SCALE,
			float(rng.next_state()) / float(RandomScript.MODULUS - 1) * STAR_SPEED_SCALE
		)
		generated.append({
			"position": position,
			"speed": speed,
			"frame": rng.next_mod(STAR_INITIAL_FRAME_COUNT),
			"delay_ms": rng.next_mod(STAR_DELAY_RANGE_MS) + STAR_MIN_DELAY_MS,
			"frame_elapsed_ms": 0.0,
		})
	return generated


static func star_source_rect(frame: int) -> Rect2:
	return Rect2(
		Vector2(float(posmod(frame, STAR_FRAME_COUNT)) * STAR_FRAME_SIZE.x, 0),
		STAR_FRAME_SIZE
	)


static func star_target_rect(position: Vector2) -> Rect2:
	return Rect2(position, STAR_FRAME_SIZE)


static func title_source_rect_for_row(row: int) -> Rect2:
	var clamped_row := clampi(row, 0, int(TITLE_SIZE.y) - 1)
	return Rect2(Vector2(0, clamped_row), Vector2(TITLE_SIZE.x, 1))


static func title_offset_for_row(row: int, phase_degrees: float) -> int:
	var wave_degrees := phase_degrees + float(row) * TITLE_ROW_PHASE_STEP_DEGREES
	return int(sin(deg_to_rad(wave_degrees)) * TITLE_WAVE_AMPLITUDE)


static func title_target_rect_for_row(row: int, phase_degrees: float) -> Rect2:
	var clamped_row := clampi(row, 0, int(TITLE_SIZE.y) - 1)
	return Rect2(
		TITLE_POSITION + Vector2(title_offset_for_row(clamped_row, phase_degrees), clamped_row),
		Vector2(TITLE_SIZE.x, 1)
	)


func _draw() -> void:
	if stars_texture != null:
		for star: Dictionary in _stars:
			var frame := int(star.get("frame", 0))
			var position: Vector2 = star.get("position", Vector2.ZERO)
			draw_texture_rect_region(stars_texture, star_target_rect(position), star_source_rect(frame))

	if title_texture != null:
		for row in range(int(TITLE_SIZE.y)):
			draw_texture_rect_region(
				title_texture,
				title_target_rect_for_row(row, _title_phase_degrees),
				title_source_rect_for_row(row)
			)


func _update_star_frames(delta: float) -> void:
	var delta_ms: float = delta * 1000.0
	for index in range(_stars.size()):
		var star: Dictionary = _stars[index]
		var elapsed: float = float(star.get("frame_elapsed_ms", 0.0)) + delta_ms
		var delay_ms: int = max(1, int(star.get("delay_ms", STAR_MIN_DELAY_MS)))
		var frame: int = int(star.get("frame", 0))
		while elapsed >= float(delay_ms):
			elapsed -= float(delay_ms)
			frame = (frame + 1) % STAR_FRAME_COUNT
		star["frame"] = frame
		star["frame_elapsed_ms"] = elapsed
		_stars[index] = star


func _step_stars() -> void:
	for index in range(_stars.size()):
		var star: Dictionary = _stars[index]
		var position: Vector2 = star.get("position", Vector2.ZERO)
		var speed: Vector2 = star.get("speed", Vector2.ZERO)
		match _direction_index:
			0:
				position += speed * STAR_MOVE_SCALE
			1:
				position += Vector2(-speed.x, speed.y) * STAR_MOVE_SCALE
			2:
				position -= speed * STAR_MOVE_SCALE
			3:
				position += Vector2(speed.x, -speed.y) * STAR_MOVE_SCALE

		if position.y > STAR_BOTTOM_WRAP:
			position.y = STAR_TOP_WRAP
		if position.y < STAR_TOP_WRAP:
			position.y = STAR_BOTTOM_WRAP
		if position.x < STAR_LEFT_WRAP:
			position.x = STAR_RIGHT_WRAP
		if position.x > STAR_RIGHT_WRAP:
			position.x = STAR_LEFT_WRAP

		star["position"] = position
		_stars[index] = star


func _load_asset_texture(texture_name: String) -> Texture2D:
	var assets := get_node_or_null("/root/KrakoutAssets")
	if assets == null or not assets.has_method("load_texture"):
		return null
	return assets.call("load_texture", texture_name) as Texture2D
