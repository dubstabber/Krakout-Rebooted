extends Control
class_name OptionsVxEffects

const ROW_MUSIC := 0
const ROW_SFX := 1
const FRAME_SIZE := Vector2(40, 40)
const STATIC_SOURCE_SIZE := Vector2(30, 30)
const STATIC_SOURCE_ORIGIN := Vector2(400, 0)
const FRAME_COUNT := 10
const FRAME_SECONDS := 0.03
const ENABLED_TARGET_FRAME := 0
const DISABLED_TARGET_FRAME := FRAME_COUNT - 1
const INDICATOR_X := 555.0
const STATIC_INDICATOR_X := 560.0
const STATIC_INDICATOR_Y_OFFSET := 15.0
const DEFAULT_MUSIC_BASE_Y := 222.0
const DEFAULT_SFX_BASE_Y := 282.0

var vx_texture: Texture2D
var _frames: Array[int] = [DISABLED_TARGET_FRAME, DISABLED_TARGET_FRAME]
var _target_frames: Array[int] = [DISABLED_TARGET_FRAME, DISABLED_TARGET_FRAME]
var _frame_elapsed: Array[float] = [0.0, 0.0]
var _base_y: Array[float] = [DEFAULT_MUSIC_BASE_Y, DEFAULT_SFX_BASE_Y]


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	size = Vector2(640, 480)
	if vx_texture == null:
		vx_texture = _load_asset_texture("Vx")


func _process(delta: float) -> void:
	advance(delta)


func set_music_enabled(is_enabled: bool, snap: bool = false) -> void:
	set_row_enabled(ROW_MUSIC, is_enabled, snap)


func set_sfx_enabled(is_enabled: bool, snap: bool = false) -> void:
	set_row_enabled(ROW_SFX, is_enabled, snap)


func configure_row_count(row_count: int) -> void:
	if row_count <= 0:
		return
	_ensure_row(row_count - 1)


func set_row_enabled(row: int, is_enabled: bool, snap: bool = false) -> void:
	_ensure_row(row)

	var target := ENABLED_TARGET_FRAME if is_enabled else DISABLED_TARGET_FRAME
	if _target_frames[row] != target:
		_frame_elapsed[row] = 0.0
	_target_frames[row] = target
	if snap:
		_frames[row] = target
		_frame_elapsed[row] = 0.0
	queue_redraw()


func set_row_base_y(row: int, base_y: float) -> void:
	_ensure_row(row)
	_base_y[row] = base_y
	queue_redraw()


func current_frame(row: int) -> int:
	if not _is_valid_row(row):
		return DISABLED_TARGET_FRAME
	return _frames[row]


func target_frame(row: int) -> int:
	if not _is_valid_row(row):
		return DISABLED_TARGET_FRAME
	return _target_frames[row]


func advance(delta: float) -> void:
	if delta <= 0.0:
		return

	var changed := false
	for row in range(_frames.size()):
		if _frames[row] == _target_frames[row]:
			_frame_elapsed[row] = 0.0
			continue

		_frame_elapsed[row] += delta
		if _frame_elapsed[row] > FRAME_SECONDS and _frames[row] != _target_frames[row]:
			_frame_elapsed[row] = 0.0
			_frames[row] += 1 if _frames[row] < _target_frames[row] else -1
			changed = true

	if changed:
		queue_redraw()


static func source_rect_for_frame(frame: int) -> Rect2:
	var clamped_frame := clampi(frame, 0, FRAME_COUNT - 1)
	return Rect2(Vector2(float(clamped_frame) * FRAME_SIZE.x, 0), FRAME_SIZE)


static func static_source_rect() -> Rect2:
	return Rect2(STATIC_SOURCE_ORIGIN, STATIC_SOURCE_SIZE)


func indicator_rect(row: int) -> Rect2:
	if not _is_valid_row(row):
		return Rect2(Vector2.ZERO, FRAME_SIZE)
	return Rect2(Vector2(INDICATOR_X, _base_y[row] + float(_frames[row])), FRAME_SIZE)


func static_indicator_rect(row: int) -> Rect2:
	if not _is_valid_row(row):
		return Rect2(Vector2.ZERO, STATIC_SOURCE_SIZE)
	return Rect2(
		Vector2(STATIC_INDICATOR_X, _base_y[row] + STATIC_INDICATOR_Y_OFFSET),
		STATIC_SOURCE_SIZE
	)


func _draw() -> void:
	if vx_texture == null:
		return

	for row in range(_frames.size()):
		draw_texture_rect_region(vx_texture, static_indicator_rect(row), static_source_rect())
		draw_texture_rect_region(vx_texture, indicator_rect(row), source_rect_for_frame(_frames[row]))


func _is_valid_row(row: int) -> bool:
	return row >= 0 and row < _frames.size()


func _ensure_row(row: int) -> void:
	if row < 0:
		return
	while row >= _frames.size():
		var next_index := _frames.size()
		_frames.append(DISABLED_TARGET_FRAME)
		_target_frames.append(DISABLED_TARGET_FRAME)
		_frame_elapsed.append(0.0)
		if next_index == ROW_MUSIC:
			_base_y.append(DEFAULT_MUSIC_BASE_Y)
		elif next_index == ROW_SFX:
			_base_y.append(DEFAULT_SFX_BASE_Y)
		else:
			_base_y.append(DEFAULT_SFX_BASE_Y + float(next_index - ROW_SFX) * 45.0)


func _load_asset_texture(texture_name: String) -> Texture2D:
	var assets := get_node_or_null("/root/KrakoutAssets")
	if assets == null or not assets.has_method("load_texture"):
		return null
	return assets.call("load_texture", texture_name) as Texture2D
