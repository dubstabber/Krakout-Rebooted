extends Control
class_name StaticMenuBackButton

signal activated

const FRAME_SIZE := Vector2(100, 100)
const FRAME_COUNT := 20
const SELECTED_FRAME_GATE_SECONDS := 0.02
const RETURN_FRAME_GATE_SECONDS := 0.005

var _backward_texture: Texture2D
var _frame := 0
var _selected_elapsed := 0.0
var _return_elapsed := 0.0
var _is_selected := false
var _is_hovered := false
var _has_focus := false


func _ready() -> void:
	focus_mode = Control.FOCUS_ALL
	mouse_filter = Control.MOUSE_FILTER_STOP
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	size = FRAME_SIZE
	custom_minimum_size = FRAME_SIZE
	_backward_texture = _load_asset_texture("Backward")
	mouse_entered.connect(_set_hovered.bind(true))
	mouse_exited.connect(_set_hovered.bind(false))
	focus_entered.connect(_set_focus_state.bind(true))
	focus_exited.connect(_set_focus_state.bind(false))


func _process(delta: float) -> void:
	advance(delta)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			grab_focus()
			activate()
			accept_event()
	elif event.is_action_pressed("ui_accept"):
		activate()
		accept_event()


func activate() -> void:
	activated.emit()


func advance(delta: float) -> void:
	if delta <= 0.0:
		return

	if _is_selected:
		_return_elapsed = 0.0
		_selected_elapsed += delta
		if _selected_elapsed > SELECTED_FRAME_GATE_SECONDS:
			_selected_elapsed = 0.0
			_frame = (_frame + 1) % FRAME_COUNT
			queue_redraw()
		return

	_selected_elapsed = 0.0
	if _frame == 0:
		_return_elapsed = 0.0
		return
	_return_elapsed += delta
	if _return_elapsed > RETURN_FRAME_GATE_SECONDS:
		_return_elapsed = 0.0
		_frame += 1
		if _frame >= FRAME_COUNT:
			_frame = 0
		queue_redraw()


func current_frame() -> int:
	return _frame


static func source_rect_for_frame(frame: int) -> Rect2:
	var clamped_frame := posmod(frame, FRAME_COUNT)
	return Rect2(Vector2(0, clamped_frame * FRAME_SIZE.y), FRAME_SIZE)


func _draw() -> void:
	if _backward_texture == null:
		return
	draw_texture_rect_region(
		_backward_texture,
		Rect2(Vector2.ZERO, FRAME_SIZE),
		source_rect_for_frame(_frame)
	)


func _set_hovered(is_hovered: bool) -> void:
	_is_hovered = is_hovered
	_sync_selected_state()


func _set_focus_state(has_focus: bool) -> void:
	_has_focus = has_focus
	_sync_selected_state()


func _sync_selected_state() -> void:
	_is_selected = _is_hovered or _has_focus


func _load_asset_texture(texture_name: String) -> Texture2D:
	var assets := get_node_or_null("/root/KrakoutAssets")
	if assets == null or not assets.has_method("load_texture"):
		return null
	return assets.call("load_texture", texture_name) as Texture2D
