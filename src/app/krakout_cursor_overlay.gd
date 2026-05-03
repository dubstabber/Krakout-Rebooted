extends Control
class_name KrakoutCursorOverlay

const CURSOR_TEXTURE_NAME := "Cursor"
const CURSOR_SOURCE_SIZE := Vector2(65, 58)
const CURSOR_HOTSPOT := Vector2.ZERO
const LOGO_TEXTURE_NAME := "Welogo"
const LOGO_FRAME_SIZE := Vector2(40, 40)
const LOGO_FRAME_COLUMNS := 5
const LOGO_FRAME_COUNT := 30
const LOGO_FRAME_SECONDS := 0.03
const LOGO_OFFSET := Vector2(19, 12)

var _cursor_texture: Texture2D
var _logo_texture: Texture2D
var _cursor_position := Vector2.ZERO
var _cursor_active := false
var _logo_frame_index := 0
var _logo_frame_elapsed := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	set_anchors_preset(Control.PRESET_FULL_RECT)
	visible = false
	_cursor_position = get_viewport().get_mouse_position()
	_cursor_texture = _load_cursor_texture()
	_logo_texture = _load_logo_texture()


func _process(delta: float) -> void:
	advance_animation(delta)


func advance_animation(delta: float) -> void:
	if not _cursor_active:
		return

	_logo_frame_elapsed += delta
	while _logo_frame_elapsed >= LOGO_FRAME_SECONDS:
		_logo_frame_elapsed -= LOGO_FRAME_SECONDS
		_logo_frame_index = (_logo_frame_index + 1) % LOGO_FRAME_COUNT
		queue_redraw()


func _input(event: InputEvent) -> void:
	if not _cursor_active:
		return

	var motion_event := event as InputEventMouseMotion
	if motion_event == null:
		return

	_cursor_position = motion_event.position
	queue_redraw()


func set_cursor_active(is_active: bool) -> void:
	_cursor_active = is_active
	visible = is_active
	if is_active:
		_cursor_position = get_viewport().get_mouse_position()
		queue_redraw()


func is_cursor_active() -> bool:
	return _cursor_active


func cursor_position() -> Vector2:
	return _cursor_position


func cursor_texture_size() -> Vector2i:
	if _cursor_texture == null:
		return Vector2i.ZERO
	return Vector2i(_cursor_texture.get_width(), _cursor_texture.get_height())


func logo_texture_size() -> Vector2i:
	if _logo_texture == null:
		return Vector2i.ZERO
	return Vector2i(_logo_texture.get_width(), _logo_texture.get_height())


func current_logo_frame_index() -> int:
	return _logo_frame_index


func _draw() -> void:
	if not _cursor_active or _cursor_texture == null:
		return

	var cursor_destination := Rect2(_cursor_position - CURSOR_HOTSPOT, CURSOR_SOURCE_SIZE)
	draw_texture_rect_region(_cursor_texture, cursor_destination, Rect2(Vector2.ZERO, CURSOR_SOURCE_SIZE))

	if _logo_texture == null:
		return

	var logo_column := _logo_frame_index % LOGO_FRAME_COLUMNS
	var logo_row := int(_logo_frame_index / LOGO_FRAME_COLUMNS)
	var logo_source := Rect2(Vector2(logo_column, logo_row) * LOGO_FRAME_SIZE, LOGO_FRAME_SIZE)
	var logo_destination := Rect2(_cursor_position + LOGO_OFFSET - CURSOR_HOTSPOT, LOGO_FRAME_SIZE)
	draw_texture_rect_region(_logo_texture, logo_destination, logo_source)


func _load_cursor_texture() -> Texture2D:
	return _load_asset_texture(CURSOR_TEXTURE_NAME)


func _load_logo_texture() -> Texture2D:
	return _load_asset_texture(LOGO_TEXTURE_NAME)


func _load_asset_texture(texture_name: String) -> Texture2D:
	var assets := get_node_or_null("/root/KrakoutAssets")
	if assets == null or not assets.has_method("load_texture"):
		return null
	return assets.call("load_texture", texture_name) as Texture2D
